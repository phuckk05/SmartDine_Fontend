import 'package:flutter/material.dart';

class ScreenUserProfile extends StatelessWidget {
  const ScreenUserProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Hồ sơ người dùng', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Card thông tin
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chỉnh sửa tên hiển thị',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoTextField(label: 'Họ và tên', value: 'Nguyễn Văn A'),
                  const SizedBox(height: 16),
                  _buildInfoTextField(label: 'Email', value: 'nguyenvana123@gmail.com'),
                  const SizedBox(height: 16),
                  _buildInfoTextField(label: 'Số điện thoại', value: '0123456789'),
                ],
              ),
            ),
            const Spacer(), // Đẩy nút xuống dưới cùng
            // Nút Lưu thay đổi
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Thêm logic lưu thay đổi
                },
                child: const Text('Lưu thay đổi'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper để tạo các trường thông tin
  Widget _buildInfoTextField({required String label, required String value}) {
    return TextFormField(
      initialValue: value,
      readOnly: true, // Đặt là true để chỉ hiển thị, không cho sửa
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}