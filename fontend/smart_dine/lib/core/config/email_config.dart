class EmailConfig {
  static const String smtpHost = 'smtp.gmail.com';
  static const int smtpPort = 587;
  static const String username = 'smart_dine';
  static const String password = 'itsx kmsl iwkd unyo';
  static const bool useTls = true;
  static const bool ignoreBadCertificate = false;
  static const String fromName = 'Smart Dine';

  static bool get isConfigured =>
      smtpHost.isNotEmpty && username.isNotEmpty && password.isNotEmpty;
}
