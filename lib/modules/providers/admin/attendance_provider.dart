// lib/modules/providers/admin/attendance_provider.dart
import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/attendance_record_model.dart';
// import 'package:linkschool/modules/admin/result/models/attendance_record.dart';
import 'package:linkschool/modules/services/admin/attendance_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:intl/intl.dart';

class AttendanceProvider with ChangeNotifier {
  final AttendanceService _attendanceService = locator<AttendanceService>();
  List<AttendanceRecord> _attendanceRecords = [];
  bool _isLoading = false;
  String _error = '';

  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchAttendanceHistory({
    required String classId,
    required String term,
    required String year,
    required String dbName,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await _attendanceService.getAttendanceHistory(
        classId: classId,
        term: term,
        year: year,
        dbName: dbName,
      );

      if (response.success && response.data != null) {
        _attendanceRecords = response.data!;
        _attendanceRecords.sort((a, b) => b.date.compareTo(a.date)); // Sort by date, most recent first
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = 'Failed to fetch attendance records: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Format date to match the desired format (e.g. "Monday, 13 April, 2025")
  String formatDate(DateTime date) {
    return DateFormat('EEEE, d MMMM, yyyy').format(date);
  }
}