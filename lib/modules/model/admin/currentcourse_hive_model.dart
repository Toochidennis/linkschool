import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class CourseRegistrationModel {
  @HiveField(0)
  final int year;

  @HiveField(1)
  final String term;

  @HiveField(2)
  final int classId;

  @HiveField(3)
  final Map<String, dynamic> data; // Store the API response data

  CourseRegistrationModel({
    required this.year,
    required this.term,
    required this.classId,
    required this.data,
  });
}