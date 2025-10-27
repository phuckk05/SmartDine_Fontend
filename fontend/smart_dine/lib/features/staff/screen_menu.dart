import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/models/item.dart';
import 'package:mart_dine/providers/cart_provider.dart';
import 'package:mart_dine/providers/menu_item_provider.dart';
import 'package:mart_dine/providers/order_item_provider.dart';
import 'package:mart_dine/widgets/appbar.dart';
// Import provider của bạn để gọi API
import 'package:mart_dine/providers/order_provider.dart';
// Giả sử bạn có model OrderItem đã import
import 'package:mart_dine/models/order_item.dart';
import 'package:mart_dine/models/order.dart';
import 'package:mart_dine/providers/cart_notifier_provider.dart';

////
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

//State provider
final _selectedCategoryProvider = StateProvider<String>((ref) => 'Tất cả');
final _selectedMenuProvider = StateProvider<String>((ref) => 'Tất cả');
final _openBillProvider = StateProvider<bool>((ref) => false);

class _ScreenMenuState extends ConsumerState<ScreenMenu> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // NÂNG CẤP: Sử dụng Map<int, int> để lưu {itemId: quantity}
  //final Map<int, int> _selectedItems = {};

  // Biến trạng thái
  bool _isLoading = true;
  int? _currentOrderId;
  bool _isSaving = false;

  //List<Item> items = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadItemsAndOrder);
  }

  // HÀM TẢI ORDER (ĐÃ CẬP NHẬT)
  Future<void> _loadItemsAndOrder() async {
    if (mounted) setState(() => _isLoading = true); // setState này OK
    try {
      // Tải menu
      await ref
          .read(menuNotifierProvider.notifier)
          .loadMenusByCompanyId(widget.companyId ?? 1);

      // Lấy order cũ
      await ref
          .read(orderNotifierProvider.notifier)
          .fetchByTableIdToday(widget.tableId);
      final orders = ref.read(orderNotifierProvider);
      if (orders.isNotEmpty) {
        _currentOrderId = orders.first.id;
        // TODO: Tải OrderItem và add vào cartProvider
      }
    } catch (e) {
      print('Lỗi khi tải menu items: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false); // setState này OK
    }
  }

  //Hàm lưu (ĐÃ HOÀN THIỆN)
  Future<void> _saveOrder() async {
    // Đọc giỏ hàng (List<Item>) từ provider
    final cartItems = ref.read(cartNotifierProvider);

    if (_isSaving || cartItems.isEmpty) return;

    setState(() => _isSaving = true); // setState này OK

    try {
      int? orderId = _currentOrderId;

      // 1. TẠO ORDER MỚI (nếu bàn này chưa có order)
     if (orderId == null) {
        Order orderData = Order.create(
          tableId: widget.tableId,
          companyId: widget.companyId ?? 1, 
          branchId: widget.branchId ?? 1,   // Giả sử ID mặc định là 1
          userId: widget.userId ?? 1,       // Giữ nguyên
          statusId: 1, // 1 = Trạng thái "Mới"
        );
        final newOrder = await ref
            .read(orderNotifierProvider.notifier)
            .createOrder(orderData);
        if (newOrder == null || newOrder.id == null) {
          throw Exception('Không thể tạo order mới từ server.');
        }
        orderId = newOrder.id!;
      }

      // 1. Đếm số lượng từ List<Item> (Rất chậm)
      final Map<int, int> itemCounts = {};
      for (var item in cartItems) {
        itemCounts[item.id!] = (itemCounts[item.id!] ?? 0) + 1;
      }

      // 2. TẠO LIST<ORDERITEM> TỪ Map ĐẾM ĐƯỢC
      final List<OrderItem> itemsToSave = [];

      for (var entry in itemCounts.entries) {
        final itemId = entry.key;
        final quantity = entry.value;

        // 3. GÁN orderId VÀO TỪNG MÓN ĂN
        final orderItem = OrderItem.create(
          orderId: orderId,
          itemId: itemId,
          quantity: quantity,
          statusId: 1,
          addedBy: widget.userId ?? 72,
          createdAt: DateTime.now(),
        );
        itemsToSave.add(orderItem);
      }

      // 4. GỬI DANH SÁCH MÓN ĂN LÊN API
      if (itemsToSave.isNotEmpty) {
        ref.read(orderItemNotifierProvider.notifier).addOrderItem(itemsToSave);
      }

      // 5. XỬ LÝ THÀNH CÔNG
      ref.read(cartNotifierProvider.notifier).clearCart(); // Xóa giỏ hàng

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã gửi order cho ${widget.tableName}!')),
        );
      }
    } catch (e) {
      print('Lỗi khi gửi order: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gửi order thất bại: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // --- HÀM THÊM ITEM (KHÔNG DÙNG setState) ---
  void _addItem(Item item) {
    ref.read(cartNotifierProvider.notifier).addItemToCart(item);
  }

  // --- HÀM BỚT ITEM (KHÔNG DÙNG setState) ---
  void _removeItem(Item item) {
    ref.read(cartNotifierProvider.notifier).removeItemFromCart(item);
  }

  // --- Các hàm tính toán (ĐỌC TỪ PROVIDER) ---
  int get _totalItemCount {
    final _selectedItems = ref.read(cartNotifierProvider); // Đọc state mới nhất
    if (_selectedItems.isEmpty) return 0;
    return _selectedItems.length;
  }

  double get _totalPrice {
    // Đọc giỏ hàng (List<Item>) từ provider
    final _selectedItems = ref.read(cartNotifierProvider);

    if (_selectedItems.isEmpty) return 0.0;

    // Dùng .fold() để cộng dồn giá của từng item trong List
    // 'sum' là tổng, 'item' là món ăn hiện tại
    return _selectedItems.fold(0.0, (sum, item) => sum + item.price);
  }

  @override
  Widget build(BuildContext context) {
    final _menuItems = ref.watch(menuNotifierProvider);
    final _selectedItems = ref.watch(cartNotifierProvider);
    final drawerWidth = MediaQuery.of(context).size.width * 0.82;

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
                child: Builder( // Dùng Builder để lấy _menuItems từ context
                  builder: (context) {
                    // *** ĐỌC GIỎ HÀNG (List<Item>) TỪ PROVIDER ***
                    final _selectedItems = ref.watch(cartNotifierProvider); 

                    if (_selectedItems.isEmpty) {
                      return const Center(
                        child: Text('Chưa có món ăn nào được chọn.'),
                      );
                    }

                    // *** BƯỚC 1: ĐẾM SỐ LƯỢNG (Group by ID) ***
                    final Map<int, int> itemCounts = {};
                    final Map<int, Item> itemMap = {}; // Lưu trữ item duy nhất
                    
                    for (var item in _selectedItems) {
                      if (item.id != null) {
                        // Đếm số lần 'itemId' xuất hiện
                        itemCounts[item.id!] = (itemCounts[item.id!] ?? 0) + 1;
                        itemMap[item.id!] = item; // Lưu lại item mẫu (chỉ cần 1)
                      }
                    }
                    
                    // Lấy danh sách ID duy nhất
                    final uniqueItemIds = itemCounts.keys.toList();

                    // *** BƯỚC 2: BUILD LISTVIEW TỪ MAP ĐÃ ĐẾM ***
                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: uniqueItemIds.length, // Lặp qua số item DUY NHẤT
                      itemBuilder: (context, index) {
                        final itemId = uniqueItemIds[index];
                        final quantity = itemCounts[itemId]!; // Lấy số lượng đã đếm
                        final item = itemMap[itemId]!; // Lấy item mẫu từ Map

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
                                onPressed: () {
                                  _removeItem(item); // Gọi hàm provider
                                },
                              ),
                              Text(
                                '$quantity', // Hiển thị số lượng đã đếm
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
                                onPressed: () {
                                  _addItem(item); // Gọi hàm provider
                                },
                              ),
                            ],
                          ),
                        );
                      },
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tổng cộng ($_totalItemCount món):',
                          style: Style.fontNormal,
                        ),
                        Text(
                          '${_totalPrice.toStringAsFixed(3)} đ',
                          style: Style.fontTitleMini.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    // *** KẾT THÚC SỬA TỔNG TIỀN ***
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedItems.isEmpty ? null : _saveOrder,
                        child: const Text('GỬI ORDER'),
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
          IconButton(icon: const Icon(LucideIcons.search), onPressed: () {}),
        ],
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Style.paddingPhone,
            vertical: 16,
          ),
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Stack(
                    fit: StackFit.expand,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _textSpinner(context),
                          const SizedBox(height: 16),
                          Expanded(child: _listMenu(_menuItems)),
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
        // Lấy số lượng bằng item.id (int)
        final quantity =
            cartItems.where((cartItem) => cartItem.id == item.id).length;
        final isSelected = quantity > 0;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color:
                cartItems.contains(item) ? primary.withOpacity(0.1) : surface,
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
                      color:
                          isSelected
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
                    // *** SỬA ONPRESSED ***
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
                      // *** SỬA ONPRESSED ***
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
