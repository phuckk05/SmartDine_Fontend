class MenuItemStatus {
  final String id;
  final String code; // AVAILABLE, UNAVAILABLE
  final String name;

  MenuItemStatus({required this.id, required this.code, required this.name});

  factory MenuItemStatus.fromJson(Map<String, dynamic> json) {
    return MenuItemStatus(
      id: json['id'],
      code: json['code'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'code': code, 'name': name};
  }

  // Helper methods
  bool isAvailable() => code == 'AVAILABLE';
  bool isUnavailable() => code == 'UNAVAILABLE';
}
