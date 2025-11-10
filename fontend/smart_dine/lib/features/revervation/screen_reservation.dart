import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/core/constrats.dart';
import 'package:mart_dine/widgets/appbar.dart';
import 'package:mart_dine/providers/table_provider.dart';
import 'package:mart_dine/models/table.dart';
import 'package:mart_dine/API/reservation_API.dart';
import 'package:intl/intl.dart';
import 'package:email_validator/email_validator.dart';

class ScreenReservation extends ConsumerStatefulWidget {
  final int? branchId;
  const ScreenReservation({super.key, this.branchId});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ScreenReservationState();
}

class _ScreenReservationState extends ConsumerState<ScreenReservation> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _numberOfGuestsController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime? _reservedDay;
  DateTime? _reservedTime;
  int? _selectedBranchId;
  List<int> _selectedTableIds = [];

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerEmailController.dispose();
    _numberOfGuestsController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Set default branch if provided
    if (widget.branchId != null) {
      _selectedBranchId = widget.branchId;
    }
  }

  Future<void> _selectReservedDay(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _reservedDay ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _reservedDay) {
      setState(() {
        _reservedDay = picked;
      });
    }
  }

  Future<void> _selectReservedTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_reservedTime ?? DateTime.now()),
    );
    if (picked != null) {
      final now = DateTime.now();
      final selectedTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );
      setState(() {
        _reservedTime = selectedTime;
      });
    }
  }

  void _submitReservation() async {
    if (_formKey.currentState!.validate()) {
      if (_reservedDay == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn ngày đặt bàn')),
        );
        return;
      }
      if (_reservedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn giờ đặt bàn')),
        );
        return;
      }
      if (_selectedTableIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn ít nhất một bàn')),
        );
        return;
      }

      // Prepare reservation data
      final reservationData = {
        'branchId': widget.branchId ?? 1,
        'customerName': _customerNameController.text,
        'customerEmail': _customerEmailController.text,
        'reservedTime': _reservedTime!.toIso8601String(),
        'reservedDay': _reservedDay!.toIso8601String(),
        'numberOfGuests': int.parse(_numberOfGuestsController.text),
        'statusId': 1, // Pending
        'note': _noteController.text,
      };

      try {
        final reservationApi = ReservationApi();
        await reservationApi.createReservation(
          reservationData,
          _selectedTableIds,
        );
        Constrats.showThongBao(context, 'Đặt bàn thành công!');
        // Clear form
        _formKey.currentState!.reset();
        setState(() {
          _reservedDay = null;
          _reservedTime = null;
          _selectedBranchId = widget.branchId;
          _selectedTableIds.clear();
        });
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi đặt bàn: $e')));
        print('Lỗi đặt bàn: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCus(
        isCanpop: true,
        isButtonEnabled: true,
        title: 'Đặt chỗ',
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(child: Column(children: [_buildBody()])),
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin đặt bàn',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Table Selection
            Consumer(
              builder: (context, ref, child) {
                final branchId = _selectedBranchId ?? widget.branchId ?? 1;
                final unpaidTableIds = ref.watch(
                  unpaidTablesByBranchProvider(branchId),
                );
                final allTables = ref.watch(tableNotifierProvider);
                return unpaidTableIds.when(
                  data: (unpaidIds) {
                    // Bàn trống: tất cả bàn - bàn có khách
                    final availableTables =
                        allTables
                            .where((table) => !unpaidIds.contains(table.id))
                            .toList();
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Chọn bàn trống *',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              // Bàn trống
                              ...availableTables.map((table) {
                                final isSelected = _selectedTableIds.contains(
                                  table.id,
                                );
                                return FilterChip(
                                  label: Text(table.name),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedTableIds.add(table.id);
                                      } else {
                                        _selectedTableIds.remove(table.id);
                                      }
                                    });
                                  },
                                  backgroundColor: Colors.white,
                                  selectedColor: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.2),
                                  checkmarkColor:
                                      Theme.of(context).primaryColor,
                                );
                              }).toList(),
                            ],
                          ),
                          if (availableTables.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                'Không có bàn trống',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Lỗi: $error'),
                );
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _customerNameController,
              decoration: const InputDecoration(
                labelText: 'Tên khách hàng *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên khách hàng';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Customer Email
            TextFormField(
              controller: _customerEmailController,
              decoration: const InputDecoration(
                labelText: 'Email khách hàng *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              // validator: (value) {
              //   if (value == null || value.isEmpty) {
              //     return 'Vui lòng nhập email';
              //   }
              //   if (!EmailValidator.validate(value)) {
              //     return 'Email không hợp lệ';
              //   }
              //   return null;
              // },
            ),
            const SizedBox(height: 16),

            // Reserved Day
            InkWell(
              onTap: () => _selectReservedDay(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Ngày đặt bàn *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _reservedDay != null
                      ? DateFormat('dd/MM/yyyy').format(_reservedDay!)
                      : 'Chọn ngày',
                  style: TextStyle(
                    color: _reservedDay != null ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Reserved Time
            InkWell(
              onTap: () => _selectReservedTime(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Giờ đặt bàn *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                ),
                child: Text(
                  _reservedTime != null
                      ? DateFormat('HH:mm').format(_reservedTime!)
                      : 'Chọn giờ',
                  style: TextStyle(
                    color: _reservedTime != null ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Number of Guests
            TextFormField(
              controller: _numberOfGuestsController,
              decoration: const InputDecoration(
                labelText: 'Số lượng khách *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.people),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập số lượng khách';
                }
                final number = int.tryParse(value);
                if (number == null || number <= 0) {
                  return 'Số lượng khách phải là số dương';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Note
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Ghi chú',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
              maxLength: 500,
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitReservation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Đặt bàn',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
