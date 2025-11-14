import 'package:flutter/material.dart';
import 'package:mart_dine/models/company_owner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/providers/qlcuahang_provider.dart';

class ItemCuaHang extends ConsumerWidget {
  final CompanyOwner item;
  final VoidCallback onDelete;

  const ItemCuaHang({
    Key? key,
    required this.item,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = item.statusId == 1;
    final statusText = isActive ? "Đang hoạt động" : "Đang bị khóa";
    final statusColor = isActive ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(
          item.companyName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("Chủ cửa hàng: ${item.ownerName}"),
            Text("SĐT: ${item.phoneNumber}"),
            Text("Số chi nhánh: ${item.totalBranches}"),
            const SizedBox(height: 6),
            Row(
              children: [
                const Text("Trạng thái: "),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🧩 Nút khóa / mở khóa
            IconButton(
              icon: Icon(
                isActive ? Icons.lock_outline : Icons.lock_open,
                color: isActive ? Colors.orange : Colors.green,
              ),
              tooltip: isActive ? 'Khóa cửa hàng' : 'Mở khóa cửa hàng',
              onPressed: () async {
                try {
                  if (isActive) {
                    await ref.read(companyOwnerApiProvider).deactivateCompany(item.companyId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Đã khóa cửa hàng '${item.companyName}'")),
                    );
                  } else {
                    await ref.read(companyOwnerApiProvider).activateCompany(item.companyId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Đã mở khóa cửa hàng '${item.companyName}'")),
                    );
                  }

                  ref.invalidate(companyOwnerListProvider);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Lỗi khi cập nhật trạng thái: $e")),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
