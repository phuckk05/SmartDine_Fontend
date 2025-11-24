import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mart_dine/API_staff/order_API.dart';
import 'package:mart_dine/API_staff/payment_API.dart';
import 'package:mart_dine/API_staff/user_API.dart';
import 'package:mart_dine/core/style.dart';
import 'package:mart_dine/model_staff/item.dart';
import 'package:mart_dine/model_staff/order.dart';
import 'package:mart_dine/model_staff/order_item.dart';
import 'package:mart_dine/model_staff/payment.dart';
import 'package:mart_dine/model_staff/user.dart';
import 'package:mart_dine/provider_staff/menu_item_provider.dart';
import 'package:mart_dine/provider_staff/user_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ScreenPayment extends ConsumerStatefulWidget {
  final int tableId;
  final String tableName;
  final Order order;
  final List<OrderItem> orderItems;
  final int? companyId;

  const ScreenPayment({
    super.key,
    required this.tableId,
    required this.tableName,
    required this.order,
    required this.orderItems,
    this.companyId,
  });

  @override
  ConsumerState<ScreenPayment> createState() => _ScreenPaymentState();
}

class _ScreenPaymentState extends ConsumerState<ScreenPayment> {
  String _selectedPaymentMethod = 'Phương thức thanh toán';
  bool _isProcessing = false;
  bool _isExportingInvoice = false;
  String? _resolvedCashierName;

  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

  final List<String> _paymentMethods = [
    'Phương thức thanh toán',
    'Tiền mặt',
    'Chuyển khoản',
    'Thẻ',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.companyId != null) {
        ref
            .read(menuNotifierProvider.notifier)
            .loadMenusByCompanyId(widget.companyId!);
      }
      _resolveCashierName();
    });
  }

  String _formatCurrency(double value) => _currencyFormatter.format(value);

  String _formatOrderDate(DateTime dateTime) =>
      _dateFormatter.format(dateTime.toLocal());

  bool get _isShareSupported {
    if (kIsWeb) return false;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
        return true;
      default:
        return false;
    }
  }

  String _getCashierDisplayName(User? currentUser) {
    if (currentUser != null) {
      final trimmedName = currentUser.fullName.trim();
      if (trimmedName.isNotEmpty) {
        return trimmedName;
      }
      final currentUserId = currentUser.id;
      if (currentUserId != null && currentUserId > 0) {
        return 'NV #$currentUserId';
      }
    }
    if (widget.order.userId > 0) {
      return 'NV #${widget.order.userId}';
    }
    return 'Chưa xác định';
  }

  // Tính tổng tiền
  double _calculateTotal() {
    // Lấy thông tin món ăn từ itemId
    final menuItems = ref.watch(menuNotifierProvider);
    final menuMap = <int, Item>{};
    for (final menuItem in menuItems) {
      final id = menuItem.id;
      if (id != null) {
        menuMap[id] = menuItem;
      }
    }

    double total = 0.0;
    for (final item in widget.orderItems) {
      final menuItem = menuMap[item.itemId];
      if (menuItem != null) {
        total += item.quantity * menuItem.price;
      }
    }

    // Debug: In ra tổng tiền tính được
    print('Calculated total: $total');
    return total;
  }

  Future<void> _resolveCashierName() async {
    final currentUser = ref.read(userNotifierProvider);
    if (currentUser != null) {
      final trimmed = currentUser.fullName.trim();
      if (trimmed.isNotEmpty) {
        setState(() {
          _resolvedCashierName = trimmed;
        });
        return;
      }
    }

    if (widget.order.userId <= 0) return;

    try {
      final userApi = ref.read(userApiProvider);
      final cashier = await userApi.getUserById(widget.order.userId);
      if (!mounted) return;
      if (cashier != null) {
        final trimmed = cashier.fullName.trim();
        setState(() {
          _resolvedCashierName =
              trimmed.isNotEmpty ? trimmed : 'NV #${widget.order.userId}';
        });
      } else {
        setState(() {
          _resolvedCashierName = 'NV #${widget.order.userId}';
        });
      }
    } catch (e) {
      debugPrint('Không thể tải tên thu ngân: $e');
      if (mounted) {
        setState(() {
          _resolvedCashierName = 'NV #${widget.order.userId}';
        });
      }
    }
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == 'Phương thức thanh toán') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn phương thức thanh toán')),
      );
      return;
    }

    // Kiểm tra xem tất cả món đã được phục vụ chưa
    final unservedItems =
        widget.orderItems.where((item) => item.statusId != 3).toList();
    if (unservedItems.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Không thể thanh toán! Còn ${unservedItems.length} món chưa được phục vụ.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Kiểm tra xem đã có payment cho order này chưa
    final paymentApi = ref.read(paymentApiProvider);
    final existingPayments = await paymentApi.getPaymentsByOrderId(
      widget.order.id,
    );
    if (existingPayments.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đơn hàng này đã được thanh toán rồi!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final total = _calculateTotal();
      final currentUser = ref.read(userNotifierProvider);
      int? cashierId;
      final currentUserId = currentUser?.id;
      if (currentUserId != null && currentUserId > 0) {
        cashierId = currentUserId;
      } else if (widget.order.userId > 0) {
        cashierId = widget.order.userId;
      }

      // Tạo payment
      final payment = Payment(
        orderId: widget.order.id,
        amount: total,
        paymentMethod: _selectedPaymentMethod,
        branchId: widget.order.branchId,
        companyId: widget.order.companyId,
        cashierId: cashierId,
      );

      print('Creating payment with data:');
      print('orderId: ${payment.orderId}');
      print('amount: ${payment.amount}');
      print('paymentMethod: ${payment.paymentMethod}');
      print('branchId: ${payment.branchId}');
      print('companyId: ${payment.companyId}');
      print('cashierId: ${payment.cashierId}');

      final paymentApi = ref.read(paymentApiProvider);
      final createdPayment = await paymentApi.createPayment(payment);

      if (createdPayment == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể tạo thanh toán')),
          );
        }
        return;
      }

      print('Payment created successfully: ${createdPayment.orderId}');

      // Cập nhật trạng thái order thành đã thanh toán (statusId = 3)
      final orderApi = ref.read(orderApiProvider);
      final updatedOrder = await orderApi.updateOrderStatusAlt(
        widget.order.id,
        3,
      );
      print('Updated order status: ${updatedOrder?.statusId}');

      if (mounted) {
        // Hiển thị dialog thành công
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.green.shade700,
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Thanh toán thành công',
                      style: Style.fontTitle.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatOrderDate(widget.order.createdAt),
                      style: Style.fontNormal.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Đóng dialog
                      Navigator.of(context).pop(); // Quay về màn hình chọn bàn
                    },
                    child: const Text('Đóng'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi thanh toán: $e')));
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _handleExportInvoice({bool openPrintPreview = false}) async {
    if (_isExportingInvoice) return;

    setState(() {
      _isExportingInvoice = true;
    });

    final total = _calculateTotal();
    final sanitizedTableName = widget.tableName.replaceAll(' ', '_');
    final fileName = 'hoa_don_${sanitizedTableName}_${widget.order.id}.pdf';
    final shouldOpenPrintPreview = openPrintPreview || !_isShareSupported;

    try {
      if (shouldOpenPrintPreview) {
        await Printing.layoutPdf(
          name: fileName,
          onLayout: (format) => _buildInvoicePdf(total, format),
        );
      } else {
        final bytes = await _buildInvoicePdf(total, PdfPageFormat.a4);
        await Printing.sharePdf(bytes: bytes, filename: fileName);
      }
    } on MissingPluginException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Thiết bị hiện tại chưa hỗ trợ in/chia sẻ PDF (${e.message}).',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể xuất hóa đơn: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExportingInvoice = false;
        });
      }
    }
  }

  Future<Uint8List> _buildInvoicePdf(
    double total,
    PdfPageFormat pageFormat,
  ) async {
    final pdf = pw.Document();
    final regularFont = await PdfGoogleFonts.nunitoRegular();
    final boldFont = await PdfGoogleFonts.nunitoBold();
    final menuItems = ref.read(menuNotifierProvider);
    final menuLookup = <int, Item>{};
    for (final menuItem in menuItems) {
      final id = menuItem.id;
      if (id != null) {
        menuLookup[id] = menuItem;
      }
    }

    final cashier =
        _resolvedCashierName ??
        _getCashierDisplayName(ref.read(userNotifierProvider));
    final orderDate = _formatOrderDate(widget.order.createdAt);
    final paymentMethod =
        _selectedPaymentMethod == 'Phương thức thanh toán'
            ? 'Chưa chọn'
            : _selectedPaymentMethod;

    final itemRows =
        widget.orderItems.map((item) {
          final menuItem = menuLookup[item.itemId];
          final itemName = menuItem?.name ?? 'Món ${item.itemId}';
          final unitPrice = menuItem?.price ?? 0;
          final lineTotal = unitPrice * item.quantity;

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 4,
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 4,
                      child: pw.Text(
                        itemName,
                        style: pw.TextStyle(font: regularFont, fontSize: 12),
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.SizedBox(
                      width: 40,
                      child: pw.Text(
                        'x${item.quantity}',
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(font: regularFont, fontSize: 12),
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        _formatCurrency(unitPrice),
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(font: regularFont, fontSize: 12),
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        _formatCurrency(lineTotal),
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(font: regularFont, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              if (item.note != null && item.note!.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 4, bottom: 4),
                  child: pw.Text(
                    'Ghi chú: ${item.note}',
                    style: pw.TextStyle(
                      font: regularFont,
                      fontSize: 10,
                      color: PdfColor.fromInt(0xFF757575),
                    ),
                  ),
                ),
              pw.Divider(),
            ],
          );
        }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        build:
            (context) => [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'SmartDine RMS',
                        style: pw.TextStyle(font: boldFont, fontSize: 22),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Mã đơn: #${widget.order.id}',
                        style: pw.TextStyle(font: regularFont, fontSize: 12),
                      ),
                      pw.Text(
                        'Bàn: ${widget.tableName}',
                        style: pw.TextStyle(font: regularFont, fontSize: 12),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Ngày: $orderDate',
                        style: pw.TextStyle(font: regularFont, fontSize: 12),
                      ),
                      pw.Text(
                        'Thu ngân: $cashier',
                        style: pw.TextStyle(font: regularFont, fontSize: 12),
                      ),
                      pw.Text(
                        'Chi nhánh: #${widget.order.branchId}',
                        style: pw.TextStyle(font: regularFont, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 24),
              pw.Text(
                'Danh sách món',
                style: pw.TextStyle(font: boldFont, fontSize: 16),
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFE0E0E0),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 4,
                      child: pw.Text(
                        'Món',
                        style: pw.TextStyle(font: boldFont, fontSize: 12),
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.SizedBox(
                      width: 40,
                      child: pw.Text(
                        'SL',
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(font: boldFont, fontSize: 12),
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        'Đơn giá',
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(font: boldFont, fontSize: 12),
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        'Thành tiền',
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(font: boldFont, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              pw.Divider(),
              ...itemRows,
              pw.SizedBox(height: 16),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                        color: PdfColor.fromInt(0xFFBDBDBD),
                      ),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Row(
                          mainAxisSize: pw.MainAxisSize.min,
                          children: [
                            pw.Text(
                              'Phương thức: ',
                              style: pw.TextStyle(
                                font: regularFont,
                                fontSize: 12,
                              ),
                            ),
                            pw.Text(
                              paymentMethod,
                              style: pw.TextStyle(font: boldFont, fontSize: 12),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          'Tổng cộng',
                          style: pw.TextStyle(font: boldFont, fontSize: 14),
                        ),
                        pw.Text(
                          _formatCurrency(total),
                          style: pw.TextStyle(font: boldFont, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (widget.order.note != null && widget.order.note!.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 12),
                  child: pw.Text(
                    'Ghi chú đơn: ${widget.order.note}',
                    style: pw.TextStyle(font: regularFont, fontSize: 12),
                  ),
                ),
              pw.SizedBox(height: 24),
              pw.Center(
                child: pw.Text(
                  'Cảm ơn quý khách và hẹn gặp lại!',
                  style: pw.TextStyle(font: regularFont, fontSize: 12),
                ),
              ),
            ],
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    final total = _calculateTotal();
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final orderTimestamp = _formatOrderDate(widget.order.createdAt);
    final currentUser = ref.watch(userNotifierProvider);
    final cashierName =
        _resolvedCashierName ?? _getCashierDisplayName(currentUser);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Thu Ngân', style: Style.fontTitle),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            onPressed:
                _isExportingInvoice
                    ? null
                    : () => _handleExportInvoice(openPrintPreview: true),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Menu khác
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Thông tin bàn
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bàn: ${widget.tableName}',
                  style: Style.fontTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Thời gian: $orderTimestamp',
                  style: Style.fontNormal.copyWith(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Thu ngân: $cashierName',
                  style: Style.fontNormal.copyWith(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Danh sách món
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Danh sách món ăn',
                  style: Style.fontTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 12),
                ...widget.orderItems.map((item) => _buildOrderItem(item)),
                const Divider(height: 32),

                // Tổng tiền
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tổng cộng:',
                      style: Style.fontTitle.copyWith(fontSize: 18),
                    ),
                    Text(
                      '${total.toStringAsFixed(0)} VNĐ',
                      style: Style.fontTitle.copyWith(
                        fontSize: 18,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Chọn phương thức thanh toán
                Text(
                  'Chọn phương thức thanh toán:',
                  style: Style.fontTitle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPaymentMethod,
                      isExpanded: true,
                      items:
                          _paymentMethods.map((method) {
                            return DropdownMenuItem(
                              value: method,
                              child: Text(method),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Nút thanh toán
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade900 : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Nút Lưu Hóa Đơn
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _isExportingInvoice ? null : _handleExportInvoice,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.orange.shade700),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        _isExportingInvoice
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.orange.shade700,
                                ),
                              ),
                            )
                            : Text(
                              'Xuất hóa đơn',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
                const SizedBox(width: 12),
                // Nút Thanh toán
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        _isProcessing
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text(
                              'Thanh toán',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    // Lấy thông tin món ăn từ itemId
    final menuItems = ref.watch(menuNotifierProvider);
    final menuItem = menuItems.firstWhere(
      (menu) => menu.id == item.itemId,
      orElse:
          () => Item(
            companyId: 0,
            name: 'Món ${item.itemId}',
            price: 0.0,
            statusId: 1,
          ),
    );

    final itemPrice = menuItem.price * item.quantity;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Số lượng
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'x${item.quantity}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          // Tên món
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menuItem.name,
                  style: Style.fontNormal.copyWith(fontSize: 14),
                ),
                if (item.note != null && item.note!.isNotEmpty)
                  Text(
                    item.note!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          // Giá
          Text(
            '${itemPrice.toStringAsFixed(0)}đ',
            style: Style.fontNormal.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
