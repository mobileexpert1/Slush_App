import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/screens/waiting_room/readytocall.dart';
import 'package:slush/widgets/app_bar.dart';
import 'package:slush/widgets/text_widget.dart';

class EnableCameraMicrophoneScreen extends StatefulWidget {
  const EnableCameraMicrophoneScreen({Key? key}) : super(key: key);

  @override
  State<EnableCameraMicrophoneScreen> createState() => _EnableCameraMicrophoneScreenState();
}

class _EnableCameraMicrophoneScreenState extends State<EnableCameraMicrophoneScreen> {
  bool micOn=true;
  bool camOn=true;

  @override
  void initState() {
    // startTimer();
    _initializeCamera();
    super.initState();
  }

  CameraController? _controller;
  void _initializeCamera() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front);
    _controller = CameraController(front, ResolutionPreset.medium);
    await _controller!.initialize();
    // customDialogBoxVideo(context,"I’m ready");
    if (!mounted) {return;}setState(() {});
  }

/*  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitSeconds";
  }
  late Timer _timer;
  int _secondsLeft = 10;
  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {setState(() {_secondsLeft--;});
      } else {// actionForHItLike("DISLIKED");
        _timer.cancel();
        Get.to(()=>ReadyToCallScreen());}
    });
  }*/

  @override
  Widget build(BuildContext context) {
    // var miliseconds=Duration(seconds: _secondsLeft).inMilliseconds;
    final size=MediaQuery.of(context).size;
    return Scaffold(
      appBar: commonBarWithTextleft(context, Colors.transparent,""),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: size.height,
            width: size.width,
            child: Image.asset(AssetsPics.background,fit: BoxFit.fill),
          ),
          _controller == null ? const CircularProgressIndicator(color: color.txtBlue): Column(
            children: [
            const SizedBox(height: 40),
             /* CircularPercentIndicator(
                radius: 37,
                backgroundColor: Colors.transparent,
                progressColor: color.txtBlack,
                animation: true,
                animationDuration: miliseconds,
                circularStrokeCap: CircularStrokeCap.round,
                lineWidth: 4.6,
                percent:  1,
                center: Column(children: [const SizedBox(height: 17),
                    buildText2(formatDuration(Duration(seconds: _secondsLeft)), 30, FontWeight.w700, color.txtBlack),
                  ],),),*/
            SizedBox(height: 2.h),
            Container(
              // color: Colors.red,
              height: 428,width: 309,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                      child: Container(height: double.infinity, width: double.infinity, child: CameraPreview(_controller!))),
                  // Image.asset(AssetsPics.videoThumb),

                  Positioned(
                    bottom: 35.0,
                    right: 100.0,
                    child: GestureDetector(
                      onTap: (){setState(() {micOn=!micOn;
                      LocaleHandler.micOn=micOn;
                      });},
                      child: Row(
                        children: [
                        CircleAvatar(
                          radius: 27,
                          backgroundColor: color.txtWhite,
                          child: SvgPicture.asset(micOn?AssetsPics.microphoneOn:AssetsPics.microphone),
                        ),
                        const SizedBox(width: 15),
                        GestureDetector(onTap: (){
                          setState(() {camOn=!camOn;
                          LocaleHandler.camOn=camOn;
                          });
                        }, child: CircleAvatar(
                            radius: 27,
                            backgroundColor: color.txtWhite,
                            child: SvgPicture.asset(camOn?AssetsPics.camOnn:AssetsPics.cam),
                          ),
                        ),
                      ],),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 55,right: 45,top: 10),
              child: buildText("Grant access to microphone and camera by taping the iconshown", 18, FontWeight.w600, color.txtBlack),
            )
          ],)
        ],
      ),
    );
  }
}
