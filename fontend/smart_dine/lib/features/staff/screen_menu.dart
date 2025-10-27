import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mart_dine/API/order_API.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/widgets/appbar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
// Import provider của bạn để gọi API
import 'package:mart_dine/providers/order_provider.dart';
// Giả sử bạn có model OrderItem đã import
import 'package:mart_dine/models/order_item.dart';

class ScreenMenu extends ConsumerStatefulWidget {
  final String tableName;
  final int tableId; // ID của bàn (đã là int)

  const ScreenMenu({
    super.key,
    required this.tableName,
    required this.tableId,
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

  // NÂNG CẤP: Danh sách món ăn giờ có ID là SỐ (int)
  final List<_MenuItem> _menuItems = const [
    _MenuItem(id: 1, name: 'Bánh mì', price: 242.3243),
    _MenuItem(id: 2, name: 'Phở bò', price: 185.000),
    _MenuItem(id: 3, name: 'Gỏi cuốn', price: 82.000),
    _MenuItem(id: 4, name: 'Cà phê sữa', price: 45.000),
    _MenuItem(id: 5, name: 'Trà đào', price: 55.000),
    _MenuItem(id: 6, name: 'Bánh flan', price: 39.000),
    _MenuItem(id: 7, name: 'Bít tết', price: 289.000),
    _MenuItem(id: 8, name: 'Mì Ý', price: 165.000),
    _MenuItem(id: 9, name: 'Súp bí đỏ', price: 98.0000),
    _MenuItem(id: 10, name: 'Salad cá ngừ', price: 123.000),
    _MenuItem(id: 11, name: 'Bánh mì pate', price: 74.500),
    _MenuItem(id: 12, name: 'Trà trái cây', price: 69.0000),
  ];

  // NÂNG CẤP: Sử dụng Map<int, int> để lưu {itemId: quantity}
  final Map<int, int> _selectedItems = {};

  // Biến trạng thái
  bool _isLoading = true;
  int? _currentOrderId; // NÂNG CẤP: Lưu ID của order (kiểu int?)

  @override
  void initState() {
    super.initState();
    _loadExistingOrder();
  }

  // HÀM TẢI ORDER (ĐÃ CẬP NHẬT DÙNG int)
  Future<void> _loadExistingOrder() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orderApi = ref.read(orderApiProvider);

      // 1. Tìm order của bàn
      final existingOrders =
          await orderApi.fetchOrdersByTableIdToday(widget.tableId);

      if (existingOrders.isNotEmpty) {
        final order = existingOrders.first;
        _currentOrderId = order.id; // Lưu ID (kiểu int?)

        if (_currentOrderId == null) return; // Không có ID order thì dừng

        // 2. Tải các OrderItem của order này
        print('Đang tải items cho order ID: $_currentOrderId');
        final fetchedItems = await orderApi.fetchOrderItems(_currentOrderId! as String);

        // 3. Cập nhật state (giỏ hàng)
        setState(() {
          _selectedItems.clear();
          for (var item in fetchedItems) {
            // item.itemId bây giờ là int
            _selectedItems[item.itemId] = item.quantity;
          }
        });
      }
    } catch (e) {
      print('Lỗi khi tải order cũ: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // HÀM LƯU ORDER (ĐÃ CẬP NHẬT DÙNG int)
  Future<void> _saveOrder() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đang lưu order...')),
    );

    try {
      final orderApi = ref.read(orderApiProvider);

      // 1. Kiểm tra xem đã có order chưa
      if (_currentOrderId == null) {
        // CHƯA CÓ: Tạo Order mới
        // TODO: Cung cấp các ID này từ provider (ví dụ: userProvider)
        const int mockUserId = 1;
        const int mockCompanyId = 1;
        const int mockBranchId = 1;

        print('Tạo order mới cho bàn ${widget.tableId}');
        final newOrder = await orderApi.createOrder(
          tableId: widget.tableId,
          userId: mockUserId,
          companyId: mockCompanyId,
          branchId: mockBranchId,
        );
        _currentOrderId = newOrder.id; // Lưu ID (kiểu int)
      }

      if (_currentOrderId == null) {
        throw Exception('Không thể tạo hoặc lấy order ID');
      }

      // 2. Chuẩn bị danh sách OrderItem từ _selectedItems
      final List<Map<String, dynamic>> itemsToSave = [];
      _selectedItems.forEach((itemId, quantity) {
        itemsToSave.add({
          // Gửi đi itemId (kiểu int)
          'item_id': itemId, 
          'quantity': quantity,
          'note': null, 
          // Bạn có thể cần thêm orderId vào mỗi item nếu backend yêu cầu
          'order_id': _currentOrderId,
        });
      });

      // 3. Gọi API để lưu OrderItem
      print('Đang lưu ${itemsToSave.length} món cho order: $_currentOrderId');
      final success =
          await orderApi.saveOrderItems(_currentOrderId! as String, itemsToSave);

      // 4. Thông báo kết quả
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lưu order thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Lưu order thất bại');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi lưu order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- Các hàm tính toán (ĐÃ CẬP NHẬT DÙNG int) ---
  int get _totalItemCount {
    if (_selectedItems.isEmpty) return 0;
    return _selectedItems.values.reduce((sum, count) => sum + count);
  }

  double get _totalPrice {
    if (_selectedItems.isEmpty) return 0.0;
    double total = 0.0;
    _selectedItems.forEach((itemId, quantity) {
      final item = _findItemById(itemId); // Tìm bằng int ID
      total += item.price * quantity;
    });
    return total;
  }

  _MenuItem _findItemById(int id) {
    // Tìm món ăn trong menu theo int ID
    return _menuItems.firstWhere((item) => item.id == id,
        orElse: () => _MenuItem(id: 0, name: 'Món lạ', price: 0));
  }

  @override
  Widget build(BuildContext context) {
    final drawerWidth = MediaQuery.of(context).size.width * 0.82;
    return Scaffold(
      key: _scaffoldKey,
      onEndDrawerChanged: (isOpened) {
        ref.read(_openBillProvider.notifier).state = isOpened;
      },
      // --- GIỎ HÀNG (ENDDRAWER) (ĐÃ CẬP NHẬT DÙNG int) ---
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
                child: _selectedItems.isEmpty
                    ? const Center(
                        child: Text('Chưa có món ăn nào được chọn.'),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: _selectedItems.length,
                        itemBuilder: (context, index) {
                          final itemId = _selectedItems.keys.elementAt(index); // itemId là int
                          final item = _findItemById(itemId);
                          final quantity = _selectedItems[itemId]!;

                          return ListTile(
                            title: Text(item.name),
                            subtitle: Text(
                              '${item.price.toStringAsFixed(3)} đ',
                              style: Style.fontCaption,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(LucideIcons.minusCircle,
                                      size: 20, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      if (quantity > 1) {
                                        _selectedItems[itemId] = quantity - 1;
                                      } else {
                                        _selectedItems.remove(itemId);
                                      }
                                    });
                                  },
                                ),
                                Text(
                                  '$quantity',
                                  style: Style.fontNormal.copyWith(
                                      fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon: const Icon(LucideIcons.plusCircle,
                                      size: 20, color: Colors.green),
                                  onPressed: () {
                                    setState(() {
                                      _selectedItems[itemId] = quantity + 1;
                                    });
                                  },
                                ),
                              ],
                            ),
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
                        Text('Tổng cộng (${_totalItemCount} món):',
                            style: Style.fontNormal),
                        Text(
                          '${_totalPrice.toStringAsFixed(3)} đ',
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
                        Expanded(child: _listMenu()),
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

  // --- _listMenu (ĐÃ CẬP NHẬT DÙNG int) ---
  Widget _listMenu() {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;

    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: _menuItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemBuilder: (context, index) {
        final item = _menuItems[index];
        // Lấy số lượng bằng item.id (int)
        final quantity = _selectedItems[item.id] ?? 0;
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
                      color: isSelected ? primary.withOpacity(0.8) : Colors.grey.shade600,
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
                      setState(() {
                        // Thêm bằng item.id (int)
                        _selectedItems[item.id] = 1;
                      });
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
                      icon: const Icon(LucideIcons.minusCircle,
                          size: 22, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          if (quantity > 1) {
                            // Cập nhật bằng item.id (int)
                            _selectedItems[item.id] = quantity - 1;
                          } else {
                            // Xóa bằng item.id (int)
                            _selectedItems.remove(item.id);
                          }
                        });
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
                      icon: Icon(LucideIcons.plusCircle, size: 22, color: primary),
                      onPressed: () {
                        setState(() {
                          // Cập nhật bằng item.id (int)
                          _selectedItems[item.id] = quantity + 1;
                        });
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

// NÂNG CẤP: Lớp _MenuItem giờ có ID là SỐ (int)
class _MenuItem {
  final int id;
  final String name;
  final double price;

  const _MenuItem({
    required this.id,
    required this.name,
    required this.price,
  });
}