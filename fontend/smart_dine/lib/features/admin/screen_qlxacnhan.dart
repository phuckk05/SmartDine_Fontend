import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/providers/qlxacnhan_provider.dart';
import 'package:mart_dine/models/company_item.dart';

class ScreenQlXacNhan extends ConsumerWidget {
  const ScreenQlXacNhan({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companiesAsync = ref.watch(qlXacNhanProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý xác nhận'), centerTitle: true),
      body: companiesAsync.when(
        data: (companies) {
          if (companies.isEmpty) {
            return const Center(child: Text('Không có công ty chờ duyệt.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Kéo xuống để tải lại dữ liệu
              await ref.read(qlXacNhanProvider.notifier).loadPendingCompanies();
            },
            child: ListView.builder(
              itemCount: companies.length,
              itemBuilder: (context, index) {
                final company = companies[index];
                return CompanyItem(
                  company: company,
                  onApprove: () async {
                    await ref
                        .read(qlXacNhanProvider.notifier)
                        .approveCompany(company.id!);

                    // Sau khi duyệt, load lại dữ liệu
                    await ref
                        .read(qlXacNhanProvider.notifier)
                        .loadPendingCompanies();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ Đã duyệt công ty ${company.name}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  onReject: () async {
                    await ref
                        .read(qlXacNhanProvider.notifier)
                        .rejectCompany(company.id!);

                    await ref
                        .read(qlXacNhanProvider.notifier)
                        .loadPendingCompanies();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ Đã từ chối công ty ${company.name}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                  onDelete: () async {
                    await ref
                        .read(qlXacNhanProvider.notifier)
                        .deleteCompany(company.id!);

                    await ref
                        .read(qlXacNhanProvider.notifier)
                        .loadPendingCompanies();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🗑️ Đã xóa công ty ${company.name}'),
                        backgroundColor: Colors.grey[700],
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }
}
