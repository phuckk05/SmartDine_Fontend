import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/style.dart';
import 'screen_hoso.dart';
import 'package:mart_dine/models/cuahang_model.dart';
import 'package:mart_dine/providers/cuahang_providers.dart';

class StoreManagementScreen extends ConsumerWidget {
  const StoreManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredStores = ref.watch(filteredStoresProvider);

    return Scaffold(
      backgroundColor: Style.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Quản lý của hàng',
          style: Style.fontTitle.copyWith(
            color: Style.textColorWhite,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(Style.paddingPhone),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với nút "Xóa tất cả"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Danh sách cửa hàng', style: Style.fontTitle),
                ElevatedButton.icon(
                  onPressed: () {
                    _showDeleteAllDialog(context, ref);
                  },
                  icon: const Icon(Icons.delete, size: 18),
                  label: Text('Xóa tất cả', style: Style.fontButton),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Style.textColorWhite,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: Style.spacingMedium),

            // Table
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(Style.borderRadius),
                color: Style.colorLight,
              ),
              child: Column(
                children: [
                  // Table header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Style.paddingPhone,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Style.colorLight,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[400]!),
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(Style.borderRadius),
                        topRight: Radius.circular(Style.borderRadius),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 50,
                          child: Text('STT', style: Style.fontTitleSuperMini),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Tên nhà hàng',
                            style: Style.fontTitleSuperMini,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Chủ nhà hàng',
                            style: Style.fontTitleSuperMini,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Số điện thoại',
                            style: Style.fontTitleSuperMini,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Số chi nhánh',
                            style: Style.fontTitleSuperMini,
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: Center(
                            child: Text(
                              'Thao tác',
                              style: Style.fontTitleSuperMini,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // List items
                  if (filteredStores.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          'Không có dữ liệu',
                          style: Style.fontNormal.copyWith(
                            color: Style.textColorGray,
                          ),
                        ),
                      ),
                    )
                  else
                    ...filteredStores.asMap().entries.map((entry) {
                      final index = entry.key;
                      final store = entry.value;
                      return _buildStoreRow(
                        context,
                        ref,
                        store,
                        index + 1,
                        index == filteredStores.length - 1,
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreRow(
    BuildContext context,
    WidgetRef ref,
    Store store,
    int index,
    bool isLast,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Style.paddingPhone,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.grey[100] : Style.colorLight,
        border:
            isLast
                ? null
                : Border(bottom: BorderSide(color: Colors.grey[300]!)),
        borderRadius:
            isLast
                ? BorderRadius.only(
                  bottomLeft: Radius.circular(Style.borderRadius),
                  bottomRight: Radius.circular(Style.borderRadius),
                )
                : null,
      ),
      child: Row(
        children: [
          // STT
          SizedBox(
            width: 50,
            child: Text(index.toString(), style: Style.fontNormal),
          ),

          // Tên nhà hàng
          Expanded(flex: 2, child: Text(store.name, style: Style.fontNormal)),

          // Chủ nhà hàng
          Expanded(
            flex: 2,
            child: Text(store.ownerName, style: Style.fontNormal),
          ),

          // Số điện thoại
          Expanded(flex: 2, child: Text(store.phone, style: Style.fontNormal)),

          // Số chi nhánh
          Expanded(
            child: Text(store.branchNumber.toString(), style: Style.fontNormal),
          ),

          // Thao tác
          SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    color: Colors.blue,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => StoreDetailScreen(storeId: store.id),
                        ),
                      );
                    },
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete, size: 18),
                    color: Colors.red,
                    onPressed: () {
                      _showDeleteDialog(context, ref, store);
                    },
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Store store) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Xác nhận xóa', style: Style.fontTitleMini),
            content: Text(
              'Bạn có chắc muốn xóa "${store.name}"?',
              style: Style.fontNormal,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Hủy',
                  style: Style.fontButton.copyWith(color: Style.textColorGray),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  ref.read(storeListProvider.notifier).deleteStore(store.id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Đã xóa cửa hàng',
                        style: Style.fontNormal.copyWith(
                          color: Style.textColorWhite,
                        ),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Xóa', style: Style.fontButton),
              ),
            ],
          ),
    );
  }

  void _showDeleteAllDialog(BuildContext context, WidgetRef ref) {
    // Kiểm tra xem có cửa hàng nào không
    final stores = ref.read(storeListProvider);
    if (stores.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không có cửa hàng nào để xóa',
            style: Style.fontNormal.copyWith(color: Style.textColorWhite),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Xác nhận xóa tất cả', style: Style.fontTitleMini),
            content: Text(
              'Bạn có chắc muốn xóa tất cả ${stores.length} cửa hàng?\n\nHành động này không thể hoàn tác!',
              style: Style.fontNormal,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Hủy',
                  style: Style.fontButton.copyWith(color: Style.textColorGray),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Thực hiện xóa tất cả
                  ref.read(storeListProvider.notifier).deleteAllStores();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Đã xóa tất cả ${stores.length} cửa hàng',
                        style: Style.fontNormal.copyWith(
                          color: Style.textColorWhite,
                        ),
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Xóa tất cả', style: Style.fontButton),
              ),
            ],
          ),
    );
  }
}
