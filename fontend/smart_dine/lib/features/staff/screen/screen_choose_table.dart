import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Data/providers_choose_table.dart';
import 'screen_booking.dart';
import 'screen_menu.dart';
import 'screen_table_order.dart';

class ScreenSelectTable extends ConsumerWidget {
  const ScreenSelectTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(tableFilterProvider);

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
          // Bộ lọc trạng thái và loại bàn
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _FilterChip('Tất cả', selectedFilter, ref),
                _FilterChip('Trống', selectedFilter, ref),
                _FilterChip('Có khách', selectedFilter, ref),
                _FilterChip('Đã đặt', selectedFilter, ref),
                _FilterChip('VIP', selectedFilter, ref),
                _FilterChip('Yên tĩnh', selectedFilter, ref),
                _FilterChip('Trong nhà', selectedFilter, ref),
                _FilterChip('Ngoài trời', selectedFilter, ref),
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
                  final selectedFilter = ref.watch(tableFilterProvider);

                  final filteredTables = allTables.where((table) {
                    if (selectedFilter == 'Tất cả') {
                      return true;
                    }
                    if (['VIP', 'Yên tĩnh', 'Trong nhà', 'Ngoài trời'].contains(selectedFilter)) {
                      return table['type'] == selectedFilter || table['area'] == selectedFilter;
                    }
                    return table['status'] == selectedFilter;
                  }).toList();

                  return GridView.builder(
                    itemCount: filteredTables.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ScreenTableOrder(tableName: table['name'])),
                            );
                            return;
                          }

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

                          final guestCount = await showModalBottomSheet<int>(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              int count = 2;
                              return Padding(
                                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                            ref.read(tablesProvider.notifier).moveToTop(table);
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
        onSelected: (_) => ref.read(tableFilterProvider.notifier).state = label,
        selectedColor: Colors.blue.shade100,
        backgroundColor: Colors.grey.shade200,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.transparent),
        ),
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
    Color color;
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
    
    final bool isLight = color.computeLuminance() > 0.5;
    final textColor = isLight ? Colors.black : Colors.white;

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
        child: Column( // Sử dụng Column để xếp chồng nội dung và dải VIP
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Đẩy dải VIP xuống cuối
          children: [
            Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    table['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people, size: 14, color: textColor),
                      Text(
                        ' ${table['capacity']} chỗ',
                        style: TextStyle(fontSize: 12, color: textColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (table['area'] != null) // Hiển thị khu vực nếu có
                    Text(
                      table['area'],
                      style: TextStyle(fontSize: 12, color: textColor),
                    ),
                  // Chỉ hiển thị table['type'] nếu nó không phải là 'VIP' và không phải 'Thường'
                  if (table['type'] != null && table['type'] != 'VIP' && table['type'] != 'Thường')
                    Text(
                      table['type'],
                      style: TextStyle(fontSize: 12, color: textColor),
                    ),
                ],
              ),
            ),
            // Dải màu vàng cho bàn VIP
            if (table['type'] == 'VIP')
              Container(
                height: 20, // Chiều cao của dải
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.yellow.shade700,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: const Text(
                  'VIP',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54, // Màu chữ cho dải VIP
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}