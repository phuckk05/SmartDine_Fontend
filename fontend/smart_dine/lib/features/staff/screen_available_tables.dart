// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mart_dine/models/table.dart';
// import 'package:mart_dine/providers/table_provider.dart';

// class ScreenAvailableTables extends ConsumerWidget {
//   final int guestCount;

//   const ScreenAvailableTables({Key? key, required this.guestCount})
//     : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Get the list of all tables from the provider
//     final allTables = ref.watch(tableProvider).tables;

//     // Filter for available tables that can accommodate the number of guests
//     final availableTables =
//         allTables.where((table) {
//           return table.status == TableStatus.available &&
//               table.seats >= guestCount;
//         }).toList();

//     return Scaffold(
//       appBar: AppBar(title: const Text('Bàn trống phù hợp')),
//       body:
//           availableTables.isEmpty
//               ? const Center(child: Text('Không có bàn trống nào phù hợp.'))
//               : ListView.builder(
//                 itemCount: availableTables.length,
//                 itemBuilder: (context, index) {
//                   final table = availableTables[index];
//                   return ListTile(
//                     title: Text('Bàn: ${table.name}'),
//                     subtitle: Text('Số ghế: ${table.seats}'),
//                     onTap: () {
//                       // Return the selected table's name to the previous screen
//                       Navigator.of(context).pop(table);
//                     },
//                   );
//                 },
//               ),
//     );
//   }
// }
