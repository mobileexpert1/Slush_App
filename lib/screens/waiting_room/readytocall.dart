import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/localkeys.dart';
import 'package:slush/screens/events/bottomNavigation.dart';
import 'package:slush/screens/video_call/videoCall.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:slush/widgets/text_widget.dart';

class ReadyToCallScreen extends StatefulWidget {
  const ReadyToCallScreen({Key? key}) : super(key: key);

  @override
  State<ReadyToCallScreen> createState() => _ReadyToCallScreenState();
}

class _ReadyToCallScreenState extends State<ReadyToCallScreen> {
  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(height: size.height,width: size.width,
          child: Image.asset(AssetsPics.background,fit: BoxFit.fill,),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15,right: 15,top: 30,bottom: 10),
            child: Column(children: [
              Container(margin: EdgeInsets.only(top: 25), alignment: Alignment.topRight, child: SvgPicture.asset(AssetsPics.notificationI)),
              const SizedBox(height: 20),
              buildText("Speed Date", 28, FontWeight.w600, color.txtBlack),
              const SizedBox(height: 15),
              buildText("Get ready to date and find your match", 16, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
              const SizedBox(height: 55),
            Container(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(AssetsPics.example5),
                      const SizedBox(width: 25),
                      Image.asset(AssetsPics.example4),
                    ],
                  ),
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.transparent,
                    child: SvgPicture.asset(AssetsPics.bluecam),
                  )
                ],
              ),
            ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildText("Steve", 18, FontWeight.w600, color.txtBlack),
                  const SizedBox(width: 70),
                  buildText("Maria", 18, FontWeight.w600, color.txtBlack),
                ],
              ),
              const SizedBox(height: 55),
              buildText("Date number 2 out of 16", 20, FontWeight.w600, color.txtBlack),
              const SizedBox(height: 15),
              SizedBox(
                width: 280,
                child: buildText2(" “Keep the sparks flying with our app - Slush!”", 16, FontWeight.w500, color.txtBlack,fontFamily: FontFamily.hellix),
              ),
             const Spacer(),
              blue_button(context, "Video Date",press: (){
                customDialogBoxx(context,"Not sure what to do?",LocaleText.guidetext1,"I’m ready",AssetsPics.guide1,isPng: true,
                onTap: (){
                  Get.back();
                  customDialogBoxwithtitle(context, LocaleText.guidetext2, "Join Now", AssetsPics.guide2,isPng: true,onTap: (){
                    Get.back();
                    customDialogBoxwithtitle(context, LocaleText.guidetext3, "Ok", AssetsPics.guide3,isPng: true,onTap: (){
                      Get.back();
                      Get.off(()=>const VideoCallScreen());
                    });
                  });
                });
              }),
              const SizedBox(height: 15),
              white_button(context, "Leave Event",press: (){
                Get.offAll(BottomNavigationScreen());
              }),
              const SizedBox(height: 15),
            ],),
          )
        ],
      ),
    );
  }
  TextSpan buildTextSpan(String txt, Color clr) {
    return TextSpan(
        text: txt,
        style: TextStyle(color: clr,
            fontWeight: FontWeight.w500, fontSize: 16,
            fontFamily: FontFamily.hellix));
  }
  customDialogBoxx( BuildContext context,String title, String heading,String btnTxt,String img,{
    VoidCallback? onTapp=pressed, VoidCallback? onTap=pressed, bool isPng=false}) {
    return showGeneralDialog(
        barrierLabel: "Label",
        transitionDuration: const Duration(milliseconds: 500),
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return GestureDetector(
            onTap: onTapp,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  // height: MediaQuery.of(context).size.height/2.5,
                    width: MediaQuery.of(context).size.width/1.1,
                    margin: const EdgeInsets.symmetric(horizontal: 16,vertical: 24),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: color.txtWhite,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(alignment: Alignment.center,
                          height: 80, width: 80,
                          child:isPng?Image.asset(img): SvgPicture.asset(img),
                        ),
                        const SizedBox(height: 10),
                        buildText(title, 20, FontWeight.w600, color.txtBlack),
                        SizedBox(height: 1.h),
                        buildText2(heading, 16, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
                        Text.rich(
                            textAlign: TextAlign.center,
                            TextSpan(children: [
                          buildTextSpan('\nSimply, ', color.txtgrey),
                          buildTextSpan('tap the video-date ', color.txtBlue),
                          buildTextSpan('button  below in order to begin your date.\n ', color.txtgrey),
                        ])),
                        const SizedBox(height: 15),
                        blue_button(context, btnTxt!,press: onTap)
                      ],
                    )),
              ),
            ),
          );
        },
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
            position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(anim1),
            child: child,
          );}
    );
  }
}


