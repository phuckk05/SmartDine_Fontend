// file: screens/screen_add_restaurant.dart
// ĐÃ CẬP NHẬT: Giữ logic "Thêm Chi Nhánh"
// Áp dụng giao diện (style) của màn hình "Đăng Ký"
import 'dart:io'; // THÊM: Để xử lý file ảnh

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; // THÊM: Thư viện chọn ảnh
import 'package:mart_dine/core/constrats.dart' show ShadowCus, kTextColorDark;
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/models_owner/branch.dart';
import 'package:mart_dine/API_owner/branch_API.dart';
import 'package:mart_dine/API_owner/cloudinary_API.dart'; // THÊM: Import Cloudinary API
import 'package:mart_dine/providers_owner/system_stats_provider.dart';
import 'package:mart_dine/providers_owner/staff_profile_provider.dart';
import 'package:mart_dine/models_owner/staff_profile.dart';
import 'package:mart_dine/providers_owner/target_provider.dart';

class ScreenAddRestaurant extends ConsumerStatefulWidget {
  const ScreenAddRestaurant({super.key});
  @override
  ConsumerState<ScreenAddRestaurant> createState() => _ScreenAddRestaurantState();
}

class _ScreenAddRestaurantState extends ConsumerState<ScreenAddRestaurant> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _branchCodeCtrl = TextEditingController();
  bool _isLoading = false;
  int? _selectedManagerId; // State để lưu ID quản lý được chọn
  File? _imageFile; // THÊM: State để lưu file ảnh được chọn
  final ImagePicker _picker = ImagePicker(); // THÊM: Khởi tạo image picker

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _branchCodeCtrl.dispose();
    super.dispose();
  }

  // THÊM: Hàm chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // SỬA: Tích hợp Cloudinary API để tải ảnh lên và lấy URL.
  Future<String> _uploadImage(File imageFile) async {
    // Hiển thị loading ngay khi bắt đầu upload
    setState(() => _isLoading = true);
    try {
      final cloudinaryApi = CloudinaryAPI();
      final imageUrl = await cloudinaryApi.getURL(imageFile);
      return imageUrl;
    } catch (e) {
      // Nếu có lỗi, dừng loading và hiển thị thông báo
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi tải ảnh lên: $e")));
      }
      // Ném lại lỗi để hàm _saveRestaurant biết và dừng lại
      throw Exception("Lỗi tải ảnh.");
    }
  }

  // Hàm gọi API để lưu chi nhánh
  void _saveRestaurant() async {
    if (_formKey.currentState!.validate() && !_isLoading) {
      final companyId = (await ref.read(ownerProfileProvider.future)).companyId;

      if (companyId == null || _selectedManagerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lỗi: Không thể xác định công ty hoặc quản lý.")),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Bắt đầu trạng thái loading chung
      setState(() => _isLoading = true);

      String imageUrl = '';
      try {
        if (_imageFile != null) {
          imageUrl = await _uploadImage(_imageFile!);
        }
      } catch (e) { // Bắt lỗi từ _uploadImage
        setState(() => _isLoading = false); // Dừng loading nếu upload lỗi
        return; // Không tiếp tục thực hiện
      }

      final newBranch = Branch(
        id: 0, // Backend sẽ gán ID
        companyId: companyId, // Lấy companyId thật
        name: _nameCtrl.text.trim(),
        branchCode: _branchCodeCtrl.text.trim(),
        address: _addressCtrl.text.trim(), // SỬA: Cập nhật URL ảnh
        image: imageUrl, // Lưu đường dẫn ảnh hoặc URL (nếu có)
        phone: 'N/A', // Lấy từ input khác nếu cần
        statusId: 1, // SỬA: 1 = Đã duyệt
        managerId: _selectedManagerId!,
        createdAt: DateTime.now(), // Backend có thể tự set
        updatedAt: DateTime.now(), // Backend có thể tự set
      );

      try {
        final apiService = ref.read(branchApiProvider);
        final createdBranch = await apiService.createBranch(newBranch); // Gọi API

        // Refresh lại FutureProvider để cập nhật danh sách ở ScreenManagement
        ref.invalidate(branchesByCompanyProvider(companyId));
        ref.invalidate(branchListProvider); // THÊM: Invalidate danh sách tổng
        if (mounted) { // Kiểm tra widget còn tồn tại không
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text("Đã thêm và duyệt chi nhánh: ${createdBranch.name}")),
           );
           Navigator.pop(context); // Quay lại ScreenManagement
        }
      } catch (e) {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text("Lỗi thêm chi nhánh: $e")),
           );
         }
      } finally {
        // Dừng loading dù thành công hay lỗi
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  // Widget helper tạo TextField với style thống nhất
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ShadowCus( // Giả định ShadowCus tồn tại
          isConcave: true, // Giả định thuộc tính này
          borderRadius: 10,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              icon: Icon(icon, color: Colors.grey.shade600),
              hintText: 'Nhập $label',
              border: InputBorder.none,
              isDense: true,
            ),
            style: const TextStyle(fontSize: 16, color: kTextColorDark),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final staffListAsync = ref.watch(staffProfileProvider);
    // THÊM: Lấy thông tin owner để có companyId cho việc lọc quản lý
    final ownerAsync = ref.watch(ownerProfileProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar( // Sử dụng AppBar tiêu chuẩn
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Thêm Chi Nhánh Mới', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: Style.paddingPhone),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _buildTextField(label: 'Tên nhà hàng', controller: _nameCtrl, icon: Icons.storefront_outlined, validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập tên' : null),
                _buildTextField(label: 'Mã chi nhánh', controller: _branchCodeCtrl, icon: Icons.qr_code_2_outlined, validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập mã' : null),
                _buildTextField(label: 'Địa chỉ', controller: _addressCtrl, icon: Icons.location_on_outlined, validator: (v) => v == null || v.trim().isEmpty ? 'Vui lòng nhập địa chỉ' : null),
                
                // Dropdown chọn quản lý
                const Text('Giấy phép kinh doanh', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickImage,
                  child: ShadowCus(
                    borderRadius: 10,
                    padding: const EdgeInsets.all(10),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade400, width: 1, style: BorderStyle.solid),
                        ),
                        child: _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _imageFile!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: Colors.grey.shade600,
                                    size: 40,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Chạm để thêm ảnh',
                                    style: TextStyle(color: Colors.grey.shade700),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),


                const Text('Chọn người phụ trách', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                staffListAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text('Lỗi tải danh sách quản lý: $err'),
                  data: (staffList) {
                    // SỬA: Lọc tất cả nhân viên trong công ty, trừ Owner và Admin
                    final loggedInCompanyId = ownerAsync.value?.companyId;
                    final assignableStaff = staffList.where((s) {
                      final roleCode = s.role.code.toUpperCase();
                      // Chỉ lấy những người có vai trò không phải là OWNER hoặc ADMIN
                      final isAssignable = roleCode != 'OWNER' && roleCode != 'ADMIN';
                      final isInCompany = s.user.companyId == loggedInCompanyId;
                      return isAssignable && isInCompany;
                    }).toList();

                    return ShadowCus(
                      isConcave: true, borderRadius: 10,
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: DropdownButtonFormField<int>(
                        value: _selectedManagerId,
                        isExpanded: true, // SỬA: Thêm để Dropdown chiếm hết chiều rộng
                        items: assignableStaff.map((StaffProfile profile) {
                          return DropdownMenuItem<int>(
                            value: profile.user.id,
                            child: Text(profile.user.fullName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedManagerId = value;
                          });
                        },
                        decoration: InputDecoration(
                          icon: Icon(Icons.person_outline, color: Colors.grey.shade600),
                          hintText: 'Chọn người phụ trách chi nhánh',
                          border: InputBorder.none,
                        ),
                        validator: (value) => value == null ? 'Vui lòng chọn người phụ trách' : null,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveRestaurant, // Disable nút khi đang loading
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    // Hiển thị loading indicator hoặc text "Thêm Chi Nhánh"
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                        : const Text('Thêm Chi Nhánh', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ----- Các Widget Helper Giả định (Cần có trong project của bạn) -----
class ShadowCus extends StatelessWidget {
  final Widget child; final double borderRadius; final EdgeInsetsGeometry padding;
  final Color baseColor; final bool isConcave; final Border? border; // Thêm border
  const ShadowCus({ super.key, required this.child, this.borderRadius = 0.0, this.padding = EdgeInsets.zero, this.baseColor = Colors.white, this.isConcave = false, this.border});
  @override Widget build(BuildContext context) {
    return Container( padding: padding, decoration: BoxDecoration( color: baseColor, borderRadius: BorderRadius.circular(borderRadius), border: border, boxShadow: [ BoxShadow( color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 1))]), child: child );
  }
}
class Style { static const double paddingPhone = 16.0; static const TextStyle TextButton = TextStyle(color: Colors.white, fontWeight: FontWeight.bold); }
class AppBarCus extends StatelessWidget implements PreferredSizeWidget { final String title; final List<Widget>? actions; final bool? isCanpop; const AppBarCus({super.key, required this.title, this.actions, this.isCanpop}); @override Widget build(BuildContext context) { return AppBar(title: Text(title, style: const TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black), actions: actions, automaticallyImplyLeading: isCanpop ?? true, ); } @override Size get preferredSize => const Size.fromHeight(kToolbarHeight); }
// Giả định kTextColorDark, kTextColorLight được định nghĩa ở đâu đó
const Color kTextColorDark = Colors.black87;
const Color kTextColorLight = Colors.black54;