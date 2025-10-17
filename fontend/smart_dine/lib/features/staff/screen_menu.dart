import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mart_dine/models/menu.dart';
import 'package:mart_dine/providers/menu_provider.dart';
import 'package:mart_dine/providers/table_provider.dart';

// Chuyển sang ConsumerStatefulWidget để quản lý trạng thái panel
class ScreenChooseMenu extends ConsumerStatefulWidget {
  final String tableName;
  final int initialGuestCount;
  final List<String> existingItems;

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
  // ValueNotifier để quản lý trạng thái đóng/mở của panel
  final ValueNotifier<bool> _isPanelOpen = ValueNotifier(false);

  @override
  void dispose() {
    _isPanelOpen.dispose();
    super.dispose();
  }

  // --- WIDGETS ---

  // Card Món ăn
  Widget _buildMenuItemCard(MenuItemModel item, int quantity, ChooseMenuNotifier notifier) {
    final isSelected = quantity > 0;
    final currencyFormatter = NumberFormat.decimalPattern('vi_VN');

    return Container(
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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

  // Filter Chips
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

  // Widget xây dựng lớp phủ làm mờ
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
  Widget _buildOrderSummaryPanel() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isPanelOpen,
      builder: (context, isOpen, child) {
        final menuState = ref.watch(chooseMenuProvider);
        final selectedTable = ref.watch(tableProvider).selectedTable;
        final menuNotifier = ref.read(chooseMenuProvider.notifier);
        final tableNotifier = ref.read(tableProvider.notifier);
        final currencyFormatter = NumberFormat.decimalPattern('vi_VN');

        final selectedItemsWithDetails = menuState.selectedItems.entries.map((entry) {
          final item = menuState.allMenuItems.firstWhere((i) => i.id == entry.key);
          return MapEntry(item, entry.value);
        }).toList();

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
                    Text(
                      'Đơn hàng - Bàn ${selectedTable?.name ?? ''}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Số khách: ${widget.initialGuestCount}', style: TextStyle(color: Colors.grey[600])),
                    const Divider(height: 24),
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
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                            trailing: Text('${currencyFormatter.format(entry.key.price * entry.value)}đ'),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tổng cộng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          '${currencyFormatter.format(totalAmount)}đ',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                           if (selectedTable != null) {
                            final newItems = selectedItemsWithDetails.expand((entry) {
                               return List.generate(entry.value, (_) => entry.key);
                            }).toList();
                            tableNotifier.updateTableOrder(selectedTable.id, newItems);
                          }
                          menuNotifier.clearAllSelection();
                          _isPanelOpen.value = false;
                          Navigator.of(context).pop();
                        },
                        child: const Text('Xác nhận'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- BUILD METHOD CHÍNH ---
  @override
  Widget build(BuildContext context) {
    final filteredMenuItems = ref.watch(filteredMenuItemsProvider);
    final selectedItems = ref.watch(selectedItemsProvider);
    final totalItemsSelected = ref.watch(chooseMenuProvider.select((s) => s.totalItemsSelected));
    final notifier = ref.read(chooseMenuProvider.notifier);

    ref.listen<int>(chooseMenuProvider.select((s) => s.totalItemsSelected), (previous, next) {
        if (previous == 0 && next > 0) {
            _isPanelOpen.value = true;
        } else if (next == 0) {
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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5, // <-- GIÁ TRỊ ĐÃ ĐƯỢC CHỈNH LẠI
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
          if (totalItemsSelected > 0) _buildOrderSummaryPanel(),
        ],
      ),
    );
  }
}