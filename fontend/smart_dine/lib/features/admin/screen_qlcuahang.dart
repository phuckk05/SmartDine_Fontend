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
        automaticallyImplyLeading: false,
      ),
      body: asyncList.when(
        // Dữ liệu
        data: (list) {
          if (list.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(companyOwnerListProvider);
              },
              child: ListView(
                children: const [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Danh sách hoạt động cửa hàng đã duyệt',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 250),
                  Center(
                    child: Text(
                      "Không có cửa hàng nào được duyệt.",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          }

          // Nếu có dữ liệu → sort + show list
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
                          SnackBar(content: Text("Lỗi khi xóa: $e")),
                        );
                      }
                    }
                  },
                );
              },
            ),
          );
        },

        // Lỗi
        error: (err, stack) => Center(child: Text("Lỗi tải dữ liệu: $err")),

        // Loading
        loading:
            () => const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            ),
      ),
    );
  }
}
