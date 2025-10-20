import 'package:flutter/material.dart';
import 'package:mart_dine/models/table.dart';

class TableFilterDialog extends StatefulWidget {
  final TableZone? currentZone;
  final TableStatus? currentStatus;

  const TableFilterDialog({Key? key, this.currentZone, this.currentStatus})
    : super(key: key);

  @override
  State<TableFilterDialog> createState() => _TableFilterDialogState();
}

class _TableFilterDialogState extends State<TableFilterDialog> {
  late TableZone? _selectedZone;
  late TableStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedZone = widget.currentZone;
    _selectedStatus = widget.currentStatus;
  }

  String _getZoneText(TableZone zone) {
    switch (zone) {
      case TableZone.all:
        return 'Tất cả';
      case TableZone.vip:
        return 'Vip';
      case TableZone.quiet:
        return 'Yên tĩnh';
      case TableZone.indoor:
        return 'Trong nhà';
      case TableZone.outdoor:
        return 'Ngoài trời';
    }
  }

  String _getStatusText(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return 'Trống';
      case TableStatus.reserved:
        return 'Đã đặt';
      case TableStatus.serving:
        return 'Có khách';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bộ lọc',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 30, thickness: 1),

            // ✅ NỘI DUNG CUỘN ĐƯỢC ĐỂ TRÁNH LỖI OVERFLOW
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Khu vực lọc theo Loại phòng
                    const Text(
                      'Khu vực',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children:
                            TableZone.values
                                .map((zone) => _buildZoneOption(zone))
                                .toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Khu vực lọc theo Trạng thái
                    const Text(
                      'Trạng thái',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildStatusOption(null), // Lựa chọn "Tất cả"
                          ...TableStatus.values
                              .map((status) => _buildStatusOption(status))
                              .toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // --- Footer ---
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pop({'zone': _selectedZone, 'status': _selectedStatus});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Xác Nhận'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneOption(TableZone zone) {
    return RadioListTile<TableZone?>(
      title: Text(_getZoneText(zone)),
      value: zone,
      groupValue: _selectedZone,
      onChanged: (TableZone? value) {
        setState(() {
          _selectedZone = value;
        });
      },
      activeColor: Theme.of(context).primaryColor,
      controlAffinity: ListTileControlAffinity.trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildStatusOption(TableStatus? status) {
    return RadioListTile<TableStatus?>(
      title: Text(status == null ? 'Tất cả' : _getStatusText(status!)),
      value: status,
      groupValue: _selectedStatus,
      onChanged: (TableStatus? value) {
        setState(() {
          _selectedStatus = value;
        });
      },
      activeColor: Theme.of(context).primaryColor,
      controlAffinity: ListTileControlAffinity.trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
