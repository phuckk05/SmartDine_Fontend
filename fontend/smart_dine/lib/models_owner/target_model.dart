// file: models/target_model.dart
import 'dart:convert';

class Target {
  final int id;
  final int branchId;
  final double targetAmount;
  final String targetType; // 'Năm', 'Tháng', 'Tuần'
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Target({
    required this.id,
    required this.branchId,
    required this.targetAmount,
    required this.targetType,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  Target copyWith({
    int? id,
    int? branchId,
    double? targetAmount,
    String? targetType,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Target(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      targetAmount: targetAmount ?? this.targetAmount,
      targetType: targetType ?? this.targetType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'branchId': branchId,
      'targetAmount': targetAmount,
      'targetType': targetType,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Target.fromMap(Map<String, dynamic> map) {
    return Target(
      id: int.tryParse(map['id'].toString()) ?? 0,
      branchId: int.tryParse(map['branchId'].toString()) ?? 0,
      targetAmount: double.tryParse(map['targetAmount'].toString()) ?? 0.0,
      targetType: map['targetType'] ?? '',
      startDate: DateTime.tryParse(map['startDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(map['endDate'] ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Target.fromJson(String source) => Target.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Target(id: $id, branchId: $branchId, targetAmount: $targetAmount, targetType: $targetType, startDate: $startDate, endDate: $endDate, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Target &&
        other.id == id &&
        other.branchId == branchId &&
        other.targetAmount == targetAmount &&
        other.targetType == targetType &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        branchId.hashCode ^
        targetAmount.hashCode ^
        targetType.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}