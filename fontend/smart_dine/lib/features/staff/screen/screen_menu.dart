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
    final bool hasOrder = quantities.isNotEmpty;

    // Hiển thị dialog để thêm ghi chú
    void showNoteDialog(int dishIndex, String currentNote) {
      final noteController = TextEditingController(text: currentNote);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Ghi chú cho ${dishes[dishIndex]['name']}'),
          content: TextField(
            controller: noteController,
            decoration: const InputDecoration(hintText: 'Nhập ghi chú...'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(orderControllerProvider.notifier).addNote(dishIndex, noteController.text);
                Navigator.of(ctx).pop();
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      );
    }
    
    // Nút xác nhận đơn hàng
    void confirmOrder() {
      // Logic xác nhận đơn hàng
      ref.read(orderControllerProvider.notifier).confirmOrder(table['name'], guestCount);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã gửi order')));
    }
    
    // Nút thanh toán
    void checkoutOrder() {
      // Logic thanh toán
      ref.read(orderControllerProvider.notifier).checkoutOrder(table['name']);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã thanh toán')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn món'),
        backgroundColor: Colors.blue,
        actions: const [
          Icon(Icons.search),
          SizedBox(width: 12),
        ],
      ),
      body: Row(
        children: [
          // Màn hình chọn món (bên trái)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Danh sách món ăn',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                // Ô tìm kiếm (trong danh sách món ăn)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Tìm kiếm',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: dishes.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.2,
                    ),
                    itemBuilder: (context, index) {
                      final dish = dishes[index];
                      return _DishCard(
                        dish: dish,
                        onTap: () {
                          ref.read(orderControllerProvider.notifier).increase(index);
                        },
                      );
                    },
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 12),
                  child: IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          
          // Màn hình đơn hàng (bên phải)
          if (hasOrder)
            Container(
              width: MediaQuery.of(context).size.width * 0.45,
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: Colors.grey)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Thông tin bàn:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Bàn số: ${table['name']}'),
                  Text('Số khách hàng: $guestCount'),
                  const SizedBox(height: 12),
                  const Text('Món ăn:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: quantities.keys.length,
                      itemBuilder: (context, index) {
                        final dishIndex = quantities.keys.elementAt(index);
                        final dish = dishes[dishIndex];
                        final qty = quantities[dishIndex] ?? 0;
                        final note = ref.watch(orderControllerProvider.notifier).getNote(dishIndex);
                        
                        return ListTile(
                          title: Text(dish['name']),
                          subtitle: Text(
                            note.isEmpty ? '${dish['price']} VNĐ' : 'Ghi chú: $note',
                            style: const TextStyle(fontSize: 12),
                          ),
                          onTap: () => showNoteDialog(dishIndex, note),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () => ref.read(orderControllerProvider.notifier).decrease(dishIndex),
                              ),
                              Text('$qty'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => ref.read(orderControllerProvider.notifier).increase(dishIndex),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tổng cộng:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${total.toInt()} VNĐ', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () => checkoutOrder(),
                          child: const Text('Thanh toán'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => confirmOrder(),
                          child: const Text('Xác nhận'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Widget để hiển thị từng món ăn dưới dạng thẻ
class _DishCard extends StatelessWidget {
  final Map<String, dynamic> dish;
  final VoidCallback onTap;

  const _DishCard({required this.dish, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dish['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '${dish['price']} VNĐ',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}