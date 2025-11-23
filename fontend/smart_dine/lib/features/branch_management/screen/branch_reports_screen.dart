import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/core/style.dart';
import '../../../providers/branch_statistics_provider.dart';
import '../../../providers/user_session_provider.dart';
import '../../../models/statistics.dart';

class BranchReportsScreen extends ConsumerStatefulWidget {
  final bool showBackButton;
  
  const BranchReportsScreen({super.key, this.showBackButton = true});

  @override
  ConsumerState<BranchReportsScreen> createState() => _BranchReportsScreenState();
}

class _BranchReportsScreenState extends ConsumerState<BranchReportsScreen> {
  String _selectedPeriod = 'Tháng này';

  @override
  Widget build(BuildContext context) {
    // Lấy branchId từ user session
    final currentBranchId = ref.watch(currentBranchIdProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    
    // Yêu cầu user phải đăng nhập
    if (!isAuthenticated) {
      return const Scaffold(
        body: Center(
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
        appBar: widget.showBackButton
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text('Báo cáo chi nhánh', style: Style.fontTitle),
            )
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text('Báo cáo chi nhánh', style: Style.fontTitle),
              automaticallyImplyLeading: false,
            ),
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
      appBar: widget.showBackButton
        ? AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text('Báo cáo chi nhánh', style: Style.fontTitle),
          )
        : AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text('Báo cáo chi nhánh', style: Style.fontTitle),
            automaticallyImplyLeading: false,
          ),
      body: statisticsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Lỗi tải dữ liệu: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // ignore: unused_result
                  ref.refresh(branchStatisticsProvider(branchIdInt));
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        data: (statistics) => RefreshIndicator(
          onRefresh: () async {
            return ref.refresh(branchStatisticsProvider(branchIdInt));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPeriodSelector(isDark),
                const SizedBox(height: 20),
                if (statistics != null) ...[
                  _buildOverviewCards(statistics, isDark),
                  const SizedBox(height: 20),
                  _buildRevenueChart(statistics, isDark),
                  const SizedBox(height: 20),
                  _buildOrderChart(statistics, isDark),
                  const SizedBox(height: 20),
                  _buildGrowthRatesSection(statistics, isDark),
                  const SizedBox(height: 20),
                  _buildSummarySection(statistics, isDark),
                ] else ...[
                  _buildEmptyDataState(isDark),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(bool isDark) {
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;
    
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
      child: Row(
        children: [
          Icon(Icons.date_range, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            'Thời gian:',
            style: Style.fontContent.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedPeriod,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: ['Tuần này', 'Tháng này', 'Quý này']
                  .map((period) => DropdownMenuItem<String>(
                        value: period,
                        child: Text(period),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPeriod = value!;
                });
                // Refresh data when period changes
                final branchIdInt = ref.read(currentBranchIdProvider)!;
                // ignore: unused_result
                ref.refresh(branchStatisticsProvider(branchIdInt));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(BranchMetrics statistics, bool isDark) {
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;
    final textColor = isDark ? Style.colorLight : Style.colorDark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tổng quan',
          style: Style.fontTitle.copyWith(fontSize: 20, color: textColor),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [
            _buildMetricCard(
              'Doanh thu',
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
              'Giá trị TB/đơn',
              '${statistics.avgOrderValue.toString()}đ',
              Icons.trending_up,
              Colors.orange,
              cardColor,
              textColor,
            ),
            _buildMetricCard(
              'Khách hàng mới',
              statistics.newCustomers.toString(),
              Icons.people,
              Colors.purple,
              cardColor,
              textColor,
            ),
          ],
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: Style.fontTitle.copyWith(
              fontSize: 18,
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

  Widget _buildRevenueChart(BranchMetrics statistics, bool isDark) {
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
            'Xu hướng doanh thu',
            style: Style.fontTitle.copyWith(fontSize: 18, color: textColor),
          ),
          const SizedBox(height: 16),
          Text(
            'Khoảng thời gian: ${statistics.dateRange}',
            style: Style.fontContent.copyWith(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 200,
            child: Center(
              child: Text(
                'Biểu đồ doanh thu sẽ được hiển thị khi có dữ liệu chi tiết',
                style: Style.fontContent.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthRatesSection(BranchMetrics statistics, bool isDark) {
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
            'Tỷ lệ tăng trưởng',
            style: Style.fontTitle.copyWith(fontSize: 18, color: textColor),
          ),
          const SizedBox(height: 16),
          _buildGrowthItem(
            'Doanh thu',
            statistics.growthRates.revenue,
            Icons.trending_up,
            textColor,
          ),
          const SizedBox(height: 12),
          _buildGrowthItem(
            'Đơn hàng',
            statistics.growthRates.orders,
            Icons.shopping_cart,
            textColor,
          ),
          const SizedBox(height: 12),
          _buildGrowthItem(
            'Khách hàng',
            statistics.growthRates.newCustomers,
            Icons.people,
            textColor,
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthItem(String title, double percentage, IconData icon, Color textColor) {
    final isPositive = percentage >= 0;
    final color = isPositive ? Colors.green : Colors.red;
    
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: Style.fontContent.copyWith(color: textColor),
          ),
        ),
        Row(
          children: [
            Icon(
              isPositive ? Icons.arrow_upward : Icons.arrow_downward,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              '${percentage.abs().toStringAsFixed(1)}%',
              style: Style.fontContent.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummarySection(BranchMetrics statistics, bool isDark) {
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
            'Tóm tắt báo cáo',
            style: Style.fontTitle.copyWith(fontSize: 18, color: textColor),
          ),
          const SizedBox(height: 16),
          _buildSummaryItem(
            'Kỳ báo cáo',
            statistics.period,
            textColor,
          ),
          const SizedBox(height: 8),
          _buildSummaryItem(
            'Thời gian',
            statistics.dateRange,
            textColor,
          ),
          const SizedBox(height: 8),
          _buildSummaryItem(
            'Mức độ hài lòng',
            '${statistics.customerSatisfaction.toStringAsFixed(1)}/5.0',
            textColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color textColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: Style.fontContent.copyWith(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        const Text(': '),
        Expanded(
          child: Text(
            value,
            style: Style.fontContent.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }



  // Empty state khi không có dữ liệu trong ngày
  Widget _buildEmptyDataState(bool isDark) {
    final cardColor = isDark ? const Color(0xFF2D2D2D) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
            child: const Icon(
              Icons.analytics_outlined,
              size: 40,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chưa có dữ liệu thống kê',
            style: Style.fontTitle.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Hệ thống chưa ghi nhận hoạt động nào\ntrong ngày hôm nay. Hãy bắt đầu nhận đơn hàng!',
            textAlign: TextAlign.center,
            style: Style.fontContent.copyWith(
              color: textColor.withOpacity(0.7),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  final branchIdInt = ref.read(currentBranchIdProvider)!;
                  // ignore: unused_result
                  ref.refresh(branchStatisticsProvider(branchIdInt));
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Làm mới'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Quay lại'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Order chart giống như trong ảnh Dashboard
  Widget _buildOrderChart(BranchMetrics statistics, bool isDark) {
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    
    return Container(
      padding: const EdgeInsets.all(20),
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
          // Header with period selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đơn hàng',
                style: Style.fontTitleMini.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  _buildPeriodButton('Tháng', false, isDark),
                  const SizedBox(width: 8),
                  _buildPeriodButton('Tuần', true, isDark),
                  const SizedBox(width: 8),
                  _buildPeriodButton('Hôm nay', false, isDark),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Bar chart area
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOrderBar('Tuần 2', 30, 100, Colors.blue),
                _buildOrderBar('Tuần 3', 80, 100, Colors.black),
                _buildOrderBar('Tuần 4', 50, 100, Colors.blue),
                _buildOrderBar('', 90, 100, Colors.black),
                _buildOrderBar('', 65, 100, Colors.blue),
                _buildOrderBar('', 85, 100, Colors.black),
              ],
            ),
          ),
          
          // Y-axis labels
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('10k', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(height: 20),
                Text('5k', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(height: 20),
                Text('1k', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(height: 20),
                Text('0', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String text, bool isSelected, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildOrderBar(String label, double value, double maxValue, Color color) {
    final height = (value / maxValue) * 150; // Max height 150
    
    return Column(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 24,
              height: height,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (label.isNotEmpty)
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11,
            ),
          ),
      ],
    );
  }
}