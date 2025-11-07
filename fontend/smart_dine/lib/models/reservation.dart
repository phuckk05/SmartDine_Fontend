class Reservation {
  final int? id;
  final int branchId;
  final String customerName;
  final String customerEmail;
  final DateTime? reservedTime;
  final int numberOfGuests;
  final DateTime? reservedDay;
  final int statusId;
  final String? note;

  Reservation({
    this.id,
    required this.branchId,
    required this.customerName,
    required this.customerEmail,
    this.reservedTime,
    required this.numberOfGuests,
    this.reservedDay,
    required this.statusId,
    this.note,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      branchId: json['branchId'],
      customerName: json['customerName'],
      customerEmail: json['customerEmail'],
      reservedTime:
          json['reservedTime'] != null
              ? DateTime.parse(json['reservedTime'])
              : null,
      numberOfGuests: json['numberOfGuests'],
      reservedDay:
          json['reservedDay'] != null
              ? DateTime.parse(json['reservedDay'])
              : null,
      statusId: json['statusId'],
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branchId': branchId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'reservedTime': reservedTime?.toIso8601String(),
      'numberOfGuests': numberOfGuests,
      'reservedDay': reservedDay?.toIso8601String(),
      'statusId': statusId,
      'note': note,
    };
  }
}
