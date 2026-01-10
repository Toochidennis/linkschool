import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/explore/study/topic_model.dart';

import 'package:linkschool/modules/services/explore/subject_topic_sevice.dart';

class SubjectTopicsProvider extends ChangeNotifier {
  final SubjectTopicsService _service;

  SyllabusResponse? topicsData;
  bool loading = false;
  String? error;

  SubjectTopicsProvider(this._service);

  Future<void> loadTopics({
    required int courseId,
    required int examTypeId,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      topicsData = await _service.fetchTopics(
        courseId: courseId,
        examTypeId: examTypeId,
      );
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }
}
