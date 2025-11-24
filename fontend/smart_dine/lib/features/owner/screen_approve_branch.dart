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
                  return _buildPendingBranchExpansionTile(context, ref, branch);
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

  Widget _buildPendingBranchExpansionTile(
      BuildContext context, WidgetRef ref, Branch branch) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, // Để bo tròn ExpansionTile
      child: ExpansionTile(
        leading: const Icon(Icons.storefront, color: Colors.orange, size: 40),
        title: Text(
          branch.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          branch.address,
          style: const TextStyle(color: Colors.black54),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Giấy phép kinh doanh:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8), // Bo tròn góc ảnh
                  // SỬA: Kiểm tra nếu branch.image có giá trị và không rỗng
                  child: (branch.image != null && branch.image!.isNotEmpty)
                      ? Image.network(
                          branch.image!, // Sử dụng URL ảnh từ đối tượng branch
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 150,
                          // Hiển thị vòng xoay trong khi tải ảnh
                          loadingBuilder: (context, child, progress) =>
                              progress == null
                                  ? child
                                  : const Center(child: CircularProgressIndicator()),
                          // Hiển thị icon lỗi nếu không tải được ảnh
                          errorBuilder: (context, error, stack) => const Center(
                              child: Icon(Icons.error_outline, color: Colors.red, size: 40)),
                        )
                      // Hiển thị placeholder nếu không có ảnh
                      : Container(
                          height: 150,
                          color: Colors.grey.shade200,
                          child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey, size: 40)),
                        ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => ref
                        .read(branchUpdateNotifierProvider.notifier)
                        .approveBranch(branch),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Duyệt'),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}