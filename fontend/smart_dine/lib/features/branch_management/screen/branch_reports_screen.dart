import 'package:flutter/material.dart';
import 'package:mart_dine/core/style.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../services/mock_data_service.dart';
import '../../../models/statistics.dart';

class BranchReportsScreen extends StatefulWidget {
  final bool showBackButton;
  
  const BranchReportsScreen({super.key, this.showBackButton = true});

  @override
  State<BranchReportsScreen> createState() => _BranchReportsScreenState();
}

class _BranchReportsScreenState extends State<BranchReportsScreen> {
  final MockDataService _mockDataService = MockDataService();
  String _selectedPeriod = 'Tháng này';
  bool _isLoading = true;
  
  BranchMetrics? _branchMetrics;
  List<RevenueTrend> _revenueTrends = [];
  List<TopDish> _topDishes = [];
  List<EmployeePerformance> _employeePerformance = [];
  List<PeakHourData> _peakHoursData = [];
  CustomerSatisfaction? _customerSatisfaction;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final periodKey = _selectedPeriod == 'Tuần này' ? 'weekly' : 
                       _selectedPeriod == 'Tháng này' ? 'monthly' : 'quarterly';
      
      final results = await Future.wait([
        _mockDataService.loadBranchMetrics(periodKey),
        _mockDataService.loadRevenueTrends(_selectedPeriod),
        _mockDataService.loadTopDishes(),
        _mockDataService.loadEmployeePerformance(),
        _mockDataService.loadPeakHoursData(),
        _mockDataService.loadCustomerSatisfaction(),
      ]);
      
      setState(() {
        _branchMetrics = results[0] as BranchMetrics;
        _revenueTrends = results[1] as List<RevenueTrend>;
        _topDishes = results[2] as List<TopDish>;
        _employeePerformance = results[3] as List<EmployeePerformance>;
        _peakHoursData = results[4] as List<PeakHourData>;
        _customerSatisfaction = results[5] as CustomerSatisfaction;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')),
        );
      }
    }
  }

  Future<void> _onPeriodChanged(String newPeriod) async {
    setState(() {
      _selectedPeriod = newPeriod;
      _isLoading = true;
    });
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.grey[800]! : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: widget.showBackButton
          ? AppBar(
              title: Text('Báo cáo chi nhánh', style: Style.fontTitleMini),
              backgroundColor: isDark ? Colors.grey[900] : Colors.white,
              elevation: 0,
            )
          : null,
      backgroundColor: isDark ? Colors.grey[900] : Style.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Filter
            _buildPeriodFilter(isDark, cardColor, textColor),
            const SizedBox(height: 20),

            // Key Metrics Summary
            _buildKeyMetrics(isDark, cardColor, textColor),
            const SizedBox(height: 20),

            // Revenue Trend Chart
            _buildRevenueTrendChart(isDark, cardColor, textColor),
            const SizedBox(height: 20),

            // Top Dishes Performance
            _buildTopDishesReport(isDark, cardColor, textColor),
            const SizedBox(height: 20),

            // Employee Performance Report
            _buildEmployeePerformanceReport(isDark, cardColor, textColor),
            const SizedBox(height: 20),

            // Peak Hours Analysis
            _buildPeakHoursAnalysis(isDark, cardColor, textColor),
            const SizedBox(height: 20),

            // Customer Satisfaction
            _buildCustomerSatisfaction(isDark, cardColor, textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodFilter(bool isDark, Color cardColor, Color textColor) {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Báo cáo chi nhánh',
            style: Style.fontTitleMini.copyWith(color: textColor),
          ),
          Row(
            children: [
              _buildChipButton('Tuần này', _selectedPeriod == 'Tuần này', isDark, textColor, () {
                _onPeriodChanged('Tuần này');
              }),
              const SizedBox(width: 8),
              _buildChipButton('Tháng này', _selectedPeriod == 'Tháng này', isDark, textColor, () {
                _onPeriodChanged('Tháng này');
              }),
              const SizedBox(width: 8),
              _buildChipButton('Quý này', _selectedPeriod == 'Quý này', isDark, textColor, () {
                _onPeriodChanged('Quý này');
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics(bool isDark, Color cardColor, Color textColor) {
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
            'Chỉ số kinh doanh chính',
            style: Style.fontTitleMini.copyWith(color: textColor),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Tổng doanh thu',
                  '${(_branchMetrics?.totalRevenue ?? 0).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ',
                  '${_branchMetrics?.growthRates.revenue.toStringAsFixed(1) ?? '0.0'}%',
                  (_branchMetrics?.growthRates.revenue ?? 0) >= 0 ? Colors.green : Colors.red,
                  Icons.trending_up,
                  isDark,
                  textColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Số đơn hàng',
                  '${(_branchMetrics?.totalOrders ?? 0).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  '${_branchMetrics?.growthRates.orders.toStringAsFixed(1) ?? '0.0'}%',
                  (_branchMetrics?.growthRates.orders ?? 0) >= 0 ? Colors.green : Colors.red,
                  Icons.receipt_long,
                  isDark,
                  textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Giá trị TB/đơn',
                  '${(_branchMetrics?.avgOrderValue ?? 0).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ',
                  '${_branchMetrics?.growthRates.avgOrderValue.toStringAsFixed(1) ?? '0.0'}%',
                  (_branchMetrics?.growthRates.avgOrderValue ?? 0) >= 0 ? Colors.green : Colors.red,
                  Icons.attach_money,
                  isDark,
                  textColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Khách hàng mới',
                  '${_branchMetrics?.newCustomers ?? 0}',
                  '${_branchMetrics?.growthRates.newCustomers.toStringAsFixed(1) ?? '0.0'}%',
                  (_branchMetrics?.growthRates.newCustomers ?? 0) >= 0 ? Colors.green : Colors.red,
                  Icons.person_add,
                  isDark,
                  textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String change, Color changeColor, IconData icon, bool isDark, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: changeColor, size: 20),
              Text(
                change,
                style: Style.fontCaption.copyWith(
                  color: changeColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Style.fontTitleMini.copyWith(
              color: textColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Style.fontCaption.copyWith(
              color: isDark ? Colors.grey[400] : Style.textColorGray,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueTrendChart(bool isDark, Color cardColor, Color textColor) {
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
            children: [
              Icon(
                _selectedPeriod == 'Tuần này' 
                  ? Icons.calendar_view_week
                  : _selectedPeriod == 'Tháng này'
                  ? Icons.calendar_view_month  
                  : Icons.calendar_today,
                color: _selectedPeriod == 'Tuần này' 
                  ? Colors.green
                  : _selectedPeriod == 'Tháng này'
                  ? Colors.blue
                  : Colors.purple,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Xu hướng doanh thu - $_selectedPeriod',
                style: Style.fontTitleMini.copyWith(color: textColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _selectedPeriod == 'Tuần này' ? 10000000 : 
                                   _selectedPeriod == 'Tháng này' ? 10000000 : 50000000,
                  getDrawingHorizontalLine: (value) {
                    Color gridColor = _selectedPeriod == 'Tuần này' 
                      ? Colors.green.withValues(alpha: 0.3)
                      : _selectedPeriod == 'Tháng này'
                      ? Colors.blue.withValues(alpha: 0.3)
                      : Colors.purple.withValues(alpha: 0.3);
                    return FlLine(
                      color: isDark ? gridColor : gridColor.withValues(alpha: 0.5),
                      strokeWidth: 0.8,
                    );
                  },
                ),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) {
                      Color tooltipColor = _selectedPeriod == 'Tuần này' 
                        ? Colors.green
                        : _selectedPeriod == 'Tháng này'
                        ? Colors.blue
                        : Colors.purple;
                      return tooltipColor.withValues(alpha: 0.9);
                    },
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final revenue = barSpot.y;
                        final period = _revenueTrends[barSpot.x.toInt()].period;
                        final orders = _revenueTrends[barSpot.x.toInt()].orders;
                        
                        return LineTooltipItem(
                          '$period\nDoanh thu: ${(revenue / 1000000).toStringAsFixed(1)}M đ\nĐơn hàng: $orders',
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
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      interval: _selectedPeriod == 'Tuần này' ? 10000000 : 
                               _selectedPeriod == 'Tháng này' ? 10000000 : 50000000,
                      getTitlesWidget: (value, meta) {
                        if (_selectedPeriod == 'Tuần này') {
                          return Text(
                            '${(value / 1000000).toInt()}M',
                            style: Style.fontCaption.copyWith(
                              color: isDark ? Colors.grey[400] : Style.textColorGray,
                              fontSize: 10,
                            ),
                          );
                        } else {
                          return Text(
                            '${(value / 1000000).toInt()}M',
                            style: Style.fontCaption.copyWith(
                              color: isDark ? Colors.grey[400] : Style.textColorGray,
                              fontSize: 9,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < _revenueTrends.length) {
                          final period = _revenueTrends[value.toInt()].period;
                          String displayText = period;
                          
                          // Rút gọn text cho dễ nhìn
                          if (_selectedPeriod == 'Tháng này') {
                            displayText = period.replaceAll('Tuần ', 'T');
                          } else if (_selectedPeriod == 'Quý này') {
                            displayText = period.replaceAll('Tháng ', 'T');
                          }
                          
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              displayText,
                              style: Style.fontCaption.copyWith(
                                color: isDark ? Colors.grey[400] : Style.textColorGray,
                                fontSize: _selectedPeriod == 'Tuần này' ? 10 : 9,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _revenueTrends.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.revenue.toDouble());
                    }).toList(),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: _selectedPeriod == 'Tuần này' 
                        ? [Colors.green.withValues(alpha: 0.8), Colors.lightGreen.withValues(alpha: 0.8)]
                        : _selectedPeriod == 'Tháng này'
                        ? [Colors.blue.withValues(alpha: 0.8), Colors.lightBlue.withValues(alpha: 0.8)]
                        : [Colors.purple.withValues(alpha: 0.8), Colors.deepPurple.withValues(alpha: 0.8)],
                    ),
                    barWidth: 4,
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: _selectedPeriod == 'Tuần này' 
                          ? [Colors.green.withValues(alpha: 0.2), Colors.lightGreen.withValues(alpha: 0.1)]
                          : _selectedPeriod == 'Tháng này'
                          ? [Colors.blue.withValues(alpha: 0.2), Colors.lightBlue.withValues(alpha: 0.1)]
                          : [Colors.purple.withValues(alpha: 0.2), Colors.deepPurple.withValues(alpha: 0.1)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: _selectedPeriod == 'Tuần này' 
                      ? Colors.green
                      : _selectedPeriod == 'Tháng này'
                      ? Colors.blue
                      : Colors.purple,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
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

  Widget _buildTopDishesReport(bool isDark, Color cardColor, Color textColor) {

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
            children: [
              Icon(
                Icons.restaurant_menu,
                color: Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Top 5 món ăn bán chạy',
                style: Style.fontTitleMini.copyWith(color: textColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text('Món ăn', style: Style.fontCaption.copyWith(color: textColor, fontWeight: FontWeight.w600, fontSize: 11))),
                Expanded(flex: 2, child: Text('Đơn hàng', style: Style.fontCaption.copyWith(color: textColor, fontWeight: FontWeight.w600, fontSize: 11))),
                Expanded(flex: 3, child: Text('Doanh thu', style: Style.fontCaption.copyWith(color: textColor, fontWeight: FontWeight.w600, fontSize: 11))),
                Expanded(flex: 3, child: Text('Lợi nhuận', style: Style.fontCaption.copyWith(color: textColor, fontWeight: FontWeight.w600, fontSize: 11))),
                Expanded(flex: 2, child: Text('Tỷ suất', style: Style.fontCaption.copyWith(color: textColor, fontWeight: FontWeight.w600, fontSize: 11))),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Table rows
          ..._topDishes.map((dish) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
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
                  flex: 3,
                  child: Text(
                    '${dish.profit.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ',
                    style: Style.fontNormal.copyWith(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '${dish.profitMargin}%',
                    style: Style.fontNormal.copyWith(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildEmployeePerformanceReport(bool isDark, Color cardColor, Color textColor) {

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
            children: [
              Icon(
                Icons.emoji_events,
                color: Colors.amber,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Hiệu suất nhân viên xuất sắc',
                style: Style.fontTitleMini.copyWith(color: textColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text('Nhân viên', style: Style.fontCaption.copyWith(color: textColor, fontWeight: FontWeight.w600, fontSize: 11))),
                Expanded(flex: 2, child: Text('Vị trí', style: Style.fontCaption.copyWith(color: textColor, fontWeight: FontWeight.w600, fontSize: 11))),
                Expanded(flex: 2, child: Text('Đơn', style: Style.fontCaption.copyWith(color: textColor, fontWeight: FontWeight.w600, fontSize: 11))),
                Expanded(flex: 3, child: Text('Doanh thu', style: Style.fontCaption.copyWith(color: textColor, fontWeight: FontWeight.w600, fontSize: 11))),
                Expanded(flex: 2, child: Text('Đánh giá', style: Style.fontCaption.copyWith(color: textColor, fontWeight: FontWeight.w600, fontSize: 11))),
                Expanded(flex: 3, child: Text('Thưởng', style: Style.fontCaption.copyWith(color: textColor, fontWeight: FontWeight.w600, fontSize: 11))),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Table rows
          ..._employeePerformance.map((employee) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
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
                  flex: 3,
                  child: Text(
                    '${employee.totalRevenue.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ',
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
                  flex: 3,
                  child: Text(
                    '${employee.bonus.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ',
                    style: Style.fontNormal.copyWith(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildPeakHoursAnalysis(bool isDark, Color cardColor, Color textColor) {
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
            'Phân tích giờ cao điểm',
            style: Style.fontTitleMini.copyWith(color: textColor),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
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
                        if (value.toInt() >= 0 && value.toInt() < _peakHoursData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _peakHoursData[value.toInt()].timeSlot,
                              style: Style.fontCaption.copyWith(
                                color: isDark ? Colors.grey[400] : Style.textColorGray,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: _peakHoursData.asMap().entries.map((entry) {
                  final data = entry.value;
                  final color = data.level == 'peak' ? Colors.red : 
                               data.level == 'busy' ? Colors.orange : Colors.blue;
                  return BarChartGroupData(
                    x: entry.key, 
                    barRods: [BarChartRodData(toY: data.orders.toDouble(), color: color, width: 16)]
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem('Cao điểm', Colors.red, isDark, textColor),
              _buildLegendItem('Khá đông', Colors.orange, isDark, textColor),
              _buildLegendItem('Bình thường', Colors.blue, isDark, textColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerSatisfaction(bool isDark, Color cardColor, Color textColor) {
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
            'Mức độ hài lòng khách hàng',
            style: Style.fontTitleMini.copyWith(color: textColor),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 150,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                      sections: _customerSatisfaction?.ratings.map((rating) {
                        final color = Color(int.parse(rating.color.replaceFirst('#', '0xFF')));
                        return PieChartSectionData(
                          color: color, 
                          value: rating.percentage.toDouble(), 
                          title: '${rating.percentage}%', 
                          radius: 25
                        );
                      }).toList() ?? [],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _customerSatisfaction?.ratings.map((rating) {
                    final color = Color(int.parse(rating.color.replaceFirst('#', '0xFF')));
                    return _buildSatisfactionItem(
                      rating.level, 
                      color, 
                      '${rating.percentage}%', 
                      '${rating.count} khách', 
                      isDark, 
                      textColor
                    );
                  }).toList() ?? [],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.green[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.trending_up, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Mức độ hài lòng tăng ${_customerSatisfaction?.growthRate.toStringAsFixed(1) ?? '0.0'}% so với tháng trước. Điểm trung bình: ${_customerSatisfaction?.averageRating ?? 0.0}/5.0 ⭐',
                    style: Style.fontNormal.copyWith(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSatisfactionItem(String label, Color color, String percentage, String count, bool isDark, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Style.fontNormal.copyWith(color: textColor, fontSize: 12),
            ),
          ),
          Text(
            '$percentage ($count)',
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

  Widget _buildLegendItem(String label, Color color, bool isDark, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Style.fontCaption.copyWith(color: textColor, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildChipButton(String label, bool isSelected, bool isDark, Color textColor, VoidCallback onTap) {
    Color selectedColor = label == 'Tuần này' 
      ? Colors.green
      : label == 'Tháng này'
      ? Colors.blue
      : Colors.purple;
      
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
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
          boxShadow: isSelected ? [
            BoxShadow(
              color: selectedColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) Icon(
              label == 'Tuần này' 
                ? Icons.calendar_view_week
                : label == 'Tháng này'
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
}