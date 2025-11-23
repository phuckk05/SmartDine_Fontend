import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/style.dart';
import '/widgets/appbar.dart';
import 'package:fl_chart/fl_chart.dart';
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
    final trips = data.revenueByHour ?? [];

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
                    '1,845',
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
                    '165 triệu',
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
                    '1,520',
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
                    'Đánh giá TB',
                    '4.8★',
                    Icons.star,
                    Colors.amber,
                    isDark,
                    cardColor,
                    textColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            //------------------------------------------------------------------
            // Top nhân viên
            //------------------------------------------------------------------
            Text(
              'Top nhân viên',
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
                          'Số món phục vụ',
                          style: Style.fontTitleMini.copyWith(color: textColor),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Doanh thu',
                          style: Style.fontTitleMini.copyWith(color: textColor),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),

                  ...performances.map(
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
                            e['totalServed']?.toString() ?? '-',
                            style: Style.fontContent.copyWith(color: textColor),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            e['tips']?.toString() ?? '-',
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
            // Doanh thu theo giờ (Bar chart)
            //------------------------------------------------------------------
            Text(
              'Doanh thu theo giờ',
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
              child: SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 35,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor:
                            (group) => Colors.black.withOpacity(0.8),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          const hours = [
                            '6h-9h',
                            '9h-12h',
                            '12h-15h',
                            '15h-18h',
                            '18h-21h',
                            '21h-24h',
                          ];
                          String label = hours[group.x.toInt() - 1];
                          return BarTooltipItem(
                            '$label\n${rod.toY.toInt()} triệu',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(show: true),
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(
                      6,
                      (i) => _buildBarGroup(i + 1, 0),
                    ),
                  ),
                ),
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

            Row(
              children: [
                _buildTabButton('Tạo bản', false, isDark),
                const SizedBox(width: 8),
                _buildTabButton('Năm', false, isDark),
                _buildTabButton('Tháng', false, isDark),
                _buildTabButton('Tuần', true, isDark),
                _buildTabButton('Hôm nay', false, isDark),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ...performances.map(
                    (employee) => Column(
                      children: [
                        _buildEmployeeRow(
                          employee['name'] ?? '-',
                          employee['totalServed']?.toString() ?? '-',
                          employee['tips']?.toString() ?? '-',
                          employee['rating']?.toString() ?? '-',
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

            const SizedBox(height: 24),

            //------------------------------------------------------------------
            // Trips thức chart
            //------------------------------------------------------------------
            Text(
              'Trips thức',
              style: Style.fontTitleMini.copyWith(color: textColor),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                _buildTabButton('Năm', false, isDark),
                _buildTabButton('Tháng', false, isDark),
                _buildTabButton('Tuần', true, isDark),
                _buildTabButton('Hôm nay', false, isDark),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SizedBox(
                height: 200,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ...trips.map(
                      (trip) => _buildTripsBar(
                        trip.hour,
                        (trip.revenue).toDouble(),
                        50.0,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
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

  BarChartGroupData _buildBarGroup(int x, double value) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          color: Colors.blue,
          width: 20,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ],
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

  Widget _buildTabButton(String text, bool isSelected, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color:
              isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.black54),
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildEmployeeRow(
    String name,
    String v1,
    String v2,
    String v3,
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
        Expanded(
          child: Text(
            v3,
            textAlign: TextAlign.center,
            style: TextStyle(color: textColor),
          ),
        ),
      ],
    );
  }

  Widget _buildTripsBar(
    String label,
    double value,
    double maxValue,
    Color color,
  ) {
    final height = (value / maxValue) * 150;

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
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
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
