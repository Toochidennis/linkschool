import 'dart:convert';

RecentActivityResponse recentActivityResponseFromJson(String str) =>
    RecentActivityResponse.fromJson(json.decode(str));

String recentActivityResponseToJson(RecentActivityResponse data) =>
    json.encode(data.toJson());

class RecentActivityResponse {
  final int? statusCode;
  final bool? success;
  final Data? data;

  RecentActivityResponse({
    this.statusCode,
    this.success,
    this.data,
  });

  factory RecentActivityResponse.fromJson(Map<String, dynamic> json) =>
      RecentActivityResponse(
        statusCode: json["statusCode"],
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "statusCode": statusCode,
        "success": success,
        "data": data?.toJson(),
      };
}

class Data {
  final List<RecentActivity>? recentActivities;
  final List<FormClass>? formClasses;
  final List<AssignedCourse>? assignedCourses;
  final Feeds? feeds;

  Data({
    this.recentActivities,
    this.formClasses,
    this.assignedCourses,
    this.feeds,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        recentActivities: json["recent_activities"] == null
            ? []
            : List<RecentActivity>.from(json["recent_activities"]
                .map((x) => RecentActivity.fromJson(x))),
        formClasses: json["form_classes"] == null
            ? []
            : List<FormClass>.from(
                json["form_classes"].map((x) => FormClass.fromJson(x))),
        assignedCourses: json["assigned_courses"] == null
            ? []
            : List<AssignedCourse>.from(json["assigned_courses"]
                .map((x) => AssignedCourse.fromJson(x))),
        feeds: json["feeds"] == null ? null : Feeds.fromJson(json["feeds"]),
      );

  Map<String, dynamic> toJson() => {
        "recent_activities":
            recentActivities?.map((x) => x.toJson()).toList() ?? [],
        "form_classes": formClasses?.map((x) => x.toJson()).toList() ?? [],
        "assigned_courses":
            assignedCourses?.map((x) => x.toJson()).toList() ?? [],
        "feeds": feeds?.toJson(),
      };
}

class RecentActivity {
  final int? id;
  final int? syllabusId;
  final int? courseId;
  final String? levelId;
  final String? title;
  final String? courseName;
  final List<ClassItem>? classes;
  final String? createdBy;
  final String? datePosted;
  final String? type;
  final String? comment;

  RecentActivity({
    this.id,
    this.syllabusId,
    this.courseId,
    this.levelId,
    this.title,
    this.courseName,
    this.classes,
    this.createdBy,
    this.datePosted,
    this.type,
    this.comment,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) => RecentActivity(
        id: json["id"],
        syllabusId: json["syllabus_id"],
        courseId: json["course_id"],
        levelId: json["level_id"],
        title: json["title"],
        courseName: json["course_name"],
        classes: json["classes"] == null
            ? []
            : List<ClassItem>.from(
                json["classes"].map((x) => ClassItem.fromJson(x))),
        createdBy: json["created_by"],
        datePosted: json["date_posted"],
        type: json["type"],
        comment: json["comment"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "syllabus_id": syllabusId,
        "course_id": courseId,
        "level_id": levelId,
        "title": title,
        "course_name": courseName,
        "classes": classes?.map((x) => x.toJson()).toList() ?? [],
        "created_by": createdBy,
        "date_posted": datePosted,
        "type": type,
        "comment": comment,
      };
}

class ClassItem {
  final String? id;
  final String? name;

  ClassItem({
    this.id,
    this.name,
  });

  factory ClassItem.fromJson(Map<String, dynamic> json) => ClassItem(
        id: json["id"].toString(),
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

class FormClass {
  final int? levelId;
  final String? levelName;
  final List<ClassDetail>? classes;

  FormClass({
    this.levelId,
    this.levelName,
    this.classes,
  });

  factory FormClass.fromJson(Map<String, dynamic> json) => FormClass(
        levelId: json["level_id"],
        levelName: json["level_name"],
        classes: json["classes"] == null
            ? []
            : List<ClassDetail>.from(
                json["classes"].map((x) => ClassDetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "level_id": levelId,
        "level_name": levelName,
        "classes": classes?.map((x) => x.toJson()).toList() ?? [],
      };
}

class ClassDetail {
  final int? classId;
  final String? className;
  final int? totalStudents;

  ClassDetail({
    this.classId,
    this.className,
    this.totalStudents,
  });

  factory ClassDetail.fromJson(Map<String, dynamic> json) => ClassDetail(
        classId: json["class_id"],
        className: json["class_name"],
        totalStudents: json["total_students"],
      );

  Map<String, dynamic> toJson() => {
        "class_id": classId,
        "class_name": className,
        "total_students": totalStudents,
      };
}

class AssignedCourse {
  final int? classId;
  final String? className;
  final int? levelId;
  final List<Course>? courses;

  AssignedCourse({
    this.classId,
    this.className,
    this.levelId,
    this.courses,
  });

  factory AssignedCourse.fromJson(Map<String, dynamic> json) => AssignedCourse(
        classId: json["class_id"],
        className: json["class_name"],
        levelId: json["level_id"],
        courses: json["courses"] == null
            ? []
            : List<Course>.from(json["courses"].map((x) => Course.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "class_id": classId,
        "class_name": className,
        "level_id": levelId,
        "courses": courses?.map((x) => x.toJson()).toList() ?? [],
      };
}

class Course {
  final int? courseId;
  final String? courseName;

  Course({
    this.courseId,
    this.courseName,
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        courseId: json["course_id"],
        courseName: json["course_name"],
      );

  Map<String, dynamic> toJson() => {
        "course_id": courseId,
        "course_name": courseName,
      };
}

class Feeds {
  final List<StafFeed>? news;
  final List<StafFeed>? questions;

  Feeds({
    this.news,
    this.questions,
  });

  factory Feeds.fromJson(Map<String, dynamic> json) => Feeds(
        news: json["news"] == null
            ? []
            : List<StafFeed>.from(
                json["news"].map((x) => StafFeed.fromJson(x))),
        questions: json["questions"] == null
            ? []
            : List<StafFeed>.from(
                json["questions"].map((x) => StafFeed.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "news": news?.map((x) => x.toJson()).toList() ?? [],
        "questions": questions?.map((x) => x.toJson()).toList() ?? [],
      };
}

class StafFeed {
  final int id;
  final String title;
  String content;
  final int? parentId;
  final String authorName;
  final int authorId;
  final String type;
  final String createdAt;
  final List<StafFeed> replies;

  StafFeed({
    required this.id,
    required this.title,
    required this.content,
    required this.parentId,
    required this.authorName,
    required this.authorId,
    required this.type,
    required this.createdAt,
    required this.replies,
  });

  factory StafFeed.fromJson(Map<String, dynamic> json) {
    return StafFeed(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      parentId: json['parent_id'],
      authorName: json['author_name'] ?? '',
      authorId: json['author_id'] ?? 0,
      type: json['type']?.toString() ?? '',
      createdAt: json['created_at'] ?? '',
      replies: (json['replies'] as List?)
              ?.map((reply) => StafFeed.fromJson(reply as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'parent_id': parentId,
      'author_name': authorName,
      'author_id': authorId,
      'type': type,
      'created_at': createdAt,
      'replies': replies.map((reply) => reply.toJson()).toList(),
    };
  }
}
