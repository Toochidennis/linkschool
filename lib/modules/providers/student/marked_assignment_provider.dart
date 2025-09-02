
import 'package:flutter/cupertino.dart';
import 'package:linkschool/modules/model/student/streams_model.dart';
import 'package:linkschool/modules/model/student/submitted_assignment_model.dart';
import 'package:linkschool/modules/services/student/marked_assignment_service.dart';
import 'package:linkschool/modules/services/student/streams_service.dart';

class MarkedAssignmentProvider with ChangeNotifier {
  final MarkedAssignmentService _markedAssignmentService;
  List<StreamsModel> streams = [];
  bool isLoading = false;
  String? message;
  String? error;

  int currentPage = 1;
  bool hasNext = true;
  int limit = 10;
  MarkedAssignmentProvider(this._markedAssignmentService);

  Future<MarkedAssignmentModel?> fetchMarkedAssignment(int contentid, int year, int term) async {



    isLoading = true;
    error = null;
    message = null;
    notifyListeners();

    try {
      final result = await _markedAssignmentService.getMarkedAssignment(
        term: term,
        contentid: contentid,
        year: year,
      );

print ("Quest ${result}");
      isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
      return null;

    }
  }

}