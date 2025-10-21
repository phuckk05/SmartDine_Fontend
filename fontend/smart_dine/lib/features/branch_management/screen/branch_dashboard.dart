import 'package:flutter/material.dart';
import 'package:mart_dine/core/style.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mart_dine/features/branch_management/screen/order_list_screen.dart';
import 'package:mart_dine/features/branch_management/screen/branch_performance_screen.dart';
import 'package:mart_dine/features/branch_management/screen/today_activities_screen.dart';
import 'package:mart_dine/features/branch_management/screen/dish_statistics_screen.dart';
import '../../../services/mock_data_service.dart';
import '../../../models/statistics.dart';

class BranchDashboardScreen extends StatefulWidget {
  const BranchDashboardScreen({super.key});

  @override
  State<BranchDashboardScreen> createState() => _BranchDashboardScreenState();
}

class _BranchDashboardScreenState extends State<BranchDashboardScreen> {
  final MockDataService _mockDataService = MockDataService();
  
  // State cho filter biểu đồ doanh thu
  String _revenueFilter = 'Tuần';
  
  // State cho filter biểu đồ đơn hàng
  String _ordersFilter = 'Tuần';
  
  int _touchedRevenueIndex = -1;
  int _touchedOrderIndex = -1;
  
  // Data từ JSON
  BranchMetrics? _branchMetrics;
  List<TopDish> _topDishes = [];
  List<EmployeePerformance> _employeePerformance = [];
  bool _isLoading = true;

  // Đồng bộ dữ liệu biểu đồ doanh thu với statistics.json
  // Lưu theo filter 'Tuần' | 'Tháng'
  final Map<String, List<RevenueTrend>> _revenueTrendsMap = {};
  final Map<String, List<FlSpot>> _revenueSpotsMap = {};
  final Map<String, List<String>> _revenueLabelsMap = {};

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final results = await Future.wait([
        _mockDataService.loadBranchMetrics('monthly'),
        _mockDataService.loadTopDishes(),
        _mockDataService.loadEmployeePerformance(),
      ]);
      
      setState(() {
        _branchMetrics = results[0] as BranchMetrics;
        _topDishes = results[1] as List<TopDish>;
        _employeePerformance = results[2] as List<EmployeePerformance>;
        _isLoading = false;
      });

      // Preload dữ liệu doanh thu cho filter mặc định và tháng
      await _ensureRevenueTrendsLoaded('Tuần');
      await _ensureRevenueTrendsLoaded('Tháng');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _mapFilterToPeriodLabel(String filter) {
    switch (filter) {
      case 'Tuần':
        return 'Tuần này';
      case 'Tháng':
        return 'Tháng này';
      default:
        return 'Tuần này';
    }
  }

  Future<void> _ensureRevenueTrendsLoaded(String filter) async {
    if (filter == 'Hôm nay') return; // không có trong statistics.json, giữ mock
    if (_revenueTrendsMap.containsKey(filter)) return;

    final periodLabel = _mapFilterToPeriodLabel(filter);
    final trends = await _mockDataService.loadRevenueTrends(periodLabel);

    final labels = trends.map((e) => e.period).toList();
    final spots = <FlSpot>[];
    for (int i = 0; i < trends.length; i++) {
      final t = trends[i];
      final y = t.revenue / 1000000.0; // đổi sang triệu
      spots.add(FlSpot((i + 1).toDouble(), y));
    }

    setState(() {
      _revenueTrendsMap[filter] = trends;
      _revenueLabelsMap[filter] = labels;
      _revenueSpotsMap[filter] = spots;
    });
  }

  // Dữ liệu biểu đồ doanh thu theo filter (triệu đồng)
  Map<String, List<FlSpot>> _getRevenueData() {
    return {
      'Tháng': [
        FlSpot(1, 120), FlSpot(2, 150), FlSpot(3, 135), FlSpot(4, 180),
        FlSpot(5, 165), FlSpot(6, 200), FlSpot(7, 185), FlSpot(8, 220),
        FlSpot(9, 245), FlSpot(10, 280), FlSpot(11, 310), FlSpot(12, 350),
      ],
      'Tuần': [
        FlSpot(1, 45), FlSpot(2, 65), FlSpot(3, 85), FlSpot(4, 120),
        FlSpot(5, 95), FlSpot(6, 140), FlSpot(7, 165),
      ],
      'Hôm nay': [
        FlSpot(6, 5), FlSpot(9, 12), FlSpot(12, 35), FlSpot(15, 28),
        FlSpot(18, 45), FlSpot(21, 38),
      ],
    };
  }

  // Dữ liệu biểu đồ đơn hàng theo filter (đồng bộ với statistics.json)
  List<BarChartGroupData> _getOrdersData(String filter) {
    final baseColor = Colors.blue;
    final touchedColor = Colors.green;

    // Hôm nay: giữ mock nội bộ cho demo
    if (filter == 'Hôm nay') {
      final values = [2.0, 5.0, 12.0, 8.0, 15.0, 10.0];
      return List.generate(values.length, (index) {
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: values[index],
              color: _touchedOrderIndex == index ? touchedColor : baseColor,
              width: 24,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ],
        );
      });
    }

    final trends = _revenueTrendsMap[filter] ?? const <RevenueTrend>[];
    return List.generate(trends.length, (index) {
      final orders = trends[index].orders.toDouble();
      return BarChartGroupData(
        x: index + 1,
        barRods: [
          BarChartRodData(
            toY: orders,
            color: _touchedOrderIndex == index ? touchedColor : baseColor,
            width: filter == 'Tuần' ? 20 : 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      );
    });
  }

  // Lấy nhãn cho trục X theo filter
  String _getRevenueXLabel(double value, String filter) {
    if (filter == 'Tháng') {
      const months = ['T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9', 'T10', 'T11', 'T12'];
      return value.toInt() <= months.length ? months[value.toInt() - 1] : '';
    } else if (filter == 'Tuần') {
      const days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
      return value.toInt() <= days.length ? days[value.toInt() - 1] : '';
    } else {
      const hours = ['6h', '9h', '12h', '15h', '18h', '21h'];
      return value.toInt() < hours.length ? hours[value.toInt()] : '';
    }
  }

  String _getOrdersXLabel(double value, String filter) {
    if (filter == 'Hôm nay') {
      const hours = ['6h', '9h', '12h', '15h', '18h', '21h'];
      return value.toInt() < hours.length ? hours[value.toInt()] : '';
    }
    final labels = _revenueLabelsMap[filter] ?? const <String>[];
    final idx = value.toInt() - 1;
    return (idx >= 0 && idx < labels.length) ? labels[idx] : '';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Style.colorLight : Style.colorDark;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[850] : Style.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Dashboard', style: Style.fontTitle),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Restaurant Info Card
              _buildRestaurantCard(isDark, cardColor, textColor, context),
              const SizedBox(height: 20),

              // Branch Stats
              _buildBranchStats(isDark, cardColor, textColor),
              const SizedBox(height: 20),

              // Revenue Chart
              _buildRevenueChart(isDark, cardColor, textColor, _revenueFilter),
              const SizedBox(height: 20),

              // Orders Chart
              _buildOrdersChart(isDark, cardColor, textColor, _ordersFilter),
              const SizedBox(height: 20),

              // Dish Statistics
              _buildDishStatistics(isDark, cardColor, textColor),
              const SizedBox(height: 20),

              // Employee Performance
              _buildEmployeePerformance(isDark, cardColor, textColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantCard(bool isDark, Color cardColor, Color textColor, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Restaurant NHOM7',
            style: Style.fontTitleMini.copyWith(color: textColor),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(Icons.calendar_today, 'Xem đơn', isDark, textColor, context, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrderListScreen()),
                );
              }),
              _buildStatItem(Icons.bar_chart, 'Thống kê món', isDark, textColor, context, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DishStatisticsScreen()),
                );
              }),
              _buildStatItem(Icons.check_circle_outline, 'Xem hiệu xuất', isDark, textColor, context, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BranchPerformanceScreen()),
                );
              }),
              _buildStatItem(Icons.location_on_outlined, 'Xem hoạt động', isDark, textColor, context, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TodayActivitiesScreen()),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    bool isDark,
    Color textColor,
    BuildContext context,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Style.backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 24, color: textColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Style.fontCaption.copyWith(
              fontSize: 10,
              color: isDark ? Colors.grey[400] : Style.textColorGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBranchStats(bool isDark, Color cardColor, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hiệu suất chi nhánh',
          style: Style.fontTitleMini.copyWith(color: textColor),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Doanh thu tháng này',
                '${((_branchMetrics?.totalRevenue ?? 0) / 1000000).toStringAsFixed(1)}M đ',
                '↑ ${_branchMetrics?.growthRates.revenue.toStringAsFixed(1) ?? '0.0'}%',
                (_branchMetrics?.growthRates.revenue ?? 0) >= 0 ? Colors.green : Colors.red,
                isDark,
                cardColor,
                textColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Số đơn hàng',
                '${(_branchMetrics?.totalOrders ?? 0).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                '↑ ${_branchMetrics?.growthRates.orders.toStringAsFixed(1) ?? '0.0'}%',
                (_branchMetrics?.growthRates.orders ?? 0) >= 0 ? Colors.green : Colors.red,
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
                'Khách hàng mới',
                '${_branchMetrics?.newCustomers ?? 0}',
                '↑ ${_branchMetrics?.growthRates.newCustomers.toStringAsFixed(1) ?? '0.0'}%',
                (_branchMetrics?.growthRates.newCustomers ?? 0) >= 0 ? Colors.green : Colors.red,
                isDark,
                cardColor,
                textColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Mức độ hài lòng',
                '${_branchMetrics?.customerSatisfaction.toStringAsFixed(1) ?? '0.0'}/5.0 ⭐',
                '↑ ${_branchMetrics?.growthRates.satisfaction.toStringAsFixed(1) ?? '0.0'}%',
                (_branchMetrics?.growthRates.satisfaction ?? 0) >= 0 ? Colors.green : Colors.red,
                isDark,
                cardColor,
                textColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String period, String percentage, String change, Color changeColor, bool isDark, Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            period,
            style: Style.fontCaption.copyWith(
              color: isDark ? Colors.grey[400] : Style.textColorGray,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            percentage,
            style: Style.fontTitleMini.copyWith(color: textColor),
          ),
          const SizedBox(height: 4),
          Text(
            change,
            style: Style.fontNormal.copyWith(
              color: changeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart(bool isDark, Color cardColor, Color textColor, String selectedFilter) {
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
                'Doanh thu',
                style: Style.fontTitleMini.copyWith(color: textColor),
              ),
              Row(
                children: [
                  _buildChipButton('Tháng', selectedFilter == 'Tháng', isDark, textColor, () async {
                    setState(() { _revenueFilter = 'Tháng'; });
                    await _ensureRevenueTrendsLoaded('Tháng');
                  }),
                  const SizedBox(width: 8),
                  _buildChipButton('Tuần', selectedFilter == 'Tuần', isDark, textColor, () async {
                    setState(() { _revenueFilter = 'Tuần'; });
                    await _ensureRevenueTrendsLoaded('Tuần');
                  }),
                  const SizedBox(width: 8),
                  _buildChipButton('Hôm nay', selectedFilter == 'Hôm nay', isDark, textColor, () {
                    setState(() {
                      _revenueFilter = 'Hôm nay';
                    });
                  }),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => Colors.black.withValues(alpha: 0.8),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        String label;
                        if (selectedFilter == 'Hôm nay') {
                          label = _getRevenueXLabel(spot.x, selectedFilter);
                        } else {
                          final idx = spot.x.toInt() - 1;
                          final labels = _revenueLabelsMap[selectedFilter] ?? const [];
                          label = (idx >= 0 && idx < labels.length) ? labels[idx] : '';
                        }
                        return LineTooltipItem(
                          '$label\n${spot.y.toInt()} triệu đ',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                  touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                    if (response != null && response.lineBarSpots != null) {
                      setState(() {
                        _touchedRevenueIndex = response.lineBarSpots!.first.spotIndex;
                      });
                    } else {
                      setState(() {
                        _touchedRevenueIndex = -1;
                      });
                    }
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}m',
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
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _getRevenueXLabel(value, selectedFilter),
                            style: Style.fontCaption.copyWith(
                              color: isDark ? Colors.grey[400] : Style.textColorGray,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: selectedFilter == 'Hôm nay'
                    ? _getRevenueData()[selectedFilter]!.first.x
                    : 1,
                maxX: selectedFilter == 'Hôm nay'
                    ? _getRevenueData()[selectedFilter]!.last.x
                    : (_revenueSpotsMap[selectedFilter]?.length ?? 1).toDouble(),
                minY: 0,
                maxY: () {
                  if (selectedFilter == 'Hôm nay') {
                    return 50.0;
                  }
                  final spots = _revenueSpotsMap[selectedFilter] ?? const <FlSpot>[];
                  if (spots.isEmpty) return 50.0;
                  final maxVal = spots.map((s) => s.y).fold<double>(0, (a, b) => a > b ? a : b);
                  // thêm headroom ~15%
                  return (maxVal * 1.15);
                }(),
                lineBarsData: [
                  LineChartBarData(
                    spots: selectedFilter == 'Hôm nay'
                        ? _getRevenueData()[selectedFilter]!
                        : (_revenueSpotsMap[selectedFilter] ?? const <FlSpot>[]),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: _touchedRevenueIndex == index ? 6 : 4,
                          color: _touchedRevenueIndex == index ? Colors.green : Colors.blue,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersChart(bool isDark, Color cardColor, Color textColor, String selectedFilter) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                'Đơn hàng',
                style: Style.fontTitleMini.copyWith(color: textColor),
              ),
              Row(
                children: [
                  _buildChipButton('Tháng', selectedFilter == 'Tháng', isDark, textColor, () async {
                    setState(() { _ordersFilter = 'Tháng'; });
                    await _ensureRevenueTrendsLoaded('Tháng');
                  }),
                  const SizedBox(width: 8),
                  _buildChipButton('Tuần', selectedFilter == 'Tuần', isDark, textColor, () async {
                    setState(() { _ordersFilter = 'Tuần'; });
                    await _ensureRevenueTrendsLoaded('Tuần');
                  }),
                  const SizedBox(width: 8),
                  _buildChipButton('Hôm nay', selectedFilter == 'Hôm nay', isDark, textColor, () {
                    setState(() {
                      _ordersFilter = 'Hôm nay';
                    });
                  }),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: () {
                  if (selectedFilter == 'Hôm nay') return 16.0;
                  final trends = _revenueTrendsMap[selectedFilter] ?? const <RevenueTrend>[];
                  if (trends.isEmpty) return 10.0;
                  final maxVal = trends.map((t) => t.orders).fold<int>(0, (a, b) => a > b ? a : b).toDouble();
                  return maxVal * 1.15; // headroom 15%
                }(),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.black.withValues(alpha: 0.8),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String label = _getOrdersXLabel(group.x.toDouble(), selectedFilter);
                      return BarTooltipItem(
                        '$label\n${rod.toY.toInt()} đơn',
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
                        _touchedOrderIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                      } else {
                        _touchedOrderIndex = -1;
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
                          '${value.toInt()}',
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
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _getOrdersXLabel(value, selectedFilter),
                            style: Style.fontCaption.copyWith(
                              color: isDark ? Colors.grey[400] : Style.textColorGray,
                              fontSize: 10,
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
                barGroups: _getOrdersData(selectedFilter),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipButton(String label, bool isSelected, bool isDark, Color textColor, VoidCallback onTap) {
    Color selectedColor = label == 'Tuần'
        ? Colors.green
        : label == 'Tháng'
            ? Colors.blue
            : Colors.purple;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? selectedColor : (isDark ? Colors.grey[600]! : Style.textColorGray),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Icon(
                label == 'Tuần'
                    ? Icons.calendar_view_week
                    : label == 'Tháng'
                        ? Icons.calendar_view_month
                        : Icons.calendar_today,
                color: Colors.white,
                size: 14,
              ),
            if (isSelected) const SizedBox(width: 4),
            Text(
              label,
              style: Style.fontNormal.copyWith(
                color: isSelected ? Colors.white : textColor,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDishStatistics(bool isDark, Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                'Thống kê món ăn',
                style: Style.fontTitleMini.copyWith(color: textColor),
              ),
              Icon(
                Icons.bar_chart,
                color: isDark ? Colors.grey[400] : Style.textColorGray,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Pie Chart for top dishes
          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: _getDishPieChartSections(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _topDishes.isEmpty ? [] : _topDishes.take(5).toList().asMap().entries.map((entry) {
                      final dish = entry.value;
                      final colors = [Colors.blue, Colors.orange, Colors.green, Colors.red, Colors.purple];
                      final totalOrders = _topDishes.fold<int>(0, (sum, d) => sum + d.ordersCount);
                      final percentage = (dish.ordersCount / totalOrders * 100).toStringAsFixed(0);
                      
                      return _buildDishLegendItem(
                        dish.name, 
                        colors[entry.key % colors.length], 
                        '$percentage%', 
                        isDark, 
                        textColor
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          
          // Dish statistics table
          Text(
            'Chi tiết món ăn',
            style: Style.fontTitleMini.copyWith(
              color: textColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildDishStatsTable(isDark, textColor),
        ],
      ),
    );
  }

  Widget _buildDishLegendItem(String name, Color color, String percentage, bool isDark, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: Style.fontNormal.copyWith(
                color: textColor,
                fontSize: 12,
              ),
            ),
          ),
          Text(
            percentage,
            style: Style.fontNormal.copyWith(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDishStatsTable(bool isDark, Color textColor) {

    return Column(
      children: [
        // Table header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text('Món ăn', style: Style.fontCaption.copyWith(color: textColor, fontWeight: FontWeight.w600, fontSize: 11))),
              Expanded(flex: 2, child: Text('Loại', style: Style.fontCaption.copyWith(color: textColor, fontWeight: FontWeight.w600, fontSize: 11))),
              Expanded(flex: 2, child: Text('Đã bán', style: Style.fontCaption.copyWith(color: textColor, fontWeight: FontWeight.w600, fontSize: 11))),
              Expanded(flex: 3, child: Text('Doanh thu', style: Style.fontCaption.copyWith(color: textColor, fontWeight: FontWeight.w600, fontSize: 11))),
              Expanded(flex: 2, child: Text('Tăng trưởng', style: Style.fontCaption.copyWith(color: textColor, fontWeight: FontWeight.w600, fontSize: 11))),
            ],
          ),
        ),
        const SizedBox(height: 8),
        
        // Table rows
        ..._topDishes.take(5).map((dish) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  dish.name,
                  style: Style.fontNormal.copyWith(color: textColor, fontSize: 12),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  dish.category,
                  style: Style.fontCaption.copyWith(color: isDark ? Colors.grey[400] : Style.textColorGray, fontSize: 11),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  dish.ordersCount.toString(),
                  style: Style.fontNormal.copyWith(color: textColor, fontSize: 12),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  '${dish.totalRevenue.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ',
                  style: Style.fontNormal.copyWith(color: textColor, fontSize: 12),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '${dish.growthRate >= 0 ? '+' : ''}${dish.growthRate.toStringAsFixed(0)}%',
                  style: Style.fontNormal.copyWith(
                    color: dish.growthRate >= 0 ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  List<PieChartSectionData> _getDishPieChartSections() {
    if (_topDishes.isEmpty) return [];
    
    final totalOrders = _topDishes.fold<int>(0, (sum, dish) => sum + dish.ordersCount);
    final colors = [Colors.blue, Colors.orange, Colors.green, Colors.red, Colors.purple];
    
    return _topDishes.take(5).toList().asMap().entries.map((entry) {
      final percentage = (entry.value.ordersCount / totalOrders * 100);
      return PieChartSectionData(
        color: colors[entry.key % colors.length],
        value: percentage,
        title: '',
        radius: 25,
      );
    }).toList();
  }

  Widget _buildEmployeePerformance(bool isDark, Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                'Hiệu xuất nhân viên',
                style: Style.fontTitleMini.copyWith(color: textColor),
              ),
              Icon(
                Icons.people_outline,
                color: isDark ? Colors.grey[400] : Style.textColorGray,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Performance chart
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.black.withValues(alpha: 0.8),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final employees = ['An', 'Bình', 'Chi', 'Dũng', 'Em'];
                      return BarTooltipItem(
                        '${employees[group.x.toInt()]}\n${rod.toY.toInt()}%',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
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
                        final employees = ['An', 'Bình', 'Chi', 'Dũng', 'Em'];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            employees[value.toInt()],
                            style: Style.fontCaption.copyWith(
                              color: isDark ? Colors.grey[400] : Style.textColorGray,
                              fontSize: 10,
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
                barGroups: _getEmployeePerformanceData(),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          
          // Employee performance table
          Text(
            'Chi tiết hiệu xuất',
            style: Style.fontTitleMini.copyWith(
              color: textColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildEmployeePerformanceTable(isDark, textColor),
        ],
      ),
    );
  }

  Widget _buildEmployeePerformanceTable(bool isDark, Color textColor) {

    return Column(
      children: [
        // Table header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text('Nhân viên', style: Style.fontCaption.copyWith(color: textColor, fontWeight: FontWeight.w600, fontSize: 11))),
              Expanded(flex: 2, child: Text('Vị trí', style: Style.fontCaption.copyWith(color: textColor, fontWeight: FontWeight.w600, fontSize: 11))),
              Expanded(flex: 2, child: Text('Đơn hàng', style: Style.fontCaption.copyWith(color: textColor, fontWeight: FontWeight.w600, fontSize: 11))),
              Expanded(flex: 2, child: Text('Đánh giá', style: Style.fontCaption.copyWith(color: textColor, fontWeight: FontWeight.w600, fontSize: 11))),
              Expanded(flex: 2, child: Text('Hiệu xuất', style: Style.fontCaption.copyWith(color: textColor, fontWeight: FontWeight.w600, fontSize: 11))),
            ],
          ),
        ),
        const SizedBox(height: 8),
        
        // Table rows
        ..._employeePerformance.take(5).map((employee) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  employee.name,
                  style: Style.fontNormal.copyWith(color: textColor, fontSize: 12),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  employee.position,
                  style: Style.fontCaption.copyWith(color: isDark ? Colors.grey[400] : Style.textColorGray, fontSize: 11),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  employee.ordersServed.toString(),
                  style: Style.fontNormal.copyWith(color: textColor, fontSize: 12),
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange, size: 12),
                    const SizedBox(width: 2),
                    Text(
                      employee.rating.toString(),
                      style: Style.fontNormal.copyWith(color: textColor, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '${employee.efficiency}%',
                  style: Style.fontNormal.copyWith(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  List<BarChartGroupData> _getEmployeePerformanceData() {
    return [
      BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 95, color: Colors.blue, width: 16)]),
      BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 92, color: Colors.green, width: 16)]),
      BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 88, color: Colors.orange, width: 16)]),
      BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 85, color: Colors.purple, width: 16)]),
      BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 82, color: Colors.red, width: 16)]),
    ];
  }
}