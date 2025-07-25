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
    print('AttendanceProvider: Fetching attendance history with params:');
    print('- classId: $classId');
    print('- term: $term');
    print('- year: $year');
    print('- dbName: $dbName');

    final response = await _attendanceService.getAttendanceHistory(
      classId: classId,
      term: term,
      year: year,
      dbName: dbName,
    );

    print('AttendanceProvider: Response received - Success: ${response.success}');
    print('AttendanceProvider: Raw data: ${response.rawData}'); // Add raw data logging
    
    if (response.success && response.data != null) {
      _attendanceRecords = response.data!;
      _attendanceRecords.sort((a, b) => b.date.compareTo(a.date));
      print('AttendanceProvider: ${_attendanceRecords.length} records loaded');
      print('AttendanceProvider: Records: ${_attendanceRecords.map((r) => r.toJson())}'); // Log records
      _error = '';
    } else {
      _error = response.message.isNotEmpty 
        ? response.message 
        : 'Failed to load attendance history';
      print('AttendanceProvider: Error - $_error');
    }
  } catch (e) {
    _error = 'Failed to fetch attendance records: ${e.toString()}';
    print('AttendanceProvider: Exception - $_error');
    
    if (e.toString().contains('Values for IN cannot be empty')) {
      _error = 'Invalid parameters provided. Please check your class selection.';
    } else if (e.toString().contains('Network')) {
      _error = 'Network error. Please check your internet connection.';
    } else if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
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
    print('AttendanceProvider: Fetching attendance details for ID: $attendanceId, dbName: $dbName');
    
    final response = await _attendanceService.getAttendanceDetails(
      attendanceId: attendanceId,
      dbName: dbName,
    );

    print('AttendanceProvider: Response received - Success: ${response.success}, Status: ${response.statusCode}');
    print('AttendanceProvider: Raw data: ${response.rawData}');

    if (response.success && response.data != null) {
      _attendanceDetails = response.data;
      _error = '';
      print('AttendanceProvider: Attendance details loaded successfully');
    } else {
      _error = response.message.isNotEmpty 
          ? response.message 
          : 'Failed to load attendance details: No data received';
      print('AttendanceProvider: Error loading details - $_error');
    }
  } catch (e) {
    _error = 'Failed to fetch attendance details: ${e.toString()}';
    print('AttendanceProvider: Exception loading details - $_error');
    
    if (e.toString().contains('Network')) {
      _error = 'Network error. Please check your internet connection.';
    } else if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
      _error = 'Session expired. Please login again.';
    }
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}


  // Future<void> fetchAttendanceDetails({
  //   required String attendanceId,
  //   required String dbName,
  // }) async {
  //   // Validate required parameters
  //   if (attendanceId.isEmpty) {
  //     _error = 'Attendance ID cannot be empty';
  //     notifyListeners();
  //     return;
  //   }

  //   if (dbName.isEmpty) {
  //     _error = 'Database name cannot be empty';
  //     notifyListeners();
  //     return;
  //   }

  //   _isLoading = true;
  //   _error = '';
  //   _attendanceDetails = null;
  //   notifyListeners();

  //   try {
  //     print('AttendanceProvider: Fetching attendance details for ID: $attendanceId');
      
  //     final response = await _attendanceService.getAttendanceDetails(
  //       attendanceId: attendanceId,
  //       dbName: dbName,
  //     );

  //     if (response.success && response.data != null) {
  //       _attendanceDetails = response.data;
  //       _error = ''; // Clear any previous errors
  //       print('AttendanceProvider: Attendance details loaded successfully');
  //     } else {
  //       _error = response.message.isNotEmpty 
  //         ? response.message 
  //         : 'Failed to load attendance details';
  //       print('AttendanceProvider: Error loading details - $_error');
  //     }
  //   } catch (e) {
  //     _error = 'Failed to fetch attendance details: ${e.toString()}';
  //     print('AttendanceProvider: Exception loading details - $_error');
      
  //     // More specific error handling
  //     if (e.toString().contains('Network')) {
  //       _error = 'Network error. Please check your internet connection.';
  //     } else if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
  //       _error = 'Session expired. Please login again.';
  //     }
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

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