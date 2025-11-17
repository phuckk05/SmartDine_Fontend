// file: features/owner/screen_approve_branch.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/models_owner/branch.dart';
import 'package:mart_dine/providers_owner/branch_provider.dart';

class ScreenApproveBranch extends ConsumerWidget {
  const ScreenApproveBranch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Theo dõi provider chứa danh sách chi nhánh chờ duyệt
    final pendingBranchesAsync = ref.watch(pendingBranchesProvider);
    // Theo dõi Notifier để hiển thị trạng thái loading khi đang duyệt
    final branchUpdateState = ref.watch(branchUpdateNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Duyệt chi nhánh',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          pendingBranchesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Text('Lỗi tải danh sách: $err',
                  style: const TextStyle(color: Colors.red)),
            ),
            data: (branches) {
              if (branches.isEmpty) {
                return const Center(
                  child: Text(
                    'Không có chi nhánh nào đang chờ duyệt.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: branches.length,
                itemBuilder: (context, index) {
                  final branch = branches[index];
                  return _buildPendingBranchCard(context, ref, branch);
                },
              );
            },
          ),
          // Lớp phủ loading khi đang thực hiện duyệt
          if (branchUpdateState.isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildPendingBranchCard(
      BuildContext context, WidgetRef ref, Branch branch) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const Icon(Icons.storefront, color: Colors.orange, size: 40),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    branch.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    branch.address,
                    style: const TextStyle(color: Colors.black54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                // Gọi hàm duyệt chi nhánh từ Notifier
                ref
                    .read(branchUpdateNotifierProvider.notifier)
                    .approveBranch(branch);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Duyệt'),
            ),
          ],
        ),
      ),
    );
  }
}