import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/cuahang_model.dart';
import '../../models/cuahang_data.dart';

class StoreService {
  // Simulated asynchronous operations
  Future<List<Store>> fetchStores() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return StoreMockData.generateMockStores();
  }

  Future<Store> createStore(Store store) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Validate store
    if (!store.isValid) {
      throw Exception('Invalid store details');
    }

    return store;
  }

  Future<Store> updateStore(Store store) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Validate store
    if (!store.isValid) {
      throw Exception('Invalid store details');
    }

    return store;
  }

  Future<void> deleteStore(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Simulated deletion process
  }

  Future<void> deleteAllStores() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Simulated bulk deletion process
  }
}

// Provider for the service
final storeServiceProvider = Provider<StoreService>((ref) {
  return StoreService();
});
