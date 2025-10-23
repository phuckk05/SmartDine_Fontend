import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mart_dine/features/cashier/screen_cashier_payment.dart';
import 'package:mart_dine/models/menu.dart';
import 'package:mart_dine/providers/menu_provider.dart';
import 'package:mart_dine/providers/table_provider.dart';

class ScreenChooseMenu extends ConsumerStatefulWidget {
  final String tableName;
  final int initialGuestCount;
  final List<String> existingItems;
  // Constructor không cần index nữa

  const ScreenChooseMenu({
    Key? key,
    required this.tableName,
    required this.initialGuestCount,
    required this.existingItems,
  }) : super(key: key);

  @override
  ConsumerState<ScreenChooseMenu> createState() => _ScreenChooseMenuState();
}

class _ScreenChooseMenuState extends ConsumerState<ScreenChooseMenu> {
  final ValueNotifier<bool> _isPanelOpen = ValueNotifier(false);

  @override
  void dispose() {
    _isPanelOpen.dispose();
    super.dispose();
  }

  // --- WIDGETS ---

  // ... (Hàm _buildMenuItemCard, _buildFilterChips, _buildDimmingOverlay giữ nguyên) ...
  Widget _buildMenuItemCard(
      MenuItemModel item, int quantity, ChooseMenuNotifier notifier) {
    final isSelected = quantity > 0;
    final currencyFormatter = NumberFormat.decimalPattern('vi_VN');

    return Container(
      // Styling...
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Icon(
                    item.category == MenuCategory.mainCourse
                        ? Icons.restaurant_menu
                        : Icons.local_cafe,
                    color: Colors.blueGrey[300],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${currencyFormatter.format(item.price)}đ',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Add/Remove buttons...
          if (!isSelected)
            GestureDetector(
              onTap: () => notifier.incrementItem(item.id),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, color: Colors.red, size: 20),
                    onPressed: () => notifier.decrementItem(item.id),
                  ),
                  Text(
                    '$quantity',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.blue, size: 20),
                    onPressed: () => notifier.incrementItem(item.id),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  Widget _buildFilterChips(WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final notifier = ref.read(chooseMenuProvider.notifier);

    String getCategoryLabel(MenuCategory category) {
      switch (category) {
        case MenuCategory.all: return 'Tất cả';
        case MenuCategory.mainCourse: return 'Món chính';
        case MenuCategory.drink: return 'Đồ uống';
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: MenuCategory.values.map((category) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(getCategoryLabel(category)),
              selected: selectedCategory == category,
              onSelected: (_) => notifier.setFilter(category),
              selectedColor: Colors.blue,
              labelStyle: TextStyle(
                color: selectedCategory == category ? Colors.white : Colors.black,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  Widget _buildDimmingOverlay() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isPanelOpen,
      builder: (context, isOpen, child) {
        return IgnorePointer(
          ignoring: !isOpen,
          child: GestureDetector(
            onTap: () {
              _isPanelOpen.value = false;
            },
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isOpen ? 1.0 : 0.0,
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          ),
        );
      },
    );
  }


  // Panel Tóm tắt Đơn hàng
  // ✅ CẬP NHẬT LOGIC NÚT THANH TOÁN
  Widget _buildOrderSummaryPanel() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isPanelOpen,
      builder: (context, isOpen, child) {
        final menuState = ref.watch(chooseMenuProvider);
        final selectedTable = ref.watch(tableProvider).selectedTable;
        final menuNotifier = ref.read(chooseMenuProvider.notifier);
        final tableNotifier = ref.read(tableProvider.notifier);
        final currencyFormatter = NumberFormat.decimalPattern('vi_VN');

        // Lấy danh sách món đã chọn
        final selectedItemsWithDetails =
            menuState.selectedItems.entries.map((entry) {
          final item =
              menuState.allMenuItems.firstWhere((i) => i.id == entry.key);
          return MapEntry(item, entry.value);
        }).toList();

        // Tính tổng tiền các món MỚI chọn
        final double totalAmount = selectedItemsWithDetails.fold(
          0.0,
          (sum, entry) => sum + (entry.key.price * entry.value),
        );

        return AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          top: 0,
          bottom: 0,
          right: isOpen ? 0 : -MediaQuery.of(context).size.width * 0.8,
          child: Row(
            children: [
              // Nút đóng/mở panel
              GestureDetector(
                onTap: () => _isPanelOpen.value = !_isPanelOpen.value,
                child: Container(
                  width: 25,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                    ),
                  ),
                  child: Icon(
                    isOpen ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              // Nội dung panel
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thông tin bàn, khách
                    Text(
                      'Đơn hàng - Bàn ${selectedTable?.name ?? ''}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Số khách: ${widget.initialGuestCount}',
                        style: TextStyle(color: Colors.grey[600])),
                    const Divider(height: 24),
                    // Danh sách món mới chọn
                    Expanded(
                      child: ListView.builder(
                        itemCount: selectedItemsWithDetails.length,
                        itemBuilder: (context, index) {
                          final entry = selectedItemsWithDetails[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(entry.key.name),
                            leading: Text(
                              '${entry.value}x',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                            trailing: Text(
                                '${currencyFormatter.format(entry.key.price * entry.value)}đ'),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 24),
                    // Tổng tiền món mới
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tổng cộng (món mới)', // Ghi chú là món mới
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          '${currencyFormatter.format(totalAmount)}đ',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- KHU VỰC NÚT BẤM ---
                    Row(
                      children: [
                        // ✅ NÚT THANH TOÁN (Cho Thu ngân)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (selectedTable != null) {
                                // 1. Lấy danh sách món MỚI
                                final newItems =
                                    selectedItemsWithDetails.expand((entry) {
                                  return List.generate(
                                      entry.value, (_) => entry.key);
                                }).toList();
                                
                                // 2. Gọi hàm: vừa thêm món VỪA thanh toán VÀ LẤY ID
                                final String? newOrderId = tableNotifier.updateOrderAndCheckout(
                                    selectedTable.id, newItems);
                                    
                                // 3. Dọn dẹp và đóng panel/menu
                                menuNotifier.clearAllSelection();
                                _isPanelOpen.value = false;
                                Navigator.of(context).pop(); // Đóng màn hình menu

                                // 4. Điều hướng đến màn hình Payment
                                if (newOrderId != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (ctx) => ScreenCashierPayment(orderId: newOrderId),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Lỗi: Không thể tạo hóa đơn'), backgroundColor: Colors.red),
                                  );
                                }

                              }
                            },
                            child: const Text('Thanh Toán'),
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15),
                              backgroundColor: Colors.green[700],
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 16), 

                        // ✅ NÚT XÁC NHẬN (CHỈ THÊM MÓN)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (selectedTable != null) {
                                final newItems =
                                    selectedItemsWithDetails.expand((entry) {
                                  return List.generate(
                                      entry.value, (_) => entry.key);
                                }).toList();
                                // Gọi hàm cũ (chỉ thêm món)
                                tableNotifier.updateTableOrder(
                                    selectedTable.id, newItems);
                              }
                              menuNotifier.clearAllSelection();
                              _isPanelOpen.value = false;
                              Navigator.of(context).pop(); // Đóng màn hình menu
                            },
                            child: const Text('Xác nhận'),
                            style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // --- KẾT THÚC KHU VỰC NÚT BẤM ---
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- BUILD METHOD CHÍNH --- (Không thay đổi)
  @override
  Widget build(BuildContext context) {
    // ... (Phần build giữ nguyên) ...
        final filteredMenuItems = ref.watch(filteredMenuItemsProvider);
    final selectedItems = ref.watch(selectedItemsProvider);
    final totalItemsSelected =
        ref.watch(chooseMenuProvider.select((s) => s.totalItemsSelected));
    final notifier = ref.read(chooseMenuProvider.notifier);

    // Lắng nghe tổng số món được chọn để tự động mở/đóng panel
    ref.listen<int>(chooseMenuProvider.select((s) => s.totalItemsSelected),
        (previous, next) {
      if (previous == 0 && next > 0) {
        // Nếu bắt đầu chọn từ 0, mở panel
        _isPanelOpen.value = true;
      } else if (next == 0) {
        // Nếu xóa về 0, đóng panel
        _isPanelOpen.value = false;
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.grey.withOpacity(0.2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Chọn món', style: TextStyle(color: Colors.black)),
      ),
      body: Stack(
        children: [
          // Lớp 1: Nội dung chính (GridView)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilterChips(ref),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredMenuItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredMenuItems[index];
                      final quantity = selectedItems[item.id] ?? 0;
                      return _buildMenuItemCard(item, quantity, notifier);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Lớp 2: Lớp phủ làm mờ
          _buildDimmingOverlay(),

          // Lớp 3: Panel đơn hàng
          // Panel chỉ hiện khi có món *mới* được chọn
          if (totalItemsSelected > 0) _buildOrderSummaryPanel(),
        ],
      ),
    );
  }
}