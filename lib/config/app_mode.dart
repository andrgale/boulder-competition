enum AppMode {
  athlete,
  admin,
}

class AppConfig {
  static late AppMode mode;
  static late bool mostraCampo;

  static bool get isAthlete =>
      mode == AppMode.athlete;

  static bool get isAdmin =>
      mode == AppMode.admin;
}