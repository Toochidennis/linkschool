import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';


class CustomStudentAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showNotification;
  final bool showSettings;
  final bool showBackButton;
  final bool showPostInput;
  final bool centerTitle;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onPostTap;
  final VoidCallback? onBackPressed;

  const CustomStudentAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showNotification = false,
    this.showSettings = false,
    this.showBackButton = false,
    this.showPostInput = false,
    this.centerTitle = false,
    this.onNotificationTap,
    this.onSettingsTap,
    this.onPostTap,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => Size.fromHeight(showPostInput 
    ? kToolbarHeight + 83  // Increased height to accommodate input field
    : kToolbarHeight + 32); // Reduced height when input is hidden

  @override
  Widget build(BuildContext context) {
    // Create title widget based on whether subtitle exists
    Widget titleWidget = subtitle != null
      ? RichText(
          textAlign: centerTitle ? TextAlign.center : TextAlign.start,
          text: TextSpan(
            text: '$title, ',
            style: AppTextStyles.normal700(
                fontSize: 22, color: AppColors.backgroundLight),
            children: [
              TextSpan(
                text: subtitle,
                style: AppTextStyles.normal700(
                    fontSize: 22, color: AppColors.secondaryLight),
              ),
            ],
          ),
        )
      : Text(
          title,
          textAlign: centerTitle ? TextAlign.center : TextAlign.start,
          style: AppTextStyles.normal600(
            fontSize: 18.0,
            color: Colors.white,
          ),
        );

    return AppBar(
      backgroundColor: AppColors.paymentTxtColor1,
      toolbarHeight: preferredSize.height,
      automaticallyImplyLeading: false,
      centerTitle: centerTitle,
      leading: showBackButton
          ? IconButton(
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              icon: Image.asset(
                'assets/icons/arrow_back.png',
                color: Colors.white,
                width: 34.0,
                height: 34.0,
              ),
            )
          : null,
      flexibleSpace: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16, showPostInput ? 32 : 32, 8, 8),
              child: Row(
                mainAxisAlignment: centerTitle 
                  ? MainAxisAlignment.center 
                  : MainAxisAlignment.spaceBetween,
                children: [
                  if (!centerTitle) ...[
                    titleWidget,
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showNotification)
                          IconButton(
                            onPressed: onNotificationTap,
                            icon: SvgPicture.asset(
                              'assets/icons/notifications.svg',
                              colorFilter: const ColorFilter.mode(
                                  Colors.white, BlendMode.srcIn),
                            ),
                          ),
                        if (showSettings)
                          IconButton(
                            onPressed: onSettingsTap,
                            icon: SvgPicture.asset(
                              'assets/icons/settings.svg',
                              colorFilter: const ColorFilter.mode(
                                  Colors.white, BlendMode.srcIn),
                              width: 24,
                              height: 24,
                            ),
                          ),
                      ],
                    ),
                  ],
                  if (centerTitle) ...[
                    Expanded(
                      child: Center(child: titleWidget),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showNotification)
                          IconButton(
                            onPressed: onNotificationTap,
                            icon: SvgPicture.asset(
                              'assets/icons/notifications.svg',
                              colorFilter: const ColorFilter.mode(
                                  Colors.white, BlendMode.srcIn),
                            ),
                          ),
                        if (showSettings)
                          IconButton(
                            onPressed: onSettingsTap,
                            icon: SvgPicture.asset(
                              'assets/icons/settings.svg',
                              colorFilter: const ColorFilter.mode(
                                  Colors.white, BlendMode.srcIn),
                              width: 24,
                              height: 24,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (showPostInput)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      radius: 16,
                      child:
                          Icon(Icons.person, color: Colors.grey[600], size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: onPostTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6.0,  // Reduced vertical padding
                            horizontal: 12.0,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey[400]!,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Text(
                            "What's on your mind?",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}