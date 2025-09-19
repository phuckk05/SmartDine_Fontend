Mô tả dự án: SmartServe RMS
SmartServe RMS là hệ thống quản lý vận hành nhà hàng (Restaurant Management System) được thiết kế để tối ưu hóa quy trình phục vụ, thanh toán và quản lý. Dự án gồm 3 phần chính:

Frontend (Mobile App – Flutter)
Ngôn ngữ: Dart

Nền tảng: Flutter (Android/iOS)

Vai trò: Giao diện cho nhân viên và thu ngân

Chức năng chính:

Đặt món, tạo đơn hàng

Quét mã bàn hoặc chọn bàn

Thanh toán và in hóa đơn

Xem lịch sử đơn hàng

Nhận thông báo từ bếp hoặc quản lý

App được thiết kế tối ưu cho thao tác nhanh, giao diện thân thiện với người dùng.
Backend (Spring Boot)
Ngôn ngữ: Java

Framework: Spring Boot + Spring Data JPA

Database: Supabase (PostgreSQL)

Triển khai: Render (Cloud Hosting)

Chức năng chính:

Cung cấp RESTful API cho mobile và web

Quản lý người dùng theo role: admin, manager, cashier, staff

Xử lý logic đơn hàng, menu, thanh toán

Kết nối database Supabase để lưu trữ dữ liệu

Bảo mật API theo phân quyền

Backend là trung tâm xử lý logic, đảm bảo dữ liệu chính xác và bảo mật.

Web Admin (Spring Boot + Thymeleaf hoặc React)
Vai trò: Giao diện quản trị cho admin và manager

Chức năng chính:

Quản lý thực đơn: thêm, sửa, xóa món ăn

Quản lý nhân viên và phân quyền

Xem báo cáo doanh thu, món bán chạy

Theo dõi tồn kho và cảnh báo nguyên liệu

Cấu hình hệ thống, khuyến mãi, ca làm
