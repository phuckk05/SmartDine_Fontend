import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models/item_cuahang.dart';
import 'package:mart_dine/providers/qlcuahang_provider.dart';

class ScreenQlCuaHang extends ConsumerWidget {
  const ScreenQlCuaHang({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(companyOwnerListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hoạt động cửa hàng',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: asyncList.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text("Không có cửa hàng nào được duyệt."),
            );
          }

          //Sắp xếp giảm dần theo thời gian tạo (mới nhất lên đầu)
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(companyOwnerListProvider),
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                return ItemCuaHang(
                  item: item,
                  onDelete: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text("Xác nhận xóa"),
                            content: Text(
                              "Bạn có chắc muốn xóa cửa hàng '${item.companyName}' không?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Hủy"),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Xóa"),
                              ),
                            ],
                          ),
                    );

                    if (confirm == true) {
                      try {
                        await ref
                            .read(companyOwnerApiProvider)
                            .deleteCompany(item.userId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Đã xóa cửa hàng '${item.companyName}' thành công",
                            ),
                          ),
                        );
                        ref.invalidate(companyOwnerListProvider);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Lỗi khi xóa: ${e.toString()}"),
                          ),
                        );
                      }
                    }
                  },
                );
              },
            ),
          );
        },
        error: (err, stack) => Center(child: Text("Lỗi tải dữ liệu: $err")),
        loading:
            () => const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            ),
      ),
    );
  }
}
