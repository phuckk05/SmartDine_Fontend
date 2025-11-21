// file: screens/screen_menu_management.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models_owner/categories.dart'; // Import model
import 'package:mart_dine/providers_owner/category_provider.dart' show categoryUpdateNotifierProvider;
import 'package:mart_dine/providers_owner/menu_item_relation_provider.dart' show categoryListProvider;
import 'package:mart_dine/providers_owner/system_stats_provider.dart'; // Lấy companyId
import 'screen_dish_management.dart';
import 'package:mart_dine/widgets_owner/_menu_modals.dart'; // Đường dẫn tương đối

class ScreenMenuManagement extends ConsumerStatefulWidget {
  const ScreenMenuManagement({super.key});
  @override
  ConsumerState<ScreenMenuManagement> createState() =>
      _ScreenMenuManagementState();
}

class _ScreenMenuManagementState extends ConsumerState<ScreenMenuManagement> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Hàm trigger rebuild để lọc
  void _filterCategories() {
    setState(() {});
  }

  void _stopSearching() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
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
          onSubmitted: (_) => _filterCategories(),
          onChanged: (_) => _filterCategories(), // Lọc real-time
          style: const TextStyle(color: Colors.black, fontSize: 18),
          decoration: InputDecoration(
            hintText: 'Tìm kiếm nhóm món...',
            hintStyle: TextStyle(color: Colors.grey.shade600),
            fillColor: Colors.grey.shade200,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      );
    } else {
      return const Text(
        "Quản lý menu",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      );
    }
  }

  // SỬA: Kích hoạt lại Modal Sửa/Xóa
  void _showEditDeleteModal(Category category) {
    // SỬA LỖI: Tách luồng hiển thị dialog để đảm bảo context luôn hợp lệ
    showDialog<bool>( // Nhận giá trị trả về (true nếu nhấn xóa)
      context: context,
      builder:
          (context) => EditDeleteCategoryModal(
            categoryName: category.name,
            onSave: (newName) {
               // Đóng modal sau khi lưu
              ref
                  .read(categoryUpdateNotifierProvider.notifier)
                  .editCategory(category, newName);
            },
            onDelete: () {
              // Chỉ đóng modal và trả về true để báo hiệu hành động xóa
              Navigator.of(context).pop(true);
            },
          ),
    ).then((wantsToDelete) async { // Xử lý sau khi modal đầu tiên đóng
      if (wantsToDelete == true) {
        // Bây giờ hiển thị dialog xác nhận với context gốc của màn hình
              // Thêm hộp thoại xác nhận trước khi xóa
              final confirm = await showDialog<bool>(
                context: context, 
                builder:
                    (ctx) => AlertDialog(
                      title: const Text('Xác nhận xóa'),
                      content: Text(
                        'Bạn có chắc chắn muốn xóa nhóm món "${category.name}" không? Hành động này không thể hoàn tác.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Hủy'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text(
                            'Xóa',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
              );
              if (confirm == true) {
                try {
                  await ref.read(categoryUpdateNotifierProvider.notifier)
                     .deleteCategory(category.id);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Lỗi: ${e.toString().replaceFirst("Exception: ", "")}",
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
      }
    });
    
  }

  // SỬA: Kích hoạt lại Modal Thêm
  void _showAddModal() async {
    // SỬA: Lấy companyId bất đồng bộ từ ownerProfileProvider
    final companyId = (await ref.read(ownerProfileProvider.future)).companyId;
    if (companyId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lỗi: Không tìm thấy thông tin công ty.")),
        );
      }
      return;
    }
    showDialog(
      context: context,
      builder:
          (context) => AddCategoryModal(
            onAdd: (newCategoryName) {
              ref
                  .read(categoryUpdateNotifierProvider.notifier)
                  .addCategory(newCategoryName, companyId);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // SỬA: Watch FutureProvider

    final categoryListAsync = ref.watch(categoryListProvider);

    // Watch notifier để rebuild khi có thay đổi và hiển thị loading/error

    ref.listen<AsyncValue<void>>(categoryUpdateNotifierProvider, (_, state) {
      if (state.hasError && !state.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Đã xảy ra lỗi: ${state.error}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: _buildAppBarTitle(),

        backgroundColor: Colors.white,

        elevation: 0,

        actions: [
          // SỬA LỖI: Chỉ hiển thị icon tìm kiếm khi KHÔNG tìm kiếm
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search, size: 28, color: Colors.black),
              onPressed: () => setState(() => _isSearching = true),
            ),

          // SỬA LỖI: Chỉ hiển thị icon đóng khi ĐANG tìm kiếm
          IconButton(
            icon:
                _isSearching
                    ? const Icon(Icons.close, size: 28, color: Colors.black)
                    : const SizedBox.shrink(), // Dùng SizedBox.shrink() để không chiếm không gian

            onPressed: _isSearching ? _stopSearching : () {},
          ),

          const SizedBox(width: 10),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),

        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // SỬA: Dùng .when() để xử lý AsyncValue
                  categoryListAsync.when(
                    loading:
                        () => const Center(child: CircularProgressIndicator()),

                    error:
                        (err, stack) => Center(
                          child: Text(
                            'Lỗi tải Nhóm món: $err',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),

                    data: (allCategories) {
                      // Lọc

                      final query = _searchController.text.toLowerCase();

                      final filteredCategories =
                          query.isEmpty
                              ? allCategories
                              : allCategories
                                  .where(
                                    (cat) =>
                                        cat.name.toLowerCase().contains(query),
                                  )
                                  .toList();

                      if (filteredCategories.isEmpty) {
                        return const Center(
                          child: Text("Không tìm thấy nhóm món nào."),
                        );
                      }

                      return ListView.builder(
                        itemCount: filteredCategories.length,

                        itemBuilder: (context, index) {
                          final category = filteredCategories[index];

                          return _menuCategoryItem(
                            category,
                          ); // Truyền Category object
                        },
                      );
                    },
                  ),

                  // Lớp phủ loading khi đang thực hiện CUD
                  if (ref.watch(categoryUpdateNotifierProvider).isLoading)
                    Container(
                      color: Colors.black.withOpacity(0.1),

                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),

            // Nút Thêm nhóm món
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 20),

              child: SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: _showAddModal,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // SỬA: Đổi lại màu xanh

                    foregroundColor: Colors.white,

                    padding: const EdgeInsets.symmetric(vertical: 14),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  child: const Text(
                    "Thêm nhóm món",

                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // <<< SỬA: Nhận Category object >>>

  Widget _menuCategoryItem(Category category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,

          MaterialPageRoute(
            builder:
                (context) => ScreenDishManagement(
                  categoryId: category.id, // <<< SỬA: Truyền ID

                  categoryName: category.name, // <<< SỬA: Truyền Tên
                ),
          ),
        );
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 12),

        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(10),

          border: Border.all(color: Colors.grey.shade200),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            Row(
              children: [
                const Icon(
                  Icons.category_outlined,
                  size: 24,
                  color: Colors.black87,
                ), // Icon khác

                const SizedBox(width: 15),

                Text(
                  category.name, // <<< SỬA: Lấy tên từ object

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            IconButton(
              icon: const Icon(
                Icons.more_horiz,
                size: 24,
                color: Colors.black54,
              ),

              onPressed: () {
                _showEditDeleteModal(category); // <<< SỬA: Truyền object
              },
            ),
          ],
        ),
      ),
    );
  }
}
