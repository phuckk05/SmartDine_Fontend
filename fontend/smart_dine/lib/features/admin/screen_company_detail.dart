// import 'package:flutter/material.dart';
// import 'package:mart_dine/api/company_owner_api.dart';
// import 'package:mart_dine/models/company_owner.dart';

// class ScreenCompanyDetail extends StatefulWidget {
//   final int companyId;
//   const ScreenCompanyDetail({super.key, required this.companyId});

//   @override
//   State<ScreenCompanyDetail> createState() => _ScreenCompanyDetailState();
// }

// class _ScreenCompanyDetailState extends State<ScreenCompanyDetail> {
//   CompanyOwner? company;
//   bool loading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadDetail();
//   }

//   Future<void> _loadDetail() async {
//     try {
//       final api = CompanyOwnerAPI();
//       final result = await api.getCompanyOwnerDetail(widget.companyId);
//       setState(() {
//         company = result;
//         loading = false;
//       });
//     } catch (e) {
//       setState(() => loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Chi tiết công ty')),
//       body:
//           loading
//               ? const Center(child: CircularProgressIndicator())
//               : company == null
//               ? const Center(child: Text('Không tìm thấy công ty'))
//               : Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: ListView(
//                   children: [
//                     Text(
//                       '🏢 ${company!.companyName}',
//                       style: const TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text('Mã công ty: ${company!.companyCode}'),
//                     Text('Địa chỉ: ${company!.address}'),
//                     Text(
//                       'Trạng thái: ${company!.isActive ? "Hoạt động" : "Vô hiệu"}',
//                     ),
//                     const Divider(),
//                     Text('👤 Chủ cửa hàng: ${company!.ownerName}'),
//                     Text('📞 SĐT: ${company!.phoneNumber}'),
//                   ],
//                 ),
//               ),
//     );
//   }
// }
