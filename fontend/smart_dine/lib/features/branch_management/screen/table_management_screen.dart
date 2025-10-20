import 'package:flutter/material.dart';
import 'package:mart_dine/core/style.dart';
import '../../../models/table.dart' as model;
import '../../../services/mock_data_service.dart';

class TableManagementScreen extends StatefulWidget {
  final bool showBackButton;
  
  const TableManagementScreen({super.key, this.showBackButton = true});

  @override
  State<TableManagementScreen> createState() => _TableManagementScreenState();
}

class _TableManagementScreenState extends State<TableManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MockDataService _mockDataService = MockDataService();
  
  // Controller cho form thêm/sửa bàn
  final TextEditingController _tableNameController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  // Data
  List<model.Table> _tables = [];
  List<model.TableStatus> _tableStatuses = [];
  List<model.TableType> _tableTypes = [];
  bool _isLoading = true;
  String? _selectedStatusId;
  String? _selectedTypeId;
  
  // Filter
  String _selectedFilter = 'Tất cả';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final tables = await _mockDataService.loadTables();
      final statuses = await _mockDataService.loadTableStatuses();
      final types = await _mockDataService.loadTableTypes();
      
      setState(() {
        _tables = tables;
        _tableStatuses = statuses;
        _tableTypes = types;
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
    _tableNameController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
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
            title: Text('Quản lý bàn ăn', style: Style.fontTitle),
          )
        : AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: Text('Quản lý bàn ăn', style: Style.fontTitle),
          ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildTableListView(isDark, textColor, cardColor),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () => _showAddTableDialog(context, isDark, textColor, cardColor),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Màn hình danh sách bàn ăn
  Widget _buildTableListView(bool isDark, Color textColor, Color cardColor) {
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
              hintText: 'Tìm kiếm bàn',
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
        
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildFilterChip('Tất cả', isDark),
              const SizedBox(width: 8),
              _buildFilterChip('Trống', isDark),
              const SizedBox(width: 8),
              _buildFilterChip('Đang sử dụng', isDark),
              const SizedBox(width: 8),
              _buildFilterChip('Khu VIP', isDark),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Table list
        Expanded(
          child: Builder(
            builder: (context) {
              // Filter logic
              List<model.Table> filteredTables = _tables.where((table) {
                // Search filter
                final searchQuery = _searchController.text.toLowerCase();
                final matchesSearch = searchQuery.isEmpty ||
                    table.name.toLowerCase().contains(searchQuery) ||
                    table.description?.toLowerCase().contains(searchQuery) == true ||
                    table.capacity.toString().contains(searchQuery);
                
                if (!matchesSearch) return false;
                
                // Category filter
                switch (_selectedFilter) {
                  case 'Tất cả':
                    return true;
                  case 'Trống':
                    return table.isAvailable();
                  case 'Đang sử dụng':
                    return table.isOccupied();
                  case 'Khu VIP':
                    return table.type?.code == 'VIP';
                  default:
                    return true;
                }
              }).toList();
              
              // Show empty state if no results
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
                      const SizedBox(height: 8),
                      Text(
                        'Thử thay đổi bộ lọc hoặc tìm kiếm khác',
                        style: Style.fontCaption.copyWith(
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredTables.length,
                itemBuilder: (context, index) {
                  final table = filteredTables[index];
                  return _buildTableCard(table, isDark, textColor, cardColor);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isDark) {
    final isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _selectedFilter = label;
        });
      },
      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
      selectedColor: Colors.blue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[700]),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildTableCard(model.Table table, bool isDark, Color textColor, Color cardColor) {
    Color statusColor;
    if (table.isAvailable()) {
      statusColor = Colors.green;
    } else if (table.isOccupied()) {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.red;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên bàn
                Text(
                  table.name,
                  style: Style.fontTitleMini.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Trạng thái
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    table.status?.name ?? 'Không xác định',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Thông tin chi tiết
                Row(
                  children: [
                    // Sức chứa
                    Icon(Icons.people_outline, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${table.capacity} người',
                      style: Style.fontCaption.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Loại bàn
                    Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      table.type?.name ?? 'Bình thường',
                      style: Style.fontCaption.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                
                // Mô tả (nếu có)
                if (table.description != null && table.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    table.description!,
                    style: Style.fontCaption.copyWith(
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: textColor),
            onPressed: () => _showEditTableDialog(context, table, isDark, textColor, cardColor),
          ),
        ],
      ),
    );
  }

  // Dialog thêm bàn mới
  void _showAddTableDialog(BuildContext context, bool isDark, Color textColor, Color cardColor) {
    // Reset controllers
    _tableNameController.clear();
    _capacityController.clear();
    _descriptionController.clear();
    _selectedStatusId = _tableStatuses.isNotEmpty ? _tableStatuses.first.id : null;
    _selectedTypeId = _tableTypes.isNotEmpty ? _tableTypes.first.id : null;

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
                            'Thêm Bàn Mới',
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
                      _buildFormField('Tên bàn:', _tableNameController, isDark, textColor, cardColor),
                      const SizedBox(height: 16),
                      _buildFormField('Sức chứa:', _capacityController, isDark, textColor, cardColor, 
                        keyboardType: TextInputType.number),
                      const SizedBox(height: 16),
                      _buildFormField('Mô tả:', _descriptionController, isDark, textColor, cardColor, 
                        maxLines: 2),
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
                      const SizedBox(height: 16),
                      
                      // Type dropdown
                      _buildDropdown(
                        'Loại bàn:',
                        _selectedTypeId,
                        _tableTypes.map((t) => DropdownMenuItem(
                          value: t.id,
                          child: Text(t.name),
                        )).toList(),
                        (value) => setStateDialog(() => _selectedTypeId = value),
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
                                if (_tableNameController.text.isNotEmpty &&
                                    _capacityController.text.isNotEmpty &&
                                    _selectedStatusId != null &&
                                    _selectedTypeId != null) {
                                  
                                  final newTable = model.Table(
                                    id: 'table-${DateTime.now().millisecondsSinceEpoch}',
                                    branchId: 'branch-001', // Mock branch ID
                                    name: _tableNameController.text,
                                    typeId: _selectedTypeId!,
                                    description: _descriptionController.text.isEmpty 
                                        ? null 
                                        : _descriptionController.text,
                                    capacity: int.parse(_capacityController.text),
                                    statusId: _selectedStatusId!,
                                    createdAt: DateTime.now(),
                                    updatedAt: DateTime.now(),
                                  );
                                  
                                  // Set relations
                                  newTable.status = _tableStatuses.firstWhere((s) => s.id == _selectedStatusId);
                                  newTable.type = _tableTypes.firstWhere((t) => t.id == _selectedTypeId);
                                  
                                  setState(() {
                                    _tables.add(newTable);
                                  });
                                  
                                  Navigator.pop(context);
                                  _showSuccessDialog(context, 'Thêm Bàn Thành Công', isDark, cardColor);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Vui lòng điền đầy đủ thông tin'),
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

  // Dialog chỉnh sửa bàn
  void _showEditTableDialog(BuildContext context, model.Table table, bool isDark, Color textColor, Color cardColor) {
    // Populate controllers with table data
    _tableNameController.text = table.name;
    _capacityController.text = table.capacity.toString();
    _descriptionController.text = table.description ?? '';
    _selectedStatusId = table.statusId;
    _selectedTypeId = table.typeId;

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
                      _buildFormField('Tên bàn:', _tableNameController, isDark, textColor, cardColor),
                      const SizedBox(height: 16),
                      _buildFormField('Sức chứa:', _capacityController, isDark, textColor, cardColor, 
                        keyboardType: TextInputType.number),
                      const SizedBox(height: 16),
                      _buildFormField('Mô tả:', _descriptionController, isDark, textColor, cardColor, 
                        maxLines: 2),
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
                      const SizedBox(height: 16),
                      
                      // Type dropdown
                      _buildDropdown(
                        'Loại bàn:',
                        _selectedTypeId,
                        _tableTypes.map((t) => DropdownMenuItem(
                          value: t.id,
                          child: Text(t.name),
                        )).toList(),
                        (value) => setStateDialog(() => _selectedTypeId = value),
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
                              onPressed: () {
                                if (_tableNameController.text.isNotEmpty &&
                                    _capacityController.text.isNotEmpty &&
                                    _selectedStatusId != null &&
                                    _selectedTypeId != null) {
                                  
                                  setState(() {
                                    // Update table
                                    final index = _tables.indexWhere((t) => t.id == table.id);
                                    if (index != -1) {
                                      _tables[index] = model.Table(
                                        id: table.id,
                                        branchId: table.branchId,
                                        name: _tableNameController.text,
                                        typeId: _selectedTypeId!,
                                        description: _descriptionController.text.isEmpty 
                                            ? null 
                                            : _descriptionController.text,
                                        capacity: int.parse(_capacityController.text),
                                        statusId: _selectedStatusId!,
                                        createdAt: table.createdAt,
                                        updatedAt: DateTime.now(),
                                      );
                                      
                                      // Set relations
                                      _tables[index].status = _tableStatuses.firstWhere((s) => s.id == _selectedStatusId);
                                      _tables[index].type = _tableTypes.firstWhere((t) => t.id == _selectedTypeId);
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

  // Dialog xác nhận xóa
  void _showDeleteConfirmDialog(BuildContext context, model.Table table, bool isDark, Color textColor, Color cardColor) {
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
                  'Bạn có chắc chắn muốn xóa ${table.name}?',
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
                        onPressed: () {
                          Navigator.pop(context);
                        },
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
                            _tables.removeWhere((t) => t.id == table.id);
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
