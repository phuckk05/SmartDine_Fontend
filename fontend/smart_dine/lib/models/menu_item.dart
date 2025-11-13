class MenuItemStatus {
  final String id;
  final String code; // AVAILABLE, UNAVAILABLE
  final String name;

  MenuItemStatus({
    required this.id,
    required this.code,
    required this.name,
  });

  factory MenuItemStatus.fromJson(Map<String, dynamic> json) {
    return MenuItemStatus(
      id: json['id'],
      code: json['code'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
    };
  }
}

class CategoryStatus {
  final String id;
  final String code; // ACTIVE, INACTIVE
  final String name;

  CategoryStatus({
    required this.id,
    required this.code,
    required this.name,
  });

  factory CategoryStatus.fromJson(Map<String, dynamic> json) {
    return CategoryStatus(
      id: json['id'],
      code: json['code'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
    };
  }
}

class Category {
  final String id;
  final String companyId;
  final String name;
  final String statusId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  // Relations
  CategoryStatus? status;

  Category({
    required this.id,
    required this.companyId,
    required this.name,
    required this.statusId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.status,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      companyId: json['company_id'],
      name: json['name'],
      statusId: json['status_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
      status: json['status'] != null ? CategoryStatus.fromJson(json['status']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'name': name,
      'status_id': statusId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      if (status != null) 'status': status!.toJson(),
    };
  }

  bool isActive() => status?.code == 'ACTIVE';
  bool isInactive() => status?.code == 'INACTIVE';
}

class MenuItem {
  final String id;
  final String companyId;
  final String name;
  final double price;
  final String statusId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  // Relations
  MenuItemStatus? status;
  List<String>? images;
  String? categoryName;

  MenuItem({
    required this.id,
    required this.companyId,
    required this.name,
    required this.price,
    required this.statusId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.status,
    this.images,
    this.categoryName,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      companyId: json['company_id'],
      name: json['name'],
      price: json['price'].toDouble(),
      statusId: json['status_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
      status: json['status'] != null ? MenuItemStatus.fromJson(json['status']) : null,
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      categoryName: json['category_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'name': name,
      'price': price,
      'status_id': statusId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      if (status != null) 'status': status!.toJson(),
      if (images != null) 'images': images,
      if (categoryName != null) 'category_name': categoryName,
    };
  }

  String getStatusName() => status?.name ?? 'Unknown';
  bool isAvailable() => status?.code == 'AVAILABLE';
  bool isUnavailable() => status?.code == 'UNAVAILABLE';

  // Get first image or placeholder
  String getImageUrl() {
    if (images != null && images!.isNotEmpty) {
      return images!.first;
    }
    return ''; // Return empty or placeholder URL
  }
}
