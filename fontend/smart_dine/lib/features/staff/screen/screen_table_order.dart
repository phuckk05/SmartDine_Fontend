import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Data/menu_controller.dart';
import '../Data/providers_choose_table.dart';

class ScreenTableOrder extends ConsumerWidget {
  final String tableName;
  const ScreenTableOrder({super.key, required this.tableName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final order = orders[tableName];
    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Bàn $tableName')),
        body: const Center(child: Text('Không có order cho bàn này')),
      );
    }

    final items = order['items'] as Map<int, int>;
    final dishes = ref.read(dishesProvider);
    final total = items.entries.fold<int>(0, (sum, e) {
      final price = dishes[e.key]['price'] as int;
      return sum + price * e.value;
    });

    return Scaffold(
      appBar: AppBar(title: Text('Order - Bàn $tableName')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Số khách: ${order['guestCount']}'),
            const SizedBox(height: 12),
            const Text('Món đã chọn:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: items.entries.map((e) {
                  final dish = dishes[e.key];
                  return ListTile(
                    title: Text(dish['name']),
                    subtitle: Text('${dish['price']} VND x${e.value}'),
                    trailing: Text('${dish['price'] * e.value} VND'),
                  );
                }).toList(),
              ),
            ),
            const Divider(),
            Text('Tổng: $total VND', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
                ElevatedButton(
                  onPressed: () {
                    // Clear order and set table to 'Trống'
                    ref.read(ordersProvider.notifier).removeOrder(tableName);
                    ref.read(tablesProvider.notifier).freeTable(tableName);
                    Navigator.pop(context);
                  },
                  child: const Text('Hoàn tất'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
