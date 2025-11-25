import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/core/constrats.dart' show ShadowCus, kTextColorLight, kTextColorDark;
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/widgets_owner/appbar.dart';

// Đặt mặc định là true để khớp ảnh
final _darkModeProvider = StateProvider<bool>((ref) => true); 

class ScreenSettings extends ConsumerStatefulWidget {
  const ScreenSettings({super.key});

  @override
  ConsumerState<ScreenSettings> createState() => _ScreenSettingsState();
}

class _ScreenSettingsState extends ConsumerState<ScreenSettings> {
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(_darkModeProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarCus(title: 'Cài đặt'), 
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: Style.paddingPhone, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SỬA MÀU: Label màu xám
            const Text('Tài khoản', style: TextStyle(fontWeight: FontWeight.bold, color: kTextColorLight)), 
            const SizedBox(height: 10),
            _buildSettingItem(
              icon: Icons.person_outline,
              title: 'Thông tin tài khoản',
              onTap: () {},
            ),
            
            const SizedBox(height: 25),
            // SỬA MÀU: Label màu xám
            const Text('Nội dung và hoạt động', style: TextStyle(fontWeight: FontWeight.bold, color: kTextColorLight)),
            const SizedBox(height: 10),
            _buildDarkModeSwitch(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({required IconData icon, required String title, required VoidCallback onTap}) {
    // SỬA BỐ CỤC: Bỏ ShadowCus nếu bạn muốn nó là một hàng dài không có shadow bao quanh
    // Nếu bạn muốn giữ ShadowCus (như các màn hình khác), thì giữ nguyên.
    return ShadowCus(
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, size: 24, color: kTextColorDark),
            const SizedBox(width: 15),
            Text(title, style: const TextStyle(fontSize: 16, color: kTextColorDark)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: kTextColorLight),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkModeSwitch(bool isDarkMode) {
    return ShadowCus(
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.mode_night_outlined, size: 24, color: kTextColorDark),
              const SizedBox(width: 15),
              const Text('Chế độ tối', style: TextStyle(fontSize: 16, color: kTextColorDark)),
            ],
          ),
          Switch(
            value: isDarkMode,
            onChanged: (value) {
              ref.read(_darkModeProvider.notifier).state = value;
            },
            // SỬA MÀU: Switch màu xanh khi active
            activeColor: Colors.blue, 
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}