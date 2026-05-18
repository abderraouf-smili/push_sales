enum AppEnvironment {
  demo,
  vpn,
  real,
  emulator,
  production;

  static AppEnvironment fromName(String value) {
    switch (value.trim().toLowerCase()) {
      case 'demo':
      case 'local_demo':
        return AppEnvironment.demo;
      case 'emulator':
        return AppEnvironment.emulator;
      case 'real':
      case 'reel':
        return AppEnvironment.real;
      case 'production':
      case 'prod':
        return AppEnvironment.production;
      case 'vpn':
      default:
        return AppEnvironment.vpn;
    }
  }
}
