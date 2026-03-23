import 'dart:async';

import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/widgets/network_dialog.dart';

class CbtContinueAdsDialog extends StatefulWidget {
  final Future<bool> Function()? onWatchAds;
  final Future<bool> Function()? onSubscribe;
  final VoidCallback? onSubmitTest;

  const CbtContinueAdsDialog({
    super.key,
    this.onWatchAds,
    this.onSubscribe,
    this.onSubmitTest,
  });

  @override
  State<CbtContinueAdsDialog> createState() => _CbtContinueAdsDialogState();
}

class _CbtContinueAdsDialogState extends State<CbtContinueAdsDialog> {
  bool _isProcessing = false;
  int _retrySeconds = 0;
  Timer? _retryTimer;
  String? _retryMessage;

  bool get _isRetrying => _retrySeconds > 0;

  Future<void> _handleWatchAds() async {
    if (_isProcessing || _isRetrying) return;
    final online = await NetworkDialog.ensureOnline(context);
    if (!online) return;
    _retryTimer?.cancel();
    setState(() {
      _isProcessing = true;
      _retrySeconds = 0;
      _retryMessage = null;
    });
    bool success = false;
    try {
      success = await (widget.onWatchAds?.call() ?? Future.value(false));
    } catch (_) {
      success = false;
    }
    if (!mounted) return;
    setState(() => _isProcessing = false);
    if (success) {
      Navigator.pop(context, 'ads');
    } else {
      _startRetryCountdown();
    }
  }

  Future<void> _handleSubscribe() async {
    if (_isProcessing || _isRetrying) return;
    setState(() => _isProcessing = true);
    final success = await (widget.onSubscribe?.call() ?? Future.value(false));
    if (!mounted) return;
    setState(() => _isProcessing = false);
    if (success) {
      Navigator.pop(context, 'subscribe');
    }
  }

  void _startRetryCountdown() {
    _retryTimer?.cancel();
    setState(() {
      _retrySeconds = 10;
      _retryMessage = 'Ad failed to load. Retry in $_retrySeconds s';
    });
    _retryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _retrySeconds -= 1;
        if (_retrySeconds <= 0) {
          _retrySeconds = 0;
          _retryMessage = 'Please try again.';
          timer.cancel();
        } else {
          _retryMessage = 'Ad failed to load. Retry in $_retrySeconds s';
        }
      });
    });
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 32,
              spreadRadius: 2,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Icon Badge ──
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.eLearningBtnColor1.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.eLearningBtnColor1.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.lock_clock_rounded,
                  size: 36,
                  color: AppColors.eLearningBtnColor1,
                ),
              ),
              const SizedBox(height: 16),

              // ── Title ──
              Text(
                'Trial Limit Reached!',
                style: AppTextStyles.normal700(
                  fontSize: 22,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You\'ve used all 10 free questions.\nChoose how to keep going.',
                textAlign: TextAlign.center,
                style: AppTextStyles.normal400(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),

              // ── Subscribe Button (Primary CTA) ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      (_isProcessing || _isRetrying) ? null : _handleSubscribe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade500,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.payments_sharp,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Pay Now',
                        style: AppTextStyles.normal600(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── OR Divider ──
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.grey.shade300,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR',
                      style: AppTextStyles.normal500(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.grey.shade300,
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Continue with Ads Button (Secondary) ──
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed:
                      (_isProcessing || _isRetrying) ? null : _handleWatchAds,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.eLearningBtnColor1,
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_circle_outline_rounded,
                        color: AppColors.eLearningBtnColor1,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Continue with Ads',
                        style: AppTextStyles.normal600(
                          fontSize: 15,
                          color: AppColors.eLearningBtnColor1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              if (_isProcessing) ...[
                const LinearProgressIndicator(),
                const SizedBox(height: 12),
                Text(
                  'Loading ad...',
                  style: AppTextStyles.normal500(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              if (_retryMessage != null) ...[
                Text(
                  _retryMessage!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.normal500(
                    fontSize: 13,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // ── Submit Test link ──
              InkWell(
                onTap:
                    (_isProcessing || _isRetrying) ? null : widget.onSubmitTest,
                child: Text(
                  'Submit Test',
                  style: AppTextStyles.normal500(
                    fontSize:18,
                    color: AppColors.eLearningBtnColor1,
                  ).copyWith(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
