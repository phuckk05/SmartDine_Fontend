import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mart_dine/models/pending_company.dart';

class CompanyItem extends StatelessWidget {
  final PendingCompany company;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const CompanyItem({
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},

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
            company.companyName,
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Chi tiết công ty',
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

                  /// Company Info
                  _buildInfoRow('Tên công ty:', company.companyName),
                  _buildInfoRow('Mã:', company.companyCode),
                  _buildInfoRow('Địa chỉ:', company.address),
                  _buildInfoRow('Ngày tạo:', _formatDate(company.createdAt)),
                  _buildInfoRow('Cập nhật:', _formatDate(company.updatedAt)),
                  _buildInfoRow('Trạng thái:', company.companyStatus),

                  const SizedBox(height: 16),

                  /// Owner Info
                  const Text(
                    "Thông tin chủ sở hữu",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),

                  _buildInfoRow('Tên:', company.fullName),
                  _buildInfoRow('Email:', company.email),
                  _buildInfoRow('SĐT:', company.phoneNumber),
                  _buildInfoRow('Trạng thái:', company.ownerStatus),

                  const SizedBox(height: 16),

                  /// Images
                  const Text(
                    "Hình ảnh CCCD:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      if (company.frontImage.isNotEmpty)
                        Expanded(
                          child: Image.network(
                            company.frontImage,
                            height: 130,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(width: 10),
                      if (company.backImage.isNotEmpty)
                        Expanded(
                          child: Image.network(
                            company.backImage,
                            height: 130,
                            fit: BoxFit.cover,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

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
            width: 120,
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
