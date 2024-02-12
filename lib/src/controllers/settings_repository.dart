abstract class SettingsRepository {
  bool get isDarkMode;
  Future<void> updateDarkMode(bool isDark);
}
