import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/models/item.dart';
import 'package:mart_dine/providers/cart_notifier_provider.dart';
import 'package:mart_dine/providers/menu_item_provider.dart';
import 'package:mart_dine/providers/order_item_provider.dart';
import 'package:mart_dine/widgets/appbar.dart';
import 'package:mart_dine/providers/order_provider.dart';
import 'package:mart_dine/models/order_item.dart';
import 'package:mart_dine/models/order.dart';

class ScreenMenu extends ConsumerStatefulWidget {
  final String tableName;
  final int tableId;
  final int? companyId;
  final int? branchId;
  final int? userId;

  const ScreenMenu({
    super.key,
    required this.tableName,
    required this.tableId,
    this.companyId,
    this.branchId,
    this.userId,
  });

  @override
  ConsumerState<ScreenMenu> createState() => _ScreenMenuState();
}

// State providers
final _selectedCategoryProvider = StateProvider<String>((ref) => 'Tất cả');
final _selectedMenuProvider = StateProvider<String>((ref) => 'Tất cả');
final _openBillProvider = StateProvider<bool>((ref) => false);

class _ScreenMenuState extends ConsumerState<ScreenMenu> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // UI State variables
  bool _isLoading = true;
  int? _currentOrderId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // ✅ SỬA: Dùng addPostFrameCallback để tránh lỗi StateNotifier
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cartNotifierProvider.notifier).clearCart();
      _loadItemsAndOrder();
    });
  }

  // Load menu and check for existing order
  Future<void> _loadItemsAndOrder() async {
    if (mounted) setState(() => _isLoading = true);
    
    try {
      // Load menu items
      await ref
          .read(menuNotifierProvider.notifier)
          .loadMenusByCompanyId(widget.companyId ?? 1);

      // Fetch existing orders for the table today
      await ref
          .read(orderNotifierProvider.notifier)
          .fetchByTableIdToday(widget.tableId);
          
      final orders = ref.read(orderNotifierProvider);
      if (orders.isNotEmpty) {
        _currentOrderId = orders.first.id;
        // TODO: Load OrderItems and add to cart
        // Example:
        // final orderItems = await ref.read(orderItemApiProvider).fetchOrderItemsByOrderId(_currentOrderId!);
        // for (var orderItem in orderItems) {
        //   final item = await getItemById(orderItem.itemId);
        //   for (int i = 0; i < orderItem.quantity; i++) {
        //     ref.read(cartNotifierProvider.notifier).addItemToCart(item);
        //   }
        // }
      }
    } catch (e) {
      print('Lỗi khi tải menu items: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể tải menu: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Save the order
  Future<void> _saveOrder() async {
    final cartItems = ref.read(cartNotifierProvider);

    if (_isSaving || cartItems.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      int? orderId = _currentOrderId;

      // 1. Create new Order if it doesn't exist
      if (orderId == null) {
        Order orderData = Order.create(
          tableId: widget.tableId,
          companyId: widget.companyId ?? 1,
          branchId: widget.branchId ?? 1,
          userId: widget.userId ?? 1,
          statusId: 1, // 1 = New/Pending
          note: "test order from staff app",
          promotionId: 1,
        );
        
        final newOrder = await ref
            .read(orderNotifierProvider.notifier)
            .createOrder(orderData);
            
        if (newOrder == null || newOrder.id == null) {
          throw Exception('Không thể tạo order mới từ server.');
        }
        orderId = newOrder.id!;
        _currentOrderId = orderId; // ✅ Lưu lại orderId
      }

      // 2. Count quantities from cart
      final Map<int, int> itemCounts = {};
      for (var item in cartItems) {
        if (item.id != null) {
          itemCounts[item.id!] = (itemCounts[item.id!] ?? 0) + 1;
        }
      }

      // 3. Create List<OrderItem>
      final List<OrderItem> itemsToSave = [];
      for (var entry in itemCounts.entries) {
        final itemId = entry.key;
        final quantity = entry.value;

        final orderItem = OrderItem.create(
          orderId: orderId,
          itemId: itemId,
          quantity: quantity,
          statusId: 1,
          note: 'test order item',
          addedBy: widget.userId ?? 1,
          createdAt: DateTime.now(),

        );
        itemsToSave.add(orderItem);
      }

      // 4. Send to API
      if (itemsToSave.isNotEmpty) {
        await ref
            .read(orderItemNotifierProvider.notifier)
            .addOrderItem(itemsToSave);
      }

      // 5. Success: Clear cart and navigate back
      ref.read(cartNotifierProvider.notifier).clearCart();

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã gửi order cho ${widget.tableName}!')),
        );
      }
    } catch (e) {
      print('Lỗi khi gửi order: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gửi order thất bại: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // Add item to cart
  void _addItem(Item item) {
    ref.read(cartNotifierProvider.notifier).addItemToCart(item);
  }

  // Remove item from cart
  void _removeItem(Item item) {
    ref.read(cartNotifierProvider.notifier).removeItemFromCart(item);
  }

  // Count specific item in cart
  int _countForItem(List<Item> cartItems, Item item) {
    if (item.id == null) return 0;
    return cartItems.where((i) => i.id == item.id).length;
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = ref.watch(menuNotifierProvider);
    final cartItems = ref.watch(cartNotifierProvider);

    // Calculate totals
    final totalItemCount = cartItems.length;
    final totalPrice = cartItems.fold(0.0, (sum, item) => sum + item.price);

    final drawerWidth = MediaQuery.of(context).size.width * 0.82;

    return Scaffold(
      key: _scaffoldKey,
      onEndDrawerChanged: (isOpened) {
        ref.read(_openBillProvider.notifier).state = isOpened;
      },
      // ===== END DRAWER (Cart) =====
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
                  builder: (context) {
                    if (cartItems.isEmpty) {
                      return const Center(
                        child: Text('Chưa có món ăn nào được chọn.'),
                      );
                    }

                    // Group items by ID and count
                    final Map<int, int> itemCounts = {};
                    final Map<int, Item> itemMap = {};

                    for (var item in cartItems) {
                      if (item.id != null) {
                        itemCounts[item.id!] = (itemCounts[item.id!] ?? 0) + 1;
                        itemMap[item.id!] = item;
                      }
                    }

                    final uniqueItemIds = itemCounts.keys.toList();

                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: uniqueItemIds.length,
                      itemBuilder: (context, index) {
                        final itemId = uniqueItemIds[index];
                        final quantity = itemCounts[itemId]!;
                        final item = itemMap[itemId]!;

                        return ListTile(
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
                                style: Style.fontNormal.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  LucideIcons.plusCircle,
                                  size: 20,
                                  color: Colors.green,
                                ),
                                onPressed: () => _addItem(item),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tổng cộng ($totalItemCount món):',
                          style: Style.fontNormal,
                        ),
                        Text(
                          '${totalPrice.toStringAsFixed(3)} đ',
                          style: Style.fontTitleMini.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (cartItems.isEmpty || _isSaving)
                            ? null
                            : _saveOrder,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('GỬI ORDER'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBarCus(
        title: widget.tableName,
        isCanpop: true,
        isButtonEnabled: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.search),
            onPressed: () {},
          ),
        ],
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Style.paddingPhone,
            vertical: 16,
          ),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _textSpinner(context),
                        const SizedBox(height: 16),
                        Expanded(child: _listMenu(menuItems, cartItems)),
                      ],
                    ),
                    _actionButton(context, totalItemCount),
                  ],
                ),
        ),
      ),
    );
  }

  // ===== DROPDOWN SPINNERS =====
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
            items: dropdownMenus
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
            items: dropdownItems
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

  // ===== MENU GRID =====
  Widget _listMenu(List<Item> menuItems, List<Item> cartItems) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;

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
        final quantity = _countForItem(cartItems, item);
        final isSelected = quantity > 0;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primary.withOpacity(0.1) : surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primary : Colors.grey.shade300,
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
                      color: isSelected ? primary : onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${item.price.toStringAsFixed(3)} đ',
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? primary.withOpacity(0.8)
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
                    onPressed: () => _addItem(item),
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
                      onPressed: () => _removeItem(item),
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
                      onPressed: () => _addItem(item),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  // ===== ACTION BUTTON (Floating Cart Button) =====
  Widget _actionButton(BuildContext context, int totalItemCount) {
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
          label: Text('$totalItemCount'),
          isLabelVisible: totalItemCount > 0 && !isOpen,
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