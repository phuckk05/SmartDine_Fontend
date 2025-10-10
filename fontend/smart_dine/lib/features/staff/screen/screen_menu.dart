import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Data/menu_controller.dart';

class ScreenMenu extends ConsumerWidget {
  final Map<String, dynamic> table;
  final int guestCount;

  const ScreenMenu({super.key, required this.table, required this.guestCount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dishes = ref.watch(dishesProvider);
    final quantities = ref.watch(orderControllerProvider);
    final total = ref.watch(orderTotalProvider);

    void confirmOrder() async {
      await ref.read(orderControllerProvider.notifier).confirmOrder(table['name'], guestCount);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Xác nhận đơn hàng'),
          content: Text('Bàn: ${table['name']}\nKhách: $guestCount\n\n' +
              quantities.entries
                  .map((e) => '${dishes[e.key]['name']} x${e.value}')
                  .join('\n') +
              '\n\nTổng: $total VND'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã gửi order')));
                Navigator.pop(context);
              },
              child: const Text('Xác nhận'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Chọn món - Bàn ${table['name']}')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Số khách: $guestCount'),
                Text('Tổng: $total VND'),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: dishes.length,
              itemBuilder: (context, index) {
                final dish = dishes[index];
                final qty = quantities[index] ?? 0;
                return ListTile(
                  title: Text(dish['name']),
                  subtitle: Text('${dish['price']} VND'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: qty > 0 ? () => ref.read(orderControllerProvider.notifier).decrease(index) : null,
                      ),
                      Text('$qty'),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => ref.read(orderControllerProvider.notifier).increase(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              onPressed: quantities.isNotEmpty ? confirmOrder : null,
              child: const Text('Gửi order'),
            ),
          )
        ],
      ),
    );
  }
}
