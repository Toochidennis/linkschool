import 'package:flutter/material.dart';
import 'package:linkschool/modules/admin/home/quick_actions/manage_course_screen.dart';
import 'package:linkschool/modules/admin/home/quick_actions/manage_level_class_screen.dart';
import 'package:linkschool/modules/admin/home/quick_actions/manage_staffs_screen.dart';

import 'package:linkschool/modules/admin/home/quick_actions/student_statistics_screen.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/admin/general_settings.dart';
import 'package:provider/provider.dart';

class AdminSettingsScreen extends StatefulWidget {
  final VoidCallback? onLogout;
  const AdminSettingsScreen({super.key, this.onLogout});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true, // Allow programmatic pop
      onPopInvokedWithResult: (didPop, result) {
        // Only prevent physical back button, allow programmatic navigation
        if (didPop) {
          return; // Already popped, do nothing
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFF4A4FBC), // Blue color from image
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 24,
            ),
          ),
          title: const Text(
            'Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: 'Urbanist',
            ),
          ),
          centerTitle: false,
        ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 1),
            _buildSettingsItem(
              title: 'General settings',
              onTap: () {
                // Navigate to general settings
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GeneralSettingsScreen(),
                  ),
                );
              },
            ),
            _buildDivider(),
            _buildSettingsItem(
              title: 'Level & Class',
              onTap: () {
                // Navigate to level settings
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LevelClassManagementScreen(),
                  ),
                );
              },
            ),
            _buildDivider(),
            _buildSettingsItem(
              title: 'Courses',
              onTap: () {
               Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CourseManagementScreen(),
                  ),
                );
              },
            ),
            _buildDivider(),
            _buildSettingsItem(
              title: 'Manage Students',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StudentStatisticsScreen(),
                  ),
                );
              },
            ),
            _buildDivider(),
            _buildSettingsItem(
              title: 'Staff Directory',
              onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManageStaffScreen(),
                  ),
                );
                
              },
            ),
            _buildDivider(),
           
            _buildDivider(),
            _buildSettingsItem(
              title: 'Logout',
              onTap: () async {
                  final authProvider =
                      Provider.of<AuthProvider>(context, listen: false);
                  await authProvider.logout(); // Clear user data from Hive
                  if (widget.onLogout != null) {
                    widget.onLogout!(); // This triggers the flip to explore dashboard
                  }
                  Navigator.of(context).pop(); // Pop the settings screen
                },
              isLogout: true,
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildSettingsItem({
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 20.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: isLogout ? Colors.red : Colors.black87,
                  fontFamily: 'Urbanist',
                ),
              ),
              if (!isLogout)
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 24,
                ),
              if (isLogout)
                Icon(
                  Icons.logout,
                  color: Colors.red,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: Colors.grey[200],
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
    );
  }


}