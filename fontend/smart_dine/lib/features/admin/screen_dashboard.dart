import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/style.dart';

// Provider cho dữ liệu dashboard
final dashboardDataProvider = FutureProvider<DashboardData>((ref) async {
  await Future.delayed(const Duration(seconds: 1));
  return DashboardData(
    stores: [
      StoreData(name: 'Restaurant A', revenue: 124, percentage: 35),
      StoreData(name: 'Restaurant B', revenue: 124, percentage: 67),
      StoreData(name: 'Restaurant C', revenue: 434, percentage: 64),
      StoreData(
        name: 'Restaurant D',
        revenue: 245,
        percentage: 0,
        noData: true,
      ),
    ],
    monthlyRevenue: [50, 80, 120, 150, 180, 250, 380],
  );
});

class DashboardData {
  final List<StoreData> stores;
  final List<double> monthlyRevenue;

  DashboardData({required this.stores, required this.monthlyRevenue});
}

class StoreData {
  final String name;
  final int revenue;
  final int percentage;
  final bool noData;

  StoreData({
    required this.name,
    required this.revenue,
    required this.percentage,
    this.noData = false,
  });
}

// Provider cho filter (Năm/Tháng/Tuần)
final revenueFilterProvider = StateProvider<String>((ref) => 'Tháng');

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardData = ref.watch(dashboardDataProvider);
    final selectedFilter = ref.watch(revenueFilterProvider);

    // Lấy kích thước màn hình
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / 375; // Base: 375px

    // Font sizes responsive
    final titleSize = 24.0 * scale;
    final headerSize = 18.0 * scale;
    final buttonSize = 14.0 * scale;
    final chartLabelSize = 12.0 * scale;

    return Scaffold(
      backgroundColor: Style.colorLight,
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: Style.fontTitle.copyWith(
            color: Style.colorDark,
            fontSize: titleSize.clamp(20, 28),
          ),
        ),
        backgroundColor: Style.colorLight,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.bar_chart,
              color: Style.colorDark,
              size: (28.0 * scale).clamp(24, 32),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: dashboardData.when(
        data:
            (data) => RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(dashboardDataProvider);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(Style.paddingPhone * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Grid 2x2 của các cửa hàng
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cardWidth =
                            (constraints.maxWidth - Style.spacingMedium) / 2;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: Style.spacingMedium,
                                mainAxisSpacing: Style.spacingMedium,
                                childAspectRatio: 1.05,
                              ),
                          itemCount: data.stores.length,
                          itemBuilder: (context, index) {
                            final store = data.stores[index];
                            return _buildStoreCard(store, index, cardWidth);
                          },
                        );
                      },
                    ),
                    SizedBox(height: Style.spacingLarge * scale),

                    // Phần Doanh thu
                    Row(
                      children: [
                        Text(
                          'Doanh thu',
                          style: Style.fontTitleMini.copyWith(
                            fontSize: headerSize.clamp(16, 22),
                          ),
                        ),
                        const Spacer(),
                        _buildFilterButton(
                          'Năm',
                          selectedFilter,
                          ref,
                          buttonSize,
                        ),
                        const SizedBox(width: Style.spacingSmall),
                        _buildFilterButton(
                          'Tháng',
                          selectedFilter,
                          ref,
                          buttonSize,
                        ),
                        const SizedBox(width: Style.spacingSmall),
                        _buildFilterButton(
                          'Tuần',
                          selectedFilter,
                          ref,
                          buttonSize,
                        ),
                      ],
                    ),
                    SizedBox(height: 20 * scale),

                    // Biểu đồ
                    SizedBox(
                      height: 250 * scale,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 45,
                                interval: 100,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '${value.toInt()}m',
                                    style: Style.fontCaption.copyWith(
                                      fontSize: chartLabelSize.clamp(10, 14),
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final labels = [
                                    '',
                                    '',
                                    '2',
                                    '3',
                                    '4',
                                    '5',
                                    '6',
                                    '7',
                                    'CN',
                                  ];
                                  final index = value.toInt();
                                  if (index >= 0 && index < labels.length) {
                                    return Text(
                                      labels[index],
                                      style: Style.fontCaption.copyWith(
                                        fontSize: chartLabelSize.clamp(10, 14),
                                      ),
                                    );
                                  }
                                  return const Text('');
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
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: List.generate(
                                data.monthlyRevenue.length,
                                (index) => FlSpot(
                                  (index + 2).toDouble(),
                                  data.monthlyRevenue[index],
                                ),
                              ),
                              isCurved: true,
                              curveSmoothness: 0.35,
                              color: Style.colorDark,
                              barWidth: 2.5,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  if (index == data.monthlyRevenue.length - 1) {
                                    return FlDotCirclePainter(
                                      radius: 5,
                                      color: Style.colorDark,
                                      strokeWidth: 2,
                                      strokeColor: Style.colorLight,
                                    );
                                  }
                                  return FlDotCirclePainter(
                                    radius: 0,
                                    color: Colors.transparent,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(show: false),
                            ),
                          ],
                          minY: 0,
                          maxY: 400,
                          minX: 2,
                          maxX: 8,
                        ),
                      ),
                    ),
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
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  SizedBox(height: Style.spacingMedium),
                  Text('Lỗi: $error', style: Style.fontNormal),
                  SizedBox(height: Style.spacingMedium),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(dashboardDataProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Style.buttonBackgroundColor,
                    ),
                    child: Text('Thử lại', style: Style.fontButton),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildStoreCard(StoreData store, int index, double cardWidth) {
    final colors = [
      Style.colorDark,
      const Color(0xFFE5E5E5),
      const Color(0xFFF0F0F0),
      const Color(0xFFF5F5F5),
    ];
    final textColors = [
      Style.colorLight,
      Style.colorDark,
      Style.colorDark,
      Style.colorDark,
    ];

    // Tính font size dựa vào card width
    final revenueSize = cardWidth * 0.13;
    final nameSize = cardWidth * 0.075;
    final percentSize = cardWidth * 0.065;

    return Container(
      padding: EdgeInsets.all(cardWidth * 0.09),
      decoration: BoxDecoration(
        color: colors[index],
        borderRadius: BorderRadius.circular(Style.cardBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${store.revenue} M',
            style: Style.fontTitle.copyWith(
              fontSize: revenueSize,
              color: textColors[index],
            ),
          ),
          Text(
            store.name,
            style: Style.fontNormal.copyWith(
              fontSize: nameSize,
              color: textColors[index].withOpacity(0.7),
            ),
          ),
          const Spacer(),
          if (store.noData)
            Text(
              'Không có chi tiêu',
              style: Style.fontCaption.copyWith(fontSize: percentSize),
            )
          else
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '0%',
                      style: Style.fontCaption.copyWith(
                        fontSize: percentSize,
                        color: textColors[index].withOpacity(0.5),
                      ),
                    ),
                    Text(
                      '${store.percentage}%',
                      style: Style.fontTitleSuperMini.copyWith(
                        fontSize: percentSize,
                        color: textColors[index],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: store.percentage / 100,
                    backgroundColor: textColors[index].withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      textColors[index],
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(
    String text,
    String selected,
    WidgetRef ref,
    double fontSize,
  ) {
    final isSelected = selected == text;
    return GestureDetector(
      onTap: () {
        ref.read(revenueFilterProvider.notifier).state = text;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Style.paddingPhone,
          vertical: Style.spacingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Style.colorDark : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: Style.fontButton.copyWith(
            color: isSelected ? Style.colorLight : Style.colorDark,
            fontSize: fontSize.clamp(12.0, 16.0),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
