// file: screens/screen_dish_management.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models_owner/item.dart'; // Đảm bảo đường dẫn đúng
import 'package:mart_dine/providers_owner/item_provider.dart' 
    show itemUpdateNotifierProvider, itemsByCategoryProvider;
import 'package:mart_dine/providers_owner/system_stats_provider.dart'; // Lấy companyId
import 'package:mart_dine/widgets_owner/_dish_modals.dart'; // Đường dẫn tương đối

class ScreenDishManagement extends ConsumerStatefulWidget {
  final int categoryId;
  final String categoryName;

  const ScreenDishManagement({
    super.key, 
    required this.categoryId, 
    required this.categoryName
  });

  @override
  ConsumerState<ScreenDishManagement> createState() => _ScreenDishManagementState();
}

class _ScreenDishManagementState extends ConsumerState<ScreenDishManagement> {
  
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _filterDishes() { setState(() {}); }
  void _stopSearching() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _filterDishes();
    });
  }
  
  // Widget AppBar (Giữ nguyên)
  Widget _buildAppBarTitle() {
    if (_isSearching) {
      return Container(
        height: 38,
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: TextField(
          controller: _searchController,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _filterDishes(),
          onChanged: (_) => _filterDishes(),
          style: const TextStyle(color: Colors.white, fontSize: 18),
          decoration: InputDecoration(
            hintText: 'Tìm kiếm món ăn...',
            hintStyle: TextStyle(color: Colors.white70),
            fillColor: Colors.blue.shade700,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      );
    } else {
      return Text(
        widget.categoryName,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
      );
    }
  }

  // Modal Thêm (Đã đúng)
  void _showAddDishModal() async {
    // SỬA: Lấy companyId bất đồng bộ từ provider
    final companyId = await ref.read(ownerCompanyIdProvider.future);
    if (companyId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lỗi: Không thể xác định công ty để thêm món.")),
        );
      }
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AddDishModal(
        onAdd: (name, priceString) {
          final price = double.tryParse(priceString) ?? 0.0;
          ref.read(itemUpdateNotifierProvider.notifier).addItem(name, price, widget.categoryId, companyId);
        },
      ),
    );
  }
  
  // Modal Sửa/Xóa (Đã đúng)
  void _showEditDeleteDishModal(Item dish) {
    // SỬA LỖI: Tách luồng hiển thị dialog để đảm bảo context luôn hợp lệ
    showDialog<bool>( // Nhận giá trị trả về (true nếu nhấn xóa)
      context: context,
      builder: (context) => EditDeleteDishModal( 
        initialDish: dish,
        onSave: (newName, newPriceString) {
          Navigator.of(context).pop(); // Đóng modal sau khi lưu
          final newPrice = double.tryParse(newPriceString) ?? 0.0;
          ref.read(itemUpdateNotifierProvider.notifier).editItem(dish, newName, newPrice, widget.categoryId);
        },
        onDelete: () {
          // Chỉ đóng modal và trả về true để báo hiệu hành động xóa
          Navigator.of(context).pop(true);
        },
      ),
    ).then((wantsToDelete) async { // Xử lý sau khi modal đầu tiên đóng
      if (wantsToDelete == true) {
        // Bây giờ hiển thị dialog xác nhận với context gốc của màn hình
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Xác nhận xóa'),
              content: Text('Bạn có chắc chắn muốn xóa món "${dish.name}" không?'),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Hủy')),
                TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Xóa', style: TextStyle(color: Colors.red))),
              ],
            ),
          );

          if (confirm == true) {
            try {
              // SỬA LỖI: Không cần 'await' ở đây vì đây là gọi hàm của Notifier, không phải Future trực tiếp
              await ref.read(itemUpdateNotifierProvider.notifier).deleteItem(dish, widget.categoryId);
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Lỗi: ${e.toString().replaceFirst("Exception: ", "")}"), backgroundColor: Colors.red),
                );
              }
            }
          }
      }
    });
    
  }

  @override
  Widget build(BuildContext context) {
    // Watch provider (giờ đã đúng)
    final itemListAsync = ref.watch(itemsByCategoryProvider(widget.categoryId));
    
    // Watch notifier (Giữ nguyên)
    ref.listen<AsyncValue<void>>(itemUpdateNotifierProvider, (_, state) {
      if (state.hasError && !state.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đã xảy ra lỗi: ${state.error}"), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // (Giữ nguyên phần còn lại của AppBar)
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildAppBarTitle(),
        actions: [
          if (!_isSearching)
            IconButton(icon: const Icon(Icons.search, size: 28, color: Colors.white), onPressed: () => setState(() => _isSearching = true)),
          IconButton(
            icon: _isSearching ? const Icon(Icons.close, size: 28, color: Colors.white) : const SizedBox.shrink(),
            onPressed: _isSearching ? _stopSearching : null,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                  // (Giữ nguyên .when)
                  child: itemListAsync.when(
                     loading: () => const Center(child: CircularProgressIndicator()),
                     error: (err, stack) => Center(child: Text('Lỗi tải món ăn: $err', style: const TextStyle(color: Colors.red))),
                     data: (allItems) {
                        final query = _searchController.text.toLowerCase();
                        final filteredDishes = query.isEmpty
                          ? allItems
                          : allItems.where((item) => item.name.toLowerCase().contains(query)).toList();
                          
                        if (filteredDishes.isEmpty) {
                          return Center(child: Text(query.isEmpty ? "Nhóm này chưa có món ăn." : "Không tìm thấy món ăn."));
                        }

                        return GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, crossAxisSpacing: 16.0, mainAxisSpacing: 16.0, childAspectRatio: 0.75,
                          ),
                          itemCount: filteredDishes.length, 
                          itemBuilder: (context, index) {
                            final dish = filteredDishes[index];
                            return _dishItem(dish);
                          },
                        );
                     }
                  ),
                ),
                // (Giữ nguyên lớp phủ loading)
                if (ref.watch(itemUpdateNotifierProvider).isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.2),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ],
      ),
      
      // (Giữ nguyên FloatingActionButton)
      floatingActionButton: _isSearching ? null : FloatingActionButton(
        onPressed: _showAddDishModal,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
  
  // (Giữ nguyên _dishItem)
  Widget _dishItem(Item dish) {
    return GestureDetector(
      onTap: () {
        _showEditDeleteDishModal(dish);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 80, 
            decoration: BoxDecoration(
              color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300)
            ),
            child: const Icon(Icons.fastfood, size: 40, color: Colors.black54), 
          ),
          const SizedBox(height: 5),
          Text(
            dish.name,
            textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
          ),
          Text(
            formatCurrency(dish.price), 
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

// Helper function (có thể chuyển vào file core/utils.dart)
String formatCurrency(double price) => '${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ';