import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/core/style.dart';
import '../../../providers/user_session_provider.dart';

/// Wrapper widget để handle session management cho các màn hình branch management
/// Loại bỏ duplicate code trong tất cả các screens
class BranchSessionWrapper extends ConsumerWidget {
  final Widget child;
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;

  const BranchSessionWrapper({
    super.key,
    required this.child,
    required this.title,
    this.showBackButton = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentBranchId = ref.watch(currentBranchIdProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Nếu chưa có session, tự động tạo mock session (chỉ cho development)
    if (!isAuthenticated || currentBranchId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Chỉ mock khi thực sự không có session nào
        final session = ref.read(userSessionProvider);
        if (session.userId == null) {
          ref.read(userSessionProvider.notifier).mockLogin(branchId: 1);
        }
      });

      return Scaffold(
        backgroundColor: isDark ? Colors.grey[850] : Style.backgroundColor,
        appBar: _buildAppBar(context, isDark),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang khởi tạo phiên làm việc...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[850] : Style.backgroundColor,
      appBar: _buildAppBar(context, isDark),
      body: child,
    );
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context, bool isDark) {
    if (showBackButton) {
      return AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(title, style: Style.fontTitle),
        actions: actions,
      );
    } else {
      return AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(title, style: Style.fontTitle),
        actions: actions,
      );
    }
  }
}