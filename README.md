# Mô tả dự án: SmartServe RMS
# I. Giới thiệu chung

SmartServe RMS (Restaurant Management System) là hệ thống quản lý vận hành nhà hàng được phát triển nhằm tối ưu hóa toàn bộ quy trình từ phục vụ, đặt món, thanh toán đến quản lý dữ liệu kinh doanh.
Giải pháp hướng đến việc nâng cao hiệu suất hoạt động, giảm sai sót thủ công và cải thiện trải nghiệm khách hàng thông qua giao diện di động hiện đại.

# Dự án gồm hai phần chính:

Ứng dụng di động (Mobile App) – Dành cho nhân viên, thu ngân, bếp và quản lý chi nhánh.

Hệ thống Backend (API Server) – Xử lý logic, quản lý dữ liệu và phân quyền người dùng.

# II. Phần 1: Ứng dụng di động (Frontend)
# 1.1. Công nghệ sử dụng

 Ngôn ngữ: Dart

Framework: Flutter

Nền tảng: Android / iOS

Môi trường phát triển: Android Studio / VS Code

# 1.2. Vai trò

Ứng dụng mobile đóng vai trò là giao diện tương tác trực tiếp giữa người dùng và hệ thống, hỗ trợ nhiều nhóm người dùng trong nhà hàng:

Nhân viên phục vụ (Staff): Nhận order, ghi món, gửi bếp.

Thu ngân (Cashier): Tính tiền, áp dụng khuyến mãi, in hóa đơn.

Quản lý chi nhánh (Manager): Theo dõi hoạt động chi nhánh, xem báo cáo.

Chủ nhà hàng (Owner): Quản lý tổng thể các chi nhánh, doanh thu.

Bếp (Kitchen): Nhận và xử lý món từ nhân viên phục vụ theo thời gian thực.

# 1.3. Các chức năng chính

Đặt món và tạo đơn hàng:
Nhân viên có thể tạo đơn hàng mới, chọn món theo danh mục, tùy chỉnh số lượng và ghi chú.

Quét mã bàn hoặc chọn bàn:
Sử dụng mã QR để nhận diện bàn ăn, giảm sai sót khi ghi order.

Gửi order đến bếp:
Món được đồng bộ ngay với thiết bị bếp thông qua hệ thống backend.

Thanh toán và in hóa đơn:
Hỗ trợ thanh toán bằng tiền mặt, thẻ, chuyển khoản hoặc ví điện tử, đồng thời in hóa đơn nhanh.

Xem lịch sử đơn hàng:
Theo dõi chi tiết hóa đơn đã thanh toán hoặc đang phục vụ.

Nhận thông báo theo thời gian thực:
Thông báo từ bếp (món hoàn thành) hoặc từ quản lý (thông báo nội bộ).

Phân quyền người dùng:
Giao diện và chức năng được hiển thị tùy theo vai trò đăng nhập.

# III. Phần 2: Hệ thống Backend (API Server)
# 2.1. Công nghệ sử dụng

Ngôn ngữ: Java

Framework: Spring Boot, Spring Data JPA

Cơ sở dữ liệu: Supabase (PostgreSQL)

Triển khai: Render (Cloud Hosting)

API: RESTful API

# 2.2. Vai trò

Backend là trung tâm xử lý logic nghiệp vụ, chịu trách nhiệm:

Kết nối, lưu trữ và truy xuất dữ liệu từ Supabase.

Quản lý xác thực, phân quyền và bảo mật người dùng.

Cung cấp API cho ứng dụng di động giao tiếp.

Xử lý quy trình nghiệp vụ phức tạp như order, thanh toán, khuyến mãi và ca làm.

# 2.3. Các chức năng chính

Quản lý người dùng và phân quyền:
Các vai trò gồm Admin, Manager, Cashier, Staff, Chef.

Quản lý menu và danh mục món:
Cho phép thêm, sửa, xóa món ăn, danh mục và trạng thái hoạt động.

Xử lý đơn hàng:
Tạo, cập nhật, thanh toán, hủy đơn; theo dõi trạng thái món (đang chế biến, hoàn tất, phục vụ).

Quản lý thanh toán và giảm giá:
Hỗ trợ nhiều phương thức thanh toán và mã giảm giá theo từng chi nhánh hoặc công ty.

Quản lý công ty và chi nhánh:
Mỗi công ty có thể sở hữu nhiều chi nhánh, dữ liệu được tách biệt nhưng vẫn có thể tổng hợp theo cấp chủ nhà hàng.

Báo cáo và thống kê:
Tổng hợp doanh thu, số lượng đơn, món bán chạy, khung giờ cao điểm.

Bảo mật hệ thống:
Sử dụng JWT Authentication, xác thực bằng token và phân quyền chi tiết theo từng người dùng.
  
# IV. Tổng kết

SmartServe RMS là hệ thống quản lý nhà hàng toàn diện, được thiết kế với:

Ứng dụng di động Flutter cho trải nghiệm người dùng mượt mà, thao tác nhanh.

Backend Spring Boot mạnh mẽ, bảo mật, dễ mở rộng.

Cơ sở dữ liệu Supabase (PostgreSQL) linh hoạt và đáng tin cậy.

Hạ tầng triển khai Render Cloud giúp mở rộng dễ dàng.

Hệ thống hướng đến mục tiêu số hóa quy trình vận hành nhà hàng, giúp quản lý hiệu quả, tiết kiệm chi phí và nâng cao trải nghiệm phục vụ khách hàng.
