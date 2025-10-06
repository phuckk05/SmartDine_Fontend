// import 'package:fluentui_system_icons/fluentui_system_icons.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:me_talk/core/style.dart';
// import 'package:me_talk/providers/mode_provider.dart';
// import 'package:me_talk/widgets/create_post.dart';
// import 'package:me_talk/widgets/list_image_user.dart';
// import 'package:me_talk/widgets/list_post.dart';

// class ScreenProfile extends ConsumerStatefulWidget {
//   const ScreenProfile({super.key});
//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _ScreenProfileState();
// }

// class _ScreenProfileState extends ConsumerState<ScreenProfile> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(extendBodyBehindAppBar: true, body: _body());
//   }

//   Widget _body() {
//     return Stack(
//       children: [
//         SingleChildScrollView(
//           child: Column(
//             children: [
//               Stack(
//                 children: [
//                   Column(
//                     children: [
//                       // _image(),
//                       Container(
//                         height: 50,
//                         color: Theme.of(context).scaffoldBackgroundColor,
//                       ),
//                     ],
//                   ),
//                   // _profile_picture(),
//                 ],
//               ),
//               // _username(),
//               // _information(context, ref),
//               // ListImageUser(),
//               // SizedBox(height: 10),
//               // _textPost("Bài viết của bạn"),
//               // SizedBox(height: 10),
//               // CreatePost(),
//               // SizedBox(height: 10),
//               // ListPost(),
//             ],
//           ),
//         ),
//         Positioned(
//           top: 0,
//           left: 0,
//           right: 0,
//           child: AppBar(
//             elevation: 0,
//             centerTitle: true,
//             iconTheme: IconThemeData(
//               color: Theme.of(context).colorScheme.onSurface,
//             ),
//             backgroundColor: Colors.transparent,
//             toolbarHeight: 50,
//             surfaceTintColor: Colors.transparent,
//             actions: [
//               IconButton(
//                 onPressed: () {},
//                 padding: EdgeInsets.zero,
//                 constraints: BoxConstraints(),
//                 icon: Icon(Icons.more_horiz, size: 32),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   //Ành nền
//   Widget _image() {
//     return Container(
//       height: 170,
//       width: double.infinity,
//       decoration: BoxDecoration(color: Colors.grey[500]),
//       // child: Image.network(
//       //   'https://tse2.mm.bing.net/th?id=OIP.62erNRY5-JZB1NuFyZ7n7QHaD4&pid=Api&P=0&h=220',
//       //   fit: BoxFit.cover,
//       // ),
//     );
//   }

//   //Ảnh đại diện
//   Widget _profile_picture() {
//     return Positioned(
//       bottom: 0,
//       right: 0,
//       left: 0,
//       child: Container(
//         padding: EdgeInsets.all(5),
//         width: 100,
//         height: 100,
//         decoration: BoxDecoration(
//           color: Theme.of(context).scaffoldBackgroundColor,
//           shape: BoxShape.circle,
//         ),
//         child: CircleAvatar(
//           backgroundColor: Colors.grey[500],
//           radius: 30,
//           // backgroundImage: NetworkImage(
//           //   'https://i.imgur.com/BoN9kdC.png',
//           //   scale: 0.5,
//           // ),
//         ),
//       ),
//     );
//   }

//   //Text "Bài viết của bạn"
//   Widget _textPost(String text) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: Style.paddingPhone),
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: Text(text, style: Style.fontTitleMini),
//       ),
//     );
//   }

//   //Tên Username
//   Widget _username() {
//     return Text('Phuckk', style: Style.fontUsername);
//   }

//   // Widget thông tin hồ sơ (đẹp, hiện đại)
//   Widget _information(BuildContext context, WidgetRef ref) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(20),
//           color: Theme.of(context).colorScheme.surface,
//           boxShadow: [
//             BoxShadow(
//               blurRadius: 5,
//               color: ref.watch(modeProvider) ? Colors.white24 : Colors.black12,
//               offset: Offset(0, 4),
//             ),
//           ],
//         ),
//         padding: const EdgeInsets.only(left: 16, right: 5, top: 16, bottom: 16),
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('Thông tin hồ sơ', style: Style.fontTitleMini),
//                 Spacer(),
//                 IconButton(
//                   onPressed: () {},
//                   icon: Icon(FluentIcons.add_circle_24_filled),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             _buildInfoRow(icon: Icons.cake, label: "25 tuổi"),
//             const SizedBox(height: 10),
//             _buildInfoRow(
//               icon: FluentIcons.location_24_filled,
//               label: "TP HCM",
//               iconColor: Colors.redAccent,
//             ),
//             const SizedBox(height: 10),
//             _buildInfoRow(
//               icon: FluentIcons.briefcase_24_filled,
//               label: "Nhà phát triển Flutter",
//             ),
//             const SizedBox(height: 10),
//             _buildInfoRow(
//               icon: FluentIcons.accessibility_24_filled,
//               label: "1m75",
//             ),
//             const SizedBox(height: 10),
//             _buildInfoRow(icon: Icons.school, label: "Đại học CNTT"),
//             const SizedBox(height: 10),
//             _buildInfoRow(icon: FluentIcons.heart_24_filled, label: "Độc thân"),
//             const SizedBox(height: 20),

//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text("Sở thích", style: Style.fontTitleMini),
//             ),
//             const SizedBox(height: 10),

//             Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: [
//                 _buildHobbyChip("Du lịch"),
//                 _buildHobbyChip("Âm nhạc"),
//                 _buildHobbyChip("Cờ vua"),
//                 _buildHobbyChip(
//                   "Đọc sách kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk",
//                 ),
//                 _buildHobbyChip("Chụp ảnh"),
//                 _buildHobbyChip(
//                   "Thể thao kkfffffffffffffffffffffffffffffffkkkkkkkkkkkfkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk",
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   //build thông tin hồ sơ
//   Widget _buildInfoRow({
//     required IconData icon,
//     required String label,
//     Color? iconColor,
//   }) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Icon(icon, size: 20, color: iconColor ?? Colors.blueGrey),
//         const SizedBox(width: 10),
//         Text(label, style: Style.fontContent),
//       ],
//     );
//   }

//   //build sở thích
//   Widget _buildHobbyChip(String label) {
//     return Padding(
//       padding: const EdgeInsets.only(right: 11),
//       child: Chip(
//         label: ConstrainedBox(
//           constraints: BoxConstraints(
//             maxWidth: double.infinity,
//           ), // Giới hạn chiều rộng
//           child: Text(
//             label,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             softWrap: true,
//           ),
//         ),
//         backgroundColor: Colors.blue.shade50,
//         labelStyle: TextStyle(color: Colors.blue.shade800),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }
// }
