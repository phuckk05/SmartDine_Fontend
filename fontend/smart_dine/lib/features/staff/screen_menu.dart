import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/core/constrats.dart';
import 'package:mart_dine/features/cashier/screen_payment.dart';
import 'package:mart_dine/models/item.dart';
import 'package:mart_dine/models/order.dart';
import 'package:mart_dine/models/order_item.dart';
import 'package:mart_dine/providers/cart_provider.dart';
import 'package:mart_dine/providers/menu_item_provider.dart';
import 'package:mart_dine/providers/table_provider.dart';
import 'package:mart_dine/API/order_API.dart';
import 'package:mart_dine/API/order_item_API.dart';
import 'package:mart_dine/routes.dart';
import 'package:mart_dine/widgets/appbar.dart';
import 'package:mart_dine/widgets/icon_back.dart';
// Import provider của bạn để gọi API
// Giả sử bạn có model OrderItem đã import

////
class ScreenMenu extends ConsumerStatefulWidget {
  final String tableName;
  final int tableId;
  final int? companyId;
  final int? branchId;
  final int? userId;
  final Order? initialOrder;
  final List<OrderItem>? initialOrderItems;

  const ScreenMenu({
    super.key,
    required this.tableName,
    required this.tableId,
    this.companyId,
    this.branchId,
    this.userId,
    this.initialOrder,
    this.initialOrderItems,
  });

  @override
  ConsumerState<ScreenMenu> createState() => _ScreenMenuState();
}

class _DisplayOrderItem {
  final Item item;
  final int quantity;

  const _DisplayOrderItem({required this.item, required this.quantity});
}

//State provider
final _selectedCategoryProvider = StateProvider<String>((ref) => 'Tất cả');
final _selectedMenuProvider = StateProvider<String>((ref) => 'Tất cả');
final _openBillProvider = StateProvider<bool>((ref) => false);
final _isSavingProvider = StateProvider<bool>((ref) => false);
final _isLoadingExistingProvider = StateProvider<bool>((ref) => false);
final _isRequestingPaymentProvider = StateProvider<bool>((ref) => false);
final _orderNoteProvider = StateProvider<String>((ref) => '');
final _itemNotesProvider = StateProvider<Map<int, String>>((ref) => {});
final _expandedNotesProvider = StateProvider<Set<int>>((ref) => {});

class _ScreenMenuState extends ConsumerState<ScreenMenu> {
  bool _showSearchBar = false;
  // Loại bỏ dấu tiếng Việt cho tìm kiếm
  String _removeVietnameseDiacritics(String str) {
    const vietnamese =
        'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
    const english =
        'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';
    String result = str.toLowerCase();
    for (int i = 0; i < vietnamese.length; i++) {
      result = result.replaceAll(vietnamese[i], english[i]);
    }
    return result;
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Order? _currentOrder;
  List<OrderItem> _existingOrderItems = [];

  // Search
  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = '';

  // Controllers for item notes
  final Map<int, TextEditingController> _itemNoteControllers = {};

  @override
  void dispose() {
    _searchController.dispose();
    // Dispose all item note controllers
    _itemNoteControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  String _formatCurrency(num value) {
    final bool isNegative = value < 0;
    final int intValue = value.abs().round();
    final String digits = intValue.toString();

    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      final int remaining = digits.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }

    final String prefix = isNegative ? '-' : '';
    return '$prefix${buffer.toString()} đ';
  }

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.initialOrder;
    _existingOrderItems = List<OrderItem>.from(
      widget.initialOrderItems ?? const <OrderItem>[],
    );
    Future.microtask(_initializeData);
  }

  Future<void> _initializeData() async {
    if (!mounted) return;
    ref.read(_isLoadingExistingProvider.notifier).state = true;

    try {
      await ref
          .read(menuNotifierProvider.notifier)
          .loadMenusByCompanyId(widget.companyId ?? 1);

      if (widget.initialOrder != null) {
        await _reloadExistingOrder(widget.initialOrder!);
      } else {
        await _fetchLatestOrderAndItems();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Lỗi tải order: $e');
    } finally {
      if (mounted) {
        ref.read(_isLoadingExistingProvider.notifier).state = false;
      }
    }
  }

  Future<void> _fetchLatestOrderAndItems() async {
    final orderApi = ref.read(orderApiProvider);
    final orderItemApi = ref.read(orderItemApiProvider);

    final orders = await orderApi.fetchOrdersByTableIdToday(widget.tableId);
    if (orders.isEmpty) {
      if (!mounted) return;
      setState(() {
        _currentOrder = null;
        _existingOrderItems = [];
      });
      return;
    }

    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Choose the most recent active order (status 2 only). If none, clear current order.
    Order? current;
    for (final order in orders) {
      if (order.statusId == 2) {
        current = order;
        break;
      }
    }

    if (current == null) {
      if (!mounted) return;
      setState(() {
        _currentOrder = null;
        _existingOrderItems = [];
      });
      return;
    }

    final items = await orderItemApi.getOrderItemsByOrderId(current.id);
    if (!mounted) return;

    setState(() {
      _currentOrder = current;
      _existingOrderItems = items;
    });

    // Debug: Print order info
    print('Current order ID: ${current.id}, Status: ${current.statusId}');
    print('Total orders for table: ${orders.length}');
    for (var order in orders) {
      print('Order ${order.id}: status ${order.statusId}');
    }
  }

  //Hàm lưu (ĐÃ HOÀN THIỆN - FIX DUPLICATE ORDER)
  Future<void> _saveOrder() async {
    if (ref.watch(_isSavingProvider)) return;

    final cartItems = ref.read(cartNotifierProvider);
    if (cartItems.isEmpty) {
      Constrats.showThongBao(context, 'Vui lòng chọn món trước khi gửi order.');
      return;
    }

    if (widget.companyId == null ||
        widget.branchId == null ||
        widget.userId == null) {
      Constrats.showThongBao(
        context,
        'Thiếu thông tin chi nhánh hoặc người tạo order.',
      );
      return;
    }

    ref.read(_isSavingProvider.notifier).state = true;

    try {
      final orderApi = ref.read(orderApiProvider);
      final bool isUpdate = _currentOrder != null;

      late final Order targetOrder;
      if (_currentOrder == null) {
        // Kiểm tra lại xem có order nào đang active cho bàn này không
        final existingOrders = await orderApi.fetchOrdersByTableIdToday(
          widget.tableId,
        );
        final activeOrder =
            existingOrders.where((order) => order.statusId == 2).toList();

        if (activeOrder.isNotEmpty) {
          // Nếu có order active, sử dụng order đó thay vì tạo mới
          targetOrder = activeOrder.first;
          _currentOrder = targetOrder;
        } else {
          // Chỉ tạo order mới khi thực sự không có order active
          final newOrder = Order(
            tableId: widget.tableId,
            companyId: widget.companyId!,
            branchId: widget.branchId!,
            userId: widget.userId!,
            promotionId: null,
            note:
                ref.read(_orderNoteProvider).isEmpty
                    ? null
                    : ref.read(_orderNoteProvider),
            statusId: 2, // Đang phục vụ
          );

          final savedOrder = await orderApi.saveOrder(newOrder);
          if (savedOrder == null || savedOrder.id == 0) {
            Constrats.showThongBao(
              context,
              'Không thể tạo order. Vui lòng thử lại.',
            );
            return;
          }
          targetOrder = savedOrder;
          _currentOrder = savedOrder;
        }
      } else {
        targetOrder = _currentOrder!;
      }

      final Map<int, int> quantityByItem = {};
      for (final item in cartItems) {
        final itemId = item.id;
        if (itemId == null) continue;
        quantityByItem.update(itemId, (value) => value + 1, ifAbsent: () => 1);
      }

      final orderItems =
          quantityByItem.entries
              .map(
                (entry) => OrderItem(
                  orderId: targetOrder.id,
                  itemId: entry.key,
                  quantity: entry.value,
                  note: ref.read(_itemNotesProvider)[entry.key],
                  statusId: 1, // Đang phục vụ
                  addedBy: widget.userId,
                  servedBy: null,
                ),
              )
              .toList();

      if (orderItems.isNotEmpty) {
        await orderApi.saveOrderItems(orderItems);
      }

      ref.read(cartNotifierProvider.notifier).clearCart();
      ref.read(_orderNoteProvider.notifier).state =
          ''; // Reset note after saving
      await _reloadExistingOrder(targetOrder);

      Constrats.showThongBao(
        context,
        isUpdate ? 'Đã cập nhật order.' : 'Gửi order thành công.',
      );
    } catch (e) {
      Constrats.showThongBao(context, 'Gửi order thất bại: $e');
    } finally {
      if (mounted) {
        ref.read(_isSavingProvider.notifier).state = false;
      }
    }
  }

  Future<void> _requestPayment() async {
    if (_currentOrder == null || ref.watch(_isRequestingPaymentProvider)) {
      return;
    }

    ref.read(_isRequestingPaymentProvider.notifier).state = true;

    try {
      // Update order status to 4 (requesting payment) before navigating
      final orderApi = ref.read(orderApiProvider);
      final updatedOrder = await orderApi.updateOrderStatusAlt(
        _currentOrder!.id,
        4,
      );

      // Update local state
      setState(() {
        _currentOrder = updatedOrder;
      });

      // Thanh toán ngay lập tức - chuyển trực tiếp đến màn hình thanh toán
      if (mounted) {
        // Đóng drawer nếu đang mở
        if (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) {
          Navigator.of(context).pop();
        }

        // Chuyển đến màn hình thanh toán
        Routes.pushRightLeftConsumerFul(
          context,
          ScreenPayment(
            tableId: widget.tableId,
            tableName: widget.tableName,
            order: _currentOrder!,
            orderItems: _existingOrderItems,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) {
        ref.read(_isRequestingPaymentProvider.notifier).state = false;
      }
    }
  }

  Future<void> _reloadExistingOrder(Order order) async {
    try {
      final orderItemApi = ref.read(orderItemApiProvider);
      final items = await orderItemApi.getOrderItemsByOrderId(order.id);
      if (!mounted) return;
      setState(() {
        _currentOrder = order;
        _existingOrderItems = items;
      });

      // Check if all order items are served (statusId == 3) and order is not already requesting payment
      if (_existingOrderItems.isNotEmpty &&
          _existingOrderItems.every((item) => item.statusId == 3) &&
          _currentOrder?.statusId != 4) {
        // Automatically request payment when all items are served
        await _requestPayment();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Lỗi tải lại order item: $e');
    }
  }

  List<_DisplayOrderItem> _buildExistingDisplay(List<Item> menuItems) {
    if (_existingOrderItems.isEmpty) return <_DisplayOrderItem>[];

    final menuMap = <int, Item>{};
    for (final menuItem in menuItems) {
      final id = menuItem.id;
      if (id != null) {
        menuMap[id] = menuItem;
      }
    }

    final Map<int, int> counts = {};
    for (final orderItem in _existingOrderItems) {
      counts.update(
        orderItem.itemId,
        (value) => value + orderItem.quantity,
        ifAbsent: () => orderItem.quantity,
      );
    }

    final List<_DisplayOrderItem> display = <_DisplayOrderItem>[];
    counts.forEach((itemId, quantity) {
      final menuItem = menuMap[itemId];
      if (menuItem != null) {
        display.add(_DisplayOrderItem(item: menuItem, quantity: quantity));
      }
    });

    return display;
  }

  List<_DisplayOrderItem> _buildCartDisplay(List<Item> cartItems) {
    if (cartItems.isEmpty) return <_DisplayOrderItem>[];

    final Map<int, int> counts = {};
    final Map<int, Item> itemsById = {};

    for (final item in cartItems) {
      final id = item.id;
      if (id == null) continue;
      counts.update(id, (value) => value + 1, ifAbsent: () => 1);
      itemsById[id] = item;
    }

    final List<_DisplayOrderItem> display = <_DisplayOrderItem>[];
    counts.forEach((itemId, quantity) {
      final item = itemsById[itemId];
      if (item != null) {
        display.add(_DisplayOrderItem(item: item, quantity: quantity));
      }
    });

    return display;
  }

  int _combinedQuantity(
    List<_DisplayOrderItem> existing,
    List<_DisplayOrderItem> current,
  ) {
    int total = 0;
    for (final entry in existing) {
      total += entry.quantity;
    }
    for (final entry in current) {
      total += entry.quantity;
    }
    return total;
  }

  double _combinedPrice(
    List<_DisplayOrderItem> existing,
    List<_DisplayOrderItem> current,
  ) {
    double total = 0;
    for (final entry in existing) {
      total += entry.item.price * entry.quantity;
    }
    for (final entry in current) {
      total += entry.item.price * entry.quantity;
    }
    return total;
  }

  Widget _buildCartListTile(_DisplayOrderItem entry, ThemeData theme) {
    final item = entry.item;
    final quantity = entry.quantity;
    final itemId = item.id ?? 0;
    final currentNote = ref.watch(_itemNotesProvider)[itemId] ?? '';
    final isExpanded = ref.watch(_expandedNotesProvider).contains(itemId);

    // Get or create controller for this item
    if (!_itemNoteControllers.containsKey(itemId)) {
      _itemNoteControllers[itemId] = TextEditingController(text: currentNote);
    }
    TextEditingController controller = _itemNoteControllers[itemId]!;
    if (controller.text != currentNote) {
      controller.text = currentNote;
    }

    return Column(
      children: [
        ListTile(
          title: Text(item.name, style: Style.fontNormal),
          subtitle: Text(
            '${item.price.toStringAsFixed(3)} đ',
            style: Style.fontCaption,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  LucideIcons.minusCircle,
                  size: 20,
                  color: Colors.red,
                ),
                onPressed: () => _removeItem(item),
              ),
              Text(
                '$quantity',
                style: Style.fontNormal.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(
                  LucideIcons.plusCircle,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                onPressed: () => _addItem(item),
              ),
            ],
          ),
          onTap: () {
            final currentExpanded = ref.read(_expandedNotesProvider);
            final newExpanded = Set<int>.from(currentExpanded);
            if (newExpanded.contains(itemId)) {
              newExpanded.remove(itemId);
            } else {
              newExpanded.add(itemId);
            }
            ref.read(_expandedNotesProvider.notifier).state = newExpanded;
          },
        ),
        if (currentNote.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.messageSquare,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      currentNote,
                      style: Style.fontCaption.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Ghi chú cho ${item.name} (tùy chọn)',
                hintText: 'Ví dụ: ít cay, nhiều rau...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              maxLines: 1,
              controller: controller,
              onChanged: (value) {
                final currentNotes = ref.read(_itemNotesProvider);
                final updatedNotes = Map<int, String>.from(currentNotes);
                if (value.isEmpty) {
                  updatedNotes.remove(itemId);
                } else {
                  updatedNotes[itemId] = value;
                }
                ref.read(_itemNotesProvider.notifier).state = updatedNotes;
              },
            ),
          ),
      ],
    );
  }

  void _addItem(Item item) {
    ref.read(cartNotifierProvider.notifier).addItemToCart(item);
  }

  void _removeItem(Item item) {
    ref.read(cartNotifierProvider.notifier).removeItemFromCart(item);
  }

  int get _totalItemCount {
    final _selectedItems = ref.read(cartNotifierProvider); // Đọc state mới nhất
    if (_selectedItems.isEmpty) return 0;
    return _selectedItems.length;
  }

  @override
  Widget build(BuildContext context) {
    final _menuItems = ref.watch(menuNotifierProvider);
    final _selectedItems = ref.watch(cartNotifierProvider);
    final drawerWidth = MediaQuery.of(context).size.width * 0.82;

    // Lọc menu theo từ khóa tìm kiếm
    final List<Item> filteredMenuItems =
        _searchKeyword.isEmpty
            ? _menuItems
            : _menuItems.where((item) {
              final itemName = _removeVietnameseDiacritics(item.name);
              final keyword = _removeVietnameseDiacritics(_searchKeyword);
              return itemName.contains(keyword);
            }).toList();

    return Scaffold(
      key: _scaffoldKey,
      onEndDrawerChanged: (isOpened) {
        ref.read(_openBillProvider.notifier).state = isOpened;
      },
      // --- GIỎ HÀNG (ENDDRAWER) (ĐÃ CẬP NHẬT LOGIC) ---
      endDrawer: Drawer(
        width: drawerWidth,
        child: SafeArea(
          child: Column(
            children: [
              ListTile(
                title: Text(
                  'Order của bàn ${widget.tableName}',
                  style: Style.fontTitleMini.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Builder(
                  // Dùng Builder để lấy _menuItems từ context
                  builder: (context) {
                    // *** ĐỌC GIỎ HÀNG (List<Item>) TỪ PROVIDER ***
                    final cartItems = ref.watch(cartNotifierProvider);
                    final existingDisplay = _buildExistingDisplay(_menuItems);
                    final cartDisplay = _buildCartDisplay(cartItems);
                    final theme = Theme.of(context);
                    final isLoadingExisting = ref.watch(
                      _isLoadingExistingProvider,
                    );

                    if (isLoadingExisting &&
                        existingDisplay.isEmpty &&
                        cartDisplay.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (existingDisplay.isEmpty && cartDisplay.isEmpty) {
                      return const Center(
                        child: Text('Chưa có món nào cho bàn này.'),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        if (_currentOrder != null) {
                          await _reloadExistingOrder(_currentOrder!);
                        }
                      },
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          if (existingDisplay.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    LucideIcons.checkCircle,
                                    size: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Món đã order hôm nay',
                                    style: Style.fontNormal.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...existingDisplay.map(
                              (entry) => Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  dense: true,
                                  title: Text(
                                    entry.item.name,
                                    style: Style.fontNormal.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${entry.item.price.toStringAsFixed(3)} đ',
                                    style: Style.fontCaption,
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'x${entry.quantity}',
                                        style: Style.fontNormal.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: Icon(
                                          LucideIcons.plusCircle,
                                          size: 20,
                                          color: theme.colorScheme.primary,
                                        ),
                                        tooltip: 'Thêm 1 phần',
                                        onPressed: () => _addItem(entry.item),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const Divider(height: 16),
                          ],
                          if (cartDisplay.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    LucideIcons.shoppingCart,
                                    size: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Món đang chọn',
                                    style: Style.fontNormal.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...cartDisplay.map(
                              (entry) => _buildCartListTile(entry, theme),
                            ),
                          ] else if (existingDisplay.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Text(
                                'Chưa chọn thêm món mới.',
                                style: Style.fontCaption,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
              // *** KẾT THÚC SỬA LISTVIEW ***
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // *** BỎ COMMENT VÀ SỬA LẠI TỔNG TIỀN ***
                    Builder(
                      builder: (context) {
                        final existingDisplay = _buildExistingDisplay(
                          _menuItems,
                        );
                        final cartDisplay = _buildCartDisplay(_selectedItems);
                        final totalQuantity = _combinedQuantity(
                          existingDisplay,
                          cartDisplay,
                        );
                        final totalPrice = _combinedPrice(
                          existingDisplay,
                          cartDisplay,
                        );

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tổng cộng ($totalQuantity món):',
                              style: Style.fontNormal,
                            ),
                            Text(
                              '${totalPrice.toStringAsFixed(3)} đ',
                              style: Style.fontTitleMini.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    // *** KẾT THÚC SỬA TỔNG TIỀN ***
                    const SizedBox(height: 16),
                    // Order Note Input
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Ghi chú đơn hàng (tùy chọn)',
                        hintText: 'Nhập ghi chú cho đơn hàng...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      maxLines: 2,
                      onChanged: (value) {
                        ref.read(_orderNoteProvider.notifier).state = value;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                _selectedItems.isEmpty ||
                                        ref.watch(_isSavingProvider)
                                    ? null
                                    : _saveOrder,
                            child:
                                ref.watch(_isSavingProvider)
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : const Text('GỬI ORDER'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                _currentOrder == null ||
                                        ref.watch(_isRequestingPaymentProvider)
                                    ? null
                                    : _requestPayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _currentOrder?.statusId == 4
                                      ? Colors.green
                                      : Colors.orange,
                            ),
                            child:
                                ref.watch(_isRequestingPaymentProvider)
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : Text(
                                      _currentOrder?.statusId == 3
                                          ? 'Đã yêu cầu'
                                          : 'THANH TOÁN',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        leading: IconBack.back(context),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: Theme.of(context).iconTheme,
        title:
            _showSearchBar
                ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm món...',
                    border: InputBorder.none,
                    //lay corlor he
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchKeyword = value;
                    });
                  },
                )
                : Text(widget.tableName, style: Style.fontTitle),
        centerTitle: false,

        actions: [
          if (!_showSearchBar)
            IconButton(
              icon: const Icon(LucideIcons.search),
              onPressed: () {
                setState(() {
                  _showSearchBar = true;
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _showSearchBar = false;
                  _searchKeyword = '';
                  _searchController.clear();
                });
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Style.paddingPhone,
            vertical: 16,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _textSpinner(context),
                  const SizedBox(height: 12),
                  // ĐÃ CHUYỂN TÌM KIẾM LÊN APPBAR
                  if (_showSearchBar) const SizedBox(height: 12),
                  Expanded(child: _listMenu(filteredMenuItems)),
                ],
              ),
              _actionButton(context),
            ],
          ),
        ),
      ),
    );
  }

  //Tiêu đề món ăn & spinner (Không đổi)
  Widget _textSpinner(BuildContext context) {
    final dropdownItems = <String>[
      'Tất cả',
      'Món khai vị',
      'Món chính',
      'Tráng miệng',
      'Đồ uống',
    ];
    final dropdownMenus = <String>['Tất cả', 'Menu ngày thường'];

    return Row(
      children: [
        DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            items:
                dropdownMenus
                    .map(
                      (value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    )
                    .toList(),
            value: ref.watch(_selectedMenuProvider),
            onChanged: (value) {
              if (value == null) return;
              ref.read(_selectedMenuProvider.notifier).state = value;
            },
            customButton: Row(
              children: [
                Text(
                  ref.watch(_selectedMenuProvider),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ],
            ),
            dropdownStyleData: DropdownStyleData(
              offset: const Offset(0, 0),
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              maxHeight: 240,
              width: 140,
            ),
            menuItemStyleData: const MenuItemStyleData(height: 44),
          ),
        ),
        const Spacer(),
        DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            items:
                dropdownItems
                    .map(
                      (value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    )
                    .toList(),
            value: ref.watch(_selectedCategoryProvider),
            onChanged: (value) {
              if (value == null) return;
              ref.read(_selectedCategoryProvider.notifier).state = value;
            },
            customButton: Row(
              children: [
                Text(
                  ref.watch(_selectedCategoryProvider),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ],
            ),
            dropdownStyleData: DropdownStyleData(
              offset: const Offset(0, 0),
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              maxHeight: 240,
              width: 140,
            ),
            menuItemStyleData: const MenuItemStyleData(height: 44),
          ),
        ),
      ],
    );
  }

  // --- _listMenu (ĐÃ CẬP NHẬT CÁC NÚT BẤM) ---
  Widget _listMenu(List<Item> menuItems) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;
    final cartItems = ref.watch(cartNotifierProvider);

    // Highlight items that have already been ordered for this table
    final orderedItemIds = _existingOrderItems.map((oi) => oi.itemId).toSet();

    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: menuItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemBuilder: (context, index) {
        final item = menuItems[index];
        final quantity =
            cartItems.where((cartItem) => cartItem.id == item.id).length;
        final isSelected = quantity > 0;
        final isOrdered = orderedItemIds.contains(item.id);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? primary.withOpacity(0.1)
                    : isOrdered
                    ? Colors.yellow.withOpacity(0.18)
                    : surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isSelected
                      ? primary
                      : isOrdered
                      ? Colors.orange
                      : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color:
                          isSelected
                              ? primary
                              : isOrdered
                              ? Colors.orange
                              : onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${item.price.toStringAsFixed(3)} đ',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          isSelected
                              ? primary.withOpacity(0.8)
                              : isOrdered
                              ? Colors.orange.withOpacity(0.8)
                              : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              if (!isSelected)
                Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(LucideIcons.plusCircle, color: primary),
                    onPressed: () {
                      _addItem(item);
                    },
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        LucideIcons.minusCircle,
                        size: 22,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        _removeItem(item);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '$quantity',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        LucideIcons.plusCircle,
                        size: 22,
                        color: primary,
                      ),
                      // *** SỬA ONPRESSED ***
                      onPressed: () {
                        _addItem(item);
                      },
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  //Nút hành động show ra order (Không đổi)
  Widget _actionButton(BuildContext context) {
    final theme = Theme.of(context);
    final isOpen = ref.watch(_openBillProvider);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return AnimatedAlign(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      alignment: isOpen ? Alignment.bottomLeft : Alignment.bottomRight,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset + 8),
        child: Badge(
          label: Text('$_totalItemCount'),
          isLabelVisible: _totalItemCount > 0 && !isOpen,
          backgroundColor: Colors.red,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 6,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(16),
              backgroundColor: theme.colorScheme.primary,
            ),
            onPressed: () {
              final scaffoldState = _scaffoldKey.currentState;
              final nextState = !isOpen;
              ref.read(_openBillProvider.notifier).state = nextState;
              if (nextState) {
                scaffoldState?.openEndDrawer();
              } else {
                scaffoldState?.closeEndDrawer();
              }
            },
            child: AnimatedRotation(
              turns: isOpen ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Icon(
                Icons.arrow_back,
                color: theme.colorScheme.onPrimary,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
