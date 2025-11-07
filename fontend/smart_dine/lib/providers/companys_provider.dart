import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/API/company_API.dart';
import 'package:mart_dine/models/company.dart';

class CompanysNotifier extends StateNotifier<List<Company>> {
  final CompanyAPI companyAPI;
  CompanysNotifier(this.companyAPI) : super([]);

  List<Company> build() {
    return state;
  }

  // Lấy tất cả các công ty
  Future<void> fetchCompanys() async {
    final companys = await companyAPI.getAllCompanys();
    state = companys;
  }
}

final companysNotifierProvider =
    StateNotifierProvider<CompanysNotifier, List<Company>>((ref) {
      return CompanysNotifier(ref.read(companyApiProvider));
    });
