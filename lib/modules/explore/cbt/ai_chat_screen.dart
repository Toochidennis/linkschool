import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/services/explore/explanation_model.dart';
import 'package:uuid/uuid.dart';

class AIChatScreen extends StatefulWidget {
  final String question;
  final String initialExplanation;
  final String correctAnswer;
  final String selectedAnswer;

  const AIChatScreen({
    super.key,
    required this.question,
    required this.initialExplanation,
    required this.correctAnswer,
    required this.selectedAnswer,
  });

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: 'user');
  final _ai = const types.User(id: 'ai', firstName: 'AI Tutor');
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    // Add the initial explanation as the first AI message
    final initialMessage = types.TextMessage(
      author: _ai,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: widget.initialExplanation,
    );

    // Add a system message with context
    final contextMessage = types.SystemMessage(
      id: const Uuid().v4(),
      createdAt: DateTime.now().millisecondsSinceEpoch - 1000,
      text: 'Ask me anything about this question!',
    );

    setState(() {
      _messages.insert(0, initialMessage);
      _messages.insert(0, contextMessage);
    });
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
      // Get AI response
      final aiResponse = await DeepSeekService.getFollowUpExplanation(
        question: widget.question,
        originalExplanation: widget.initialExplanation,
        followUpQuestion: message.text,
      );

      final aiMessage = types.TextMessage(
        author: _ai,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        text: aiResponse,
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

        // Show error message
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
              'AI Tutor',
              style: AppTextStyles.normal600(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            Text(
              'Ask me anything about this question',
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
              _showQuestionContext();
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
          systemMessageTheme: SystemMessageTheme(
            textStyle: AppTextStyles.normal500(
              fontSize: 13,
              color: AppColors.text7Light,
            ), margin: const EdgeInsets.symmetric(vertical: 8),
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
                Icons.question_answer_rounded,
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
                'Ask me anything about the question and I\'ll help you understand it better!',
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

  void _showQuestionContext() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
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
                      'Question Context',
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
                    // Question
                    _buildContextCard(
                      'Question',
                      widget.question,
                      Icons.help_outline,
                      AppColors.eLearningBtnColor1,
                    ),
                    const SizedBox(height: 16),

                    // Your Answer
                    _buildContextCard(
                      'Your Answer',
                      widget.selectedAnswer,
                      Icons.person_outline,
                      Colors.orange,
                    ),
                    const SizedBox(height: 16),

                    // Correct Answer
                    _buildContextCard(
                      'Correct Answer',
                      widget.correctAnswer,
                      Icons.check_circle_outline,
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

  Widget _buildContextCard(
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
}
