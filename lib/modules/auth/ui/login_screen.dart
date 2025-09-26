import 'package:flutter/material.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/common/buttons/custom_medium_elevated_button.dart';
import 'package:linkschool/modules/common/constants.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/explore/home/explore_dashboard.dart';
import 'package:provider/provider.dart';

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
  bool _obscureSchoolCode = true;
  bool _isLoading = false;

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
  void dispose() {
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _schoolCodeFocus.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _schoolCodeController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      final username = _usernameController.text;
      final password = _passwordController.text;
      final schoolCode = _schoolCodeController.text;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        await authProvider.login(username, password, schoolCode);
        widget.onLoginSuccess();
        CustomToaster.toastSuccess(context, 'Success', 'Login successful!');
      } catch (e) {
        CustomToaster.toastError(context, 'Error', 'Login failed: $e');
        print('error:$e');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _navigateToExploreDashboard();
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
                Positioned(
                  top: 120,
                  right: 300,
                  left: 0,
                  child: Container(
                    child: InkWell(
                      onTap: () => _navigateToExploreDashboard(),
                      child: Icon(
                        Icons.arrow_back,
                        size: 16,
                        color: AppColors.attCheckColor1,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 100,
                  right: 0,
                  left: 0,
                  child: Container(
                    child: _buildLoginForm(),
                  ),
                ),
                Positioned(
                  top: 700,
                  bottom: 30,
                  left: 60,
                  child: Wrap(
                    children: [
                      SizedBox(height: 150),
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
                )
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
        Padding(
          padding: EdgeInsets.fromLTRB(24, 68, 24, 16),
          child: Wrap(
            children: [
              Image(
                image: AssetImage(
                  'assets/images/explore-images/ls-logo.png',
                ),
                width: 19.23,
                height: 20,
              ),
              SizedBox(width: 10),
              Text("Link",
                  style: AppTextStyles.normal700(
                    fontSize: 16,
                    color: AppColors.aboutTitle,
                  )),
              Text("Skool",
                  style: AppTextStyles.normal700(
                      fontSize: 16, color: AppColors.bgXplore1))
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 24, left: 10, right: 10),
          child: Column(
            // ✅ Use Column instead of Wrap
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
              SizedBox(height: 20), // Add some spacing
              // ✅ Remove Expanded wrapper and add form fields directly
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      focusNode: _usernameFocus,
                      decoration: InputDecoration(
                        hintText: 'Enter Username',
                        filled: true,
                        fillColor: AppColors.assessmentColor1,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a username';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_passwordFocus);
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Enter Password',
                        filled: true,
                        fillColor: AppColors.assessmentColor1,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_schoolCodeFocus);
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _schoolCodeController,
                      focusNode: _schoolCodeFocus,
                      obscureText: _obscureSchoolCode,
                      decoration: InputDecoration(
                        hintText: 'Enter School Code',
                        filled: true,
                        fillColor: AppColors.assessmentColor1,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureSchoolCode
                              ? Icons.visibility_off_rounded
                              : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _obscureSchoolCode = !_obscureSchoolCode;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a school code';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    CustomBlueElevatedButton(
                      text: _isLoading ? 'Signing in...' : 'Login',
                      onPressed: _isLoading ? null : _login,
                      backgroundColor: AppColors.aicircle,
                      textStyle: AppTextStyles.italicTitle700(
                          fontSize: 14, color: AppColors.assessmentColor1),
                      padding:
                          EdgeInsets.symmetric(vertical: 14, horizontal: 140),
                    ),
                    if (_isLoading)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: AppColors.aicircle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Padding(
        //   padding: const EdgeInsets.only(top: 24, left: 10, right: 10),
        //   child: Wrap(
        //     children: [
        //       Text("Get Started now",
        //           style: AppTextStyles.normal700(
        //               fontSize: 32, color: AppColors.bookText)),
        //       Column(
        //         children: [
        //           Padding(
        //             padding:
        //                 const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        //             child: Text(
        //               "Log in and simplify your school processes",
        //               style: AppTextStyles.normal400(
        //                   fontSize: 14, color: AppColors.assessmentColor2),
        //             ),
        //           )
        //         ],
        //       ),
        //       Expanded(
        //         child: Padding(
        //           padding: const EdgeInsets.all(8),
        //           child: Column(
        //             children: [
        //               TextFormField(
        //                 controller: _usernameController,
        //                 focusNode: _usernameFocus,
        //                 decoration: InputDecoration(
        //                   hintText: 'Enter Username',
        //                   filled: true,
        //                   fillColor: AppColors.assessmentColor1,
        //                   contentPadding:
        //                       EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        //                   border: OutlineInputBorder(
        //                     borderRadius: BorderRadius.circular(10),
        //                     borderSide: BorderSide.none,
        //                   ),
        //                 ),
        //                 validator: (value) {
        //                   if (value == null || value.isEmpty) {
        //                     return 'Please enter a username';
        //                   }
        //                   return null;
        //                 },
        //                 onFieldSubmitted: (_) {
        //                   FocusScope.of(context).requestFocus(_passwordFocus);
        //                 },
        //               ),
        //               SizedBox(height: 20),
        //               TextFormField(
        //                 controller: _passwordController,
        //                 focusNode: _passwordFocus,
        //                 obscureText: _obscurePassword,
        //                 decoration: InputDecoration(
        //                   hintText: 'Enter Password',
        //                   filled: true,
        //                   fillColor: AppColors.assessmentColor1,
        //                   contentPadding:
        //                       EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        //                   border: OutlineInputBorder(
        //                     borderRadius: BorderRadius.circular(10),
        //                     borderSide: BorderSide.none,
        //                   ),
        //                   suffixIcon: IconButton(
        //                     icon: Icon(_obscurePassword
        //                         ? Icons.visibility_off
        //                         : Icons.visibility),
        //                     onPressed: () {
        //                       setState(() {
        //                         _obscurePassword = !_obscurePassword;
        //                       });
        //                     },
        //                   ),
        //                 ),
        //                 validator: (value) {
        //                   if (value == null || value.isEmpty) {
        //                     return 'Please enter a password';
        //                   }
        //                   return null;
        //                 },
        //                 onFieldSubmitted: (_) {
        //                   FocusScope.of(context).requestFocus(_schoolCodeFocus);
        //                 },
        //               ),
        //               SizedBox(height: 20),
        //               TextFormField(
        //                 controller: _schoolCodeController,
        //                 focusNode: _schoolCodeFocus,
        //                 obscureText: _obscureSchoolCode,
        //                 decoration: InputDecoration(
        //                   hintText: 'Enter School Code',
        //                   filled: true,
        //                   fillColor: AppColors.assessmentColor1,
        //                   contentPadding:
        //                       EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        //                   border: OutlineInputBorder(
        //                     borderRadius: BorderRadius.circular(10),
        //                     borderSide: BorderSide.none,
        //                   ),
        //                   suffixIcon: IconButton(
        //                     icon: Icon(_obscureSchoolCode
        //                         ? Icons.visibility_off_rounded
        //                         : Icons.visibility),
        //                     onPressed: () {
        //                       setState(() {
        //                         _obscureSchoolCode = !_obscureSchoolCode;
        //                       });
        //                     },
        //                   ),
        //                 ),
        //                 validator: (value) {
        //                   if (value == null || value.isEmpty) {
        //                     return 'Please enter a school code';
        //                   }
        //                   return null;
        //                 },
        //               ),
        //               SizedBox(height: 20),
        //               CustomBlueElevatedButton(
        //                 text: _isLoading ? 'Signing in...' : 'Login',
        //                 onPressed: _isLoading ? null : _login,
        //                 backgroundColor: AppColors.aicircle,
        //                 textStyle: AppTextStyles.italicTitle700(
        //                     fontSize: 14, color: AppColors.assessmentColor1),
        //                 padding:
        //                     EdgeInsets.symmetric(vertical: 14, horizontal: 140),
        //               ),
        //               if (_isLoading)
        //                 Padding(
        //                   padding: const EdgeInsets.only(top: 10),
        //                   child: SizedBox(
        //                     width: 20,
        //                     height: 20,
        //                     child: CircularProgressIndicator(
        //                       strokeWidth: 3,
        //                       color: AppColors.aicircle,
        //                     ),
        //                   ),
        //                 ),
        //             ],
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/auth/provider/auth_provider.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/custom_toaster.dart';
// import 'package:linkschool/modules/explore/home/explore_dashboard.dart';
// import 'package:provider/provider.dart';
// // import 'custom_toaster.dart'; // Import the CustomToaster

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
//   bool _isLoading = false; 
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

//   Future<void> _login() async {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();

//       setState(() {
//         _isLoading = true; // Show loading spinner
//       });

//       final username = _usernameController.text;
//       final password = _passwordController.text;
//       final schoolCode = _schoolCodeController.text;
      

//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       try {
//         await authProvider.login(username, password, schoolCode);
//         widget.onLoginSuccess(); // Ensure this is called
//         CustomToaster.toastSuccess(
//             context, 'Success', 'Login successful!'); // Show success toast
//       } catch (e) {
//         CustomToaster.toastError(
//             context, 'Error', 'Login failed: $e'); // Show error toast
//             print('error:$e');
//       } finally {
//         setState(() {
//           _isLoading = false; // Hide loading spinner
//         });
//       }
//     }
//   }

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
//                               ? Icon(Icons.check_circle,
//                                   color: Colors.blue[700])
//                               : Icon(Icons.error, color: Colors.red),
//                           contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 16, vertical: 14),
//                         ),
//                         onChanged: (value) {
//                           setState(() {
//                             _showUsernameCheck = value.isNotEmpty;
//                           });
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
//                                 Icon(Icons.check_circle,
//                                     color: Colors.blue[700]),
//                               if (!_showPasswordCheck)
//                                 Icon(Icons.error, color: Colors.red),
//                               IconButton(
//                                 icon: Icon(
//                                   _obscurePassword
//                                       ? Icons.visibility_off
//                                       : Icons.visibility,
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
//                           contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 16, vertical: 14),
//                         ),
//                         obscureText: _obscurePassword,
//                         onChanged: (value) {
//                           setState(() {
//                             _showPasswordCheck = value.isNotEmpty;
//                           });
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
//                               ? Icon(Icons.check_circle,
//                                   color: Colors.blue[700])
//                               : Icon(Icons.error, color: Colors.red),
//                           contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 16, vertical: 14),
//                         ),
//                         onChanged: (value) {
//                           setState(() {
//                             _showSchoolCodeCheck = value.isNotEmpty;
//                           });
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
//                           onPressed: _isLoading
//                               ? null
//                               : _login, // Disable button when loading
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Color.fromRGBO(0, 80, 255, 1),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: _isLoading
//                               ? Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Text(
//                                       'Signing in...',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w600,
//                                         color: AppColors.backgroundLight,
//                                       ),
//                                     ),
//                                     SizedBox(
//                                         width:
//                                             8), // Add spacing between text and spinner
//                                     SizedBox(
//                                       width: 20, // Set the width of the spinner
//                                       height:
//                                           20, // Set the height of the spinner
//                                       child: CircularProgressIndicator(
//                                         strokeWidth:
//                                             3, // Adjust the thickness of the spinner
//                                         color: AppColors.backgroundLight,
//                                       ),
//                                     ),
//                                   ],
//                                 )
//                               : Text(
//                                   'Sign in',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                     color: AppColors.backgroundLight,
//                                   ),
//                                 ),
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