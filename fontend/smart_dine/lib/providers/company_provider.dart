import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/API/company_API.dart';
import 'package:mart_dine/API/user_API.dart';
import 'package:mart_dine/models/company.dart';

class CompanyNotifier extends StateNotifier<Company?> {
  //Lấy Data từ company API
  final CompanyAPI companyAPI;
  final UserAPI userAPI;

  //Constructor
  CompanyNotifier(this.companyAPI, this.userAPI) : super(null);

  // Đăng ký user
  Future<int> signUpComapny(Company company, int userId) async {
    try {
      final response = await companyAPI.createCompany(company);
      if (response != null) {
        state = response;
        print('🔍 [CompanyNotifier] Created company: ${response.toMap()}');
        //Cập nhật companyId cho user
        await userAPI.updateCompanyId(userId, response.id!);
        return 1;
      }
    } catch (e) {
      return 0;
    }
    return 0;
  }
}

final companyNotifierProvider =
    StateNotifierProvider<CompanyNotifier, Company?>((ref) {
      return CompanyNotifier(
        ref.read(companyApiProvider),
        ref.read(userApiProvider),
      );
    });
