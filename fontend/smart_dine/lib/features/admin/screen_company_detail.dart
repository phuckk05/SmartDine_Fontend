import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mart_dine/models/pending_company.dart';

class ScreenCompanyDetail extends StatelessWidget {
  final PendingCompany company;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const ScreenCompanyDetail({
    super.key,
    required this.company,
    required this.onApprove,
    required this.onReject,
  });

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy - HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _handleAction(
    BuildContext context,
    VoidCallback callback,
  ) async {
    // Hiện loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // Gọi callback (API đang xử lý ở màn trước)
    callback();

    await Future.delayed(const Duration(milliseconds: 300));

    Navigator.pop(context); // tắt loading
    Navigator.pop(context); // quay lại trang trước
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết công ty"),
        backgroundColor: Colors.blueAccent,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              company.companyName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            _buildInfoRow("Mã công ty:", company.companyCode),
            _buildInfoRow("Địa chỉ:", company.address),
            _buildInfoRow("Ngày tạo:", _formatDate(company.createdAt)),
            _buildInfoRow("Cập nhật:", _formatDate(company.updatedAt)),
            _buildInfoRow("Trạng thái:", company.companyStatus),

            const SizedBox(height: 20),

            const Text(
              "Thông tin chủ sở hữu",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),

            const SizedBox(height: 10),

            _buildInfoRow("Họ tên:", company.fullName),
            _buildInfoRow("Email:", company.email),
            _buildInfoRow("SĐT:", company.phoneNumber),
            _buildInfoRow("Trạng thái:", company.ownerStatus),

            const SizedBox(height: 20),

            const Text(
              "Ảnh CCCD",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                if (company.frontImage.isNotEmpty)
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        company.frontImage,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                if (company.backImage.isNotEmpty)
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        company.backImage,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _handleAction(context, onReject),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  icon: const Icon(Icons.close),
                  label: const Text("Từ chối"),
                ),

                ElevatedButton.icon(
                  onPressed: () => _handleAction(context, onApprove),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  icon: const Icon(Icons.check),
                  label: const Text("Duyệt"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
