enum AppFlavor {
  barber,
  client,
}

class AppConfig {
  static AppFlavor? _flavor;

  static void setFlavor(AppFlavor flavor) {
    _flavor = flavor;
  }

  static AppFlavor get flavor {
    if (_flavor == null) {
      throw Exception('AppFlavor not initialized!');
    }
    return _flavor!;
  }

  static bool get isBarber => _flavor == AppFlavor.barber;
  static bool get isClient => _flavor == AppFlavor.client;
}
