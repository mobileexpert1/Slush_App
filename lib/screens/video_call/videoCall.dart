import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/localkeys.dart';
import 'package:slush/controller/video_call_controller.dart';
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
  List reportingMatter = [
    "Did not have much in common",
    "Nudity / inappropriate",
    "Swearing / Aggression",
    "I have joined the wrong event",
    "I left the video-call by accident",
    "They are in the wrong event",
    "others"
  ];

  int selectedIndex = -1;

  // bool camOnn = false;
  // bool micOnn = false;
  static const appId = 'ace5073becd844af9e3a1651abf1b1ef';
  // static const token = '007eJxTYPCekn513TS5y48uX0wuOu81+Xfk4Q6rLZx16fsmmm66uvqfAkNicqqpgblxUmpyioWJSWKaZapxoqGZqWFiUpphkmFq2nGXaWkNgYwM5ivjWRkZIBDE52EwNDAy0jU3MQNiCwYGAHhjI80=';
  static const token = '007eJxTYFA558h1UUpsgbTf4o1dB9KV2y4aimhlijNEyPL8F90uaazAkJicampgbpyUmpxiYWKSmGaZapxoaGZqmJiUZphkmJp2d9uMtIZARobO93WsjAwQCOJzMJSkFpeAMAMDALn9Hu4=';
  String channelId = 'testtest';

  @override
  void initState() {
    super.initState();
    initializeAgora();
    // _initAgora();
    WidgetsBinding.instance.addPostFrameCallback((_) {

      // Provider.of<TimerProvider>(context, listen: false).resetTimer();
      // Provider.of<TimerProvider>(context, listen: false).startTimer();
    });
  }
  final AgoraClient client = AgoraClient(
    agoraConnectionData: AgoraConnectionData(
      appId: appId,
      channelName: LocaleHandler.channelId,
      tempToken: LocaleHandler.rtctoken,
    ),
    enabledPermission: [Permission.camera, Permission.microphone],
  );

  Future<void> initializeAgora() async {
    await [Permission.camera, Permission.microphone].request();
    // Initialize the client
    await client.initialize();
    await client.engine.muteLocalVideoStream(LocaleHandler.camOn);
    await client.engine.muteLocalAudioStream(LocaleHandler.micOn);
    client.engine.registerEventHandler(
      RtcEngineEventHandler(
        onUserJoined: (connection, remoteUid, elapsed) {
          print('Remote user $remoteUid joined');
          // Handle the remote user joining
          _handleRemoteUserJoined(remoteUid);
        },

        onUserOffline: (connection, remoteUid, reason) {
          print('Remote user $remoteUid left channel');
          // Handle the remote user cutting the call
          _handleRemoteUserLeft();
        },
      ),
    );
  }

  void _handleRemoteUserJoined(int remoteUid) {
    // Implement your logic here when the remote user connects
    print('Remote user $remoteUid connected');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TimerProvider>(context, listen: false).resetTimer();
      Provider.of<TimerProvider>(context, listen: false).startTimer();
    });
    // For example, you can show a message or update the UI
  }

  void _handleRemoteUserLeft() {
    // Implement your logic here when the remote user cuts the call
    print('Remote user cut the call');
    // For example, you can navigate to a different screen or show a dialog
    Get.to(() => const FeedbackVideoChatScreen());
    _onExit();
  }


  @override
  void dispose() {
    client.engine.leaveChannel();
    client.release();
    super.dispose();
  }
  void _onExit() {
    client.release();
    client.engine.leaveChannel();
    setState(() {});
  }




  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);
    final duration = timerProvider.duration;
    final formattedTime = "${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}";
    WidgetsBinding.instance.addPostFrameCallback((_) {
    if (formattedTime == "00:00") {
      print("disconnect");
      timerProvider.stopTimer();
      timerProvider.resetTimer();
      _onExit();
      Get.offAll(() => const FeedbackVideoChatScreen());
    }});

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: color.txtWhite,
        body: SafeArea(
          child: Stack(
            children: [
              AgoraVideoViewer(
                client: client,
                floatingLayoutContainerHeight: 160,
                floatingLayoutContainerWidth: 120,
                layoutType: Layout.oneToOne,
                enableHostControls: true,
                renderModeType: RenderModeType.renderModeHidden,
                showAVState: true,
              ),
              // Positioned(top: 16.0, right: 16.0, child: FloatingActionButton(backgroundColor: Colors.transparent, onPressed: () {// _client.sessionController.switchCamera();
              //     }, child: SvgPicture.asset(AssetsPics.camrotate),),),
              AgoraVideoButtons(
                  client: client,
                  autoHideButtons: false,
                  autoHideButtonTime: 5,
                  enabledButtons: const [
                    // BuiltInButtons.callEnd,
                    // BuiltInButtons.toggleMic,
                    // BuiltInButtons.toggleCamera,
                  ],
                  extraButtons: [
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            LocaleHandler.micOn = !LocaleHandler.micOn;});
                          // _engine.muteLocalAudioStream(micOnn);
                          client.engine.muteLocalAudioStream(LocaleHandler.micOn);
                        },
                        child: SizedBox(height: 60, width: 60,
                            child: SvgPicture.asset(LocaleHandler.micOn ? AssetsPics.micOff : AssetsPics.micOn))),
                    //AssetsPics.microphoneOn:AssetsPics.microphone
                    const SizedBox(width: 20),
                    GestureDetector(
                        onTap: () {
                          if (formattedTime != "00:00") {
                            customBuilderSheet(
                                context, 'Is everything OK?', "Submit",
                                heading: LocaleText.feedbackguide1, onTap: () {
                              timerProvider.stopTimer();
                              // timerProvider.resetTimer();
                              // _engine.leaveChannel();
                              print("LocaleHandler.eventParticipantData====${LocaleHandler.eventParticipantData["participantId"]}");

                              timerProvider.videoCallReport(LocaleHandler.eventParticipantData["participantId"], reportReason);
                              client.engine.leaveChannel();
                              _onExit();
                              print("disconnect");
                              Get.off(() => const FeedbackVideoChatScreen());
                            });
                            // Get.back();
                          }
                        },
                        child: SizedBox(
                            height: 60,
                            width: 60,
                            child: SvgPicture.asset(AssetsPics.callCut))),
                    const SizedBox(width: 20),
                    GestureDetector(
                        onTap: ()async {
                          setState(() {
                            LocaleHandler.camOn = !LocaleHandler.camOn;
                          });
                          await client.engine.muteLocalVideoStream(LocaleHandler.camOn);
                        },
                        child: SizedBox(height: 60, width: 60,
                            child: SvgPicture.asset(LocaleHandler.camOn ? AssetsPics.camOff : AssetsPics.camOn))),
                  ]),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  alignment: Alignment.center,
                  height: 5.h,
                  width: 27.w,
                  decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(33)),
                  child: buildText(
                      formattedTime, 25, FontWeight.w600, color.txtWhite),
                ),
              ),

              Positioned(
                top: 25,
                right: 25,
                child: GestureDetector(
                    onTap: () {
                      client.engine.switchCamera();
                    },
                    child: SizedBox(
                        height: 26,
                        width: 26,
                        child: SvgPicture.asset(AssetsPics.camrotate))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String reportReason="";
  customBuilderSheet(BuildContext context, String title, String btnTxt,
      {required String heading,
      VoidCallback? onTapp = pressed,
      VoidCallback? onTap = pressed,
      bool? forAdvanceTap}) {
    return showGeneralDialog(
      barrierDismissible: true,
        barrierLabel: "Label",
        transitionDuration: const Duration(milliseconds: 500),
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return GestureDetector(
            onTap: pressed,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    height: MediaQuery.of(context).size.height / 1.65,
                    width: MediaQuery.of(context).size.width / 1.1,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: color.txtWhite, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const SizedBox(height: 10),
                        buildText(title, 20, FontWeight.w600, color.txtBlack),
                        buildText2(heading, 18, FontWeight.w500, color.txtgrey, fontFamily: FontFamily.hellix),
                        Expanded(
                          child: StatefulBuilder(builder:
                              (BuildContext context, StateSetter setState) {
                            return ListView.builder(
                                itemCount: reportingMatter.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedIndex = index;
                                          reportReason=reportingMatter[index];
                                        });
                                      },
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
                                                backgroundColor:
                                                    selectedIndex == index
                                                        ? color.txtWhite
                                                        : color.txtWhite,
                                                child: selectedIndex == index
                                                    ? SvgPicture.asset(
                                                        AssetsPics.blueTickCheck,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : const SizedBox(),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            buildText2(reportingMatter[index], 18,
                                                FontWeight.w500, color.txtgrey,
                                                fontFamily: FontFamily.hellix),
                                          ],
                                        ),
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

