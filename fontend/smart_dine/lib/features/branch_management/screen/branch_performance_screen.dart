import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/style.dart';
import '/widgets/appbar.dart';
import '../../../providers/user_session_provider.dart';
import '../../../providers/employee_performance_provider.dart';

class BranchPerformanceScreen extends ConsumerStatefulWidget {
  const BranchPerformanceScreen({super.key});

  @override
  ConsumerState<BranchPerformanceScreen> createState() =>
      _BranchPerformanceScreenState();
}

class _BranchPerformanceScreenState
    extends ConsumerState<BranchPerformanceScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Style.colorLight : Style.colorDark;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;

    /// Kiểm tra user session
    final currentBranchId = ref.watch(currentBranchIdProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (!isAuthenticated || currentBranchId == null) {
      return Scaffold(
        backgroundColor: isDark ? Colors.grey[850] : Style.backgroundColor,
        appBar: AppBarCus(
          title: 'Hiệu xuất chi nhánh',
          isCanpop: true,
          isButtonEnabled: true,
        ),
        body: _buildEmptyState(context, isDark, cardColor, textColor),
      );
    }

    /// Watch employee performance
    final performanceAsync = ref.watch(
      employeePerformanceProvider(currentBranchId),
    );

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[850] : Style.backgroundColor,
      appBar: AppBarCus(
        title: 'Hiệu xuất chi nhánh',
        isCanpop: true,
        isButtonEnabled: true,
      ),
      body: performanceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stackTrace) => _buildErrorState(
              error,
              isDark,
              cardColor,
              textColor,
              currentBranchId,
            ),
        data: (data) {
          final performances = data?.employeeList ?? [];
          if (data == null || performances.isEmpty) {
            return _buildEmptyState(context, isDark, cardColor, textColor);
          }

          return _buildContent(
            data,
            isDark,
            cardColor,
            textColor,
            currentBranchId,
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  /// BUILD NỘI DUNG CHÍNH
  // ---------------------------------------------------------------------------

  Widget _buildContent(
    data,
    bool isDark,
    Color cardColor,
    Color textColor,
    int branchId,
  ) {
    final performances = data.employeeList ?? [];

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(employeePerformanceProvider(branchId).notifier)
            .refresh();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //------------------------------------------------------------------
            // Tổng quan
            //------------------------------------------------------------------
            Text(
              'Tổng quan chi nhánh',
              style: Style.fontTitleMini.copyWith(color: textColor),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Tổng đơn hàng',
                    data.overview?['totalOrders']?.toString() ?? '0',
                    Icons.shopping_cart,
                    Colors.blue,
                    isDark,
                    cardColor,
                    textColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Doanh thu',
                    '${data.overview?['totalRevenue'] ?? '0'} đ',
                    Icons.attach_money,
                    Colors.green,
                    isDark,
                    cardColor,
                    textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Khách hàng',
                    data.overview?['totalOrders']?.toString() ?? '0',
                    Icons.people,
                    Colors.orange,
                    isDark,
                    cardColor,
                    textColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Tỷ lệ hoàn thành',
                    '${(data.overview?['completionRate'] ?? 0.0).toStringAsFixed(1)}%',
                    Icons.check_circle,
                    Colors.purple,
                    isDark,
                    cardColor,
                    textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Cập nhật',
                    data.overview?['lastUpdated'] != null
                        ? DateTime.parse(data.overview!['lastUpdated']).toLocal().toString().split(' ')[0]
                        : 'N/A',
                    Icons.update,
                    Colors.teal,
                    isDark,
                    cardColor,
                    textColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            //------------------------------------------------------------------
            // Hiệu suất nhân viên
            //------------------------------------------------------------------
            Text(
              'Hiệu suất nhân viên',
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
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Nhân viên',
                          style: Style.fontTitleMini.copyWith(color: textColor),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Số bàn phục vụ',
                          style: Style.fontTitleMini.copyWith(color: textColor),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Số đơn hoàn thành',
                          style: Style.fontTitleMini.copyWith(color: textColor),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),

                  ...performances.where((employee) {
                    // Lọc chỉ hiển thị nhân viên có role STAFF, CHEF, Cashier
                    final roleId = employee['roleId'] ?? employee['role'];
                    final role = roleId is int ? roleId : (roleId?.toString().toLowerCase() ?? '');
                    return role == 3 || role == '3' || // STAFF
                           role == 4 || role == '4' || // CHEF
                           role == 6 || role == '6' || // Cashier
                           (role is String && (
                             role.contains('nhân viên') || role.contains('nhan vien') ||
                             role.contains('đầu bếp') || role.contains('dau bep') ||
                             role.contains('chef') || role.contains('thu ngân') ||
                             role.contains('thu ngan') || role.contains('cashier') ||
                             role.contains('staff')
                           ));
                  }).map(
                    (e) => Row(
                      children: [
                        Expanded(
                          child: Text(
                            e['name'] ?? '-',
                            style: Style.fontContent.copyWith(color: textColor),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            e['tablesServed']?.toString() ?? '0',
                            style: Style.fontContent.copyWith(color: textColor),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            e['ordersCompleted']?.toString() ?? '0',
                            style: Style.fontContent.copyWith(color: textColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            //------------------------------------------------------------------
            // Hiệu xuất nhân viên
            //------------------------------------------------------------------
            Text(
              'Hiệu xuất nhân viên',
              style: Style.fontTitleMini.copyWith(color: textColor),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Tên nhân viên',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Đơn phục vụ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Doanh thu',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  ...performances.map(
                    (employee) => Column(
                      children: [
                        _buildEmployeeRow(
                          employee['name'] ?? '-',
                          employee['totalServed']?.toString() ?? '-',
                          employee['tips']?.toString() ?? '-',
                          textColor,
                        ),
                        if (performances.indexOf(employee) <
                            performances.length - 1)
                          const Divider(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  /// CÁC WIDGET PHỤ
  // ---------------------------------------------------------------------------

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
    Color cardColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: Style.fontCaption.copyWith(
              color: isDark ? Colors.grey[400] : Style.textColorGray,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Style.fontTitleMini.copyWith(color: textColor, fontSize: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    bool isDark,
    Color cardColor,
    Color textColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.trending_up, size: 40, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Text(
            'Chưa có dữ liệu hiệu xuất',
            style: Style.fontTitle.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Hệ thống sẽ hiển thị hiệu xuất khi có dữ liệu.\nVui lòng đăng nhập với tài khoản có quyền truy cập chi nhánh.',
            textAlign: TextAlign.center,
            style: Style.fontContent.copyWith(
              color: textColor.withOpacity(0.7),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            label: const Text(
              'Quay lại',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6200EE),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeRow(
    String name,
    String v1,
    String v2,
    Color textColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            name,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            v1,
            textAlign: TextAlign.center,
            style: TextStyle(color: textColor),
          ),
        ),
        Expanded(
          child: Text(
            v2,
            textAlign: TextAlign.center,
            style: TextStyle(color: textColor),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(
    Object error,
    bool isDark,
    Color cardColor,
    Color textColor,
    int branchId,
  ) {
    return Container(
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Lỗi tải dữ liệu hiệu suất',
            style: Style.fontTitle.copyWith(color: textColor),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Style.fontContent.copyWith(
              color: textColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
