// import 'package:flutter/material.dart';
// import 'package:mart_dine/models/table.dart';

// class TableFilterDialog extends StatefulWidget {
//   final TableZone? currentZone;
//   final TableStatus? currentStatus;

//   const TableFilterDialog({
//     Key? key,
//     this.currentZone,
//     this.currentStatus,
//   }) : super(key: key);

//   @override
//   State<TableFilterDialog> createState() => _TableFilterDialogState();
// }

// class _TableFilterDialogState extends State<TableFilterDialog> {
//   late TableZone? _selectedZone;
//   late TableStatus? _selectedStatus;

//   @override
//   void initState() {
//     super.initState();
//     // Đảm bảo "Tất cả" được chọn mặc định nếu không có giá trị ban đầu
//     _selectedZone = widget.currentZone ?? TableZone.all;
//     _selectedStatus = widget.currentStatus; // Giữ nguyên null nếu không có, hoặc gán cho "Tất cả"
//   }

//   String _getZoneText(TableZone zone) {
//     switch (zone) {
//       case TableZone.all: return 'Tất cả';
//       case TableZone.vip: return 'Vip';
//       case TableZone.quiet: return 'Yên tĩnh';
//       case TableZone.indoor: return 'Trong nhà';
//       case TableZone.outdoor: return 'Ngoài trời';
//     }
//   }

//   String _getStatusText(TableStatus status) {
//     switch (status) {
//       case TableStatus.available: return 'Trống';
//       case TableStatus.reserved: return 'Đã đặt';
//       case TableStatus.serving: return 'Có khách';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // ✅ MÀU SẮC CHỈ ÁP DỤNG TRONG DIALOG NÀY: Xanh nước nhạt (Đã giữ nguyên)
//     const Color primaryBlue = Color(0xFF2196F3); // Một màu xanh dương tiêu chuẩn
//     const Color lightBlueBackground = Color(0xFFE3F2FD); // Màu xanh nước nhạt cho nền dialog
//     const Color whiteContainer = Colors.white; // Màu trắng cho các container bên trong

//     return Dialog(
//       backgroundColor: lightBlueBackground, // Nền của toàn bộ dialog
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min, // ✅ ĐÃ SỬA LỖI TỪ MainAxisSize.AxisSize.min thành MainAxisSize.min
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // --- Header ---
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text('Bộ lọc', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//                 IconButton(
//                   icon: const Icon(Icons.close, color: Colors.grey),
//                   onPressed: () => Navigator.of(context).pop(),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),

//             // --- Nội dung cuộn ---
//             Flexible(
//               child: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min, // ✅ ĐÃ SỬA LỖI TỪ MainAxisSize.AxisSize.min thành MainAxisSize.min
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Khu vực
//                     const Text('Khu vực', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
//                     const SizedBox(height: 8),
//                     Container(
//                       decoration: BoxDecoration(
//                         color: whiteContainer, // Màu trắng cho container khu vực
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Column(
//                         children: TableZone.values.map((zone) => _buildZoneOption(zone, primaryBlue)).toList(),
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     // Trạng thái
//                     const Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
//                     const SizedBox(height: 8),
//                     Container(
//                       decoration: BoxDecoration(
//                         color: whiteContainer, // Màu trắng cho container trạng thái
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Column(
//                         children: [
//                           _buildStatusOption(null, primaryBlue), // "Tất cả" cho Trạng thái
//                           ...TableStatus.values.map((status) => _buildStatusOption(status, primaryBlue)).toList(),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 30),

//             // --- Nút Xác nhận ---
//             Center(
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.of(context).pop({
//                     'zone': _selectedZone,
//                     'status': _selectedStatus,
//                   });
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: primaryBlue, // Màu xanh đậm cho nút
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 child: const Text('Xác Nhận'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Helper widget cho các lựa chọn Khu vực
//   Widget _buildZoneOption(TableZone zone, Color activeColor) {
//     return RadioListTile<TableZone?>(
//       title: Text(_getZoneText(zone)),
//       value: zone,
//       groupValue: _selectedZone,
//       onChanged: (TableZone? value) {
//         setState(() {
//           _selectedZone = value;
//         });
//       },
//       activeColor: activeColor, // Sử dụng màu xanh cho radio button khi được chọn
//       controlAffinity: ListTileControlAffinity.trailing,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//     );
//   }

//   // Helper widget cho các lựa chọn Trạng thái
//   Widget _buildStatusOption(TableStatus? status, Color activeColor) {
//     return RadioListTile<TableStatus?>(
//       title: Text(status == null ? 'Tất cả' : _getStatusText(status)),
//       value: status,
//       groupValue: _selectedStatus,
//       onChanged: (TableStatus? value) {
//         setState(() {
//           _selectedStatus = value;
//         });
//       },
//       activeColor: activeColor, // Sử dụng màu xanh cho radio button khi được chọn
//       controlAffinity: ListTileControlAffinity.trailing,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//     );
//   }
// }
