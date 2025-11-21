import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/features/staff/screen_choose_table.dart';
import 'package:mart_dine/provider_staff/user_provider.dart';
import 'package:mart_dine/routes.dart';

class ScreenRoleSelection extends ConsumerWidget {
  const ScreenRoleSelection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(userNotifierProvider);

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy thông tin người dùng')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Chọn vai trò', style: Style.fontTitle),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Chào mừng, ${currentUser.fullName.isNotEmpty ? currentUser.fullName : currentUser.email}',
                style: Style.fontTitle.copyWith(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Vui lòng chọn vai trò của bạn',
                style: Style.fontNormal.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Nút Nhân viên phục vụ
              _buildRoleButton(
                context,
                'Nhân viên phục vụ',
                'Phục vụ khách hàng, quản lý bàn',
                Icons.restaurant_menu,
                Colors.green,
                () {
                  Routes.pushRightLeftConsumerFul(
                    context,
                    const ScreenChooseTable(),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Nút Thu ngân
              _buildRoleButton(
                context,
                'Thu ngân',
                'Thanh toán và quản lý hóa đơn',
                Icons.point_of_sale,
                Colors.blue,
                () {
                  // TODO: Navigate to cashier screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Chức năng thu ngân đang phát triển'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Nút Bếp (nếu role là 4 - Chef)
              if (currentUser.role == 4)
                _buildRoleButton(
                  context,
                  'Bếp',
                  'Chuẩn bị và quản lý món ăn',
                  Icons.kitchen,
                  Colors.orange,
                  () {
                    // Routes.pushRightLeftConsumerFul(
                    //   context,
                    //   const ScreenBottomNavigation(index: 1),
                    // );
                  },
                ),

              const SizedBox(height: 48),

              // Nút đăng xuất
              TextButton(
                onPressed: () {
                  ref.read(userNotifierProvider.notifier).signOut();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text(
                  'Đăng xuất',
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      width: double.infinity,
      height: 100,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: color.withOpacity(0.3)),
          ),
          padding: const EdgeInsets.all(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: Style.fontTitle.copyWith(fontSize: 18, color: color),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Style.fontNormal.copyWith(
                      fontSize: 14,
                      color: color.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color),
          ],
        ),
      ),
    );
  }
}
