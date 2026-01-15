// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'signup_screen.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/providers/login/schools_provider.dart';
import 'package:provider/provider.dart';

class SelectSchool extends StatefulWidget {
  final void Function(String schoolCode)? onSchoolSelected;
  final VoidCallback? onBack;
  final VoidCallback? onDemoLoginSuccess;

  const SelectSchool(
      {super.key, this.onSchoolSelected, this.onBack, this.onDemoLoginSuccess});

  @override
  State<SelectSchool> createState() => _SelectSchoolState();
}

class _SelectSchoolState extends State<SelectSchool> {
  String query = '';
  final bool _isDemoLoading = false;
  final String _loadingRole = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<SchoolProvider>(context, listen: false).fetchSchools());
  }

  void _showDemoRoleDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          backgroundColor: Colors.white,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Close button at top right
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Icon(
                            Icons.close,
                            size: 24,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),

                      // Icon
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_circle_filled_rounded,
                          color: AppColors.primaryLight,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      Text(
                        'Try Demo Mode',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.normal700(
                          fontSize: 22,
                          color: AppColors.backgroundDark,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Description
                      Text(
                        'Select a role to explore the app features',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.normal400(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Role options
                      _buildRoleOption(
                        context: context,
                        icon: Icons.admin_panel_settings_rounded,
                        title: 'Admin',
                        subtitle: 'Manage school, staff & students',
                        color: const Color(0xFF8E24AA),
                        onTap: () {
                          Navigator.of(context).pop();
                          _navigateToDemoMode('admin');
                        },
                      ),
                      const SizedBox(height: 12),

                      _buildRoleOption(
                        context: context,
                        icon: Icons.person_rounded,
                        title: 'Staff',
                        subtitle: 'Access staff portal & features',
                        color: const Color(0xFF43A047),
                        onTap: () {
                          Navigator.of(context).pop();
                          _navigateToDemoMode('staff');
                        },
                      ),
                      const SizedBox(height: 12),

                      _buildRoleOption(
                        context: context,
                        icon: Icons.school_rounded,
                        title: 'Student',
                        subtitle: 'Explore learning materials & CBTs',
                        color: const Color(0xFF1E88E5),
                        onTap: () {
                          Navigator.of(context).pop();
                          _navigateToDemoMode('student');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.normal600(
                        fontSize: 16,
                        color: AppColors.backgroundDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.normal400(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToDemoMode(String role) async {
    // Demo credentials for each role
    final Map<String, Map<String, String>> demoCredentials = {
      'admin': {
        'username': 'practice',
        'password': 'portal',
        'schoolCode': '5416',
      },
      'student': {
        'username': '337',
        'password': 'chik52625',
        'schoolCode': '5416',
      },
      'staff': {
        'username': '42',
        'password': 'chik35483',
        'schoolCode': '5416',
      },
    };

    final credentials = demoCredentials[role];
    if (credentials == null) return;

    // Show loading dialog
    _showDemoLoadingDialog(role);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.login(
        credentials['username']!,
        credentials['password']!,
        credentials['schoolCode']!,
      );

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show success message
      if (mounted) {
        CustomToaster.toastSuccess(
          context,
          'Success',
          'Logged in as ${role.toUpperCase()} demo account',
        );
      }

      // Trigger success callback (similar to normal login)
      if (widget.onDemoLoginSuccess != null) {
        widget.onDemoLoginSuccess!();
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show error message
      if (mounted) {
        CustomToaster.toastError(
          context,
          'Error',
          'Demo login failed: $e',
        );
      }
    }
  }

  void _showDemoLoadingDialog(String role) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Loading spinner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  'Setting up Demo Mode',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.normal700(
                    fontSize: 18,
                    color: AppColors.backgroundDark,
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  'Signing in as ${role.toUpperCase()}...',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.normal400(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final schoolProvider = Provider.of<SchoolProvider>(context);
    final filteredSchools = schoolProvider.searchSchools(query);

    return PopScope(
      canPop: false, // Disable physical back button
      onPopInvoked: (didPop) {
        if (!didPop && widget.onBack != null) {
          // If back was attempted but prevented, call the callback
          widget.onBack!();
        }
      },
      child: Scaffold(
        body: Container(
          decoration: Constants.customScreenDec0ration(),
          width: double.infinity,
          height: double.infinity,
          child: Padding(
            padding: const EdgeInsets.only(top: 48, left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button and Try Demo button row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.black, size: 24),
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.of(context).pop();
                        } else if (widget.onBack != null) {
                          widget.onBack!();
                        }
                      },
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 16),

                // Sign Up and Try Demo buttons row
                Row(
                  children: [
                    // Sign Up button - bold and modern
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.eLearningBtnColor1,
                              AppColors.eLearningBtnColor1.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.eLearningBtnColor1.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const SignupScreen(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                 
                                  const SizedBox(width: 8),
                                  Text(
                                    'Sign Up',
                                    style: AppTextStyles.normal700(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Try Demo button
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primaryLight.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _showDemoRoleDialog,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                 
                                  const SizedBox(width: 8),
                                  Text(
                                    'Try Demo',
                                    style: AppTextStyles.normal600(
                                      fontSize: 15,
                                      color: AppColors.primaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                 SizedBox(height: 18),
                 TextField(
                  onChanged: (value) => setState(() => query = value),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    filled: true,
                    fillColor: AppColors.assessmentColor1,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 22),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide(
                          width: 0.5, color: AppColors.assessmentColor1),
                    ),
                    hintStyle: TextStyle(color: AppColors.admissionTitle),
                  ),
                ),
                const SizedBox(height: 18),
                // Title and subtitle - centered
                Center(
                  child: Text(
                    "Select Your Institution",
                    style: AppTextStyles.normal700(
                        fontSize: 20, color: AppColors.aboutTitle),
                    textAlign: TextAlign.center,
                  ),
                ),
                Center(
                  child: Text(
                    "Please select your School/Institution below",
                    style: AppTextStyles.normal500(
                        fontSize: 12, color: AppColors.admissionTitle),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                
                const SizedBox(height: 10),
                if (schoolProvider.isLoading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (schoolProvider.error != null)
                  Expanded(
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.error_outline,
                                size: 56,
                                color: Colors.red.shade400,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Unable to Load Schools',
                              style: AppTextStyles.normal600(
                                fontSize: 18,
                                color: AppColors.text2Light,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'There was a problem loading the list of schools.\nPlease check your internet connection.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.normal400(
                                fontSize: 14,
                                color: AppColors.text7Light,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                schoolProvider.fetchSchools();
                              },
                              icon: const Icon(Icons.refresh, size: 18),
                              label: Text(
                                'Try Again',
                                style: AppTextStyles.normal600(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.eLearningBtnColor1,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (filteredSchools.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: AppColors.text7Light,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No schools found',
                            style: AppTextStyles.normal600(
                              fontSize: 18,
                              color: AppColors.text2Light,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try a different search term',
                            style: AppTextStyles.normal400(
                              fontSize: 14,
                              color: AppColors.text7Light,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredSchools.length,
                      itemBuilder: (context, index) {
                        final school = filteredSchools[index];
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (widget.onSchoolSelected != null) {
                                  widget.onSchoolSelected!(
                                    school.schoolCode.toString(),
                                  );
                                }
                              },
                              child: _selectSchoolItems(
                                image:
                                    'assets/images/explore-images/ls-logo.png',
                                title: school.schoolName,
                                address: school.address ?? '',
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: 10),
                          ],
                        );
                      },
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _selectSchoolItems({
  required String image,
  required String title,
  required String address,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Image.asset(image, height: 25, width: 25),
      const SizedBox(width: 8),
      Expanded(
        // ✅ Added Expanded to constrain width
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.normal500(
                fontSize: 14,
                color: AppColors.backgroundDark,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (address.isNotEmpty) // ✅ Only show if address exists
              Text(
                address,
                style: AppTextStyles.normal500(
                  fontSize: 10,
                  color: AppColors.backgroundDark,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    ],
  );
}
