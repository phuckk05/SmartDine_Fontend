import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models/phongbep_models.dart';
import 'package:mart_dine/providers/phongbep_providers.dart';
import '../../../core/style.dart';

class KitchenScreen extends ConsumerWidget {
  const KitchenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredOrders = ref.watch(filteredOrdersProvider);
    final selectedTab = ref.watch(selectedTabProvider);
    final searchQuery = ref.watch(searchQueryProvider);

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
              '23-01-2025',
              style: Style.fontNormal.copyWith(
                color: Style.textColorWhite.withOpacity(0.9),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: Style.textColorWhite,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Không có thông báo mới',
                    style: Style.fontNormal.copyWith(
                      color: Style.textColorWhite,
                    ),
                  ),
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
              _buildTabs(ref, isWeb),
              _buildHeader(isWeb, filteredOrders.length),
              _buildOrdersList(ref, filteredOrders, selectedTab, isWeb),
            ],
          ),
        ),
      ),
    );
  }

  /// Build search bar
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

  /// Build tabs
  Widget _buildTabs(WidgetRef ref, bool isWeb) {
    return Container(
      color: Style.colorLight,
      child: isWeb ? _buildWebTabs(ref) : _buildMobileTabs(ref),
    );
  }

  /// Build header with count
  Widget _buildHeader(bool isWeb, int count) {
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
            'Danh sách các món*',
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

  /// Build orders list
  Widget _buildOrdersList(
    WidgetRef ref,
    List<KitchenOrder> orders,
    int selectedTab,
    bool isWeb,
  ) {
    return Expanded(
      child:
          orders.isEmpty
              ? _buildEmptyState()
              : (isWeb
                  ? _buildWebGrid(ref, orders, selectedTab)
                  : _buildMobileList(ref, orders, selectedTab)),
    );
  }

  // ==================== TAB WIDGETS ====================

  /// Web tabs
  Widget _buildWebTabs(WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTab(ref, 'Chưa làm', 0, minWidth: 150),
        _buildTab(ref, 'Đã làm', 1, minWidth: 150),
        _buildTab(ref, 'Hết món', 2, minWidth: 150),
        _buildTab(ref, 'Đã hủy', 3, minWidth: 150),
      ],
    );
  }

  /// Mobile tabs
  Widget _buildMobileTabs(WidgetRef ref) {
    return Row(
      children: [
        _buildTab(ref, 'Chưa làm', 0),
        _buildTab(ref, 'Đã làm', 1),
        _buildTab(ref, 'Hết món', 2),
        _buildTab(ref, 'Đã hủy', 3),
      ],
    );
  }

  /// Single tab item
  Widget _buildTab(WidgetRef ref, String title, int index, {double? minWidth}) {
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
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: Style.fontTitleSuperMini.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.blue[700] : Style.textColorGray,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== LIST/GRID WIDGETS ====================

  /// Empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[400]),
          const SizedBox(height: Style.spacingMedium),
          Text(
            'Không có món nào',
            style: Style.fontTitleMini.copyWith(color: Style.textColorGray),
          ),
        ],
      ),
    );
  }

  /// Mobile list view
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

  /// Web grid view
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

  /// Dish card
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

  /// Dish info (name, time, table)
  Widget _buildDishInfo(KitchenOrder order, bool isWeb) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            order.dishName,
            style: Style.fontTitleMini.copyWith(
              fontSize: isWeb ? 18 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Giờ tạo : ${order.createdTime}',
            style: Style.fontCaption.copyWith(fontSize: isWeb ? 14 : 13),
          ),
          const SizedBox(height: 2),
          Text(
            'Bàn : ${order.tableNumber}',
            style: Style.fontCaption.copyWith(fontSize: isWeb ? 14 : 13),
          ),
        ],
      ),
    );
  }

  /// Dish actions (buttons or status)
  Widget _buildDishActions(
    WidgetRef ref,
    KitchenOrder order,
    int selectedTab,
    bool isWeb,
  ) {
    // Tab "Chưa làm" - hiển thị buttons
    if (selectedTab == 0) {
      return Wrap(
        spacing: Style.spacingSmall,
        runSpacing: Style.spacingSmall,
        children: [
          _buildActionButton(
            ref: ref,
            label: 'Xong',
            color: Colors.blue[600]!,
            onPressed: () => _handleComplete(ref, order),
            isWeb: isWeb,
          ),
          _buildActionButton(
            ref: ref,
            label: 'Hết',
            color: Colors.orange[300]!,
            onPressed: () => _handleOutOfStock(ref, order),
            isWeb: isWeb,
          ),
        ],
      );
    }

    // Tab "Đã làm" - hiển thị status "Chờ lấy"
    if (selectedTab == 1) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: isWeb ? 24 : 20,
          vertical: isWeb ? 12 : 10,
        ),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(Style.buttonBorderRadius),
        ),
        child: Text(
          'Chờ lấy',
          style: Style.fontButton.copyWith(
            fontSize: isWeb ? 15 : 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
      );
    }

    // Tab "Hết món" - hiển thị text "Đã hết"
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

    // Tab "Đã hủy" - hiển thị text "Đã hủy"
    return Text(
      'Đã hủy',
      style: Style.fontTitleMini.copyWith(
        fontSize: isWeb ? 16 : 15,
        fontWeight: FontWeight.bold,
        color: Colors.red[600],
      ),
    );
  }

  /// Action button (Xong, Hết)
  Widget _buildActionButton({
    required WidgetRef ref,
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
        overlayColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
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

  // ==================== HANDLERS ====================

  /// Handle complete order
  void _handleComplete(WidgetRef ref, KitchenOrder order) {
    if (!order.canBeProcessed) {
      _showSnackBar(ref, 'Chỉ có thể xử lý món ở tab "Chưa làm"', Colors.red);
      return;
    }

    final orders = ref.read(ordersProvider);
    final updatedOrders =
        orders.map((o) {
          return o == order ? o.markAsCompleted() : o;
        }).toList();

    ref.read(ordersProvider.notifier).state = updatedOrders;

    _showSnackBar(ref, 'Đã hoàn thành món ${order.dishName}', Colors.green);
  }

  /// Handle out of stock
  void _handleOutOfStock(WidgetRef ref, KitchenOrder order) {
    if (!order.canBeProcessed) {
      _showSnackBar(ref, 'Chỉ có thể xử lý món ở tab "Chưa làm"', Colors.red);
      return;
    }

    final orders = ref.read(ordersProvider);
    final updatedOrders =
        orders.map((o) {
          return o == order ? o.markAsOutOfStock() : o;
        }).toList();

    ref.read(ordersProvider.notifier).state = updatedOrders;

    _showSnackBar(ref, 'Món ${order.dishName} đã hết', Colors.orange);
  }

  /// Show snackbar helper
  void _showSnackBar(WidgetRef ref, String message, Color backgroundColor) {
    ScaffoldMessenger.of(ref.context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: Style.fontNormal.copyWith(color: Style.textColorWhite),
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
