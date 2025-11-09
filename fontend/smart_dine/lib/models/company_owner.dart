class CompanyOwner {
  final int? companyId;
  final String companyName;
  final String companyCode;
  final String address;
  final String? image;
  final int? statusId;

  final int? userId;
  final String ownerName;
  final String phoneNumber;

  bool isActive;

  CompanyOwner({
    this.companyId,
    required this.companyName,
    required this.companyCode,
    required this.address,
    this.image,
    this.statusId,
    this.userId,
    required this.ownerName,
    required this.phoneNumber,
    this.isActive = true,
  });

  factory CompanyOwner.fromMap(Map<String, dynamic> map) {
    return CompanyOwner(
      companyId: map['companyId'] ?? map['id'],
      companyName: map['companyName'] ?? '',
      companyCode: map['companyCode'] ?? '',
      address: map['address'] ?? '',
      image: map['image'],
      statusId: map['statusId'],
      userId: map['userId'],
      ownerName: map['ownerName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
    'companyId': companyId,
    'companyName': companyName,
    'companyCode': companyCode,
    'address': address,
    'image': image,
    'statusId': statusId,
    'userId': userId,
    'ownerName': ownerName,
    'phoneNumber': phoneNumber,
    'isActive': isActive,
  };
}
