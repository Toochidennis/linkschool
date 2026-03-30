import 'dart:convert';

class ExamModel {
  final String id;
  final String title;
  final String description;
  final String courseName;
  final String courseId;
  final String? body;
  final String? url;

  ExamModel({
    required this.id,
    required this.title,
    required this.description,
    required this.courseName,
    required this.courseId,
    this.body,
    this.url,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: _safeToString(json['id']),
      title: _safeToString(json['title']),
      description: _safeToString(json['description']),
      courseName: _safeToString(json['course_name']),
      courseId: _safeToString(json['course_id']),
      body: _safeToString(json['body']),
      url: _safeToString(json['url']),
    );
  }

  // Helper method to safely convert any type to String
  static String _safeToString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }
}

class QuestionModel {
  final String id;
  final String parent;
  final String content;
  final String title;
  final String type;
  final String answer;
  final String correct;
  final String questionImage;
  final String instruction;
  final String passage;
  final List<Map<String, dynamic>>? options;
  final Map<String, dynamic>? correctAnswer;

  QuestionModel({
    required this.id,
    required this.parent,
    required this.content,
    required this.title,
    required this.type,
    required this.answer,
    required this.correct,
    required this.questionImage,
    required this.instruction,
    required this.passage,
    this.options,
    this.correctAnswer,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    // Handle both old format and new CBT API format
    if (json.containsKey('question_id')) {
      // New CBT API format
      final optionsList = json['options'] as List<dynamic>?;
      
      // Extract question image using same logic as assessment_screen
      String questionImage = _processQuestionImage(json['question_files']);

      // Extract instruction and passage
      String instruction = json['instruction']?.toString() ?? '';
      String passage = json['passage']?.toString() ?? '';

      // Process options with image handling
      List<Map<String, dynamic>>? processedOptions;
      if (optionsList != null && optionsList.isNotEmpty) {
        processedOptions = optionsList.map((opt) {
          final optMap = opt as Map<String, dynamic>;
          
          // Extract option image using same logic as assessment_screen
          String? optionImageUrl = _processOptionImage(optMap['option_files']);
          
          return {
            'text': optMap['text']?.toString() ?? '',
            'imageUrl': optionImageUrl,
            'order': optMap['order']?.toString() ?? '0',
          };
        }).toList();
      }

      return QuestionModel(
        id: json['question_id']?.toString() ?? '',
        parent: json['question_grade']?.toString() ?? '',
        content: json['question_text']?.toString() ?? '',
        title: '',
        type: json['question_type']?.toString() ?? 'multiple_choice',
        answer: json['options'] != null ? jsonEncode(json['options']) : '',
        correct: json['correct']?['order']?.toString() ?? '',
        questionImage: questionImage,
        instruction: instruction,
        passage: passage,
        options: processedOptions,
        correctAnswer: json['correct'] != null ? Map<String, dynamic>.from(json['correct'] as Map) : null,
      );
    } else {
      // Old format
      return QuestionModel(
        id: json['id'] ?? '',
        parent: json['parent'] ?? '',
        content: json['content'] ?? '',
        title: json['title'] ?? '',
        type: json['type'] ?? '',
        answer: json['answer'] ?? '',
        correct: json['correct'] ?? '',
        questionImage: json['question_image'] ?? '',
        instruction: json['instruction'] ?? '',
        passage: json['passage'] ?? '',
        options: null,
        correctAnswer: null,
      );
    }
  }

  List<String> getOptions() {
    try {
      // If we have the new format options, use them
      if (options != null && options!.isNotEmpty) {
        return options!
            .map((option) => option['text']?.toString() ?? '')
            .toList();
      }
      
      // Otherwise try to parse the old format
      final List<dynamic> parsedAnswer = json.decode(answer);
      return parsedAnswer.map((option) => option['text'] as String).toList();
    } catch (e) {
      print('⚠️ Error parsing options: $e');
      return [];
    }
  }

  // Get option with image URL support (new format)
  Map<String, dynamic>? getOptionWithImage(int index) {
    try {
      if (options != null && options!.isNotEmpty && index < options!.length) {
        return options![index];
      }
      return null;
    } catch (e) {
      print('⚠️ Error getting option with image: $e');
      return null;
    }
  }
  
  int? getCorrectAnswerIndex() {
  try {
    int? orderValue;
    
    // Get the order value from correctAnswer or correct field
    if (correctAnswer != null) {
      orderValue = _parseOrderValue(correctAnswer!['order']);
    } else {
      orderValue = int.tryParse(correct);
    }
    
    // If we got a valid order value
    if (orderValue != null) {
      // API sends 1-based (1,2,3,4), convert to 0-based (0,1,2,3)
      final zeroBasedIndex = orderValue - 1;
      
      // Validate that the index is within the options range
      final optionCount = getOptions().length;
      if (zeroBasedIndex >= 0 && zeroBasedIndex < optionCount) {
        return zeroBasedIndex;
      } else {
        print('⚠️ Warning: Correct answer index $zeroBasedIndex out of range (0-${optionCount-1})');
        print('   Original API order value: $orderValue (1-based)');
        
        // Fallback: try to find by text matching
        final correctText = correctAnswer?['text']?.toString();
        if (correctText != null && correctText.isNotEmpty) {
          final options = getOptions();
          for (int i = 0; i < options.length; i++) {
            if (options[i].contains(correctText) || correctText.contains(options[i])) {
              print('   ✅ Found match by text at index $i');
              return i;
            }
          }
        }
      }
    }
    
    return null;
  } catch (e) {
    print('❌ Error in getCorrectAnswerIndex: $e');
    return null;
  }
}

// Also update _parseOrderValue to handle potential string values better
static int? _parseOrderValue(dynamic value) {
  if (value == null) return null;
  
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    // Handle strings like "1", "2", etc.
    final trimmed = value.trim();
    // Also handle if the string has special characters
    final match = RegExp(r'\d+').firstMatch(trimmed);
    if (match != null) {
      return int.parse(match.group(0)!);
    }
  }
  return null;
}

  // Helper method to process question images (matching assessment_screen pattern)
  static String _processQuestionImage(dynamic questionFiles) {
    if (questionFiles is List && questionFiles.isNotEmpty) {
      final file = questionFiles.first;
      if (file is Map) {
        // Try to get file content first
        String? fileContent = file['file']?.toString();
        
        // If file is empty, use file_name instead
        if (fileContent == null || fileContent.isEmpty) {
          fileContent = file['file_name']?.toString();
        }
        
        if (fileContent != null && fileContent.isNotEmpty) {
          // Handle different image formats
          if (fileContent.startsWith('data:')) {
            return fileContent;
          } else if (_isBase64(fileContent)) {
            return 'data:image/jpeg;base64,$fileContent';
          } else {
            // It's a file path - return as is for network loading
            return fileContent;
          }
        }
      }
    }
    return '';
  }

  // Helper method to process option images (matching assessment_screen pattern)
  static String? _processOptionImage(dynamic optionFiles) {
    if (optionFiles is List && optionFiles.isNotEmpty) {
      final optFile = optionFiles.first as Map<String, dynamic>?;
      if (optFile != null) {
        // Try to get file content first
        String? fileContent = optFile['file']?.toString();
        
        // If file is empty, use file_name instead
        if (fileContent == null || fileContent.isEmpty) {
          fileContent = optFile['file_name']?.toString();
        }
        
        if (fileContent != null && fileContent.isNotEmpty) {
          if (fileContent.startsWith('data:')) {
            return fileContent;
          } else if (_isBase64(fileContent)) {
            return 'data:image/jpeg;base64,$fileContent';
          } else {
            // For network images, keep the file path as is
            return fileContent;
          }
        }
      }
    }
    return null;
  }

  // Helper method to check if string is base64 (matching assessment_screen pattern)
  static bool _isBase64(String str) {
    if (str.isEmpty) return false;
    try {
      // Remove any whitespace
      str = str.replaceAll(RegExp(r'\s+'), '');
      // Basic length check (base64 strings are multiples of 4)
      if (str.length % 4 != 0) return false;
      // Try to decode
      base64Decode(str);
      return true;
    } catch (e) {
      return false;
    }
  }
}
