import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Thêm package intl để định dạng ngày, giờ
import '../Data/providers_choose_table.dart'; // Giữ nguyên import này

class ScreenBooking extends ConsumerStatefulWidget {
  const ScreenBooking({super.key});

  @override
  ConsumerState<ScreenBooking> createState() => _ScreenBookingState();
}

class _ScreenBookingState extends ConsumerState<ScreenBooking> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedTableType;
  int _guestCount = 2;
  bool _success = false;
  Map<String, dynamic>? _selectedTable;

  @override
  void initState() {
    super.initState();
    // Khởi tạo giá trị mặc định cho Ngày và Giờ
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    _selectedTableType = 'Thường';
  }

  void _findTable() {
    final tables = ref.read(tablesProvider);
    final available = tables
        .where((t) =>
            t['status'] == 'Trống' &&
            t['capacity'] >= _guestCount &&
            t['type'] == _selectedTableType)
        .toList();

    if (available.isNotEmpty) {
      available.sort((a, b) => a['capacity'].compareTo(b['capacity']));
      setState(() => _selectedTable = available.first);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã chọn bàn ${_selectedTable!['name']}')),
      );
    } else {
      setState(() => _selectedTable = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có bàn trống đủ chỗ!')),
      );
    }
  }

  void _bookTable() {
    if (_formKey.currentState!.validate()) {
      if (_selectedTable == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng kiểm tra bàn trống trước!')),
        );
        return;
      }

      // lưu booking vào bookingsProvider
      ref.read(bookingsProvider.notifier).setBooking(_selectedTable!['name'], {
        'name': _nameCtrl.text,
        'phone': _phoneCtrl.text,
        'date': _selectedDate.toString(),
        'time': _selectedTime!.format(context),
        'note': _noteCtrl.text,
        'guestCount': _guestCount,
        'tableType': _selectedTableType,
      });

      // đặt trạng thái bàn -> 'Đã đặt'
      ref.read(tablesProvider.notifier).bookTable(_selectedTable!['name']);

      setState(() => _success = true);
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt bàn mới'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _success ? _buildSuccess() : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    final String formattedDate = _selectedDate != null
        ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
        : '';
    final String formattedTime =
        _selectedTime?.format(context) ?? '';

    return Form(
      key: _formKey,
      child: ListView(
        children: [
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Tên khách hàng'),
            validator: (value) => value!.isEmpty ? 'Vui lòng nhập tên' : null,
          ),
          TextFormField(
            controller: _phoneCtrl,
            decoration: const InputDecoration(labelText: 'Số điện thoại'),
            keyboardType: TextInputType.phone,
            validator: (value) => value!.isEmpty ? 'Vui lòng nhập SĐT' : null,
          ),
          TextFormField(
            readOnly: true,
            onTap: _pickDate,
            controller: TextEditingController(text: formattedDate),
            decoration: const InputDecoration(
                labelText: 'Ngày đặt', suffixIcon: Icon(Icons.calendar_today)),
          ),
          TextFormField(
            readOnly: true,
            onTap: _pickTime,
            controller: TextEditingController(text: formattedTime),
            decoration: const InputDecoration(
                labelText: 'Giờ đặt', suffixIcon: Icon(Icons.access_time)),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Số lượng khách:'),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (_guestCount > 1) setState(() => _guestCount--);
                    },
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('$_guestCount'),
                  IconButton(
                    onPressed: () => setState(() => _guestCount++),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ],
          ),
          DropdownButtonFormField<String>(
            value: _selectedTableType,
            decoration: const InputDecoration(labelText: 'Loại bàn'),
            items: <String>['Thường', 'VIP']
                .map((String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ))
                .toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedTableType = newValue;
              });
            },
          ),
          TextFormField(
            controller: _noteCtrl,
            decoration: const InputDecoration(labelText: 'Ghi chú'),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            icon: const Icon(Icons.search),
            label: const Text('KIỂM TRA BÀN TRỐNG'),
            onPressed: _findTable,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _bookTable,
            child: const Text('ĐẶT BÀN'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    final String formattedDate = _selectedDate != null
        ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
        : '';
    final String formattedTime =
        _selectedTime?.format(context) ?? '';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 70),
          const SizedBox(height: 16),
          Text(
            'ĐẶT BÀN THÀNH CÔNG',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text('Tên khách: ${_nameCtrl.text}'),
          Text('SĐT: ${_phoneCtrl.text}'),
          Text('Ngày đặt: $formattedDate'),
          Text('Giờ đặt: $formattedTime'),
          Text('Số lượng khách: $_guestCount'),
          Text('Loại bàn: $_selectedTableType'),
          Text('Bàn: ${_selectedTable?['name']}'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('HOÀN TẤT'),
          )
        ],
      ),
    );
  }
}