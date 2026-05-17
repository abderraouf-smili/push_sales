enum AppEnvironment {
  vpn,
  emulator,
  production;

  static AppEnvironment fromName(String value) {
    switch (value.trim().toLowerCase()) {
      case 'emulator':
        return AppEnvironment.emulator;
      case 'production':
      case 'prod':
        return AppEnvironment.production;
      case 'vpn':
      default:
        return AppEnvironment.vpn;
    }
  }
}
