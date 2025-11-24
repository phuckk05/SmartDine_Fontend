import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/widgets/appbar.dart';
import '../../../providers/today_activities_provider.dart';
import '../../../providers/user_session_provider.dart';

class TodayActivitiesScreen extends ConsumerStatefulWidget {
  const TodayActivitiesScreen({super.key});

  @override
  ConsumerState<TodayActivitiesScreen> createState() => _TodayActivitiesScreenState();
}

class _TodayActivitiesScreenState extends ConsumerState<TodayActivitiesScreen> {

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Style.colorLight : Style.colorDark;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;
    
    // Lấy branchId từ user session
    final currentBranchId = ref.watch(currentBranchIdProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    
    // Yêu cầu user phải đăng nhập
    if (!isAuthenticated) {
      return Scaffold(
        backgroundColor: isDark ? Colors.grey[850] : Style.backgroundColor,
        appBar: AppBarCus(
          title: 'Hoạt động hôm nay',
          isCanpop: true,
          isButtonEnabled: true,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Vui lòng đăng nhập để tiếp tục'),
            ],
          ),
        ),
      );
    }
    
    final branchIdInt = currentBranchId;
    
    if (branchIdInt == null) {
      return Scaffold(
        backgroundColor: isDark ? Colors.grey[850] : Style.backgroundColor,
        appBar: AppBarCus(
          title: 'Hoạt động hôm nay',
          isCanpop: true,
          isButtonEnabled: true,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning, size: 64, color: Colors.orange),
              SizedBox(height: 16),
              Text('Không tìm thấy thông tin chi nhánh'),
              Text('Vui lòng đăng nhập lại'),
            ],
          ),
        ),
      );
    }
    final todayActivitiesAsync = ref.watch(todayActivitiesProvider(branchIdInt));

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[850] : Style.backgroundColor,
      appBar: AppBarCus(
        title: 'Hoạt động hôm nay',
        isCanpop: true,
        isButtonEnabled: true,
      ),
      body: todayActivitiesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Có lỗi xảy ra khi tải dữ liệu',
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(todayActivitiesProvider(branchIdInt).notifier).refresh();
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        data: (data) => _buildContent(context, data, textColor, cardColor),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TodayActivitiesData data, Color textColor, Color cardColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tổng đơn hàng card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tổng đơn hàng hôm nay',
                    style: Style.fontNormal.copyWith(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${data.totalOrders}',
                    style: Style.fontTitle.copyWith(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Đơn hàng đã hoàn thành: ${data.completedOrders}',
                    style: Style.fontCaption.copyWith(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stats grid
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Tổng số bàn',
                    '${data.totalTables}',
                    cardColor,
                    textColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Bàn chưa thanh toán',
                    '${data.unpaidTables}',
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
                    'Đã hoàn thành',
                    '${data.completedOrders}',
                    cardColor,
                    textColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Đang phục vụ',
                    '${data.servingOrders}',
                    cardColor,
                    textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Món ăn bán (dữ liệu động)
            Text(
              'Món ăn bán',
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
              child: data.soldDishes.isEmpty
                  ? Text('Không có dữ liệu', style: Style.fontCaption.copyWith(color: Style.textColorGray))
                  : Column(
                      children: [
                        for (int i = 0; i < data.soldDishes.length; i++) ...[
                          _buildDishRow(
                            data.soldDishes[i]['name'] ?? '',
                            data.soldDishes[i]['quantity']?.toString() ?? '',
                            textColor,
                          ),
                          if (i < data.soldDishes.length - 1) const Divider(height: 24),
                        ],
                      ],
                    ),
            ),
            const SizedBox(height: 24),

            // Đơn hàng theo giờ
            Text(
              'Đơn hàng theo giờ',
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
              child: data.hourlyBreakdown.isEmpty
                  ? Text('Không có dữ liệu', style: Style.fontCaption.copyWith(color: Style.textColorGray))
                  : Column(
                      children: [
                        for (var entry in data.hourlyBreakdown.entries) ...[
                          _buildDishRow(
                            '${entry.key}:00',
                            entry.value.toString(),
                            textColor,
                          ),
                          if (entry != data.hourlyBreakdown.entries.last) const Divider(height: 16),
                        ],
                      ],
                    ),
            ),
          ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color cardColor, Color textColor) {
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
        children: [
          Text(
            label,
            style: Style.fontCaption.copyWith(color: Style.textColorGray),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Style.fontTitleMini.copyWith(
              color: textColor,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDishRow(String dish, String quantity, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          dish,
          style: Style.fontNormal.copyWith(color: textColor),
        ),
        Text(
          quantity,
          style: Style.fontNormal.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
