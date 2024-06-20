import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/screens/sign_up/location_access.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/text_widget.dart';

class SignUpDetailsCompletedScreen extends StatefulWidget {
  const SignUpDetailsCompletedScreen({Key? key}) : super(key: key);

  @override
  State<SignUpDetailsCompletedScreen> createState() => _SignUpDetailsCompletedScreenState();
}

class _SignUpDetailsCompletedScreenState extends State<SignUpDetailsCompletedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: color.txtBlue,
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Image.asset(AssetsPics.bluebg,fit: BoxFit.cover,),
            // decoration: BoxDecoration(image: DecorationImage(image: Image.asset("assets/bg/blue_bg.png"))),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 100,left: 40),
            child: Container(
              height: 35.h,
              width: 36.h,
                alignment: Alignment.center,
                child: SvgPicture.asset(AssetsPics.bigheart,fit: BoxFit.cover,)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15,right: 15),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 26.h),
                    Container(
                      alignment: Alignment.center,
                      child: SvgPicture.asset(AssetsPics.congo),),
                    buildText("Congratulations !", 28, FontWeight.w600, color.txtWhite),
                    buildText("Your profile setup is complete", 20, FontWeight.w500, color.txtWhite),
                     SizedBox(height: 2.h),
                    buildText2("Press continue to view upcoming speed date events or view user profiles.", 20, FontWeight.w500, color.txtWhite,fontFamily: FontFamily.hellix),
                    const Spacer(),
                    white_button(context, "Continue",press: (){
                      Get.to(()=>const SignUpLocationAccessScreen());
                    }),
                     SizedBox(height: 2.h+4),

                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
