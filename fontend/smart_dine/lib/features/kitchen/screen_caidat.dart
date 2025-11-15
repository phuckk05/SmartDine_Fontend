import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/features/signin/screen_signin.dart';
import 'package:mart_dine/services/auth_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user.dart';

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
  final AuthService _authService = AuthService();

  SettingNotifier() : super(SettingState());
  // Lấy dữ liệu user và role từ API
  Future<void> fetchUserData() async {
    try {
      state = state.copyWith(isLoading: true);

      // Lấy user từ SharedPreferences
      final savedUser = await getSavedUser();

      if (savedUser == null) {
        print('Không tìm thấy user trong SharedPreferences');
        state = state.copyWith(
          isLoading: false,
          isLoggedOut: true,
        ); // nếu muốn logout
        return;
      }

      // Gọi API lấy danh sách roles
      final rolesRes = await http.get(
        Uri.parse('https://smartdine-backend-oq2x.onrender.com/api/roles/all'),
      );

      final List<dynamic> roles = json.decode(rolesRes.body);

      // Tìm roleName tương ứng từ roleId của user
      final roleMatch = roles.firstWhere(
        (r) => r['id'] == savedUser.role,
        orElse: () => {'name': 'Unknown'},
      );

      // Cập nhật state
      state = state.copyWith(
        user: {
          "id": savedUser.id,
          "fullName": savedUser.fullName,
          "email": savedUser.email,
          "phone": savedUser.phone,
          "fontImage": savedUser.fontImage,
          "backImage": savedUser.backImage,
          "statusId": savedUser.statusId,
          "role": savedUser.role,
          "companyId": savedUser.companyId,
          "createdAt": savedUser.createdAt,
        },
        roleName: roleMatch['name'],
        isLoading: false,
        isLoggedOut: false,
      );
    } catch (e) {
      print('Lỗi khi fetch dữ liệu: $e');
      state = state.copyWith(isLoading: false, isLoggedOut: false);
    }
  }

  // Lấy user đã lưu từ SharedPreferences
  Future<User?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('user');

    if (jsonString == null) return null;

    final Map<String, dynamic> data = jsonDecode(jsonString);
    return User.fromMap(data);
  }

  // Đăng xuất
  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      if (token != null) {
        await _authService.logout(token); // nếu lỗi nhảy xuống catch
      }

      await prefs.remove("token");
      await prefs.remove("user");

      return true;
    } catch (e) {
      return false;
    }
  }

  void toggleVibration(bool value) =>
      state = state.copyWith(vibrationEnabled: value);

  void toggleDarkMode(bool value) =>
      state = state.copyWith(darkModeEnabled: value);
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
      ref.read(settingProvider.notifier).fetchUserData(); // Gọi API
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingProvider);
    final notifier = ref.read(settingProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
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
                      title: const Text('Chế độ tối'),
                      value: state.darkModeEnabled,
                      onChanged: notifier.toggleDarkMode,
                    ),

                    const Spacer(),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final success = await notifier.logout();

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Đăng xuất thành công"),
                                duration: Duration(seconds: 2),
                              ),
                            );

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ScreenSignIn(),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Đăng xuất thất bại, vui lòng thử lại.",
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },

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
