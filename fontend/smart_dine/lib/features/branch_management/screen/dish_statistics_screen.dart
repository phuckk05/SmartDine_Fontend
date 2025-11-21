import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/widgets/appbar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import '../../../providers/user_session_provider.dart';
import '../../../providers/dish_statistics_provider.dart';

class DishStatisticsScreen extends ConsumerStatefulWidget {
  final bool showBackButton;
  
  const DishStatisticsScreen({super.key, this.showBackButton = true});

  @override
  ConsumerState<DishStatisticsScreen> createState() => _DishStatisticsScreenState();
}

class _DishStatisticsScreenState extends ConsumerState<DishStatisticsScreen> {
  String _selectedFilter = 'Tuần';
  int _touchedIndex = -1;

  String _getXLabel(double value, String filter) {
    if (filter == 'Năm') {
      return 'T${value.toInt()}';
    } else if (filter == 'Tháng') {
      return 'Tuần ${value.toInt()}';
    } else if (filter == 'Tuần') {
      const days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
      return value.toInt() <= days.length ? days[value.toInt() - 1] : '';
    } else {
      const hours = ['6h', '9h', '12h', '15h', '18h', '21h'];
      return value.toInt() < hours.length ? hours[value.toInt()] : '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Style.colorLight : Style.colorDark;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    // Kiểm tra user session
    final currentBranchId = ref.watch(currentBranchIdProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    
    if (!isAuthenticated) {
      return Scaffold(
        backgroundColor: isDark ? Colors.grey[850] : Style.backgroundColor,
        appBar: widget.showBackButton 
          ? AppBarCus(
              title: 'Thống kê món',
              isCanpop: true,
              isButtonEnabled: true,
            )
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text('Thống kê món', style: Style.fontTitle),
              automaticallyImplyLeading: false,
            ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Vui lòng đăng nhập để xem thống kê'),
            ],
          ),
        ),
      );
    }
    
    if (currentBranchId == null) {
      return Scaffold(
        backgroundColor: isDark ? Colors.grey[850] : Style.backgroundColor,
        appBar: widget.showBackButton 
          ? AppBarCus(
              title: 'Thống kê món',
              isCanpop: true,
              isButtonEnabled: true,
            )
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text('Thống kê món', style: Style.fontTitle),
              automaticallyImplyLeading: false,
            ),
        body: _buildEmptyState(isDark, cardColor, textColor),
      );
    }

    // Watch dish statistics data
    final dishStatisticsAsync = ref.watch(dishStatisticsProvider(currentBranchId));

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[850] : Style.backgroundColor,
      appBar: widget.showBackButton 
        ? AppBarCus(
            title: 'Thống kê món',
            isCanpop: true,
            isButtonEnabled: true,
          )
        : AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text('Thống kê món', style: Style.fontTitle),
            automaticallyImplyLeading: false,
          ),
      body: dishStatisticsAsync.when(
        loading: () => _buildLoadingSkeleton(isDark, cardColor, textColor),
        error: (error, stackTrace) => _buildErrorState(error, isDark, cardColor, textColor, currentBranchId),
        data: (data) => data?.isEmpty == true 
          ? _buildEmptyState(isDark, cardColor, textColor)
          : _buildContent(data ?? DishStatisticsData(dishRevenueList: [], chartData: {}, totalDishes: 0, totalRevenue: 0.0), isDark, cardColor, textColor, currentBranchId, isMobile),
      ),
    );
  }

  Widget _buildContent(DishStatisticsData data, bool isDark, Color cardColor, Color textColor, int branchId, bool isMobile) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(dishStatisticsProvider(branchId).notifier).refresh(period: _selectedFilter.toLowerCase());
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterChip('Năm', _selectedFilter == 'Năm', isDark, textColor, () {
                  setState(() {
                    _selectedFilter = 'Năm';
                  });
                  ref.read(dishStatisticsProvider(branchId).notifier).changePeriod('year');
                }),
                _buildFilterChip('Tháng', _selectedFilter == 'Tháng', isDark, textColor, () {
                  setState(() {
                    _selectedFilter = 'Tháng';
                  });
                  ref.read(dishStatisticsProvider(branchId).notifier).changePeriod('month');
                }),
                _buildFilterChip('Tuần', _selectedFilter == 'Tuần', isDark, textColor, () {
                  setState(() {
                    _selectedFilter = 'Tuần';
                  });
                  ref.read(dishStatisticsProvider(branchId).notifier).changePeriod('week');
                }),
                _buildFilterChip('Hôm nay', _selectedFilter == 'Hôm nay', isDark, textColor, () {
                  setState(() {
                    _selectedFilter = 'Hôm nay';
                  });
                  ref.read(dishStatisticsProvider(branchId).notifier).changePeriod('today');
                }),
              ],
            ),
            const SizedBox(height: 24),

            // Biểu đồ món bán chạy
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Số món bán theo ${_selectedFilter.toLowerCase()}',
                    style: Style.fontTitleMini.copyWith(color: textColor),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: isMobile ? 180 : 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _getMaxY(data, _selectedFilter),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (group) => Colors.black.withOpacity(0.8),
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              String label = _getXLabel(group.x.toDouble(), _selectedFilter);
                              return BarTooltipItem(
                                '$label\n${rod.toY.toInt()} món',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                          touchCallback: (FlTouchEvent event, barTouchResponse) {
                            setState(() {
                              if (barTouchResponse != null &&
                                  barTouchResponse.spot != null &&
                                  event is! PointerUpEvent) {
                                _touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                              } else {
                                _touchedIndex = -1;
                              }
                            });
                          },
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: Style.fontCaption.copyWith(
                                    color: isDark ? Colors.grey[400] : Style.textColorGray,
                                    fontSize: 10,
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _getXLabel(value, _selectedFilter),
                                    style: Style.fontCaption.copyWith(
                                      color: isDark ? Colors.grey[400] : Style.textColorGray,
                                      fontSize: 9,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: _buildBarChartGroups(data, _selectedFilter),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bảng thống kê
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
                  _buildTableHeader(textColor),
                  const Divider(height: 1),
                  ...data.dishRevenueList.map((dish) => _buildTableRow(
                    dish['name'] ?? '',
                    dish['revenue'] ?? '0',
                    dish['total'] ?? '0',
                    dish['sold'] ?? '0',
                    dish['remaining'] ?? '0',
                    dish['percentage'] ?? '0%',
                    textColor,
                  )).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, bool isDark, Color textColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.black : (isDark ? Colors.grey[600]! : Style.textColorGray),
          ),
        ),
        child: Text(
          label,
          style: Style.fontNormal.copyWith(
            color: isSelected ? Colors.white : textColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader(Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Tên món',
              style: Style.fontCaption.copyWith(
                color: Style.textColorGray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Doanh thu',
              style: Style.fontCaption.copyWith(
                color: Style.textColorGray,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'Số bán',
              style: Style.fontCaption.copyWith(
                color: Style.textColorGray,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'Đã bán',
              style: Style.fontCaption.copyWith(
                color: Style.textColorGray,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'Tỷ lệ',
              style: Style.fontCaption.copyWith(
                color: Style.textColorGray,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(
    String name,
    String revenue,
    String total,
    String sold,
    String remaining,
    String percentage,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: Style.fontNormal.copyWith(
                color: textColor,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              revenue,
              style: Style.fontNormal.copyWith(
                color: textColor,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              total,
              style: Style.fontNormal.copyWith(
                color: textColor,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              '$sold/$remaining',
              style: Style.fontNormal.copyWith(
                color: textColor,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              percentage,
              style: Style.fontNormal.copyWith(
                color: textColor,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Empty state khi không có chi nhánh
  Widget _buildEmptyState(bool isDark, Color cardColor, Color textColor) {
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.restaurant_menu,
              size: 40,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          
          // Title
          Text(
            'Chưa có dữ liệu thống kê món',
            style: Style.fontTitle.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 12),
          
          // Subtitle
          Text(
            'Hệ thống sẽ hiển thị thống kê khi có đơn hàng.\nVui lòng đăng nhập với tài khoản có quyền truy cập chi nhánh.',
            textAlign: TextAlign.center,
            style: Style.fontContent.copyWith(
              color: textColor.withOpacity(0.7),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          
          // Button
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            label: const Text(
              'Quay lại',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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

  Widget _buildErrorState(Object error, bool isDark, Color cardColor, Color textColor, int branchId) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(dishStatisticsProvider(branchId).notifier).refresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Lỗi tải dữ liệu thống kê',
                style: Style.fontTitle.copyWith(color: textColor),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Style.fontContent.copyWith(color: textColor.withOpacity(0.7)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await ref.read(dishStatisticsProvider(branchId).notifier).refresh();
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getMaxY(DishStatisticsData data, String period) {
    if (data.chartData.containsKey(period)) {
      final chartList = data.chartData[period]!;
      if (chartList.isNotEmpty) {
        final maxValue = chartList.map((item) => (item['y'] as num).toDouble()).reduce((a, b) => a > b ? a : b);
        return maxValue * 1.2; // Add 20% padding
      }
    }
    
    // Fallback values
    switch (period) {
      case 'Năm': return 1500;
      case 'Tháng': return 400;
      case 'Tuần': return 100;
      default: return 25;
    }
  }

  List<BarChartGroupData> _buildBarChartGroups(DishStatisticsData data, String period) {
    final color = Colors.blue;
    final touchedColor = Colors.green;
    
    if (data.chartData.containsKey(period)) {
      final chartList = data.chartData[period]!;
      return chartList.map((item) {
        final x = (item['x'] as num).toInt();
        final y = (item['y'] as num).toDouble();
        return BarChartGroupData(
          x: x,
          barRods: [
            BarChartRodData(
              toY: y,
              color: _touchedIndex == (x - 1) ? touchedColor : color,
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ],
        );
      }).toList();
    }
    
    // Fallback to empty data
    return [];
  }

  Widget _buildLoadingSkeleton(bool isDark, Color cardColor, Color textColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter buttons skeleton
          Row(
            children: List.generate(4, (index) => 
              Shimmer.fromColors(
                baseColor: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                highlightColor: isDark ? Colors.grey[600]! : Colors.grey[100]!,
                child: Container(
                  width: 60,
                  height: 36,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Chart skeleton
          Shimmer.fromColors(
            baseColor: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            highlightColor: isDark ? Colors.grey[600]! : Colors.grey[100]!,
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Table skeleton
          Shimmer.fromColors(
            baseColor: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            highlightColor: isDark ? Colors.grey[600]! : Colors.grey[100]!,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
