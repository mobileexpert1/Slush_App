import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/screens/getstarted/slider_scree.dart';
import 'package:slush/screens/sign_up/location_access.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/text_widget.dart';

class AccountSuspended extends StatefulWidget {
  const AccountSuspended({Key? key}) : super(key: key);

  @override
  State<AccountSuspended> createState() => _AccountSuspendedState();
}

class _AccountSuspendedState extends State<AccountSuspended> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: color.txtBlue,
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Image.asset(
              AssetsPics.bluebg,
              fit: BoxFit.cover,
            ),
            // decoration: BoxDecoration(image: DecorationImage(image: Image.asset("assets/bg/blue_bg.png"))),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 160, left: 40),
            child: Container(
                height: 35.h,
                width: 36.h,
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  AssetsPics.bigheart,
                  fit: BoxFit.cover,
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 32.h),
                    Stack(
                      children: [
                        Positioned(
                          right: 100,
                          child: Container(
                            alignment: Alignment.center,
                            child: SvgPicture.asset(AssetsPics.threeDots),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: SvgPicture.asset(AssetsPics.accountLock),
                        ),
                      ],
                    ),
                    buildText("Account suspened", 28, FontWeight.w600, color.txtWhite),
                    buildText("Your account has been suspended.", 20, FontWeight.w500, color.txtWhite),
                    SizedBox(height: 2.h),
                    buildText2("To learn more please contact us using the email address below", 20,
                        FontWeight.w400, color.txtWhite, fontFamily: FontFamily.hellix),
                    SizedBox(height: 2.h),
                    Container(
                      height: 44,
                      width: 277,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(39),
                        color: color.example10,
                      ),
                      child: buildText("support@slushdating.com", 18,
                          FontWeight.w600, color.txtWhite),
                    ),
                    const Spacer(),
                    white_button(context, "Understood", press: () {
                      Get.offAll(() => const SliderScreen());
                    }),
                    SizedBox(height: 2.h + 4),
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
