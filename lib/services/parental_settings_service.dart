import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParentalSettingsService extends ChangeNotifier {
  final SharedPreferences _prefs;

  static const String _codeKey = 'parental_code';
  static const String _defaultCode = '1234';

  String _currentCode = _defaultCode;

  ParentalSettingsService(this._prefs) {
    _loadSettings();
  }

  String get currentCode => _currentCode;

  void _loadSettings() {
    _currentCode = _prefs.getString(_codeKey) ?? _defaultCode;
    notifyListeners();
  }

  Future<void> updateCode(String newCode) async {
    _currentCode = newCode;
    await _prefs.setString(_codeKey, newCode);
    notifyListeners();
  }

  bool verifyCode(String code) {
    return code == _currentCode;
  }
}
