import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/providers/setting_provider.dart';

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
      ref.read(settingProvider.notifier).fetchChef(4);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingProvider);
    final notifier = ref.read(settingProvider.notifier);

    // Xử lý điều hướng khi logout
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

                    /// Thông tin Chef
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// Bên trái: Thông tin cá nhân
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.chef?.name ?? 'Không có tên',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('ID: ${state.chef?.id ?? ''}'),
                              const SizedBox(height: 4),
                              Text(state.chef?.email ?? ''),
                            ],
                          ),

                          /// Bên phải: vai trò (label cố định)
                          const Text(
                            'Bếp trưởng',
                            style: TextStyle(fontWeight: FontWeight.w600),
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

                    /// Cài đặt ứng dụng
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

                    /// Nút đăng xuất
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
