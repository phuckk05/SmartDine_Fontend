// File: _dish_modals.dart

import 'package:mart_dine/models_owner/item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// === Modal 1: Thêm Món Ăn (Dùng khi nhấn FAB +) ===

class AddDishModal extends StatefulWidget {
  final Function(String name, String price) onAdd;

  const AddDishModal({super.key, required this.onAdd});

  @override
  State<AddDishModal> createState() => _AddDishModalState();
}

class _AddDishModalState extends State<AddDishModal> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Thêm món", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon mô phỏng món ăn
            const Icon(Icons.fastfood, size: 60, color: Colors.black54), 
            const SizedBox(height: 15),
            
            // Nhập tên
            TextField(
              controller: _nameController,
              decoration: _inputDecoration("Nhập tên"),
            ),
            const SizedBox(height: 10),
            
            // Nhập giá
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Chỉ cho phép nhập số
              decoration: _inputDecoration("Nhập giá"),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.all(10),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Nút Thêm
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  widget.onAdd(_nameController.text.trim(), _priceController.text.trim());
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Thêm", style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 10),
            // Nút Hủy
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Hủy", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// === Modal 2: Sửa & Xóa Món Ăn (Dùng khi nhấn vào món ăn) ===

class EditDeleteDishModal extends StatefulWidget {
  final Item initialDish;
  final Function(String newName, String newPrice) onSave;
  final VoidCallback onDelete;

  const EditDeleteDishModal({
    super.key,
    required this.initialDish, 
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<EditDeleteDishModal> createState() => _EditDeleteDishModalState();
}

class _EditDeleteDishModalState extends State<EditDeleteDishModal> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialDish.name);
    _priceController = TextEditingController(text: widget.initialDish.price.toStringAsFixed(0));
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
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Sửa món", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon mô phỏng món ăn
            const Icon(Icons.fastfood, size: 60, color: Colors.black54), 
            const SizedBox(height: 15),
            
            // Nhập tên
            TextField(
              controller: _nameController,
              decoration: _inputDecoration("Nhập tên"),
            ),
            const SizedBox(height: 10),
            
            // Nhập giá
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _inputDecoration("Nhập giá"),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.all(10),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Nút Lưu
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (_nameController.text.isNotEmpty && _priceController.text.isNotEmpty) {
                    widget.onSave(_nameController.text.trim(), _priceController.text.trim());
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Lưu", style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 10),
            // Nút Xóa
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  widget.onDelete();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Xóa", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  );
}