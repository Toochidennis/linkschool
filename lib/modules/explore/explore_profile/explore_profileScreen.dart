import 'package:flutter/material.dart';
import 'package:linkschool/config/env_config.dart' show EnvConfig;
import 'package:linkschool/modules/providers/cbt_user_provider.dart';
import 'package:paystack_for_flutter/paystack_for_flutter.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/providers/app_settings_provider.dart';
import 'package:linkschool/modules/services/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Add this import for the payment dialog
import 'package:linkschool/modules/common/cbt_settings_helper.dart';

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
  final FirebaseAuthService _authService = FirebaseAuthService();
  User? _currentUser;
  bool _isSignedIn = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _authService.getCurrentUser();
    setState(() {
      _currentUser = user;
      _isSignedIn = user != null;
    });
  }

  Future<void> _handleSignIn() async {
    if (!mounted) return;
    try {
      final userCredential = await _authService.signInWithGoogle();
      final user = userCredential?.user;
      if (user != null) {
        // Register user in backend via CbtUserProvider
        final userProvider =
            Provider.of<CbtUserProvider>(context, listen: false);
        await userProvider.handleFirebaseSignUp(
          email: user.email ?? '',
          name: user.displayName ?? '',
          profilePicture: user.photoURL ?? '',
        );
        setState(() {
          _currentUser = user;
          _isSignedIn = true;
        });
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
        final cbtUserProvider =
            Provider.of<CbtUserProvider>(context, listen: false);

        // Clear provider state and persisted CBT user data
        await cbtUserProvider.logout();
        print('✅ CbtUserProvider logout completed');

        // Clear commonly used auth/shared keys
        await _clearAllUserSharedPrefs();
        print('✅ SharedPreferences cleared');

        // Sign out from Firebase LAST
        await _authService.signOut();
        print('✅ Firebase signout completed');

        setState(() {
          _currentUser = null;
          _isSignedIn = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logged out successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        print('❌ Error during logout: $e');
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

      for (final k in [...authKeys, ...cbtKeys]) {
        if (prefs.containsKey(k)) await prefs.remove(k);
      }

      // Optionally clear any other known flags
      print('✅ Cleared user-related SharedPreferences keys');
    } catch (e) {
      print('❌ Error clearing SharedPreferences on logout: $e');
    }
  }

  // Add this method to handle the payment flow
  Future<void> _handleSubscribeNow() async {
    // Directly launch Paystack payment page using the same logic as _chargeWithPaystack
    final settings = await CbtSettingsHelper.getSettings();
    final _subscriptionPrice = settings.discountRate > 0
        ? (settings.amount * (1 - settings.discountRate)).round()
        : settings.amount;
    final _authService = FirebaseAuthService();
    final userEmail = await _authService.getCurrentUserEmail();
    if (userEmail == null || userEmail.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to retrieve user email'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final amountInKobo = _subscriptionPrice * 100;
    final reference = 'CBT_${DateTime.now().millisecondsSinceEpoch}';
    final paystackSecretKey = EnvConfig.paystackSecretKey;
    PaystackFlutter().pay(
      context: context,
      secretKey: paystackSecretKey,
      amount: amountInKobo.toDouble(),
      email: userEmail,
      callbackUrl: "https://callback.com",
      showProgressBar: true,
      paymentOptions: [
        PaymentOption.card,
        PaymentOption.bankTransfer,
        PaymentOption.mobileMoney,
      ],
      currency: Currency.NGN,
      metaData: {
        "subscription": "CBT Access",
        "price": _subscriptionPrice,
      },
      onSuccess: (paystackCallback) async {
        print('✅ Payment successful: "+paystackCallback.reference+"');
        // Optionally verify and update payment here
        final cbtUserProvider =
            Provider.of<CbtUserProvider>(context, listen: false);
        await cbtUserProvider.updateUserAfterPayment(reference: reference);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Payment Successful! Subscription activated.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          setState(() {});
        }
      },
      onCancelled: (paystackCallback) {
        print('❌ Payment cancelled or failed: "+paystackCallback.reference+"');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment cancelled'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);

    final cbtUserProvider = Provider.of<CbtUserProvider>(context);
    final subscriptionStatus = cbtUserProvider.subscriptionStatus;
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaleFactor: settings.textScaleFactor),
      child: Scaffold(
        backgroundColor: settings.backgroundColor,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner if not signed in
                if (!_isSignedIn)
                  Card(
                    color: Colors.orange[100],
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.orange),
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
                // Profile Header Section
                if (_isSignedIn)
                  _buildProfileHeader(settings, subscriptionStatus),
                if (_isSignedIn) const SizedBox(height: 24),

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

                const SizedBox(height: 24),

                // Logout Section (only if signed in)
                if (_isSignedIn) ...[
                  _buildSectionHeader('Account', settings),
                  const SizedBox(height: 12),
                  _buildSettingsCard([
                    _buildSettingsTile(
                      icon: Icons.logout,
                      title: 'Logout',
                      subtitle: 'Sign out of your account',
                      settings: settings,
                      trailing: Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: _handleLogout,
                    ),
                  ], settings),
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
      AppSettingsProvider settings, Map<String, dynamic> subscriptionStatus) {
    final user = _currentUser;
    if (user == null) return const SizedBox.shrink();

    // Show static subscription expiry message if user has paid
    String timeLeft = '';
    if (subscriptionStatus['hasPaid'] == true) {
      timeLeft = 'Subscription expires in 1 year';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: settings.isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: settings.isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Profile Picture
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.text2Light.withOpacity(0.2),
                backgroundImage:
                    user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                child: user.photoURL == null
                    ? Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.text2Light,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName ?? 'User',
                      style: AppTextStyles.normal600(
                        fontSize: 18,
                        color: settings.isDarkMode
                            ? Colors.white
                            : AppColors.text2Light,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email ?? '',
                      style: AppTextStyles.normal400(
                        fontSize: 14,
                        color: settings.isDarkMode
                            ? Colors.grey[300]!
                            : Colors.grey[600]!,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          subscriptionStatus['hasPaid'] == true
                              ? Icons.verified
                              : Icons.warning,
                          color: subscriptionStatus['hasPaid'] == true
                              ? Colors.green
                              : Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          subscriptionStatus['hasPaid'] == true
                              ? 'Subscribed'
                              : 'Not Subscribed',
                          style: AppTextStyles.normal500(
                            fontSize: 14,
                            color: subscriptionStatus['hasPaid'] == true
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    if (timeLeft.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          timeLeft,
                          style: AppTextStyles.normal400(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          // Payment Button (only show if not subscribed)
          if (subscriptionStatus['hasPaid'] != true) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.eLearningBtnColor1,
                    AppColors.eLearningBtnColor1.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.eLearningBtnColor1.withOpacity(0.3),
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
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
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

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Privacy Policy'),
          content: Text(
              'Your privacy is important to us. We collect and use your data responsibly.'),
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
//                 ? Colors.black.withOpacity(0.3) 
//                 : Colors.grey.withOpacity(0.1),
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
//               backgroundColor: AppColors.text2Light.withOpacity(0.2),
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
//             color: settings.isDarkMode ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.1),
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
//           color: AppColors.text2Light.withOpacity(0.1),
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
