import 'package:flutter/material.dart';
import 'package:linkschool/modules/services/firebase_auth_service.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/providers/cbt_user_provider.dart';
import 'package:provider/provider.dart';

class GoogleSignupDialog extends StatefulWidget {
  final VoidCallback onSignupSuccess;
  final VoidCallback? onSkip;

  const GoogleSignupDialog({
    super.key,
    required this.onSignupSuccess,
    this.onSkip,
  });

  @override
  State<GoogleSignupDialog> createState() => _GoogleSignupDialogState();
}

class _GoogleSignupDialogState extends State<GoogleSignupDialog> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  String? _errorMessage;
  final _authService = FirebaseAuthService();
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔐 Starting Google sign-up process...');
      
      final userCredential = await _authService.signInWithGoogle();
      
      if (userCredential == null) {
        setState(() {
          _errorMessage = 'Sign-in was cancelled';
        });
        return;
      }

      if (!mounted) return;

      final user = userCredential.user;
      if (user == null) {
        throw Exception('No user data received from Firebase');
      }

      print('✅ Google Sign-in successful!');
      print('User ID: ${user.uid}');
      print('User Email: ${user.email}');

      print('📡 Sending user data to backend API...');
      
      final userProvider = Provider.of<CbtUserProvider>(context, listen: false);
      
      await userProvider.handleFirebaseSignUp(
        email: user.email ?? '',
        name: user.displayName ?? '',
        profilePicture: user.photoURL ?? '',
      );

      if (!mounted) return;

      print('✅ User data sent to backend successfully');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Welcome ${user.displayName ?? "User"}! Your scores will be saved.',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      
      Navigator.of(context).pop();
      widget.onSignupSuccess();
    } catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.toString());
      });
      print('❌ Sign-in error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('network')) {
      return 'Network error. Please check your internet connection.';
    } else if (error.contains('cancelled')) {
      return 'Sign-in was cancelled.';
    } else if (error.contains('invalid-credential')) {
      return 'Invalid credentials. Please try again.';
    }
    return 'Sign-in failed. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Go back to CBT dashboard when back is pressed
        if (mounted) {
          Navigator.of(context).pop(); // Close dialog
          widget.onSkip?.call();
        }
        return false;
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.eLearningBtnColor1,
                  AppColors.eLearningBtnColor1.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 10),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.security_outlined,
                    size: 48,
                    color: AppColors.eLearningBtnColor1,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  'Save Your Progress',
                  style: AppTextStyles.normal700(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  'Sign in with Google to save your test scores and track your progress.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.normal400(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 24),

                // Error Message
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Google Sign-in Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleGoogleSignin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.eLearningBtnColor1,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.eLearningBtnColor1,
                              ),
                            ),
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
                              const Text(
                                'Sign in with Google',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                // Back Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            Navigator.of(context).pop();
                            widget.onSkip?.call();
                          },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Go Back',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Info Message
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.white.withOpacity(0.8),
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Sign in required to save your test results.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
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
}
