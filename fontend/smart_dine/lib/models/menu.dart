// Enum loại món
enum MenuCategory { all, mainCourse, drink }

// Model món ăn
class MenuItemModel {
  final String id;
  final String name;
  final double price; // ✅ Thay đổi từ String sang double
  final MenuCategory category;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.price, // ✅ Thay đổi từ String sang double
    required this.category,
  });

  MenuItemModel copyWith({
    String? id,
    String? name,
    double? price, // ✅ Cập nhật kiểu dữ liệu
    MenuCategory? category,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
    );
  }
}

// State cho ChooseMenu
class ChooseMenuState {
  final List<MenuItemModel> allMenuItems;
  final List<MenuItemModel> filteredMenuItems;
  final MenuCategory selectedCategory;
  final List<String> selectedItemIds;

  ChooseMenuState({
    required this.allMenuItems,
    required this.filteredMenuItems,
    this.selectedCategory = MenuCategory.all,
    this.selectedItemIds = const [],
  });

  ChooseMenuState copyWith({
    List<MenuItemModel>? allMenuItems,
    List<MenuItemModel>? filteredMenuItems,
    MenuCategory? selectedCategory,
    List<String>? selectedItemIds,
  }) {
    return ChooseMenuState(
      allMenuItems: allMenuItems ?? this.allMenuItems,
      filteredMenuItems: filteredMenuItems ?? this.filteredMenuItems,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedItemIds: selectedItemIds ?? this.selectedItemIds,
    );
  }
}