import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class Table {
  final int? id;
  final int branchId;
  final String name;
  final int typeId;
  final String? description;
  final int statusId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Table({
    this.id,
    required this.branchId,
    required this.name,
    required this.typeId,
    this.description,
    required this.statusId,
    this.createdAt,
    this.updatedAt,
  });
  // Factory Table.create({
  //   required int branchId,
  //   required String name,
  //   required int typeId,
  //   required String? description,
  //   required int statusId,
  // }) {
  //   return Table(
  //     branchId: branchId,
  //     name: name,
  //     typeId: typeId,
  //     description: description,
  //     statusId: statusId,
  //     createdAt: DateTime.now(),
  //     updatedAt: DateTime.now(),
  //   );
  // }

  Table copyWith({
    ValueGetter<int?>? id,
    int? branchId,
    String? name,
    int? typeId,
    ValueGetter<String?>? description,
    int? statusId,
    ValueGetter<DateTime?>? createdAt,
    ValueGetter<DateTime?>? updatedAt,
  }) {
    return Table(
      id: id != null ? id() : this.id,
      branchId: branchId ?? this.branchId,
      name: name ?? this.name,
      typeId: typeId ?? this.typeId,
      description: description != null ? description() : this.description,
      statusId: statusId ?? this.statusId,
      createdAt: createdAt != null ? createdAt() : this.createdAt,
      updatedAt: updatedAt != null ? updatedAt() : this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'branchId': branchId,
      'name': name,
      'typeId': typeId,
      'description': description,
      'statusId': statusId,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory Table.fromMap(Map<String, dynamic> map) {
    DateTime? _parseDate(dynamic value) {
      if (value == null) return null;
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      if (value is String) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    return Table(
      id: map['id'] != null ? int.tryParse(map['id'].toString()) : null,
      branchId:
          int.tryParse((map['branchId'] ?? map['branch_id']).toString()) ?? 0,
      name: map['name']?.toString() ?? '',
      typeId: int.tryParse((map['typeId'] ?? map['type_id']).toString()) ?? 0,
      description: map['description']?.toString(),
      statusId:
          int.tryParse((map['statusId'] ?? map['status_id']).toString()) ?? 0,
      createdAt: _parseDate(map['createdAt'] ?? map['created_at']),
      updatedAt: _parseDate(map['updatedAt'] ?? map['updated_at']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Table.fromJson(String source) => Table.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Table(id: $id, branchId: $branchId, name: $name, typeId: $typeId, description: $description, statusId: $statusId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Table &&
        other.id == id &&
        other.branchId == branchId &&
        other.name == name &&
        other.typeId == typeId &&
        other.description == description &&
        other.statusId == statusId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        branchId.hashCode ^
        name.hashCode ^
        typeId.hashCode ^
        description.hashCode ^
        statusId.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
