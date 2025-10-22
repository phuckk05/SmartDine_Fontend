import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/core/style.dart';

// Provider lưu trạng thái filter
final tableStatusProvider = StateProvider<String>((ref) => 'Tất cả');

// Provider lưu danh sách bàn
final tablesProvider =
    StateNotifierProvider<TableNotifier, List<Map<String, dynamic>>>(
      (ref) => TableNotifier(),
    );

class TableNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  TableNotifier() : super(List<Map<String, dynamic>>.from(_initialTables));

  void moveToTop(Map<String, dynamic> table) {
    state = [table, ...state.where((t) => t['name'] != table['name']).toList()];
  }
}

class ScreenSelectTable extends ConsumerWidget {
  const ScreenSelectTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedStatus = ref.watch(tableStatusProvider);
    final tables = ref.watch(tablesProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Chọn bàn',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: const [
          Icon(Icons.filter_alt_outlined, color: Colors.white),
          SizedBox(width: 12),
          Icon(Icons.settings, color: Colors.white),
          SizedBox(width: 12),
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
                        onTap: () {
                          ref.read(tablesProvider.notifier).moveToTop(table);
                          // Không cần snackbar nếu muốn mượt hơn
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

// ---------------------------
// Dữ liệu mẫu ban đầu
// ---------------------------
final List<Map<String, dynamic>> _initialTables = [
  {'name': 'A-1', 'capacity': 4, 'status': 'Trống', 'area': 'Khu trong nhà'},
  {'name': 'A-2', 'capacity': 6, 'status': 'Có khách', 'area': 'Khu trong nhà'},
  {'name': 'A-3', 'capacity': 8, 'status': 'Đã đặt', 'area': 'Ngoài trời'},
  {'name': 'A-4', 'capacity': 4, 'status': 'Trống', 'area': 'Trong nhà'},
  {'name': 'A-5', 'capacity': 6, 'status': 'Có khách', 'area': 'Ngoài trời'},
  {'name': 'A-6', 'capacity': 8, 'status': 'Đã đặt', 'area': 'Trong nhà'},
  {'name': 'A-7', 'capacity': 2, 'status': 'Có khách', 'area': 'Khu Tiên'},
  {'name': 'A-8', 'capacity': 2, 'status': 'Có khách', 'area': 'Trong nhà'},
  {'name': 'A-9', 'capacity': 8, 'status': 'Đã đặt', 'area': 'Ngoài trời'},
  {'name': 'A-10', 'capacity': 4, 'status': 'Trống', 'area': 'Trong nhà'},
  {'name': 'A-11', 'capacity': 6, 'status': 'Có khách', 'area': 'Trong nhà'},
  {'name': 'A-12', 'capacity': 8, 'status': 'Trống', 'area': 'Trong nhà'},
  {'name': 'A-13', 'capacity': 4, 'status': 'Đã đặt', 'area': 'Ngoài trời'},
  {'name': 'A-14', 'capacity': 6, 'status': 'Có khách', 'area': 'Trong nhà'},
  {'name': 'A-15', 'capacity': 8, 'status': 'Trống', 'area': 'Trong nhà'},
  {'name': 'A-16', 'capacity': 2, 'status': 'Có khách', 'area': 'Trong nhà'},
  {'name': 'A-17', 'capacity': 6, 'status': 'Có khách', 'area': 'Ngoài trời'},
  {'name': 'A-18', 'capacity': 8, 'status': 'Đã đặt', 'area': 'Trong nhà'},
];
