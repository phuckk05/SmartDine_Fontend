class UserStatus {
  final String id;
  final String code; // ACTIVE, INACTIVE, LOCKED
  final String name;

  UserStatus({required this.id, required this.code, required this.name});

  factory UserStatus.fromJson(Map<String, dynamic> json) {
    return UserStatus(id: json['id'], code: json['code'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'code': code, 'name': name};
  }

  // Helper methods
  bool isActive() => code == 'ACTIVE';
  bool isInactive() => code == 'INACTIVE';
  bool isLocked() => code == 'LOCKED';
}
