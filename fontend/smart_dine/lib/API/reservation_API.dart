import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mart_dine/models/reservation.dart';

class ReservationApi {
  final String baseUrl =
      'https://smartdine-backend-oq2x.onrender.com/api/reservations';

  Future<Reservation> createReservation(
    Map<String, dynamic> reservationData,
    List<int> tableIds,
  ) async {
    final url = Uri.parse(
      baseUrl,
    ); // <-- Sửa lại endpoint đúng là /api/reservations
    final body = jsonEncode({
      'reservation': reservationData,
      'tableIds': tableIds,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Reservation.fromJson(data['reservation']);
    } else {
      throw Exception('Failed to create reservation: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getReservedTablesByBranch(int branchId) async {
    final url = Uri.parse('$baseUrl/reserved-tables/branch/$branchId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get reserved tables: ${response.body}');
    }
  }

  Future<void> updateReservationStatus(int reservationId, int statusId) async {
    final url = Uri.parse('$baseUrl/$reservationId/status');
    final body = jsonEncode({'statusId': statusId});

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update reservation status: ${response.body}');
    }
  }
}

final reservationApiProvider = Provider((ref) => ReservationApi());
