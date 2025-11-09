import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/providers/qlcuahang_provider.dart';
import 'package:mart_dine/models/item_cuahang.dart';

class ScreenQlCuaHang extends ConsumerWidget {
  const ScreenQlCuaHang({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyState = ref.watch(qlCuaHangProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Quản lý cửa hàng"),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:
                () => ref.read(qlCuaHangProvider.notifier).loadCompanyOwners(),
          ),
        ],
      ),
      body: companyState.when(
        data: (companies) {
          if (companies.isEmpty) {
            return const Center(child: Text("Không có cửa hàng nào đã duyệt"));
          }
          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(qlCuaHangProvider.notifier).loadCompanyOwners();
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: companies.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final company = companies[index];
                return ItemCuaHang(company: company);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Lỗi: $e")),
      ),
    );
  }
}
