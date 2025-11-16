import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// PROVIDER
final settingProvider = StateNotifierProvider<SettingNotifier, SettingState>(
  (ref) => SettingNotifier(),
);

/// STATE
class SettingState {
  final bool isLoading;
  final Map<String, dynamic>? user;
  final String? roleName;
  final bool vibration;
  final bool darkMode;

  const SettingState({
    this.isLoading = false,
    this.user,
    this.roleName,
    this.vibration = true,
    this.darkMode = false,
  });

  SettingState copyWith({
    bool? isLoading,
    Map<String, dynamic>? user,
    String? roleName,
    bool? vibration,
    bool? darkMode,
  }) {
    return SettingState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      roleName: roleName ?? this.roleName,
      vibration: vibration ?? this.vibration,
      darkMode: darkMode ?? this.darkMode,
    );
  }
}

/// CONTROLLER
class SettingNotifier extends StateNotifier<SettingState> {
  SettingNotifier() : super(const SettingState());

  Future<void> loadUser(String email) async {
    state = state.copyWith(isLoading: true);

    try {
      final userRes = await http.get(
        Uri.parse(
          'https://smartdine-backend-oq2x.onrender.com/api/users/email/$email',
        ),
      );
      final user = json.decode(userRes.body);

      final roleRes = await http.get(
        Uri.parse('https://smartdine-backend-oq2x.onrender.com/api/roles/all'),
      );
      final roles = json.decode(roleRes.body) as List;

      final roleName =
          roles.firstWhere(
            (r) => r['id'] == user['role'],
            orElse: () => {'name': 'Unknown'},
          )['name'];

      state = state.copyWith(user: user, roleName: roleName, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void setVibration(bool value) {
    state = state.copyWith(vibration: value);
  }

  void setDarkMode(bool value) {
    state = state.copyWith(darkMode: value);
  }
}

/// UI – SCREEN
class ScreenSettingDashboard extends ConsumerStatefulWidget {
  const ScreenSettingDashboard({super.key});

  @override
  ConsumerState<ScreenSettingDashboard> createState() =>
      _ScreenSettingDashboardState();
}

class _ScreenSettingDashboardState
    extends ConsumerState<ScreenSettingDashboard> {
  @override
  void initState() {
    super.initState();

    /// Load user khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingProvider.notifier).loadUser("hadl@gmail.com");
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingProvider);
    final notifier = ref.read(settingProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text("Cài đặt Dashboard")),
      body:
          state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Thông tin admin",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    /// CARD USER
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// LEFT INFO
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.user?['fullName'] ?? "Tên nhân viên",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text("ID: ${state.user?['id'] ?? ''}"),
                              const SizedBox(height: 4),
                              Text(state.user?['email'] ?? ''),
                            ],
                          ),

                          /// ROLE
                          Text(
                            state.roleName ?? "Vai trò",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),

                    /// LOGOUT BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text("Đăng xuất"),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
