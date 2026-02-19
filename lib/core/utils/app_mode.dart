enum AppMode { normal, readOnly }

class AppConfig {
  static AppMode mode = AppMode.normal;

  static bool get isReadOnly => mode == AppMode.readOnly;

  static void toggleMode() {
    mode = mode == AppMode.normal ? AppMode.readOnly : AppMode.normal;
  }
}
