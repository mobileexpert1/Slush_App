import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/widgets/text_widget.dart';

PreferredSizeWidget commonBar(BuildContext context,Color bg,{VoidCallback? press=onPress}) {
  return AppBar(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
        statusBarBrightness: Brightness.light, // For iOS (dark icons)
      ),
      surfaceTintColor: Colors.transparent,
      // backgroundColor: bg,
      backgroundColor: Colors.transparent,
      flexibleSpace: const Image(image: AssetImage(AssetsPics.appBarbg),
        fit: BoxFit.fitWidth,
        alignment: Alignment.topCenter,
      ),
      centerTitle: true,
      leadingWidth: 50,
      leading: GestureDetector(
        onTap: press,
        child: Padding(
          padding: const EdgeInsets.only(left: 10,top: 12,bottom: 4),
          child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20)
              ),
            padding: EdgeInsets.only(left: 9,right: 9),
              child: SvgPicture.asset(AssetsPics.arrowLeft)),
          // child: Icon(Icons.arrow_back,color: color.txtBlack,),
        ),
      ),
      title: buildText("", 24, FontWeight.w600, color.txtWhite));
}

PreferredSizeWidget commonBarWithText(BuildContext context,Color bg,{VoidCallback? press=onPress,VoidCallback? press2=onPress}) {
  return AppBar(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
        statusBarBrightness: Brightness.light, // For iOS (dark icons)
      ),
      surfaceTintColor: Colors.transparent,
      // backgroundColor: bg,
      backgroundColor: Colors.transparent,
      flexibleSpace: const Image(image: AssetImage(AssetsPics.appBarbg),
        fit: BoxFit.fitWidth,
        alignment: Alignment.topCenter,
      ),
      centerTitle: true,
      leadingWidth: 50,
      leading: GestureDetector(
        onTap: press,
        child: Padding(
          padding: const EdgeInsets.only(left: 15,top: 15,bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20)
            ),
              padding: EdgeInsets.only(left: 7,right: 7),
              child: SvgPicture.asset(AssetsPics.arrowLeft)),
        ),
      ),
      title: Container(padding: const EdgeInsets.only(top: 10),
        child: GestureDetector(
          onTap: press2,
          child: Align(
              alignment: Alignment.centerRight,child: buildText("Skip", 20, FontWeight.w600, color.txtgrey2)),
        ),
      ));
}

PreferredSizeWidget commonBarWithTextleft(BuildContext context,Color bg,String txt,{VoidCallback? press=onPress,bool tran=false}) {
  return AppBar(
      forceMaterialTransparency: tran,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
        statusBarBrightness: Brightness.light, // For iOS (dark icons)
      ),
    elevation: 0.0,
      surfaceTintColor: Colors.transparent,
      // backgroundColor: bg,
      backgroundColor: Colors.transparent,
      flexibleSpace:txt=="Ticket Details"?null: const Image(image: AssetImage(AssetsPics.appBarbg),
          fit: BoxFit.fitWidth,
          alignment: Alignment.topCenter,
      ),
      centerTitle: true,
      leadingWidth: 50,
      leading: GestureDetector(
        onTap: press,
        child: Padding(
          padding: const EdgeInsets.only(left: 14,top: 13,bottom: 6),
          child: Container(
              decoration: BoxDecoration(
                // color: Colors.red,
                  borderRadius: BorderRadius.circular(20)
              ),
              padding: EdgeInsets.only(left: 9,right: 8),
              child: SvgPicture.asset(AssetsPics.arrowLeft)),
        ),
      ),
      title: Container(padding: const EdgeInsets.only(top: 10),
        child: Align(
            alignment: Alignment.centerLeft,child: buildText(txt, 24, FontWeight.w600, color.txtBlack)),
      ));
}

PreferredSizeWidget commonBarWithTextleftforChat(BuildContext context,Color bg,String txt,{VoidCallback? press=onPress,VoidCallback? press2=onPress,bool tran=false,}) {
  return AppBar(
      forceMaterialTransparency: tran,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
        statusBarBrightness: Brightness.light, // For iOS (dark icons)
      ),
      elevation: 0.0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: bg,
      centerTitle: true,
      leadingWidth: 50,
      leading: GestureDetector(
        onTap: press,
        child: Padding(
          padding: const EdgeInsets.only(left: 14,top: 12,bottom: 6),
          child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20)
              ),
              padding: EdgeInsets.only(left: 8,right: 8),
              child: SvgPicture.asset(AssetsPics.arrowLeft)),
        ),
      ),actions: [
    GestureDetector(
      onTap: press2,
      child: Padding(
        padding: const EdgeInsets.only(right: 15,top: 9),
        child: SvgPicture.asset(AssetsPics.infoicon,),
      ),
    )
  ],
      title: Container(padding: const EdgeInsets.only(top: 10),
        child: Align(
            alignment: Alignment.centerLeft,child: buildText(txt, 24, FontWeight.w600, color.txtBlack)),
      ));
}
void onPress(){
  Get.back();
}