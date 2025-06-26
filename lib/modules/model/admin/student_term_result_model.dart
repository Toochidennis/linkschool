// import 'package:freezed_annotation/freezed_annotation.dart';

// part 'student_term_result_model.freezed.dart';
// part 'student_term_result_model.g.dart';

// @freezed
// class StudentTermResult with _$StudentTermResult {
//   const factory StudentTermResult({
//     required int position,
//     required double average,
//     required int totalStudents,
//     required List<SubjectResult> subjects,
//   }) = _StudentTermResult;

//   factory StudentTermResult.fromJson(Map<String, dynamic> json) =>
//       _$StudentTermResultFromJson(json);
// }

// @freezed
// class SubjectResult with _$SubjectResult {
//   const factory SubjectResult({
//     required String courseName,
//     required List<Assessment> assessments,
//     required String total,
//     required String grade,
//     required String remark,
//   }) = _SubjectResult;

//   factory SubjectResult.fromJson(Map<String, dynamic> json) =>
//       _$SubjectResultFromJson(json);
// }

// @freezed
// class Assessment with _$Assessment {
//   const factory Assessment({
//     required String assessmentName,
//     required double score,
//   }) = _Assessment;

//   factory Assessment.fromJson(Map<String, dynamic> json) =>
//       _$AssessmentFromJson(json);
// }