import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hive/hive.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

/// Model for a chat session
class ChatSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Map<String, dynamic>> messages;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'messages': messages,
      };

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
        id: json['id'],
        title: json['title'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        messages: List<Map<String, dynamic>>.from(json['messages']),
      );
}

class LinkSkoolAIChatPage extends StatefulWidget {
  const LinkSkoolAIChatPage({super.key});

  @override
  State<LinkSkoolAIChatPage> createState() => _LinkSkoolAIChatPageState();
}

class _LinkSkoolAIChatPageState extends State<LinkSkoolAIChatPage> {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: 'user');
  final _ai = const types.User(id: 'ai', firstName: 'LinkSkool AI');
  bool _isTyping = false;
  final Dio _dio = Dio();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Chat history
  List<ChatSession> _chatSessions = [];
  String? _currentSessionId;
  late Box _chatBox;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeChatHistory();
  }

  Future<void> _initializeChatHistory() async {
    try {
      _chatBox = await Hive.openBox('ai_chat_history');
      await _loadChatSessions();

      // Start with a new chat or load the most recent one
      if (_chatSessions.isEmpty) {
        _startNewChat();
      } else {
        // Load the most recent session
        _loadSession(_chatSessions.first.id);
      }

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing chat history: $e');
      _startNewChat();
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _loadChatSessions() async {
    try {
      final sessionsJson = _chatBox.get('sessions', defaultValue: '[]');
      final List<dynamic> sessionsList = jsonDecode(sessionsJson);
      _chatSessions = sessionsList
          .map((json) => ChatSession.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      // Sort by updatedAt descending (most recent first)
      _chatSessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (e) {
      print('Error loading chat sessions: $e');
      _chatSessions = [];
    }
  }

  Future<void> _saveChatSessions() async {
    try {
      final sessionsJson =
          jsonEncode(_chatSessions.map((s) => s.toJson()).toList());
      await _chatBox.put('sessions', sessionsJson);
    } catch (e) {
      print('Error saving chat sessions: $e');
    }
  }

  Future<void> _saveCurrentSession() async {
    if (_currentSessionId == null) return;

    final sessionIndex =
        _chatSessions.indexWhere((s) => s.id == _currentSessionId);
    if (sessionIndex == -1) return;

    // Convert messages to JSON-serializable format
    final messagesJson = _messages
        .map((msg) {
          if (msg is types.TextMessage) {
            return {
              'type': 'text',
              'id': msg.id,
              'authorId': msg.author.id,
              'text': msg.text,
              'createdAt': msg.createdAt,
            };
          }
          return null;
        })
        .where((m) => m != null)
        .toList();

    // Generate title from first user message if not set
    String title = _chatSessions[sessionIndex].title;
    if (title == 'New Chat' && _messages.length > 1) {
      final firstUserMsg = _messages.reversed.firstWhere(
        (m) => m is types.TextMessage && m.author.id == _user.id,
        orElse: () => _messages.last,
      );
      if (firstUserMsg is types.TextMessage) {
        title = firstUserMsg.text.length > 30
            ? '${firstUserMsg.text.substring(0, 30)}...'
            : firstUserMsg.text;
      }
    }

    _chatSessions[sessionIndex] = ChatSession(
      id: _currentSessionId!,
      title: title,
      createdAt: _chatSessions[sessionIndex].createdAt,
      updatedAt: DateTime.now(),
      messages: List<Map<String, dynamic>>.from(messagesJson),
    );

    // Re-sort sessions
    _chatSessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    await _saveChatSessions();
  }

  void _loadSession(String sessionId) {
    final session = _chatSessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => _chatSessions.first,
    );

    _currentSessionId = session.id;
    _messages.clear();

    // Convert stored messages back to types.Message
    for (final msgJson in session.messages) {
      if (msgJson['type'] == 'text') {
        final author = msgJson['authorId'] == _user.id ? _user : _ai;
        _messages.add(types.TextMessage(
          id: msgJson['id'],
          author: author,
          text: msgJson['text'],
          createdAt: msgJson['createdAt'],
        ));
      }
    }

    // Reverse to show newest first (chat UI expects this order)
    _messages.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));

    setState(() {});
  }

  void _startNewChat() {
    final sessionId = const Uuid().v4();
    final now = DateTime.now();

    final newSession = ChatSession(
      id: sessionId,
      title: 'New Chat',
      createdAt: now,
      updatedAt: now,
      messages: [],
    );

    _chatSessions.insert(0, newSession);
    _currentSessionId = sessionId;
    _messages.clear();

    // Add welcome message
    final initialMessage = types.TextMessage(
      author: _ai,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text:
          'Hi! 👋 I\'m LinkSkool AI. How can I help you with your studies today?',
    );
    _messages.insert(0, initialMessage);

    _saveChatSessions();
    setState(() {});
  }

  Future<void> _deleteSession(String sessionId) async {
    _chatSessions.removeWhere((s) => s.id == sessionId);
    await _saveChatSessions();

    // If we deleted the current session, switch to another or start new
    if (_currentSessionId == sessionId) {
      if (_chatSessions.isNotEmpty) {
        _loadSession(_chatSessions.first.id);
      } else {
        _startNewChat();
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _dio.close();
    super.dispose();
  }

  void _handleSendPressed(types.PartialText message) async {
    final userMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    setState(() {
      _messages.insert(0, userMessage);
      _isTyping = true;
    });

    // Save after user message
    await _saveCurrentSession();

    try {
      final response = await _getAIResponse(message.text);

      final aiMessage = types.TextMessage(
        author: _ai,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: response,
      );

      if (mounted) {
        setState(() {
          _messages.insert(0, aiMessage);
          _isTyping = false;
        });
        // Save after AI response
        await _saveCurrentSession();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
        });

        final errorMessage = types.TextMessage(
          author: _ai,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: const Uuid().v4(),
          text: 'Sorry, I encountered an error. Please try again.',
        );

        setState(() {
          _messages.insert(0, errorMessage);
        });
      }
    }
  }

  Future<String> _getAIResponse(String userMessage) async {
    try {
      final response = await _dio.post(
        EnvConfig.deepSeekUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${EnvConfig.deepSeekApiKey}',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are LinkSkool AI, a helpful educational assistant. Provide clear and concise responses. Use markdown formatting when appropriate (e.g., **bold**, *italic*, lists, etc.).'
            },
            {
              'role': 'user',
              'content': userMessage,
            }
          ],
          'temperature': 0.7,
          'max_tokens': 1000,
        },
      );

      if (response.statusCode == 200) {
        final choices = response.data['choices'] as List;
        if (choices.isNotEmpty) {
          final message = choices[0]['message']['content'];
          return message ?? 'No response received.';
        }
        return 'No response received.';
      } else {
        return 'Error: ${response.statusCode}';
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return 'Authentication failed. Please check the API key.';
      } else {
        return 'Network error. Please try again.';
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  void _showAboutDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.eLearningBtnColor1,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'About LinkSkool AI',
                      style: AppTextStyles.normal700(
                        fontSize: 20,
                        color: AppColors.text4Light,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard(
                      'What I can do',
                      'I\'m here to help with your studies! Ask me questions about any subject, get explanations, practice problems, or study tips.',
                      Icons.psychology_outlined,
                      AppColors.eLearningBtnColor1,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      'How to use',
                      'Simply type your question in the chat box below. I\'ll do my best to provide clear and helpful answers.',
                      Icons.chat_bubble_outline,
                      Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      'Tips for best results',
                      'Be specific with your questions. The more details you provide, the better I can help you understand.',
                      Icons.lightbulb_outline,
                      Colors.green,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      String title, String content, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.normal600(
                  fontSize: 14,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: AppTextStyles.normal400(
              fontSize: 14,
              color: AppColors.text4Light,
            ),
          ),
        ],
      ),
    );
  }

  /// Convert markdown to HTML
  String _markdownToHtml(String markdown) {
    return md.markdownToHtml(
      markdown,
      extensionSet: md.ExtensionSet.gitHubWeb,
    );
  }

  /// Custom text message builder with markdown support
  Widget _buildTextMessage(
    types.TextMessage message, {
    required int messageWidth,
    required bool showName,
  }) {
    final isUserMessage = message.author.id == _user.id;
    final backgroundColor =
        isUserMessage ? AppColors.eLearningBtnColor1 : Colors.grey.shade200;
    final textColor = isUserMessage ? Colors.white : AppColors.text4Light;

    // For user messages, show plain text
    if (isUserMessage) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: AppTextStyles.normal400(
            fontSize: 15,
            color: textColor,
          ),
        ),
      );
    }

    // For AI messages, render markdown
    final htmlContent = _markdownToHtml(message.text);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Html(
        data: htmlContent,
        style: {
          "body": Style(
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
            fontSize: FontSize(15),
            color: textColor,
          ),
          "p": Style(
            margin: Margins.only(bottom: 8),
            padding: HtmlPaddings.zero,
          ),
          "h1": Style(
            fontSize: FontSize(22),
            fontWeight: FontWeight.bold,
            margin: Margins.only(bottom: 8, top: 4),
          ),
          "h2": Style(
            fontSize: FontSize(20),
            fontWeight: FontWeight.bold,
            margin: Margins.only(bottom: 8, top: 4),
          ),
          "h3": Style(
            fontSize: FontSize(18),
            fontWeight: FontWeight.bold,
            margin: Margins.only(bottom: 6, top: 4),
          ),
          "h4": Style(
            fontSize: FontSize(16),
            fontWeight: FontWeight.bold,
            margin: Margins.only(bottom: 4, top: 2),
          ),
          "strong": Style(
            fontWeight: FontWeight.bold,
          ),
          "em": Style(
            fontStyle: FontStyle.italic,
          ),
          "ul": Style(
            margin: Margins.only(left: 16, bottom: 8),
          ),
          "ol": Style(
            margin: Margins.only(left: 16, bottom: 8),
          ),
          "li": Style(
            margin: Margins.only(bottom: 4),
          ),
          "blockquote": Style(
            border: Border(
              left: BorderSide(
                color: AppColors.eLearningBtnColor1,
                width: 3,
              ),
            ),
            padding: HtmlPaddings.only(left: 12),
            margin: Margins.symmetric(vertical: 8),
            fontStyle: FontStyle.italic,
            color: Colors.grey.shade600,
          ),
          "a": Style(
            color: AppColors.eLearningBtnColor1,
            textDecoration: TextDecoration.underline,
          ),
        },
      ),
    );
  }

  /// Build the chat history drawer
  Widget _buildChatHistoryDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.eLearningBtnColor1,
              ),
              child: Row(
                children: [
                  const Icon(Icons.history, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Chat History',
                      style: AppTextStyles.normal600(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // New Chat Button
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _startNewChat();
                  },
                  icon: const Icon(Icons.add, size: 20),
                  label: Text(
                    'New Chat',
                    style: AppTextStyles.normal600(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.eLearningBtnColor1,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),

            const Divider(height: 1),

            // Chat Sessions List
            Expanded(
              child: _chatSessions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No chat history',
                            style: AppTextStyles.normal500(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _chatSessions.length,
                      itemBuilder: (context, index) {
                        final session = _chatSessions[index];
                        final isActive = session.id == _currentSessionId;

                        return _buildSessionTile(session, isActive);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionTile(ChatSession session, bool isActive) {
    return Dismissible(
      key: Key(session.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.shade400,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Chat'),
                content:
                    const Text('Are you sure you want to delete this chat?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (direction) {
        _deleteSession(session.id);
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.eLearningBtnColor1.withOpacity(0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.chat_bubble_outline,
            size: 20,
            color:
                isActive ? AppColors.eLearningBtnColor1 : Colors.grey.shade600,
          ),
        ),
        title: Text(
          session.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.normal500(
            fontSize: 14,
            color:
                isActive ? AppColors.eLearningBtnColor1 : AppColors.text4Light,
          ),
        ),
        subtitle: Text(
          _formatDate(session.updatedAt),
          style: AppTextStyles.normal400(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
        selected: isActive,
        selectedTileColor: AppColors.eLearningBtnColor1.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: () {
          Navigator.pop(context);
          _loadSession(session.id);
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.eLearningBtnColor1,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'LinkSkool AI',
            style: AppTextStyles.normal600(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: _buildChatHistoryDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.eLearningBtnColor1,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LinkSkool AI',
              style: AppTextStyles.normal600(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            Text(
              'Your AI study companion',
              style: AppTextStyles.normal400(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
        actions: [
          // New chat button
          IconButton(
            icon: const Icon(Icons.add_comment_outlined, color: Colors.white),
            onPressed: _startNewChat,
            tooltip: 'New Chat',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              _showAboutDialog();
            },
          ),
        ],
      ),
      body: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _user,
        showUserAvatars: true,
        showUserNames: true,
        textMessageBuilder: _buildTextMessage,
        typingIndicatorOptions: TypingIndicatorOptions(
          typingUsers: _isTyping ? [_ai] : [],
        ),
        theme: DefaultChatTheme(
          backgroundColor: Colors.grey.shade50,
          primaryColor: AppColors.eLearningBtnColor1,
          secondaryColor: Colors.grey.shade200,
          inputBackgroundColor: Colors.white,
          inputTextColor: AppColors.text4Light,
          inputBorderRadius: BorderRadius.circular(24),
          messageBorderRadius: 16,
          sentMessageBodyTextStyle: AppTextStyles.normal400(
            fontSize: 15,
            color: Colors.white,
          ),
          receivedMessageBodyTextStyle: AppTextStyles.normal400(
            fontSize: 15,
            color: AppColors.text4Light,
          ),
          inputTextStyle: AppTextStyles.normal400(
            fontSize: 15,
            color: AppColors.text4Light,
          ),
        ),
        inputOptions: InputOptions(
          sendButtonVisibilityMode: SendButtonVisibilityMode.always,
        ),
        emptyState: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.smart_toy_rounded,
                size: 64,
                color: AppColors.eLearningBtnColor1.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Start a conversation',
                style: AppTextStyles.normal600(
                  fontSize: 18,
                  color: AppColors.text4Light,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ask me anything about your studies and I\'ll help you understand it better!',
                textAlign: TextAlign.center,
                style: AppTextStyles.normal400(
                  fontSize: 14,
                  color: AppColors.text7Light,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
