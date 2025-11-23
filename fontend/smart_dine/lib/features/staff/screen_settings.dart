import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/API_staff/branch_API.dart';
import 'package:mart_dine/API_staff/user_branch_API.dart';
import 'package:mart_dine/features/staff/screen_user_profile.dart';
import 'package:mart_dine/model_staff/user.dart';
import 'package:mart_dine/models/user_session.dart';
import 'package:mart_dine/provider_staff/mode_provider.dart';
import 'package:mart_dine/provider_staff/user_provider.dart';
import 'package:mart_dine/providers/user_session_provider.dart';

final _branchNameByIdProvider = FutureProvider.family<String?, int>((
  ref,
  branchId,
) async {
  final branchApi = ref.watch(branchApiProvider2);
  final branch = await branchApi.getBranchById(branchId);
  return branch?.name;
});

final _branchNameByUserProvider = FutureProvider.family<String?, int>((
  ref,
  userId,
) async {
  final userBranchApi = ref.watch(userBranchApiProvider);
  final data = await userBranchApi.getBranchByUserId(userId);
  if (data == null) return null;
  return data['branchName'] ?? data['branch_name'] ?? data['branchCode'];
});

class ScreenSettings extends ConsumerWidget {
  const ScreenSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final isDarkMode = ref.watch(modeProvider);
    final user = ref.watch(userNotifierProvider);
    final session = ref.watch(userSessionProvider);

    final displayName = _resolveDisplayName(user, session);
    final resolvedBranchId = _resolveBranchId(session);

    AsyncValue<String?>? branchLabelState;
    if (resolvedBranchId != null) {
      branchLabelState = ref.watch(_branchNameByIdProvider(resolvedBranchId));
    } else {
      final userId = user?.id ?? session.userId;
      if (userId != null) {
        branchLabelState = ref.watch(_branchNameByUserProvider(userId));
      }
    }

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
          _buildUserProfile(
            context,
            displayName: displayName,
            branchLabelState: branchLabelState,
            fallbackBranchId: resolvedBranchId,
            onLogout: () => _handleLogout(context, ref),
          ),

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
  Widget _buildUserProfile(
    BuildContext context, {
    required String displayName,
    required AsyncValue<String?>? branchLabelState,
    int? fallbackBranchId,
    required VoidCallback onLogout,
  }) {
    final branchChip = _buildBranchChipFromState(
      context,
      branchLabelState,
      fallbackBranchId: fallbackBranchId,
    );

    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text(
                  'Đăng xuất',
                  style: TextStyle(color: Colors.redAccent),
                ),
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              ),
            ],
          ),
          const SizedBox(height: 8),
          branchChip,
        ],
      ),
    );
  }

  String _resolveDisplayName(User? user, UserSession session) {
    final candidates = <String?>[
      user?.fullName,
      session.userName,
      session.name,
      user?.email,
      session.email,
    ];

    for (final value in candidates) {
      if (value != null && value.trim().isNotEmpty) {
        return value;
      }
    }

    return 'Chưa xác định';
  }

  int? _resolveBranchId(UserSession session) {
    if (session.currentBranchId != null) {
      return session.currentBranchId;
    }
    if (session.branchIds.isNotEmpty) {
      return session.branchIds.first;
    }
    return null;
  }

  Widget _buildBranchChipFromState(
    BuildContext context,
    AsyncValue<String?>? branchLabelState, {
    int? fallbackBranchId,
  }) {
    final fallbackLabel =
        fallbackBranchId != null
            ? 'Chi nhánh #$fallbackBranchId'
            : 'Chưa có chi nhánh';

    if (branchLabelState == null) {
      return _buildBranchChip(context, fallbackLabel);
    }

    return branchLabelState.when(
      data: (name) {
        final label =
            (name != null && name.trim().isNotEmpty) ? name : fallbackLabel;
        return _buildBranchChip(context, label);
      },
      loading:
          () => const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      error: (_, __) => _buildBranchChip(context, fallbackLabel),
    );
  }

  Widget _buildBranchChip(BuildContext context, String label) {
    return Chip(
      avatar: const Icon(Icons.storefront, size: 16, color: Colors.blue),
      label: Text(label),
      backgroundColor: Colors.blue.withOpacity(0.1),
      padding: EdgeInsets.zero,
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

  void _handleLogout(BuildContext context, WidgetRef ref) {
    ref.read(userNotifierProvider.notifier).signOut();
    Navigator.of(context).popUntil((route) => route.isFirst);
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
