import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/localkeys.dart';
import 'package:slush/screens/video_call/congo_match_screen.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:http/http.dart'as http;

class FeedbackVideoChatScreen extends StatefulWidget {
  const FeedbackVideoChatScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackVideoChatScreen> createState() => _FeedbackVideoChatScreenState();
}

class _FeedbackVideoChatScreenState extends State<FeedbackVideoChatScreen> {
  List reportingMatter = [
    "Did not have much in common",
    "Nudity / inappropriate",
    "Swearing / Aggression",
    "I have joined the wrong event",
    "I left the video-call by accident",
    "They are in the wrong event",
  ];
  int selectedIndex = -1;
  late Timer _timer;
  int _secondsLeft = 60;
  @override
  void initState() {
    super.initState();
    startTimer();
  }
  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        // actionForHItLike("DISLIKED");
        _timer.cancel();
        customBuilderSheet(context, 'Is everything OK?',"Submit", heading: LocaleText.feedbackguide1);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitSeconds";
  }

  Future actionForHItLike(String action,String id)async{
    final url= "${ApiList.action}$id/action";
    var uri=Uri.parse(url);
    var response=await http.post(uri,
    headers: {'Content-Type': 'application/json', "Authorization": "Bearer ${LocaleHandler.accessToken}"},
      body: jsonEncode({"action":action})
    );
    if(response.statusCode==201){}
    else if(response.statusCode==401){}
    else{}
  }
  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    final duration = Duration(minutes: 60);
    final milliseconds = duration.inMilliseconds;
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: size.height,
            width: size.width,
            child: Image.asset(AssetsPics.background,fit: BoxFit.cover,),
          ),
          SafeArea(
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 18,vertical: 15),
              child: Column(
              children: [
                CircularPercentIndicator(radius: 37,
                backgroundColor: Colors.transparent,
                    progressColor: color.txtBlack,
                    animation: true,
                    animationDuration: 60000,
                    circularStrokeCap: CircularStrokeCap.round,
                    lineWidth: 4.6,
                    percent:  1,
                  center: Column(
                    children: [
                      const SizedBox(height: 17),
                      buildText2(formatDuration(Duration(seconds: _secondsLeft)), 30, FontWeight.w700, color.txtBlack),
                    ],
                  ),
                ),
                SizedBox(height: 2.h+2),
                buildText("Did you like them?", 24, FontWeight.w600, color.txtBlack),
                SizedBox(height: 2.h+2),
                Container(
                  height: 16.h,
                  width: 16.h,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SvgPicture.asset(AssetsPics.videocalledperson,fit: BoxFit.cover,),
                      Container(
                        height: 13.h,
                        width: 13.h,
                        decoration: BoxDecoration(
                          color: Colors.white54,
                          borderRadius: BorderRadius.circular(38)
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(38),
                          child: Image.asset(AssetsPics.sample,fit: BoxFit.cover,)),
                      )
                    ],
                  ),
                ),
                SizedBox(height:2.h+2),
                buildText("Josep,26", 20, FontWeight.w600, color.txtBlack),
                SizedBox(height: 2.h+2),
                buildText2(LocaleText.feedbackguide, 16, FontWeight.w400, color.txtgrey),
              ],
            ),),
          ),
          Positioned(
            bottom: 0.0,
            child: Container(
              padding: const EdgeInsets.only(left: 20,right: 20,top: 30),
              width: size.width,
              height: 40.h,
              decoration: const BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(40)),color: color.txtWhite),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  GestureDetector(
                      onTap: (){
                        actionForHItLike("DISLIKED","502");
                        // _timer.cancel();
                        customBuilderSheet(context, 'Is everything OK?',"Submit", heading: LocaleText.feedbackguide1,onTap: (){});
                      },
                      child: buildColumn("Dislike",AssetsPics.dislike,8.h)),
                  const SizedBox(width: 15),
                  GestureDetector(onTap: (){
                    actionForHItLike("LIKED","502");
                    _timer.cancel();
                    Get.off(()=>const CongratMatchScreen());}, child: buildColumn("Like",AssetsPics.heart,10.h)),
                    const SizedBox(width: 15),
                    GestureDetector(
                        onTap: (){
                          customSparkBottomSheet(context,AssetsPics.sparkleft, "Are you sure you would like to use 1 x Spark?", "Cancel", "Yes",true,
                          onTap2: (){Get.back();
                            customSparkBottomSheet(context,AssetsPics.sparkempty, " You have run out of Sparks, please purchase  more.", "Cancel", "Purchase",false);
                          });},child: buildColumn("Spark",AssetsPics.superlike,8.h)),
                ],),
                const SizedBox(height: 25),
                Text.rich(
                    textAlign: TextAlign.center,
                    TextSpan(children: [
                      buildTextSpan('Tap ', color.txtgrey),
                      buildTextSpan('’Like’ ', color.txtBlue),
                      buildTextSpan("if you liked them.", color.txtgrey),
                    ])),
                Text.rich(
                    textAlign: TextAlign.center,
                    TextSpan(children: [
                      buildTextSpan("If it's mutual, you'll ", color.txtgrey),
                      buildTextSpan("‘Match’", color.txtBlue),
                      buildTextSpan(" and can chat.", color.txtgrey),
                    ])),
                Text.rich(
                    textAlign: TextAlign.center,
                    TextSpan(children: [
                      buildTextSpan("If not, tap ", color.txtgrey),
                      buildTextSpan("’Dislike’ ", color.txtBlue),
                      buildTextSpan("if you are not interested.", color.txtgrey),
                    ])),
                Text.rich(
                    textAlign: TextAlign.center,
                    TextSpan(children: [
                      buildTextSpan("Tap the ", color.txtgrey),
                      buildTextSpan("’Spark’ ", color.txtBlue),
                      buildTextSpan("if you think they could be the one.", color.txtgrey),
                    ])),
              ],),
            ),
          )
        ],
      ),
    );
  }

  Column buildColumn(String txt,String img,double hi) {
    return Column(children: [
                  buildText(txt, 15, FontWeight.w600, color.txtBlack),
                  Container(
                    alignment: Alignment.center,
                    height: hi,
                    width: hi,
                    decoration:  BoxDecoration(
                      color:txt=="Like"? color.txtBlue:Colors.white,
                      shape: BoxShape.circle,
                        boxShadow:const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 20.0,
                              offset: Offset(0.0,10.0)
                          )
                        ]
                    ),
                    child: SvgPicture.asset(img),
                  )
                ],);
  }


  
  TextSpan buildTextSpan(String txt, Color clr) {
    return TextSpan(
        text: txt,
        style: TextStyle(color: clr,
            fontWeight: FontWeight.w400, fontSize: 16,
            fontFamily: FontFamily.hellix,));
  }



  customBuilderSheet(BuildContext context,String title, String btnTxt,
      {
        required String heading,
        VoidCallback? onTapp = pressed,
        VoidCallback? onTap = pressed,
        bool? forAdvanceTap}) {
    return showGeneralDialog(
        barrierLabel: "Label",
        transitionDuration: const Duration(milliseconds: 500),
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return GestureDetector(
            // onTap: pressed,
          // return WillPopScope(
          //   onWillPop: () async => false,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    height: MediaQuery.of(context).size.height / 1.65,
                    width: MediaQuery.of(context).size.width / 1.1,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: color.txtWhite,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const SizedBox(height: 10),
                        buildText(title, 20, FontWeight.w600, color.txtBlack),
                        buildText2(heading, 18, FontWeight.w500, color.txtgrey,
                            fontFamily: FontFamily.hellix),
                        Expanded(
                          child: StatefulBuilder(
                              builder: (BuildContext context, StateSetter setState) {
                                return ListView.builder(
                                    itemCount: reportingMatter.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        child: GestureDetector(
                                          onTap: () {setState(() {selectedIndex = index;});},
                                          child: Container(
                                            color: Colors.transparent,
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor:
                                                  selectedIndex == index ? color.txtBlue : color.txtBlack,
                                                  radius: 9,
                                                  child: CircleAvatar(
                                                    radius: 8,
                                                    backgroundColor: selectedIndex == index ? color.txtWhite : color.txtWhite,
                                                    // backgroundImage: SvgPicture.asset(AssetsPics.arrowLeft),
                                                    child: selectedIndex == index ? SvgPicture.asset(AssetsPics.blueTickCheck, fit: BoxFit.cover,) : const SizedBox(),
                                                  ),
                                                ),
                                                const SizedBox(width: 10,),
                                                buildText2(reportingMatter[index], 17.sp, FontWeight.w500, color.txtgrey, fontFamily: FontFamily.hellix),
                                                // Text(reportingMatter[index]),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    });
                              }),
                        ),
                        const SizedBox(height: 15),
                        blue_button(context, btnTxt, press: onTapp)
                      ],
                    )),
              ),
            ),
          );
        },
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
            position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
                .animate(anim1),
            child: child,
          );
        });
  }

  customSparkBottomSheet(BuildContext context,String img ,String title, String btnTxt1, String btnTxt2, bool isSparkLeft,{
    VoidCallback? onTapp = pressed,
    VoidCallback? onTap1=pressed,
    VoidCallback? onTap2=pressed,
    bool? forAdvanceTap}) {
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
                    width: MediaQuery.of(context).size.width / 1.1,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: color.txtWhite,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Image.asset(img,fit: BoxFit.cover,),
                         SizedBox(height:isSparkLeft? 10:0),
                        isSparkLeft? Container(
                          height: 32,
                          width: 140,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: color.example4
                          ),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(AssetsPics.star,height: 20),
                              SizedBox(width: 5),
                              buildText("3 Sparks left",14,FontWeight.w600,color.txtBlack),
                            ],),):const SizedBox(),
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.only(left: 8,right: 8),
                          child: buildText2(title, 20, FontWeight.w600, color.txtBlack),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: onTap1,
                              child: Container(
                                alignment: Alignment.center,
                                height: 56,
                                width: MediaQuery.of(context).size.width/2-45,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                                    color: color.txtWhite,
                                    border: Border.all(width: 1.5,color: color.txtBlue)
                                ),
                                child: buildText(btnTxt1,18,FontWeight.w600,color.txtBlue),
                              ),
                            ),
                            GestureDetector(
                              onTap: onTap2,
                              child: Container(
                                alignment: Alignment.center,
                                height: 56,
                                width: MediaQuery.of(context).size.width/2-45,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                                    gradient:  const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
                                      colors:[color.gradientLightBlue, color.txtBlue],)
                                ),
                                child: buildText(btnTxt2,18,FontWeight.w600,color.txtWhite),
                              ),
                            ),
                          ],),
                         const SizedBox(height: 8),
                      ],
                    )),
              ),
            ),
          );
        },
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
            position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
                .animate(anim1),
            child: child,
          );
        });
  }
}
