import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/chef_api.dart';
import '../models/chef.dart';

class SettingState {
  final Chef? chef;
  final bool isLoading;
  final bool vibrationEnabled;
  final bool darkModeEnabled;
  final bool isLoggedOut;

  const SettingState({
    this.chef,
    this.isLoading = false,
    this.vibrationEnabled = false,
    this.darkModeEnabled = false,
    this.isLoggedOut = false,
  });

  SettingState copyWith({
    Chef? chef,
    bool? isLoading,
    bool? vibrationEnabled,
    bool? darkModeEnabled,
    bool? isLoggedOut,
  }) {
    return SettingState(
      chef: chef ?? this.chef,
      isLoading: isLoading ?? this.isLoading,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      isLoggedOut: isLoggedOut ?? this.isLoggedOut,
    );
  }
}

class SettingNotifier extends StateNotifier<SettingState> {
  final Ref ref;

  SettingNotifier(this.ref) : super(const SettingState()) {
    _loadPreferences(); // Tự động tải cài đặt khi khởi tạo
  }

  Future<void> fetchChef(int id) async {
    state = state.copyWith(isLoading: true);

    try {
      final api = ref.read(chefApiProvider);
      final chef = await api.getById(id);

      if (chef != null) {
        state = state.copyWith(chef: chef, isLoading: false);
      } else {
        print("⚠️ Không tìm thấy thông tin Chef với id: $id");
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      print("❌ Lỗi khi lấy thông tin Chef: $e");
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> toggleVibration(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('vibrationEnabled', value);
      state = state.copyWith(vibrationEnabled: value);
    } catch (e) {
      print("❌ Lỗi khi lưu chế độ rung: $e");
    }
  }

  Future<void> toggleDarkMode(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('darkModeEnabled', value);
      state = state.copyWith(darkModeEnabled: value);
    } catch (e) {
      print("❌ Lỗi khi lưu chế độ tối: $e");
    }
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vibration = prefs.getBool('vibrationEnabled') ?? false;
      final darkMode = prefs.getBool('darkModeEnabled') ?? false;

      state = state.copyWith(
        vibrationEnabled: vibration,
        darkModeEnabled: darkMode,
      );
    } catch (e) {
      print("❌ Lỗi khi tải SharedPreferences: $e");
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Xoá toàn bộ dữ liệu
      state = state.copyWith(isLoggedOut: true);
    } catch (e) {
      print("❌ Lỗi khi đăng xuất: $e");
    }
  }
}

final settingProvider = StateNotifierProvider<SettingNotifier, SettingState>((
  ref,
) {
  return SettingNotifier(ref);
});
