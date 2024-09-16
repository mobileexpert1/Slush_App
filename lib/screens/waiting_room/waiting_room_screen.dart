import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/controller/waitingroom_controller.dart';
import 'package:slush/screens/waiting_room/enablecameramicrophone.dart';
import 'package:slush/screens/waiting_room/waiting_completed_screen.dart';
import 'package:slush/widgets/alert_dialog.dart';
import 'package:slush/widgets/app_bar.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:slush/widgets/text_widget.dart';

class WaitingRoom extends StatefulWidget {
  WaitingRoom({super.key, required this.data, required this.min});
  var data;
  int min;

  @override
  State<WaitingRoom> createState() => _WaitingRoomState();
}

class _WaitingRoomState extends State<WaitingRoom> with SingleTickerProviderStateMixin {

  late Timer _timer;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final int startingMinutes = 15;
  int initialMinutes = 0;
  double initialPercent = 0.0;
  int min=0;


  @override
  void initState() {
    LocaleHandler.fixtureParticipantId.clear();
    super.initState();
    min=widget.min<0?0:widget.min;
    double reaming =min/60;
    int x=15-reaming.toInt();
    initialMinutes=x;
    initialPercent = initialMinutes / startingMinutes.toDouble();
    _animationController = AnimationController(vsync: this, duration:  Duration(seconds: min));
    _animation = Tween<double>(begin: initialPercent, end: 1.0).animate(_animationController);
    _animationController.forward();
    settimer();


    // startTimer();
  }

  void settimer() {
    Provider.of<waitingRoom>(context,listen: false).changeValue();
    setState(() {startTimer();});
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (widget.min > 0) {setState(() {widget.min--;
      if(widget.min < 120 && !LocaleHandler.speeddatePermission){
        if(LocaleHandler.onCamPrefrencescreen){Get.back();}
        LocaleHandler.onCamPrefrencescreen=false;
        LocaleHandler.dateno=0;
        DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(widget.data["startsAt"] * 1000);
        DateTime timeFormat = DateTime.now();
        var timee = DateTime.tryParse(dateTime.toString());
        min = timee!.difference(timeFormat).inSeconds;
        if(!LocaleHandler.lateEntry){Get.off(() => WaitingCompleted(data: widget.data, min: min));}
      }
      });
      } else {_timer.cancel();
      if(LocaleHandler.onCamPrefrencescreen){Get.back();}
      if(!LocaleHandler.lateEntry){
        Get.to(() => WaitingCompleted(data: widget.data, min: min));}
      }});
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  PageController controller = PageController();
  int numberOfPages = 3;
  int currentPage = 0;
  int value = 40;
  int indicatorIndex = 0;
  final messages = [
    "You will go on a series of video-dates that will last 3 minutes each.",
    "After your video-date, you will need to decide whether you like or dislike your date.",
    "At the end of the event, if you both like each other you will match and then can chat."
  ];
  final images = [
    AssetsPics.example1,
    AssetsPics.example2,
    AssetsPics.example3
  ];

  late CameraController _controller;

  // void _initializeCamera() async {
  //   final cameras = await availableCameras();
  //   final front = cameras.firstWhere(
  //       (camera) => camera.lensDirection == CameraLensDirection.front);
  //   _controller = CameraController(front, ResolutionPreset.medium);
  //   await _controller.initialize();
  //   customDialogBoxVideo(context, "I’m ready");
  //   if (!mounted) {
  //     return;
  //   }
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    // var duration = Duration(seconds: _animation.value.toInt());
    // var milliseconds = duration.inMilliseconds;
    return Scaffold(
      body: Stack(
        children: [
          Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(AssetsPics.background),
                    fit: BoxFit.cover),
              ),
              child: Stack(
                children: [
                  Stack(
                    fit: StackFit.expand,
                    alignment: Alignment.center,
                    children: [
                      Column(
                        children: [
                          // Container(height: 8.h),
                          SizedBox(height: size.height*0.07),
                          buildText2("Starting Soon\n${widget.data["title"]} - ${widget.data["type"]}", 28, FontWeight.w600, color.txtBlack),
                          // SizedBox(height: 6.h),
                          SizedBox(height: size.height*0.06),
                          buildText2(LocaleHandler.lateEntry?"Event already started":"We are almost there.", 20, FontWeight.w600, color.txtBlack),
                          // SizedBox(height: 3.h),
                          Container(height: size.height*0.03),

                          AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return CircularPercentIndicator(
                                  // widgetIndicator: const Icon(Icons.album_outlined,size: 35,color: color.purpleColor),
                                  widgetIndicator: Container(
                                      padding: const EdgeInsets.only(top: 10, left: 8),
                                      height: 5, width: 5, alignment: Alignment.center,
                                      child: Stack(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(left: 6.1),
                                            height: 25,width: 25,
                                            decoration: BoxDecoration(
                                              color: Colors.black54.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.5),
                                                  blurRadius: 17.0,
                                                  offset: const Offset(0, 7), // Change the offset for different shadow effects
                                                ),
                                              ],
                                            ),
                                          ),
                                          SvgPicture.asset(AssetsPics.timerCircle),
                                        ],
                                      )),
                                  arcType: ArcType.HALF,
                                  circularStrokeCap: CircularStrokeCap.round,
                                  arcBackgroundColor: color.waitingremainingpurple,
                                  radius: 120.0,
                                  //fillColor: Colors.lightGreen,
                                  lineWidth: 18.0,
                                  animation: true,
                                  // animationDuration: 300000,
                                  // animationDuration: 950000,
                                  animationDuration: initialPercent.toInt(),
                                  percent: _animation.value,
                                  center: Column(
                                    children: [
                                      // Container(height: 45),
                                      Container(height: size.height*0.07),
                                      // buildText2(formatDuration(Duration(seconds: widget.data["startsAt"])), 36, FontWeight.w700, color.txtBlack),
                                      buildText2(widget.min<0?"00:00": formatDuration(Duration(seconds: widget.min)), 36, FontWeight.w700, color.txtBlack),
                                      buildText2("minutes", 20, FontWeight.w500, color.txtBlack),
                                    ],
                                  ),
                                  backgroundColor: Colors.grey,
                                  progressColor: color.purpleColor,
                                );
                              }
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                buildText2("Event participants", 18, FontWeight.w600, color.txtBlack),
                                RichText(
                                  text: TextSpan(
                                    // text: '10/',
                                    text: '${widget.data["participants"].length}/',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: color.txtBlack,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: FontFamily.baloo2),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: widget.data["totalParticipants"].toString(),
                                          style: const TextStyle(fontSize: 16, color: color.txtBlue, fontWeight: FontWeight.w600, fontFamily: FontFamily.baloo2))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(alignment: Alignment.centerLeft,
                              // color: Colors.grey,
                              // height: 10.h,
                              height: size.height*0.1,
                              child: widget.data["participants"].length == 0 ? const SizedBox()
                                  : ListView.builder(
                                  padding: const EdgeInsets.only(left: 15),
                                  shrinkWrap: true,
                                  itemCount: widget.data["participants"].length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (BuildContext context, int index) {
                                    return Container(
                                      // width: 70,
                                      width: size.width*0.18,
                                      margin: const EdgeInsets.all(6),
                                      child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: ImageFiltered(
                                            imageFilter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                                            child: CachedNetworkImage(
                                                imageUrl: widget.data["participants"][index]["user"]["profilePictures"][0]["key"],
                                                fit: BoxFit.cover),
                                          )),
                                    );
                                  })),
                          SizedBox(height: 1.h),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                // SizedBox(height: 3.h),
                                Container(height: size.height*0.03),
                                buildText("Waiting and not sure what to do?", 16,
                                    FontWeight.w500, color.txtBlack,
                                    fontFamily: FontFamily.hellix),
                                buildText("Check out the Event guide below.", 16,
                                    FontWeight.w500, color.txtBlack,
                                    fontFamily: FontFamily.hellix),
                                // Container(color: Colors.red, height: 20),
                                Container( height: size.height*0.02),
                                blue_button(context, "Event guide", press: () {
                                  setState(() {
                                    currentPage = 0;
                                    indicatorIndex = 0;
                                  });
                                  customDialogWithPicture(context, "Ok", heading: "", onTap: onPress, img: AssetsPics.sample);
                                }),
                                // const SizedBox(height: 20),
                                SizedBox( height: size.height*0.02),
                                GestureDetector(
                                  onTap: () {
                                    // _initializeCamera();
                                    Get.to(() => const EnableCameraMicrophoneScreen());
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 56,
                                    // height: size.height*0.07,
                                    // width: MediaQuery.of(context).size.width/2-37,
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.transparent,
                                        border: Border.all(width: 1.5, color: color.txtBlue)),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.linked_camera, color: color.txtBlue),
                                        buildText("  Check your appearance", 18, FontWeight.w600, color.txtBlue),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 3.h)
                              ]),)
                        ],)
                    ],),
                  Positioned(
                    top: 60,
                    left: 10,
                    child: GestureDetector(
                        onTap: () {Get.back();},
                        child: Container(padding: const EdgeInsets.all(9), height: 35,
                            width: 35,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                            child: SvgPicture.asset(AssetsPics.arrowLeft))),
                  ),
                ],
              )),
          permissionSpeeddateAlert(context)
        ],
      ),
    );
  }

  customDialogWithPicture(BuildContext context, String btnTxt,
      {String? img, required String heading, VoidCallback? onTap = pressed}) {
    return showGeneralDialog(
        barrierLabel: "Label",
        transitionDuration: const Duration(milliseconds: 500),
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return StatefulBuilder(builder: (context, setState) {
            return GestureDetector(
              onTap: onTap,
              child: Scaffold(
                backgroundColor: Colors.black54,
                body: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      width: MediaQuery.of(context).size.width / 1.1,
                      // margin: const EdgeInsets.symmetric(horizontal: 16,vertical: 10),
                      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: color.txtWhite,
                          borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.center,
                            height: 400,
                            width: MediaQuery.of(context).size.width,
                            // color: Colors.red,
                            child: PageView.builder(
                              controller: controller,
                              itemCount: numberOfPages,
                              onPageChanged: (indexx) {
                                setState(() {
                                  currentPage = indexx;
                                  if (indexx == 0) {value = 40;}
                                  else if (indexx == 1) {value = 70;}
                                  else {value = 100;}
                                });
                                indicatorIndex = indexx;
                              },
                              itemBuilder: (BuildContext context, int index) {
                                return Column(
                                  children: [
                                    Container(
                                        height: 300,
                                        width: 310,
                                        padding: EdgeInsets.only(top: index == 2 ? 10 : 27,
                                            bottom: 0, left: 15, right: 15),
                                        decoration: BoxDecoration(
                                            color: const Color.fromRGBO(238, 238, 238, 1),
                                            borderRadius: BorderRadius.circular(12)),
                                        child: Image.asset(images[index])),
                                    const SizedBox(height: 8),
                                    buildText2(messages[index], 17,
                                        FontWeight.w500, color.txtBlack,
                                        fontFamily: FontFamily.hellix),
                                  ],
                                );
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List<Widget>.generate(3, (int index) {
                              return Container(
                                margin: const EdgeInsets.only(left: 2.0, right: 2.0, bottom: 12.0),
                                width: indicatorIndex == index ? 13 : 12.0,
                                height: indicatorIndex == index ? 13 : 12.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: indicatorIndex == index ? Colors.blue : Colors.grey,
                                    width: indicatorIndex == index ? 3 : 1,
                                  ),
                                  //shape: BoxShape.circle,
                                  // color: currentIndex == index ? Colors.blue : Colors.grey,
                                ),
                              );
                            }),
                          ),
                          blue_button(context, btnTxt, press: () {
                            DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(widget.data["startsAt"] * 1000);
                            DateTime timeFormat = DateTime.now();
                            var timee = DateTime.tryParse(dateTime.toString());
                            min = timee!.difference(timeFormat).inSeconds;
                            print("min================$min");
                            Get.back();
                            // if (min < 300) {
                            //   // if (min > 300) {
                            //   Get.back();
                            //   // Get.to(()=>EnableCameraMicrophoneScreen());
                            //   if(!LocaleHandler.lateEntry){ Get.to(() => WaitingCompleted(data: widget.data, min: min));}
                            // } else {
                            //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('room will open before 5 min of event Start')));
                            // }
                            // if
                          })
                        ],
                      )),
                ),
              ),
            );
          });
        },
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
            position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(anim1),
            child: child,
          );
        });
  }

  customDialogBoxVideo(BuildContext context, String btntxt,
      {VoidCallback? onTap = pressed}) {
    return showGeneralDialog(
        barrierLabel: "Label",
        transitionDuration: const Duration(milliseconds: 500),
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return GestureDetector(
            onTap: () {Get.back();},
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  // height: MediaQuery.of(context).size.height/2.5,
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(vertical: 1.h),
                    padding:
                    const EdgeInsets.only(left: 20, right: 20, bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(height: 1.h),
                        Container(
                          height: 58.h,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: color.txtWhite),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: //recordingOff?
                              AspectRatio(
                                aspectRatio: _controller.value.aspectRatio, child: Container(width: double.infinity, child: CameraPreview(_controller)),
                              )),
                        ),
                        SizedBox(height: 1.h),
                        SizedBox(height: 1.h),
                        SizedBox(height: defaultTargetPlatform == TargetPlatform.iOS ? 1.h : 0),
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
          );
        });
  }
}