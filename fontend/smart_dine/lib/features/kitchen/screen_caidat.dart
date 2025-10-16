import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/providers/caidat_provider.dart';
import '../../../core/style.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lấy state từ providers
    final settings = ref.watch(settingsProvider);

    // Dữ liệu cứng để test UI
    final userInfo = {
      'name': 'Nguyễn Đình Phúc',
      'id': '234234235253325',
      'email': 'phuckk3423@gmail.com',
      'role': 'Bếp',
    };

    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;

    return Scaffold(
      backgroundColor: Style.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Text(
          'Cài đặt',
          style: Style.fontTitle.copyWith(
            color: Style.textColorWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Thông tin tài khoản
            _buildSection(
              title: 'Tài khoản',
              isWeb: isWeb,
              children: [_buildProfileCard(userInfo, isWeb)],
            ),

            const SizedBox(height: 20),

            // Cài đặt thông báo
            _buildSection(
              title: 'Thông báo',
              isWeb: isWeb,
              children: [
                _buildSwitchTile(
                  ref: ref,
                  icon: Icons.notifications,
                  title: 'Thông báo đẩy',
                  subtitle: 'Nhận thông báo về đơn hàng mới',
                  value: settings.notificationEnabled,
                  onChanged: (value) {
                    ref
                        .read(settingsProvider.notifier)
                        .toggleNotification(value);
                  },
                  isWeb: isWeb,
                ),
                _buildSwitchTile(
                  ref: ref,
                  icon: Icons.volume_up,
                  title: 'Âm thanh',
                  subtitle: 'Phát âm thanh khi có đơn mới',
                  value: settings.soundEnabled,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).toggleSound(value);
                  },
                  isWeb: isWeb,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Giao diện
            _buildSection(
              title: 'Giao diện',
              isWeb: isWeb,
              children: [
                _buildSwitchTile(
                  ref: ref,
                  icon: Icons.dark_mode,
                  title: 'Chế độ tối',
                  subtitle: 'Giao diện tối cho mắt',
                  value: settings.darkModeEnabled,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).toggleDarkMode(value);
                  },
                  isWeb: isWeb,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Hệ thống
            _buildSection(
              title: 'Hệ thống',
              isWeb: isWeb,
              children: [
                _buildListTile(
                  context: context,
                  ref: ref,
                  icon: Icons.logout,
                  title: 'Đăng xuất',
                  subtitle: 'Thoát khỏi tài khoản',
                  onTap: () => _showLogoutDialog(context, ref),
                  isWeb: isWeb,
                  textColor: Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ==================== WIDGETS ====================

  // Build section
  Widget _buildSection({
    required String title,
    required List<Widget> children,
    required bool isWeb,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWeb ? 20 : Style.paddingPhone,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: Style.spacingSmall),
            child: Text(
              title,
              style: Style.fontTitleSuperMini.copyWith(
                fontSize: isWeb ? 16 : 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Style.colorLight,
              borderRadius: BorderRadius.circular(Style.cardBorderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: Style.shadowBlurRadius,
                  offset: Offset(Style.shadowOffsetX, Style.shadowOffsetY),
                ),
              ],
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  // Profile card
  Widget _buildProfileCard(Map<String, String> userInfo, bool isWeb) {
    return Padding(
      padding: EdgeInsets.all(isWeb ? 20 : Style.paddingPhone),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userInfo['name']!,
                  style: Style.fontTitleMini.copyWith(
                    fontSize: isWeb ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  userInfo['id']!,
                  style: Style.fontCaption.copyWith(fontSize: isWeb ? 14 : 13),
                ),
                const SizedBox(height: 4),
                Text(
                  userInfo['email']!,
                  style: Style.fontCaption.copyWith(fontSize: isWeb ? 14 : 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(Style.spacingSmall),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(Style.buttonBorderRadius),
            ),
            child: Text(
              userInfo['role']!,
              style: Style.fontTitleSuperMini.copyWith(
                fontSize: isWeb ? 14 : 13,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Switch tile
  Widget _buildSwitchTile({
    required WidgetRef ref,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isWeb,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isWeb ? 20 : Style.paddingPhone,
        vertical: 4,
      ),
      leading: Icon(icon, color: Colors.blue[700]),
      title: Text(
        title,
        style: Style.fontTitleSuperMini.copyWith(fontSize: isWeb ? 16 : 15),
      ),
      subtitle: Text(
        subtitle,
        style: Style.fontCaption.copyWith(fontSize: isWeb ? 14 : 13),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue[700],
      ),
    );
  }

  // List tile
  Widget _buildListTile({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isWeb,
    Color? textColor,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isWeb ? 20 : Style.paddingPhone,
        vertical: 4,
      ),
      leading: Icon(icon, color: textColor ?? Colors.blue[700]),
      title: Text(
        title,
        style: Style.fontTitleSuperMini.copyWith(
          fontSize: isWeb ? 16 : 15,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Style.fontCaption.copyWith(fontSize: isWeb ? 14 : 13),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

  // ==================== HANDLERS ====================

  // Show logout dialog
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Đăng xuất', style: Style.fontTitleMini),
            content: Text(
              'Bạn có chắc chắn muốn đăng xuất?',
              style: Style.fontNormal,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Hủy',
                  style: Style.fontButton.copyWith(color: Style.textColorGray),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Đã đăng xuất',
                        style: Style.fontNormal.copyWith(
                          color: Style.textColorWhite,
                        ),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: Text(
                  'Đăng xuất',
                  style: Style.fontButton.copyWith(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
