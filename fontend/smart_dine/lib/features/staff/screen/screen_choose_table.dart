import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Data/choose_table_controller.dart';
import 'screen_booking.dart';
import 'screen_menu.dart';
import 'screen_table_order.dart';

class ScreenSelectTable extends ConsumerWidget {
  const ScreenSelectTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
  final selectedStatus = ref.watch(tableStatusProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Chọn bàn',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          // 🔔 Thông báo
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              // xử lý thông báo
            },
          ),
          // 📅 Nút Đặt bàn
          IconButton(
            icon: const Icon(Icons.event_seat, color: Colors.white),
            tooltip: 'Đặt bàn',
            onPressed: () {
              // Khi bấm vào, mở form hoặc điều hướng sang màn hình đặt bàn
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScreenBooking()),
              );
            },
          ),
          const SizedBox(width: 8),
          // ⚙️ Cài đặt
          const Icon(Icons.settings, color: Colors.white),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // Ô tìm kiếm
          Padding(
            padding: const EdgeInsets.all(12),
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

          // Bộ lọc trạng thái
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _FilterChip('Tất cả', selectedStatus, ref),
                _FilterChip('Trống', selectedStatus, ref),
                _FilterChip('Có khách', selectedStatus, ref),
                _FilterChip('Đã đặt', selectedStatus, ref),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Grid danh sách bàn
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Consumer(
                builder: (context, ref, _) {
                  final allTables = ref.watch(tablesProvider);
                  final selectedStatus = ref.watch(tableStatusProvider);

                  // lọc danh sách hiển thị
                  final filteredTables =
                      selectedStatus == 'Tất cả'
                          ? allTables
                          : allTables
                              .where((t) => t['status'] == selectedStatus)
                              .toList();

                  return GridView.builder(
                    itemCount: filteredTables.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1,
                        ),
                    itemBuilder: (context, index) {
                      final table = filteredTables[index];

                      return _TableCard(
                        table: table,
                        onTap: () async {
                          if (table['status'] == 'Có khách') {
                            // Mở màn hình hiển thị order hiện tại
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ScreenTableOrder(tableName: table['name'])),
                            );
                            return;
                          }

                          // Nếu bàn đã được đặt trước (Đã đặt), lấy booking và chuyển thẳng sang chọn món
                          if (table['status'] == 'Đã đặt') {
                            final booking = ref.read(bookingsProvider)[table['name']];
                            final guestCountFromBooking = booking != null ? (booking['guestCount'] as int?) ?? 2 : 2;
                            ref.read(tablesProvider.notifier).moveToTop(table);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ScreenMenu(table: table, guestCount: guestCountFromBooking)),
                            );
                            return;
                          }

                          // Mở bottom sheet để nhập số khách (bàn trống)
                          final guestCount = await showModalBottomSheet<int>(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              int count = 2;
                              return Padding(
                                padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context).viewInsets.bottom),
                                child: StatefulBuilder(
                                  builder: (context, setState) => Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Chọn số khách cho bàn ${table['name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                if (count > 1) setState(() => count--);
                                              },
                                              icon: const Icon(Icons.remove_circle_outline),
                                            ),
                                            Text('$count', style: const TextStyle(fontSize: 18)),
                                            IconButton(
                                              onPressed: () => setState(() => count++),
                                              icon: const Icon(Icons.add_circle_outline),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('HỦY')),
                                            ElevatedButton(onPressed: () => Navigator.pop(context, count), child: const Text('XÁC NHẬN')),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );

                          if (guestCount != null) {
                            // Di chuyển bàn lên top cho tiện
                            ref.read(tablesProvider.notifier).moveToTop(table);
                            // Chuyển sang màn hình chọn món
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ScreenMenu(table: table, guestCount: guestCount)),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String selected;
  final WidgetRef ref;
  const _FilterChip(this.label, this.selected, this.ref);

  @override
  Widget build(BuildContext context) {
    final bool isSelected = label == selected;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => ref.read(tableStatusProvider.notifier).state = label,
        selectedColor: Colors.blue.shade100,
      ),
    );
  }
}

class _TableCard extends StatelessWidget {
  final Map<String, dynamic> table;
  final VoidCallback onTap;
  const _TableCard({required this.table, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color color;
    switch (table['status']) {
      case 'Có khách':
        color = Colors.blue.shade400;
        break;
      case 'Đã đặt':
        color = Colors.orange.shade400;
        break;
      default:
        color = Colors.grey.shade300;
    }

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(1, 2)),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                table['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people, size: 14),
                  Text(
                    ' ${table['capacity']} chỗ',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                table['area'],
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


