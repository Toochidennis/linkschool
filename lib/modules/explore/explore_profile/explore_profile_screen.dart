import 'package:flutter/material.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';
// import 'package:paystack_for_flutter/paystack_for_flutter.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/providers/app_settings_provider.dart';
import 'package:linkschool/modules/services/firebase_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
// Add this import for the payment dialog
// import 'package:linkschool/modules/common/cbt_settings_helper.dart';
import 'package:linkschool/modules/providers/create_user_profile_provider.dart';
import 'package:linkschool/modules/model/cbt_user_model.dart';
import 'package:linkschool/modules/explore/cbt/cbt_plans_screen.dart';
import 'package:linkschool/modules/explore/cbt/widgets/cbt_auth_dialog.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen(
      {super.key, required double height, required Color color});

  @override
  Widget build(BuildContext context) {
    return const AppSettingsScreen();
  }
}

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Add mounted checks
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _saveActiveProfileId(int? id, {String? birthDate}) async {
    final prefs = await SharedPreferences.getInstance();
    if (id != null) {
      await prefs.setInt('active_profile_id', id);
      if (birthDate != null) {
        await prefs.setString('active_profile_dob', birthDate);
      } else {
        await prefs.remove('active_profile_dob');
      }
    } else {
      await prefs.remove('active_profile_id');
      await prefs.remove('active_profile_dob');
    }
  }

  Future<void> _handleSignIn() async {
    if (!mounted) return;
    try {
      final signedIn = await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (context) => const CbtAuthDialog(),
      );

      if (signedIn == true) {
        if (!mounted) return;
        final cbtUserProvider =
            Provider.of<CbtUserProvider>(context, listen: false);
        if (cbtUserProvider.currentUser == null) {
          await cbtUserProvider.initialize();
        }
        if (!mounted) return;
        final updatedUser = cbtUserProvider.currentUser;

        if (updatedUser != null) {
          try {
            final profileProvider =
                Provider.of<CreateUserProfileProvider>(context, listen: false);
            if (updatedUser.profiles.isEmpty) {
              final profiles = await profileProvider
                  .fetchUserProfiles(updatedUser.id.toString());
              if (profiles.isNotEmpty) {
                await cbtUserProvider.replaceProfiles(profiles);
              }
            }
          } catch (e) {
            // Intentionally ignored.
          }
        }

        if (!mounted) return;

        final profiles =
            cbtUserProvider.currentUser?.profiles ?? <CbtUserProfile>[];
        CbtUserProfile? activeProfile =
            profiles.isNotEmpty ? profiles.first : null;

        if (activeProfile?.id != null) {
          await _saveActiveProfileId(
            activeProfile!.id,
            birthDate: activeProfile.birthDate,
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signed in successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign-in was cancelled')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error signing in: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        // Clear app-specific user data FIRST before Firebase signout
        if (!mounted) return;
        final cbtUserProvider =
            Provider.of<CbtUserProvider>(context, listen: false);

        // Clear provider state and persisted CBT user data
        await cbtUserProvider.logout();

        // Clear commonly used auth/shared keys
        await _clearAllUserSharedPrefs();

        // Sign out from Firebase LAST
        await _authService.signOut();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logged out successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error logging out: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Remove common user-related keys from SharedPreferences immediately.
  /// This complements `CbtUserProvider.logout()` which also clears CBT-specific data.
  Future<void> _clearAllUserSharedPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Keys set by AuthProvider
      final authKeys = ['role', 'isLoggedIn', 'token', 'sessionValid'];

      // Keys used by CbtUserProvider
      final cbtKeys = ['cbt_current_user', 'cbt_payment_reference'];
      // Keys used by Explore Courses active profile
      final profileKeys = ['active_profile_id', 'active_profile_dob'];

      for (final k in [...authKeys, ...cbtKeys, ...profileKeys]) {
        if (prefs.containsKey(k)) await prefs.remove(k);
      }

      // Optionally clear any other known flags
    } catch (e) {
      // Intentionally ignored.
    }
  }

  // Add this method to handle the payment flow
  Future<void> _handleSubscribeNow() async {
    if (!mounted) return;
    final cbtUserProvider =
        Provider.of<CbtUserProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await cbtUserProvider.syncLicenseStatus(forceRefresh: false);
    if (!mounted) return;

    if (cbtUserProvider.hasPaid ||
        (authProvider.isLoggedIn && !authProvider.isDemoLogin)) {
      return;
    }

    final didProceed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const CbtPlansScreen(),
      ),
    );
    if (didProceed == true && mounted) {
      setState(() {});
    }
  }

  Widget _buildAnimatedCard({
    required Widget child,
    required int index,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);

    final cbtUserProvider = Provider.of<CbtUserProvider>(context);
    final cbtUser = cbtUserProvider.currentUser;
    final isSignedIn = cbtUser != null;
    final subscriptionStatus = cbtUserProvider.subscriptionStatus;
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(settings.textScaleFactor)),
      child: Scaffold(
        backgroundColor: settings.backgroundColor,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner if not signed in
                if (!isSignedIn)
                  _buildAnimatedCard(
                    index: 0,
                    child: Card(
                      color: Colors.orange[100],
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                color: Colors.orange),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Sign in to access your profile and subscription features.',
                                style: AppTextStyles.normal600(
                                    fontSize: 15, color: Colors.orange[900]),
                              ),
                            ),
                            TextButton(
                              onPressed: _handleSignIn,
                              child: const Text('Sign In'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Profile Header Section
                if (isSignedIn)
                  _buildAnimatedCard(
                    index: 1,
                    child: _buildProfileHeader(
                        settings, subscriptionStatus, cbtUser),
                  ),
                if (isSignedIn) const SizedBox(height: 24),

                // App Preferences Section (Disabled for now)
                // _buildSectionHeader('App Preferences', settings),
                // const SizedBox(height: 12),
                // _buildSettingsCard([
                //   _buildSettingsTile(
                //     icon: Icons.dark_mode_outlined,
                //     title: 'Dark Mode',
                //     subtitle: 'Switch to dark theme',
                //     settings: settings,
                //     trailing: Switch(
                //       value: settings.isDarkMode,
                //       onChanged: (value) {
                //         settings.setDarkMode(value);
                //       },
                //       activeColor: AppColors.text2Light,
                //     ),
                //   ),
                //   _buildDivider(),
                // ], settings),
                //
                // const SizedBox(height: 24),

                // Support & Legal Section
                _buildAnimatedCard(
                  index: 2,
                  child: _buildSectionHeader('Support & Legal', settings),
                ),
                const SizedBox(height: 12),
                _buildAnimatedCard(
                  index: 3,
                  child: _buildSettingsCard([
                    _buildSettingsTile(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      subtitle: 'Get help and contact support',
                      settings: settings,
                      trailing: Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () => _showHelpDialog(),
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      subtitle: 'Learn about our privacy practices',
                      settings: settings,
                      trailing: Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () => _showPrivacyDialog(),
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      icon: Icons.description_outlined,
                      title: 'Terms & Conditions',
                      subtitle: 'Read our terms of service',
                      settings: settings,
                      trailing: Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () => _showTermsDialog(),
                    ),
                  ], settings),
                ),

                const SizedBox(height: 24),

                // About Section
                _buildAnimatedCard(
                  index: 4,
                  child: _buildSectionHeader('About', settings),
                ),
                const SizedBox(height: 12),
                _buildAnimatedCard(
                  index: 5,
                  child: _buildSettingsCard([
                    _buildSettingsTile(
                      icon: Icons.info_outline,
                      title: 'About LinkSchool',
                      subtitle: 'Version 1.0.0',
                      settings: settings,
                      trailing: Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () => _showAboutDialog(),
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      icon: Icons.star_outline,
                      title: 'Rate App',
                      subtitle: 'Share your feedback',
                      settings: settings,
                      trailing: Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () => _showRatingDialog(),
                    ),
                  ], settings),
                ),

                const SizedBox(height: 24),

                // Logout Section (only if signed in)
                if (isSignedIn) ...[
                  _buildAnimatedCard(
                    index: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Account', settings),
                        const SizedBox(height: 12),
                        _buildSettingsCard([
                          _buildSettingsTile(
                            icon: Icons.logout,
                            title: 'Logout',
                            subtitle: 'Sign out of your account',
                            settings: settings,
                            trailing:
                                Icon(Icons.chevron_right, color: Colors.grey),
                            onTap: _handleLogout,
                          ),
                        ], settings),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    AppSettingsProvider settings,
    Map<String, dynamic> subscriptionStatus,
    CbtUserModel? user,
  ) {
    if (user == null) return const SizedBox.shrink();

    final hasValidLicense = subscriptionStatus['hasValidLicense'] == true;
    final hasPaid = subscriptionStatus['hasPaid'] == true;
    final licenseSource = subscriptionStatus['licenseSource']?.toString();
    final licenseReason = subscriptionStatus['licenseReason']?.toString();
    final isFreeTrial = hasValidLicense && licenseSource == 'trial';
    final isExpiredTrial =
        !hasValidLicense && !hasPaid && licenseReason == 'trial_expired';
    final timeLeft = _buildLicenseExpiryText(subscriptionStatus);
    final shouldHighlightExpiry =
        (isFreeTrial || isExpiredTrial) && timeLeft.isNotEmpty;
    final surfaceColor = settings.isDarkMode ? Colors.grey[850]! : Colors.white;
    final subtleBorderColor = settings.isDarkMode
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.textFieldBorderLight.withValues(alpha: 0.55);
    final secondaryTextColor =
        settings.isDarkMode ? Colors.grey[300]! : Colors.grey[600]!;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: subtleBorderColor),
        boxShadow: [
          BoxShadow(
            color: settings.isDarkMode
                ? Colors.black.withValues(alpha: 0.22)
                : Colors.grey.withValues(alpha: 0.08),
            spreadRadius: 0,
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.text2Light.withValues(alpha: 0.18),
                      AppColors.secondaryLight.withValues(alpha: 0.12),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.transparent,
                  backgroundImage: (user.profilePicture != null &&
                          user.profilePicture!.trim().isNotEmpty)
                      ? NetworkImage(user.profilePicture!)
                      : null,
                  child: (user.profilePicture == null ||
                          user.profilePicture!.trim().isEmpty)
                      ? Icon(
                          Icons.person_rounded,
                          size: 34,
                          color: AppColors.text2Light,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayName(user),
                      style: AppTextStyles.normal600(
                        fontSize: 18,
                        color: settings.isDarkMode
                            ? Colors.white
                            : AppColors.text2Light,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: AppTextStyles.normal400(
                        fontSize: 14,
                        color: secondaryTextColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (timeLeft.isNotEmpty) ...[
            const SizedBox(height: 14),
            _buildExpiryCallout(
              settings: settings,
              text: timeLeft,
              icon: shouldHighlightExpiry
                  ? (isExpiredTrial
                      ? Icons.warning_amber_rounded
                      : Icons.local_fire_department_outlined)
                  : Icons.schedule_outlined,
              color: shouldHighlightExpiry
                  ? (isExpiredTrial
                      ? const Color(0xFFB91C1C)
                      : const Color(0xFFD97706))
                  : AppColors.text2Light,
              emphasize: shouldHighlightExpiry,
            ),
          ],

          // Show subscribe action when trial is active or access is no longer valid.
          if (!hasValidLicense || isFreeTrial) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.eLearningBtnColor1,
                    AppColors.eLearningBtnColor1.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.eLearningBtnColor1.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => _handleSubscribeNow(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.workspace_premium,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Subscribe Now ',
                      style: AppTextStyles.normal600(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _displayName(CbtUserModel user) {
    final name = user.name?.trim();
    if (name != null && name.isNotEmpty) return name;
    final first = user.first_name?.trim() ?? '';
    final last = user.last_name?.trim() ?? '';
    final combined = ('$first $last').trim();
    if (combined.isNotEmpty) return combined;
    return 'User';
  }

  Widget _buildExpiryCallout({
    required AppSettingsProvider settings,
    required String text,
    required IconData icon,
    required Color color,
    required bool emphasize,
  }) {
    final backgroundColor = settings.isDarkMode
        ? color.withValues(alpha: emphasize ? 0.18 : 0.12)
        : color.withValues(alpha: emphasize ? 0.14 : 0.08);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: emphasize
                  ? AppTextStyles.normal700(
                      fontSize: 15,
                      color: color,
                    )
                  : AppTextStyles.normal700(
                      fontSize: 14,
                      color: color,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildLicenseExpiryText(Map<String, dynamic> subscriptionStatus) {
    final hasValidLicense = subscriptionStatus['hasValidLicense'] == true;
    final hasPaid = subscriptionStatus['hasPaid'] == true;
    final licenseReason = subscriptionStatus['licenseReason']?.toString();
    final licenseSource = subscriptionStatus['licenseSource']?.toString();

    final rawExpiresAt = subscriptionStatus['licenseExpiresAt']?.toString();
    final expiresAt = (rawExpiresAt == null || rawExpiresAt.isEmpty)
        ? null
        : _parseLicenseDate(rawExpiresAt);
    final formattedDate = expiresAt == null ? null : _formatDate(expiresAt);

    if (!hasValidLicense) {
      if (!hasPaid && licenseReason == 'trial_expired') {
        if (formattedDate != null) {
          return 'Free trial expired on $formattedDate';
        }
        return 'Your free trial has expired';
      }
      return '';
    }

    if (licenseSource == 'trial') {
      if (expiresAt == null) return '';
      final daysLeft = _daysLeftUntil(expiresAt);
      if (daysLeft <= 0) {
        return 'Free trial ends today';
      }
      final dayLabel = daysLeft == 1 ? 'day' : 'days';
      return 'Free trial ends in $daysLeft $dayLabel';
    }
    if (licenseSource == 'payment') {
      if (formattedDate == null) return '';
      return 'Subscription expires $formattedDate';
    }
    if (formattedDate == null) return '';
    return 'Access expires $formattedDate';
  }

  DateTime? _parseLicenseDate(String value) {
    final normalized =
        value.contains(' ') ? value.replaceFirst(' ', 'T') : value;
    return DateTime.tryParse(normalized);
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  int _daysLeftUntil(DateTime expiry) {
    final now = DateTime.now();
    final difference = expiry.difference(now);
    if (difference.isNegative) return 0;
    return difference.inHours <= 24 ? 1 : (difference.inHours / 24).ceil();
  }

  Widget _buildSectionHeader(String title, AppSettingsProvider settings) {
    return Text(
      title,
      style: AppTextStyles.normal600(
        fontSize: 16,
        color: settings.isDarkMode ? Colors.white : AppColors.text2Light,
      ),
    );
  }

  Widget _buildSettingsCard(
      List<Widget> children, AppSettingsProvider settings) {
    final cardColor = settings.isDarkMode ? Colors.grey[800] : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: settings.isDarkMode
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    required AppSettingsProvider settings,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.text2Light.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppColors.text2Light,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.normal500(
          fontSize: 16,
          color: settings.isDarkMode ? Colors.white : AppColors.text2Light,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.normal400(
          fontSize: 14,
          color: settings.isDarkMode ? Colors.grey[300]! : Colors.grey[600]!,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[100],
      indent: 60,
      endIndent: 20,
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Help & Support'),
          content: Text(
              'Need help? Contact our support team at support@linkschool.com'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPrivacyDialog() async {
    final prefs = await SharedPreferences.getInstance();
    // Persist a flag so this dialog does not open again
    await prefs.setBool('privacy_dialog_disabled', true);

    final Uri url = Uri.parse('https://linkschoolonline.com/privacy-policy');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open privacy policy')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening privacy policy: $e')),
        );
      }
    }
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Terms & Conditions'),
          content: Text(
              'By using LinkSchool, you agree to our terms and conditions.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('About LinkSchool'),
          content: Text(
              'LinkSchool v1.0.0\n\nYour comprehensive educational platform for learning and growth.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rate LinkSchool'),
          content:
              Text('Enjoying LinkSchool? Please rate us on the app store!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Later'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Rate Now'),
            ),
          ],
        );
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/providers/cbt_user_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/providers/app_settings_provider.dart';
// import 'package:linkschool/modules/services/firebase_auth_service.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen(
//       {super.key, required double height, required Color color});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: AppSettingsScreen(),
//     );
//   }
// }

// class AppSettingsScreen extends StatefulWidget {
//   const AppSettingsScreen({super.key});

//   @override
//   _AppSettingsScreenState createState() => _AppSettingsScreenState();
// }

// class _AppSettingsScreenState extends State<AppSettingsScreen> {
//   final FirebaseAuthService _authService = FirebaseAuthService();
//   User? _currentUser;
//   bool _isSignedIn = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();
//   }

//   Future<void> _loadUserData() async {
//     final user = _authService.getCurrentUser();
//     setState(() {
//       _currentUser = user;
//       _isSignedIn = user != null;
//     });
//   }

//   Future<void> _handleSignIn() async {
//     if (!mounted) return;
//     try {
//       final userCredential = await _authService.signInWithGoogle();
//       final user = userCredential?.user;
//       if (user != null) {
//         // Register user in backend via CbtUserProvider
//         final userProvider = Provider.of<CbtUserProvider>(context, listen: false);
//         await userProvider.handleFirebaseSignUp(
//           email: user.email ?? '',
//           name: user.displayName ?? '',
//           profilePicture: user.photoURL ?? '',
//         );
//         setState(() {
//           _currentUser = user;
//           _isSignedIn = true;
//         });
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Signed in successfully')),
//           );
//         }
//       } else {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Sign-in was cancelled')),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error signing in: $e'), backgroundColor: Colors.red),
//         );
//       }
//     }
//   }

//   Future<void> _handleLogout() async {
//     try {
//       await _authService.signOut();
//       setState(() {
//         _currentUser = null;
//         _isSignedIn = false;
//       });
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Logged out successfully'),
//             duration: Duration(seconds: 2),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error logging out: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final settings = Provider.of<AppSettingsProvider>(context);

//     final cbtUserProvider = Provider.of<CbtUserProvider>(context);
//     final subscriptionStatus = cbtUserProvider.subscriptionStatus;
//     return MediaQuery(
//       data: MediaQuery.of(context).copyWith(textScaleFactor: settings.textScaleFactor),
//       child: Scaffold(
//         backgroundColor: settings.backgroundColor,
//         body: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Banner if not signed in
//                 if (!_isSignedIn)
//                   Card(
//                     color: Colors.orange[100],
//                     elevation: 0,
//                     child: Padding(
//                       padding: const EdgeInsets.all(12.0),
//                       child: Row(
//                         children: [
//                           const Icon(Icons.info_outline, color: Colors.orange),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Text(
//                               'Sign in to access your profile and subscription features.',
//                               style: AppTextStyles.normal600(fontSize: 15, color: Colors.orange[900]),
//                             ),
//                           ),
//                           TextButton(
//                             onPressed: _handleSignIn,
//                             child: const Text('Sign In'),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 // Profile Header Section
//                 if (_isSignedIn) _buildProfileHeader(settings, subscriptionStatus),
//                 if (_isSignedIn) const SizedBox(height: 24),

//               // App Preferences Section
//               _buildSectionHeader('App Preferences', settings),
//               const SizedBox(height: 12),
//               _buildSettingsCard([
//                 _buildSettingsTile(
//                   icon: Icons.dark_mode_outlined,
//                   title: 'Dark Mode',
//                   subtitle: 'Switch to dark theme',
//                   settings: settings,
//                   trailing: Switch(
//                     value: settings.isDarkMode,
//                     onChanged: (value) {
//                       settings.setDarkMode(value);
//                     },
//                     activeColor: AppColors.text2Light,
//                   ),
//                 ),
//                 _buildDivider(),
//                 // _buildSettingsTile(
//                 //   icon: Icons.language_outlined,
//                 //   title: 'Language',
//                 //   subtitle: settings.selectedLanguage,
//                 //   settings: settings,
//                 //   trailing: Icon(Icons.chevron_right, color: Colors.grey),
//                 //   onTap: () => _showLanguageDialog(),
//                 // ),
//                 _buildDivider(),
//                 // _buildSettingsTile(
//                 //   icon: Icons.text_fields_outlined,
//                 //   title: 'Text Size',
//                 //   subtitle: settings.selectedTextSize,
//                 //   settings: settings,
//                 //   trailing: Icon(Icons.chevron_right, color: Colors.grey),
//                 //   onTap: () => _showTextSizeDialog(),
//                 // ),
//               ], settings),

//               const SizedBox(height: 24),

//               // Notifications Section
//               // _buildSectionHeader('Notifications', settings),
//               // const SizedBox(height: 12),
//               // _buildSettingsCard([
//               //   _buildSettingsTile(
//               //     icon: Icons.notifications_outlined,
//               //     title: 'Push Notifications',
//               //     subtitle: 'Receive app notifications',
//               //     settings: settings,
//               //     trailing: Switch(
//               //       value: settings.isNotificationsEnabled,
//               //       onChanged: (value) {
//               //         settings.setNotifications(value);
//               //       },
//               //       activeColor: AppColors.text2Light,
//               //     ),
//               //   ),
//               // ], settings),

//               const SizedBox(height: 24),

//               // // Media & Downloads Section
//               // _buildSectionHeader('Media & Downloads', settings),
//               // const SizedBox(height: 12),
//               // _buildSettingsCard([
//               //   _buildSettingsTile(
//               //     icon: Icons.play_circle_outline,
//               //     title: 'Auto-play Videos',
//               //     subtitle: 'Automatically play videos in feeds',
//               //     settings: settings,
//               //     trailing: Switch(
//               //       value: settings.isAutoPlayEnabled,
//               //       onChanged: (value) {
//               //         settings.setAutoPlay(value);
//               //       },
//               //       activeColor: AppColors.text2Light,
//               //     ),
//               //   ),
//               //   _buildDivider(),

//               // ], settings),

//               // const SizedBox(height: 24),

//               // Support & Legal Section
//               _buildSectionHeader('Support & Legal', settings),
//               const SizedBox(height: 12),
//               _buildSettingsCard([
//                 _buildSettingsTile(
//                   icon: Icons.help_outline,
//                   title: 'Help & Support',
//                   subtitle: 'Get help and contact support',
//                   settings: settings,
//                   trailing: Icon(Icons.chevron_right, color: Colors.grey),
//                   onTap: () => _showHelpDialog(),
//                 ),
//                 _buildDivider(),
//                 _buildSettingsTile(
//                   icon: Icons.privacy_tip_outlined,
//                   title: 'Privacy Policy',
//                   subtitle: 'Learn about our privacy practices',
//                   settings: settings,
//                   trailing: Icon(Icons.chevron_right, color: Colors.grey),
//                   onTap: () => _showPrivacyDialog(),
//                 ),
//                 _buildDivider(),
//                 _buildSettingsTile(
//                   icon: Icons.description_outlined,
//                   title: 'Terms & Conditions',
//                   subtitle: 'Read our terms of service',
//                   settings: settings,
//                   trailing: Icon(Icons.chevron_right, color: Colors.grey),
//                   onTap: () => _showTermsDialog(),
//                 ),
//               ], settings),

//               const SizedBox(height: 24),

//               // About Section
//               _buildSectionHeader('About', settings),
//               const SizedBox(height: 12),
//               _buildSettingsCard([
//                 _buildSettingsTile(
//                   icon: Icons.info_outline,
//                   title: 'About LinkSchool',
//                   subtitle: 'Version 1.0.0',
//                   settings: settings,
//                   trailing: Icon(Icons.chevron_right, color: Colors.grey),
//                   onTap: () => _showAboutDialog(),
//                 ),
//                 _buildDivider(),
//                 _buildSettingsTile(
//                   icon: Icons.star_outline,
//                   title: 'Rate App',
//                   subtitle: 'Share your feedback',
//                   settings: settings,
//                   trailing: Icon(Icons.chevron_right, color: Colors.grey),
//                   onTap: () => _showRatingDialog(),
//                 ),
//               ], settings),

//               const SizedBox(height: 24),

//               // Logout Section (only if signed in)
//               if (_isSignedIn) ...[
//                 _buildSectionHeader('Account', settings),
//                 const SizedBox(height: 12),
//                 _buildSettingsCard([
//                   _buildSettingsTile(
//                     icon: Icons.logout,
//                     title: 'Logout',
//                     subtitle: 'Sign out of your account',
//                     settings: settings,
//                     trailing: Icon(Icons.chevron_right, color: Colors.grey),
//                     onTap: _handleLogout,
//                   ),
//                 ], settings),
//                 const SizedBox(height: 24),
//               ],

//               const SizedBox(height: 100),
//             ],
//           ),
//         ),
//       ),
//       ),
//     );
//   }

//   Widget _buildProfileHeader(AppSettingsProvider settings, Map<String, dynamic> subscriptionStatus) {
//     final user = _currentUser;
//     if (user == null) return const SizedBox.shrink();

//     // Show static subscription expiry message if user has paid
//     String timeLeft = '';
//     if (subscriptionStatus['hasPaid'] == true) {
//       timeLeft = 'Subscription expires in 1 year';
//     }

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: settings.isDarkMode ? Colors.grey[800] : Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: settings.isDarkMode
//                 ? Colors.black.withValues(alpha: 0.3)
//                 : Colors.grey.withValues(alpha: 0.1),
//             spreadRadius: 1,
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // Profile Picture
//           Container(
//             height: 50,
//             child: CircleAvatar(
//               radius: 40,
//               backgroundColor: AppColors.text2Light.withValues(alpha: 0.2),
//               backgroundImage: user.photoURL != null
//                   ? NetworkImage(user.photoURL!)
//                   : null,
//               child: user.photoURL == null
//                   ? Icon(
//                       Icons.person,
//                       size: 40,
//                       color: AppColors.text2Light,
//                     )
//                   : null,
//             ),
//           ),
//           const SizedBox(width: 16),
//           // User Info
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   user.displayName ?? 'User',
//                   style: AppTextStyles.normal600(
//                     fontSize: 18,
//                     color: settings.isDarkMode ? Colors.white : AppColors.text2Light,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   user.email ?? '',
//                   style: AppTextStyles.normal400(
//                     fontSize: 14,
//                     color: settings.isDarkMode
//                         ? Colors.grey[300]!
//                         : Colors.grey[600]!,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Icon(
//                       subscriptionStatus['hasPaid'] == true ? Icons.verified : Icons.warning,
//                       color: subscriptionStatus['hasPaid'] == true ? Colors.green : Colors.red,
//                       size: 20,
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       subscriptionStatus['hasPaid'] == true
//                           ? 'Subscribed'
//                           : 'Not Subscribed',
//                       style: AppTextStyles.normal500(
//                         fontSize: 14,
//                         color: subscriptionStatus['hasPaid'] == true ? Colors.green : Colors.red,
//                       ),
//                     ),
//                   ],
//                 ),
//                 if (timeLeft.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 4),
//                     child: Text(
//                       timeLeft,
//                       style: AppTextStyles.normal400(
//                         fontSize: 13,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionHeader(String title, AppSettingsProvider settings) {
//     return Text(
//       title,
//       style: AppTextStyles.normal600(
//         fontSize: 16,
//         color: settings.isDarkMode ? Colors.white : AppColors.text2Light,
//       ),
//     );
//   }

//   Widget _buildSettingsCard(List<Widget> children, AppSettingsProvider settings) {
//     final cardColor = settings.isDarkMode ? Colors.grey[800] : Colors.white;

//     return Container(
//       decoration: BoxDecoration(
//         color: cardColor,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: settings.isDarkMode ? Colors.black.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.1),
//             spreadRadius: 1,
//             blurRadius: 10,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(children: children),
//     );
//   }

//   Widget _buildSettingsTile({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     Widget? trailing,
//     VoidCallback? onTap,
//     required AppSettingsProvider settings,
//   }) {
//     return ListTile(
//       contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//       leading: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: AppColors.text2Light.withValues(alpha: 0.1),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Icon(
//           icon,
//           color: AppColors.text2Light,
//           size: 20,
//         ),
//       ),
//       title: Text(
//         title,
//         style: AppTextStyles.normal500(
//           fontSize: 16,
//           color: settings.isDarkMode ? Colors.white : AppColors.text2Light,
//         ),
//       ),
//       subtitle: Text(
//         subtitle,
//         style: AppTextStyles.normal400(
//           fontSize: 14,
//           color: settings.isDarkMode ? Colors.grey[300]! : Colors.grey[600]!,
//         ),
//       ),
//       trailing: trailing,
//       onTap: onTap,
//     );
//   }

//   Widget _buildDivider() {
//     return Divider(
//       height: 1,
//       thickness: 1,
//       color: Colors.grey[100],
//       indent: 60,
//       endIndent: 20,
//     );
//   }

//   void _showHelpDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Help & Support'),
//           content: Text('Need help? Contact our support team at support@linkschool.com'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showPrivacyDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Privacy Policy'),
//           content: Text('Your privacy is important to us. We collect and use your data responsibly.'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showTermsDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Terms & Conditions'),
//           content: Text('By using LinkSchool, you agree to our terms and conditions.'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showAboutDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('About LinkSchool'),
//           content: Text('LinkSchool v1.0.0\n\nYour comprehensive educational platform for learning and growth.'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showRatingDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Rate LinkSchool'),
//           content: Text('Enjoying LinkSchool? Please rate us on the app store!'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('Later'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('Rate Now'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
