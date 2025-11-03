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
    
    // Safe parsing with null checks
    int? parseId(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value);
      }
      return null;
    }

    int? parseSyllabusId(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value);
      }
      return null;
    }

    List<ClassModel> parseClasses(dynamic classesData) {
      if (classesData == null) return [];
      if (classesData is! List) return [];
      
      return classesData
          .where((e) => e != null)
          .map((e) {
            try {
              return ClassModel.fromJson(e as Map<String, dynamic>);
            } catch (error) {
              print('Error parsing class: $error');
              return null;
            }
          })
          .where((e) => e != null)
          .cast<ClassModel>()
          .toList();
    }

    return Topic(
      id: parseId(json['id']),
      name: (json['content'] as String?) ?? (json['name'] as String?) ?? '', // Handle both content and name fields
      objective: json['objective'] as String?,
      classes: parseClasses(json['classes']),
      syllabusId: parseSyllabusId(json['syllabus_id']),
      description: json['description'] as String?,
      creatorName: json['creator_name'] as String?,
      creatorId: parseId(json['creator_id']),
      assignments: const [],
      questions: const [],
      materials: const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'syllabus_id': syllabusId,
      'content': name,
      'name': name,
      'description': description,
      'objective': objective,
      'creator_name': creatorName,
      'creator_id': creatorId,
      'classes': classes?.map((e) => e.toJson()).toList(),
    };
  }
}

class ClassModel {
  final int id;
  final String name;

  ClassModel({required this.id, required this.name});

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    // Safe parsing for ID
    int parseId(dynamic value) {
      if (value is int) return value;
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
      throw FormatException('Invalid ID format: $value');
    }

    return ClassModel(
      id: parseId(json['id']),
      name: (json['name'] as String?) ?? (json['class_name'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  @override
  String toString() => 'id: $id, name: $name';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}


