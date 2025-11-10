import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/providers/app_settings_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen(
      {super.key, required double height, required Color color});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AppSettingsScreen(),
    );
  }
}

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  _AppSettingsScreenState createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);
    
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: settings.textScaleFactor),
      child: Scaffold(
        backgroundColor: settings.backgroundColor,
     
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Preferences Section
              _buildSectionHeader('App Preferences', settings),
              const SizedBox(height: 12),
              _buildSettingsCard([
                _buildSettingsTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  subtitle: 'Switch to dark theme',
                  settings: settings,
                  trailing: Switch(
                    value: settings.isDarkMode,
                    onChanged: (value) {
                      settings.setDarkMode(value);
                    },
                    activeColor: AppColors.text2Light,
                  ),
                ),
                _buildDivider(),
                // _buildSettingsTile(
                //   icon: Icons.language_outlined,
                //   title: 'Language',
                //   subtitle: settings.selectedLanguage,
                //   settings: settings,
                //   trailing: Icon(Icons.chevron_right, color: Colors.grey),
                //   onTap: () => _showLanguageDialog(),
                // ),
                _buildDivider(),
                // _buildSettingsTile(
                //   icon: Icons.text_fields_outlined,
                //   title: 'Text Size',
                //   subtitle: settings.selectedTextSize,
                //   settings: settings,
                //   trailing: Icon(Icons.chevron_right, color: Colors.grey),
                //   onTap: () => _showTextSizeDialog(),
                // ),
              ], settings),


              const SizedBox(height: 24),

              // Notifications Section
              // _buildSectionHeader('Notifications', settings),
              // const SizedBox(height: 12),
              // _buildSettingsCard([
              //   _buildSettingsTile(
              //     icon: Icons.notifications_outlined,
              //     title: 'Push Notifications',
              //     subtitle: 'Receive app notifications',
              //     settings: settings,
              //     trailing: Switch(
              //       value: settings.isNotificationsEnabled,
              //       onChanged: (value) {
              //         settings.setNotifications(value);
              //       },
              //       activeColor: AppColors.text2Light,
              //     ),
              //   ),
              // ], settings),

              const SizedBox(height: 24),

              // // Media & Downloads Section
              // _buildSectionHeader('Media & Downloads', settings),
              // const SizedBox(height: 12),
              // _buildSettingsCard([
              //   _buildSettingsTile(
              //     icon: Icons.play_circle_outline,
              //     title: 'Auto-play Videos',
              //     subtitle: 'Automatically play videos in feeds',
              //     settings: settings,
              //     trailing: Switch(
              //       value: settings.isAutoPlayEnabled,
              //       onChanged: (value) {
              //         settings.setAutoPlay(value);
              //       },
              //       activeColor: AppColors.text2Light,
              //     ),
              //   ),
              //   _buildDivider(),
              
              // ], settings),

              // const SizedBox(height: 24),

              // Support & Legal Section
              _buildSectionHeader('Support & Legal', settings),
              const SizedBox(height: 12),
              _buildSettingsCard([
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

              const SizedBox(height: 24),

              // About Section
              _buildSectionHeader('About', settings),
              const SizedBox(height: 12),
              _buildSettingsCard([
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

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      ),
    );
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

  Widget _buildSettingsCard(List<Widget> children, AppSettingsProvider settings) {
    final cardColor = settings.isDarkMode ? Colors.grey[800] : Colors.white;
    
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: settings.isDarkMode ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.1),
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
          color: AppColors.text2Light.withOpacity(0.1),
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

  void _showLanguageDialog() {
    final settings = Provider.of<AppSettingsProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption('English', settings),
              _buildLanguageOption('Spanish', settings),
              _buildLanguageOption('French', settings),
              _buildLanguageOption('Portuguese', settings),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String language, AppSettingsProvider settings) {
    return ListTile(
      title: Text(language),
      trailing: settings.selectedLanguage == language ? Icon(Icons.check, color: AppColors.text2Light) : null,
      onTap: () {
        settings.setLanguage(language);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Language changed to $language'),
            duration: Duration(seconds: 2),
          ),
        );
      },
    );
  }

  void _showTextSizeDialog() {
    final settings = Provider.of<AppSettingsProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Text Size'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextSizeOption('Small', settings),
              _buildTextSizeOption('Medium', settings),
              _buildTextSizeOption('Large', settings),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextSizeOption(String size, AppSettingsProvider settings) {
    double textScale = size == 'Small' ? 0.85 : size == 'Large' ? 1.15 : 1.0;
    
    return ListTile(
      title: Text(
        size,
        style: TextStyle(fontSize: 16 * textScale),
      ),
      trailing: settings.selectedTextSize == size ? Icon(Icons.check, color: AppColors.text2Light) : null,
      onTap: () {
        settings.setTextSize(size);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Text size changed to $size'),
            duration: Duration(seconds: 2),
          ),
        );
      },
    );
  }



  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Help & Support'),
          content: Text('Need help? Contact our support team at support@linkschool.com'),
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

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Privacy Policy'),
          content: Text('Your privacy is important to us. We collect and use your data responsibly.'),
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

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Terms & Conditions'),
          content: Text('By using LinkSchool, you agree to our terms and conditions.'),
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
          content: Text('LinkSchool v1.0.0\n\nYour comprehensive educational platform for learning and growth.'),
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
          content: Text('Enjoying LinkSchool? Please rate us on the app store!'),
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
