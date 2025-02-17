import 'package:flutter/material.dart';
import 'package:linkschool/modules/model/video.dart';
import 'package:linkschool/services/video.dart';
class CourseProvider with ChangeNotifier {
  List<Course> _products = [];
  bool _isLoading = false;

  List<Course> get products => _products;
  bool get isLoading => _isLoading;

  final VideoService _VideoService = VideoService();
  void fetchCourse() async {
    _isLoading = true;
    notifyListeners();
    try{
      _products = await _VideoService.getAllCourse();
    }catch (e) {
      print('Error fetching products: $e');
    }finally{
      _isLoading = false;
      notifyListeners();
    }
  }
}