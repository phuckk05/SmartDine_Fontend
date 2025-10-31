import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'style.dart'; // Nhớ import nếu dùng Style.defaultFontSize

class Constrats {
 
  // Chế độ sáng tối
  static void Mode(bool mode) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Màu nền thanh trạng thái
      statusBarIconBrightness: mode ? Brightness.light : Brightness.dark, // Màu icon thanh trạng thái
    ));
  }

  //Phần thông báo ScaffoldMessenger
  static void showThongBao(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        showCloseIcon: true,
        closeIconColor: Colors.black,
        backgroundColor: Colors.white,
        content: SizedBox(
          height: 60,
          child: Center(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: Style.defaultFontSize, // đảm bảo Style có biến này
              ),
            ),
          ),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.black54,
            width: 1,
          ),
        ),
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    );
  }
}

const Color kDarkShadowColor = Color( 0xFFAEAEC0,); // Dark shadow for embossed/convex elements
const Color kLightShadowColor = Colors.white; // Light shadow for embossed/convex elements
const Color kTextColorDark = Colors.black;
const Color kTextColorLight = Color( 0xFF969696,); // Light text color (for placeholders)
const Color kLogoIconColor = Color(0xFF6A5ACD); // Color for the logo icon

class ShadowCus extends StatelessWidget {
  final Widget? child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool isConcave; 
  final Color baseColor;
  final double blurRadius;
  final double spreadRadius;
  final Offset offset;

  const ShadowCus({
    super.key,
    this.child,
    this.borderRadius = 20.0,
    this.padding = const EdgeInsets.all(16.0),
    this.isConcave = false,
    this.baseColor = Style.backgroundColor, // Default to background color
    this.blurRadius = 2.0,
    this.spreadRadius = 1.0,
    this.offset = const Offset(4, 4),
  });

  @override
  Widget build(BuildContext context) {
    List<BoxShadow> shadows;

    if (isConcave) {
      // Concave (inset) effect for input fields
      shadows = [
        BoxShadow(
          color: kDarkShadowColor.withOpacity(0.25), // Dark inner shadow
          offset: offset,
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
        ),
        BoxShadow(
          color: kLightShadowColor, // Light inner shadow
          offset: Offset(-offset.dx, -offset.dy),
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
        ),
      ];
    } else {
      // Convex (embossed/raised) effect for cards and buttons
      shadows = [
        BoxShadow(
          color: kDarkShadowColor.withOpacity(0.2), // Dark shadow
          offset: offset,
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
        ),
        BoxShadow(
          color: kLightShadowColor, // Light shadow
          offset: Offset(-offset.dx, -offset.dy),
          blurRadius: blurRadius,
          spreadRadius: spreadRadius,
        ),
      ];
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows,
      ),
      child: child,
    );
  }
}
