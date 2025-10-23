// lib/features/admin/screen_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mart_dine/models/dashboard_model.dart';
import 'package:mart_dine/providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardDataProvider);
    final selectedFilter = ref.watch(revenueFilterProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        // ✅ ĐÃ XÓA: Real-time badge và Refresh button
      ),
      body: dashboardAsync.when(
        data:
            (data) => RefreshIndicator(
              onRefresh: () async {
                ref.read(refreshDashboardProvider)();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ ĐÃ XÓA: Summary Cards

                    // Branch Revenue Title
                    const Text(
                      'Doanh thu chi nhánh',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Branch Cards Grid
                    _buildBranchGrid(data.branches, ref),
                    const SizedBox(height: 24),

                    // Revenue Chart Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Doanh thu',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Row(
                          children: [
                            _buildFilterChip(
                              'Năm',
                              RevenueFilter.year,
                              selectedFilter,
                              ref,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'Tháng',
                              RevenueFilter.month,
                              selectedFilter,
                              ref,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              'Tuần',
                              RevenueFilter.week,
                              selectedFilter,
                              ref,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Revenue Chart
                    _buildRevenueChart(data.revenueChart, selectedFilter),
                  ],
                ),
              ),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi: $error',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => ref.read(refreshDashboardProvider)(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  // ==================== BRANCH GRID ====================

  Widget _buildBranchGrid(List<BranchRevenueData> branches, WidgetRef ref) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: branches.length,
      itemBuilder: (context, index) {
        return _buildBranchCard(branches[index], index, ref);
      },
    );
  }

  Widget _buildBranchCard(BranchRevenueData branch, int index, WidgetRef ref) {
    final colors = [
      Colors.indigo[700]!,
      Colors.purple[700]!,
      Colors.teal[700]!,
      Colors.orange[700]!,
    ];

    return GestureDetector(
      onTap: () {
        ref.read(selectedBranchProvider.notifier).state = branch.branchId;
        // TODO: Navigate to branch details
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors[index % 4], colors[index % 4].withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors[index % 4].withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              branch.revenueFormatted,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '${branch.orderCount} đơn',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const Spacer(),
            Text(
              branch.branchName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.9),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            if (!branch.hasData)
              Text(
                'Không có dữ liệu',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              )
            else
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '0%',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        branch.percentageFormatted,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: branch.percentage / 100,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ==================== FILTER CHIPS ====================

  Widget _buildFilterChip(
    String label,
    RevenueFilter filter,
    RevenueFilter selectedFilter,
    WidgetRef ref,
  ) {
    final isSelected = selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        ref.read(changeFilterProvider)(filter);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[700] : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  // ==================== REVENUE CHART ====================

  Widget _buildRevenueChart(
    List<RevenuePoint> chartData,
    RevenueFilter filter,
  ) {
    if (chartData.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: const Text('Không có dữ liệu'),
      );
    }

    final maxY = chartData.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
    final roundedMaxY = ((maxY / 100).ceil() * 100).toDouble();

    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: roundedMaxY / 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(color: Colors.grey[200]!, strokeWidth: 1);
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                interval: roundedMaxY / 4,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < chartData.length) {
                    return Text(
                      chartData[index].label,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                chartData.length,
                (index) => FlSpot(index.toDouble(), chartData[index].amount),
              ),
              isCurved: true,
              curveSmoothness: 0.4,
              color: Colors.blue[700],
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  if (index == chartData.length - 1) {
                    return FlDotCirclePainter(
                      radius: 6,
                      color: Colors.blue[700]!,
                      strokeWidth: 3,
                      strokeColor: Colors.white,
                    );
                  }
                  return FlDotCirclePainter(
                    radius: 0,
                    color: Colors.transparent,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.blue[700]!.withOpacity(0.3),
                    Colors.blue[700]!.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          minY: 0,
          maxY: roundedMaxY,
          minX: 0,
          maxX: (chartData.length - 1).toDouble(),
        ),
      ),
    );
  }
}
