class SettingsModel {
  final bool soundEnabled;
  final bool darkModeEnabled;
  final String language;
  final bool autoRefresh;
  final int refreshInterval; // seconds

  const SettingsModel({
    this.soundEnabled = true,
    this.darkModeEnabled = false,
    this.language = 'vi',
    this.autoRefresh = true,
    this.refreshInterval = 30,
  });

  SettingsModel copyWith({
    bool? soundEnabled,
    bool? darkModeEnabled,
    String? language,
    bool? autoRefresh,
    int? refreshInterval,
  }) {
    return SettingsModel(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      language: language ?? this.language,
      autoRefresh: autoRefresh ?? this.autoRefresh,
      refreshInterval: refreshInterval ?? this.refreshInterval,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'soundEnabled': soundEnabled,
      'darkModeEnabled': darkModeEnabled,
      'language': language,
      'autoRefresh': autoRefresh,
      'refreshInterval': refreshInterval,
    };
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      darkModeEnabled: json['darkModeEnabled'] as bool? ?? false,
      language: json['language'] as String? ?? 'vi',
      autoRefresh: json['autoRefresh'] as bool? ?? true,
      refreshInterval: json['refreshInterval'] as int? ?? 30,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettingsModel &&
        other.soundEnabled == soundEnabled &&
        other.darkModeEnabled == darkModeEnabled &&
        other.language == language &&
        other.autoRefresh == autoRefresh &&
        other.refreshInterval == refreshInterval;
  }

  @override
  int get hashCode {
    return soundEnabled.hashCode ^
        darkModeEnabled.hashCode ^
        language.hashCode ^
        autoRefresh.hashCode ^
        refreshInterval.hashCode;
  }

  @override
  String toString() {
    return 'SettingsModel(sound: $soundEnabled, darkMode: $darkModeEnabled, language: $language)';
  }
}
