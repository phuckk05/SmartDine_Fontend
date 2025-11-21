import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/features/staff/screen_choose_table.dart';
import 'package:mart_dine/model_staff/branch.dart';
import 'package:mart_dine/provider_staff/branch_provider.dart';
import 'package:mart_dine/routes.dart';

class ScreenBranchSelection extends ConsumerStatefulWidget {
  final int companyId;
  const ScreenBranchSelection({super.key, required this.companyId});

  @override
  ConsumerState<ScreenBranchSelection> createState() =>
      _ScreenBranchSelectionState();
}

class _ScreenBranchSelectionState extends ConsumerState<ScreenBranchSelection> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadBranches());
  }

  Future<void> _loadBranches() async {
    await ref
        .read(branchNotifierProvider2.notifier)
        .loadBranchesByCompanyId(widget.companyId);
  }

  @override
  Widget build(BuildContext context) {
    final branchState = ref.watch(branchNotifierProvider2);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chọn chi nhánh', style: Style.fontTitle),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vui lòng chọn chi nhánh của bạn',
                style: Style.fontTitle.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Các chi nhánh có sẵn cho công ty của bạn',
                style: Style.fontNormal.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: branchState.when(
                  data: (branches) => _buildBranchList(branches),
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error:
                      (error, stack) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Không thể tải danh sách chi nhánh'),
                            const SizedBox(height: 8),
                            Text('$error'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadBranches,
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBranchList(List<Branch> branches) {
    if (branches.isEmpty) {
      return const Center(
        child: Text('Không có chi nhánh nào cho công ty này'),
      );
    }

    return ListView.separated(
      itemCount: branches.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final branch = branches[index];
        return _buildBranchCard(branch);
      },
    );
  }

  Widget _buildBranchCard(Branch branch) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Routes.pushRightLeftConsumerFul(
            context,
            ScreenChooseTable(branchId: branch.id!),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.business, color: Colors.blue, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      branch.name,
                      style: Style.fontTitle.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      branch.address ?? 'Chưa có địa chỉ',
                      style: Style.fontNormal.copyWith(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
