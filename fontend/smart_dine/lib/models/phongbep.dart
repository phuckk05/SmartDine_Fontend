import 'dart:convert';

class KitchenDish {
  final int? id;
  final String tenMon;
  final String ban;
  final int statusId;
  final DateTime gioTao;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  KitchenDish({
    this.id,
    required this.tenMon,
    required this.ban,
    required this.statusId,
    required this.gioTao,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  factory KitchenDish.create({required String tenMon, required String ban}) {
    final now = DateTime.now();
    return KitchenDish(
      tenMon: tenMon,
      ban: ban,
      statusId: 0,
      gioTao: now,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
    );
  }

  KitchenDish copyWith({
    int? id,
    String? tenMon,
    String? ban,
    int? statusId,
    DateTime? gioTao,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return KitchenDish(
      id: id ?? this.id,
      tenMon: tenMon ?? this.tenMon,
      ban: ban ?? this.ban,
      statusId: statusId ?? this.statusId,
      gioTao: gioTao ?? this.gioTao,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tenMon': tenMon,
      'ban': ban,
      'statusId': statusId,
      'gioTao': gioTao.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory KitchenDish.fromMap(Map<String, dynamic> map) {
    int? _parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    DateTime _parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      if (v is String) {
        final parsed = DateTime.tryParse(v);
        if (parsed != null) return parsed;
        final i = int.tryParse(v);
        if (i != null) return DateTime.fromMillisecondsSinceEpoch(i);
      }
      return DateTime.now();
    }

    return KitchenDish(
      id: _parseInt(map['id']) ?? 0,
      tenMon: map['tenMon'] ?? '',
      ban: map['ban'] ?? '',
      statusId: _parseInt(map['statusId']) ?? 0,
      gioTao: _parseDate(map['gioTao']),
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
      deletedAt: map['deletedAt'] != null ? _parseDate(map['deletedAt']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory KitchenDish.fromJson(String source) =>
      KitchenDish.fromMap(json.decode(source));

  @override
  String toString() {
    return 'KitchenDish(id: $id, tenMon: $tenMon, ban: $ban, statusId: $statusId, gioTao: $gioTao, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is KitchenDish &&
        other.id == id &&
        other.tenMon == tenMon &&
        other.ban == ban &&
        other.statusId == statusId &&
        other.gioTao == gioTao;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        tenMon.hashCode ^
        ban.hashCode ^
        statusId.hashCode ^
        gioTao.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        deletedAt.hashCode;
  }
}
