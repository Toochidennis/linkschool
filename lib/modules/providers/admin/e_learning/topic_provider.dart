import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/e-learning/topic_model.dart';
import 'package:linkschool/modules/services/admin/e_learning/topic_service.dart';

class TopicProvider extends ChangeNotifier {
  final TopicService topicService;
  TopicProvider(this.topicService);

  bool isLoading = false;
  String error = '';

  Future<void> addTopic({
    required int syllabusId,
    required String topic,
    required String creatorName,
    required String objective,
    required int creatorId,
    required List<ClassModel> classes,
  
  
  
  }) async {
    isLoading = true;
    error = '';
    notifyListeners();
    try {
      await topicService.createTopic(
        syllabusId: syllabusId,
        topic: topic,
        creatorName: creatorName,
        objective: objective,
        creatorId: creatorId,
        classes: classes,
       
      );
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }
}