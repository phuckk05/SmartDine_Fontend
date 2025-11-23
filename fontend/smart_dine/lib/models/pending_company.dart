class PendingCompany {
  final int companyId;
  final String companyName;
  final String companyCode;
  final String address;
  final String createdAt;
  final String updatedAt;
  final String companyStatus;

  final int userId;
  final String fullName;
  final String email;
  final String phone;
  final String phoneNumber;

  final String frontImage;
  final String backImage;
  final String ownerStatus;

  PendingCompany({
    required this.companyId,
    required this.companyName,
    required this.companyCode,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
    required this.companyStatus,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.phoneNumber,
    required this.frontImage,
    required this.backImage,
    required this.ownerStatus,
  });

  factory PendingCompany.fromJson(Map<String, dynamic> json) {
    return PendingCompany(
      companyId: json['companyId'],
      companyName: json['companyName'],
      companyCode: json['companyCode'],
      address: json['address'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      companyStatus: json['companyStatus'],
      userId: json['userId'],
      fullName: json['fullName'],
      email: json['email'],
      phone: json['phone'],
      phoneNumber: json['phoneNumber'],
      frontImage: json['frontImage'] ?? "",
      backImage: json['backImage'] ?? "",
      ownerStatus: json['ownerStatus'] ?? "",
    );
  }
}
