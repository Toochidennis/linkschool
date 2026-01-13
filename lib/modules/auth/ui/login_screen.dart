import 'package:flutter/material.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_medium_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';

import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/explore/home/explore_dashboard.dart';

import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final String schoolCode; // ✅ received from SelectSchool
  final String? schoolName;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
    required this.schoolCode,
    this.schoolName,
  });

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  void _navigateBack() {
    // Simply pop back to previous screen (SelectSchool)
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() => _isLoading = true);

      final username = _usernameController.text;
      final password = _passwordController.text;
      final schoolCode = widget.schoolCode;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        await authProvider.login(username, password, schoolCode);
        widget.onLoginSuccess();
        CustomToaster.toastSuccess(context, 'Success', 'Login successful!');
      } catch (e) {
        CustomToaster.toastError(context, 'Error', 'Login failed: $e');
        print('error:$e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _navigateBack();
        return false;
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: Constants.customScreenDec0ration(),
          child: Form(
            key: _formKey,
            child: Stack(
              children: [
                // 🔙 Back Button
                Positioned(
                  top: 120,
                  right: 300,
                  left: 0,
                  child: InkWell(
                    onTap: () => _navigateBack(),
                    child: Icon(Icons.arrow_back,
                        size: 16, color: AppColors.attCheckColor1),
                  ),
                ),

                // 🧩 Form
                Positioned(
                  top: 100,
                  right: 0,
                  left: 0,
                  child: _buildLoginForm(),
                ),

                // 👇 Bottom Sign Up
                Positioned(
                  top: 700,
                  bottom: 30,
                  left: 60,
                  child: Wrap(
                    children: [
                      Text("Don't have an account?",
                          style: AppTextStyles.normal500(
                              fontSize: 12, color: AppColors.assessmentColor2)),
                      InkWell(
                        onTap: () {},
                        child: Text(
                          " Sign Up",
                          style: AppTextStyles.normal500(
                              fontSize: 14, color: AppColors.aicircle),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 68, 24, 16),
          child: Row(
            children: [
              Image.asset('assets/images/explore-images/ls-logo.png',
                  width: 20, height: 20),
              const SizedBox(width: 10),
              Text("Link",
                  style: AppTextStyles.normal700(
                      fontSize: 16, color: AppColors.aboutTitle)),
              Text("Skool",
                  style: AppTextStyles.normal700(
                      fontSize: 16, color: AppColors.bgXplore1)),
            ],
          ),
        ),

        // Titles
        Padding(
          padding: const EdgeInsets.only(top: 24, left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Get Started now",
                  style: AppTextStyles.normal700(
                      fontSize: 32, color: AppColors.bookText)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                child: Text(
                  "Log in and simplify your school processes",
                  style: AppTextStyles.normal400(
                      fontSize: 14, color: AppColors.assessmentColor2),
                ),
              ),
              const SizedBox(height: 15),

              // ✅ Display Selected School
              if (widget.schoolName != null)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.assessmentColor1,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.school, color: AppColors.aicircle, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.schoolName!,
                          style: AppTextStyles.normal500(
                              fontSize: 13, color: AppColors.bookText),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 10),

              // 🧍 Username
              TextFormField(
                controller: _usernameController,
                focusNode: _usernameFocus,
                decoration: InputDecoration(
                  hintText: 'Enter Username',
                  filled: true,
                  fillColor: AppColors.assessmentColor1,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a username'
                    : null,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_passwordFocus),
              ),
              const SizedBox(height: 20),

              // 🔒 Password
              TextFormField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Enter Password',
                  filled: true,
                  fillColor: AppColors.assessmentColor1,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a password'
                    : null,
              ),
              const SizedBox(height: 30),

              // 🚀 Login Button
              CustomBlueElevatedButton(
                text: _isLoading ? 'Signing in...' : 'Login',
                onPressed: _isLoading ? null : _login,
                backgroundColor: AppColors.aicircle,
                textStyle: AppTextStyles.italicTitle700(
                    fontSize: 14, color: AppColors.assessmentColor1),
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 140),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
