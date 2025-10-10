import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Data/choose_table_controller.dart';

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
  int _guestCount = 2;
  bool _success = false;
  Map<String, dynamic>? _selectedTable;

  void _findTable() {
    final tables = ref.read(tablesProvider);
    final available = tables
        .where((t) => t['status'] == 'Trống' && t['capacity'] >= _guestCount)
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
    if (_selectedTable == null) return;
    // lưu booking vào bookingsProvider
    ref.read(bookingsProvider.notifier).setBooking(_selectedTable!['name'], {
      'name': _nameCtrl.text,
      'phone': _phoneCtrl.text,
      'note': _noteCtrl.text,
      'guestCount': _guestCount,
    });
    // đặt trạng thái bàn -> 'Đã đặt'
    ref.read(tablesProvider.notifier).bookTable(_selectedTable!['name']);

    setState(() => _success = true);
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
      appBar: AppBar(title: const Text('Đặt bàn mới'), backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _success ? _buildSuccess() : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Tên khách hàng'),
          ),
          TextFormField(
            controller: _phoneCtrl,
            decoration: const InputDecoration(labelText: 'Số điện thoại'),
            keyboardType: TextInputType.phone,
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
                      icon: const Icon(Icons.remove_circle_outline)),
                  Text('$_guestCount'),
                  IconButton(
                      onPressed: () => setState(() => _guestCount++),
                      icon: const Icon(Icons.add_circle_outline)),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _noteCtrl,
            decoration: const InputDecoration(labelText: 'Ghi chú'),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 70),
          const SizedBox(height: 16),
          Text('ĐẶT BÀN THÀNH CÔNG',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Text('Tên khách: ${_nameCtrl.text}'),
          Text('SĐT: ${_phoneCtrl.text}'),
          Text('Bàn: ${_selectedTable?['name']}'),
          Text('Số lượng khách: $_guestCount'),
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
