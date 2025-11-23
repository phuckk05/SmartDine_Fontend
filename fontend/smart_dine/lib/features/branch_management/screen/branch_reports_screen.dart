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
                  _buildGrowthRatesSection(statistics, isDark),
                  const SizedBox(height: 20),
                  _buildSummarySection(statistics, isDark),
                ] else
                  const Center(
                    child: Text('Không có dữ liệu báo cáo'),
                  ),
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
}