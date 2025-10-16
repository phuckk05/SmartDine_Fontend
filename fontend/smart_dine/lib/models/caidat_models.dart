class SettingsModel {
  final bool notificationEnabled;
  final bool soundEnabled;
  final bool darkModeEnabled;

  SettingsModel({
    required this.notificationEnabled,
    required this.soundEnabled,
    required this.darkModeEnabled,
  });

  // Default settings
  factory SettingsModel.defaultSettings() {
    return SettingsModel(
      notificationEnabled: true,
      soundEnabled: true,
      darkModeEnabled: false,
    );
  }

  // Copy with method
  SettingsModel copyWith({
    bool? notificationEnabled,
    bool? soundEnabled,
    bool? darkModeEnabled,
  }) {
    return SettingsModel(
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'notificationEnabled': notificationEnabled,
      'soundEnabled': soundEnabled,
      'darkModeEnabled': darkModeEnabled,
    };
  }

  // From JSON
  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      notificationEnabled: json['notificationEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      darkModeEnabled: json['darkModeEnabled'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'SettingsModel(notificationEnabled: $notificationEnabled, soundEnabled: $soundEnabled, darkModeEnabled: $darkModeEnabled)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SettingsModel &&
        other.notificationEnabled == notificationEnabled &&
        other.soundEnabled == soundEnabled &&
        other.darkModeEnabled == darkModeEnabled;
  }

  @override
  int get hashCode {
    return notificationEnabled.hashCode ^
        soundEnabled.hashCode ^
        darkModeEnabled.hashCode;
  }
}
