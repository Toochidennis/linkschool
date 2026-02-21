import 'package:flutter/material.dart';
import 'package:linkschool/modules/services/network/connectivity_service.dart';

class NetworkDialog {
  static Future<bool> ensureOnline(
    BuildContext context, {
    // --- Text Customization ---
    String title = 'No Internet Connection',
    String message =
        'This action requires an internet connection. Please connect and try again.',
    String buttonText = 'OK',

    // --- Icon Customization ---
    IconData icon = Icons.wifi_off_rounded,
    Color iconColor = const Color(0xFFE53935),
    double iconSize = 48,

    // --- Container/Card Customization ---
    Color backgroundColor = Colors.white,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
    double? width,
    BoxDecoration? decoration,

    // --- Title Style ---
    TextStyle? titleStyle,

    // --- Message Style ---
    TextStyle? messageStyle,

    // --- Button Customization ---
    Color buttonColor = const Color(0xFF1E88E5),
    Color buttonTextColor = Colors.white,
    BorderRadius? buttonBorderRadius,
    EdgeInsetsGeometry buttonPadding =
        const EdgeInsets.symmetric(horizontal: 32, vertical: 12),

    // --- Spacing ---
    double iconBottomSpacing = 16,
    double titleBottomSpacing = 8,
    double messageBottomSpacing = 24,

    // --- Barrier ---
    bool barrierDismissible = true,
    Color barrierColor = const Color(0x80000000),
  }) async {
    final online = await ConnectivityService.isOnline();
    if (online) return true;
    if (!context.mounted) return false;

    await showGeneralDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Dismiss',
      barrierColor: barrierColor,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: width,
            padding: padding,
            decoration: decoration ??
                BoxDecoration(
                  color: backgroundColor,
                  borderRadius: borderRadius ?? BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Icon(
                  icon,
                  size: iconSize,
                  color: iconColor,
                ),
                SizedBox(height: iconBottomSpacing),

                // Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: titleStyle ??
                      const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                ),
                SizedBox(height: titleBottomSpacing),

                // Message
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: messageStyle ??
                      const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        height: 1.5,
                      ),
                ),
                SizedBox(height: messageBottomSpacing),

                // Button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: buttonTextColor,
                      padding: buttonPadding,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            buttonBorderRadius ?? BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: TextStyle(
                        color: buttonTextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    return false;
  }
}
