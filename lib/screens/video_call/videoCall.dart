import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/localkeys.dart';
import 'package:slush/screens/video_call/feedback_screen.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:slush/widgets/text_widget.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({Key? key}) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
bool fullScreen=false;
int _secondsLeft = 180;
late Timer _timer;
List reportingMatter = [
  "Did not have much in common",
  "Nudity / inappropriate",
  "Swearing / Aggression",
  "I have joined the wrong event",
  "I left the video-call by accident",
  "They are in the wrong event",
];

bool micOnn=false;
bool camOnn=false;
int selectedIndex = -1;
void startTimer() {
  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (_secondsLeft > 0) {
      setState(() {
        _secondsLeft--;
      });
    } else {
      _timer.cancel();
      // Get.offAll(()=>FeedbackVideoChatScreen());
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
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "$twoDigitMinutes:$twoDigitSeconds";
}

@override
  void initState() {
  startTimer();
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: color.txtWhite,
      body: Stack(
        children: [
          GestureDetector(
            onTap: (){
              setState(() {fullScreen=!fullScreen;});
            },
            child: SizedBox(
              height: size.height,
              width: size.width,
              child: Image.asset(AssetsPics.Videocallthumb,fit: BoxFit.cover),
  // child: ZegoUIKitPrebuiltCall(appID: 1301213038, appSign: "827c61f1eb95ded9705847d8d75ea7ba3e8d29f77821ee7a134192eca3134241", userID: user_id, userName: user_name, callID: callID,
  //               onDispose: () {// FirebaseFirestore.instance.collection('vc').doc(callID).set({'VideoCall': false}).then((value) => Navigator.pop(context));
  //               },
  //               config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()..onOnlySelfInRoom = (_) {// FirebaseFirestore.instance.collection('vc').doc(callID).set({'VideoCall': false});
  //                   return Navigator.pop(context);},),
            ),
          ),
          Positioned(
            right: 25.0,
            bottom:fullScreen?50.0:TargetPlatform.iOS==defaultTargetPlatform?150.0: 120.0,
            child: Container(
              height: 18.h,
              width: 24.w,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
            ),
          ),
          SafeArea(
            child: Column(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                padding: const EdgeInsets.only(left: 18,right: 20,top: 10),
                height: fullScreen?0:6.h,
                decoration:  BoxDecoration(
                  boxShadow: [
                    BoxShadow(color: Colors.transparent, blurRadius:fullScreen?0: 90.0,
                      spreadRadius:fullScreen?0: 60.0, offset:fullScreen?const Offset(0.0, 0.0): const Offset(50.0, 1.0),)
                  ],
                ),
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                  SizedBox(height: 26,width: 26, child: SvgPicture.asset(AssetsPics.camrotate)),
                ],),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: fullScreen?0:6.h,
                child: Container(
                  alignment: Alignment.center,
                  height: 6.h,
                  width: 38.w,
                  decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(33)
                  ),
                  child: buildText(formatDuration(Duration(seconds: _secondsLeft)), 29, FontWeight.w600, color.txtWhite),
                ),
              ),
              const Spacer(),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                padding: EdgeInsets.only(left: 18,right: 20,top: 10,bottom:fullScreen?0: 30),
                height:fullScreen?0: 15.h,
                decoration:  BoxDecoration(
                  boxShadow: [
                    BoxShadow(color: Colors.transparent,
                      blurRadius:fullScreen?0: 90.0, spreadRadius:fullScreen?0: 60.0, offset:fullScreen?const Offset(0.0, 0.0): const Offset(50.0, 1.0),)
                  ],
                ),
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                        onTap: (){
                          setState(() {micOnn=!micOnn;});
                          // Get.to(()=>const FeedbackVideoChatScreen());
                          }
                        ,child: SizedBox(height: 60,width: 60, child: SvgPicture.asset(
                        micOnn? AssetsPics.micOn:AssetsPics.micOff))),
                    //AssetsPics.microphoneOn:AssetsPics.microphone
                    const SizedBox(width: 15),
                    GestureDetector(
                        onTap: (){
                          if(_secondsLeft<=0){
                            customBuilderSheet(context, 'Is everything OK?',"Submit", heading: LocaleText.feedbackguide1,
                            onTap: (){
                              Get.off(()=>const FeedbackVideoChatScreen());
                            });
                          }else{
                            Get.off(()=>const FeedbackVideoChatScreen());
                          }
                        },
                        child: SizedBox(height: 60,width: 60, child: SvgPicture.asset(AssetsPics.callCut))),
                    const SizedBox(width: 15),
                    GestureDetector(
                        onTap: (){
                          setState(() {camOnn=!camOnn;});
                        },
                        child: SizedBox(height: 60,width: 60, child: SvgPicture.asset(camOnn?AssetsPics.camOn:AssetsPics.camOff))),
                  ],),
              )
            ],),
          )
        ],
      )
    );
  }
customBuilderSheet(BuildContext context,String title, String btnTxt, {
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
          onTap: pressed,
        // return WillPopScope(
        //   onWillPop: () async => false,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  height: MediaQuery.of(context).size.height / 1.65,
                  width: MediaQuery.of(context).size.width / 1.1,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
                                        onTap: () {
                                          setState(() {
                                            selectedIndex = index;
                                          });
                                        },
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
                                                child: selectedIndex == index
                                                    ? SvgPicture.asset(AssetsPics.blueTickCheck, fit: BoxFit.cover,) : const SizedBox(),
                                              ),
                                            ),
                                            const SizedBox(width: 10,),
                                            buildText2(reportingMatter[index], 18,
                                                FontWeight.w500, color.txtgrey,
                                                fontFamily: FontFamily.hellix),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            }),
                      ),
                      const SizedBox(height: 15),
                      blue_button(context, btnTxt, press: onTap)
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

/*import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoCallScreen> {

  final AgoraClient _client = AgoraClient(agoraConnectionData: AgoraConnectionData(
      // appId: "2031571010d34be896717d70114a68d2",
      appId: "9ebaea0f65974a71a2e54ae27ab79b73",
      channelName: "test",
   // tempToken: "007eJxTYOh+rPZ7x6KWhckJxbrm1Z2esyxVT2/d/qdIYtU027xouScKDEYGxoam5oYGhgYpxiZJqRaWZuaG5inmBoaGJolmFilG7DVqaQ2BjAyVHq5MjAwQCOKzMJSkFpcwMAAADXkdSA=="
      tempToken: "007eJxTYPBdo/nynM3tI5ezWzhc5++SUmXe9V6WMdHy7rmCXAtmrUIFhlRD07Q0E0uDJDNzCxMzC6MkICPZNNXY1NTEMjXRzOLQDde0hkBGhiUr3jExMkAgiM/CUJJaXMLAAAD3Uh7G"
  ));

  Future<void> _initAgora() async{
    await _client.initialize();
  }

  void _onExit() {
    _client.release();
  }




  @override
  void initState() {
    _initAgora();
    super.initState();
  }

  @override
  void dispose() {
    _onExit();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(child: Stack(children: [
        AgoraVideoViewer(client: _client,
          layoutType: Layout.oneToOne,floatingLayoutContainerHeight: 180,floatingLayoutContainerWidth: 150,
          //   key: Key("1"),
          // floatingLayoutMainViewPadding: EdgeInsets.all(10),
          // floatingLayoutSubViewPadding: EdgeInsets.all(10),
          showAVState: true,
          // renderModeType: 0,
        ),
        AgoraVideoButtons(client: _client,autoHideButtons: true,autoHideButtonTime: 5,)
      ],),

      ),
    );
  }
}*/
