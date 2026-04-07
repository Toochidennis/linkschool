import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/admin/attendance_record_model.dart';
import 'package:linkschool/modules/services/admin/attendance_service.dart';
import 'package:linkschool/modules/services/api/service_locator.dart';
import 'package:intl/intl.dart';

class AttendanceProvider with ChangeNotifier {
  final AttendanceService _attendanceService = locator<AttendanceService>();
  List<AttendanceRecord> _attendanceRecords = [];
  AttendanceRecord? _attendanceDetails;
  bool _isLoading = false;
  String _error = '';

  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;
  AttendanceRecord? get attendanceDetails => _attendanceDetails;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchAttendanceHistory({
    required String classId,
    required String term,
    required String year,
    required String dbName,
  }) async {
    if (classId.isEmpty) {
      _error = 'Class ID cannot be empty';
      notifyListeners();
      return;
    }

    if (term.isEmpty) {
      _error = 'Term cannot be empty';
      notifyListeners();
      return;
    }

    if (year.isEmpty) {
      _error = 'Year cannot be empty';
      notifyListeners();
      return;
    }

    if (dbName.isEmpty) {
      _error = 'Database name cannot be empty';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = '';
    _attendanceRecords = [];
    notifyListeners();

    try {

      final response = await _attendanceService.getAttendanceHistory(
        classId: classId,
        term: term,
        year: year,
        dbName: dbName,
      );

 // Add raw data logging

      if (response.success && response.data != null) {
        _attendanceRecords = response.data!;
        _attendanceRecords.sort((a, b) => b.date.compareTo(a.date));
 // Log records
        _error = '';
      } else {
        _error = response.message.isNotEmpty
            ? response.message
            : 'Failed to load attendance history';
      }
    } catch (e) {
      _error = 'Failed to fetch attendance records: ${e.toString()}';

      if (e.toString().contains('Values for IN cannot be empty')) {
        _error =
            'Invalid parameters provided. Please check your class selection.';
      } else if (e.toString().contains('Network')) {
        _error = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        _error = 'Session expired. Please login again.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAttendanceDetails({
    required String attendanceId,
    required String dbName,
  }) async {
    if (attendanceId.isEmpty) {
      _error = 'Attendance ID cannot be empty';
      notifyListeners();
      return;
    }

    if (dbName.isEmpty) {
      _error = 'Database name cannot be empty';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = '';
    _attendanceDetails = null;
    notifyListeners();

    try {

      final response = await _attendanceService.getAttendanceDetails(
        attendanceId: attendanceId,
        dbName: dbName,
      );


      if (response.success && response.data != null) {
        _attendanceDetails = response.data;
        _error = '';
      } else {
        _error = response.message.isNotEmpty
            ? response.message
            : 'Failed to load attendance details: No data received';
      }
    } catch (e) {
      _error = 'Failed to fetch attendance details: ${e.toString()}';

      if (e.toString().contains('Network')) {
        _error = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        _error = 'Session expired. Please login again.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('EEEE, d MMMM, yyyy').format(date);
  }

  // Method to clear errors
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Method to reset provider state
  void reset() {
    _attendanceRecords = [];
    _attendanceDetails = null;
    _isLoading = false;
    _error = '';
    notifyListeners();
  }
}

