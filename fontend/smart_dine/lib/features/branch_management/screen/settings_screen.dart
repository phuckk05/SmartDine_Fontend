import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/widgets/appbar.dart';
import '../../../providers/user_session_provider.dart';
import '../../../providers/user_provider.dart';
import '../../signin/screen_signin.dart';

class SettingsScreen extends ConsumerWidget {
  final bool showBackButton;
  
  const SettingsScreen({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Style.colorLight : Style.colorDark;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[850] : Style.backgroundColor,
      appBar: showBackButton 
        ? AppBarCus(
            title: 'Cài đặt',
            isCanpop: true,
            isButtonEnabled: true,
          )
        : AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text('Cài đặt', style: Style.fontTitle),
            automaticallyImplyLeading: false,
          ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hồ sơ nhà hàng
            Text(
              'Hồ sơ nhà hàng',
              style: Style.fontTitleMini.copyWith(color: textColor),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildUserProfile(ref, textColor),
            ),
            const SizedBox(height: 24),

            // Hệ thống & hoạt động
            Text(
              'Hệ thống & hoạt động',
              style: Style.fontTitleMini.copyWith(color: textColor),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSettingTile(
                    'Tổng số nhân viên',
                    '43',
                    Icons.people,
                    textColor,
                    () {},
                  ),
                  const Divider(height: 1),
                  _buildSettingTile(
                    'Đơn dịch vụ đang vận hành',
                    'free',
                    Icons.workspace_premium,
                    textColor,
                    () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Giấy phép kinh doanh
            Text(
              'Giấy phép kinh doanh',
              style: Style.fontTitleMini.copyWith(color: textColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Giấy phép kinh doanh của nhánh G6M',
              style: Style.fontCaption.copyWith(color: Style.textColorGray),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildLicenseCard(cardColor),
                const SizedBox(width: 12),
                _buildLicenseCard(cardColor),
              ],
            ),
            const SizedBox(height: 24),

            // Dịch vụ chúng tôi
            Text(
              'Dịch vụ chúng tôi',
              style: Style.fontTitleMini.copyWith(color: textColor),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trạng thái dịch vụ',
                    style: Style.fontNormal.copyWith(color: textColor),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Text(
                      'Đang hoạt động',
                      style: Style.fontCaption.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Button Đăng xuất
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  _showLogoutDialog(context, ref);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Đăng xuất',
                  style: Style.fontButton.copyWith(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, Color textColor, {String? label}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Style.textColorGray),
        const SizedBox(width: 8),
        if (label != null) ...[
          Text(
            '$label: ',
            style: Style.fontCaption.copyWith(color: Style.textColorGray),
          ),
        ],
        Expanded(
          child: Text(
            text,
            style: Style.fontNormal.copyWith(color: textColor),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    String title,
    String value,
    IconData icon,
    Color textColor,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: Style.fontNormal.copyWith(color: textColor),
      ),
      trailing: Text(
        value,
        style: Style.fontNormal.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildLicenseCard(Color cardColor) {
    return Expanded(
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.description,
            size: 48,
            color: Colors.amber,
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi hệ thống?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Đóng dialog trước
              
              try {
                // Gọi logout từ user_session_provider
                await ref.read(userSessionProvider.notifier).logout();
                
                // Hiển thị thông báo thành công
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã đăng xuất thành công')),
                  );
                  
                  // Chuyển về màn hình đăng nhập và xóa toàn bộ navigation stack
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const ScreenSignIn()),
                    (route) => false,
                  );
                }
              } catch (e) {
                // Xử lý lỗi nếu có
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi đăng xuất: $e')),
                  );
                }
              }
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  // Build user profile section với thông tin từ session
  Widget _buildUserProfile(WidgetRef ref, Color textColor) {
    final userSession = ref.watch(userSessionProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header với avatar và tên
        Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 30,
              backgroundColor: Style.buttonBackgroundColor.withOpacity(0.1),
              child: Text(
                _getAvatarInitial(userSession.userName ?? 'User'),
                style: TextStyle(
                  color: Style.buttonBackgroundColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Thông tin user
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userSession.userName ?? 'Không xác định',
                    style: Style.fontTitleMini.copyWith(color: textColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getUserRoleName(userSession.userRole),
                    style: Style.fontNormal.copyWith(
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                  if (userSession.isAuthenticated) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Text(
                        'Đang hoạt động',
                        style: Style.fontCaption.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Thông tin chi tiết
        Text(
          'Thông tin tài khoản',
          style: Style.fontNormal.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        _buildInfoItem(Icons.person, 'ID: ${userSession.userId ?? "N/A"}', textColor, label: 'Mã người dùng'),
        const SizedBox(height: 8),
        
        _buildInfoItem(Icons.business, 'Company ID: ${userSession.companyId ?? "N/A"}', textColor, label: 'Công ty'),
        const SizedBox(height: 8),
        
        _buildInfoItem(Icons.store, 'Branch ID: ${userSession.currentBranchId ?? "N/A"}', textColor, label: 'Chi nhánh hiện tại'),
        const SizedBox(height: 8),
        
        if (userSession.branchIds.isNotEmpty)
          _buildInfoItem(Icons.list, userSession.branchIds.join(', '), textColor, label: 'Các chi nhánh có quyền truy cập'),
        
        const SizedBox(height: 8),
        
        _buildInfoItem(Icons.access_time, _formatLoginTime(userSession.loginTime), textColor, label: 'Thời gian đăng nhập'),
      ],
    );
  }

  // Helper methods
  String _getAvatarInitial(String name) {
    if (name.isEmpty) return 'U';
    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words.first[0]}${words.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _getUserRoleName(int? role) {
    switch (role) {
      case 1:
        return 'Quản trị viên';
      case 2:
        return 'Quản lý chi nhánh';
      case 3:
        return 'Nhân viên';
      case 4:
        return 'Nhân viên phục vụ';
      case 5:
        return 'Chủ nhà hàng';
      default:
        return 'Không xác định';
    }
  }

  String _formatLoginTime(DateTime? loginTime) {
    if (loginTime == null) return 'Không xác định';
    
    final now = DateTime.now();
    final difference = now.difference(loginTime);
    
    if (difference.inMinutes < 1) {
      return 'Vừa mới';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${loginTime.day}/${loginTime.month}/${loginTime.year} ${loginTime.hour}:${loginTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
