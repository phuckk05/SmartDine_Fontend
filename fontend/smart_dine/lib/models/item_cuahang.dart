import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models/company_owner.dart';
import 'package:mart_dine/providers/qlcuahang_provider.dart';
import 'package:mart_dine/features/admin/screen_company_detail.dart';

class ItemCuaHang extends ConsumerWidget {
  final CompanyOwner company;
  const ItemCuaHang({super.key, required this.company});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // Điều hướng sang màn chi tiết
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (_) => ScreenCompanyDetail(companyId: company.companyId!),
        //   ),
        // );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon đại diện công ty
            Container(
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.store,
                color: Colors.blueAccent,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Thông tin cửa hàng
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company.companyName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Chủ sở hữu: ${company.ownerName}",
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  Text(
                    "SĐT: ${company.phoneNumber}",
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  Text(
                    "User ID: ${company.userId}",
                    style: const TextStyle(color: Colors.black45, fontSize: 13),
                  ),
                ],
              ),
            ),
            // Nút menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black54),
              onSelected: (value) async {
                if (value == 'delete') {
                  _confirmDelete(context, ref, company.companyId!);
                } else if (value == 'detail') {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder:
                  //         (_) => ScreenCompanyDetail(
                  //           companyId: company.companyId!,
                  //         ),
                  //   ),
                  // );
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'detail',
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blueAccent),
                          SizedBox(width: 8),
                          Text('Xem chi tiết'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.redAccent),
                          SizedBox(width: 8),
                          Text('Xóa'),
                        ],
                      ),
                    ),
                  ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, int companyId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: const Text('Bạn có chắc muốn xóa công ty này không?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  await ref
                      .read(qlCuaHangProvider.notifier)
                      .deleteCompany(companyId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã xóa công ty thành công')),
                  );
                },
                child: const Text('Xóa'),
              ),
            ],
          ),
    );
  }
}
