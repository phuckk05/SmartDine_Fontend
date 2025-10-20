import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mart_dine/features/staff/screen_available_tables.dart';
import 'package:mart_dine/models/table.dart';
import 'package:mart_dine/providers/table_provider.dart';

class ScreenBookTable extends ConsumerStatefulWidget {
  const ScreenBookTable({Key? key}) : super(key: key);

  @override
  ConsumerState<ScreenBookTable> createState() => _ScreenBookTableState();
}

class _ScreenBookTableState extends ConsumerState<ScreenBookTable> {
  // State variables for the form
  final _nameController = TextEditingController(text: 'Nguyễn Văn A');
  final _phoneController = TextEditingController(text: '0912 345 678');
  final _emailController = TextEditingController(); // ✅ Controller cho email
  final _dateController = TextEditingController();
  final _timeController = TextEditingController(text: '19:00');
  final _notesController = TextEditingController(text: 'Ví dụ: Cần ghế em bé');
  final _tableController = TextEditingController();

  int _guestCount = 4;
  DateTime _selectedDate = DateTime.now();
  TableModel? _selectedTable;

  @override
  void initState() {
    super.initState();
    _dateController.text =
        DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(_selectedDate);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose(); // ✅ Dispose controller email
    _dateController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    _tableController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(_selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Đặt bàn mới', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(controller: _nameController, label: 'Tên khách hàng'),
            const SizedBox(height: 16),
            _buildTextField(
                controller: _phoneController,
                label: 'Số điện thoại',
                keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            // ✅ Thêm trường nhập Email
            _buildTextField(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _dateController,
              label: 'Ngày đặt',
              readOnly: true,
              suffixIcon: Icons.calendar_today,
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 16),
            _buildTextField(
                controller: _timeController, label: 'Giờ đến', readOnly: true),
            const SizedBox(height: 16),
            _buildGuestCounter(),
            const SizedBox(height: 16),
            _buildTextField(
                controller: _tableController,
                label: 'Bàn đã chọn',
                readOnly: true),
            const SizedBox(height: 16),
            _buildTextField(
                controller: _notesController, label: 'Ghi chú', maxLines: 3),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton(
              onPressed: () async {
                final selectedTable = await Navigator.of(context).push<TableModel>(
                  MaterialPageRoute(
                    builder: (context) =>
                        ScreenAvailableTables(guestCount: _guestCount),
                  ),
                );

                if (selectedTable != null) {
                  setState(() {
                    _selectedTable = selectedTable;
                    _tableController.text = selectedTable.name;
                  });
                }
              },
              child: const Text('KIỂM TRA BÀN TRỐNG'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                if (_selectedTable != null) {
                  ref
                      .read(tableProvider.notifier)
                      .setCustomerCount(_selectedTable!.id, _guestCount);

                  // ✅ Hiển thị dialog thành công đã thiết kế lại
                  showDialog(
                    context: context,
                    builder: (dialogContext) => Dialog(
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'ĐẶT BÀN THÀNH CÔNG',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8)
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Thông tin chi tiết:',
                                      style: TextStyle(fontWeight: FontWeight.w600)),
                                  const Divider(),
                                  _buildSuccessInfo('Tên khách hàng:', _nameController.text),
                                  _buildSuccessInfo('Số điện thoại:', _phoneController.text),
                                  if (_emailController.text.isNotEmpty)
                                    _buildSuccessInfo('Email:', _emailController.text),
                                  _buildSuccessInfo('Ngày đặt:', _dateController.text),
                                  _buildSuccessInfo('Giờ đến:', _timeController.text),
                                  _buildSuccessInfo('Số lượng khách:', '$_guestCount'),
                                  _buildSuccessInfo('Loại bàn:', 'Thường'),
                                  _buildSuccessInfo('Ghi chú:', _notesController.text),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // TODO: Xử lý logic gửi SMS
                                      },
                                      child: const Text('GỬI SMS'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).then((_) {
                      // Đóng màn hình đặt bàn sau khi dialog đóng
                      Navigator.of(context).pop();
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng chọn bàn trước.')),
                  );
                }
              },
              child: const Text('ĐẶT BÀN'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: const Color(0xFF0D1B4D), // Dark blue color
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper để tạo các trường nhập liệu
  Widget _buildTextField({
    TextEditingController? controller,
    required String label,
    bool readOnly = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    IconData? suffixIcon,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  // Widget cho bộ đếm số khách
  Widget _buildGuestCounter() {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Số lượng khách',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                if (_guestCount > 1) _guestCount--;
              });
            },
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Text('$_guestCount',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          IconButton(
            onPressed: () {
              setState(() {
                _guestCount++;
              });
            },
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }
  
  // ✅ Widget helper cho dialog thành công
  Widget _buildSuccessInfo(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink(); // Ẩn nếu không có giá trị
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110, // Fixed width for labels
            child: Text(label, style: TextStyle(color: Colors.grey[700])),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}