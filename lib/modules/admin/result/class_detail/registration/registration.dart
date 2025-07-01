import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/widgets/portal/result_register/button_section.dart';
import 'package:linkschool/modules/common/widgets/portal/result_register/history_section.dart';
import 'package:linkschool/modules/common/widgets/portal/result_register/top_container.dart';
import 'package:linkschool/modules/services/api/api_service.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';

class RegistrationScreen extends StatefulWidget {
  final String classId;
  const RegistrationScreen({super.key, required this.classId});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final ApiService _apiService = locator<ApiService>();
  final AuthProvider _authProvider = locator<AuthProvider>();
  String _selectedTerm = 'First term';

  @override
  void initState() {
    super.initState();
    // Ensure the auth token is set
    if (_authProvider.token != null) {
      _apiService.setAuthToken(_authProvider.token!);
    }
    
    // Set initial term based on server data
    _setInitialTerm();
  }

  void _setInitialTerm() {
    final settings = _authProvider.getSettings();
    final termNumber = settings['term'] ?? 1;
    
    switch (termNumber) {
      case 1:
        _selectedTerm = 'First term';
        break;
      case 2:
        _selectedTerm = 'Second term';
        break;
      case 3:
        _selectedTerm = 'Third term';
        break;
      default:
        _selectedTerm = 'First term';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registration',
          style: AppTextStyles.normal600(
              fontSize: 18.0, color: AppColors.primaryLight),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            color: AppColors.primaryLight,
            width: 34.0,
            height: 34.0,
          ),
        ),
        backgroundColor: AppColors.backgroundLight,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TopContainer(
              selectedTerm: _selectedTerm,
              onTermChanged: (newValue) {
                setState(() {
                  _selectedTerm = newValue!;
                });
              },
              classId: widget.classId,
              apiService: _apiService,
              authProvider: _authProvider,
            ),
            ButtonSection(classId: widget.classId),
            const SizedBox(height: 25),
            HistorySection(classId: widget.classId),
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// import 'package:linkschool/modules/common/text_styles.dart';
// import 'package:linkschool/modules/common/widgets/portal/result_register/button_section.dart';
// import 'package:linkschool/modules/common/widgets/portal/result_register/history_section.dart';
// import 'package:linkschool/modules/common/widgets/portal/result_register/top_container.dart';
// import 'package:linkschool/modules/services/api/api_service.dart';
// import 'package:linkschool/modules/auth/provider/auth_provider.dart';
// import 'package:linkschool/modules/services/api/service_locator.dart';

// class RegistrationScreen extends StatefulWidget {
//   final String classId;
//   const RegistrationScreen({super.key, required this.classId});

//   @override
//   State<RegistrationScreen> createState() => _RegistrationScreenState();
// }

// class _RegistrationScreenState extends State<RegistrationScreen> {
//   String _selectedTerm = 'First term';
//   final ApiService _apiService = locator<ApiService>();
//   final AuthProvider _authProvider = locator<AuthProvider>();

//   @override
//   void initState() {
//     super.initState();
//     // Ensure the auth token is set
//     if (_authProvider.token != null) {
//       _apiService.setAuthToken(_authProvider.token!);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Registration',
//           style: AppTextStyles.normal600(
//               fontSize: 18.0, color: AppColors.primaryLight),
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           icon: Image.asset(
//             'assets/icons/arrow_back.png',
//             color: AppColors.primaryLight,
//             width: 34.0,
//             height: 34.0,
//           ),
//         ),
//         backgroundColor: AppColors.backgroundLight,
//         elevation: 0.0,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             TopContainer(
//               selectedTerm: _selectedTerm,
//               onTermChanged: (newValue) {
//                 setState(() {
//                   _selectedTerm = newValue!;
//                 });
//               },
//               classId: widget.classId,
//               apiService: _apiService,
//               authProvider: _authProvider,
//             ),
//             ButtonSection(classId: widget.classId),
//             const SizedBox(height: 25),
//             HistorySection(classId: widget.classId),
//           ],
//         ),
//       ),
//     );
//   }
// }