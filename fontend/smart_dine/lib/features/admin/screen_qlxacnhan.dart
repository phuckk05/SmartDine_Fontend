import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/style.dart';
import 'package:mart_dine/models/xacnhan_model.dart';
import 'package:mart_dine/providers/xacnhan_providers.dart';

class ConfirmManagementScreen extends ConsumerWidget {
  const ConfirmManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredList = ref.watch(filteredUserRequestsProvider);

    return Scaffold(
      backgroundColor: Style.backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(ref),
          _buildHeader(),
          const SizedBox(height: Style.spacingSmall),
          _buildUserList(context, ref, filteredList),
        ],
      ),
    );
  }

  // AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Quản lý xác nhận',
        style: Style.fontTitle.copyWith(
          color: Style.textColorWhite,
          fontSize: 20,
        ),
      ),
      backgroundColor: const Color(0xFF1976D2),
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
    );
  }

  // Search bar
  Widget _buildSearchBar(WidgetRef ref) {
    return Container(
      color: Style.colorLight,
      padding: const EdgeInsets.all(Style.paddingPhone),
      child: TextField(
        onChanged: (value) {
          ref.read(searchQueryProvider.notifier).state = value;
        },
        decoration: InputDecoration(
          hintText: 'Tìm kiếm',
          hintStyle: Style.fontNormal.copyWith(color: Style.textColorGray),
          prefixIcon: Icon(Icons.search, color: Style.textColorGray),
          filled: true,
          fillColor: Colors.grey[300],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  // Header
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: Style.colorLight,
      padding: const EdgeInsets.symmetric(
        horizontal: Style.paddingPhone,
        vertical: 12,
      ),
      child: Text('Tất cả các thông tin', style: Style.fontTitleSuperMini),
    );
  }

  // User list
  Widget _buildUserList(
    BuildContext context,
    WidgetRef ref,
    List<UserRequest> filteredList,
  ) {
    return Expanded(
      child:
          filteredList.isEmpty
              ? Center(
                child: Text(
                  'Không tìm thấy kết quả',
                  style: Style.fontNormal.copyWith(color: Style.textColorGray),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: Style.paddingPhone,
                ),
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final user = filteredList[index];
                  return _buildUserCard(context, ref, user);
                },
              ),
    );
  }

  // User card
  Widget _buildUserCard(BuildContext context, WidgetRef ref, UserRequest user) {
    return GestureDetector(
      onTap: () => _showUserDetailDialog(context, ref, user),
      child: Container(
        margin: const EdgeInsets.only(bottom: Style.spacingSmall),
        padding: const EdgeInsets.all(Style.paddingPhone),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(Style.cardBorderRadius),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.userName, style: Style.fontTitleMini),
                  const SizedBox(height: 4),
                  Text(
                    user.roleDisplay,
                    style: Style.fontCaption.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
            // Status badge
            if (!user.isPending)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: user.isConfirmed ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  user.statusDisplay,
                  style: Style.fontCaption.copyWith(
                    color: Style.textColorWhite,
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // User detail dialog
  void _showUserDetailDialog(
    BuildContext context,
    WidgetRef ref,
    UserRequest user,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Style.dialogBorderRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Chi tiết ${user.userName.toLowerCase()}',
                    style: Style.fontTitleMini,
                  ),
                  const SizedBox(height: Style.spacingMedium),
                  Text(user.roleDisplay, style: Style.fontNormal),
                  const SizedBox(height: Style.spacingMedium),
                  _buildInfoRow('Tên người dùng:', user.fullName),
                  _buildInfoRow('Địa chỉ:', user.address),
                  _buildInfoRow('Số điện thoại:', user.phone),
                  _buildInfoRow('Ngày yêu cầu:', user.formattedRequestDate),
                  if (user.email != null && user.email!.isNotEmpty)
                    _buildInfoRow('Email:', user.email!),
                  const SizedBox(height: Style.spacingMedium),
                  Text(
                    user.isPending
                        ? 'Đang chờ xác nhận ...'
                        : user.statusDisplay,
                    style: Style.fontCaption.copyWith(
                      fontStyle: FontStyle.italic,
                      color: user.isConfirmed ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (user.isPending) _buildActionButtons(context, ref, user),
                ],
              ),
            ),
          ),
    );
  }

  // Action buttons
  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    UserRequest user,
  ) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              ref.read(userRequestListProvider.notifier).confirmUser(user.id);
              Navigator.pop(context);
              _showSnackBar(context, 'Đã xác nhận thành công', Colors.green);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Style.textColorWhite,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Style.buttonBorderRadius),
              ),
            ),
            child: Text('Xác Nhận', style: Style.fontButton),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              _showRejectConfirmDialog(context, ref, user);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Style.buttonBorderRadius),
              ),
            ),
            child: Text(
              'Từ chối',
              style: Style.fontButton.copyWith(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  // Info row
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: Style.fontNormal)),
          Expanded(child: Text(value, style: Style.fontTitleSuperMini)),
        ],
      ),
    );
  }

  // Reject confirmation dialog
  void _showRejectConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    UserRequest user,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Xác nhận từ chối', style: Style.fontTitleMini),
            content: Text(
              'Bạn có chắc muốn từ chối yêu cầu của ${user.userName}?',
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
              TextButton(
                onPressed: () {
                  ref
                      .read(userRequestListProvider.notifier)
                      .rejectUser(user.id);
                  Navigator.pop(context);
                  _showSnackBar(context, 'Đã từ chối yêu cầu', Colors.red);
                },
                child: Text(
                  'Từ chối',
                  style: Style.fontButton.copyWith(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  // Show snackbar
  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: Style.fontNormal.copyWith(color: Style.textColorWhite),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
