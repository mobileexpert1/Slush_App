import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/widgets/text_widget.dart';

class CustomTopToaster extends StatefulWidget {
   CustomTopToaster({super.key,required this.textt});
  String textt;
  @override
  State<CustomTopToaster> createState() => _CustomTopToasterState();
}

class _CustomTopToasterState extends State<CustomTopToaster>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _isVisible=false;
    // Initialize the AnimationController
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1), // Start above the screen
      end: const Offset(0, 0), // End at its original position
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Start the animation
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 200), () {
      _controller.forward().then((value) { setState(() {_isVisible = true;});});
    });
    Future.delayed(const Duration(seconds: 6), () {
      _controller.reverse().then((value) { setState(() {_isVisible = false;});});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return _isVisible ? SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.only(top: 20),
        color:const Color(0xff67AD5C),
        width: size.width,
        height: size.height * 0.11,
        child: Stack(
          children: [
            Row(
              children: [
                SvgPicture.asset(AssetsPics.bannerheart),
                const Spacer(),
                SvgPicture.asset(AssetsPics.bannerheart),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 15),
              child: Center(child: Padding(
                padding: const EdgeInsets.only(top: 30),
                child: DefaultTextStyle(style: const TextStyle(),child: buildText(widget.textt, 18, FontWeight.w600, Colors.white),),
              )),
            )
          ],
        ),
      ),
    ) : const SizedBox.shrink();
  }
}




class CustomredTopToaster extends StatefulWidget {
   CustomredTopToaster({super.key,required this.textt});
  String textt;

  @override
  State<CustomredTopToaster> createState() => _CustomredTopToasterState();
}

class _CustomredTopToasterState extends State<CustomredTopToaster>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    // Initialize the AnimationController
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1), // Start above the screen
      end: const Offset(0, 0), // End at its original position
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Start the animation
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 200), () {
      _controller.forward().then((value) { setState(() {_isVisible = true;});});
    });
    Future.delayed(const Duration(seconds: 6), () {
      _controller.reverse().then((value) { setState(() {_isVisible = false;LocaleHandler.isBanner2=false;});});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return _isVisible && LocaleHandler.isBanner2
        ? SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.only(top: 20),
        color:const Color(0xffE15C47),
        width: size.width,
        height: size.height * 0.11,
        child: Stack(
          children: [
            Row(
              children: [
                SvgPicture.asset(AssetsPics.bannerheart),
                const Spacer(),
                SvgPicture.asset(AssetsPics.bannerheart),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 15),
              child: Center(child: Padding(
                padding: const EdgeInsets.only(top: 30),
                child: DefaultTextStyle(style: const TextStyle(),child: buildText(widget.textt, 18, FontWeight.w600, Colors.white),),
              )),
            )
          ],
        ),
      ),
    )
        : const SizedBox.shrink();
  }
}


// verification banner
class CustomBlueTopToaster extends StatefulWidget {
  CustomBlueTopToaster({super.key,required this.textt});
  String textt;

  @override
  State<CustomBlueTopToaster> createState() => _CustomBlueTopToasterState();
}

class _CustomBlueTopToasterState extends State<CustomBlueTopToaster>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    // Initialize the AnimationController
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1), // Start above the screen
      end: const Offset(0, 0), // End at its original position
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Start the animation
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 200), () {
      _controller.forward().then((value) { setState(() {_isVisible = true;});});
    });
    Future.delayed(const Duration(seconds: 6), () {
      _controller.reverse().then((value) { setState(() {_isVisible = false;LocaleHandler.isBanner2=false;});});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return _isVisible
        ? SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.only(top: 20),
        color:const Color(0xff0562B2),
        width: size.width,
        height: size.height * 0.11,
        child: Stack(
          children: [
            Row(
              children: [
                SvgPicture.asset(AssetsPics.bannerheart),
                const Spacer(),
                SvgPicture.asset(AssetsPics.bannerheart),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 15),
              child: Center(child: Padding(
                padding: const EdgeInsets.only(top: 30),
                child: DefaultTextStyle(style: const TextStyle(),child: buildText(widget.textt, 18, FontWeight.w600, Colors.white),),
              )),
            )
          ],
        ),
      ),
    )
        : const SizedBox.shrink();
  }
}


