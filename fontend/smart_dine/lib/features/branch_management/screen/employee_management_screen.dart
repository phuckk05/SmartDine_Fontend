import 'package:flutter/material.dart';
import 'package:mart_dine/core/style.dart';
import '../../../models/employee.dart';
import '../../../models/role.dart';
import '../../../services/mock_data_service.dart';

class EmployeeManagementScreen extends StatefulWidget {
  final bool showBackButton;
  
  const EmployeeManagementScreen({super.key, this.showBackButton = true});

  @override
  State<EmployeeManagementScreen> createState() => _EmployeeManagementScreenState();
}

class _EmployeeManagementScreenState extends State<EmployeeManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MockDataService _mockDataService = MockDataService();
  
  // Track which employee card is expanded
  int? _expandedIndex;
  
  // Controllers cho form thêm/sửa nhân viên
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cccdController = TextEditingController();
  
  // Data
  List<Employee> _employees = [];
  List<UserStatus> _userStatuses = [];
  List<Role> _roles = [];
  bool _isLoading = true;
  String? _selectedStatusId;
  String? _selectedRoleId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final employees = await _mockDataService.loadEmployees();
      final statuses = await _mockDataService.loadUserStatuses();
      final roles = await _mockDataService.loadRoles();
      
      setState(() {
        _employees = employees;
        _userStatuses = statuses;
        _roles = roles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cccdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildEmployeeListView(isDark, textColor, cardColor),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () => _showAddEmployeeDialog(context, isDark, textColor, cardColor),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Màn hình danh sách nhân viên
  Widget _buildEmployeeListView(bool isDark, Color textColor, Color cardColor) {
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
        Expanded(
          child: Builder(
            builder: (context) {
              // Filter by search query
              List<Employee> filteredEmployees = _employees.where((employee) {
                final searchQuery = _searchController.text.toLowerCase();
                return searchQuery.isEmpty ||
                    employee.fullName.toLowerCase().contains(searchQuery) ||
                    employee.phone.toLowerCase().contains(searchQuery) ||
                    employee.email.toLowerCase().contains(searchQuery) ||
                    employee.getPrimaryRole().toLowerCase().contains(searchQuery);
              }).toList();
              
              if (filteredEmployees.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Không tìm thấy nhân viên nào',
                        style: Style.fontTitleMini.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredEmployees.length,
                itemBuilder: (context, index) {
                  final employee = filteredEmployees[index];
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
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeCard(
    Employee employee,
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
                      employee.getAvatarInitial(),
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
                          employee.getPrimaryRole(),
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
                      color: employee.isActive() 
                          ? Colors.green 
                          : employee.isInactive() 
                              ? Colors.orange 
                              : Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      employee.status?.name ?? 'Không xác định',
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
                  if (employee.cccd != null)
                    _buildDetailRow(Icons.badge_outlined, 'CCCD', employee.cccd!, isDark),
                  _buildDetailRow(Icons.calendar_today, 'Ngày tạo', 
                    _formatDate(employee.createdAt), isDark),
                  if (employee.roles != null && employee.roles!.isNotEmpty)
                    _buildDetailRow(Icons.work_outline, 'Các vai trò', 
                      employee.roles!.map((r) => r.name).join(', '), isDark),
                  
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

  // Dialog thêm nhân viên mới
  void _showAddEmployeeDialog(BuildContext context, bool isDark, Color textColor, Color cardColor) {
    // Reset controllers
    _fullNameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _cccdController.clear();
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
                      _buildFormField('CCCD:', _cccdController, isDark, textColor, cardColor),
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
                              onPressed: () {
                                if (_fullNameController.text.isNotEmpty &&
                                    _phoneController.text.isNotEmpty &&
                                    _emailController.text.isNotEmpty &&
                                    _selectedStatusId != null &&
                                    _selectedRoleId != null) {
                                  
                                  final newEmployee = Employee(
                                    id: 'employee-${DateTime.now().millisecondsSinceEpoch}',
                                    fullName: _fullNameController.text,
                                    phone: _phoneController.text,
                                    email: _emailController.text,
                                    passwordHash: '\$2a\$10\$example', // Default hash
                                    statusId: _selectedStatusId!,
                                    cccd: _cccdController.text.isEmpty ? null : _cccdController.text,
                                    createdAt: DateTime.now(),
                                    updatedAt: DateTime.now(),
                                    roleIds: [_selectedRoleId!],
                                    branchIds: ['branch-001'], // Mock branch
                                    companyIds: ['company-001'], // Mock company
                                  );
                                  
                                  // Set relations
                                  newEmployee.status = _userStatuses.firstWhere((s) => s.id == _selectedStatusId);
                                  newEmployee.roles = [_roles.firstWhere((r) => r.id == _selectedRoleId)];
                                  
                                  setState(() {
                                    _employees.add(newEmployee);
                                  });
                                  
                                  Navigator.pop(context);
                                  _showSuccessDialog(context, 'Thêm Nhân Viên Thành Công', isDark, cardColor);
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
  void _showEditEmployeeDialog(BuildContext context, Employee employee, bool isDark, Color textColor, Color cardColor) {
    // Populate controllers
    _fullNameController.text = employee.fullName;
    _phoneController.text = employee.phone;
    _emailController.text = employee.email;
    _cccdController.text = employee.cccd ?? '';
    _selectedStatusId = employee.statusId;
    _selectedRoleId = employee.roleIds?.first;

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
                      _buildFormField('CCCD:', _cccdController, isDark, textColor, cardColor),
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
                              onPressed: () {
                                if (_fullNameController.text.isNotEmpty &&
                                    _phoneController.text.isNotEmpty &&
                                    _emailController.text.isNotEmpty &&
                                    _selectedStatusId != null &&
                                    _selectedRoleId != null) {
                                  
                                  setState(() {
                                    final index = _employees.indexWhere((e) => e.id == employee.id);
                                    if (index != -1) {
                                      _employees[index] = Employee(
                                        id: employee.id,
                                        fullName: _fullNameController.text,
                                        phone: _phoneController.text,
                                        email: _emailController.text,
                                        passwordHash: employee.passwordHash,
                                        statusId: _selectedStatusId!,
                                        cccd: _cccdController.text.isEmpty ? null : _cccdController.text,
                                        createdAt: employee.createdAt,
                                        updatedAt: DateTime.now(),
                                        roleIds: [_selectedRoleId!],
                                        branchIds: employee.branchIds,
                                        companyIds: employee.companyIds,
                                      );
                                      
                                      // Set relations
                                      _employees[index].status = _userStatuses.firstWhere((s) => s.id == _selectedStatusId);
                                      _employees[index].roles = [_roles.firstWhere((r) => r.id == _selectedRoleId)];
                                    }
                                  });
                                  
                                  Navigator.pop(context);
                                  _showSuccessDialog(context, 'Lưu Thay Đổi Thành Công', isDark, cardColor);
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
    String? value,
    List<DropdownMenuItem<String>> items,
    void Function(String?) onChanged,
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
            child: DropdownButton<String>(
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
  void _showDeleteConfirmDialog(BuildContext context, Employee employee, bool isDark, Color textColor, Color cardColor) {
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
                        onPressed: () {
                          setState(() {
                            _employees.removeWhere((e) => e.id == employee.id);
                          });
                          Navigator.pop(context);
                          _showSuccessDialog(context, 'Xóa Thành Công', isDark, cardColor);
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