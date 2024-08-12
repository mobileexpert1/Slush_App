// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:slush/constants/image.dart';
//
// void showCustomSnackBar(BuildContext context, String img,bool isPng) {
//   final overlay = Overlay.of(context);
//   final overlayEntry = OverlayEntry(
//     builder: (context) => AnimatedSnackBar(img: img,isPng: isPng),
//   );
//
//   // Add the overlay entry
//   overlay.insert(overlayEntry);
//
//   // Remove the overlay entry after a duration
//   Future.delayed(const Duration(seconds: 3), () {
//     overlayEntry.remove();
//   });
// }
//
// class AnimatedSnackBar extends StatefulWidget {
//   final String img;
//   final bool isPng;
//
//   AnimatedSnackBar({required this.img,required this.isPng});
//
//   @override
//   _AnimatedSnackBarState createState() => _AnimatedSnackBarState();
// }
//
// class _AnimatedSnackBarState extends State<AnimatedSnackBar>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<Offset> _slideAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     )..forward().then((_) {
//       Future.delayed(const Duration(seconds: 2), () {
//         _controller.reverse();
//       });
//     });
//
//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, -1),
//       end: const Offset(0, 0),
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeOut,
//     ));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.topCenter,
//       child: SlideTransition(
//         position: _slideAnimation,
//         child: Material(
//           color: Colors.transparent,
//           child: FittedBox(
//             child: Container(
//               width: MediaQuery.of(context).size.width, // Full width
//               // color: Colors.blue,
//               // padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: Stack(alignment: Alignment.center,
//                 children: [
//                   SizedBox(width: MediaQuery.of(context).size.width,
//                       child:widget.isPng?Image.asset(widget.img,fit: BoxFit.cover): SvgPicture.asset(widget.img,fit: BoxFit.cover)),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       widget.isPng?const SizedBox(): Container(color: Colors.transparent,
//                         transform: Matrix4.translationValues(MediaQuery.of(context).size.width * -.11, 0, 0.0),
//                         child: SvgPicture.asset(AssetsPics.bannerheart),
//                       ),
//                       widget.isPng?const SizedBox():   Container(color: Colors.transparent,
//                           transform: Matrix4.translationValues(MediaQuery.of(context).size.width * .01, 0, 10.0),
//                           child: SvgPicture.asset(AssetsPics.bannerheart)),
//                     ],),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// }