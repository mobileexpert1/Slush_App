import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/localkeys.dart';
import 'package:slush/controller/video_call_controller.dart';
import 'package:slush/screens/events/bottomNavigation.dart';
import 'package:slush/screens/video_call/feedback_screen.dart';
import 'package:slush/screens/video_call/videoCall.dart';
import 'package:slush/screens/waiting_room/firebase_firestore_service.dart';
import 'package:slush/screens/waiting_room/waiting_completed_screen.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:slush/widgets/text_widget.dart';

class ReadyToCallScreen extends StatefulWidget {
  final data;

  const ReadyToCallScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<ReadyToCallScreen> createState() => _ReadyToCallScreenState();
}

class _ReadyToCallScreenState extends State<ReadyToCallScreen> {
  // final NotificationService _notificationService = NotificationService();
  bool onlyonce = true;
  bool onlyaceptonce = true;
  bool onlyrejectonce = true;

  @override
  void initState() {
    callFunction();
    // _notificationService.initialize();
    super.initState();
  }

  callFunction() async {
    LocaleHandler.eventParticipantData = widget.data;
    Provider.of<TimerProvider>(context, listen: false).startTimerr();
    startTimer();
    Future.delayed(const Duration(seconds: 3));
    Provider.of<TimerProvider>(context,listen: false).updateFixtureStatus(LocaleHandler.eventParticipantData["participantId"], "JOINED");
    final cameraStatus = await Permission.camera.status;
    final microphoneStatus = await Permission.microphone.status;
    if (!cameraStatus.isGranted || !microphoneStatus.isGranted) {await [Permission.camera, Permission.microphone].request();}
  }

  late Timer _timer;

  void startTimer() {
    int mins = Provider.of<TimerProvider>(context, listen: false).durationn - 300;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mins > 0) {
        setState(() {mins--;});
        print(";-;-;-;-$mins");
        if (mins - 5 == 5) {
          print(";-;-;-;-");
          FireStoreService().updateCallStatusToPicked("reject");
          // customDialogBoxwithtitle(context, LocaleText.guidetext3, "Ok", AssetsPics.guide3,isPng: true,onTap: (){
          //   Get.back();   Get.offAll(()=>WaitingCompletedFeedBack(data: LocaleHandler.eventdataa)); });
        }
      } else {
        Get.back();
        Get.offAll(() => WaitingCompletedFeedBack(data: LocaleHandler.eventdataa));
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            SizedBox(
                height: size.height,
                width: size.width,
                child: Image.asset(AssetsPics.background, fit: BoxFit.fill)),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15, right: 15, top: 0, bottom: 10),
              child: Column(
                children: [
                  Container(height: size.height * 0.04),


                  Container(
                      margin: const EdgeInsets.only(top: 20),
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                          onTap: (){
                            customDialogBoxx(context, "Not sure what to do?",
                                LocaleText.guidetext1, "I’m ready", AssetsPics.guide1,
                                isPng: true, onTap: () {
                                  // FireStoreService().addCollection();
                                  Get.back();
                                  // customDialogBoxwithtitle(context, LocaleText.guidetext2, "Join Now", AssetsPics.guide2,isPng: true,onTap: (){
                                  //   Get.back();
                                  //   Get.to(()=> const VideoCallScreen());
                                  //   _timer.cancel();
                                  // });
                                });
                          },
                          child: SvgPicture.asset(AssetsPics.notificationI))),
                  // Container(height: 20),
                  Container(height: size.height * 0.02),
                  buildText("Speed Date", 28, FontWeight.w600, color.txtBlack),
                  const SizedBox(height: 15),
                  buildText("Get ready to date and find your match", 16,
                      FontWeight.w500, color.txtgrey,
                      fontFamily: FontFamily.hellix),
                  // const SizedBox(height: 55),
                  Container(height: size.height * 0.06),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RotationTransition(
                              turns: const AlwaysStoppedAnimation(-7 / 360),
                              child: Container(
                                  decoration: BoxDecoration(color: Colors.white54, borderRadius: BorderRadius.circular(40)),
                                  padding: const EdgeInsets.all(4),
                                  height: 20.h,
                                  width: 19.h,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(40),
                                      child: CachedNetworkImage(imageUrl: LocaleHandler.avatar, fit: BoxFit.cover)))),
                          // Image.asset(AssetsPics.example5),
                          const SizedBox(width: 25),
                          // Image.asset(AssetsPics.example4),
                          RotationTransition(
                              turns: const AlwaysStoppedAnimation(7 / 360),
                              child: Container(
                                  decoration: BoxDecoration(color: Colors.white54, borderRadius: BorderRadius.circular(40)),
                                  padding: const EdgeInsets.all(4),
                                  height: 20.h,
                                  width: 19.h,
                                  child: ClipRRect(borderRadius: BorderRadius.circular(40),
                                      child: CachedNetworkImage(imageUrl: widget.data["avatar"], fit: BoxFit.cover)))),
                        ],
                      ),
                      CircleAvatar(radius: 45, backgroundColor: Colors.transparent, child: SvgPicture.asset(AssetsPics.bluecam),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // buildText("Steve", 18, FontWeight.w600, color.txtBlack),
                      buildText(LocaleHandler.name, 18, FontWeight.w600,
                          color.txtBlack),
                      SizedBox(width: size.width * 0.3),
                      // buildText("Maria", 18, FontWeight.w600, color.txtBlack),
                      buildText(widget.data["firstName"], 18, FontWeight.w600, color.txtBlack),
                    ],
                  ),
                  // const SizedBox(height: 55),
                  Container(height: size.height * 0.06),
                  buildText("Date number ${LocaleHandler.dateno} out of ${LocaleHandler.totalDate}",
                      20, FontWeight.w600, color.txtBlack),
                  const SizedBox(height: 15),
                  SizedBox(width: 280,
                    child: buildText2(" “Keep the sparks flying with our app - Slush!”", 16, FontWeight.w500, color.txtBlack, fontFamily: FontFamily.hellix),
                  ),
                  const Spacer(),

                  // TimerProgressIndicator(),
                 // const SizedBox(height: 10),

                  Flexible(
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FireStoreService().getCallStatusStream(),
                      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.hasError) {return buildSizedBox();}
                        if (!snapshot.hasData || !snapshot.data!.exists) {return buildSizedBox();}
                        else if (snapshot.hasData) {
                          var data = snapshot.data!.data() as Map<String, dynamic>;
                          if (data['callstatus'] == "wait" && data['createdUserId'] != LocaleHandler.userId) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (onlyonce) {
                                onlyonce = false;
                                customDialogBoxwithtitle(context, LocaleText.guidetext2, "Join Now", AssetsPics.guide2, isPng: true, onTap: () {
                                  Get.back();
                                  FireStoreService().updateCallStatusToPicked("accept");
                                  Get.offAll(() => const VideoCallScreen());
                                  _timer.cancel();
                                });
                              }
                            });
                            return buildSizedBox();
                          } else if (data['callstatus'] == "wait" && data['createdUserId'] == LocaleHandler.userId) {
                            // return SizedBox(height: size.height * 0.04, child: const Text('please wait for second person response'));
                          } else if (data['callstatus'] == "accept" && data['createdUserId'] == LocaleHandler.userId) {
                            // WidgetsBinding.instance.addPostFrameCallback((_) {if(onlyaceptonce){onlyaceptonce=false;Get.offAll(() => const VideoCallScreen());_timer.cancel();}});
                          }
                          else if (data['callstatus'] == "reject" ) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {if(onlyrejectonce){onlyrejectonce=false;
                                customDialogBoxwithtitle(context, LocaleText.guidetext3, "Ok", AssetsPics.guide3,isPng: true,onTap: (){Get.back();
                                // Get.offAll(()=>WaitingCompletedFeedBack(data: LocaleHandler.eventdataa));
                                Get.offAll(() => const FeedbackVideoChatScreen());
                                });_timer.cancel();}});
                          }
                        }
                        return buildSizedBox();
                      },
                    ),
                  ),

                  Stack(
                    // alignment: Alignment.center,
                    children: [
                    Column(children: [
                      blue_button(context, "Video Date", press: () {
                        FireStoreService().addCollection();
                        Get.back();
                        Get.to(()=> const VideoCallScreen());
                        _timer.cancel();
                        // customDialogBoxwithtitle(context, LocaleText.guidetext2, "Join Now", AssetsPics.guide2,isPng: true,onTap: (){
                        //   FireStoreService().addCollection();Get.back();Get.to(()=> const VideoCallScreen());_timer.cancel();});
                      }),
                      // const SizedBox(height: 15),
                      SizedBox(height: size.height * 0.02),
                      white_button(context, "Leave Event", press: () {
                        Provider.of<TimerProvider>(context,listen: false).stopTimerr();
                        customSparkBottomSheeet(context,
                            AssetsPics.guide2,
                            "Are you sure you want to leave the event", "Cancel", "Leave", onTap2: () {
                              Get.back();
                              LocaleHandler.bottomSheetIndex = 0;
                              Get.offAll(BottomNavigationScreen());
                              _timer.cancel();
                            });
                      }),
                    ],),
                    Container(
                      padding: EdgeInsets.only(left: size.width*0.5+5),
                      child: Lottie.asset('assets/animation/ClickAnimation.json',
                        repeat: true,
                        width: size.width*0.3-20,
                        height:  size.width*0.3-20,
                      ),
                    ),
                  ],),
                  // const SizedBox(height: 15),
                  SizedBox(height: size.height * 0.01)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  SizedBox buildSizedBox() => const SizedBox(height: 10);

  TextSpan buildTextSpan(String txt, Color clr) {
    return TextSpan(
        text: txt,
        style: TextStyle(
            color: clr,
            fontWeight: FontWeight.w500,
            fontSize: 16,
            fontFamily: FontFamily.hellix));
  }

  customDialogBoxx(BuildContext context, String title, String heading,
      String btnTxt, String img,
      {VoidCallback? onTapp = pressed,
      VoidCallback? onTap = pressed,
      bool isPng = false}) {
    return showGeneralDialog(
        barrierLabel: "Label",
        barrierDismissible: true,
        transitionDuration: const Duration(milliseconds: 500),
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  // height: MediaQuery.of(context).size.height/2.5,
                  width: MediaQuery.of(context).size.width / 1.1,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: color.txtWhite,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        height: 80,
                        width: 80,
                        child: isPng ? Image.asset(img) : SvgPicture.asset(img),
                      ),
                      buildSizedBox(),
                      buildText(title, 20, FontWeight.w600, color.txtBlack),
                      SizedBox(height: 1.h),
                      buildText2(heading, 16, FontWeight.w500, color.txtgrey, fontFamily: FontFamily.hellix),
                      Text.rich(
                          textAlign: TextAlign.center,
                          TextSpan(children: [
                            buildTextSpan('\nSimply, ', color.txtgrey),
                            buildTextSpan('tap the video-date ', color.txtBlue),
                            buildTextSpan('button  below in order to begin your date.\n ', color.txtgrey),
                          ])),
                      const SizedBox(height: 15),
                      blue_button(context, btnTxt, press: onTap)
                    ],
                  )),
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

class TimerProgressIndicator extends StatefulWidget {
  @override
  _TimerProgressIndicatorState createState() => _TimerProgressIndicatorState();
}

class _TimerProgressIndicatorState extends State<TimerProgressIndicator> {
  double _progress = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (_progress < 1.0) {
        setState(() {
          _progress += 1.0 / 60.0; // Update progress for each second
        });
        print(";-;-;-;-$_progress");
      } else {
        _timer?.cancel(); // Stop the timer once it reaches 100%
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300, // Set the width of the progress bar
      height: 5, // Set the height of the progress bar
      child: LinearProgressIndicator(
        value: _progress, // Percentage complete
        backgroundColor: Colors.grey[300], // Background color
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue), // Progress color
        minHeight: 6, // Line width
      ),
    );
  }
}


