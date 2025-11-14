import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final settingProvider = StateNotifierProvider<SettingNotifier, SettingState>(
  (ref) => SettingNotifier(),
);

class SettingState {
  final bool isLoading;
  final bool isLoggedOut;
  final Map<String, dynamic>? user;
  final String? roleName;
  final bool vibrationEnabled;
  final bool darkModeEnabled;

  SettingState({
    this.isLoading = false,
    this.isLoggedOut = false,
    this.user,
    this.roleName,
    this.vibrationEnabled = true,
    this.darkModeEnabled = false,
  });

  SettingState copyWith({
    bool? isLoading,
    bool? isLoggedOut,
    Map<String, dynamic>? user,
    String? roleName,
    bool? vibrationEnabled,
    bool? darkModeEnabled,
  }) {
    return SettingState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedOut: isLoggedOut ?? this.isLoggedOut,
      user: user ?? this.user,
      roleName: roleName ?? this.roleName,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
    );
  }
}

class SettingNotifier extends StateNotifier<SettingState> {
  SettingNotifier() : super(SettingState());

  Future<void> fetchUserData(String email) async {
    try {
      state = state.copyWith(isLoading: true);

      final userRes = await http.get(
        Uri.parse(
          'https://smartdine-backend-oq2x.onrender.com/api/users/email/$email',
        ),
      );
      final userData = json.decode(userRes.body);

      // Gọi API roles để lấy tên vai trò
      final rolesRes = await http.get(
        Uri.parse('https://smartdine-backend-oq2x.onrender.com/api/roles/all'),
      );
      final List<dynamic> roles = json.decode(rolesRes.body);

      final roleMatch = roles.firstWhere(
        (r) => r['id'] == userData['role'],
        orElse: () => {'name': 'Unknown'},
      );

      state = state.copyWith(
        user: userData,
        roleName: roleMatch['name'],
        isLoading: false,
      );
    } catch (e) {
      print('Lỗi khi fetch dữ liệu: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  void toggleVibration(bool value) =>
      state = state.copyWith(vibrationEnabled: value);

  void toggleDarkMode(bool value) =>
      state = state.copyWith(darkModeEnabled: value);

  void logout() {
    state = state.copyWith(isLoggedOut: true);
  }
}

class ScreenSetting extends ConsumerStatefulWidget {
  const ScreenSetting({super.key});

  @override
  ConsumerState<ScreenSetting> createState() => _ScreenSettingState();
}

class _ScreenSettingState extends ConsumerState<ScreenSetting> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(settingProvider.notifier)
          .fetchUserData('hadl@gmail.com'); // Gọi API
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingProvider);
    final notifier = ref.read(settingProvider.notifier);

    if (state.isLoggedOut) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:
            state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông tin nhân viên',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// Bên trái: Thông tin user
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.user?['fullName'] ?? 'Không có tên',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('ID: ${state.user?['id'] ?? ''}'),
                              const SizedBox(height: 4),
                              Text(state.user?['email'] ?? ''),
                            ],
                          ),

                          /// Bên phải: Vai trò
                          Text(
                            state.roleName ?? 'Không xác định',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      'Hoạt động & dịch vụ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    SwitchListTile(
                      title: const Text('Rung khi có món mới'),
                      value: state.vibrationEnabled,
                      onChanged: notifier.toggleVibration,
                    ),
                    SwitchListTile(
                      title: const Text('Chế độ tối'),
                      value: state.darkModeEnabled,
                      onChanged: notifier.toggleDarkMode,
                    ),

                    const Spacer(),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: notifier.logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Đăng xuất',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
