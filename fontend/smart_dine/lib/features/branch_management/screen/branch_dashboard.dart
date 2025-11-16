import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/features/branch_management/screen/order_list_screen.dart';
import 'package:mart_dine/features/branch_management/screen/today_activities_screen.dart';
import '../../../providers/branch_statistics_provider.dart';
import '../../../providers/user_session_provider.dart';
import '../../../models/statistics.dart';

class BranchDashboardScreen extends ConsumerStatefulWidget {
  const BranchDashboardScreen({super.key});

  @override
  ConsumerState<BranchDashboardScreen> createState() => _BranchDashboardScreenState();
}

class _BranchDashboardScreenState extends ConsumerState<BranchDashboardScreen> {
  // Primary color constant
  static const Color primaryColor = Color(0xFF6200EE);

  @override
  Widget build(BuildContext context) {
    // Lấy branchId từ user session
    final currentBranchId = ref.watch(currentBranchIdProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    
    // Kiểm tra authentication - yêu cầu user phải đăng nhập
    if (!isAuthenticated) {
      return Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[850] : Style.backgroundColor,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Vui lòng đăng nhập để tiếp tục'),
            ],
          ),
        ),
      );
    }

    final branchIdInt = currentBranchId;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (branchIdInt == null) {
      return Scaffold(
        backgroundColor: isDark ? Colors.grey[850] : Style.backgroundColor,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning, size: 64, color: Colors.orange),
              SizedBox(height: 16),
              Text('Không tìm thấy thông tin chi nhánh'),
              Text('Vui lòng đăng nhập lại'),
            ],
          ),
        ),
      );
    }
    final statisticsAsyncValue = ref.watch(branchStatisticsProvider(branchIdInt));
    
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[850] : Style.backgroundColor,
      body: SafeArea(
        child: statisticsAsyncValue.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => RefreshIndicator(
            onRefresh: () async {
              return ref.refresh(branchStatisticsProvider(branchIdInt));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  // Hiển thị các card với thông báo "Chưa có dữ liệu"
                  _buildEmptyMetricsCards(isDark),
                  const SizedBox(height: 20),
                  _buildQuickActions(isDark),
                ],
              ),
            ),
          ),
          data: (statistics) => RefreshIndicator(
            onRefresh: () async {
              return ref.refresh(branchStatisticsProvider(ref.read(currentBranchIdProvider)!));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  if (statistics != null) ...[
                    _buildMetricsCards(statistics, isDark),
                    const SizedBox(height: 20),
                  ],
                  _buildQuickActions(isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard Chi nhánh',
              style: Style.fontTitle.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              'Tổng quan hoạt động hôm nay',
              style: Style.fontContent.copyWith(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            final branchIdInt = ref.read(currentBranchIdProvider)!;
            // ignore: unused_result
            ref.refresh(branchStatisticsProvider(branchIdInt));
          },
          icon: const Icon(Icons.refresh),
          style: IconButton.styleFrom(
            backgroundColor: primaryColor.withOpacity(0.1),
            foregroundColor: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsCards(BranchMetrics statistics, bool isDark) {
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;
    final textColor = isDark ? Style.colorLight : Style.colorDark;
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          'Doanh thu hôm nay',
          '${statistics.totalRevenue.toString()}đ',
          Icons.attach_money,
          Colors.green,
          cardColor,
          textColor,
        ),
        _buildMetricCard(
          'Đơn hàng',
          statistics.totalOrders.toString(),
          Icons.receipt_long,
          Colors.blue,
          cardColor,
          textColor,
        ),
        _buildMetricCard(
          'Khách hàng mới',
          statistics.newCustomers.toString(),
          Icons.people,
          Colors.orange,
          cardColor,
          textColor,
        ),
        _buildMetricCard(
          'Giá trị TB/đơn',
          '${statistics.avgOrderValue.toString()}đ',
          Icons.trending_up,
          Colors.purple,
          cardColor,
          textColor,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color iconColor,
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor, size: 24),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: Style.fontTitle.copyWith(
              fontSize: 20,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Style.fontContent.copyWith(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;
    final textColor = isDark ? Style.colorLight : Style.colorDark;
    
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
            'Thao tác nhanh',
            style: Style.fontTitle.copyWith(fontSize: 18, color: textColor),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: [
              _buildQuickActionButton(
                'Danh sách đơn hàng',
                Icons.list_alt,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrderListScreen(),
                    ),
                  );
                },
                isDark,
              ),
              _buildQuickActionButton(
                'Hoạt động hôm nay',
                Icons.today,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TodayActivitiesScreen(),
                    ),
                  );
                },
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    VoidCallback onTap,
    bool isDark,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: primaryColor.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: Style.fontContent.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMetricsCards(bool isDark) {
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;
    final textColor = isDark ? Style.colorLight : Style.colorDark;
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildEmptyMetricCard(
          'Doanh thu hôm nay',
          Icons.attach_money,
          Colors.green,
          cardColor,
          textColor,
        ),
        _buildEmptyMetricCard(
          'Đơn hàng',
          Icons.receipt_long,
          Colors.blue,
          cardColor,
          textColor,
        ),
        _buildEmptyMetricCard(
          'Khách hàng mới',
          Icons.people,
          Colors.orange,
          cardColor,
          textColor,
        ),
        _buildEmptyMetricCard(
          'Giá trị TB/đơn',
          Icons.trending_up,
          Colors.purple,
          cardColor,
          textColor,
        ),
      ],
    );
  }

  Widget _buildEmptyMetricCard(
    String title,
    IconData icon,
    Color iconColor,
    Color cardColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor.withOpacity(0.5), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Style.fontContent.copyWith(
                    color: textColor.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Chưa có dữ liệu',
            style: Style.fontTitleMini.copyWith(
              color: Colors.orange,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'API chưa trả về dữ liệu',
            style: Style.fontContent.copyWith(
              color: textColor.withOpacity(0.5),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}