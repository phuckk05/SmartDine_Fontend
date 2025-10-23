import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/style.dart';

// Model cho chi tiết nhà hàng
class StoreDetail {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String code;
  final DateTime establishDate;
  final int totalBranches;
  final int totalEmployees;
  final String servicePackage;
  final List<String> licenseImages;
  bool isActive;

  StoreDetail({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.code,
    required this.establishDate,
    required this.totalBranches,
    required this.totalEmployees,
    required this.servicePackage,
    required this.licenseImages,
    this.isActive = false,
  });
}

// Provider cho store detail
final storeDetailProvider =
    StateNotifierProvider<StoreDetailNotifier, StoreDetail?>((ref) {
      return StoreDetailNotifier();
    });

class StoreDetailNotifier extends StateNotifier<StoreDetail?> {
  StoreDetailNotifier() : super(null);

  void loadStore(String id) {
    // Mock data
    state = StoreDetail(
      id: id,
      name: 'Restaurant GGM',
      email: 'phuck3242@gmail.com',
      phone: '32435345345',
      code: 'GGM-234234',
      establishDate: DateTime(2023, 4, 24),
      totalBranches: 4,
      totalEmployees: 43,
      servicePackage: 'free',
      licenseImages: ['assets/license1.jpg', 'assets/license2.jpg'],
      isActive: false,
    );
  }

  void toggleActivation() {
    if (state != null) {
      state = StoreDetail(
        id: state!.id,
        name: state!.name,
        email: state!.email,
        phone: state!.phone,
        code: state!.code,
        establishDate: state!.establishDate,
        totalBranches: state!.totalBranches,
        totalEmployees: state!.totalEmployees,
        servicePackage: state!.servicePackage,
        licenseImages: state!.licenseImages,
        isActive: !state!.isActive,
      );
    }
  }
}

class StoreDetailScreen extends ConsumerStatefulWidget {
  final String storeId;

  const StoreDetailScreen({super.key, required this.storeId});

  @override
  ConsumerState<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends ConsumerState<StoreDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(storeDetailProvider.notifier).loadStore(widget.storeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(storeDetailProvider);

    if (store == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Style.backgroundColor,
      appBar: AppBar(
        title: Text('Hồ sơ', style: Style.fontTitleMini.copyWith(fontSize: 18)),
        backgroundColor: Style.colorLight,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Style.textColorBlack),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Style.spacingMedium),

            // Thông tin nhà hàng
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Style.paddingPhone,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Thông tin nhà hàng', style: Style.fontTitleMini),
                  const SizedBox(height: Style.spacingSmall),
                  Text(store.name, style: Style.fontTitle),
                  const SizedBox(height: Style.spacingMedium),

                  // Info box
                  Container(
                    padding: const EdgeInsets.all(Style.paddingPhone),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(Style.borderRadius),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.email, store.email),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.phone, store.phone),
                        const SizedBox(height: 12),
                        _buildInfoRowText('Mã nhà hàng', store.code),
                        const SizedBox(height: 12),
                        _buildInfoRowText(
                          'Ngày thành lập',
                          '${store.establishDate.day.toString().padLeft(2, '0')}-${store.establishDate.month.toString().padLeft(2, '0')}-${store.establishDate.year}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: Style.spacingLarge),

            // Hệ thống & hoạt động
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Style.paddingPhone,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hệ thống & hoạt động', style: Style.fontTitleMini),
                  const SizedBox(height: Style.spacingSmall),
                  Container(
                    padding: const EdgeInsets.all(Style.paddingPhone),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(Style.borderRadius),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRowText(
                          'Tổng số chi nhánh hiện tại',
                          store.totalBranches.toString(),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRowText(
                          'Tổng số nhân viên',
                          store.totalEmployees.toString(),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRowText(
                          'Gói dịch vụ đang sử dụng',
                          store.servicePackage,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: Style.spacingLarge),

            // Giấy phép kinh doanh
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Style.paddingPhone,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Giấy phép kinh doanh', style: Style.fontTitleMini),
                  const SizedBox(height: 4),
                  Text(
                    'Giấy phép kinh doanh chi nhánh ${store.code}',
                    style: Style.fontCaption,
                  ),
                  const SizedBox(height: 12),

                  // License images
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.amber[100],
                            borderRadius: BorderRadius.circular(
                              Style.borderRadius,
                            ),
                            border: Border.all(color: Colors.brown, width: 3),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.description,
                              size: 60,
                              color: Colors.brown[300],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.amber[100],
                            borderRadius: BorderRadius.circular(
                              Style.borderRadius,
                            ),
                            border: Border.all(color: Colors.brown, width: 3),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.description,
                              size: 60,
                              color: Colors.brown[300],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: Style.spacingLarge),

            // Trạng thái
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Style.paddingPhone,
              ),
              child: Row(
                children: [
                  Text('Trạng thái', style: Style.fontTitleSuperMini),
                  const SizedBox(width: Style.spacingMedium),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Style.paddingPhone,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: store.isActive ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      store.isActive ? 'Đã kích hoạt' : 'Chưa kích hoạt',
                      style: Style.fontCaption.copyWith(
                        color: Style.textColorWhite,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: Style.spacingLarge),

            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Style.paddingPhone,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _showActivationDialog(context, store.isActive);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Style.textColorWhite,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            Style.borderRadius,
                          ),
                        ),
                      ),
                      child: Text(
                        store.isActive ? 'Vô hiệu hóa' : 'Kích hoạt',
                        style: Style.fontButton,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            Style.borderRadius,
                          ),
                        ),
                      ),
                      child: Text(
                        'Hủy',
                        style: Style.fontButton.copyWith(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: Style.spacingExtraLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: Style.iconSize, color: Style.textColorBlack),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: Style.fontNormal)),
      ],
    );
  }

  Widget _buildInfoRowText(String label, String value) {
    return Row(
      children: [
        Expanded(flex: 2, child: Text(label, style: Style.fontNormal)),
        Expanded(flex: 1, child: Text(value, style: Style.fontTitleSuperMini)),
      ],
    );
  }

  void _showActivationDialog(BuildContext context, bool isActive) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              isActive ? 'Vô hiệu hóa tài khoản' : 'Kích hoạt tài khoản',
              style: Style.fontTitleMini,
            ),
            content: Text(
              isActive
                  ? 'Bạn có chắc muốn vô hiệu hóa tài khoản này?'
                  : 'Bạn có chắc muốn kích hoạt tài khoản này?',
              style: Style.fontNormal,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Hủy',
                  style: Style.fontButton.copyWith(color: Style.textColorGray),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  ref.read(storeDetailProvider.notifier).toggleActivation();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isActive
                            ? 'Đã vô hiệu hóa tài khoản'
                            : 'Đã kích hoạt tài khoản thành công',
                        style: Style.fontNormal.copyWith(
                          color: Style.textColorWhite,
                        ),
                      ),
                      backgroundColor: isActive ? Colors.red : Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isActive ? Colors.red : Colors.blue,
                ),
                child: Text(
                  isActive ? 'Vô hiệu hóa' : 'Kích hoạt',
                  style: Style.fontButton,
                ),
              ),
            ],
          ),
    );
  }
}
