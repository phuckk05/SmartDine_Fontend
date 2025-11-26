import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/features/owner/screen_account_info.dart';
import 'package:mart_dine/features/signin/screen_signin.dart';
import 'package:mart_dine/models/user_session.dart';
import 'package:mart_dine/provider_staff/mode_provider.dart';
import 'package:mart_dine/providers/user_session_provider.dart';
import 'package:mart_dine/routes.dart';

class ScreenSettings extends ConsumerWidget {
  const ScreenSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final isDarkMode = ref.watch(modeProvider);
    final session = ref.watch(userSessionProvider);

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
          _buildUserProfile(context, ref, session),

          // Account section
          _buildSectionHeader(context, 'Tài khoản'),
          _buildSettingsItem(
            context: context,
            icon: Icons.person_outline,
            title: 'Thông tin tài khoản',
            onTap: () {
              Routes.pushRightLeftConsumerLess(
                context,
                const ScreenAccountInfo(),
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
  Widget _buildUserProfile(
    BuildContext context,
    WidgetRef ref,
    UserSession session,
  ) {
    final userName = session.userName ?? session.name ?? 'Nhân viên';
    final branchLabel =
        session.currentBranchId != null
            ? 'CN ${session.currentBranchId}'
            : '__';

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
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Chip(
                avatar: const Icon(
                  Icons.storefront,
                  size: 16,
                  color: Colors.blue,
                ),
                label: Text(branchLabel),
                backgroundColor: Colors.blue.withOpacity(0.1),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          OutlinedButton(
            onPressed: () => _confirmLogout(context, ref),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: BorderSide(color: Colors.grey.shade400),
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout =
        await showDialog<bool>(
          context: context,
          builder:
              (dialogContext) => AlertDialog(
                title: const Text('Đăng xuất'),
                content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('Hủy'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: const Text('Đăng xuất'),
                  ),
                ],
              ),
        ) ??
        false;

    if (!shouldLogout) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(userSessionProvider.notifier).logout();
      messenger.showSnackBar(
        const SnackBar(content: Text('Đăng xuất thành công')),
      );
      Routes.pushAndRemoveUntil(context, const ScreenSignIn());
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Đăng xuất thất bại: $e')));
    }
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
