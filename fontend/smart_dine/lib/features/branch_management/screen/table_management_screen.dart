import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/core/style.dart';
import '../../../models/table.dart' as table_model;
import '../../../providers/table_management_provider.dart';
import '../../../providers/user_session_provider.dart';

// ignore_for_file: use_build_context_synchronously

// Status class for table statuses
class TableStatus {
  final int id;
  final String name;
  final String code;

  TableStatus({
    required this.id,
    required this.name,
    required this.code,
  });
}



class TableManagementScreen extends ConsumerStatefulWidget {
  final bool showBackButton;
  
  const TableManagementScreen({super.key, this.showBackButton = true});

  @override
  ConsumerState<TableManagementScreen> createState() => _TableManagementScreenState();
}

class _TableManagementScreenState extends ConsumerState<TableManagementScreen> {
  // Hàm load lại dữ liệu bàn (invalidate provider)
  Future<void> _loadTables() async {
    final branchId = ref.read(currentBranchIdProvider);
    if (branchId != null) {
      ref.invalidate(tableManagementProvider(branchId));
    }
  }

  // Hàm refresh (gọi lại loadTables)
  Future<void> _refreshTables() async {
    await _loadTables();
  }
  final TextEditingController _searchController = TextEditingController();
  
  // Track which table card is expanded
  int? _expandedIndex;
  
  // Controllers cho form thêm/sửa bàn
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Controller cho form thêm loại bàn
  final TextEditingController _tableTypeNameController = TextEditingController();
  final TextEditingController _tableTypeCodeController = TextEditingController();
  
  // Data
  final List<TableStatus> _tableStatuses = [
    TableStatus(id: 1, name: 'Trống', code: 'EMPTY'),
    TableStatus(id: 2, name: 'Đang sử dụng', code: 'OCCUPIED'),
    TableStatus(id: 3, name: 'Đã đặt', code: 'RESERVED'),
    TableStatus(id: 4, name: 'Bảo trì', code: 'MAINTENANCE'),
  ];
  
  int? _selectedStatusId;
  int? _selectedTypeId;

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _tableTypeNameController.dispose();
    _tableTypeCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lấy branchId từ user session
    final currentBranchId = ref.watch(currentBranchIdProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    
    // Yêu cầu user phải đăng nhập
    if (!isAuthenticated || currentBranchId == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[850] : Style.backgroundColor,
        appBar: widget.showBackButton
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text('Quản lý bàn', style: Style.fontTitle),
            )
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              automaticallyImplyLeading: false,
              title: Text('Quản lý bàn', style: Style.fontTitle),
            ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.login, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Vui lòng đăng nhập để tiếp tục'),
            ],
          ),
        ),
      );
    }

    final branchId = currentBranchId;
    final currentCompanyId = ref.watch(currentCompanyIdProvider);

    final tablesAsyncValue = ref.watch(tableManagementProvider(branchId));
    final tableTypesAsyncValue = ref.watch(tableTypesProvider(currentCompanyId ?? 1));
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
            title: Text('Quản lý bàn', style: Style.fontTitle),
          )
        : AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: Text('Quản lý bàn', style: Style.fontTitle),
          ),
      body: tablesAsyncValue.when(
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
                  ref.invalidate(tableManagementProvider(branchId));
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        data: (tables) => tableTypesAsyncValue.when(
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
                  'Lỗi khi tải loại bàn',
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
                    ref.invalidate(tableTypesProvider(currentCompanyId ?? 1));
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
          data: (tableTypes) => _buildTableManagementContent(tables, tableTypes, isDark, textColor, cardColor),
        ),
      ),
    );
  }

  // Widget chính cho quản lý bàn
  Widget _buildTableManagementContent(List<table_model.Table> tables, List<table_model.TableType> tableTypes, bool isDark, Color textColor, Color cardColor) {
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[850] : Style.backgroundColor,
      appBar: widget.showBackButton
        ? AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text('Quản lý bàn', style: Style.fontTitle),
          )
        : AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: Text('Quản lý bàn', style: Style.fontTitle),
          ),
      body: _buildTableListView(tables, tableTypes, isDark, textColor, cardColor),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () => _showAddTableDialog(context, tableTypes, isDark, textColor, cardColor),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Màn hình danh sách bàn
  Widget _buildTableListView(List<table_model.Table> tables, List<table_model.TableType> tableTypes, bool isDark, Color textColor, Color cardColor) {
    // Map typeId/statusId sang tên
    final mappedTables = tables.map((table) {
      final type = tableTypes.firstWhere(
        (t) => t.id == table.typeId,
        orElse: () => table_model.TableType(id: 0, name: 'Chưa có', code: ''),
      );
      final status = _tableStatuses.firstWhere(
        (s) => s.id == table.statusId,
        orElse: () => TableStatus(id: 0, name: 'Chưa có', code: ''),
      );
      return table.copyWith(
        typeName: type.name,
        statusName: status.name,
      );
    }).toList();
    return RefreshIndicator(
      onRefresh: _refreshTables,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // Search bar and summary
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Summary cards
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Tổng số bàn',
                        tables.length.toString(),
                        Icons.table_restaurant,
                        Colors.blue,
                        isDark,
                        cardColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        'Bàn hoạt động',
                        tables.where((t) => t.statusId == 1).length.toString(),
                        Icons.check_circle,
                        Colors.green,
                        isDark,
                        cardColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        'Bàn bảo trì',
                        tables.where((t) => t.statusId == 2).length.toString(),
                        Icons.build,
                        Colors.orange,
                        isDark,
                        cardColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {}); // Rebuild để apply search filter
                  },
                  style: Style.fontNormal.copyWith(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm bàn theo tên',
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
              ],
            ),
          ),
          // Table list
          Builder(
            builder: (context) {
              // Filter by search query
              List<table_model.Table> filteredTables = mappedTables.where((table) {
                final searchQuery = _searchController.text.toLowerCase();
                return searchQuery.isEmpty ||
                    table.name.toLowerCase().contains(searchQuery) ||
                    (table.description?.toLowerCase().contains(searchQuery) ?? false) ||
                    (table.typeName?.toLowerCase().contains(searchQuery) ?? false);
              }).toList();
              if (filteredTables.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.table_restaurant_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Không tìm thấy bàn nào',
                        style: Style.fontTitleMini.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredTables.length,
                itemBuilder: (context, index) {
                  final table = filteredTables[index];
                  final isExpanded = _expandedIndex == index;
                  return _buildTableCard(
                    table,
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
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, bool isDark, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: Style.fontTitle.copyWith(
              color: isDark ? Style.colorLight : Style.colorDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Style.fontCaption.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTableCard(
    table_model.Table table,
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
            color: Colors.black.withValues(alpha: 0.05),
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
                  // Table icon with type color
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _getTypeColor(table.typeId),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.table_restaurant,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          table.name,
                          style: Style.fontTitleMini.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          table.typeName ?? 'Loại bàn chưa xác định',
                          style: Style.fontCaption.copyWith(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (table.description?.isNotEmpty == true)
                          Text(
                            table.description!,
                            style: Style.fontCaption.copyWith(
                              color: isDark ? Colors.grey[500] : Colors.grey[500],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(table.statusId),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      table.statusName ?? 'Không xác định',
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
                  _buildDetailRow(Icons.business_outlined, 'Chi nhánh', table.branchName ?? 'Chưa có', isDark),
                  _buildDetailRow(Icons.category_outlined, 'Loại bàn', table.typeName ?? 'Chưa có', isDark),
                  _buildDetailRow(Icons.info_outline, 'Trạng thái', table.statusName ?? 'Chưa có', isDark),
                  if (table.description?.isNotEmpty == true)
                    _buildDetailRow(Icons.description_outlined, 'Mô tả', table.description!, isDark),
                  _buildDetailRow(Icons.calendar_today, 'Ngày tạo', 
                    _formatDate(table.createdAt), isDark),
                  _buildDetailRow(Icons.update, 'Cập nhật lần cuối', 
                    _formatDate(table.updatedAt), isDark),
                  if (table.orderCount > 0)
                    _buildDetailRow(Icons.receipt_long, 'Số order hiện tại', 
                      table.orderCount.toString(), isDark),
                  
                  const SizedBox(height: 16),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showEditTableDialog(context, table, isDark, textColor, cardColor),
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
                          onPressed: () => _showDeleteConfirmDialog(context, table, isDark, textColor, cardColor),
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

  Color _getStatusColor(int? statusId) {
    switch (statusId) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      case 4:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Color _getTypeColor(int? typeId) {
    switch (typeId) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.purple;
      case 3:
        return Colors.indigo;
      case 4:
        return Colors.amber;
      case 5:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  // Dialog thêm bàn mới
  void _showAddTableDialog(BuildContext context, List<table_model.TableType> tableTypes, bool isDark, Color textColor, Color cardColor) {
    // Reset controllers
    _nameController.clear();
    _descriptionController.clear();
    _selectedStatusId = _tableStatuses.isNotEmpty ? _tableStatuses.first.id : null;
    _selectedTypeId = tableTypes.isNotEmpty ? tableTypes.first.id : null;

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
                          Text('Thêm Bàn Mới', style: Style.fontTitle.copyWith(color: textColor)),
                          IconButton(
                            icon: Icon(Icons.close, color: textColor),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Form fields
                      _buildFormField('Tên bàn:', _nameController, isDark, textColor, cardColor),
                      const SizedBox(height: 16),
                      _buildFormField('Mô tả:', _descriptionController, isDark, textColor, cardColor, maxLines: 3),
                      const SizedBox(height: 16),
                      // Type dropdown + nút thêm loại bàn
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              'Loại bàn:',
                              _selectedTypeId,
                              tableTypes.isNotEmpty
                                  ? tableTypes.map((t) => DropdownMenuItem(
                                      value: t.id,
                                      child: Text(t.name),
                                    )).toList()
                                  : [
                                      const DropdownMenuItem(
                                        value: null,
                                        child: Text('Chưa có loại bàn, hãy tạo mới'),
                                      ),
                                    ],
                              (value) => setStateDialog(() => _selectedTypeId = value),
                              isDark,
                              textColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.add_circle, color: Colors.blue),
                            tooltip: 'Thêm loại bàn mới',
                            onPressed: () {
                              _showAddTableTypeDialog(context, isDark, textColor, cardColor, setStateDialog);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Status dropdown
                      _buildDropdown(
                        'Trạng thái:',
                        _selectedStatusId,
                        _tableStatuses.map((s) => DropdownMenuItem(
                          value: s.id,
                          child: Text(s.name),
                        )).toList(),
                        (value) => setStateDialog(() => _selectedStatusId = value),
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
                              child: Text('Hủy', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final localContext = context;
                                if (_nameController.text.isNotEmpty && _selectedStatusId != null && _selectedTypeId != null) {
                                  final branchId = ref.read(currentBranchIdProvider);
                                  if (branchId != null) {
                                    try {
                                      final newTable = table_model.Table(
                                        branchId: branchId,
                                        name: _nameController.text,
                                        typeId: _selectedTypeId,
                                        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
                                        statusId: _selectedStatusId,
                                        createdAt: DateTime.now(),
                                        updatedAt: DateTime.now(),
                                        typeName: tableTypes.firstWhere((t) => t.id == _selectedTypeId).name,
                                        statusName: _tableStatuses.firstWhere((s) => s.id == _selectedStatusId).name,
                                      );
                                      await ref.read(tableManagementProvider(branchId).notifier).createTable(newTable);
                                      Navigator.pop(localContext);
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        _showSuccessDialog(localContext, 'Thêm Bàn Thành Công', isDark, cardColor);
                                      });
                                    } catch (e) {
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        ScaffoldMessenger.of(localContext).showSnackBar(
                                          SnackBar(content: Text('Lỗi khi thêm bàn: $e'), backgroundColor: Colors.red),
                                        );
                                      });
                                    }
                                  }
                                } else {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    ScaffoldMessenger.of(localContext).showSnackBar(
                                      const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin bắt buộc'), backgroundColor: Colors.red),
                                    );
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Lưu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  // Dialog chỉnh sửa bàn
  void _showEditTableDialog(BuildContext context, table_model.Table table, bool isDark, Color textColor, Color cardColor) {
    // Populate controllers
    _nameController.text = table.name;
    _descriptionController.text = table.description ?? '';
    _selectedStatusId = table.statusId;
    _selectedTypeId = table.typeId;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Consumer(
          builder: (context, ref, child) {
            final branchId = ref.watch(currentBranchIdProvider);
            final tableTypesAsyncValue = ref.watch(tableTypesProvider(branchId!));
            
            return Dialog(
              backgroundColor: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: tableTypesAsyncValue.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text('Lỗi tải loại bàn: $error'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Đóng'),
                          ),
                        ],
                      ),
                    ),
                    data: (tableTypes) => StatefulBuilder(
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
                                  'Chỉnh Sửa Bàn',
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
                            _buildFormField('Tên bàn:', _nameController, isDark, textColor, cardColor),
                            const SizedBox(height: 16),
                            _buildFormField('Mô tả:', _descriptionController, isDark, textColor, cardColor, maxLines: 3),
                            const SizedBox(height: 16),
                            
                            _buildDropdown(
                              'Loại bàn:',
                              _selectedTypeId,
                              tableTypes.map((t) => DropdownMenuItem(
                                value: t.id,
                                child: Text(t.name),
                              )).toList(),
                              (value) => setStateDialog(() => _selectedTypeId = value),
                              isDark,
                              textColor,
                            ),
                            const SizedBox(height: 16),
                            
                            _buildDropdown(
                              'Trạng thái:',
                              _selectedStatusId,
                              _tableStatuses.map((s) => DropdownMenuItem(
                                value: s.id,
                                child: Text(s.name),
                              )).toList(),
                              (value) => setStateDialog(() => _selectedStatusId = value),
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
                                      _showDeleteConfirmDialog(context, table, isDark, textColor, cardColor);
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
                                      final localContext = context;
                                      if (_nameController.text.isNotEmpty &&
                                          _selectedStatusId != null &&
                                          _selectedTypeId != null) {
                                        
                                        final branchId = ref.read(currentBranchIdProvider);
                                        if (branchId != null && table.id != null) {
                                          try {
                                            final updatedTable = table.copyWith(
                                              name: _nameController.text,
                                              description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
                                              typeId: _selectedTypeId!,
                                              statusId: _selectedStatusId!,
                                              updatedAt: DateTime.now(),
                                              typeName: tableTypes.firstWhere((t) => t.id == _selectedTypeId).name,
                                              statusName: _tableStatuses.firstWhere((s) => s.id == _selectedStatusId).name,
                                            );
                                            
                                            await ref.read(tableManagementProvider(branchId).notifier)
                                              .updateTable(table.id!, updatedTable);
                                            
                                            Navigator.pop(localContext);
                                            WidgetsBinding.instance.addPostFrameCallback((_) {
                                              _showSuccessDialog(localContext, 'Lưu Thay Đổi Thành Công', isDark, cardColor);
                                            });
                                          } catch (e) {
                                            WidgetsBinding.instance.addPostFrameCallback((_) {
                                              ScaffoldMessenger.of(localContext).showSnackBar(
                                                SnackBar(
                                                  content: Text('Lỗi khi cập nhật: $e'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            });
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
              ),
            );
          },
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
  void _showDeleteConfirmDialog(BuildContext context, table_model.Table table, bool isDark, Color textColor, Color cardColor) {
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
                  'Bạn có chắc chắn muốn xóa bàn ${table.name}?',
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
                          final localContext = context;
                          final branchId = ref.read(currentBranchIdProvider);
                          if (branchId != null && table.id != null) {
                            try {
                              await ref.read(tableManagementProvider(branchId).notifier)
                                .deleteTable(table.id!);
                              
                              Navigator.pop(localContext);
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _showSuccessDialog(localContext, 'Xóa Thành Công', isDark, cardColor);
                              });
                            } catch (e) {
                              Navigator.pop(localContext);
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                ScaffoldMessenger.of(localContext).showSnackBar(
                                  SnackBar(
                                    content: Text('Lỗi khi xóa: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              });
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
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        // Auto close after 2 seconds - sử dụng Timer
        Timer? timer;
        timer = Timer(const Duration(milliseconds: 2000), () {
          if (dialogContext.mounted && Navigator.of(dialogContext).canPop()) {
            Navigator.of(dialogContext).pop();
          }
          timer?.cancel();
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
                const SizedBox(height: 24),
                // Thêm button đóng
                ElevatedButton(
                  onPressed: () {
                    timer?.cancel();
                    Navigator.of(dialogContext).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Đóng',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Dialog thêm loại bàn mới
  void _showAddTableTypeDialog(BuildContext context, bool isDark, Color textColor, Color cardColor, StateSetter setStateDialog) {
    _tableTypeNameController.clear();
    _tableTypeCodeController.clear();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateDialogInner) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Thêm loại bàn mới', style: Style.fontTitle.copyWith(color: textColor)),
                    const SizedBox(height: 16),
                    _buildFormField('Tên loại bàn', _tableTypeNameController, isDark, textColor, cardColor),
                    const SizedBox(height: 16),
                    _buildFormField('Mã loại bàn', _tableTypeCodeController, isDark, textColor, cardColor),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: isDark ? Colors.grey[600]! : Colors.grey[400]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('Hủy', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final localContext = context;
                              if (_tableTypeNameController.text.isNotEmpty && _tableTypeCodeController.text.isNotEmpty) {
                                final currentCompanyId = ref.read(currentCompanyIdProvider);
                                if (currentCompanyId != null) {
                                  try {
                                    await ref.read(tableTypesProvider(currentCompanyId).notifier).createTableType(
                                      _tableTypeNameController.text, 
                                      _tableTypeCodeController.text
                                    );
                                    
                                    // Refresh the dropdown
                                    setStateDialog(() {});
                                    
                                    Navigator.pop(dialogContext);
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      ScaffoldMessenger.of(localContext).showSnackBar(
                                        const SnackBar(content: Text('Thêm loại bàn thành công'), backgroundColor: Colors.green),
                                      );
                                    });
                                  } catch (e) {
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      ScaffoldMessenger.of(localContext).showSnackBar(
                                        SnackBar(content: Text('Lỗi khi thêm loại bàn: $e'), backgroundColor: Colors.red),
                                      );
                                    });
                                  }
                                }
                              } else {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  ScaffoldMessenger.of(localContext).showSnackBar(
                                    const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin'), backgroundColor: Colors.red),
                                  );
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Lưu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}