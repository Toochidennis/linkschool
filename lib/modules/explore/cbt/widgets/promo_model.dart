import 'package:flutter/material.dart';

class PromoInterstitialDialog extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  final String? ctaLabel;

  const PromoInterstitialDialog({
    super.key,
    required this.imageUrl,
    required this.onTap,
    required this.onDismiss,
    this.ctaLabel,
  });

  static void show({
    required BuildContext context,
    required String imageUrl,
    required VoidCallback onTap,
    String? ctaLabel,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.75),
      barrierDismissible: false,
      builder: (_) => PromoInterstitialDialog(
        imageUrl: imageUrl,
        onTap: onTap,
        onDismiss: () => Navigator.of(context).pop(),
        ctaLabel: ctaLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // ── Tappable image ──────────────────────────────────────
          GestureDetector(
            onTap: onTap,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        height: 300,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                              : null,
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/promo.png',
                      fit: BoxFit.contain,
                      height: 300,
                    ),
                  ),
                ),

                // ── CTA hint below image ──────────────────────────
                if (ctaLabel != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ctaLabel!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded,
                            size: 16, color: Colors.black87),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── X close button (top right) ──────────────────────────
          Positioned(
            top: -16,
            right: -16,
            child: GestureDetector(
              onTap: onDismiss,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.close, size: 18, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }
}