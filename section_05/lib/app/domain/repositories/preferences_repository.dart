abstract class PreferencesRepository {
  bool get isDarkMode;
  Future<void> darkMode(bool enabled);
}
