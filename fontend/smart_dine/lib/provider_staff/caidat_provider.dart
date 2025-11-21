// /import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/user.dart';
// import '../models/user_profile_model.dart';
// import '../models/settings_data.dart'; //dữ liệu cài đặt mặc định

// final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsModel>(
//   (ref) {
//     return SettingsNotifier();
//   },
// );

// class SettingsNotifier extends StateNotifier<SettingsModel> {
//   SettingsNotifier() : super(SettingsMockData.getDefaultSettings()) {
//     print('⚙️ [SettingsProvider] Initialized with default settings');
//   }

//   /// Toggle âm thanh
//   void toggleSound(bool enabled) {
//     state = state.copyWith(soundEnabled: enabled);
//     print('⚙️ [SettingsProvider] Sound: $enabled');
//   }

//   /// Toggle dark mode
//   void toggleDarkMode(bool enabled) {
//     state = state.copyWith(darkModeEnabled: enabled);
//     print('⚙️ [SettingsProvider] Dark mode: $enabled');
//   }

//   /// Thay đổi ngôn ngữ
//   void changeLanguage(String language) {
//     state = state.copyWith(language: language);
//     print('⚙️ [SettingsProvider] Language: $language');
//   }

//   /// Toggle auto refresh
//   void toggleAutoRefresh(bool enabled) {
//     state = state.copyWith(autoRefresh: enabled);
//     print('⚙️ [SettingsProvider] Auto refresh: $enabled');
//   }

//   /// Thay đổi refresh interval
//   void changeRefreshInterval(int seconds) {
//     state = state.copyWith(refreshInterval: seconds);
//     print('⚙️ [SettingsProvider] Refresh interval: $seconds seconds');
//   }

//   /// Reset về mặc định
//   void resetToDefault() {
//     state = SettingsMockData.getDefaultSettings();
//     print('⚙️ [SettingsProvider] Reset to default');
//   }
// }

// // ==================== USER PROFILE PROVIDER ====================

// final currentUserProfileProvider = Provider<UserProfile>((ref) {
//   // Lấy user profile hiện tại từ mock data
//   return SettingsMockData.getCurrentUserProfile();
// });

// // ==================== LOGOUT PROVIDER ====================

// final logoutProvider = Provider<Future<void> Function()>((ref) {
//   return () async {
//     print('🚪 [LogoutProvider] Logging out...');
//     await Future.delayed(const Duration(milliseconds: 500));

//     // Reset settings
//     ref.read(settingsProvider.notifier).resetToDefault();

//     print('🚪 [LogoutProvider] Logout completed');
//   };
// });

// // ==================== HELPER PROVIDERS ====================

// /// Provider để check dark mode
// final isDarkModeProvider = Provider<bool>((ref) {
//   final settings = ref.watch(settingsProvider);
//   return settings.darkModeEnabled;
// });

// /// Provider để check sound
// final isSoundEnabledProvider = Provider<bool>((ref) {
//   final settings = ref.watch(settingsProvider);
//   return settings.soundEnabled;
// });

// /// Provider để lấy language
// final currentLanguageProvider = Provider<String>((ref) {
//   final settings = ref.watch(settingsProvider);
//   return settings.language;
// /});
