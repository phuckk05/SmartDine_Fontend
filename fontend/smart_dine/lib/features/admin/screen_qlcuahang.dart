import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models/company.dart';
import 'package:mart_dine/providers/qlcuahang_provider.dart';
import 'package:mart_dine/models/cuahang_item.dart';

class ScreenQlcuahang extends ConsumerStatefulWidget {
  const ScreenQlcuahang({super.key});

  @override
  ConsumerState<ScreenQlcuahang> createState() => _ScreenQlcuahangState();
}

class _ScreenQlcuahangState extends ConsumerState<ScreenQlcuahang> {
  @override
  Widget build(BuildContext context) {
    final storeAsync = ref.watch(qlCuaHangProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text(
          'Quản lý cửa hàng',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        elevation: 0,
      ),
      body: storeAsync.when(
        data: (stores) {
          if (stores.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.storefront, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Không có cửa hàng nào được duyệt.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh:
                () async =>
                    ref.read(qlCuaHangProvider.notifier).loadActiveStores(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: stores.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final store = stores[index];
                return CuaHangItem(
                  store: store,
                  onToggle: (isActive) async {
                    await ref
                        .read(qlCuaHangProvider.notifier)
                        .toggleStoreStatus(store.id!, isActive);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isActive
                              ? '✅ Đã kích hoạt ${store.name}'
                              : '🚫 Đã vô hiệu ${store.name}',
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor:
                            isActive ? Colors.green : Colors.redAccent,
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
        loading:
            () => const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            ),
        error:
            (err, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.redAccent,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Lỗi khi tải dữ liệu:\n$err',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed:
                          () =>
                              ref
                                  .read(qlCuaHangProvider.notifier)
                                  .loadActiveStores(),
                      icon: const Icon(Icons.refresh),
                      label: const Text("Thử lại"),
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
