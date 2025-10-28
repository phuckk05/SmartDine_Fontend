import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/models/user.dart';

class SettingState {
  final bool isLoading;
  final bool isLoggedOut;
  final bool vibrationEnabled;
  final bool darkModeEnabled;
  final User? user;

  SettingState({
    this.isLoading = false,
    this.isLoggedOut = false,
    this.vibrationEnabled = false,
    this.darkModeEnabled = false,
    this.user,
  });

  SettingState copyWith({
    bool? isLoading,
    bool? isLoggedOut,
    bool? vibrationEnabled,
    bool? darkModeEnabled,
    User? user,
  }) {
    return SettingState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedOut: isLoggedOut ?? this.isLoggedOut,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      user: user ?? this.user,
    );
  }
}

class SettingNotifier extends StateNotifier<SettingState> {
  SettingNotifier() : super(SettingState());

  Future<void> fetchUserByEmail(String email) async {
    state = state.copyWith(isLoading: true);
    try {
      final url = Uri.parse(
        'https://smartdine-backend-oq2x.onrender.com/api/users/email/$email',
      );
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final user = User.fromMap(data);
        state = state.copyWith(isLoading: false, user: user);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      print('Fetch user error: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  void toggleVibration(bool value) =>
      state = state.copyWith(vibrationEnabled: value);

  void toggleDarkMode(bool value) =>
      state = state.copyWith(darkModeEnabled: value);

  void logout() => state = state.copyWith(isLoggedOut: true);
}

final settingProvider = StateNotifierProvider<SettingNotifier, SettingState>((
  ref,
) {
  return SettingNotifier();
});
