import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_session_provider.dart';
import '../features/signin/screen_signin.dart';
import '../features/branch_management/screen/branch_navigation.dart';

/// AuthWrapper - Kiểm tra authentication và chuyển hướng đúng role
/// Tự động kiểm tra session đã lưu và điều hướng tương ứng
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userSession = ref.watch(userSessionProvider);
    
    // Nếu chưa đăng nhập -> Màn hình đăng nhập
    if (!userSession.isAuthenticated) {
      return const ScreenSignIn();
    }
    
    // Đã đăng nhập -> Chuyển hướng theo role
    return _routeByRole(userSession.userRole);
  }
  
  /// Chuyển hướng dựa trên role của user
  Widget _routeByRole(int? role) {
    switch (role) {
      case 1:
        // Admin -> Hiện tại chuyển về Branch Management (comment để mở rộng sau)
        return const BranchManagementNavigation();
        // TODO: return const AdminDashboardNavigation();
        
      case 2:
        // Manager -> Branch Management Navigation
        return const BranchManagementNavigation();
        
      case 3:
        // Staff -> Hiện tại chuyển về Branch Management (comment để mở rộng sau)
        return const BranchManagementNavigation();
        // TODO: return const StaffNavigation();
        
      case 4:
        // Chef -> Hiện tại chuyển về Branch Management (comment để mở rộng sau)
        return const BranchManagementNavigation();
        // TODO: return const KitchenNavigation();
        
      case 5:
        // Owner -> Hiện tại chuyển về Branch Management (comment để mở rộng sau)
        return const BranchManagementNavigation();
        // TODO: return const OwnerDashboardNavigation();
        
      default:
        // Role không xác định -> về màn hình đăng nhập
        return const ScreenSignIn();
    }
  }
}

/// Loading wrapper để hiển thị loading khi đang khởi tạo session
class AuthLoadingWrapper extends ConsumerWidget {
  const AuthLoadingWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // UserSessionNotifier tự động load session trong constructor
    // Chỉ cần delay một chút để đảm bảo session đã được load
    return FutureBuilder<void>(
      future: Future.delayed(const Duration(milliseconds: 100)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Đang khởi tạo...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }
        
        // Sau khi khởi tạo xong -> AuthWrapper
        return const AuthWrapper();
      },
    );
  }
}