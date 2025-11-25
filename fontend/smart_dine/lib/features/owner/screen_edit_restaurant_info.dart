// file: screens/screen_edit_restaurant_info.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import models
import 'package:mart_dine/models_owner/branch.dart';
import 'package:mart_dine/models_owner/user.dart'; // Cần cho mock provider

import 'package:mart_dine/providers_owner/branch_provider.dart';
// Import providers
import 'package:mart_dine/providers_owner/mock_user_provider.dart'; // Tạm dùng để lấy tên QL
import 'package:mart_dine/providers_owner/target_provider.dart'; // Chứa branchListProvider

// Import API service
import 'package:mart_dine/API_owner/branch_API.dart'; // API để gọi update

class ScreenEditRestaurantInfo extends ConsumerStatefulWidget {
  final Branch branchToEdit;
  final bool isEditable; // THÊM: Cờ xác định có được chỉnh sửa hay không
  const ScreenEditRestaurantInfo({
    super.key,
    required this.branchToEdit,
    this.isEditable = false, // Mặc định là false nếu không được truyền
  });

  @override
  ConsumerState<ScreenEditRestaurantInfo> createState() => _ScreenEditRestaurantInfoState();
}

class _ScreenEditRestaurantInfoState extends ConsumerState<ScreenEditRestaurantInfo> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _branchCodeController;
  late TextEditingController _managerNameController;
  bool _isLoading = false; // State quản lý loading

  @override
  void initState() {
    super.initState();
    // Khởi tạo controller với dữ liệu của chi nhánh đang sửa
    _nameController = TextEditingController(text: widget.branchToEdit.name);
    _addressController = TextEditingController(text: widget.branchToEdit.address);
    _branchCodeController = TextEditingController(text: widget.branchToEdit.branchCode);
    _managerNameController = TextEditingController();

    // Tra cứu tên quản lý (tạm thời từ mock provider)
    String managerName = "QL ID: ${widget.branchToEdit.managerId}";
    try {
      // Dùng read(context) trong initState
      final allUsers = ref.read(mockUserListProvider);
      managerName = allUsers.firstWhere((user) => user.id == widget.branchToEdit.managerId).fullName;
    } catch (e) {
      print("Không tìm thấy tên quản lý (ID: ${widget.branchToEdit.managerId}) trong mock provider.");
    }
    _managerNameController.text = managerName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _branchCodeController.dispose();
    _managerNameController.dispose();
    super.dispose();
  }

  // Hàm gọi API update
  void _updateInfo() async {
     if (_isLoading) return; // Không cho nhấn nút nếu đang xử lý

     setState(() => _isLoading = true);

     // Tạo đối tượng Branch đã cập nhật
     final updatedBranch = widget.branchToEdit.copyWith(
       name: _nameController.text.trim(),
       address: _addressController.text.trim(),
       branchCode: _branchCodeController.text.trim(),
       // managerId không được sửa ở màn hình này
       updatedAt: DateTime.now(), // API Service sẽ set lại
     );

     try {
         // Lấy service từ provider
         final apiService = ref.read(branchApiProvider);
         
         // Gọi API update (Lưu ý: Backend CẦN có endpoint PUT /api/branches/{id})
         await apiService.updateBranch(widget.branchToEdit.id, updatedBranch);

         // SỬA: Dùng refresh để tải lại ngay và invalidate provider chi tiết
         ref.refresh(branchListProvider.future);
         ref.invalidate(branchDetailProvider(widget.branchToEdit.id));

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Cập nhật thông tin chi nhánh thành công!"))
            );
            // Pop 2 lần để quay về ScreenManagement (bỏ qua ScreenRestaurantDetail)
            Navigator.of(context).pop(); // SỬA: Chỉ pop 1 lần để quay về màn hình chi tiết
          }

     } catch (e) {
         // Hiển thị lỗi
         if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text("Lỗi cập nhật chi nhánh: $e")),
             );
         }
     } finally {
         // Dừng loading dù thành công hay lỗi
         if (mounted) {
           setState(() => _isLoading = false);
         }
     }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Sửa thông tin chi nhánh",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [ // THÊM: Truyền widget.isEditable vào các TextField
            _buildTextField("Tên chi nhánh", _nameController, readOnly: !widget.isEditable),
            _buildTextField("Địa chỉ", _addressController, readOnly: !widget.isEditable),
            _buildTextField("Mã chi nhánh", _branchCodeController, readOnly: !widget.isEditable),
            _buildTextField("Tên quản lý", _managerNameController, readOnly: true), // Không cho sửa tên QL ở đây
            _buildReadOnlyField("Trạng thái", "Đang hoạt động"), // Giả lập
            
            const SizedBox(height: 40),

            // Nút Cập nhật
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton( // THÊM: Disable nút nếu không có quyền chỉnh sửa
                onPressed: _isLoading || !widget.isEditable ? null : _updateInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    // Hiển thị loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    // Hiển thị text
                    : const Text(
                        "Cập nhật",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Widget chung cho TextField
  Widget _buildTextField(String label, TextEditingController controller, {bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            filled: readOnly,
            fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  // Widget chỉ đọc
  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Text(value, style: const TextStyle(fontSize: 16, color: Colors.black54)),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}