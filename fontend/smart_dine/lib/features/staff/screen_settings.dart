import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/features/staff/screen_order_history.dart';
import 'package:mart_dine/features/staff/screen_user_profile.dart';

class ScreenSettings extends ConsumerWidget {
  const ScreenSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Cài đặt', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView(
        children: [
          // User profile section
          _buildUserProfile(context),

          // Account section
          _buildSectionHeader('Tài khoản'),
          _buildSettingsItem(
            icon: Icons.person_outline,
            title: 'Thông tin tài khoản',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScreenUserProfile()),
              );
            },
          ),
          _buildSettingsItem(
            icon: Icons.history,
            title: 'Lịch sử gọi món',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScreenOrderHistory()),
              );
            },
          ),

          // Content and activity section
          _buildSectionHeader('Nội dung và hoạt động'),
          _buildDarkModeToggle(context),
        ],
      ),
    );
  }

  // Widget for the user profile card
  Widget _buildUserProfile(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nhân viên 1',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Chip(
                avatar: const Icon(Icons.storefront, size: 16, color: Colors.blue),
                label: const Text('Chi nhánh A'),
                backgroundColor: Colors.blue.withOpacity(0.1),
                padding: EdgeInsets.zero,
              )
            ],
          ),
          OutlinedButton(
            onPressed: () {
              // TODO: Handle logout logic
            },
            child: const Text('Đăng xuất'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: BorderSide(color: Colors.grey.shade400),
            ),
          ),
        ],
      ),
    );
  }

  // Widget for section headers
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  // Widget for a single settings item
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[600]),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // Widget for the dark mode toggle
  Widget _buildDarkModeToggle(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SwitchListTile(
        title: const Text('Chế độ tối'),
        secondary: Icon(Icons.nightlight_round, color: Colors.grey[600]),
        value: false, // Default value, to be updated with state management
        onChanged: (bool value) {
          // TODO: Handle dark mode logic
        },
      ),
    );
  }
}