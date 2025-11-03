import 'package:flutter/material.dart';
import 'package:linkschool/modules/admin/result/class_detail/attendance/attendance_history.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/model/admin/attendance_record_model.dart';
import 'package:linkschool/modules/providers/admin/attendance_provider.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';

class AttendanceHistoryList extends StatefulWidget {
  final String classId;
   final VoidCallback? onRefresh; 
  const AttendanceHistoryList({
    super.key,
    required this.classId,
    this.onRefresh
  });

  @override
  State<AttendanceHistoryList> createState() => AttendanceHistoryListState();
}

class AttendanceHistoryListState extends State<AttendanceHistoryList> {
  final List<String> subjects = [
    'English Language',
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'History',
    'Geography',
    'Literature'
  ];

Future<void> refreshData() async {
    await _fetchAttendanceHistory();
   
  }



  @override
  void initState() {
    super.initState();
    // Defer the API call until after the build phase
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _fetchAttendanceHistory();
      
    // });
  }

  Future<void> _fetchAttendanceHistory() async {
    try {
      final attendanceProvider = locator<AttendanceProvider>();
      final authProvider = locator<AuthProvider>();

      // Validate classId first
      if (widget.classId.isEmpty) {
        throw Exception('Class ID is required but not provided');
      }

      // Get userData from Hive with validation
      final userBox = Hive.box('userData');
      final userData = userBox.get('userData');
      
      if (userData == null) {
        throw Exception('User data not found. Please login again.');
      }

      // Extract database name with validation
      final dbName = userData['_db'];
      if (dbName == null || dbName.toString().isEmpty) {
        throw Exception('Database name not found in user data');
      }

      // Get settings with proper validation
      final settings = authProvider.settings ?? authProvider.getSettings();
      if (settings.isEmpty) {
        throw Exception('Settings not found. Please login again.');
      }

      // Extract term and year with proper type handling and validation
      final termValue = settings['term'];
      final yearValue = settings['year'];

      if (termValue == null || yearValue == null) {
        throw Exception('Term or year not found in settings');
      }

      // Convert to string, handling both int and string types
      final term = termValue.toString();
      final year = yearValue.toString();

      // Additional validation
      if (term.isEmpty || year.isEmpty) {
        throw Exception('Term or year is empty');
      }

      print('Fetching attendance with params:');
      print('- classId: ${widget.classId}');
      print('- term: $term');
      print('- year: $year');
      print('- dbName: $dbName');

      // Fetch attendance history with validated parameters
      await attendanceProvider.fetchAttendanceHistory(
        classId: widget.classId,
        term: term,
        year: year,
        dbName: dbName.toString(),
      );

    } catch (e) {
      print('Error in _fetchAttendanceHistory: $e');
      // Set error in provider to show in UI
      final attendanceProvider = locator<AttendanceProvider>();
      // Since we can't directly set error, we'll let the provider handle it
      // The error will be caught by the provider's try-catch block
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(
      builder: (context, attendanceProvider, child) {

       

        if (attendanceProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (attendanceProvider.error.isNotEmpty) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 8),
                Text(
                  'Error loading attendance history',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  attendanceProvider.error,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _fetchAttendanceHistory,
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        final attendanceRecords = attendanceProvider.attendanceRecords;

        if (attendanceRecords.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.history,
                  color: Colors.grey,
                  size: 48,
                ),
                const SizedBox(height: 8),
                Text(
                  'No attendance records found',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          width: double.infinity,
          color: AppColors.backgroundLight,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: attendanceRecords.length > 8 ? 8 : attendanceRecords.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[300], indent: 16, endIndent: 16),
              itemBuilder: (context, index) => _buildAttendanceHistoryItem(context, index, attendanceRecords, attendanceProvider),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttendanceHistoryItem(
    BuildContext context,
    int index,
    List<AttendanceRecord> attendanceRecords,
    AttendanceProvider attendanceProvider,
  ) {
    final record = attendanceRecords[index];
    final formattedDate = attendanceProvider.formatDate(record.date);
    final subject = record.courseName.isNotEmpty ? record.courseName : subjects[index % subjects.length]; // Fallback to subjects list if courseName is empty

    return ListTile(
      leading: Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
        child: const Icon(Icons.check, color: Colors.white, size: 20),
      ),
      title: Text(formattedDate),
      subtitle: Text('Subject: $subject, Count: ${record.count}', style: const TextStyle(color: Colors.grey)),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AttendanceHistoryScreen(
            date: formattedDate,
            attendanceId: record.id.toString(),
          ),
        ),
      ),
    );
  }
}



