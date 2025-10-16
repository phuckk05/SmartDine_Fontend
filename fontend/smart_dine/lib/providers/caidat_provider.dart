import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/user.dart';
import '../models/caidat_models.dart';

/// Provider cho Settings (Notification, Sound, Dark Mode)
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsModel>(
  (ref) => SettingsNotifier(),
);

/// Notifier cho Settings
class SettingsNotifier extends StateNotifier<SettingsModel> {
  SettingsNotifier() : super(SettingsModel.defaultSettings()) {
    _loadSettings();
  }

  // Load settings từ SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('app_settings');
      if (jsonString != null) {
        final json = jsonDecode(jsonString);
        state = SettingsModel.fromJson(json);
      }
    } catch (e) {
      print('Error loading settings: $e');
      // Nếu có lỗi, dùng default settings
      state = SettingsModel.defaultSettings();
    }
  }

  // Save settings vào SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(state.toJson());
      await prefs.setString('app_settings', jsonString);
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  // Toggle notification
  void toggleNotification(bool value) {
    state = state.copyWith(notificationEnabled: value);
    _saveSettings();
  }

  // Toggle sound
  void toggleSound(bool value) {
    state = state.copyWith(soundEnabled: value);
    _saveSettings();
  }

  // Toggle dark mode
  void toggleDarkMode(bool value) {
    state = state.copyWith(darkModeEnabled: value);
    _saveSettings();
  }

  // Reset settings về mặc định
  void resetToDefault() {
    state = SettingsModel.defaultSettings();
    _saveSettings();
  }
}

// ==================== USER PROVIDER ====================

/// Provider cho Current User (User đang đăng nhập)
final currentUserProvider = StateProvider<User?>((ref) {
  // Khởi tạo null, sẽ load khi app start hoặc sau khi login
  return null;
});

/// Provider để load user từ SharedPreferences
final loadUserProvider = FutureProvider<User?>((ref) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');

    if (userJson != null && userJson.isNotEmpty) {
      final user = User.fromJson(userJson);
      // Update currentUserProvider
      ref.read(currentUserProvider.notifier).state = user;
      return user;
    }
  } catch (e) {
    print('Error loading user: $e');
  }
  return null;
});

/// Provider để lấy role name từ statusId
final userRoleProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 'Chưa đăng nhập';

  // Map statusId sang role name
  // Điều chỉnh theo logic của bạn
  switch (user.statusId) {
    case 1:
      return 'Bếp';
    case 2:
      return 'Phục vụ';
    case 3:
      return 'Thu ngân';
    case 4:
      return 'Quản lý';
    case 5:
      return 'Admin';
    default:
      return 'Nhân viên';
  }
});

/// Provider kiểm tra user đã đăng nhập chưa
final isLoggedInProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

// ==================== AUTH FUNCTIONS ====================

/// Provider cho login function
final loginProvider = Provider<Future<bool> Function(User)>((ref) {
  return (User user) async {
    try {
      // Lưu user vào provider
      ref.read(currentUserProvider.notifier).state = user;

      // Lưu user vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', user.toJson());
      await prefs.setInt('user_id', user.id ?? 0);

      return true;
    } catch (e) {
      print('Error during login: $e');
      return false;
    }
  };
});

/// Provider cho logout function
final logoutProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    try {
      // Clear user data
      ref.read(currentUserProvider.notifier).state = null;

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user');
      await prefs.remove('user_id');

      // Reset settings về default (optional)
      // ref.read(settingsProvider.notifier).resetToDefault();

      print('Logout successful');
    } catch (e) {
      print('Error during logout: $e');
    }
  };
});

/// Provider cho update user function
final updateUserProvider = Provider<Future<bool> Function(User)>((ref) {
  return (User updatedUser) async {
    try {
      // Update provider
      ref.read(currentUserProvider.notifier).state = updatedUser;

      // Update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', updatedUser.toJson());

      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  };
});

// ==================== HELPER PROVIDERS ====================

/// Provider lấy user ID
final userIdProvider = Provider<int?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.id;
});

/// Provider lấy user fullName
final userFullNameProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.fullName ?? 'Guest';
});

/// Provider lấy user email
final userEmailProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.email ?? '';
});

/// Provider kiểm tra user có quyền quản lý không
final isManagerProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  // statusId = 4 hoặc 5 là quản lý/admin
  return user?.statusId == 4 || user?.statusId == 5;
});

/// Provider kiểm tra user có quyền admin không
final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.statusId == 5;
});
