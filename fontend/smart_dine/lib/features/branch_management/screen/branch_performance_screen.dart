import 'package:flutter/material.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/widgets/appbar.dart';
import 'package:fl_chart/fl_chart.dart';

class BranchPerformanceScreen extends StatelessWidget {
  const BranchPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Style.colorLight : Style.colorDark;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[850] : Style.backgroundColor,
      appBar: AppBarCus(
        title: 'Hiệu xuất chi nhánh',
        isCanpop: true,
        isButtonEnabled: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tổng quan
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

            // Hiệu suất nhân viên
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
                  _buildEmployeeRow(
                    '1',
                    'Hà Đức Lương',
                    '285 đơn',
                    '24.5 triệu',
                    textColor,
                  ),
                  const Divider(height: 24),
                  _buildEmployeeRow(
                    '2',
                    'Phúc',
                    '268 đơn',
                    '22.8 triệu',
                    textColor,
                  ),
                  const Divider(height: 24),
                  _buildEmployeeRow(
                    '3',
                    'Tú Kiệt',
                    '245 đơn',
                    '21.2 triệu',
                    textColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Biểu đồ doanh thu theo giờ
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
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}tr',
                              style: Style.fontCaption.copyWith(
                                color:
                                    isDark
                                        ? Colors.grey[400]
                                        : Style.textColorGray,
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
                            const titles = [
                              '',
                              '6-9h',
                              '9-12h',
                              '12-15h',
                              '15-18h',
                              '18-21h',
                              '21-24h',
                            ];
                            if (value.toInt() < 0 ||
                                value.toInt() >= titles.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                titles[value.toInt()],
                                style: Style.fontCaption.copyWith(
                                  color:
                                      isDark
                                          ? Colors.grey[400]
                                          : Style.textColorGray,
                                  fontSize: 9,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      _buildBarGroup(1, 8.5),
                      _buildBarGroup(2, 12.8),
                      _buildBarGroup(3, 28.5),
                      _buildBarGroup(4, 15.2),
                      _buildBarGroup(5, 32.5),
                      _buildBarGroup(6, 18.8),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Món ăn bán chạy
            Text(
              'Món ăn bán chạy',
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
                  _buildDishRow('Phở bò', '425 phần', '8.5 triệu', textColor),
                  const Divider(height: 24),
                  _buildDishRow(
                    'Cà phê sữa',
                    '315 phần',
                    '6.3 triệu',
                    textColor,
                  ),
                  const Divider(height: 24),
                  _buildDishRow(
                    'Bánh mì thịt',
                    '280 phần',
                    '4.2 triệu',
                    textColor,
                  ),
                  const Divider(height: 24),
                  _buildDishRow('Bún chả', '245 phần', '5.6 triệu', textColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
            offset: const Offset(0, 2),
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

  Widget _buildEmployeeRow(
    String rank,
    String name,
    String orders,
    String revenue,
    Color textColor,
  ) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color:
                rank == '1'
                    ? Colors.amber
                    : (rank == '2' ? Colors.grey[400] : Colors.brown[300]),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              rank,
              style: Style.fontNormal.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Style.fontNormal.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                orders,
                style: Style.fontCaption.copyWith(color: Style.textColorGray),
              ),
            ],
          ),
        ),
        Text(
          revenue,
          style: Style.fontNormal.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDishRow(
    String dish,
    String quantity,
    String revenue,
    Color textColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dish,
                style: Style.fontNormal.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                quantity,
                style: Style.fontCaption.copyWith(color: Style.textColorGray),
              ),
            ],
          ),
        ),
        Text(
          revenue,
          style: Style.fontNormal.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
}
