import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/API_staff/company_API.dart';
import 'package:mart_dine/model_staff/company.dart';

class CompanyNotifier extends StateNotifier<Company?> {
  //Lấy Data từ company API
  final CompanyAPI companyAPI;

  Set<Company?> build() {
    return const {};
  }

  // Đăng ký user
  Future<int> signUpComapny(Company company, int userId) async {
    print("company $company - id $userId");
    try {
      final response = await companyAPI.createCompany(company);
      if (response != null) {
        state = response;
        return 1;
      }
    } catch (e) {
      print('Lỗi tạo company :  $e');
      return 0;
    }
    return 0;
  }

  //Constructor
  CompanyNotifier(this.companyAPI) : super(null);
}

final companyNotifierProvider =
    StateNotifierProvider<CompanyNotifier, Company?>((ref) {
      return CompanyNotifier(ref.read(companyApiProvider));
    });
