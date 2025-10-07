import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Style {
  //Style for text of button
  static TextStyle TextButton = TextStyle(
    color: Colors.white, // Text color for the button
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );
  //font cho tiêu đề mini
  static TextStyle fontTitleMini = GoogleFonts.roboto(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.2,
    height: 1.5,
    shadows: [
      Shadow(
        color: Colors.black.withOpacity(0.1), // Đổ bóng nhẹ hơn, tinh tế
        offset: Offset(0, 2),
        blurRadius: 4,
      ),
    ],
  );
  //font cho tiêu đề mini
  static TextStyle fontTitleSuperMini = GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.2,
    height: 1.5,
    shadows: [
      Shadow(
        color: Colors.black.withOpacity(0.1), // Đổ bóng nhẹ hơn, tinh tế
        offset: Offset(0, 2),
        blurRadius: 4,
      ),
    ],
  );
  //font bình thường
  static TextStyle fontNormal = GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.3,
  );

  //font cho tất cả title
  static TextStyle fontTitle = GoogleFonts.roboto(
    fontSize: 22,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.3,
    height: 1.3,
    color: Colors.blue.shade700,
    shadows: [
      Shadow(
        color: Colors.black.withOpacity(0.1), // Đổ bóng nhẹ hơn, tinh tế
        offset: Offset(0, 2),
        blurRadius: 4,
      ),
    ],
  );

  //font cho Username
  static TextStyle fontUsername = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.2,
    shadows: [
      Shadow(
        color: Colors.black.withOpacity(0.1), // Đổ bóng nhẹ hơn, tinh tế
        offset: Offset(0, 2),
        blurRadius: 4,
      ),
    ],
  );

  //font cho nội dung bài viết
  static TextStyle fontContent = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.2,
    height: 1.5,
    shadows: [
      Shadow(
        color: Colors.black.withOpacity(0.1), // Đổ bóng nhẹ hơn, tinh tế
        offset: Offset(0, 2),
        blurRadius: 4,
      ),
    ],
  );

  //font nút bấm/hành động
  static TextStyle fontButton = GoogleFonts.roboto(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.2,
    height: 1.2,
    color: Colors.white,
  );

  //font chú thích nhỏ và thời gian
  static TextStyle fontCaption = GoogleFonts.roboto(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.3,
    color: Colors.grey[600], // Màu sắc nhẹ nhàng cho chú thích
    shadows: [
      Shadow(
        color: Colors.black.withOpacity(0.05), // Đổ bóng nhẹ hơn, tinh tế
        offset: Offset(0, 1),
        blurRadius: 2,
      ),
    ],
  );

  //font cho comment
  static TextStyle fontComment = GoogleFonts.roboto(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.4,
    shadows: [
      Shadow(
        color: Colors.black.withOpacity(0.05), // Đổ bóng nhẹ hơn, tinh tế
        offset: Offset(0, 1),
        blurRadius: 2,
      ),
    ],
  );

  //font name app
  static const String fontFamily = 'Lobster';

  static const double defaultFontSize = 16.0;
  static const double headingFontSize = 24.0;
  static const double subheadingFontSize = 20.0;

  //Colors
  static const Color textColorGray = Color(0xFF666666);
  static const Color textColorBlack = Color.fromARGB(200, 0, 0, 0);
  static const Color textColorWhite = Colors.white;

  static const String primaryColor = '#6200EE';
  static const String secondaryColor = '#03DAC6';
  static const Color backgroundColor = Color(0xFFF0F0F0);
  static const String textColor = '#000000';
  static const Color buttonBackgroundColor = Color(0xFF4BC0D9);

  //Color Mode

  static const Color colorDark = Colors.black;
  static const Color colorLight = Colors.white;

  // Add more styles as needed
  static const double paddingPhone = 16.0;
  static const double paddingTablet = 26.0;
  static const double buttonHeight = 48.0;
  static const double buttonBorderRadius = 8.0;
  static const double inputFieldHeight = 56.0;
  static const double inputFieldBorderRadius = 8.0;
  static const double cardElevation = 2.0;
  static const double cardBorderRadius = 12.0;
  static const double iconSize = 24.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingExtraLarge = 32.0;
  static const double borderWidth = 1.0;
  static const double borderRadius = 12.0;
  static const double shadowBlurRadius = 4.0;
  static const double shadowSpreadRadius = 0.0;
  static const double shadowOffsetX = 0.0;
  static const double shadowOffsetY = 2.0;
  static const double elevation = 4.0;
  static const double iconButtonSize = 48.0;
  static const double textFieldHeight = 56.0;
  static const double textFieldBorderRadius = 8.0;
  static const double dialogBorderRadius = 16.0;
  static const double dialogElevation = 8.0;
  static const double tooltipHeight = 32.0;
  static const double tooltipBorderRadius = 8.0;
  static const double tooltipPadding = 8.0;
}
