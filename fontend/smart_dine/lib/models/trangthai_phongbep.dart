import 'dart:convert';

enum DishStatus { chuaLam, daLam, hetMon, daHuy }

class KitchenDish {
  final int? id;
  final String tenMon;
  final String ban;
  final DateTime gioTao;
  final DishStatus trangThai;

  KitchenDish({
    this.id,
    required this.tenMon,
    required this.ban,
    required this.gioTao,
    required this.trangThai,
  });

  factory KitchenDish.create({required String tenMon, required String ban}) {
    return KitchenDish(
      tenMon: tenMon,
      ban: ban,
      gioTao: DateTime.now(),
      trangThai: DishStatus.chuaLam,
    );
  }

  KitchenDish copyWith({
    int? id,
    String? tenMon,
    String? ban,
    DateTime? gioTao,
    DishStatus? trangThai,
  }) {
    return KitchenDish(
      id: id ?? this.id,
      tenMon: tenMon ?? this.tenMon,
      ban: ban ?? this.ban,
      gioTao: gioTao ?? this.gioTao,
      trangThai: trangThai ?? this.trangThai,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tenMon': tenMon,
      'ban': ban,
      'gioTao': gioTao.toIso8601String(),
      'trangThai': trangThai.index,
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
      id: _parseInt(map['id']),
      tenMon: map['tenMon'] ?? '',
      ban: map['ban'] ?? '',
      gioTao: _parseDate(map['gioTao']),
      trangThai:
          DishStatus.values[_parseInt(
                map['trangThai'],
              )?.clamp(0, DishStatus.values.length - 1) ??
              0],
    );
  }

  String toJson() => json.encode(toMap());

  factory KitchenDish.fromJson(String source) =>
      KitchenDish.fromMap(json.decode(source));

  @override
  String toString() {
    return 'KitchenDish(id: $id, tenMon: $tenMon, ban: $ban, gioTao: $gioTao, trangThai: $trangThai)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KitchenDish &&
        other.id == id &&
        other.tenMon == tenMon &&
        other.ban == ban &&
        other.trangThai == trangThai &&
        other.gioTao == gioTao;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        tenMon.hashCode ^
        ban.hashCode ^
        gioTao.hashCode ^
        trangThai.hashCode;
  }
}
