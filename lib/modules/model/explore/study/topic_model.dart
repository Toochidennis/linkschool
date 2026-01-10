// Root response model
class SyllabusResponse {
  final int statusCode;
  final bool success;
  final String message;
  final List<Syllabus> data;

  SyllabusResponse({
    required this.statusCode,
    required this.success,
    required this.message,
    required this.data,
  });

  factory SyllabusResponse.fromJson(Map<String, dynamic> json) {
    return SyllabusResponse(
      statusCode: json['statusCode'],
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List)
          .map((e) => Syllabus.fromJson(e))
          .toList(),
    );
  }
}

// Syllabus model
class Syllabus {
  final int syllabusId;
  final String syllabusName;
  final List<Topic> topics;

  Syllabus({
    required this.syllabusId,
    required this.syllabusName,
    required this.topics,
  });

  factory Syllabus.fromJson(Map<String, dynamic> json) {
    return Syllabus(
      syllabusId: json['syllabus_id'],
      syllabusName: json['syllabus_name'],
      topics: (json['topics'] as List)
          .map((e) => Topic.fromJson(e))
          .toList(),
    );
  }
}

// Topic model
class Topic {
  final int topicId;
  final String topicName;

  Topic({
    required this.topicId,
    required this.topicName,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      topicId: json['topic_id'],
      topicName: json['topic_name'],
    );
  }
}
