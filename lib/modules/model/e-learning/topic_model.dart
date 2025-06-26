import 'package:linkschool/modules/model/e-learning/material_model.dart';
import 'package:linkschool/modules/model/e-learning/question_model.dart';
import 'package:linkschool/modules/admin/e_learning/admin_assignment_screen.dart';

class Topic {
  final int? syllabusId;
  final String name;
  final String? description;
  final String? objective;
  final String? creatorName;
  final int? creatorId;
  final List<ClassModel>? classes; // You can create a ClassInfo model for better typing
  final String? db;
  final List<Assignment> assignments;
  final List<Question> questions;
  final List<Material> materials;

  Topic({
    this.syllabusId,
    required this.name,
    this.description,
    this.objective,
    this.creatorName,
    this.creatorId,
    this.classes,
    this.db,
    required this.assignments,
    required this.questions,
    required this.materials,
  });
}

class ClassModel {
  final int id;
  final String name;

  ClassModel({required this.id, required this.name});

  factory ClassModel.fromJson(Map<String, dynamic> json) => ClassModel(
        id: json['id'],
        name: json['name'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  @override
  String toString() => 'id: $id, name: $name';
}
