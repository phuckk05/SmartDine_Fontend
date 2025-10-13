import 'dart:convert';

class Company {
  final int id;
  final String companyName;
  final String comapyAddress;
  final String copanyImagUrl;
  final int companyCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  Company({
    required this.id,
    required this.companyName,
    required this.comapyAddress,
    required this.copanyImagUrl,
    required this.companyCode,
    required this.createdAt,
    required this.updatedAt,
  });

  Company copyWith({
    int? id,
    String? companyName,
    String? comapyAddress,
    String? copanyImagUrl,
    int? companyCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Company(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      comapyAddress: comapyAddress ?? this.comapyAddress,
      copanyImagUrl: copanyImagUrl ?? this.copanyImagUrl,
      companyCode: companyCode ?? this.companyCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'companyName': companyName,
      'comapyAddress': comapyAddress,
      'copanyImagUrl': copanyImagUrl,
      'companyCode': companyCode,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Company.fromMap(Map<String, dynamic> map) {
    return Company(
      id: map['id']?.toInt() ?? 0,
      companyName: map['companyName'] ?? '',
      comapyAddress: map['comapyAddress'] ?? '',
      copanyImagUrl: map['copanyImagUrl'] ?? '',
      companyCode: map['companyCode']?.toInt() ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Company.fromJson(String source) =>
      Company.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Company(id: $id, companyName: $companyName, comapyAddress: $comapyAddress, copanyImagUrl: $copanyImagUrl, companyCode: $companyCode, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Company &&
        other.id == id &&
        other.companyName == companyName &&
        other.comapyAddress == comapyAddress &&
        other.copanyImagUrl == copanyImagUrl &&
        other.companyCode == companyCode &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        companyName.hashCode ^
        comapyAddress.hashCode ^
        copanyImagUrl.hashCode ^
        companyCode.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
