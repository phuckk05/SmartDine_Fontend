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
      backgroundColor: const Color(0xFFF8F9FB),
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
        // ------------------- DỮ LIỆU -------------------
        data: (list) {
          if (list.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(companyOwnerListProvider);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.store_mall_directory,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Không có cửa hàng nào được duyệt.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          // Sắp xếp mới nhất
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(companyOwnerListProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
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

        // ------------------- LOADING -------------------
        loading:
            () => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.blueAccent),
                  SizedBox(height: 16),
                  Text(
                    'Đang tải dữ liệu...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),

        // ------------------- ERROR -------------------
        error:
            (err, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Lỗi tải dữ liệu:\n$err",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 15),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => ref.invalidate(companyOwnerListProvider),
                      label: const Text('Thử lại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}
