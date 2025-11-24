// file: lib/features/owner/screen_menu_management.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models_owner/menu.dart';
import 'package:mart_dine/features/owner/screen_item_management.dart'; // THÊM: Import màn hình mới
import 'package:mart_dine/providers_owner/menu_provider.dart';
import 'screen_category_management.dart';
import 'screen_menu_dish_management.dart' hide IconButton; // THAY ĐỔI: Import màn hình mới và ẩn IconButton


/// Màn hình chính để quản lý danh sách các Menu
class ScreenMenuManagement extends ConsumerStatefulWidget {
  const ScreenMenuManagement({super.key});

  @override
  ConsumerState<ScreenMenuManagement> createState() => _ScreenMenuManagementState();
}

class _ScreenMenuManagementState extends ConsumerState<ScreenMenuManagement> {
  void _showAddMenuModal() {
    // Không cần lấy companyId ở đây nữa vì provider đã tự xử lý
    // Điều này giúp mã nguồn sạch hơn và tránh lỗi không cần thiết.
    // final companyId = (await ref.read(ownerProfileProvider.future)).companyId;
    // if (companyId == null) {
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text("Lỗi: Không tìm thấy thông tin công ty.")),
    //     );
    //   }
    //   return;
    // }
    showDialog(
      context: context,
      builder: (context) => _AddEditMenuModal(
        title: "Thêm Menu mới",
        onSave: (name, description) {
          // Gọi notifier để thêm menu.
          // Notifier sẽ tự động lấy companyId và gán statusId.
          ref
              .read(menuUpdateNotifierProvider.notifier)
              .addMenu(name, description);
        },
      ),
    );
  }

  void _showEditMenuModal(Menu menu) {
    showDialog(
      context: context,
      builder: (context) => _AddEditMenuModal(
        title: "Chỉnh sửa Menu",
        initialName: menu.name,
        initialDescription: menu.description,
        onSave: (name, description) {
          ref
              .read(menuUpdateNotifierProvider.notifier)
              .editMenu(menu, name, description);
        },
      ),
    );
  }

  void _deleteMenu(int menuId) {
    // Thêm hộp thoại xác nhận trước khi xóa
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text(
            'Bạn có chắc chắn muốn xóa menu này không? Tất cả các nhóm món và món ăn liên quan cũng sẽ bị ảnh hưởng.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Đóng dialog xác nhận
              ref.read(menuUpdateNotifierProvider.notifier).deleteMenu(menuId);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final menus = ref.watch(menuListProvider);

    // Lắng nghe trạng thái của notifier để hiển thị lỗi hoặc loading
    ref.listen<AsyncValue<void>>(menuUpdateNotifierProvider, (_, state) {
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
        title: const Text(
          "Quản lý Menu",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.category, color: Colors.black),
            tooltip: 'Quản lý nhóm món',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ScreenCategoryManagement())),
          ), // THÊM: Dấu phẩy bị thiếu
          const SizedBox(width: 8), // Giữ lại SizedBox để có khoảng cách
          // THÊM: Nút để mở màn hình quản lý món ăn tập trung
          IconButton(
            icon: const Icon(Icons.fastfood_outlined, color: Colors.black),
            tooltip: 'Quản lý món ăn',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScreenItemManagement())),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  menus.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) =>
                        Center(child: Text('Lỗi tải menu: $err')),
                    data: (menuList) {
                      if (menuList.isEmpty) {
                        return const Center(
                            child: Text(
                                "Chưa có menu nào. Hãy thêm một menu mới."));
                      }
                      return ListView.builder(
                        itemCount: menuList.length,
                        itemBuilder: (context, index) {
                          final menu = menuList[index];
                          return _menuItem(menu);
                        },
                      );
                    },
                  ),
                  // Lớp phủ loading khi đang thực hiện CUD
                  if (ref.watch(menuUpdateNotifierProvider).isLoading)
                    Container(
                        color: Colors.black.withOpacity(0.1),
                        child: const Center(child: CircularProgressIndicator())),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showAddMenuModal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Thêm Menu",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(Menu menu) {
    return GestureDetector(
      onTap: () {
        // THAY ĐỔI: Điều hướng đến màn hình quản lý món ăn của menu
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScreenMenuDishManagement(
              menuId: menu.id!,
              menuName: menu.name,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            const Icon(Icons.menu_book, size: 28, color: Colors.blue),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(menu.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(menu.description ?? '', style: const TextStyle(fontSize: 13, color: Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditMenuModal(menu);
                } else if (value == 'delete') {
                  // Sửa lỗi: Đảm bảo id không null trước khi xóa
                  if (menu.id != null) {
                    _deleteMenu(menu.id!);
                  }
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(value: 'edit', child: Text('Sửa')),
                const PopupMenuItem<String>(value: 'delete', child: Text('Xóa', style: TextStyle(color: Colors.red))),
              ],
              icon: const Icon(Icons.more_vert, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modal để thêm hoặc sửa Menu
class _AddEditMenuModal extends StatefulWidget {
  final String title;
  final String? initialName;
  final String? initialDescription;
  final Function(String name, String description) onSave;

  const _AddEditMenuModal({required this.title, required this.onSave, this.initialName, this.initialDescription});

  @override
  State<_AddEditMenuModal> createState() => _AddEditMenuModalState();
}

class _AddEditMenuModalState extends State<_AddEditMenuModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _descriptionController = TextEditingController(text: widget.initialDescription ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Tên Menu'),
              validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập tên menu' : null,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Mô tả'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(_nameController.text, _descriptionController.text);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}