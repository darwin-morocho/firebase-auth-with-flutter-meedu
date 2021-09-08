import 'package:flutter_firebase_auth/app/domain/repositories/preferences_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

const darkModeKey = 'dark-mode';

class PreferencesRepositoryImpl implements PreferencesRepository {
  final SharedPreferences _preferences;
  PreferencesRepositoryImpl(this._preferences);

  @override
  bool get isDarkMode => _preferences.getBool(darkModeKey) ?? false;

  @override
  Future<void> darkMode(bool enabled) {
    return _preferences.setBool(darkModeKey, enabled);
  }
}
