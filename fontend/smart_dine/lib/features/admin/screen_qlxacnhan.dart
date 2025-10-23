import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/style.dart';

// Model
class UserRequest {
  final String id;
  final String userName;
  final String role;
  final String fullName;
  final String address;
  final String phone;
  final DateTime requestDate;
  bool isConfirmed;

  UserRequest({
    required this.id,
    required this.userName,
    required this.role,
    required this.fullName,
    required this.address,
    required this.phone,
    required this.requestDate,
    this.isConfirmed = false,
  });
}

// Provider cho danh sách user
final userRequestListProvider =
    StateNotifierProvider<UserRequestNotifier, List<UserRequest>>((ref) {
      return UserRequestNotifier();
    });

class UserRequestNotifier extends StateNotifier<List<UserRequest>> {
  UserRequestNotifier() : super([]) {
    _loadData();
  }

  void _loadData() {
    state = [
      UserRequest(
        id: '1',
        userName: 'Người Dùng 1',
        role: 'Quản lý chi nhánh',
        fullName: 'Nguyễn Văn A',
        address: 'Chi nhánh Quận 1,TP.HCM',
        phone: '0123456789',
        requestDate: DateTime(2025, 9, 29),
      ),
      UserRequest(
        id: '2',
        userName: 'Người Dùng 2',
        role: 'Thu Ngân',
        fullName: 'Trần Thị B',
        address: 'Chi nhánh Quận 2,TP.HCM',
        phone: '0987654321',
        requestDate: DateTime(2025, 9, 28),
      ),
      UserRequest(
        id: '3',
        userName: 'Người Dùng 3',
        role: 'Quản lý chi nhánh',
        fullName: 'Lê Văn C',
        address: 'Chi nhánh Quận 3,TP.HCM',
        phone: '0912345678',
        requestDate: DateTime(2025, 9, 27),
      ),
      UserRequest(
        id: '4',
        userName: 'Người Dùng 4',
        role: 'Nhân Viên',
        fullName: 'Phạm Thị D',
        address: 'Chi nhánh Quận 4,TP.HCM',
        phone: '0898765432',
        requestDate: DateTime(2025, 9, 26),
      ),
      UserRequest(
        id: '5',
        userName: 'Người Dùng 5',
        role: 'Nhân Viên',
        fullName: 'Hoàng Văn E',
        address: 'Chi nhánh Quận 5,TP.HCM',
        phone: '0901234567',
        requestDate: DateTime(2025, 9, 25),
      ),
    ];
  }

  void confirmUser(String id) {
    state = [
      for (final item in state)
        if (item.id == id)
          UserRequest(
            id: item.id,
            userName: item.userName,
            role: item.role,
            fullName: item.fullName,
            address: item.address,
            phone: item.phone,
            requestDate: item.requestDate,
            isConfirmed: true,
          )
        else
          item,
    ];
  }

  void rejectUser(String id) {
    state = state.where((item) => item.id != id).toList();
  }
}

// Provider cho search
final searchQueryProvider = StateProvider<String>((ref) => '');

class ConfirmManagementScreen extends ConsumerWidget {
  const ConfirmManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userList = ref.watch(userRequestListProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    // Filter theo search
    final filteredList =
        searchQuery.isEmpty
            ? userList
            : userList
                .where(
                  (user) =>
                      user.userName.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ) ||
                      user.role.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ),
                )
                .toList();

    return Scaffold(
      backgroundColor: Style.backgroundColor,
      appBar: AppBar(
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
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Style.colorLight,
            padding: const EdgeInsets.all(Style.paddingPhone),
            child: TextField(
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: 'Tìm kiếm',
                hintStyle: Style.fontNormal.copyWith(
                  color: Style.textColorGray,
                ),
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
          ),

          // Header
          Container(
            width: double.infinity,
            color: Style.colorLight,
            padding: const EdgeInsets.symmetric(
              horizontal: Style.paddingPhone,
              vertical: 12,
            ),
            child: Text(
              'Tất cả các thông tin',
              style: Style.fontTitleSuperMini,
            ),
          ),

          const SizedBox(height: Style.spacingSmall),

          // List
          Expanded(
            child:
                filteredList.isEmpty
                    ? Center(
                      child: Text(
                        'Không tìm thấy kết quả',
                        style: Style.fontNormal.copyWith(
                          color: Style.textColorGray,
                        ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, WidgetRef ref, UserRequest user) {
    return GestureDetector(
      onTap: () {
        _showUserDetailDialog(context, ref, user);
      },
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
                    user.role,
                    style: Style.fontCaption.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                  // Title
                  Text(
                    'Chi tiết ${user.userName.toLowerCase()}',
                    style: Style.fontTitleMini,
                  ),
                  const SizedBox(height: Style.spacingMedium),

                  // Role
                  Text(user.role, style: Style.fontNormal),
                  const SizedBox(height: Style.spacingMedium),

                  // Info
                  _buildInfoRow('Tên người dùng:', user.fullName),
                  _buildInfoRow('Địa chỉ', user.address),
                  _buildInfoRow('Số điện thoại', user.phone),
                  _buildInfoRow(
                    'Ngày yêu cầu:',
                    '${user.requestDate.day.toString().padLeft(2, '0')}/${user.requestDate.month.toString().padLeft(2, '0')}/${user.requestDate.year}',
                  ),

                  const SizedBox(height: Style.spacingMedium),

                  // Status text
                  Text(
                    'Đang chờ xác nhận ...',
                    style: Style.fontCaption.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ref
                                .read(userRequestListProvider.notifier)
                                .confirmUser(user.id);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Đã xác nhận thành công',
                                  style: Style.fontNormal.copyWith(
                                    color: Style.textColorWhite,
                                  ),
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Style.textColorWhite,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                Style.buttonBorderRadius,
                              ),
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
                            _showDeleteConfirmDialog(context, ref, user);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(
                              color: Colors.red,
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                Style.buttonBorderRadius,
                              ),
                            ),
                          ),
                          child: Text(
                            'Từ chối',
                            style: Style.fontButton.copyWith(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

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

  void _showDeleteConfirmDialog(
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Đã từ chối yêu cầu',
                        style: Style.fontNormal.copyWith(
                          color: Style.textColorWhite,
                        ),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
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
}
