import 'package:collection/collection.dart'; // THÊM: Để sử dụng groupBy
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models_owner/item.dart';
import 'package:mart_dine/models_owner/categories.dart'; // THÊM: Import model Category
import 'package:mart_dine/providers_owner/item_provider.dart' show allItemsProvider, itemUpdateNotifierProvider, itemsByMenuProvider; // SỬA: Thêm itemsByMenuProvider
import 'package:mart_dine/providers_owner/system_stats_provider.dart';
import 'package:mart_dine/providers_owner/menu_item_relation_provider.dart' show categoryListProvider; // SỬA: Xóa itemsByMenuProvider

/// Màn hình quản lý tất cả món ăn trong một Menu.
class ScreenMenuDishManagement extends ConsumerStatefulWidget {
  final int menuId;
  final String menuName;

  const ScreenMenuDishManagement(
      {super.key, required this.menuId, required this.menuName});

  @override
  ConsumerState<ScreenMenuDishManagement> createState() =>
      _ScreenMenuDishManagementState();
}

class _ScreenMenuDishManagementState
    extends ConsumerState<ScreenMenuDishManagement> {
  @override
  Widget build(BuildContext context) {
    // SỬA: Theo dõi 3 provider: món ăn TRONG menu, nhóm món TRONG menu, và TẤT CẢ món ăn của công ty
    final itemsInMenuAsync = ref.watch(itemsByMenuProvider(widget.menuId));
    final ownerProfileAsync = ref.watch(ownerProfileProvider); // Lấy companyId
    // THÊM: Lấy danh sách tất cả các category để tra cứu tên
    final allCategoriesAsync = ref.watch(categoryListProvider);
    final companyId = ownerProfileAsync.value?.companyId; // Dùng để lấy tất cả món ăn khi thêm
    final AsyncValue<List<Item>> allCompanyItemsAsync = companyId != null
        ? ref.watch(allItemsProvider(companyId))
        : const AsyncValue.loading();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.menuName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(itemsByMenuProvider(widget.menuId));
          ref.invalidate(categoryListProvider);
        }, // SỬA: Sử dụng `itemsInMenuAsync` để hiển thị danh sách chính
        child: itemsInMenuAsync.when( // SỬA: Sử dụng `itemsInMenuAsync` để hiển thị danh sách chính
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Lỗi tải món ăn: $err')),
          data: (itemsInMenu) {
            if (itemsInMenu.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.no_food_outlined, size: 60, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text('Menu chưa có món.', style: TextStyle(fontSize: 16, color: Colors.black54)),
                      const Text('Nhấn dấu "+" để thêm món ăn vào menu.', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ),
              );
            }
            // THÊM: Nhóm các món ăn theo categoryName
            final groupedItems = groupBy(itemsInMenu, (Item item) => item.categoryId);
            final categoryNames = groupedItems.keys.toList();

            // SỬA: Dùng .when() cho categories để lấy được tên
            return allCategoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Lỗi tải nhóm món: $err')),
              data: (allCategories) {
                // Tạo một map để tra cứu tên category từ id
                final categoryIdToNameMap = {for (var cat in allCategories) cat.id: cat.name};

                return ListView.builder(
                  itemCount: categoryNames.length,
                  itemBuilder: (context, index) {
                    final categoryId = categoryNames[index];
                    final itemsInCategory = groupedItems[categoryId]!;
                    // SỬA: Lấy tên category từ map, nếu không có thì hiển thị 'Chưa phân loại'
                    final categoryDisplayName = categoryIdToNameMap[categoryId] ?? 'Chưa phân loại';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            categoryDisplayName, // SỬA: Hiển thị tên đã tra cứu
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ),
                        ...itemsInCategory.map((item) => ListTile( // SỬA: Thêm CircleAvatar để hiển thị ảnh
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey.shade200,
                                // Sử dụng NetworkImage nếu có URL ảnh
                                backgroundImage: (item.image != null && item.image!.isNotEmpty)
                                    ? NetworkImage(item.image!)
                                    : null,
                                // Hiển thị icon placeholder nếu không có ảnh
                                child: (item.image == null || item.image!.isEmpty)
                                    ? const Icon(Icons.fastfood, color: Colors.grey)
                                    : null,
                              ),
                              title: Text(item.name),
                              subtitle: Text('${item.price.toStringAsFixed(0)} đ', style: TextStyle(color: Colors.grey.shade600)),
                              trailing: IconButton(
                                icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                                onPressed: () => _showDeleteConfirmationDialog(item),
                                tooltip: 'Xóa khỏi menu',
                              ),
                            )),
                        const Divider(height: 1),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // SỬA: Gọi thẳng hàm hiển thị danh sách món ăn của công ty
          _showAvailableItemsModal(
            itemsInMenuAsync,
            allCompanyItemsAsync,
            allCategoriesAsync, // THÊM: Truyền tham số còn thiếu
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Modal hiển thị danh sách các món ăn có sẵn để chọn
  void _showAvailableItemsModal(
    AsyncValue<List<Item>> itemsInMenuAsync,
    AsyncValue<List<Item>> allCompanyItemsAsync,
    AsyncValue<List<Category>> allCategoriesAsync, // THÊM: Truyền danh sách category vào modal
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true, // Cho phép modal cao hơn
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _AvailableItemsModalContent(
        itemsInMenuAsync: itemsInMenuAsync,
        allCompanyItemsAsync: allCompanyItemsAsync,
        allCategoriesAsync: allCategoriesAsync,
        menuId: widget.menuId, // Truyền menuId vào modal
      ),
    );
  }

  // THÊM: Hàm helper để gọi notifier và hiển thị kết quả
  Future<void> _assignItemToMenu(Item item) async {
    if (!mounted) return;
    try {
      final companyId = ref.read(ownerProfileProvider).value?.companyId;
      if (companyId == null) throw Exception("Không thể xác định công ty.");

      // SỬA: Gọi hàm mới không cần categoryId
      // HÀM NÀY KHÔNG CÒN PHÙ HỢP VÌ THIẾU categoryId
      // LOGIC MỚI SẼ ĐƯỢC XỬ LÝ TRONG MODAL
 
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Thêm món ăn thành công!"),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Lỗi: ${e.toString()}"),
            backgroundColor: Colors.red),
      );
    }
  }

  // THÊM: Hàm hiển thị dialog xác nhận xóa
  void _showDeleteConfirmationDialog(Item item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa món "${item.name}" khỏi menu này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Đóng dialog
              _unassignItemFromMenu(item); // Gọi hàm xóa
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // THÊM: Hàm gọi notifier để xóa món khỏi menu
  Future<void> _unassignItemFromMenu(Item item) async {
    if (!mounted) return;

    try {
      await ref
          .read(itemUpdateNotifierProvider.notifier)
          .unassignItemFromMenu(item.id!, item.categoryId!, widget.menuId);
 
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Đã xóa món ăn khỏi menu."),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Lỗi khi xóa món ăn: ${e.toString()}"),
            backgroundColor: Colors.red),
      );
    }
  }


  void _showLoadingDialog() {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator()),
      );
    }
  }

  void _showErrorDialog(String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text("Lỗi"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(c).pop(),
              child: const Text("Đóng"),
            ),
          ],
        ),
      );
    }
  }
}

/// Widget nội dung cho modal chọn món ăn, có thể quản lý trạng thái riêng.
class _AvailableItemsModalContent extends ConsumerStatefulWidget {
  final AsyncValue<List<Item>> itemsInMenuAsync;
  final AsyncValue<List<Item>> allCompanyItemsAsync;
  final AsyncValue<List<Category>> allCategoriesAsync;
  final int menuId; // THÊM

  const _AvailableItemsModalContent({
    required this.itemsInMenuAsync,
    required this.allCompanyItemsAsync,
    required this.allCategoriesAsync,
    required this.menuId, // THÊM
  });

  @override
  ConsumerState<_AvailableItemsModalContent> createState() =>
      _AvailableItemsModalContentState();
}

class _AvailableItemsModalContentState
    extends ConsumerState<_AvailableItemsModalContent> {
  Category? _targetCategory; // Nhóm món mà người dùng muốn thêm món VÀO
  final Set<int> _selectedItemIds = {}; // Danh sách các món ăn được chọn để thêm

  @override
  Widget build(BuildContext context) {
    // Lồng các .when() để xử lý các trạng thái loading/error/data
    return widget.allCategoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text("Lỗi tải nhóm món: $err")),
      data: (allCategories) {
        return widget.allCompanyItemsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text("Lỗi tải món ăn: $err")),
          data: (allCompanyItems) {
            final itemsInThisMenu = widget.itemsInMenuAsync.value ?? [];
            final itemIdsInMenu = itemsInThisMenu.map((item) => item.id).toSet();

            // Bước 1: Nếu chưa chọn nhóm món đích, hiển thị danh sách nhóm món
            // SỬA: Xử lý trường hợp menu mới chưa có món (và do đó chưa có nhóm)
            if (_targetCategory == null) {
              // Lấy danh sách các category đang được sử dụng trong menu này
              // SỬA: Luôn hiển thị TẤT CẢ các nhóm món của công ty để người dùng có thể thêm món vào một nhóm mới chưa có trong menu.
              final categoriesToShow = allCategories;
              return _buildCategorySelection(context, categoriesToShow);
            }
            // Bước 2: Nếu đã chọn nhóm món, hiển thị danh sách món ăn của công ty để chọn
            else {
              final availableItems = allCompanyItems
                  .where((item) => !itemIdsInMenu.contains(item.id))
                  .toList();

              return _buildItemMultiSelection(
                context,
                _targetCategory!,
                availableItems,
                onConfirm: () async {
                  final companyId = ref.read(ownerProfileProvider).value?.companyId;
                  if (companyId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi: Không tìm thấy công ty.")));
                    return;
                  }
                  if (_selectedItemIds.isEmpty) {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng chọn ít nhất một món ăn.")));
                    return;
                  }

                  // Đóng modal trước khi gọi API
                  Navigator.of(context).pop(); 

                  try {
                    // Gọi provider để thực hiện gán hàng loạt
                    await ref.read(itemUpdateNotifierProvider.notifier).assignItemsToMenu(
                      menuId: widget.menuId,
                      companyId: companyId,
                      categoryId: _targetCategory!.id!,
                      itemIds: _selectedItemIds.toList(),
                    );
                     if (mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Thêm món ăn thành công!"), backgroundColor: Colors.green));
                     }
                  } catch (e) {
                     if (mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi khi thêm món: $e"), backgroundColor: Colors.red));
                     }
                  }
                },
              );
            }
          },
        );
      },
    );
  }

  // Widget xây dựng danh sách chọn Nhóm món ĐÍCH
  Widget _buildCategorySelection(
      BuildContext context, List<Category> categories) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            _buildDragHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text("Thêm món vào nhóm nào?",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20)),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return ListTile(
                    leading: const Icon(Icons.category_outlined),
                    title: Text(category.name),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => setState(() => _targetCategory = category),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // Widget xây dựng danh sách chọn nhiều Món ăn
  Widget _buildItemMultiSelection(
    BuildContext context,
    Category targetCategory,
    List<Item> items, {
    required VoidCallback onConfirm,
  }) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            _buildDragHandle(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ListTile(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => setState(() {
                    _targetCategory = null;
                    _selectedItemIds.clear(); // Xóa các lựa chọn cũ
                  }),
                ),
                title: Text("Chọn món ăn", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20)),
                subtitle: Text("Thêm vào nhóm: ${targetCategory.name}"),
              ),
            ),
            const Divider(height: 1),
            if (items.isEmpty)
              const Expanded(
                  child: Center(child: Text("Tất cả món ăn của công ty đã có trong menu này.")))
            else
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = _selectedItemIds.contains(item.id);
                    return CheckboxListTile(
                      secondary: CircleAvatar(
                        backgroundImage: (item.image != null && item.image!.isNotEmpty) ? NetworkImage(item.image!) : null,
                        child: (item.image == null || item.image!.isEmpty) ? const Icon(Icons.fastfood) : null,
                      ),
                      title: Text(item.name),
                      subtitle: Text('${item.price.toStringAsFixed(0)} đ'),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedItemIds.add(item.id!);
                          } else {
                            _selectedItemIds.remove(item.id!);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: Text("Thêm ${_selectedItemIds.length} món đã chọn"),
              ),
            )
          ],
        );
      },
    );
  }

  // Tay nắm kéo cho modal
  Widget _buildDragHandle() => Container(
        width: 40, height: 5, margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
      );
}