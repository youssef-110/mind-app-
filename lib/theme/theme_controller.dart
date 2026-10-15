import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  Color seedColor = const Color(0xFF6C63FF);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt('seedColor');
    if (value != null) seedColor = Color(value);
    notifyListeners();
  }

  Future<void> update(Color color) async {
    seedColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('seedColor', color.value);
    notifyListeners();
  }
}
