// file: lib/features/owner/screen_item_management.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mart_dine/API_owner/cloudinary_API.dart';
import 'package:mart_dine/models_owner/item.dart';
import 'package:mart_dine/models_owner/categories.dart';
import 'package:mart_dine/providers_owner/item_provider.dart';
import 'package:mart_dine/providers_owner/system_stats_provider.dart';
import 'package:mart_dine/providers_owner/menu_item_relation_provider.dart' show categoryListProvider;

/// Màn hình quản lý tất cả các món ăn của công ty
class ScreenItemManagement extends ConsumerWidget {
  const ScreenItemManagement({super.key});

  void _showAddDishModal(BuildContext context, WidgetRef ref, int companyId) {
    showDialog(
      context: context,
      builder: (ctx) => AddDishModal(companyId: companyId),
    );
  }

  void _showEditDishModal(BuildContext context, WidgetRef ref, Item item) {
    showDialog(
      context: context,
      builder: (ctx) => EditDeleteDishModal(
        initialDish: item,
        onSave: (newName, newPrice, imageFile, isImageRemoved) async {
          String? finalImageUrl = item.image;

          if (imageFile != null) {
            // Nếu có ảnh mới, tải lên và lấy URL
            final cloudinaryApi = CloudinaryAPI();
            try {
              finalImageUrl = await cloudinaryApi.getURL(imageFile);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Lỗi tải ảnh mới: $e")),
              );
              return;
            }
          } else if (isImageRemoved) {
            // Nếu người dùng xóa ảnh
            finalImageUrl = null;
          }

          // Gọi notifier để cập nhật
          ref.read(itemUpdateNotifierProvider.notifier).editItem(
                item,
                newName,
                double.parse(newPrice),
                // SỬA: Không còn newCategoryId
                finalImageUrl,
              );
        },
        onDelete: () {
          // Hiển thị dialog xác nhận trước khi xóa
          Navigator.of(ctx).pop(); // Đóng modal sửa
          _showDeleteConfirmationDialog(context, ref, item);
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, WidgetRef ref, Item item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
            'Bạn có chắc chắn muốn xóa món "${item.name}" không? Món ăn này sẽ bị xóa khỏi tất cả các menu đang chứa nó.'),
        actions: [
          TextButton(
            child: const Text('Hủy'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(itemUpdateNotifierProvider.notifier).deleteItem(item);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownerProfileAsync = ref.watch(ownerProfileProvider);
    final companyId = ownerProfileAsync.value?.companyId;

    // Theo dõi notifier để rebuild khi có thay đổi
    ref.watch(itemUpdateNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Món ăn'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: companyId == null
          ? const Center(child: Text("Không thể xác định công ty."))
          : Consumer(
              builder: (context, ref, child) {
                // SỬA: Lấy thêm danh sách các category để tra cứu tên
                final allItemsAsync = ref.watch(allItemsProvider(companyId));
                final allCategoriesAsync = ref.watch(categoryListProvider);

                // SỬA: Dùng .when() lồng nhau để đảm bảo cả 2 đều có dữ liệu trước khi hiển thị
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(allItemsProvider(companyId));
                    ref.invalidate(categoryListProvider);
                  },
                  child: allItemsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Lỗi tải món ăn: $err')),
                    data: (items) {
                      return allCategoriesAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, _) => Center(child: Text('Lỗi tải nhóm món: $err')),
                        data: (allCategories) {
                          // Tạo một map để tra cứu tên category từ id cho hiệu quả
                          final categoryIdToNameMap = {for (var cat in allCategories) cat.id: cat.name};

                          if (items.isEmpty) {
                            return const Center(child: Text('Chưa có món ăn nào. Hãy thêm mới!'));
                          }

                          return ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];

                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.grey.shade200,
                                    backgroundImage: (item.image != null && item.image!.isNotEmpty)
                                        ? NetworkImage(item.image!)
                                        : null,
                                    child: (item.image == null || item.image!.isEmpty)
                                        ? const Icon(Icons.fastfood, color: Colors.grey)
                                        : null,
                                  ),
                                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                    '${item.price.toStringAsFixed(0)} đ',
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                  trailing: const Icon(Icons.edit_note, color: Colors.grey),
                                  onTap: () => _showEditDishModal(context, ref, item),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: companyId != null
          ? FloatingActionButton(
              onPressed: () => _showAddDishModal(context, ref, companyId),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class AddDishModal extends ConsumerStatefulWidget {
  final int companyId;

  const AddDishModal({super.key, required this.companyId});

  @override
  ConsumerState<AddDishModal> createState() => _AddDishModalState();
}

class _AddDishModalState extends ConsumerState<AddDishModal> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  // XÓA: Không cần chọn category khi tạo món ăn.

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    // XÓA: Không cần lấy danh sách category ở đây.
    return AlertDialog(
      title: const Text("Thêm món ăn mới"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Tên món")),
            TextField(controller: _priceController, decoration: const InputDecoration(labelText: "Giá"), keyboardType: TextInputType.number),
            // XÓA: Toàn bộ Dropdown chọn category đã được gỡ bỏ.
            const SizedBox(height: 16),
            ElevatedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.image), label: const Text("Chọn ảnh")),
            if (_imageFile != null) Image.file(_imageFile!, height: 100),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
        ElevatedButton(
          onPressed: () async {
            // SỬA: Gỡ bỏ kiểm tra category đã chọn.
            if (_nameController.text.isNotEmpty && _priceController.text.isNotEmpty) {
              String? imageUrl;
              if (_imageFile != null) {
                final cloudinaryApi = CloudinaryAPI();
                try {
                  imageUrl = await cloudinaryApi.getURL(_imageFile!);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Lỗi tải ảnh lên: $e")),
                    );
                  }
                  return;
                }
              }
              // SỬA: Gọi hàm addItem đã được hoàn nguyên (không có categoryId).
              ref
                  .read(itemUpdateNotifierProvider.notifier)
                  .addItem(_nameController.text, double.parse(_priceController.text),
                      widget.companyId, imageUrl);

              Navigator.pop(context);
            }
          },
          child: const Text("Thêm"),
        ),
      ],
    );
  }
}

class EditDeleteDishModal extends ConsumerStatefulWidget {
  final Item initialDish;
  final Function(
    String newName, String newPrice,
    File? imageFile,
    bool isImageRemoved,
  ) onSave;
  final VoidCallback onDelete;

  const EditDeleteDishModal({
    super.key,
    required this.initialDish,
    required this.onSave,
    required this.onDelete,
  });

  @override
  ConsumerState<EditDeleteDishModal> createState() => _EditDeleteDishModalState();
}

class _EditDeleteDishModalState extends ConsumerState<EditDeleteDishModal> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  File? _imageFile;
  String? _networkImage;
  bool _isImageRemoved = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isImageRemoved = false; // Nếu chọn ảnh mới thì không phải là xóa ảnh
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialDish.name);
    _priceController =
        TextEditingController(text: widget.initialDish.price.toStringAsFixed(0));
    _networkImage = widget.initialDish.image;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Sửa món ăn"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildImagePicker(),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Tên món ăn"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: "Giá"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onDelete,
          child: const Text("Xóa", style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Hủy"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty && _priceController.text.isNotEmpty) {
              widget.onSave(
                _nameController.text,
                _priceController.text,
                _imageFile, 
                _isImageRemoved,
              );
              Navigator.pop(context);
            }
          },
          child: const Text("Lưu"),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    Widget imageContent;

    if (_imageFile != null) {
      imageContent = Image.file(_imageFile!, fit: BoxFit.cover);
    } else if (_networkImage?.isNotEmpty == true && !_isImageRemoved) {
      imageContent = Image.network(
        _networkImage!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) =>
            const Icon(Icons.broken_image, color: Colors.grey),
      );
    } else {
      imageContent = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined,
              color: Colors.grey.shade600, size: 40),
          const SizedBox(height: 8),
          Text('Chạm để thêm ảnh', style: TextStyle(color: Colors.grey.shade700)),
        ],
      );
    }

    return Stack(
      alignment: Alignment.topRight,
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: imageContent,
            ),
          ),
        ),
        if (_imageFile != null || (_networkImage?.isNotEmpty == true && !_isImageRemoved))
          InkWell(
            onTap: () => setState(() {
              _imageFile = null;
              _isImageRemoved = true;
            }),
            child: const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.black54,
              child: Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
      ],
    );
  }
}