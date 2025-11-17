// File: _charts.dart

import 'package:flutter/material.dart';
import 'dart:math';

// =================================================================
// 1. Line Chart Painter (Vẽ Đồ thị đường)
// =================================================================

class LineChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels; // <<< THÊM DÒNG NÀY

  LineChartPainter(List<int> rawData, this.labels) // <<< CẬP NHẬT CONSTRUCTOR
      : data = rawData.map((e) => e.toDouble()).toList();

  @override
  void paint(Canvas canvas, Size size) {
    const leftPadding = 36.0;
    const rightPadding = 12.0;
    const topPadding = 12.0;
    const bottomPadding = 36.0;

    final plotWidth = size.width - leftPadding - rightPadding;
    final plotHeight = size.height - topPadding - bottomPadding;
    if (plotWidth <= 0 || plotHeight <= 0) return;

    final paintAxis = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(leftPadding, topPadding),
        Offset(leftPadding, topPadding + plotHeight), paintAxis);
    canvas.drawLine(Offset(leftPadding, topPadding + plotHeight),
        Offset(leftPadding + plotWidth, topPadding + plotHeight), paintAxis);

    // --- Sửa lỗi nếu data rỗng ---
    final maxY = data.isEmpty ? 1.0 : data.reduce((a, b) => a > b ? a : b);
    
    const labelCount = 4;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i <= labelCount; i++) {
      final yValue = (maxY / labelCount) * i;
      final yPos = topPadding + plotHeight - (yValue / maxY) * plotHeight;
      textPainter.text = TextSpan(
          text: i == 0 ? '0' : '${(yValue).toInt()}',
          style: const TextStyle(fontSize: 11, color: Colors.black));
      textPainter.layout();
      textPainter.paint(canvas, Offset(leftPadding - textPainter.width - 6, yPos - textPainter.height / 2));
      final grid = Paint()..color = Colors.black12..strokeWidth = 0.6;
      canvas.drawLine(Offset(leftPadding, yPos), Offset(leftPadding + plotWidth, yPos), grid);
    }
    
    // --- Ngăn lỗi nếu chỉ có 1 điểm dữ liệu ---
    final dx = (data.length > 1) ? plotWidth / (data.length - 1) : 0.0;
    
    final paintLine = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final paintDot = Paint()..color = Colors.black;

    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = leftPadding + i * dx;
      final y = topPadding + plotHeight - (data[i] / maxY) * plotHeight;
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
      canvas.drawCircle(Offset(x, y), 4, paintDot);
    }
    canvas.drawPath(path, paintLine);

    // --- CẬP NHẬT PHẦN VẼ NHÃN TRỤC X ---
    // final labelsX = ["2", "3", "4", "5", "6", "7", "CN"]; // <<< BỎ DÒNG NÀY
    final totalLabels = labels.length; // <<< DÙNG DỮ LIỆU NHÃN ĐƯỢC TRUYỀN VÀO
    if (totalLabels == 0) return; // Không vẽ gì nếu không có nhãn

    // Cần kiểm tra xem có đủ dữ liệu cho nhãn hay không
    final labelSpacing = (totalLabels > 1) ? plotWidth / (totalLabels - 1) : plotWidth; 
    
    for (int i = 0; i < min(totalLabels, data.length); i++) {
      final x = leftPadding + i * labelSpacing;
      final tp = TextPainter(
          text: TextSpan(text: labels[i], style: const TextStyle(fontSize: 11, color: Colors.black)),
          textDirection: TextDirection.ltr);
      tp.layout();
      // Nếu là điểm dữ liệu duy nhất, căn giữa
      final xPos = (totalLabels == 1) ? (leftPadding + plotWidth / 2 - tp.width / 2) : (x - tp.width / 2);
      tp.paint(canvas, Offset(xPos, topPadding + plotHeight + 6));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =================================================================
// 2. Bar Chart Painter (Vẽ Đồ thị cột)
// =================================================================
// (Không cần thay đổi BarChartPainter)
class BarChartPainter extends CustomPainter {
  final List<List<int>> data;
  final List<String> labels;

  BarChartPainter(this.data, this.labels);

  @override
  void paint(Canvas canvas, Size size) {
    const leftPadding = 36.0;
    const rightPadding = 12.0;
    const topPadding = 12.0;
    const bottomPadding = 40.0; 

    final plotWidth = size.width - leftPadding - rightPadding;
    final plotHeight = size.height - topPadding - bottomPadding;
    if (plotWidth <= 0 || plotHeight <= 0) return;

    final paintAxis = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(leftPadding, topPadding),
        Offset(leftPadding, topPadding + plotHeight), paintAxis);
    canvas.drawLine(Offset(leftPadding, topPadding + plotHeight),
        Offset(leftPadding + plotWidth, topPadding + plotHeight), paintAxis);

    final flat = data.expand((g) => g).toList();
    final maxY = (flat.isNotEmpty ? flat.reduce((a, b) => a > b ? a : b).toDouble() : 1.0);
    final yLabels = [0, (maxY * 0.25).round(), (maxY * 0.5).round(), (maxY * 0.75).round(), maxY.round()];
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    
    for (int i = 0; i < yLabels.length; i++) {
      final yValue = yLabels[i].toDouble();
      final yPos = topPadding + plotHeight - (yValue / maxY) * plotHeight;
      textPainter.text = TextSpan(text: i == 0 ? '0' : '${yLabels[i]}', style: const TextStyle(fontSize: 11, color: Colors.black));
      textPainter.layout();
      textPainter.paint(canvas, Offset(leftPadding - textPainter.width - 6, yPos - textPainter.height / 2));
      
      final grid = Paint()..color = Colors.black12..strokeWidth = 0.6;
      canvas.drawLine(Offset(leftPadding, yPos), Offset(leftPadding + plotWidth, yPos), grid);
    }

    final groupCount = data.length;
    if (groupCount == 0) return;
    final groupSpacing = plotWidth / groupCount;
    final colors = [Colors.blue, Colors.black, Colors.grey]; 

    for (int gi = 0; gi < groupCount; gi++) {
      final group = data[gi];
      if (group.isEmpty) continue;
      
      final barCount = group.length;
      const barPadding = 6.0;
      final groupInnerWidth = groupSpacing * 0.6;
      final barWidth = (groupInnerWidth - (barCount - 1) * barPadding) / barCount;
      
      final groupCenter = leftPadding + gi * groupSpacing + groupSpacing / 2;
      final groupTotalUsedWidth = barCount * barWidth + (barCount - 1) * barPadding;
      final startX = groupCenter - groupTotalUsedWidth / 2;

      for (int j = 0; j < group.length; j++) {
        final value = group[j].toDouble();
        final barH = (value / maxY) * plotHeight;
        final x = startX + j * (barWidth + barPadding);
        final y = topPadding + plotHeight - barH;
        final paint = Paint()..color = colors[j % colors.length];

        canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(x, y, barWidth, barH), const Radius.circular(6)), paint);
      }

      // --- Sửa lỗi nếu labels không đủ ---
      if (gi < labels.length) {
        final labelPainter = TextPainter(
            text: TextSpan(text: labels[gi], style: const TextStyle(fontSize: 11, color: Colors.black)),
            textDirection: TextDirection.ltr);
        labelPainter.layout();
        labelPainter.paint(canvas, Offset(groupCenter - labelPainter.width / 2, topPadding + plotHeight + 6));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}