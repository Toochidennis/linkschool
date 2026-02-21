import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';
import 'package:linkschool/modules/services/firebase_auth_service.dart';
import 'package:provider/provider.dart';

class CbtAuthDialog extends StatefulWidget {
  const CbtAuthDialog({super.key});

  @override
  State<CbtAuthDialog> createState() => _CbtAuthDialogState();
}

class _CbtAuthDialogState extends State<CbtAuthDialog>
    with SingleTickerProviderStateMixin {
  final _authService = FirebaseAuthService();
  late TabController _tabController;

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  final _signupFirstNameController = TextEditingController();
  final _signupLastNameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupPhoneController = TextEditingController();
  final _signupBirthDateController = TextEditingController();
  String? _selectedGender;

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscureLoginPassword = true;
  bool _obscureSignupPassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupFirstNameController.dispose();
    _signupLastNameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupPhoneController.dispose();
    _signupBirthDateController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleAuth() async {
    if (_isGoogleLoading) return;
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential == null) {
        setState(() {
          _errorMessage = 'Sign-in was cancelled';
        });
        return;
      }

      final user = userCredential.user;
      if (user == null) {
        throw Exception('No user data received from Firebase');
      }

      final name =
          (user.displayName == null || user.displayName!.trim().isEmpty)
              ? _deriveNameFromEmail(user.email ?? '')
              : user.displayName!.trim();

      if (!mounted) return;
      final userProvider = Provider.of<CbtUserProvider>(context, listen: false);
      await userProvider.handleFirebaseLogin(
        email: user.email ?? '',
        name: name,
        profilePicture: user.photoURL ?? '',
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _errorMessage = _mapAuthError(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  Future<void> _handleEmailLogin() async {
    if (_isLoading) return;

    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email and password.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (!mounted) return;
      final userProvider = Provider.of<CbtUserProvider>(context, listen: false);
      await userProvider.loginWithEmailPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _errorMessage = _mapAuthError(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleEmailSignup() async {
    if (_isLoading) return;

    final firstName = _signupFirstNameController.text.trim();
    final lastName = _signupLastNameController.text.trim();
    final email = _signupEmailController.text.trim();
    final password = _signupPasswordController.text;
    final phone = _signupPhoneController.text.trim();
    final birthDate = _signupBirthDateController.text.trim();
    final gender = _selectedGender ?? '';

    if (firstName.isEmpty || lastName.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your first and last name.';
      });
      return;
    }

    if (gender.isEmpty || birthDate.isEmpty || phone.isEmpty) {
      setState(() {
        _errorMessage = 'Please complete all signup fields.';
      });
      return;
    }

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email and password.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (!mounted) return;
      final userProvider = Provider.of<CbtUserProvider>(context, listen: false);
      await userProvider.signupWithEmailPassword(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        gender: gender,
        birthDate: birthDate,
        phone: phone,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _errorMessage = _mapAuthError(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _deriveNameFromEmail(String email) {
    if (email.isEmpty) return 'User';
    final part = email.split('@').first.replaceAll('.', ' ').trim();
    if (part.isEmpty) return 'User';
    return part
        .split(' ')
        .map((e) => e.isEmpty ? '' : '${e[0].toUpperCase()}${e.substring(1)}')
        .join(' ')
        .trim();
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _mapAuthError(String error) {
    final value = error.toLowerCase();
    if (value.contains('email already in use')) {
      return 'Email already in use.';
    }
    if (value.contains('invalid-email')) {
      return 'Invalid email address.';
    }
    if (value.contains('user-not-found')) {
      return 'No account found for this email.';
    }
    if (value.contains('wrong-password')) {
      return 'Incorrect password.';
    }
    if (value.contains('email-already-in-use')) {
      return 'An account already exists for this email.';
    }
    if (value.contains('weak-password')) {
      return 'Password is too weak.';
    }
    if (value.contains('network')) {
      return 'Network error. Please try again.';
    }
    final backendMessage = _extractBackendMessage(error);
    if (backendMessage != null) {
      return backendMessage;
    }
    return 'Authentication failed. Please try again.';
  }

  String? _extractBackendMessage(String error) {
    final trimmed = error.replaceFirst('Exception: ', '');
    if (trimmed.contains('"message"')) {
      final match = RegExp(r'"message"\s*:\s*"([^"]+)"').firstMatch(trimmed);
      if (match != null) {
        return match.group(1);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final contentWidth = MediaQuery.of(context).size.width.clamp(0, 420.0).toDouble();
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: contentWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 18),
                    Text(
                      'Welcome Back',
                      style: AppTextStyles.normal700(
                        fontSize: 28,
                        color: AppColors.text4Light,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Welcome back! Sign in with Google or your email and password.',
                      style: AppTextStyles.normal400(
                        fontSize: 14,
                        color: AppColors.text7Light,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTabSwitcher(),
                    const SizedBox(height: 20),
                    _buildGoogleButton(),
                    const SizedBox(height: 16),
                    _buildDividerText(
                      _tabController.index == 0
                          ? 'Or continue with email'
                          : 'Or create with email',
                    ),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: _tabController.index == 0
                          ? _buildLoginForm()
                          : _buildSignupForm(),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      _buildErrorBanner(_errorMessage!),
                    ],
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(false),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF5FF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD0E2FF)),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.eLearningBtnColor1,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'LINKSKOOL',
                style: AppTextStyles.normal700(
                  fontSize: 12,
                  color: AppColors.eLearningBtnColor1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabSwitcher() {
  return Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: const Color(0xFFF2F4F7),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              _tabController.animateTo(0);
              setState(() {});
            },
            child: Container(
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _tabController.index == 0
                    ? AppColors.eLearningBtnColor1
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                'Login',
                style: AppTextStyles.normal600(
                  fontSize: 14,
                  color: _tabController.index == 0
                      ? Colors.white
                      : AppColors.text7Light,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              _tabController.animateTo(1);
              setState(() {});
            },
            child: Container(
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _tabController.index == 1
                    ? AppColors.eLearningBtnColor1
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                'Sign Up',
                style: AppTextStyles.normal600(
                  fontSize: 14,
                  color: _tabController.index == 1
                      ? Colors.white
                      : AppColors.text7Light,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: _isGoogleLoading ? null : _handleGoogleAuth,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade300, width: 1.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          backgroundColor: Colors.white,
        ),
        child: _isGoogleLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/google_icon.png',
                    width: 22,
                    height: 22,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.info, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Continue with Google',
                    style: AppTextStyles.normal600(
                      fontSize: 14,
                      color: AppColors.text4Light,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDividerText(String text) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        const SizedBox(width: 12),
        Text(
          text,
          style: AppTextStyles.normal400(
            fontSize: 12,
            color: AppColors.text7Light,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Email Address'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _loginEmailController,
          hintText: 'you@example.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Password'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _loginPasswordController,
          hintText: 'Enter your password',
          obscureText: _obscureLoginPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureLoginPassword ? Icons.visibility_off : Icons.visibility,
              size: 18,
              color: AppColors.text7Light,
            ),
            onPressed: () {
              setState(() => _obscureLoginPassword = !_obscureLoginPassword);
            },
          ),
        ),
        const SizedBox(height: 20),
        _buildPrimaryButton(
          label: _isLoading ? 'Signing in...' : 'Sign In',
          onPressed: _isLoading ? null : _handleEmailLogin,
        ),
      ],
    );
  }

  Widget _buildSignupForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Column(  // This stays as Column
        children: [
          // Remove Expanded here
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFieldLabel('First Name'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _signupFirstNameController,
                hintText: 'John',
              ),
            ],
          ),
          const SizedBox(height: 16),  // Changed from width to height
          // Remove Expanded here too
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFieldLabel('Last Name'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _signupLastNameController,
                hintText: 'Doe',
              ),
            ],
          ),
        ],
      ),
        const SizedBox(height: 16),
        _buildFieldLabel('Email Address'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _signupEmailController,
          hintText: 'you@example.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Phone'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _signupPhoneController,
          hintText: '+234 9030405067',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Date of Birth'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _signupBirthDateController,
                    hintText: 'yyyy-mm-dd',
                    keyboardType: TextInputType.datetime,
                    readOnly: true,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today, size: 18),
                      onPressed: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime(now.year - 16, now.month, now.day),
                          firstDate: DateTime(1950),
                          lastDate: DateTime(now.year - 3, now.month, now.day),
                        );
                        if (picked != null) {
                          setState(() {
                            _signupBirthDateController.text = _formatDate(picked);
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('Gender'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('Male')),
                      DropdownMenuItem(value: 'female', child: Text('Female')),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedGender = value);
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300, width: 1.4),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300, width: 1.4),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: AppColors.eLearningBtnColor1,
                          width: 1.6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Password'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _signupPasswordController,
          hintText: 'Create a strong password',
          obscureText: _obscureSignupPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureSignupPassword ? Icons.visibility_off : Icons.visibility,
              size: 18,
              color: AppColors.text7Light,
            ),
            onPressed: () {
              setState(() => _obscureSignupPassword = !_obscureSignupPassword);
            },
          ),
        ),
        const SizedBox(height: 20),
        _buildPrimaryButton(
          label: _isLoading ? 'Creating account...' : 'Sign Up',
          onPressed: _isLoading ? null : _handleEmailSignup,
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.normal600(
        fontSize: 13,
        color: AppColors.text4Light,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool readOnly = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.normal400(
          fontSize: 14,
          color: AppColors.text8Light,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.4),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.eLearningBtnColor1,
            width: 1.6,
          ),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.eLearningBtnColor1,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 4,
        ),
        child: Text(
          label,
          style: AppTextStyles.normal600(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFC7C7)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFE02424), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.normal500(
                fontSize: 12,
                color: const Color(0xFFE02424),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
