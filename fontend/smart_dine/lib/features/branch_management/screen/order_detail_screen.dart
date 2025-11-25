import 'package:flutter/material.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/widgets/appbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/order_management_provider.dart';
import '../../../providers/user_session_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';

class OrderDetailScreen extends ConsumerWidget {
  final int orderId;
  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  Future<void> _generateInvoicePdf(BuildContext context, dynamic order) async {
    final pdf = pw.Document();

    // Load custom font for Vietnamese support
    final fontData = await rootBundle.load('assets/fonts/NotoSans-Regular.woff2');
    final vietnameseFont = pw.Font.ttf(fontData);

    // Create bold version using the same font (PDF library limitation)
    final vietnameseBoldFont = pw.Font.ttf(fontData);

    // Fallback fonts for better compatibility
    final fallbackFonts = [
      pw.Font.times(),
      pw.Font.courier(),
      pw.Font.helvetica(),
    ];

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('HÓA ĐƠN', style: pw.TextStyle(fontSize: 24, font: vietnameseBoldFont, fontFallback: fallbackFonts)),
              pw.SizedBox(height: 20),
              pw.Text('Mã đơn: ${order.id ?? ''}', style: pw.TextStyle(font: vietnameseFont, fontFallback: fallbackFonts)),
              pw.Text('Chi nhánh: ${order.branchId ?? ''}', style: pw.TextStyle(font: vietnameseFont, fontFallback: fallbackFonts)),
              pw.Text('Ngày tạo: ${order.getFormattedDate()}', style: pw.TextStyle(font: vietnameseFont, fontFallback: fallbackFonts)),
              pw.Text('Bàn: ${order.getTableDisplayName()}', style: pw.TextStyle(font: vietnameseFont, fontFallback: fallbackFonts)),
              pw.Text('Nhân viên: ${order.userName ?? ''}', style: pw.TextStyle(font: vietnameseFont, fontFallback: fallbackFonts)),
              pw.Text('Trạng thái: ${_getPaymentStatusName(order.statusId)}', style: pw.TextStyle(font: vietnameseFont, fontFallback: fallbackFonts)),
              pw.SizedBox(height: 20),
              pw.Text('Danh sách món:', style: pw.TextStyle(font: vietnameseBoldFont, fontFallback: fallbackFonts)),
              pw.SizedBox(height: 10),
              if (order.items?.isNotEmpty == true)
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Text('Tên món', style: pw.TextStyle(font: vietnameseBoldFont, fontFallback: fallbackFonts)),
                        pw.Text('SL', style: pw.TextStyle(font: vietnameseBoldFont, fontFallback: fallbackFonts)),
                        pw.Text('Giá', style: pw.TextStyle(font: vietnameseBoldFont, fontFallback: fallbackFonts)),
                        pw.Text('Thành tiền', style: pw.TextStyle(font: vietnameseBoldFont, fontFallback: fallbackFonts)),
                      ],
                    ),
                    ...order.items!.map<pw.TableRow>((item) {
                      final price = item.itemPrice ?? 0;
                      final quantity = item.quantity ?? 0;
                      final total = price * quantity;
                      return pw.TableRow(
                        children: [
                          pw.Text(item.itemName ?? 'Món ${item.itemId}', style: pw.TextStyle(font: vietnameseFont, fontFallback: fallbackFonts)),
                          pw.Text('$quantity', style: pw.TextStyle(font: vietnameseFont, fontFallback: fallbackFonts)),
                          pw.Text('${price.toStringAsFixed(0)}đ', style: pw.TextStyle(font: vietnameseFont, fontFallback: fallbackFonts)),
                          pw.Text('${total.toStringAsFixed(0)}đ', style: pw.TextStyle(font: vietnameseFont, fontFallback: fallbackFonts)),
                        ],
                      );
                    }),
                  ],
                ),
              pw.SizedBox(height: 20),
              pw.Text('Tổng tiền: ${order.totalAmount ?? 0}đ', style: pw.TextStyle(font: vietnameseBoldFont, fontFallback: fallbackFonts)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Style.colorLight : Style.colorDark;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;

    final orderAsync = ref.watch(orderWithItemsProvider(orderId));

    return orderAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Lỗi: $error')),
      ),
      data: (order) {
        if (order == null) {
          return const Scaffold(
            body: Center(child: Text('Không tìm thấy dữ liệu đơn hàng')),
          );
        }
        return Scaffold(
          backgroundColor: isDark ? Colors.grey[850] : Style.backgroundColor,
          appBar: AppBarCus(
            title: 'Chi tiết đơn hàng',
            isCanpop: true,
            isButtonEnabled: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chi nhánh card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Chi nhánh ${order.branchId ?? ref.read(currentBranchIdProvider) ?? "N/A"}',
                              style: Style.fontTitleMini.copyWith(color: textColor),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue),
                            ),
                            child: Text(
                              _getPaymentStatusName(order.statusId),
                              style: Style.fontCaption.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Mã đơn:', order.id?.toString() ?? '', textColor),
                      _buildInfoRow('Tạo ngày:', order.getFormattedDate(), textColor),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Thông tin bàn
                Text(
                  'Thông tin bàn',
                  style: Style.fontTitleMini.copyWith(color: textColor),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('Bàn', order.getTableDisplayName(), textColor),
                      _buildInfoRow('Nhân viên phục vụ', order.userName ?? '', textColor),
                      // Nếu có trường customerName trong order, hãy dùng ở đây. Nếu không, có thể bỏ qua hoặc thay bằng giá trị khác.
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Danh sách món
                Text(
                  'Danh sách món',
                  style: Style.fontTitleMini.copyWith(color: textColor),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: order.items?.isNotEmpty == true
                    ? Column(
                        children: order.items!.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return Column(
                            children: [
                              if (index > 0) const Divider(height: 24),
                              _buildOrderItem(
                                item.itemName ?? 'Món ${item.itemId}',
                                'x${item.quantity}',
                                item.itemPrice != null ? '${item.itemPrice!.toStringAsFixed(0)}đ' : '0đ',
                                item.note ?? '',
                                textColor,
                              ),
                            ],
                          );
                        }).toList(),
                      )
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Text(
                                'Chưa có món ăn nào',
                                style: Style.fontContent.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                ),
                const SizedBox(height: 20),

                // Tính tiền chi tiết
                Text(
                  'Tính tiền chi tiết',
                  style: Style.fontTitleMini.copyWith(color: textColor),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('Tạm tính', '${order.totalAmount ?? 0}đ', textColor),
                      // You can add more payment details if available in the order model
                      const Divider(height: 24),
                      _buildInfoRow(
                        'Tổng thanh toán', '${order.totalAmount ?? 0}đ', textColor, isTotal: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Thanh toán
                Text(
                  'Thanh toán',
                  style: Style.fontTitleMini.copyWith(color: textColor),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('Phương thức thanh toán', 'Tiền mặt', textColor),
                      _buildInfoRow('Trạng thái thanh toán', _getPaymentStatusName(order.statusId), textColor),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Button In hóa đơn
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _generateInvoicePdf(context, order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'In hóa đơn',
                      style: Style.fontTitleMini.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, Color textColor, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Style.fontNormal.copyWith(
              color: isTotal ? textColor : Style.textColorGray,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: Style.fontNormal.copyWith(
              color: textColor,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(
    String itemName,
    String quantity,
    String price,
    String note,
    Color textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              itemName,
              style: Style.fontNormal.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              quantity,
              style: Style.fontNormal.copyWith(color: textColor),
            ),
          ],
        ),
        if (note.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            note,
            style: Style.fontCaption.copyWith(
              color: Colors.red,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            price,
            style: Style.fontNormal.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  String _getPaymentStatusName(int? statusId) {
    switch (statusId) {
      case 1:
        return 'Chờ xử lý';
      case 2:
        return 'Đang nấu';
      case 3:
        return 'Sẵn sàng';
      case 4:
        return 'Đã phục vụ';
      case 5:
        return 'Đã thanh toán';
      case 6:
        return 'Đã hủy';
      default:
        return 'Chưa xác định';
    }
  }
}
