import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/localkeys.dart';
import 'package:slush/screens/login/login.dart';
import 'package:slush/screens/sign_up/create_account.dart';
import 'package:slush/widgets/alert_dialog.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/text_widget.dart';

class SliderScreen extends StatefulWidget {
  const SliderScreen({Key? key}) : super(key: key);

  @override
  State<SliderScreen> createState() => _SliderScreenState();
}

class _SliderScreenState extends State<SliderScreen> {
  final images = [AssetsPics.sliderthird];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          Stack(
            children: [
              SizedBox(
                  width: size.width,
                  height: size.height,
                  child: Image.asset(AssetsPics.ticketbackground, fit: BoxFit.fill)),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: buildCarouselSlider(size),
              ),
            ],
          ),
          Positioned(
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Column(
                children: [
                  Expanded(child: Container()),
                  Text.rich(TextSpan(children: [
                    buildTextSpan('Welcome to ', color.txtBlack),
                    buildTextSpan('Slush', color.txtBlue),
                  ])),
                  Text.rich(TextSpan(children: [
                    buildTextSpan('Break the Ice Through', color.txtBlack),
                    buildTextSpan(' Video', color.txtBlack),
                  ])),
                  const SizedBox(height: 4),
                  buildText2(LocaleText.likeMatch, 16, FontWeight.w500, color.txtgrey, fontFamily: FontFamily.hellix),
                  const SizedBox(height: 18),
                  blue_button(context, "Create account", press: ()async {
                    Get.to(() => const CreateNewAccount());
                  }),
                  const SizedBox(height: 15),
                  loginbutton(),
                   SizedBox(height: 3.h),
                ],
              ),
            ),
          ),
          bioAlert(context),

        ],
      ),
    );
  }

  Widget buildCarouselSlider(Size size) {
    return CarouselSlider.builder(
        itemCount: images.length,
        itemBuilder: (context, itemIndex, pageViewIndex) {
          return Stack(
            children: [
              SizedBox(width: size.width, height: size.height-180,child: Image.asset(AssetsPics.BG,fit: BoxFit.cover))
            ],
          );
        },
        options: CarouselOptions(
            viewportFraction: 1.0,
            height: size.height,
          scrollPhysics: NeverScrollableScrollPhysics()
        ));
  }

  TextSpan buildTextSpan(String txt, Color clr) {
    return TextSpan(text: txt,
        style: TextStyle(color: clr,
            fontWeight: FontWeight.w600,
            // fontSize: 26,
            fontSize: 21.sp,
            fontFamily: FontFamily.baloo2));
  }

  Widget loginbutton() {
    return GestureDetector(
      onTap: () {
        Get.to(() => const LoginScreen());
      },
      child: Container(
        alignment: Alignment.center,
        height: 56,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: color.txtWhite,
            border: Border.all(width: 1, color: color.txtBlue)),
        child: buildText("Login", 18, FontWeight.w600, color.txtBlue),
      ),
    );
  }
}
