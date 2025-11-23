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
        title: const Text(
          'Dashboard Quản trị',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        automaticallyImplyLeading: false,
      ),

      body: RefreshIndicator(
        color: Colors.blueAccent,
        onRefresh: () async {
          /// Gọi refresh provider
          ref.invalidate(adminStatsProvider);
          await ref.read(adminStatsProvider.future);
        },

        child: asyncStats.when(
          loading:
              () => const Center(
                child: CircularProgressIndicator(color: Colors.blueAccent),
              ),

          error:
              (err, _) => ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: Center(child: Text("Lỗi tải dữ liệu: $err")),
                  ),
                ],
              ),

          data:
              (stats) => ListView(
                padding: const EdgeInsets.all(16),
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
