import 'cuahang_model.dart';

class StoreMockData {
  static List<Store> generateMockStores() {
    return [
      Store(
        name: 'Nhà hàng 1',
        ownerName: 'Nguyễn Văn A',
        phone: '0123456789',
        branchNumber: 1,
        address: 'Quận 1, TP.HCM',
        foundedDate: DateTime(2023, 1, 15),
      ),
      Store(
        name: 'Nhà hàng 2',
        ownerName: 'Trần Thị B',
        phone: '0987654321',
        branchNumber: 2,
        address: 'Quận 2, TP.HCM',
        foundedDate: DateTime(2023, 2, 20),
      ),
      Store(
        name: 'Nhà hàng 3',
        ownerName: 'Lê Văn C',
        phone: '0912345678',
        branchNumber: 1,
        address: 'Quận 3, TP.HCM',
        foundedDate: DateTime(2023, 3, 10),
      ),
    ];
  }

  // Generate a specific number of mock stores
  static List<Store> generateCustomMockStores(int count) {
    return List.generate(count, (index) {
      return Store(
        name: 'Nhà hàng ${index + 1}',
        ownerName: 'Chủ nhà hàng ${index + 1}',
        phone: '090${1000000 + index}',
        branchNumber: index % 3 + 1,
        address: 'Địa chỉ ${index + 1}, TP.HCM',
        foundedDate: DateTime.now().subtract(Duration(days: index * 30)),
      );
    });
  }
}
