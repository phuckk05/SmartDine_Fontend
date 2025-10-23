import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/features/kitchen/screen_thongbao.dart';
import 'package:mart_dine/providers/thongbao_provider.dart';
import '../../../core/style.dart';
import '../../models/kitchen_order.dart'; // Mô hình đơn hàng bếp
import '../../models/kitchen_order_tinhtrang.dart'; // Tình trạng đơn hàng bếp
import '../../providers/kitchen_amthanh_providers.dart';

class KitchenScreen extends ConsumerWidget {
  const KitchenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredOrders = ref.watch(filteredOrdersProvider);
    final selectedTab = ref.watch(selectedTabProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final orderCounts = ref.watch(orderCountByStatusProvider);

    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;
    final maxWidth = isWeb ? 1200.0 : double.infinity;

    return Scaffold(
      backgroundColor: Style.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Phòng bếp',
              style: Style.fontTitle.copyWith(
                color: Style.textColorWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: Style.spacingSmall),
            Text(
              _getCurrentDate(),
              style: Style.fontNormal.copyWith(
                color: Style.textColorWhite.withOpacity(0.9),
              ),
            ),
          ],
        ),
        actions: [
          // Hiển thị số orders pending
          if (orderCounts[KitchenOrderStatus.pending]! > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange[600],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${orderCounts[KitchenOrderStatus.pending]} món chờ',
                    style: Style.fontNormal.copyWith(
                      color: Style.textColorWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.notifications_outlined, color: Style.textColorWhite),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Consumer(
                    builder: (context, ref, child) {
                      final unreadCount = ref.watch(unreadCountProvider);
                      if (unreadCount == 0) return const SizedBox.shrink();

                      return Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            },
            tooltip: 'Thông báo',
          ),
          if (isWeb) const SizedBox(width: Style.spacingSmall),
        ],
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            children: [
              _buildSearchBar(ref, isWeb, searchQuery),
              _buildTabs(ref, isWeb, orderCounts),
              _buildHeader(isWeb, filteredOrders.length, selectedTab),
              _buildOrdersList(ref, filteredOrders, selectedTab, isWeb),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== BUILD METHODS ====================

  Widget _buildSearchBar(WidgetRef ref, bool isWeb, String searchQuery) {
    return Container(
      padding: EdgeInsets.all(isWeb ? 20 : Style.paddingPhone),
      color: Style.colorLight,
      child: TextField(
        onChanged: (value) {
          ref.read(searchQueryProvider.notifier).state = value;
        },
        decoration: InputDecoration(
          hintText: 'Tìm kiếm món ăn hoặc bàn...',
          hintStyle: Style.fontNormal.copyWith(color: Style.textColorGray),
          prefixIcon: Icon(Icons.search, color: Style.textColorGray),
          suffixIcon:
              searchQuery.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear, color: Style.textColorGray),
                    onPressed: () {
                      ref.read(searchQueryProvider.notifier).state = '';
                    },
                  )
                  : null,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  /// Build tabs - 4 TABS
  Widget _buildTabs(
    WidgetRef ref,
    bool isWeb,
    Map<KitchenOrderStatus, int> counts,
  ) {
    return Container(
      color: Style.colorLight,
      child: isWeb ? _buildWebTabs(ref, counts) : _buildMobileTabs(ref, counts),
    );
  }

  Widget _buildWebTabs(WidgetRef ref, Map<KitchenOrderStatus, int> counts) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTab(
          ref,
          'Chưa làm',
          0,
          counts[KitchenOrderStatus.pending]!,
          minWidth: 150,
        ),
        _buildTab(
          ref,
          'Đã làm',
          1,
          counts[KitchenOrderStatus.completed]!,
          minWidth: 150,
        ),
        _buildTab(
          ref,
          'Hết món',
          2,
          counts[KitchenOrderStatus.outOfStock]!,
          minWidth: 150,
        ),
        _buildTab(
          ref,
          'Đã hủy',
          3,
          counts[KitchenOrderStatus.cancelled]!,
          minWidth: 150,
        ),
      ],
    );
  }

  /// Mobile tabs
  Widget _buildMobileTabs(WidgetRef ref, Map<KitchenOrderStatus, int> counts) {
    return Row(
      children: [
        _buildTab(ref, 'Chưa làm', 0, counts[KitchenOrderStatus.pending]!),
        _buildTab(ref, 'Đã làm', 1, counts[KitchenOrderStatus.completed]!),
        _buildTab(ref, 'Hết món', 2, counts[KitchenOrderStatus.outOfStock]!),
        _buildTab(ref, 'Đã hủy', 3, counts[KitchenOrderStatus.cancelled]!),
      ],
    );
  }

  Widget _buildTab(
    WidgetRef ref,
    String title,
    int index,
    int count, {
    double? minWidth,
  }) {
    final selectedTab = ref.watch(selectedTabProvider);
    final isSelected = selectedTab == index;

    return Expanded(
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: minWidth ?? 0),
        child: GestureDetector(
          onTap: () => ref.read(selectedTabProvider.notifier).state = index,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? Colors.blue[700]! : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Style.fontTitleSuperMini.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color:
                          isSelected ? Colors.blue[700] : Style.textColorGray,
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue[700] : Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: Style.fontCaption.copyWith(
                          color: Style.textColorWhite,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isWeb, int count, int selectedTab) {
    String title;
    switch (selectedTab) {
      case 0:
        title = 'Món cần làm';
        break;
      case 1:
        title = 'Món đã làm xong';
        break;
      case 2:
        title = 'Món hết nguyên liệu';
        break;
      case 3:
        title = 'Món đã bị hủy';
        break;
      default:
        title = 'Danh sách các món';
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWeb ? 20 : Style.paddingPhone,
        vertical: 12,
      ),
      color: Style.colorLight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Style.fontTitleMini.copyWith(
              fontSize: isWeb ? 18 : 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[700],
              borderRadius: BorderRadius.circular(Style.borderRadius),
            ),
            child: Text(
              '$count',
              style: Style.fontTitleSuperMini.copyWith(
                color: Style.textColorWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(
    WidgetRef ref,
    List<KitchenOrder> orders,
    int selectedTab,
    bool isWeb,
  ) {
    return Expanded(
      child:
          orders.isEmpty
              ? _buildEmptyState(selectedTab)
              : (isWeb
                  ? _buildWebGrid(ref, orders, selectedTab)
                  : _buildMobileList(ref, orders, selectedTab)),
    );
  }

  Widget _buildEmptyState(int selectedTab) {
    String message;
    switch (selectedTab) {
      case 0:
        message = 'Không có món nào cần làm';
        break;
      case 1:
        message = 'Không có món nào đã hoàn thành';
        break;
      case 2:
        message = 'Không có món nào hết';
        break;
      case 3:
        message = 'Không có món nào bị hủy';
        break;
      default:
        message = 'Không có món nào';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[400]),
          const SizedBox(height: Style.spacingMedium),
          Text(
            message,
            style: Style.fontTitleMini.copyWith(color: Style.textColorGray),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList(
    WidgetRef ref,
    List<KitchenOrder> orders,
    int selectedTab,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(Style.paddingPhone),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _buildDishCard(ref, orders[index], false, selectedTab);
      },
    );
  }

  Widget _buildWebGrid(
    WidgetRef ref,
    List<KitchenOrder> orders,
    int selectedTab,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.5,
        crossAxisSpacing: Style.spacingMedium,
        mainAxisSpacing: Style.spacingMedium,
      ),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _buildDishCard(ref, orders[index], true, selectedTab);
      },
    );
  }

  // ==================== DISH CARD ====================

  Widget _buildDishCard(
    WidgetRef ref,
    KitchenOrder order,
    bool isWeb,
    int selectedTab,
  ) {
    return Container(
      margin: isWeb ? EdgeInsets.zero : const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isWeb ? 20 : Style.paddingPhone),
      decoration: BoxDecoration(
        color: Style.colorLight,
        borderRadius: BorderRadius.circular(Style.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: Style.shadowBlurRadius,
            offset: Offset(Style.shadowOffsetX, Style.shadowOffsetY),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildDishInfo(order, isWeb),
          _buildDishActions(ref, order, selectedTab, isWeb),
        ],
      ),
    );
  }

  Widget _buildDishInfo(KitchenOrder order, bool isWeb) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.dishName,
                  style: Style.fontTitleMini.copyWith(
                    fontSize: isWeb ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (order.quantity > 1)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'x${order.quantity}',
                    style: Style.fontCaption.copyWith(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Giờ tạo: ${order.createdTime}',
            style: Style.fontCaption.copyWith(fontSize: isWeb ? 14 : 13),
          ),
          const SizedBox(height: 2),
          Text(
            'Bàn: ${order.tableNumber}',
            style: Style.fontCaption.copyWith(fontSize: isWeb ? 14 : 13),
          ),
          if (order.note != null && order.note!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Ghi chú: ${order.note}',
              style: Style.fontCaption.copyWith(
                fontSize: isWeb ? 14 : 13,
                color: Colors.orange[700],
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDishActions(
    WidgetRef ref,
    KitchenOrder order,
    int selectedTab,
    bool isWeb,
  ) {
    if (selectedTab == 0) {
      return Wrap(
        spacing: Style.spacingSmall,
        runSpacing: Style.spacingSmall,
        children: [
          _buildActionButton(
            label: 'Xong',
            color: Colors.blue[600]!,
            onPressed: () => _handleComplete(ref, order),
            isWeb: isWeb,
          ),
          _buildActionButton(
            label: 'Hết',
            color: Colors.orange[300]!,
            onPressed: () => _handleOutOfStock(ref, order),
            isWeb: isWeb,
          ),
        ],
      );
    }

    if (selectedTab == 1) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: isWeb ? 24 : 20,
          vertical: isWeb ? 12 : 10,
        ),
        decoration: BoxDecoration(
          color: Colors.green[100],
          borderRadius: BorderRadius.circular(Style.buttonBorderRadius),
        ),
        child: Text(
          'Chờ lấy',
          style: Style.fontButton.copyWith(
            fontSize: isWeb ? 15 : 14,
            fontWeight: FontWeight.w600,
            color: Colors.green[700],
          ),
        ),
      );
    }

    if (selectedTab == 2) {
      return Text(
        'Đã hết',
        style: Style.fontTitleMini.copyWith(
          fontSize: isWeb ? 16 : 15,
          fontWeight: FontWeight.bold,
          color: Colors.orange[600],
        ),
      );
    }

    return Text(
      'Đã hủy',
      style: Style.fontTitleMini.copyWith(
        fontSize: isWeb ? 16 : 15,
        fontWeight: FontWeight.bold,
        color: Colors.red[600],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required bool isWeb,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Style.textColorWhite,
        padding: EdgeInsets.symmetric(
          horizontal: isWeb ? 28 : 24,
          vertical: isWeb ? 14 : 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Style.buttonBorderRadius),
        ),
        elevation: 0,
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.hovered)) {
            return Colors.white.withOpacity(0.1);
          }
          return null;
        }),
      ),
      child: Text(
        label,
        style: Style.fontButton.copyWith(fontSize: isWeb ? 16 : 15),
      ),
    );
  }

  void _handleComplete(WidgetRef ref, KitchenOrder order) {
    if (!order.canBeProcessed) {
      _showSnackBar(ref, 'Chỉ có thể xử lý món ở tab "Chưa làm"', Colors.red);
      return;
    }

    ref.read(completeOrderProvider(order.id))();

    _showSnackBar(
      ref,
      'Đã hoàn thành món ${order.dishName}. Đã tạo thông báo!',
      Colors.green,
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      ref.read(selectedTabProvider.notifier).state = 1;
    });
  }

  void _handleOutOfStock(WidgetRef ref, KitchenOrder order) {
    if (!order.canBeProcessed) {
      _showSnackBar(ref, 'Chỉ có thể xử lý món ở tab "Chưa làm"', Colors.red);
      return;
    }

    ref.read(outOfStockOrderProvider(order.id))();

    _showSnackBar(
      ref,
      'Món ${order.dishName} đã hết. Đã tạo thông báo!',
      Colors.orange,
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      ref.read(selectedTabProvider.notifier).state = 2;
    });
  }

  void _showSnackBar(WidgetRef ref, String message, Color backgroundColor) {
    final context = ref.context;
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: Style.fontNormal.copyWith(color: Style.textColorWhite),
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
  }
}
