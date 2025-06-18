import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _notificationsEnabled = false;
  String _audioQuality = 'Medium';

  bool get notificationsEnabled => _notificationsEnabled;
  String get audioQuality => _audioQuality;

  SettingsProvider() {
    _loadSettings();
  }

  void toggleNotifications() async {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
  }

  void setAudioQuality(String quality) async {
    _audioQuality = quality;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('audioQuality', quality);
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? false;
    _audioQuality = prefs.getString('audioQuality') ?? 'Medium';
    notifyListeners();
  }
}