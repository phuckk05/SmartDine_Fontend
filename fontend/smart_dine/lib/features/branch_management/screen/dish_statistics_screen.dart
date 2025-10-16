import 'package:flutter/material.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/widgets/appbar.dart';
import 'package:fl_chart/fl_chart.dart';

class DishStatisticsScreen extends StatefulWidget {
  const DishStatisticsScreen({super.key});

  @override
  State<DishStatisticsScreen> createState() => _DishStatisticsScreenState();
}

class _DishStatisticsScreenState extends State<DishStatisticsScreen> {
  String _selectedFilter = 'Tuần';
  int _touchedIndex = -1;

  // Dữ liệu biểu đồ theo filter
  Map<String, List<BarChartGroupData>> _getChartData() {
    final color = Colors.blue;
    final touchedColor = Colors.green;
    
    return {
      'Năm': List.generate(12, (index) {
        final values = [850.0, 920.0, 880.0, 1050.0, 980.0, 1120.0, 1080.0, 1250.0, 1180.0, 1320.0, 1280.0, 1450.0];
        return BarChartGroupData(
          x: index + 1,
          barRods: [
            BarChartRodData(
              toY: values[index],
              color: _touchedIndex == index ? touchedColor : color,
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ],
        );
      }),
      'Tháng': List.generate(4, (index) {
        final values = [280.0, 320.0, 350.0, 380.0];
        return BarChartGroupData(
          x: index + 1,
          barRods: [
            BarChartRodData(
              toY: values[index],
              color: _touchedIndex == index ? touchedColor : color,
              width: 40,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ],
        );
      }),
      'Tuần': List.generate(7, (index) {
        final values = [45.0, 52.0, 68.0, 72.0, 65.0, 85.0, 90.0];
        return BarChartGroupData(
          x: index + 1,
          barRods: [
            BarChartRodData(
              toY: values[index],
              color: _touchedIndex == index ? touchedColor : color,
              width: 24,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ],
        );
      }),
      'Hôm nay': List.generate(6, (index) {
        final values = [5.0, 8.0, 18.0, 12.0, 22.0, 15.0];
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: values[index],
              color: _touchedIndex == index ? touchedColor : color,
              width: 32,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ],
        );
      }),
    };
  }

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

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[850] : Style.backgroundColor,
      appBar: AppBarCus(
        title: 'Thống kê món',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter buttons
            Row(
              children: [
                _buildFilterChip('Năm', _selectedFilter == 'Năm', isDark, textColor, () {
                  setState(() {
                    _selectedFilter = 'Năm';
                  });
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Tháng', _selectedFilter == 'Tháng', isDark, textColor, () {
                  setState(() {
                    _selectedFilter = 'Tháng';
                  });
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Tuần', _selectedFilter == 'Tuần', isDark, textColor, () {
                  setState(() {
                    _selectedFilter = 'Tuần';
                  });
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Hôm nay', _selectedFilter == 'Hôm nay', isDark, textColor, () {
                  setState(() {
                    _selectedFilter = 'Hôm nay';
                  });
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
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _selectedFilter == 'Năm' ? 1500 : (_selectedFilter == 'Tháng' ? 400 : (_selectedFilter == 'Tuần' ? 100 : 25)),
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
                        barGroups: _getChartData()[_selectedFilter]!,
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
                  _buildTableRow('Phở bò', '8,500,000đ', '425', '425', '0', '100%', textColor),
                  _buildTableRow('Cà phê sữa', '6,300,000đ', '315', '310', '5', '98%', textColor),
                  _buildTableRow('Bánh mì thịt', '4,200,000đ', '280', '275', '5', '98%', textColor),
                  _buildTableRow('Bún chả', '5,600,000đ', '245', '240', '5', '98%', textColor),
                  _buildTableRow('Trà sữa', '3,800,000đ', '190', '182', '8', '96%', textColor),
                  _buildTableRow('Gỏi cuốn', '2,100,000đ', '140', '135', '5', '96%', textColor),
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
}
