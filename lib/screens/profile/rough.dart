import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/localkeys.dart';
import 'package:slush/screens/profile/edit_profile.dart';
import 'package:slush/widgets/text_widget.dart';

class MySliverList extends StatefulWidget {
  const MySliverList({Key? key}) : super(key: key);

  @override
  State<MySliverList> createState() => _MySliverListState();
}

class _MySliverListState extends State<MySliverList> {
  List items=[
    "Travelling","Modeling","Dancing","Books","Music","Dancing"
  ];
  PageController controller = PageController();
  int numberOfPages = 3;
  int currentPage = 0;
  int indicatorIndex = 0;

  bool isScrolled=false;
  var hi=0.0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        child: Center(

        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        backgroundColor: color.txtBlue,
        onPressed: () {},
        child: SvgPicture.asset(AssetsPics.floatiAction),
      ),
    );
  }
}
