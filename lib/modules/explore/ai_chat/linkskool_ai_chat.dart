import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    final initialMessage = types.TextMessage(
      author: _ai,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: 'Hi! 👋 I\'m LinkSkool AI. How can I help you with your studies today?',
    );

    setState(() {
      _messages.insert(0, initialMessage);
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.eLearningBtnColor1,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
