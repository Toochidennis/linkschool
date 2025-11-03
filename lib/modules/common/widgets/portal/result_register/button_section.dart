import 'package:flutter/material.dart';
import 'package:linkschool/modules/admin/result/class_detail/registration/bulk_registration.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/common/buttons/custom_long_elevated_button.dart';
import 'package:linkschool/modules/common/text_styles.dart';
import 'package:linkschool/modules/common/utils/registration/registration_utils.dart';
import 'package:linkschool/config/env_config.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/common/custom_toaster.dart';
import 'package:linkschool/modules/services/api/api_service.dart';


class ButtonSection extends StatelessWidget {
  final String classId;
  
  const ButtonSection({super.key, required this.classId});
  
  // Method to duplicate course registration
  Future<void> _duplicateCourseRegistration(BuildContext context, String classId) async {
    try {
      // Get auth token from AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      
      // Alternative: Get token from Hive if Provider is not accessible
      String? tokenFromHive;
      if (token == null) {
        final userBox = Hive.box('userData');
        tokenFromHive = userBox.get('token');
      }
      
      // Create API service with API key from environment
      final apiService = ApiService(
        apiKey: EnvConfig.apiKey,
        baseUrl: EnvConfig.apiBaseUrl
      );
      
      // Set the auth token
      final authToken = token ?? tokenFromHive;
      if (authToken != null && authToken.isNotEmpty) {
        apiService.setAuthToken(authToken);
      } else {
        // If token is not available, show an error
        CustomToaster.toastError(
          context, 
          'Authentication Error', 
          'You need to be logged in to perform this action'
        );
        return;
      }
      
      final payload = {
        "_db": EnvConfig.dbName
      };
      
      // Use the ApiService to send the POST request
      final response = await apiService.post(
        endpoint: 'portal/classes/$classId/course-registrations/duplicate',
        body: payload,
      );
      
      // Check if the request was successful
      if (response.success) {
        // Show success toast
        CustomToaster.toastSuccess(
          context, 
          'Success', 
          'Course registration copied successfully'
        );
      } else {
        // Error handling
        CustomToaster.toastError(
          context, 
          'Error', 
          response.message
        );
      }
    } catch (e) {
      // Exception handling
      CustomToaster.toastError(
        context, 
        'Error', 
        'An error occurred: ${e.toString()}'
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CustomLongElevatedButton(
            text: 'Register Student',
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BulkRegistrationScreen(classId: classId))),
            backgroundColor: AppColors.videoColor4,
            textStyle: AppTextStyles.normal600(
                fontSize: 16, color: AppColors.backgroundLight),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.regBtnColor2,
                    side: const BorderSide(color: AppColors.videoColor4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Implement onPressed to call the duplicate API
                  onPressed: () => _duplicateCourseRegistration(context, classId),
                  child: Text(
                    '+ Copy registration',
                    style: AppTextStyles.normal600(
                        fontSize: 12, color: AppColors.videoColor4),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.regBtnColor2,
                    side: const BorderSide(color: AppColors.videoColor4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text('+ Bulk registration',
                      style: AppTextStyles.normal600(
                          fontSize: 12, color: AppColors.videoColor4)),
                  onPressed: () {
                    // Pass classId directly to the showRegistrationDialog function
                    print('ButtonSection: Calling showRegistrationDialog with classId: $classId');
                    showRegistrationDialog(context, classId: classId);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

