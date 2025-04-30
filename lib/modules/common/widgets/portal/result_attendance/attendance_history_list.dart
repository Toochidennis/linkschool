import 'package:flutter/material.dart';
import 'package:linkschool/modules/admin/result/class_detail/attendance/attendance_history.dart';
import 'package:linkschool/modules/common/app_colors.dart';
import 'package:linkschool/modules/providers/admin/attendance_provider.dart';
import 'package:linkschool/modules/auth/provider/auth_provider.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';

class AttendanceHistoryList extends StatefulWidget {
  final String classId;
  
  const AttendanceHistoryList({
    Key? key, 
    required this.classId,
  }) : super(key: key);

  @override
  State<AttendanceHistoryList> createState() => _AttendanceHistoryListState();
}

class _AttendanceHistoryListState extends State<AttendanceHistoryList> {
  final List<String> subjects = ['English Language', 'Mathematics', 'Physics', 'Chemistry', 'Biology', 'History', 'Geography', 'Literature'];
  
  @override
  void initState() {
    super.initState();
    _fetchAttendanceHistory();
  }

  Future<void> _fetchAttendanceHistory() async {
    final attendanceProvider = locator<AttendanceProvider>();
    final authProvider = locator<AuthProvider>();
    
    // Get settings from auth provider
    final settings = authProvider.settings;
    final userBox = Hive.box('userData');
    final userData = userBox.get('userData');
    
    // Get database name from the stored login response
    final dbName = userData?['_db'] ?? 'aalmgzmy_linkskoo_practice';
    
    // Get term and year from settings
    final term = settings?['term']?.toString() ?? '3';
    final year = settings?['year']?.toString() ?? '2025';
    
    // Fetch attendance history
    await attendanceProvider.fetchAttendanceHistory(
      classId: widget.classId,
      term: term,
      year: year,
      dbName: dbName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(
      builder: (context, attendanceProvider, child) {
        if (attendanceProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (attendanceProvider.error.isNotEmpty) {
          return Center(child: Text('Error: ${attendanceProvider.error}'));
        }
        
        final attendanceRecords = attendanceProvider.attendanceRecords;
        
        if (attendanceRecords.isEmpty) {
          return const Center(child: Text('No attendance records found.'));
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
    List<dynamic> attendanceRecords,
    AttendanceProvider attendanceProvider
  ) {
    final record = attendanceRecords[index];
    // Format date to match the original format (e.g., "Thursday, 20 July, 2026")
    final formattedDate = attendanceProvider.formatDate(record.date);
    
    // Assign a subject from the subjects list (cycling through if needed)
    final subject = subjects[index % subjects.length];
    
    return ListTile(
      leading: Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
        child: const Icon(Icons.check, color: Colors.white, size: 20),
      ),
      title: Text(formattedDate),
      subtitle: Text('Attendance Count: ${record.count}', style: const TextStyle(color: Colors.grey)),
      onTap: () => Navigator.push(
        context, 
        MaterialPageRoute(
          builder: (context) => AttendanceHistoryScreen(
            date: formattedDate,
            attendanceId: record.id.toString(),
          )
        )
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:linkschool/modules/admin/result/class_detail/attendance/attendance_history.dart';
// import 'package:linkschool/modules/common/app_colors.dart';
// // import 'package:linkschool/modules/portal/result/class_detail/attendance/attendance_history.dart';

// class AttendanceHistoryList extends StatefulWidget {
//   const AttendanceHistoryList({super.key});

//   @override
//   State<AttendanceHistoryList> createState() => _AttendanceHistoryListState();
// }

// class _AttendanceHistoryListState extends State<AttendanceHistoryList> {
//   final List<String> subjects = ['English Language', 'Mathematics', 'Physics', 'Chemistry', 'Biology', 'History', 'Geography', 'Literature'];

//   final List<String> dates = ['Thursday, 20 July, 2026', 'Friday, 21 July, 2026', 'Monday, 24 July, 2026', 'Tuesday, 25 July, 2026', 'Wednesday, 26 July, 2026', 'Thursday, 27 July, 2026', 'Friday, 28 July, 2026', 'Monday, 31 July, 2026'];
  

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       color: AppColors.backgroundLight,
//       constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: ListView.separated(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: 8,
//           separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[300], indent: 16, endIndent: 16),
//           itemBuilder: (context, index) => _buildAttendanceHistoryItem(context, index),
//         ),
//       ),
//     );
//   }

//   Widget _buildAttendanceHistoryItem(BuildContext context, int index) {
//     return ListTile(
//       leading: Container(
//         width: 30,
//         height: 30,
//         decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
//         child: const Icon(Icons.check, color: Colors.white, size: 20),
//       ),
//       title: Text(dates[index]),
//       subtitle: Text(subjects[index], style: const TextStyle(color: Colors.grey)),
//       onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AttendanceHistoryScreen(date: dates[index]))),
//     );
//   }
// }