import 'package:flutter/material.dart';
import 'package:mart_dine/core/style.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mart_dine/features/branch_management/screen/order_list_screen.dart';
import 'package:mart_dine/features/branch_management/screen/branch_performance_screen.dart';
import 'package:mart_dine/features/branch_management/screen/settings_screen.dart';
import 'package:mart_dine/features/branch_management/screen/notifications_screen.dart';
import 'package:mart_dine/features/branch_management/screen/today_activities_screen.dart';
import 'package:mart_dine/features/branch_management/screen/dish_statistics_screen.dart';

class BranchDashboardScreen extends StatefulWidget {
  const BranchDashboardScreen({super.key});

  @override
  State<BranchDashboardScreen> createState() => _BranchDashboardScreenState();
}

class _BranchDashboardScreenState extends State<BranchDashboardScreen> {
  // State cho filter biểu đồ doanh thu
  String _revenueFilter = 'Tuần';
  
  // State cho filter biểu đồ đơn hàng
  String _ordersFilter = 'Tuần';
  
  int _touchedRevenueIndex = -1;
  int _touchedOrderIndex = -1;

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

  // Dữ liệu biểu đồ đơn hàng theo filter
  List<BarChartGroupData> _getOrdersData(String filter) {
    final color = Colors.blue;
    final touchedColor = Colors.green;
    
    if (filter == 'Tháng') {
      final values = [42.0, 55.0, 48.0, 65.0, 58.0, 75.0, 68.0, 82.0, 88.0, 95.0, 102.0, 115.0];
      return List.generate(12, (index) {
        return BarChartGroupData(
          x: index + 1,
          barRods: [
            BarChartRodData(
              toY: values[index],
              color: _touchedOrderIndex == index ? touchedColor : color,
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ],
        );
      });
    } else if (filter == 'Tuần') {
      final values = [18.0, 25.0, 32.0, 45.0, 38.0, 52.0, 60.0];
      return List.generate(7, (index) {
        return BarChartGroupData(
          x: index + 1,
          barRods: [
            BarChartRodData(
              toY: values[index],
              color: _touchedOrderIndex == index ? touchedColor : color,
              width: 20,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ],
        );
      });
    } else {
      final values = [2.0, 5.0, 12.0, 8.0, 15.0, 10.0];
      return List.generate(6, (index) {
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: values[index],
              color: _touchedOrderIndex == index ? touchedColor : color,
              width: 24,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ],
        );
      });
    }
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
    if (filter == 'Tháng') {
      return 'T${value.toInt()}';
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
    
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[850] : Style.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Dashboard', style: Style.fontTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: textColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: textColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
          ),
        ],
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
          'Các chi tiêu',
          style: Style.fontTitleMini.copyWith(color: textColor),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '23/4/2025 - 28/4/2025',
                '38%',
                '↓ 4%',
                Colors.red,
                isDark,
                cardColor,
                textColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '23/4/2025 - 23/6/2025',
                '49%',
                '↑ 1%',
                Colors.green,
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
                  _buildChipButton('Tháng', selectedFilter == 'Tháng', isDark, textColor, () {
                    setState(() {
                      _revenueFilter = 'Tháng';
                    });
                  }),
                  const SizedBox(width: 8),
                  _buildChipButton('Tuần', selectedFilter == 'Tuần', isDark, textColor, () {
                    setState(() {
                      _revenueFilter = 'Tuần';
                    });
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
                    getTooltipColor: (touchedSpot) => Colors.black.withOpacity(0.8),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        String label = _getRevenueXLabel(spot.x, selectedFilter);
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
                minX: _getRevenueData()[selectedFilter]!.first.x,
                maxX: _getRevenueData()[selectedFilter]!.last.x,
                minY: 0,
                maxY: selectedFilter == 'Tháng' ? 400 : (selectedFilter == 'Tuần' ? 200 : 50),
                lineBarsData: [
                  LineChartBarData(
                    spots: _getRevenueData()[selectedFilter]!,
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
                      color: Colors.blue.withOpacity(0.1),
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
                'Đơn hàng',
                style: Style.fontTitleMini.copyWith(color: textColor),
              ),
              Row(
                children: [
                  _buildChipButton('Tháng', selectedFilter == 'Tháng', isDark, textColor, () {
                    setState(() {
                      _ordersFilter = 'Tháng';
                    });
                  }),
                  const SizedBox(width: 8),
                  _buildChipButton('Tuần', selectedFilter == 'Tuần', isDark, textColor, () {
                    setState(() {
                      _ordersFilter = 'Tuần';
                    });
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
                maxY: selectedFilter == 'Tháng' ? 120 : (selectedFilter == 'Tuần' ? 65 : 16),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.black.withOpacity(0.8),
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
}