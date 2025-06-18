import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontSizeProvider with ChangeNotifier {
  String _fontSize = 'Medium';
  double _fontScale = 1.0;

  String get fontSize => _fontSize;
  double get fontScale => _fontScale;

  FontSizeProvider() {
    _loadFontSize();
  }

  void setFontSize(String size) async {
    _fontSize = size;
    switch (size) {
      case 'Small':
        _fontScale = 0.8;
        break;
      case 'Medium':
        _fontScale = 1.0;
        break;
      case 'Large':
        _fontScale = 1.2;
        break;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fontSize', size);
  }

  void _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    final size = prefs.getString('fontSize') ?? 'Medium';
    setFontSize(size);
  }
}