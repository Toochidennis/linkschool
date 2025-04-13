// lib/modules/admin/result/models/attendance_record.dart
class AttendanceRecord {
  final int id;
  final int count;
  final DateTime date;

  AttendanceRecord({
    required this.id,
    required this.count,
    required this.date,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'],
      count: json['count'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'count': count,
      'date': date.toIso8601String(),
    };
  }
}