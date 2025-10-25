import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/features/staff/screen_user_profile.dart';
import 'package:mart_dine/providers/mode_provider.dart';

class ScreenSettings extends ConsumerWidget {
  const ScreenSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final isDarkMode = ref.watch(modeProvider);

    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Cài đặt', style: TextStyle(color: textColor)),
        backgroundColor: surfaceColor,
        elevation: 1,
      ),
      body: ListView(
        children: [
          // User profile section
          _buildUserProfile(context),

          // Account section
          _buildSectionHeader(context, 'Tài khoản'),
          _buildSettingsItem(
            context: context,
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
            context: context,
            icon: Icons.history,
            title: 'Lịch sử gọi món',
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (_) => const ScreenOrderHistory()),
              // );
            },
          ),

          // Content and activity section
          _buildSectionHeader(context, 'Nội dung và hoạt động'),
          _buildDarkModeToggle(context, ref, isDarkMode),
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
        color: Theme.of(context).colorScheme.surface,
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
                avatar: const Icon(
                  Icons.storefront,
                  size: 16,
                  color: Colors.blue,
                ),
                label: const Text('Chi nhánh A'),
                backgroundColor: Colors.blue.withOpacity(0.1),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          OutlinedButton(
            onPressed: () {},
            child: Text('Đăng xuất'),
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
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
    );
  }

  // Widget for a single settings item
  Widget _buildSettingsItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
        ),
        title: Text(title),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
        ),
        onTap: onTap,
      ),
    );
  }

  // Widget for the dark mode toggle
  Widget _buildDarkModeToggle(
    BuildContext context,
    WidgetRef ref,
    bool isDarkMode,
  ) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: SwitchListTile(
        title: const Text('Chế độ tối'),
        secondary: Icon(
          Icons.nightlight_round,
          color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
        ),
        value: isDarkMode,
        onChanged: (bool value) {
          ref.read(modeProvider.notifier).setMode(value);
        },
      ),
    );
  }
}
