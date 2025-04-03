import 'package:flutter/material.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/explore/home/explore_dashboard.dart';
import 'package:provider/provider.dart';
// import 'custom_toaster.dart'; // Import the CustomToaster

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _schoolCodeFocus = FocusNode();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _schoolCodeController = TextEditingController();

  bool _obscurePassword = true;
  bool _showUsernameCheck = false;
  bool _showPasswordCheck = false;
  bool _showSchoolCodeCheck = false;
  bool _isLoading = false; 
  late double opacity;

  void _navigateToExploreDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ExploreDashboard(
          onSwitch: (bool value) {},
          selectedIndex: 0,
          onTabSelected: (int index) {},
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _usernameFocus.addListener(_onUsernameFocusChange);
    _passwordFocus.addListener(_onPasswordFocusChange);
    _schoolCodeFocus.addListener(_onSchoolCodeFocusChange);
  }

  @override
  void dispose() {
    _usernameFocus.removeListener(_onUsernameFocusChange);
    _passwordFocus.removeListener(_onPasswordFocusChange);
    _schoolCodeFocus.removeListener(_onSchoolCodeFocusChange);
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _schoolCodeFocus.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _schoolCodeController.dispose();
    super.dispose();
  }

  void _onUsernameFocusChange() {
    if (!_usernameFocus.hasFocus && _usernameController.text.isNotEmpty) {
      setState(() {
        _showUsernameCheck = true;
      });
    }
  }

  void _onPasswordFocusChange() {
    if (!_passwordFocus.hasFocus && _passwordController.text.isNotEmpty) {
      setState(() {
        _showPasswordCheck = true;
      });
    }
  }

  void _onSchoolCodeFocusChange() {
    if (!_schoolCodeFocus.hasFocus && _schoolCodeController.text.isNotEmpty) {
      setState(() {
        _showSchoolCodeCheck = true;
      });
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true; // Show loading spinner
      });

      final username = _usernameController.text;
      final password = _passwordController.text;
      final schoolCode = _schoolCodeController.text;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        await authProvider.login(username, password, schoolCode);
        widget.onLoginSuccess(); // Ensure this is called
        CustomToaster.toastSuccess(
            context, 'Success', 'Login successful!'); // Show success toast
      } catch (e) {
        CustomToaster.toastError(
            context, 'Error', 'Login failed: $e'); // Show error toast
      } finally {
        setState(() {
          _isLoading = false; // Hide loading spinner
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    opacity = brightness == Brightness.light ? 0.1 : 0.15;
    return WillPopScope(
      onWillPop: () async {
        _navigateToExploreDashboard();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(0, 80, 255, 1),
          elevation: 0,
          leading: IconButton(
            onPressed: _navigateToExploreDashboard,
            icon: Image.asset(
              'assets/icons/arrow_back.png',
              color: AppColors.backgroundLight,
              width: 34.0,
              height: 34.0,
            ),
          ),
          title: const Text(
            'Sign in',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            color: Color.fromRGBO(0, 80, 255, 1),
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Hello there, sign in to continue!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _usernameController,
                        focusNode: _usernameFocus,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: _showUsernameCheck
                              ? Icon(Icons.check_circle,
                                  color: Colors.blue[700])
                              : Icon(Icons.error, color: Colors.red),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _showUsernameCheck = value.isNotEmpty;
                          });
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a username';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_passwordFocus);
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_showPasswordCheck)
                                Icon(Icons.check_circle,
                                    color: Colors.blue[700]),
                              if (!_showPasswordCheck)
                                Icon(Icons.error, color: Colors.red),
                              IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.blue[700],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ],
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        obscureText: _obscurePassword,
                        onChanged: (value) {
                          setState(() {
                            _showPasswordCheck = value.isNotEmpty;
                          });
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _schoolCodeController,
                        focusNode: _schoolCodeFocus,
                        decoration: InputDecoration(
                          labelText: 'School Code',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: _showSchoolCodeCheck
                              ? Icon(Icons.check_circle,
                                  color: Colors.blue[700])
                              : Icon(Icons.error, color: Colors.red),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _showSchoolCodeCheck = value.isNotEmpty;
                          });
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a school code';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Add forgot password functionality
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : _login, // Disable button when loading
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(0, 80, 255, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Signing in...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.backgroundLight,
                                      ),
                                    ),
                                    SizedBox(
                                        width:
                                            8), // Add spacing between text and spinner
                                    SizedBox(
                                      width: 20, // Set the width of the spinner
                                      height:
                                          20, // Set the height of the spinner
                                      child: CircularProgressIndicator(
                                        strokeWidth:
                                            3, // Adjust the thickness of the spinner
                                        color: AppColors.backgroundLight,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  'Sign in',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.backgroundLight,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/auth/provider/auth_provider.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/explore/home/explore_dashboard.dart';
// import 'package:provider/provider.dart';
// // import 'package:shared_preferences/shared_preferences.dart';


// class LoginScreen extends StatefulWidget {
//   final VoidCallback onLoginSuccess;

//   const LoginScreen({super.key, required this.onLoginSuccess});

//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _usernameFocus = FocusNode();
//   final _passwordFocus = FocusNode();
//   final _schoolCodeFocus = FocusNode();
//   final _usernameController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _schoolCodeController = TextEditingController();

//   bool _obscurePassword = true;
//   bool _showUsernameCheck = false;
//   bool _showPasswordCheck = false;
//   bool _showSchoolCodeCheck = false;
//   late double opacity;

//   void _navigateToExploreDashboard() {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ExploreDashboard(
//           onSwitch: (bool value) {}, 
//           selectedIndex: 0,
//           onTabSelected: (int index) {}, 
//         ),
//       ),
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     _usernameFocus.addListener(_onUsernameFocusChange);
//     _passwordFocus.addListener(_onPasswordFocusChange);
//     _schoolCodeFocus.addListener(_onSchoolCodeFocusChange);
//   }

//   @override
//   void dispose() {
//     _usernameFocus.removeListener(_onUsernameFocusChange);
//     _passwordFocus.removeListener(_onPasswordFocusChange);
//     _schoolCodeFocus.removeListener(_onSchoolCodeFocusChange);
//     _usernameFocus.dispose();
//     _passwordFocus.dispose();
//     _schoolCodeFocus.dispose();
//     _usernameController.dispose();
//     _passwordController.dispose();
//     _schoolCodeController.dispose();
//     super.dispose();
//   }

//   void _onUsernameFocusChange() {
//     if (!_usernameFocus.hasFocus && _usernameController.text.isNotEmpty) {
//       setState(() {
//         _showUsernameCheck = true;
//       });
//     }
//   }

//   void _onPasswordFocusChange() {
//     if (!_passwordFocus.hasFocus && _passwordController.text.isNotEmpty) {
//       setState(() {
//         _showPasswordCheck = true;
//       });
//     }
//   }

//   void _onSchoolCodeFocusChange() {
//     if (!_schoolCodeFocus.hasFocus && _schoolCodeController.text.isNotEmpty) {
//       setState(() {
//         _showSchoolCodeCheck = true;
//       });
//     }
//   }


// Future<void> _login() async {
//   if (_formKey.currentState!.validate()) {
//     _formKey.currentState!.save();

//     final username = _usernameController.text;
//     final password = _passwordController.text;
//     final schoolCode = _schoolCodeController.text;

//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     try {
//       await authProvider.login(username, password, schoolCode);
//       widget.onLoginSuccess(); // Ensure this is called
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Login failed: $e')),
//       );
//     }
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     final Brightness brightness = Theme.of(context).brightness;
//     opacity = brightness == Brightness.light ? 0.1 : 0.15;
//     return WillPopScope(
//       onWillPop: () async {
//         _navigateToExploreDashboard();
//         return false;
//       },
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: Color.fromRGBO(0, 80, 255, 1),
//           elevation: 0,
//           leading: IconButton(
//             onPressed: _navigateToExploreDashboard,
//             icon: Image.asset(
//               'assets/icons/arrow_back.png',
//               color: AppColors.backgroundLight,
//               width: 34.0,
//               height: 34.0,
//             ),
//           ),
//           title: const Text(
//             'Sign in',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//         body: Container(
//           decoration: const BoxDecoration(
//             color: Color.fromRGBO(0, 80, 255, 1),
//           ),
//           child: Container(
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(30),
//                 topRight: Radius.circular(30),
//               ),
//             ),
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.all(24.0),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Welcome Back',
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       const Text(
//                         'Hello there, sign in to continue!',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey,
//                         ),
//                       ),
//                       const SizedBox(height: 32),
//                       TextFormField(
//                         controller: _usernameController,
//                         focusNode: _usernameFocus,
//                         decoration: InputDecoration(
//                           labelText: 'Username',
//                           filled: true,
//                           fillColor: Colors.grey[100],
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide.none,
//                           ),
//                           suffixIcon: _showUsernameCheck
//                               ? Icon(Icons.check_circle, color: Colors.blue[700])
//                               : null,
//                           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                         ),
//                         onChanged: (value) {
//                           if (value.isEmpty) {
//                             setState(() {
//                               _showUsernameCheck = false;
//                             });
//                           }
//                         },
//                         validator: (value) {
//                           if (value!.isEmpty) {
//                             return 'Please enter a username';
//                           }
//                           return null;
//                         },
//                         onFieldSubmitted: (_) {
//                           FocusScope.of(context).requestFocus(_passwordFocus);
//                         },
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         controller: _passwordController,
//                         focusNode: _passwordFocus,
//                         decoration: InputDecoration(
//                           labelText: 'Password',
//                           filled: true,
//                           fillColor: Colors.grey[100],
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide.none,
//                           ),
//                           suffixIcon: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               if (_showPasswordCheck)
//                                 Icon(Icons.check_circle, color: Colors.blue[700]),
//                               IconButton(
//                                 icon: Icon(
//                                   _obscurePassword ? Icons.visibility_off : Icons.visibility,
//                                   color: Colors.blue[700],
//                                 ),
//                                 onPressed: () {
//                                   setState(() {
//                                     _obscurePassword = !_obscurePassword;
//                                   });
//                                 },
//                               ),
//                             ],
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                         ),
//                         obscureText: _obscurePassword,
//                         onChanged: (value) {
//                           if (value.isEmpty) {
//                             setState(() {
//                               _showPasswordCheck = false;
//                             });
//                           }
//                         },
//                         validator: (value) {
//                           if (value!.isEmpty) {
//                             return 'Please enter a password';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),
//                       TextFormField(
//                         controller: _schoolCodeController,
//                         focusNode: _schoolCodeFocus,
//                         decoration: InputDecoration(
//                           labelText: 'School Code',
//                           filled: true,
//                           fillColor: Colors.grey[100],
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide.none,
//                           ),
//                           suffixIcon: _showSchoolCodeCheck
//                               ? Icon(Icons.check_circle, color: Colors.blue[700])
//                               : null,
//                           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                         ),
//                         onChanged: (value) {
//                           if (value.isEmpty) {
//                             setState(() {
//                               _showSchoolCodeCheck = false;
//                             });
//                           }
//                         },
//                         validator: (value) {
//                           if (value!.isEmpty) {
//                             return 'Please enter a school code';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 8),
//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: TextButton(
//                           onPressed: () {
//                             // Add forgot password functionality
//                           },
//                           child: Text(
//                             'Forgot Password?',
//                             style: TextStyle(
//                               color: Colors.blue[700],
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//                       SizedBox(
//                         width: double.infinity,
//                         height: 50,
//                         child: ElevatedButton(
//                           onPressed: _login,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Color.fromRGBO(0, 80, 255, 1),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: const Text(
//                             'Sign in',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: AppColors.backgroundLight,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }