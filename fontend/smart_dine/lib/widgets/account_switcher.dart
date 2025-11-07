import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_session_provider.dart';

class AccountSwitcher extends ConsumerWidget {
  const AccountSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userSession = ref.watch(userSessionProvider);
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🔧 Dev Mode - Chuyển đổi tài khoản',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Thông tin tài khoản hiện tại
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '👤 Đang đăng nhập: ${userSession.userName}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('🏷️ Vai trò: ${userSession.userRole}'),
                  Text('🏢 Chi nhánh: ${userSession.branchIds}'),
                  Text('📍 Chi nhánh hiện tại: ${userSession.currentBranchId}'),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            Text(
              'Chọn loại tài khoản để test:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            
            // Các nút chuyển đổi tài khoản
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildAccountButton(
                  context,
                  ref,
                  '👑 Admin Tổng',
                  'admin',
                  'Quản lý tất cả chi nhánh',
                  Colors.red,
                ),
                _buildAccountButton(
                  context,
                  ref,
                  '🏢 Manager CN2',
                  'manager_branch_2',
                  'Chỉ quản lý chi nhánh 2',
                  Colors.orange,
                ),
                _buildAccountButton(
                  context,
                  ref,
                  '👥 Staff CN3',
                  'staff_branch_3',
                  'Chỉ làm việc ở chi nhánh 3',
                  Colors.green,
                ),
                _buildAccountButton(
                  context,
                  ref,
                  '🔗 Manager Đa CN',
                  'multi_branch_manager',
                  'Quản lý chi nhánh 2,3,4',
                  Colors.purple,
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            Text(
              '💡 Mỗi tài khoản sẽ chỉ thấy dữ liệu của chi nhánh được phép truy cập',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountButton(
    BuildContext context,
    WidgetRef ref,
    String title,
    String accountType,
    String description,
    Color color,
  ) {
    return ElevatedButton(
      onPressed: () async {
        try {
          await ref.read(userSessionProvider.notifier)
              .mockLoginByAccountType(accountType);
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ Đã chuyển sang: $title'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Lỗi: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Text(
            description,
            style: const TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}