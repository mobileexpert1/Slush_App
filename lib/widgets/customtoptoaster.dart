import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:slush/constants/image.dart';

class CustomTopToaster extends StatefulWidget {
  const CustomTopToaster({super.key});

  @override
  State<CustomTopToaster> createState() => _CustomTopToasterState();
}

class _CustomTopToasterState extends State<CustomTopToaster> {
  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.only(top: 60),
      color: Colors.green,
      width: size.width,
      child: Stack(children: [
        Positioned(
           left: -50,
            child: SvgPicture.asset(AssetsPics.bannerheart,)),
        SvgPicture.asset(AssetsPics.bannerheart,),
        // SvgPicture.asset(AssetsPics.bannerheart),
        const Text("Unmatched")
      ],),
    );
  }
}
