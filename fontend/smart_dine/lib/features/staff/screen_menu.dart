import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/widgets/appbar.dart';

class ScreenMenu extends ConsumerStatefulWidget {
  final String tableName;
  const ScreenMenu({super.key, required this.tableName});

  @override
  ConsumerState<ScreenMenu> createState() => _ScreenMenuState();
}

//State provider
final _selectedCategoryProvider = StateProvider<String>((ref) => 'Tất cả');
final _selectedMenuProvider = StateProvider<String>((ref) => 'Tất cả');
final _openBillProvider = StateProvider<bool>((ref) => false);

class _ScreenMenuState extends ConsumerState<ScreenMenu> {
  //Biến golobal key
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<_MenuItem> _menuItems = const [
    _MenuItem(name: 'Bánh mì', price: 242.3243),
    _MenuItem(name: 'Phở bò', price: 185.0000),
    _MenuItem(name: 'Gỏi cuốn', price: 82.0000),
    _MenuItem(name: 'Cà phê sữa', price: 45.0000),
    _MenuItem(name: 'Trà đào', price: 55.0000),
    _MenuItem(name: 'Bánh flan', price: 39.0000),
    _MenuItem(name: 'Bít tết', price: 289.0000),
    _MenuItem(name: 'Mì Ý', price: 165.0000),
    _MenuItem(name: 'Súp bí đỏ', price: 98.0000),
    _MenuItem(name: 'Salad cá ngừ', price: 123.0000),
    _MenuItem(name: 'Bánh mì pate', price: 74.5000),
    _MenuItem(name: 'Trà trái cây', price: 69.0000),
  ];

  final Set<int> _selectedIndices = {};

  @override
  Widget build(BuildContext context) {
    final drawerWidth = MediaQuery.of(context).size.width * 0.82;
    return Scaffold(
      key: _scaffoldKey,
      onEndDrawerChanged: (isOpened) {
        ref.read(_openBillProvider.notifier).state = isOpened;
      },
      endDrawer: Drawer(
        width: drawerWidth,
        child: SafeArea(
          child: Column(
            children: [
              ListTile(title: Text('Order của bàn ${widget.tableName}')),
              const Divider(),
              Expanded(
                child:
                    _selectedIndices.isEmpty
                        ? const Center(
                          child: Text('Chưa có món ăn nào được chọn.'),
                        )
                        : ListView.builder(
                          itemCount: _selectedIndices.length,
                          itemBuilder: (context, index) {
                            final menuIndex = _selectedIndices.elementAt(index);
                            final item = _menuItems[menuIndex];
                            return ListTile(
                              title: Text(item.name),
                              trailing: Text(
                                '${item.price.toStringAsFixed(4)} đ',
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBarCus(
        title: widget.tableName,
        isCanpop: true,
        isButtonEnabled: true,
        actions: [
          IconButton(icon: const Icon(LucideIcons.search), onPressed: () {}),
        ],
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Style.paddingPhone,
            vertical: 16,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _textSpinner(context),
                  const SizedBox(height: 16),
                  Expanded(child: _listMenu()),
                ],
              ),
              _actionButton(context),
            ],
          ),
        ),
      ),
    );
  }

  //Tiêu đề món ăn & spinner
  Widget _textSpinner(BuildContext context) {
    final dropdownItems = <String>[
      'Tất cả',
      'Món khai vị',
      'Món chính',
      'Tráng miệng',
      'Đồ uống',
    ];
    final dropdownMenus = <String>['Tất cả', 'Menu ngày thường'];

    return Row(
      children: [
        DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            items:
                dropdownMenus
                    .map(
                      (value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    )
                    .toList(),
            value: ref.watch(_selectedMenuProvider),
            onChanged: (value) {
              if (value == null) return;
              ref.read(_selectedMenuProvider.notifier).state = value;
            },
            customButton: Row(
              children: [
                Text(
                  ref.watch(_selectedMenuProvider),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ],
            ),
            dropdownStyleData: DropdownStyleData(
              offset: const Offset(0, 0), // menu nằm ngay dưới nút
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              maxHeight: 240,
              width: 140,
            ),
            menuItemStyleData: const MenuItemStyleData(height: 44),
          ),
        ),
        const Spacer(),

        DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            items:
                dropdownItems
                    .map(
                      (value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    )
                    .toList(),
            value: ref.watch(_selectedCategoryProvider),
            onChanged: (value) {
              if (value == null) return;
              ref.read(_selectedCategoryProvider.notifier).state = value;
            },
            customButton: Row(
              children: [
                Text(
                  ref.watch(_selectedCategoryProvider),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ],
            ),
            dropdownStyleData: DropdownStyleData(
              offset: const Offset(0, 0), // menu nằm ngay dưới nút
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              maxHeight: 240,
              width: 140,
            ),
            menuItemStyleData: const MenuItemStyleData(height: 44),
          ),
        ),
      ],
    );
  }

  //List món ăn
  Widget _listMenu() {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;

    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: _menuItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.1,
      ),
      itemBuilder: (context, index) {
        final item = _menuItems[index];
        final isSelected = _selectedIndices.contains(index);

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedIndices.remove(index);
              } else {
                _selectedIndices.add(index);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? primary : surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.transparent : Colors.grey.shade300,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isSelected ? Colors.white : onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${item.price.toStringAsFixed(3)} đ',
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white70 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //Nút hành động show ra order
  Widget _actionButton(BuildContext context) {
    final theme = Theme.of(context);
    final isOpen = ref.watch(_openBillProvider);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return AnimatedAlign(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      alignment: isOpen ? Alignment.bottomLeft : Alignment.bottomRight,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset + 8),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 6,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
            backgroundColor: theme.colorScheme.primary,
          ),
          onPressed: () {
            final scaffoldState = _scaffoldKey.currentState;
            final nextState = !isOpen;
            ref.read(_openBillProvider.notifier).state = nextState;
            if (nextState) {
              scaffoldState?.openEndDrawer();
            } else {
              scaffoldState?.closeEndDrawer();
            }
          },
          child: AnimatedRotation(
            turns: isOpen ? 0.5 : 0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Icon(
              Icons.arrow_back,
              color: theme.colorScheme.onPrimary,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final String name;
  final double price;

  const _MenuItem({required this.name, required this.price});
}
