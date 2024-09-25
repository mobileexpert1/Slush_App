
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/localkeys.dart';
import 'package:slush/constants/prefs.dart';
import 'package:slush/screens/getstarted/slider_scree.dart';
import 'package:slush/widgets/alert_dialog.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  PageController controller = PageController();

  final messages = [LocaleText.slushevent, LocaleText.vidmeetswiping, "Like & Match"];
  final messages2 = [LocaleText.joindiverse, LocaleText.everything, LocaleText.expressinterest,];
  final images = [AssetsPics.firstBg, AssetsPics.secondBg, AssetsPics.thirdBg];

  int numberOfPages = 3;
  int currentPage = 0;
  int value = 40;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          pageview_builder(),
          Center(
              child: Column(
            children: [
              Align(alignment: Alignment.bottomRight,
                  child: Padding(padding:  EdgeInsets.only(top: 7.h, right: 3.h),
                    child: GestureDetector(
                        onTap: () {
                          Preferences.setValue("tutorialScreen", "done");
                          Get.offAll(() => const SliderScreen());
                        },
                        child: buildText2("Skip", 18, FontWeight.w600, color.txtWhite)),
                  )),
              const Spacer(),
              page_indicator(),
              SizedBox(height: 3.h),
              circle_progress_bar(),
               SizedBox(height: 3.h),
            ],
          )),
          bioAlert(context),
        ],
      ),
    );
  }

  Widget pageview_builder() {
    return PageView.builder(
      controller: controller,
      itemCount: numberOfPages,
      onPageChanged: (indexx) {
        setState(() {
          currentPage = indexx;
          if (indexx == 0) {value = 40;}
          else if (indexx == 1) {value = 70;}
          else {value = 100;}
        });
      },
      itemBuilder: (BuildContext context, int index) {
        return EachPage(messages[index], images[index], messages2[index]);
      },
    );
  }

  Widget page_indicator() {
    return SmoothPageIndicator(
      controller: controller,
      count: images.length,
      axisDirection: Axis.horizontal,
      textDirection: TextDirection.ltr,
      effect: const ScaleEffect(
        dotWidth: 8.5,
        dotHeight: 6.0,
        spacing: 5.0,
        activeDotColor: Colors.blue,
        dotColor: Colors.white,
        activeStrokeWidth: 1.0,
        radius: 25.0,
        offset: 20.0,
      ),
    );
  }

  Widget circle_progress_bar() {
    return GestureDetector(
      onTap: () {
        if (numberOfPages == currentPage + 1) {
          Preferences.setValue("tutorialScreen", "done");
          Get.offAll(() => const SliderScreen());
        } else {
          controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 35.0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [color.gradientLightBlue, color.gradientDarkBlue],
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.white54,
                            blurRadius: 20.0,
                            offset: Offset(0.0,10.0)
                        )
                      ]
                  ),

                ),
                IgnorePointer(child: SvgPicture.asset(AssetsPics.arroeRight)),
              ],
            ),
          ),
          SizedBox(
            height: 100,
            width: 100,
            child: CircularPercentIndicator(
                radius: 47.0,
                backgroundColor: Colors.transparent,
                progressColor: Colors.white,
                animation: true,
                animateFromLastPercent: true,
                circularStrokeCap: CircularStrokeCap.round,
                lineWidth: 4.6,
                percent: value / 100),
          ),
        ],
      ),
    );
  }
}

class EachPage extends StatelessWidget {
  final String message;
  final String message2;
  final String image;

  EachPage(this.message, this.image, this.message2);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            SizedBox(height: size.height,
                width: size.width,
                child: Image.asset(image, fit: BoxFit.fill)),
            SizedBox(height: size.height, width: size.width, child: SvgPicture.asset(AssetsPics.blackbackground,fit: BoxFit.cover),),
            Container(
              alignment: Alignment.topCenter,
              width: size.width,
              child: SvgPicture.asset(AssetsPics.introblackupperbg),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                   SizedBox(height: 61.h),
                  buildText(message, 28, FontWeight.w600, color.txtWhite),
                  const SizedBox(height: 8),
                  Container(child: buildText2(message2, 16, FontWeight.w500, color.txtWhite, fontFamily: FontFamily.hellix))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
