import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/providers/admin_stats_provider.dart';
import 'package:mart_dine/widgets/stat_card.dart';

class ScreenAdminDashboard extends ConsumerWidget {
  const ScreenAdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncStats = ref.watch(adminStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Admin"),
        backgroundColor: Colors.teal,
      ),
      body: asyncStats.when(
        loading:
            () => const Center(
              child: CircularProgressIndicator(color: Colors.teal),
            ),

        error: (err, _) => Center(child: Text("Lỗi tải dữ liệu: $err")),

        data:
            (stats) => Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      StatCard(
                        icon: Icons.store_mall_directory,
                        title: "Tổng công ty",
                        value: stats.totalCompanies.toString(),
                      ),
                      StatCard(
                        icon: Icons.apartment,
                        title: "Tổng chi nhánh",
                        value: stats.totalBranches.toString(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
