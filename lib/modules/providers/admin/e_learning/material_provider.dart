import 'package:flutter/material.dart';
import 'package:linkschool/modules/services/admin/e_learning/material_service.dart';

class MaterialProvider extends ChangeNotifier {
  final MaterialService _materialService;
  bool isLoading = false;
  String? error;
  MaterialProvider(this._materialService);

  Future<void> addMaterial(Map<String, dynamic> material) async {
    isLoading = true;
    error = null; 
    notifyListeners();
    try {
      await _materialService.AddMaterial(material);
    } catch (e) {
      print('Error adding material: $e');
      rethrow;
    }
    isLoading = false;
    notifyListeners();
  }
  Future<void> UpDateMaterial(Map<String, dynamic> material ,int id) async {
    isLoading = true;
    error = null; 
    notifyListeners();
    try {
      await _materialService.UpDateMaterial(material,id);
    } catch (e) {
      print('Error adding material: $e');
      rethrow;
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteMaterial(int id) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _materialService.deleteMaterial(id);
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  
}
