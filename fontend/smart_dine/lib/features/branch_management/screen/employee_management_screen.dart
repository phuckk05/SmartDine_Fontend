import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/core/style.dart';
import '../../../models/user.dart';
import '../../../providers/employee_management_provider.dart';

// Status class for user statuses
class UserStatus {
  final int id;
  final String name;
  final String code;

  UserStatus({
    required this.id,
    required this.name,
    required this.code,
  });
}

// Role class for user roles
class Role {
  final int id;
  final String name;
  final String code;

  Role({
    required this.id,
    required this.name,
    required this.code,
  });
}

class EmployeeManagementScreen extends ConsumerStatefulWidget {
  final bool showBackButton;
  
  const EmployeeManagementScreen({super.key, this.showBackButton = true});

  @override
  ConsumerState<EmployeeManagementScreen> createState() => _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState extends ConsumerState<EmployeeManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // Track which employee card is expanded
  int? _expandedIndex;
  
  // Controllers cho form thêm/sửa nhân viên
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // Data
  List<UserStatus> _userStatuses = [
    UserStatus(id: 1, name: 'Hoạt động', code: 'ACTIVE'),
    UserStatus(id: 2, name: 'Tạm ngưng', code: 'INACTIVE'),
    UserStatus(id: 3, name: 'Bị khóa', code: 'BLOCKED'),
  ];
  
  List<Role> _roles = [
    Role(id: 1, name: 'Quản lý', code: 'MANAGER'),
    Role(id: 2, name: 'Nhân viên phục vụ', code: 'WAITER'),
    Role(id: 3, name: 'Đầu bếp', code: 'CHEF'),
    Role(id: 4, name: 'Thu ngân', code: 'CASHIER'),
  ];
  
  int? _selectedStatusId;
  int? _selectedRoleId;

  @override
  void dispose() {
    _searchController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  int? _getBranchId() {
    // TODO: Get branchId từ user context thông qua UserBranch
    // For now, return mock branchId
    return 1; // Mock branch ID
  }

  @override
  Widget build(BuildContext context) {
    final branchId = _getBranchId();
    if (branchId == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy thông tin chi nhánh')),
      );
    }

    final employeesAsyncValue = ref.watch(employeeManagementProvider(branchId));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Style.colorLight : Style.colorDark;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[850] : Style.backgroundColor,
      appBar: widget.showBackButton
        ? AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text('Quản lý nhân viên', style: Style.fontTitle),
          )
        : AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: Text('Quản lý nhân viên', style: Style.fontTitle),
          ),
      body: employeesAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Lỗi khi tải dữ liệu',
                style: Style.fontTitleMini.copyWith(color: Colors.red),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Style.fontCaption.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(employeeManagementProvider(branchId));
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        data: (employees) => _buildEmployeeListView(employees, isDark, textColor, cardColor),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () => _showAddEmployeeDialog(context, isDark, textColor, cardColor),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Màn hình danh sách nhân viên
  Widget _buildEmployeeListView(List<User> employees, bool isDark, Color textColor, Color cardColor) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {}); // Rebuild để apply search filter
            },
            style: Style.fontNormal.copyWith(color: textColor),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm nhân viên',
              hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey),
              prefixIcon: Icon(Icons.search, color: textColor),
              filled: true,
              fillColor: cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        
        // Employee list
        Builder(
          builder: (context) {
            // Map roleId, statusId, companyId sang tên nếu thiếu
            List<User> mappedEmployees = employees.map((employee) {
              String? statusName = employee.statusName;
              if (statusName == null && employee.statusId != null) {
                final found = _userStatuses.firstWhere(
                  (s) => s.id == employee.statusId,
                  orElse: () => UserStatus(id: 0, name: 'Không xác định', code: 'UNKNOWN'),
                );
                statusName = found.name;
              }
              String? roleName = employee.roleName;
              if (roleName == null && employee.role != null) {
                final found = _roles.firstWhere(
                  (r) => r.id == employee.role,
                  orElse: () => Role(id: 0, name: 'Chưa có', code: 'NONE'),
                );
                roleName = found.name;
              }
              String? companyName = employee.companyName;
              if (companyName == null && employee.companyId != null) {
                companyName = 'ID: [${employee.companyId}]';
              }
              return employee.copyWith(
                statusName: statusName,
                roleName: roleName,
                companyName: companyName,
              );
            }).toList();
            return Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: mappedEmployees.length,
                itemBuilder: (context, index) {
                  final employee = mappedEmployees[index];
                  final isExpanded = _expandedIndex == index;
                  return _buildEmployeeCard(
                    employee,
                    index,
                    isExpanded,
                    isDark,
                    textColor,
                    cardColor,
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmployeeCard(
    User employee,
    int index,
    bool isExpanded,
    bool isDark,
    Color textColor,
    Color cardColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header - always visible
          InkWell(
            onTap: () {
              setState(() {
                _expandedIndex = isExpanded ? null : index;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.blue,
                    child: Text(
                      _getAvatarInitial(employee.fullName),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.fullName,
                          style: Style.fontTitleMini.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          employee.roleName ?? 'Chưa xác định',
                          style: Style.fontCaption.copyWith(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              employee.phone,
                              style: Style.fontCaption.copyWith(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(employee.statusId),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      employee.statusName ?? 'Không xác định',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Expand icon
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: textColor,
                  ),
                ],
              ),
            ),
          ),
          
          // Expanded details
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 12),
                  
                  // Detailed info
                  _buildDetailRow(Icons.email_outlined, 'Email', employee.email, isDark),
                  _buildDetailRow(Icons.business_outlined, 'Công ty', employee.companyName ?? 'Chưa có', isDark),
                  _buildDetailRow(Icons.calendar_today, 'Ngày tạo', 
                    _formatDate(employee.createdAt), isDark),
                  _buildDetailRow(Icons.work_outline, 'Vai trò', 
                    employee.roleName ?? 'Chưa có', isDark),
                  
                  const SizedBox(height: 16),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showEditEmployeeDialog(context, employee, isDark, textColor, cardColor),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Chỉnh sửa'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: const BorderSide(color: Colors.blue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showDeleteConfirmDialog(context, employee, isDark, textColor, cardColor),
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Xóa'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
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
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: Style.fontNormal.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Style.fontNormal.copyWith(
                color: isDark ? Style.colorLight : Style.colorDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getAvatarInitial(String fullName) {
    if (fullName.isEmpty) return '?';
    final words = fullName.trim().split(' ');
    if (words.length >= 2) {
      return '${words.first[0]}${words.last[0]}'.toUpperCase();
    }
    return fullName[0].toUpperCase();
  }

  Color _getStatusColor(int? statusId) {
    switch (statusId) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Dialog thêm nhân viên mới
  void _showAddEmployeeDialog(BuildContext context, bool isDark, Color textColor, Color cardColor) {
    // Reset controllers
    _fullNameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _passwordController.clear();
    _selectedStatusId = _userStatuses.isNotEmpty ? _userStatuses.first.id : null;
    _selectedRoleId = _roles.isNotEmpty ? _roles.first.id : null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setStateDialog) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Thêm Nhân Viên Mới',
                            style: Style.fontTitle.copyWith(color: textColor),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: textColor),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Form fields
                      _buildFormField('Họ tên:', _fullNameController, isDark, textColor, cardColor),
                      const SizedBox(height: 16),
                      _buildFormField('Số điện thoại:', _phoneController, isDark, textColor, cardColor,
                        keyboardType: TextInputType.phone),
                      const SizedBox(height: 16),
                      _buildFormField('Email:', _emailController, isDark, textColor, cardColor,
                        keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 16),
                      _buildFormField('Mật khẩu:', _passwordController, isDark, textColor, cardColor,
                        obscureText: true),
                      const SizedBox(height: 16),
                      
                      // Status dropdown
                      _buildDropdown(
                        'Trạng thái:',
                        _selectedStatusId,
                        _userStatuses.map((s) => DropdownMenuItem(
                          value: s.id,
                          child: Text(s.name),
                        )).toList(),
                        (value) => setStateDialog(() => _selectedStatusId = value),
                        isDark,
                        textColor,
                      ),
                      const SizedBox(height: 16),
                      
                      // Role dropdown
                      _buildDropdown(
                        'Vai trò:',
                        _selectedRoleId,
                        _roles.map((r) => DropdownMenuItem(
                          value: r.id,
                          child: Text(r.name),
                        )).toList(),
                        (value) => setStateDialog(() => _selectedRoleId = value),
                        isDark,
                        textColor,
                      ),
                      const SizedBox(height: 24),
                      
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: BorderSide(color: isDark ? Colors.grey[600]! : Colors.grey[400]!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Hủy',
                                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_fullNameController.text.isNotEmpty &&
                                    _phoneController.text.isNotEmpty &&
                                    _emailController.text.isNotEmpty &&
                                    _passwordController.text.isNotEmpty &&
                                    _selectedStatusId != null &&
                                    _selectedRoleId != null) {
                                  
                                  // Call API to add employee
                                  final branchId = _getBranchId();
                                  if (branchId != null) {
                                    try {
                                      final newUser = User(
                                        fullName: _fullNameController.text,
                                        email: _emailController.text,
                                        phone: _phoneController.text,
                                        passworkHash: _passwordController.text, // This will be hashed by backend
                                        statusId: _selectedStatusId,
                                        role: _selectedRoleId,
                                        companyId: 1, // Mock company ID
                                        createdAt: DateTime.now(),
                                        updatedAt: DateTime.now(),
                                        roleName: _roles.firstWhere((r) => r.id == _selectedRoleId).name,
                                        statusName: _userStatuses.firstWhere((s) => s.id == _selectedStatusId).name,
                                        branchIds: [branchId],
                                      );
                                      
                                      await ref.read(employeeManagementProvider(branchId).notifier)
                                        .addEmployee(newUser);
                                      
                                      Navigator.pop(context);
                                      _showSuccessDialog(context, 'Thêm Nhân Viên Thành Công', isDark, cardColor);
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Lỗi khi thêm nhân viên: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Vui lòng điền đầy đủ thông tin bắt buộc'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Thêm',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // Dialog chỉnh sửa nhân viên
  void _showEditEmployeeDialog(BuildContext context, User employee, bool isDark, Color textColor, Color cardColor) {
    // Populate controllers
    _fullNameController.text = employee.fullName;
    _phoneController.text = employee.phone;
    _emailController.text = employee.email;
    _passwordController.clear(); // Don't populate password for security
    _selectedStatusId = employee.statusId;
    _selectedRoleId = employee.role;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setStateDialog) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Chỉnh Sửa Nhân Viên',
                            style: Style.fontTitle.copyWith(color: textColor),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: textColor),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Form fields (same as add dialog)
                      _buildFormField('Họ tên:', _fullNameController, isDark, textColor, cardColor),
                      const SizedBox(height: 16),
                      _buildFormField('Số điện thoại:', _phoneController, isDark, textColor, cardColor,
                        keyboardType: TextInputType.phone),
                      const SizedBox(height: 16),
                      _buildFormField('Email:', _emailController, isDark, textColor, cardColor,
                        keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 16),
                      _buildFormField('Mật khẩu mới (để trống nếu không đổi):', _passwordController, isDark, textColor, cardColor,
                        obscureText: true),
                      const SizedBox(height: 16),
                      
                      _buildDropdown(
                        'Trạng thái:',
                        _selectedStatusId,
                        _userStatuses.map((s) => DropdownMenuItem(
                          value: s.id,
                          child: Text(s.name),
                        )).toList(),
                        (value) => setStateDialog(() => _selectedStatusId = value),
                        isDark,
                        textColor,
                      ),
                      const SizedBox(height: 16),
                      
                      _buildDropdown(
                        'Vai trò:',
                        _selectedRoleId,
                        _roles.map((r) => DropdownMenuItem(
                          value: r.id,
                          child: Text(r.name),
                        )).toList(),
                        (value) => setStateDialog(() => _selectedRoleId = value),
                        isDark,
                        textColor,
                      ),
                      const SizedBox(height: 24),
                      
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _showDeleteConfirmDialog(context, employee, isDark, textColor, cardColor);
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Xóa',
                                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_fullNameController.text.isNotEmpty &&
                                    _phoneController.text.isNotEmpty &&
                                    _emailController.text.isNotEmpty &&
                                    _selectedStatusId != null &&
                                    _selectedRoleId != null) {
                                  
                                  final branchId = _getBranchId();
                                  if (branchId != null && employee.id != null) {
                                    try {
                                      final updatedUser = employee.copyWith(
                                        fullName: _fullNameController.text,
                                        phone: _phoneController.text,
                                        email: _emailController.text,
                                        passworkHash: _passwordController.text.isEmpty ? employee.passworkHash : _passwordController.text,
                                        statusId: _selectedStatusId!,
                                        role: _selectedRoleId!,
                                        updatedAt: DateTime.now(),
                                        roleName: _roles.firstWhere((r) => r.id == _selectedRoleId).name,
                                        statusName: _userStatuses.firstWhere((s) => s.id == _selectedStatusId).name,
                                      );
                                      
                                      await ref.read(employeeManagementProvider(branchId).notifier)
                                        .updateEmployee(employee.id!, updatedUser);
                                      
                                      Navigator.pop(context);
                                      _showSuccessDialog(context, 'Lưu Thay Đổi Thành Công', isDark, cardColor);
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Lỗi khi cập nhật: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Lưu',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper widgets
  Widget _buildDropdown(
    String label,
    int? value,
    List<DropdownMenuItem<int>> items,
    void Function(int?) onChanged,
    bool isDark,
    Color textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Style.fontNormal.copyWith(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: value,
              isExpanded: true,
              dropdownColor: isDark ? Colors.grey[800] : Colors.white,
              style: Style.fontNormal.copyWith(color: textColor),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormField(
    String label, 
    TextEditingController controller, 
    bool isDark, 
    Color textColor, 
    Color cardColor, {
    TextInputType? keyboardType,
    int maxLines = 1,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Style.fontNormal.copyWith(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          obscureText: obscureText,
          style: Style.fontNormal.copyWith(color: textColor),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  // Dialog xác nhận xóa
  void _showDeleteConfirmDialog(BuildContext context, User employee, bool isDark, Color textColor, Color cardColor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Xác nhận xóa',
                  style: Style.fontTitle.copyWith(color: textColor),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bạn có chắc chắn muốn xóa nhân viên ${employee.fullName}?',
                  style: Style.fontNormal.copyWith(
                    color: isDark ? Style.colorLight : Style.colorDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: isDark ? Colors.grey[600]! : Colors.grey[400]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Hủy',
                          style: TextStyle(
                            color: isDark ? Style.colorLight : Style.colorDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final branchId = _getBranchId();
                          if (branchId != null && employee.id != null) {
                            try {
                              await ref.read(employeeManagementProvider(branchId).notifier)
                                .deleteEmployee(employee.id!);
                              
                              Navigator.pop(context);
                              _showSuccessDialog(context, 'Xóa Thành Công', isDark, cardColor);
                            } catch (e) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Lỗi khi xóa: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Xóa',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Dialog thành công
  void _showSuccessDialog(BuildContext context, String message, bool isDark, Color cardColor) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // Auto close after 1.5 seconds
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });
        
        return Dialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  message,
                  style: Style.fontTitle.copyWith(
                    color: isDark ? Style.colorLight : Style.colorDark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}