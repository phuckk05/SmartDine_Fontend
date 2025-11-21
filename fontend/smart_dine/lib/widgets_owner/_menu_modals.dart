// File: _menu_modals.dart

import 'package:flutter/material.dart';

// === Modal 1: Sửa & Xóa Nhóm Món (Dùng khi nhấn vào 3 chấm) ===

class EditDeleteCategoryModal extends StatefulWidget {
  final String categoryName;
  final Function(String newName) onSave;
  final Function() onDelete;

  const EditDeleteCategoryModal({
    super.key,
    required this.categoryName,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<EditDeleteCategoryModal> createState() => _EditDeleteCategoryModalState();
}

class _EditDeleteCategoryModalState extends State<EditDeleteCategoryModal> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.categoryName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Sửa nhóm món", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: "Nhập tên nhóm món...",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  if (_controller.text.isNotEmpty) {
                    widget.onSave(_controller.text);
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

// === Modal 2: Thêm Nhóm Món (Dùng khi nhấn nút "Thêm nhóm món") ===

class AddCategoryModal extends StatefulWidget {
  final Function(String newCategory) onAdd;

  const AddCategoryModal({super.key, required this.onAdd});

  @override
  State<AddCategoryModal> createState() => _AddCategoryModalState();
}

class _AddCategoryModalState extends State<AddCategoryModal> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Thêm nhóm món", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: "Nhập nhóm món...",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  widget.onAdd(_controller.text.trim());
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