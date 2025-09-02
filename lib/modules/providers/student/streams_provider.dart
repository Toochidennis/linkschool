
import 'package:flutter/cupertino.dart';
import 'package:linkschool/modules/model/student/streams_model.dart';
import 'package:linkschool/modules/services/student/streams_service.dart';

class StreamsProvider with ChangeNotifier {
  final StreamsService _streamsService;
  List<StreamsModel> streams = [];
  bool isLoading = false;
  String? message;
  String? error;

  int currentPage = 1;
  bool hasNext = true;
  int limit = 10;
  StreamsProvider(this._streamsService);

  Future<Map<String, dynamic>?> fetchStreams(int syllabusid) async {



    isLoading = true;
    error = null;
    message = null;
    notifyListeners();

    try {
      final result = await _streamsService.getStreams(
        syllabusid: syllabusid,
      );

    //  final newstreams = result as List<StreamsModel>;

    //  streams.addAll(newstreams);

      isLoading = false;
      notifyListeners();
      print("Paint ${result}");
      return result;
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
      return null;

    }
  }

}