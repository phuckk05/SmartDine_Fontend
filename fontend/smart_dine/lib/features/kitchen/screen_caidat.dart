import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/features/signin/screen_signin.dart';
import 'package:mart_dine/routes.dart';
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

      final savedUser = await getSavedUser();
      if (savedUser == null) {
        state = state.copyWith(isLoading: false, isLoggedOut: true);
        return;
      }

      // Lấy role
      final rolesRes = await http.get(
        Uri.parse('https://smartdine-backend-oq2x.onrender.com/api/roles/all'),
      );
      final roles = json.decode(rolesRes.body);

      final roleMatch = roles.firstWhere(
        (r) => r['id'] == savedUser.role,
        orElse: () => {'name': 'Unknown'},
      );

      // Gán thông tin user cơ bản
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

      /// GỌI API CHI NHÁNH (mới thêm)
      await fetchCompanyBranch(savedUser.id!);
    } catch (e) {
      state = state.copyWith(isLoading: false, isLoggedOut: false);
    }
  }

  // Lấy user đã lưu từ SharedPreferences
  Future<User?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('user');

    if (jsonString == null) return null;

    final Map<String, dynamic> data = jsonDecode(jsonString);
    print('🔍 [Setting] Retrieved user data: $data');
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

  // Lấy thông tin công ty và chi nhánh
  Future<void> fetchCompanyBranch(int userId) async {
    try {
      final res = await http.get(
        Uri.parse(
          'https://smartdine-backend-oq2x.onrender.com/api/company/company-branch/$userId',
        ),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        state = state.copyWith(
          user: {
            ...?state.user,
            "companyName": data["companyName"],
            "branchName": data["branchName"],
          },
        );
      } else {
        print("Lỗi khi gọi API company-branch: ${res.body}");
      }
    } catch (e) {
      print("Lỗi fetchCompanyBranch: $e");
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
        title: const Text(
          'Cài đặt tài khoản',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body:
          state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Thông tin nhân viên",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),

                    /// THÔNG TIN NGƯỜI SỬ DỤNG THẺ
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          /// Thông tin user
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.user?['fullName'] ?? 'Không có tên',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Mã nhân viên: ${state.user?['id'] ?? ''}",
                                ),
                                Text("Email: ${state.user?['email'] ?? ''}"),
                                Text(
                                  "Cửa hàng: ${state.user?['companyName'] ?? '---'}",
                                ),
                                Text(
                                  "Chi nhánh: ${state.user?['branchName'] ?? '---'}",
                                ),
                              ],
                            ),
                          ),

                          /// Role
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              state.roleName ?? "Không xác định",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),
                    const Text(
                      "Hoạt động & dịch vụ",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),

                    /// DARK MODE SWITCH
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        "Chế độ tối",
                        style: TextStyle(fontSize: 16),
                      ),
                      value: state.darkModeEnabled,
                      onChanged: notifier.toggleDarkMode,
                      secondary: const Icon(Icons.dark_mode),
                    ),

                    const SizedBox(height: 40),

                    /// ĐĂNG XUẤT BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final success = await notifier.logout();

                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Đăng xuất thành công"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            // Chuyển về màn hình đăng nhập hoặc màn hình đầu tiên
                            Routes.pushAndRemoveUntil(context, ScreenSignIn());
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
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text(
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
