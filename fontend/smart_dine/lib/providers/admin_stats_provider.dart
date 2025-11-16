import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final adminStatsProvider = FutureProvider<AdminStats>((ref) async {
  final url = Uri.parse(
    "https://smartdine-backend-oq2x.onrender.com/api/admin/stats",
  );

  final response = await http.get(url);

  if (response.statusCode != 200) {
    throw Exception("Không tải được thống kê");
  }

  final data = json.decode(response.body);

  return AdminStats.fromJson(data["data"]);
});

class AdminStats {
  final int totalCompanies;
  final int totalBranches;

  AdminStats({required this.totalCompanies, required this.totalBranches});

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalCompanies: json["totalCompanies"],
      totalBranches: json["totalBranches"],
    );
  }
}
