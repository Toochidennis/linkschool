import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';

class DiscussionCommentComposeSheet extends StatefulWidget {
  final Future<String?> Function(String text) onSend;

  const DiscussionCommentComposeSheet({
    super.key,
    required this.onSend,
  });

  @override
  State<DiscussionCommentComposeSheet> createState() =>
      _DiscussionCommentComposeSheetState();
}

class _DiscussionCommentComposeSheetState
    extends State<DiscussionCommentComposeSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add a comment',
              style: AppTextStyles.normal700(
                fontSize: 16,
                color: AppColors.text4Light,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              minLines: 3,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Write your comment…',
                hintStyle: AppTextStyles.normal500(
                  fontSize: 14,
                  color: AppColors.text7Light,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.textFieldBorderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.textFieldBorderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF2563EB),
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (context, value, _) {
                  final canSend =
                      value.text.trim().isNotEmpty && !_isSubmitting;
                  return ElevatedButton(
                    onPressed: canSend
                        ? () async {
                            final navigator = Navigator.of(context);
                            FocusScope.of(context).unfocus();
                            setState(() {
                              _isSubmitting = true;
                              _errorText = null;
                            });
                            try {
                              final errorMessage =
                                  await widget.onSend(_controller.text.trim());
                              if (!mounted) return;

                              if (errorMessage == null) {
                                navigator.pop();
                                return;
                              }

                              setState(() => _errorText = errorMessage);
                            } finally {
                              if (mounted) {
                                setState(() => _isSubmitting = false);
                              }
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.eLearningBtnColor1,
                      disabledBackgroundColor:
                          AppColors.eLearningBtnColor1.withValues(alpha: 0.4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Post Comment',
                            style: AppTextStyles.normal600(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                  );
                },
              ),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorText!,
                style: AppTextStyles.normal500(
                  fontSize: 13,
                  color: Colors.red,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
