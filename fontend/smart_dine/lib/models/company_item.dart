import 'package:flutter/material.dart';
import 'package:mart_dine/models/company.dart';

class CompanyItem extends StatelessWidget {
  final Company company;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const CompanyItem({
    super.key,
    required this.company,
    required this.onApprove,
    required this.onReject,
  });



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCompanyDetailDialog(context),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blueAccent.withOpacity(0.1),
            child: const Icon(Icons.business, color: Colors.blueAccent),
          ),
          title: Text(
            company.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Mã: ${company.companyCode}\nĐịa chỉ: ${company.address}',
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }

  void _showCompanyDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tiêu đề
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Chi tiết thông tin',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Nội dung thông tin
                _buildInfoRow('Tên:', company.name),
                _buildInfoRow('Mã:', company.companyCode),
                _buildInfoRow('Địa chỉ:', company.address),
                _buildInfoRow(
                  'Ngày tạo:',
                  '${company.createdAt.day}/${company.createdAt.month}/${company.createdAt.year}',
                ),
                _buildInfoRow(
                  'Cập nhật:',
                  '${company.updatedAt.day}/${company.updatedAt.month}/${company.updatedAt.year}',
                ),
                _buildInfoRow('Trạng thái:', company.statusId.toString()),
                const SizedBox(height: 20),

                // Nút hành động
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onReject();
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Từ chối'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onApprove();
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Duyệt'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
