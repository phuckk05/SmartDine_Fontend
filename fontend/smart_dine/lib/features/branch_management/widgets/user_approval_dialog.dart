import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/style.dart';
import '../../../core/constrats.dart';
import '../../../models/user.dart';
import '../../../providers/user_approval_provider.dart';

class UserApprovalDialog extends ConsumerStatefulWidget {
  final int companyId;
  
  const UserApprovalDialog({
    super.key,
    required this.companyId,
  });

  @override
  ConsumerState<UserApprovalDialog> createState() => _UserApprovalDialogState();
}

class _UserApprovalDialogState extends ConsumerState<UserApprovalDialog> {
  final TextEditingController _reasonController = TextEditingController();
  
  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pendingUsers = ref.watch(userApprovalNotifierProvider(widget.companyId));
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: isDark ? Style.colorDark : Style.colorLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Style.buttonBackgroundColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.pending_actions,
                    color: Style.buttonBackgroundColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Duyệt tài khoản nhân viên',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Style.colorLight : Style.colorDark,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: isDark ? Style.colorLight : Style.colorDark,
                    ),
                  ),
                ],
              ),
            ),
            
            // Body
            Expanded(
              child: pendingUsers.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Lỗi tải dữ liệu',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Style.colorLight : Style.colorDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                data: (users) {
                  if (users.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: Colors.green.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Không có tài khoản nào chờ duyệt',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Style.colorLight : Style.colorDark,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      return _buildUserCard(users[index], isDark);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(User user, bool isDark) {
    final textColor = isDark ? Style.colorLight : Style.colorDark;
    final cardColor = isDark ? Style.colorDark.withOpacity(0.3) : Style.colorLight;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: Style.buttonBackgroundColor.withOpacity(0.1),
                child: Text(
                  _getAvatarInitial(user.fullName),
                  style: TextStyle(
                    color: Style.buttonBackgroundColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      user.phone,
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // Role badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRoleColor(user.role),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getRoleName(user.role),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Registration date
          Text(
            'Đăng ký: ${_formatDate(user.createdAt)}',
            style: TextStyle(
              fontSize: 12,
              color: textColor.withOpacity(0.6),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              // Approve button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _approveUser(user.id!),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Duyệt'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Reject button  
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _rejectUser(user.id!),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Từ chối'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getAvatarInitial(String fullName) {
    if (fullName.isEmpty) return '?';
    final words = fullName.trim().split(' ');
    if (words.length >= 2) {
      return '${words.first[0]}${words.last[0]}'.toUpperCase();
    }
    return fullName[0].toUpperCase();
  }

  String _getRoleName(int? role) {
    switch (role) {
      case 1:
        return 'Admin';
      case 2:
        return 'Manager';
      case 3:
        return 'Staff';
      case 4:
        return 'Waiter';
      case 5:
        return 'Owner';
      default:
        return 'Unknown';
    }
  }

  Color _getRoleColor(int? role) {
    switch (role) {
      case 1:
        return Colors.purple;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.green;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _approveUser(int userId) async {
    try {
      final notifier = ref.read(userApprovalNotifierProvider(widget.companyId).notifier);
      final success = await notifier.approveUser(userId);
      
      if (success) {
        Constrats.showThongBao(context, 'Đã duyệt tài khoản thành công!');
      } else {
        Constrats.showThongBao(context, 'Lỗi duyệt tài khoản!');
      }
    } catch (e) {
      Constrats.showThongBao(context, 'Lỗi: ${e.toString()}');
    }
  }

  Future<void> _rejectUser(int userId) async {
    // Show reason dialog
    String? reason = await _showReasonDialog('Lý do từ chối tài khoản:');
    
    try {
      final notifier = ref.read(userApprovalNotifierProvider(widget.companyId).notifier);
      final success = await notifier.rejectUser(userId, reason: reason);
      
      if (success) {
        Constrats.showThongBao(context, 'Đã từ chối tài khoản thành công!');
      } else {
        Constrats.showThongBao(context, 'Lỗi từ chối tài khoản!');
      }
    } catch (e) {
      Constrats.showThongBao(context, 'Lỗi: ${e.toString()}');
    }
  }

  Future<String?> _showReasonDialog(String title) async {
    _reasonController.clear();
    
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return AlertDialog(
          backgroundColor: isDark ? Style.colorDark : Style.colorLight,
          title: Text(
            title,
            style: TextStyle(
              color: isDark ? Style.colorLight : Style.colorDark,
            ),
          ),
          content: TextField(
            controller: _reasonController,
            decoration: InputDecoration(
              hintText: 'Nhập lý do (không bắt buộc)',
              hintStyle: TextStyle(
                color: (isDark ? Style.colorLight : Style.colorDark).withOpacity(0.5),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            maxLines: 3,
            style: TextStyle(
              color: isDark ? Style.colorLight : Style.colorDark,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(
                'Hủy',
                style: TextStyle(
                  color: isDark ? Style.colorLight : Style.colorDark,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(_reasonController.text.trim()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Style.buttonBackgroundColor,
              ),
              child: const Text(
                'Xác nhận',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}