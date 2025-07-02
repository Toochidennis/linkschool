import 'dart:convert';

import 'package:linkschool/modules/model/e-learning/material_model.dart';
import 'package:linkschool/modules/model/e-learning/question_model.dart';
import 'package:linkschool/modules/admin/e_learning/admin_assignment_screen.dart';

class Topic {
  final int? id;
  final int? syllabusId;
  final String name;
  final String? description;
  final String? objective;
  final String? creatorName;
  final int? creatorId;
  final List<ClassModel>? classes;
  final List<Assignment> assignments;
  final List<Question> questions;
  final List<Material> materials;

  Topic({
    this.id,
    this.syllabusId,
    required this.name,
    this.description,
    this.objective,
    this.creatorName,
    this.creatorId,
    this.classes,
    required this.assignments,
    required this.questions,
    required this.materials,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    print('Parsing topic: ${json['content']}');
    return Topic(
      id: json['id'] as int ,
      name: json['content'] as String? ?? '', // Map content to name
      objective: json['objective'] as String?,
      classes: (json['classes'] as List<dynamic>?)
              ?.map((e) => ClassModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      syllabusId: json['syllabus_id'] as int?, // Use syllabus_id to match API
      description: json['description'] as String?,
      creatorName: json['creator_name'] as String?,
      creatorId: json['creator_id'] as int?,
      assignments: const [],
      questions: const [],
      materials: const [],
    );
  }
}

class ClassModel {
  final int id;
  final String name;

  ClassModel({required this.id, required this.name});

  factory ClassModel.fromJson(Map<String, dynamic> json) => ClassModel(
        id: int.parse(json['id'].toString()), // Handle string IDs
        name: json['name'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  @override
  String toString() => 'id: $id, name: $name';
}