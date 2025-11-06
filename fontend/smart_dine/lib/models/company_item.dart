import 'package:flutter/material.dart';
import 'package:mart_dine/models/company.dart';

class CompanyItem extends StatelessWidget {
  final Company company;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onDelete;

  const CompanyItem({
    Key? key,
    required this.company,
    required this.onApprove,
    required this.onReject,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          company.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mã công ty: ${company.companyCode}'),
            Text('Địa chỉ: ${company.address}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'approve':
                onApprove();
                break;
              case 'reject':
                onReject();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(value: 'approve', child: Text('Duyệt')),
                const PopupMenuItem(value: 'reject', child: Text('Từ chối')),
                const PopupMenuItem(value: 'delete', child: Text('Xóa')),
              ],
        ),
      ),
    );
  }
}
