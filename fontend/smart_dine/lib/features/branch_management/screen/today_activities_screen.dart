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
    
    // Nếu chưa có session, tự động tạo mock session
    if (!isAuthenticated || currentBranchId == null) {
      // Tự động mock login với branch mặc định
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(userSessionProvider.notifier).mockLogin(branchId: 1);
      });
      
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
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang khởi tạo phiên làm việc...'),
            ],
          ),
        ),
      );
    }
    
    final todayActivitiesAsync = ref.watch(todayActivitiesProvider(currentBranchId));

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
                  ref.read(todayActivitiesProvider(currentBranchId).notifier).refresh();
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
            // Doanh thu card
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
                    'Doanh thu hôm nay',
                    style: Style.fontNormal.copyWith(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_calculateRevenue(data)} đ',
                    style: Style.fontTitle.copyWith(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '↑ 12% so với hôm qua',
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

            // Món đặt thêm & Món hủy (dữ liệu động)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Món đặt thêm',
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
                        child: data.extraDishes.isEmpty
                            ? Text('Không có dữ liệu', style: Style.fontCaption.copyWith(color: Style.textColorGray))
                            : Column(
                                children: [
                                  for (int i = 0; i < data.extraDishes.length; i++) ...[
                                    _buildSimpleRow(
                                      data.extraDishes[i]['name'] ?? '',
                                      data.extraDishes[i]['quantity']?.toString() ?? '',
                                      textColor,
                                    ),
                                    if (i < data.extraDishes.length - 1) const Divider(height: 16),
                                  ],
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Món hủy',
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
                        child: data.cancelledDishes.isEmpty
                            ? Text('Không có dữ liệu', style: Style.fontCaption.copyWith(color: Style.textColorGray))
                            : Column(
                                children: [
                                  for (int i = 0; i < data.cancelledDishes.length; i++) ...[
                                    _buildSimpleRow(
                                      data.cancelledDishes[i]['name'] ?? '',
                                      data.cancelledDishes[i]['quantity']?.toString() ?? '',
                                      textColor,
                                    ),
                                    if (i < data.cancelledDishes.length - 1) const Divider(height: 16),
                                  ],
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Bottom stats: Supplies & Documents (dữ liệu động từ API)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kết tải thêm',
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
                            if (data.extraSupplies.isEmpty)
                              Text('Không có dữ liệu', style: Style.fontCaption.copyWith(color: Style.textColorGray)),
                            for (int i = 0; i < data.extraSupplies.length; i++) ...[
                              _buildSimpleRow(
                                data.extraSupplies[i]['name'] ?? '',
                                data.extraSupplies[i]['quantity']?.toString() ?? '',
                                textColor,
                              ),
                              if (i < data.extraSupplies.length - 1) const Divider(height: 8),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kết tài liệu',
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
                            if (data.extraDocuments.isEmpty)
                              Text('Không có dữ liệu', style: Style.fontCaption.copyWith(color: Style.textColorGray)),
                            for (int i = 0; i < data.extraDocuments.length; i++) ...[
                              _buildSimpleRow(
                                data.extraDocuments[i]['name'] ?? '',
                                data.extraDocuments[i]['quantity']?.toString() ?? '',
                                textColor,
                              ),
                              if (i < data.extraDocuments.length - 1) const Divider(height: 8),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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

  Widget _buildSimpleRow(String label, String value, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Style.fontCaption.copyWith(color: Style.textColorGray),
        ),
        Text(
          value,
          style: Style.fontNormal.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _calculateRevenue(TodayActivitiesData data) {
    // Giả sử mỗi order trung bình 585,000 đ
    final averageOrderValue = 585000;
    final totalRevenue = data.completedOrders * averageOrderValue;
    return _formatCurrency(totalRevenue);
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }
}
