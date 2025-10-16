import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/providers/lichsu_provider.dart';
import '../../../core/style.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch providers
    final filteredHistory = ref.watch(filteredHistoryProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final activeFiltersCount = ref.watch(activeFiltersCountProvider);

    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;

    return Scaffold(
      backgroundColor: Style.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Text(
          'Lịch sử đã lấy món',
          style: Style.fontTitle.copyWith(
            color: Style.textColorWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar với icon filter
          Container(
            padding: EdgeInsets.all(isWeb ? 20 : Style.paddingPhone),
            color: Style.colorLight,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      ref.read(searchQueryProvider.notifier).state = value;
                    },
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm món, bàn, nhân viên...',
                      hintStyle: Style.fontNormal.copyWith(
                        color: Style.textColorGray,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Style.textColorGray,
                      ),
                      suffixIcon:
                          searchQuery.isNotEmpty
                              ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Style.textColorGray,
                                ),
                                onPressed: () {
                                  ref.read(searchQueryProvider.notifier).state =
                                      '';
                                },
                              )
                              : null,
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          Style.buttonBorderRadius,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: Style.paddingPhone,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Filter button với badge
                Stack(
                  children: [
                    InkWell(
                      onTap: () => _showFilterDialog(context, ref),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(
                            Style.buttonBorderRadius,
                          ),
                        ),
                        child: const Icon(
                          Icons.filter_list,
                          color: Colors.black87,
                          size: Style.iconSize,
                        ),
                      ),
                    ),
                    if (activeFiltersCount > 0)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            '$activeFiltersCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isWeb ? 20 : Style.paddingPhone,
              vertical: 12,
            ),
            color: Style.colorLight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tất cả thông báo (${filteredHistory.length})',
                  style: Style.fontTitleSuperMini.copyWith(
                    fontSize: isWeb ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (activeFiltersCount > 0)
                  TextButton.icon(
                    onPressed: () {
                      ref.read(clearAllFiltersProvider)();
                    },
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: const Text('Xóa bộ lọc'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
              ],
            ),
          ),

          // List
          Expanded(
            child:
                filteredHistory.isEmpty
                    ? _buildEmptyState(activeFiltersCount > 0)
                    : ListView.builder(
                      padding: EdgeInsets.all(isWeb ? 20 : Style.paddingPhone),
                      itemCount: filteredHistory.length,
                      itemBuilder: (context, index) {
                        return _buildHistoryCard(filteredHistory[index], isWeb);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  // Empty state
  Widget _buildEmptyState(bool hasFilters) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilters ? Icons.search_off : Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: Style.spacingMedium),
          Text(
            hasFilters ? 'Không tìm thấy kết quả' : 'Không có lịch sử',
            style: Style.fontTitleMini.copyWith(color: Style.textColorGray),
          ),
          if (hasFilters) ...[
            const SizedBox(height: 8),
            Text(
              'Thử thay đổi bộ lọc hoặc từ khóa tìm kiếm',
              style: Style.fontCaption.copyWith(color: Style.textColorGray),
            ),
          ],
        ],
      ),
    );
  }

  // History card
  Widget _buildHistoryCard(dynamic order, bool isWeb) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isWeb ? 16 : 14),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(Style.buttonBorderRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(Style.spacingSmall),
            decoration: BoxDecoration(
              color: Style.colorLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.receipt_long,
              color: Colors.grey[700],
              size: Style.iconSize,
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên món và bàn
                RichText(
                  text: TextSpan(
                    style: Style.fontNormal.copyWith(fontSize: isWeb ? 15 : 14),
                    children: [
                      const TextSpan(text: 'Tên món ăn: '),
                      TextSpan(
                        text: order.dishName,
                        style: Style.fontTitleSuperMini,
                      ),
                      const TextSpan(text: '    '),
                      const TextSpan(text: 'Bàn: '),
                      TextSpan(
                        text: order.tableNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),

                // Đã lấy bởi
                Text(
                  'Đã lấy bởi: ${order.staffName}',
                  style: Style.fontNormal.copyWith(fontSize: isWeb ? 14 : 13),
                ),
                const SizedBox(height: 2),

                // Thời gian
                Text(
                  order.formattedTime,
                  style: Style.fontCaption.copyWith(fontSize: isWeb ? 13 : 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Show filter dialog
  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    showDialog(context: context, builder: (context) => const _FilterDialog());
  }
}

// ==================== FILTER DIALOG ====================

class _FilterDialog extends ConsumerWidget {
  const _FilterDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTimeFilter = ref.watch(selectedTimeFilterProvider);
    final staffFilter = ref.watch(staffFilterProvider);
    final dishFilter = ref.watch(dishCategoryFilterProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Style.dialogBorderRadius),
      ),
      child: Container(
        width: 320,
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header với nút X
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Bộ lọc', style: Style.fontTitleMini),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Time filter section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Thời gian', style: Style.fontTitleMini),
                  const SizedBox(height: Style.spacingSmall),
                  Row(
                    children: [
                      _buildTimeTab(
                        ref,
                        'Hôm nay',
                        'today',
                        selectedTimeFilter,
                      ),
                      const SizedBox(width: Style.spacingSmall),
                      _buildTimeTab(
                        ref,
                        'Tuần này',
                        'week',
                        selectedTimeFilter,
                      ),
                      const SizedBox(width: Style.spacingSmall),
                      _buildTimeTabWithIcon(
                        ref,
                        'Chọn ngày',
                        'custom',
                        selectedTimeFilter,
                        context,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: Style.spacingMedium),

            // Nhân viên section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.centerLeft,
              child: Text('Nhân viên', style: Style.fontTitleMini),
            ),
            const SizedBox(height: Style.spacingSmall),

            // Nhân viên checkboxes
            ...staffFilter.keys.map((staff) {
              return CheckboxListTile(
                title: Text(staff, style: Style.fontNormal),
                value: staffFilter[staff],
                onChanged: (value) {
                  final updated = Map<String, bool>.from(staffFilter);
                  updated[staff] = value ?? false;
                  ref.read(staffFilterProvider.notifier).state = updated;
                },
                controlAffinity: ListTileControlAffinity.trailing,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                dense: true,
              );
            }),

            const SizedBox(height: Style.spacingMedium),

            // Món ăn section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.centerLeft,
              child: Text('Loại món ăn', style: Style.fontTitleMini),
            ),
            const SizedBox(height: Style.spacingSmall),

            // Món ăn checkboxes
            ...dishFilter.keys.map((dish) {
              return CheckboxListTile(
                title: Text(dish, style: Style.fontNormal),
                value: dishFilter[dish],
                onChanged: (value) {
                  final updated = Map<String, bool>.from(dishFilter);
                  updated[dish] = value ?? false;
                  ref.read(dishCategoryFilterProvider.notifier).state = updated;
                },
                controlAffinity: ListTileControlAffinity.trailing,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                dense: true,
              );
            }),

            const SizedBox(height: 20),

            // Nút Xác Nhận
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        Style.buttonBorderRadius,
                      ),
                    ),
                  ),
                  child: Text('Xác Nhận', style: Style.fontButton),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Build time tab
  Widget _buildTimeTab(
    WidgetRef ref,
    String label,
    String value,
    String selectedValue,
  ) {
    bool isSelected = selectedValue == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(selectedTimeFilterProvider.notifier).state = value;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: Style.spacingSmall),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[600] : Style.colorLight,
            border: Border.all(
              color: isSelected ? Colors.blue[600]! : Colors.grey[400]!,
              width: Style.borderWidth,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Style.fontCaption.copyWith(
              fontSize: 13,
              color: isSelected ? Style.textColorWhite : Colors.black87,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // Build time tab with icon and date picker
  Widget _buildTimeTabWithIcon(
    WidgetRef ref,
    String label,
    String value,
    String selectedValue,
    BuildContext context,
  ) {
    bool isSelected = selectedValue == value;
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          ref.read(selectedTimeFilterProvider.notifier).state = value;

          // Show date range picker
          final DateTimeRange? picked = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            initialDateRange: ref.read(customDateRangeProvider),
          );

          if (picked != null) {
            ref.read(customDateRangeProvider.notifier).state = picked;
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: Style.spacingSmall),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[600] : Style.colorLight,
            border: Border.all(
              color: isSelected ? Colors.blue[600]! : Colors.grey[400]!,
              width: Style.borderWidth,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: Style.fontCaption.copyWith(
                  fontSize: 13,
                  color: isSelected ? Style.textColorWhite : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.calendar_today,
                size: 14,
                color: isSelected ? Style.textColorWhite : Colors.black87,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
