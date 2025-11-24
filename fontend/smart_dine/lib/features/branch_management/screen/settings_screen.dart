import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/widgets/appbar.dart';
import '../../../providers/employee_management_provider.dart';
import '../../../providers/user_session_provider.dart';
import '../../../API/branch_API.dart';
import '../../../models/branch.dart';
import '../../signin/screen_signin.dart';

class SettingsScreen extends ConsumerWidget {
  final bool showBackButton;
  
  const SettingsScreen({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Style.colorLight : Style.colorDark;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;
    
    // Lấy thông tin user session và validate
    final userSession = ref.watch(userSessionProvider);
    final userSessionNotifier = ref.read(userSessionProvider.notifier);
    
    // Validate session ngay khi build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userSessionNotifier.validateSession();
    });

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
            // Thông tin tài khoản đăng nhập
            Text(
              'Thông tin tài khoản',
              style: Style.fontTitleMini.copyWith(color: textColor),
            ),
            const SizedBox(height: 12),
            
            // Lấy thông tin chi nhánh cho phần tài khoản
            userSession.currentBranchId != null
              ? FutureBuilder<Branch?>(
                  future: BranchAPI().getBranchById(
                    userSession.currentBranchId.toString(),
                    userId: userSession.userId,
                  ),
                  builder: (context, snapshot) {
                    final branch = snapshot.data;
                    return Container(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoItem(
                            Icons.person, 
                            userSession.userName ?? 'Chưa có tên', 
                            textColor, 
                            label: 'Tên người dùng'
                          ),
                          const SizedBox(height: 8),
                          _buildInfoItem(
                            Icons.badge, 
                            'ID: ${userSession.userId ?? 'N/A'}', 
                            textColor, 
                            label: 'Mã người dùng'
                          ),
                          const SizedBox(height: 8),
                          _buildInfoItem(
                            Icons.business, 
                            snapshot.connectionState == ConnectionState.waiting
                              ? 'Đang tải...'
                              : 'Chi nhánh: ${branch?.name ?? userSession.currentBranchId ?? 'Chưa chọn'}', 
                            textColor, 
                            label: 'Chi nhánh hiện tại'
                          ),
                          const SizedBox(height: 8),
                          _buildInfoItem(
                            Icons.admin_panel_settings, 
                            _getRoleName(userSession.userRole), 
                            textColor, 
                            label: 'Vai trò'
                          ),
                          const SizedBox(height: 8),
                          _buildInfoItem(
                            Icons.access_time, 
                            userSession.loginTime?.toString().split('.')[0] ?? 'Chưa có', 
                            textColor, 
                            label: 'Thời gian đăng nhập'
                          ),
                          const SizedBox(height: 8),
                          _buildInfoItem(
                            Icons.apartment, 
                            snapshot.connectionState == ConnectionState.waiting
                              ? 'Đang tải...'
                              : '${branch?.companyName ?? 'Company ID: ${userSession.companyId ?? 'N/A'}'}', 
                            textColor, 
                            label: 'Công ty'
                          ),
                        ],
                      ),
                    );
                  },
                )
              : Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoItem(
                        Icons.person, 
                        userSession.userName ?? 'Chưa có tên', 
                        textColor, 
                        label: 'Tên người dùng'
                      ),
                      const SizedBox(height: 8),
                      _buildInfoItem(
                        Icons.badge, 
                        'ID: ${userSession.userId ?? 'N/A'}', 
                        textColor, 
                        label: 'Mã người dùng'
                      ),
                      const SizedBox(height: 8),
                      _buildInfoItem(
                        Icons.business, 
                        'Chi nhánh: Chưa chọn', 
                        textColor, 
                        label: 'Chi nhánh hiện tại'
                      ),
                      const SizedBox(height: 8),
                      _buildInfoItem(
                        Icons.admin_panel_settings, 
                        _getRoleName(userSession.userRole), 
                        textColor, 
                        label: 'Vai trò'
                      ),
                      const SizedBox(height: 8),
                      _buildInfoItem(
                        Icons.access_time, 
                        userSession.loginTime?.toString().split('.')[0] ?? 'Chưa có', 
                        textColor, 
                        label: 'Thời gian đăng nhập'
                      ),
                      const SizedBox(height: 8),
                      _buildInfoItem(
                        Icons.apartment, 
                        'Company ID: ${userSession.companyId ?? 'N/A'}', 
                        textColor, 
                        label: 'Công ty'
                      ),
                    ],
                  ),
                ),
            const SizedBox(height: 24),

            // Hồ sơ nhà hàng
            Text(
              'Hồ sơ nhà hàng',
              style: Style.fontTitleMini.copyWith(color: textColor),
            ),
            const SizedBox(height: 12),
            
            // Lấy thông tin chi nhánh với fallback tốt hơn
            userSession.currentBranchId != null
              ? FutureBuilder<Branch?>(
                  future: BranchAPI().getBranchById(
                    userSession.currentBranchId.toString(),
                    userId: userSession.userId,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        padding: const EdgeInsets.all(32),
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
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    }
                    
                    if (snapshot.hasError) {
                      return Container(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thông tin chi nhánh',
                              style: Style.fontNormal.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Chi nhánh: ${userSession.currentBranchId ?? 'N/A'}',
                              style: Style.fontTitleMini.copyWith(color: Colors.orange),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Đang tải thông tin chi nhánh từ server...',
                              style: Style.fontCaption.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    final branch = snapshot.data;
                    return Container(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thông tin chi nhánh',
                            style: Style.fontNormal.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            branch?.name ?? 'SmartDine - Chi nhánh ${userSession.currentBranchId}',
                            style: Style.fontTitleMini.copyWith(color: textColor),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoItem(Icons.business, branch?.branchCode ?? 'N/A', textColor, label: 'Mã chi nhánh'),
                          const SizedBox(height: 8),
                          _buildInfoItem(Icons.location_on, branch?.address ?? 'Chưa cập nhật', textColor, label: 'Địa chỉ'),
                          const SizedBox(height: 8),
                          _buildInfoItem(Icons.phone, branch?.managerPhone ?? 'Chưa cập nhật', textColor, label: 'SĐT quản lý'),
                          const SizedBox(height: 8),
                          _buildInfoItem(Icons.info, 'Chi nhánh ID: ${branch?.id ?? userSession.currentBranchId}', textColor, label: 'Mã chi nhánh'),
                          const SizedBox(height: 8),
                          _buildInfoItem(Icons.apartment, '${branch?.companyName ?? 'Company'} (ID: ${branch?.companyId ?? userSession.companyId ?? 'N/A'})', textColor, label: 'Công ty'),
                          const SizedBox(height: 8),
                          _buildInfoItem(Icons.calendar_today, branch?.createdAt.year.toString() ?? 'N/A', textColor, label: 'Năm thành lập'),
                        ],
                      ),
                    );
                  },
                )
              : Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông tin chi nhánh',
                        style: Style.fontNormal.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Chưa có thông tin chi nhánh',
                        style: Style.fontTitleMini.copyWith(color: Colors.orange),
                      ),
                    ],
                  ),
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
                  Consumer(
                    builder: (context, ref, child) {
                      final currentBranchId = ref.watch(currentBranchIdProvider);
                      if (currentBranchId == null) {
                        return _buildSettingTile(
                          'Tổng số nhân viên',
                          'Chưa có chi nhánh',
                          Icons.people,
                          textColor,
                          () {},
                        );
                      }
                      
                      final employeesAsyncValue = ref.watch(employeeManagementProvider(currentBranchId));
                      return employeesAsyncValue.when(
                        loading: () => _buildSettingTile(
                          'Tổng số nhân viên',
                          'Đang tải...',
                          Icons.people,
                          textColor,
                          () {},
                        ),
                        error: (error, stackTrace) => _buildSettingTile(
                          'Tổng số nhân viên',
                          'Lỗi tải dữ liệu',
                          Icons.people,
                          Colors.red,
                          () {},
                        ),
                        data: (employees) => _buildSettingTile(
                          'Tổng số nhân viên',
                          '${employees.length}',
                          Icons.people,
                          textColor,
                          () {},
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSettingTile(
                    'Dịch vụ đang sử dụng',
                    'SmartDine Pro',
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
              'Giấy phép kinh doanh của chi nhánh ${userSession.currentBranchId ?? 'N/A'}',
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
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Thực hiện đăng xuất
              await ref.read(userSessionProvider.notifier).logout();
              
              // Hiển thị thông báo
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã đăng xuất thành công'),
                    backgroundColor: Colors.green,
                  ),
                );
                
                // Chuyển về màn hình đăng nhập
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ScreenSignIn(),
                  ),
                  (route) => false, // Xóa tất cả các route trước đó
                );
              }
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Helper method để lấy tên vai trò
  String _getRoleName(int? role) {
    switch (role) {
      case 1:
        return 'Quản trị viên';
      case 2:
        return 'Quản lý chi nhánh';
      case 3:
        return 'Nhân viên';
      case 4:
        return 'Đầu bếp';
      case 5:
        return 'Chủ sở hữu';
      default:
        return 'Không xác định';
    }
  }
}
