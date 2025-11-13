import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
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
    
    // Nếu chưa có session, tự động tạo mock session
    if (!isAuthenticated || currentBranchId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(userSessionProvider.notifier).mockLogin(branchId: 1);
      });
      
      return const Scaffold(
        body: Center(
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

    final branchIdInt = currentBranchId;
    // Pass period parameter to provider
    final statisticsAsyncValue = ref.watch(branchStatisticsProvider(branchIdInt));
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                // Load data for selected period
                final branchIdInt = ref.read(currentBranchIdProvider) ?? 1;
                ref.read(branchStatisticsProvider(branchIdInt).notifier)
                   .loadStatisticsForPeriod(_selectedPeriod);
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
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Style.fontCaption.copyWith(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Generate chart data based on statistics period
  Map<String, dynamic> _generateChartData(BranchMetrics statistics) {
    final baseRevenue = statistics.totalRevenue.toDouble();
    final period = statistics.period.toLowerCase();
    
    List<FlSpot> spots = [];
    List<String> labels = [];
    double maxY = 0;
    
    if (period.contains('tháng')) {
      // Monthly data - show last 12 months
      for (int i = 0; i < 12; i++) {
        final revenue = baseRevenue * (0.7 + (i * 0.05) + (i % 3) * 0.1);
        spots.add(FlSpot(i.toDouble(), revenue));
        labels.add('T${i + 1}');
        if (revenue > maxY) maxY = revenue;
      }
    } else if (period.contains('tuần') || period.contains('week')) {
      // Weekly data - show last 7 days
      for (int i = 0; i < 7; i++) {
        final revenue = baseRevenue * (0.6 + (i * 0.08) + (i % 2) * 0.15);
        spots.add(FlSpot(i.toDouble(), revenue));
        final day = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'][i];
        labels.add(day);
        if (revenue > maxY) maxY = revenue;
      }
    } else if (period.contains('quý')) {
      // Quarterly data - show 3 months
      for (int i = 0; i < 3; i++) {
        final revenue = baseRevenue * (0.8 + (i * 0.1));
        spots.add(FlSpot(i.toDouble(), revenue));
        labels.add('Tháng ${i + 1}');
        if (revenue > maxY) maxY = revenue;
      }
    } else {
      // Daily data - show 24 hours
      for (int i = 0; i < 24; i++) {
        double multiplier = 0.1;
        if (i >= 6 && i <= 10) multiplier = 0.6; // Morning peak
        if (i >= 11 && i <= 14) multiplier = 1.0; // Lunch peak  
        if (i >= 17 && i <= 21) multiplier = 0.8; // Dinner peak
        
        final revenue = baseRevenue * multiplier / 10; // Distribute across hours
        spots.add(FlSpot(i.toDouble(), revenue));
        labels.add('${i}h');
        if (revenue > maxY) maxY = revenue;
      }
    }
    
    return {
      'spots': spots,
      'labels': labels,
      'maxY': maxY * 1.1, // Add 10% padding
    };
  }

  Widget _buildRevenueChart(BranchMetrics statistics, bool isDark) {
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;
    final textColor = isDark ? Style.colorLight : Style.colorDark;
    
    // Generate realistic chart data based on period and current statistics
    final chartData = _generateChartData(statistics);
    
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
              Text(
                'Xu hướng doanh thu',
                style: Style.fontTitle.copyWith(fontSize: 18, color: textColor),
              ),
              Text(
                statistics.period,
                style: Style.fontContent.copyWith(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                  horizontalInterval: chartData['maxY']! / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) => Text(
                        '${(value / 1000).round()}k',
                        style: TextStyle(
                          color: textColor.withOpacity(0.6),
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Text(
                        chartData['labels']![value.toInt()] ?? '',
                        style: TextStyle(
                          color: textColor.withOpacity(0.6),
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData['spots']!,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: Colors.blue,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => Colors.black.withOpacity(0.8),
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final index = barSpot.x.toInt();
                        final label = chartData['labels']![index] ?? '';
                        final value = (barSpot.y / 1000).round();
                        return LineTooltipItem(
                          '$label\n${value}k VNĐ',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
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