import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/company_owner_API.dart';
import '../models/company_owner.dart';

/// Provider cho API
final companyOwnerApiProvider = Provider<CompanyOwnerAPI>((ref) {
  return CompanyOwnerAPI();
});

/// Provider danh sách công ty
final companyOwnerListProvider = FutureProvider.autoDispose<List<CompanyOwner>>(
  (ref) async {
    final api = ref.read(companyOwnerApiProvider);
    return api.getCompanyOwners();
  },
);
