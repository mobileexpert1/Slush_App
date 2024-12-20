import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/localkeys.dart';
import 'package:slush/controller/video_call_controller.dart';
import 'package:slush/screens/events/bottomNavigation.dart';
import 'package:slush/screens/video_call/feedback_screen.dart';
import 'package:slush/screens/waiting_room/firebase_firestore_service.dart';
import 'package:slush/screens/waiting_room/waiting_completed_screen.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:slush/widgets/toaster.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({Key? key}) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  // List reportingMatter = [
  //   "They did not show up!",
  //   "Did not have much in common",
  //   "Nudity / inappropriate",
  //   "Swearing / Aggression",
  //   "I have joined the wrong event",
  //   "I left the video-call by accident",
  //   "They are in the wrong event",
  //   "others"
  // ];

  List reportingMatter = [
    "They did not show up!",
    "We didn’t have much in common",
    "I’m in the wrong event",
    "Inappropriate behaviour",
    "Video call froze",
    "Other"
  ];

  int selectedIndex = -1;
  static const appId = 'ace5073becd844af9e3a1651abf1b1ef';
  // static const token = '007eJxTYFA558h1UUpsgbTf4o1dB9KV2y4aimhlijNEyPL8F90uaazAkJicampgbpyUmpxiYWKSmGaZapxoaGZqmJiUZphkmJp2d9uMtIZARobO93WsjAwQCOJzMJSkFpeAMAMDALn9Hu4=';
  // String channelId = 'testtest';

  @override
  void initState() {
    super.initState();
    initializeAgora();
    // _initAgora();
  }

  final AgoraClient client = AgoraClient(
    agoraConnectionData: AgoraConnectionData(
      appId: appId,
      channelName: LocaleHandler.channelId,
      tempToken: LocaleHandler.rtctoken,
    ),
    enabledPermission: [Permission.camera, Permission.microphone],
  );

  bool _isLoading = true;
  bool remoteUserJoined = false;

  Future<void> initializeAgora() async {
    await OneSignal.User.pushSubscription.optOut();
    setState(() {_isLoading = true;});
    try {
      await [Permission.camera, Permission.microphone].request();
      // Initialize the client
      await client.initialize();
      await client.engine.muteLocalVideoStream(LocaleHandler.camOn);
      await client.engine.muteLocalAudioStream(LocaleHandler.micOn);
      await client.engine.startPreview();
      client.engine.registerEventHandler(
        RtcEngineEventHandler(
          onUserJoined: (connection, remoteUid, elapsed) {
            remoteUserJoined=true;
            print('Remote user $remoteUid joined');
            // Handle the remote user joining
            _handleRemoteUserJoined(remoteUid);
          },

          onUserOffline: (connection, remoteUid, reason) {
            print('Remote user $remoteUid left channel');
            // Handle the remote user cutting the call
            _handleRemoteUserLeft();
          },
          onFirstRemoteVideoFrame: (connection, remoteUid, width, height, elapsed) {
            print('First remote video frame received from user $remoteUid');
            setState(() {});
            // You can trigger UI updates or handle the remote video frame here
          },

        ),
      );
      const ChannelMediaOptions options = ChannelMediaOptions(
        autoSubscribeVideo: true,
        autoSubscribeAudio: true,
      );
      await client.engine.joinChannel(
        token: LocaleHandler.rtctoken,  // Pass the token here
        channelId: LocaleHandler.channelId,  // Pass the channel ID here
        uid: 0, options: options,  // Auto-assign UID if not required
      );}catch (e) {
      print('Error initializing Agora: $e');
    }finally {
      setState(() {_isLoading = false;});
    }
  }

  void _handleRemoteUserJoined(int remoteUid) {
    // Implement your logic here when the remote user connects
    print('Remote user $remoteUid connected');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TimerProvider>(context, listen: false).vstopTimerr();
      Provider.of<TimerProvider>(context, listen: false).resetTimer();
      Provider.of<TimerProvider>(context, listen: false).startTimer();
    });
    // setState(() {notjoined=true;});
    // For example, you can show a message or update the UI
  }

  void _handleRemoteUserLeft() {
    showToastMsg("${LocaleHandler.eventParticipantData["firstName"]} is didn't Pick you call");
    // setState(() {notjoined=true;});
    // Implement your logic here when the remote user cuts the call
    print('Remote user cut the call');
    // For example, you can navigate to a different screen or show a dialog
    Get.offAll(() => const FeedbackVideoChatScreen());
    _onExit();
  }

  @override
  Future<void> dispose() async{
    client.engine.leaveChannel();
    client.release();
    await OneSignal.User.pushSubscription.optIn();
    super.dispose();
  }

  void _onExit() {
    client.release();
    client.engine.leaveChannel();
    setState(() {});
  }

  bool onlyrejectonce=true;
  bool onlywaitonce=true;
  bool onlyacepctonce=true;

  @override
  Widget build(BuildContext context) {
    final timerProvider = Provider.of<TimerProvider>(context);
    final duration = timerProvider.duration;
    final formattedTime = "${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}";
    final size =MediaQuery.of(context).size;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (formattedTime == "00:00") {
        print("disconnect");
        timerProvider.stopTimer();
        timerProvider.resetTimer();
        _onExit();
        Get.offAll(() => const FeedbackVideoChatScreen());
      }});

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: color.txtWhite,
        body:  SafeArea(
          child:_isLoading?const Center(child: CircularProgressIndicator(color: color.txtBlue)) : Stack(
            children: [
              AgoraVideoViewer(
                client: client,
                floatingLayoutContainerHeight: 160,
                floatingLayoutContainerWidth: 120,
                layoutType: Layout.oneToOne,
                enableHostControls: true,
                renderModeType: RenderModeType.renderModeHidden,
                showAVState: true,
                disabledVideoWidget:  Container(
                  padding: EdgeInsets.all(20),
                  color: Colors.black,
                  child: CachedNetworkImage(imageUrl: LocaleHandler.eventParticipantData["avatar"],
                      fit: BoxFit.cover,
                      imageBuilder: (context, imageProvider) => Container(decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: imageProvider, fit: BoxFit.cover))),
                      placeholder: (ctx, url) => const Center(child: SizedBox()),
                      errorWidget: (context, url, error) => ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.asset(AssetsPics.demouser))),),//LocaleHandler.eventParticipantData["avatar"]
              ),
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
                        setState(() {LocaleHandler.micOn = !LocaleHandler.micOn;});
                        // _engine.muteLocalAudioStream(micOnn);
                        client.engine.muteLocalAudioStream(LocaleHandler.micOn);
                        // (client.enableLocalVideo(!mute));
                        // client.agoraEventHandlers.enableLocalVideo(!mute);
                      },
                      child: SizedBox(height: 60, width: 60, child: SvgPicture.asset(LocaleHandler.micOn ? AssetsPics.micOff : AssetsPics.micOn))),
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
                            Get.offAll(() => const FeedbackVideoChatScreen());
                          });
                          // Get.back();
                        }
                      },
                      child: SizedBox(height: 60, width: 60, child: SvgPicture.asset(AssetsPics.callCut))),
                  const SizedBox(width: 20),
                  GestureDetector(
                      onTap: () async {
                        setState(() {LocaleHandler.camOn = !LocaleHandler.camOn;});
                        await client.engine.muteLocalVideoStream(LocaleHandler.camOn);

                        // await client.engine.enableLocalVideo(LocaleHandler.camOn);
                        // await client.engine.muteAllRemoteVideoStreams(LocaleHandler.camOn);
                        // await client.engine.disableVideo();
                        // await client.engine.enableVideo();
                        // await client.engine.enableVideo();
                        final options = WatermarkOptions(
                          position: 1,  // Position (e.g., top-left)
                          scale: 0.1,   // Scale the watermark to 10% of its original size
                          alpha: 0.5,   // Set transparency to 50%
                        );

                        // await client.engine.addVideoWatermark(watermarkUrl: AssetsPics.eyeOff, options: options);
                        // await client.engine.enableVideoImageSource(enable: true, options: options);
                        // await client.agoraEventHandlers.onLocalVideoStateChanged(e){};
                        // await client.engine.




                      },
                      child: SizedBox(height: 60, width: 60, child: SvgPicture.asset(LocaleHandler.camOn ? AssetsPics.camOff : AssetsPics.camOn))),
                ],

                addScreenSharing: false,
                cloudRecordingEnabled: true,
                verticalButtonPadding: 20.0,
                // buttonAlignment: Alignment.bottomCenter,
                cloudRecordingButtonWidget: Text("cloudRecordingButtonWidget"),
                disableVideoButtonChild: Text("disableVideoButtonChild"),
                disconnectButtonChild: Text("disconnectButtonChild"),
                muteButtonChild: Text("muteButtonChild"),
                screenSharingButtonWidget:Text("screenSharingButtonWidget") ,
                switchCameraButtonChild: Text("switchCameraButtonChild"),
                onDisconnect: (){print("onDisconnect");},
              ),
              // AgoraUIKit(),
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  alignment: Alignment.center,
                  height: 5.h,
                  width: 27.w,
                  decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(33)),
                  child: buildText(formattedTime, 25, FontWeight.w600, color.txtWhite),
                ),
              ),
              Positioned(
                top: 25,
                right: 25,
                child: GestureDetector(
                    onTap: () {client.engine.switchCamera();},
                    child: SizedBox(height: 26, width: 26, child: SvgPicture.asset(AssetsPics.camrotate))),
              ),

              LocaleHandler.camOn && remoteUserJoined?
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  height: size.height*0.22,
                  width: size.width*0.34,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration( color: Colors.grey,borderRadius: BorderRadius.circular(20)),
                  child: CachedNetworkImage(imageUrl: LocaleHandler.avatar,
                      // fit: BoxFit.cover,
                      imageBuilder: (context, imageProvider) => Container(decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: imageProvider, fit: BoxFit.cover))),
                      placeholder: (ctx, url) => const Center(child: SizedBox()),
                      errorWidget: (context, url, error) => ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.asset(AssetsPics.demouser))),
                ),
              ) :const SizedBox(),


              StreamBuilder<DocumentSnapshot>(
                stream: FireStoreService().getCallStatusStream(),
                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasError) {return buildSizedBox();}
                  if (!snapshot.hasData || !snapshot.data!.exists) {return buildSizedBox();}
                  else if (snapshot.hasData) {
                    var data = snapshot.data!.data() as Map<String, dynamic>;
                    if (data['callstatus'] == "wait" && data['createdUserId'] == LocaleHandler.userId) {
                      print(";-;-;-;-${data['callstatus']}");
                      return  Center(child: blue_buttonwidehi(context, "Waiting for you date to join..."));
                    }
                    else if (data['callstatus'] == "accept") {
                      print(";-;-;-;-${data['callstatus']}");
                      if(onlyacepctonce){
                        onlyacepctonce=false;
                        Provider.of<TimerProvider>(context, listen: false).vstopTimerr();}
                      return const SizedBox();}
                    else if (data['callstatus'] == "reject" ) {
                      print(";-;-;-;-${data['callstatus']}");
                      if(onlyrejectonce) {
                        onlyrejectonce=false;
                        Provider.of<TimerProvider>(context, listen: false).vstopTimerr();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          onlyrejectonce = false;
                          showToastMsg("${LocaleHandler.eventParticipantData["firstName"]} is didn't Pick you call");
                          if (LocaleHandler.dateno == LocaleHandler.totalDate) {LocaleHandler.dateno = 0;
                          LocaleHandler.totalDate = 1;
                          showToastMsg("Event is over");
                          Get.offAll(() => BottomNavigationScreen());
                          Provider.of<TimerProvider>(context, listen: false).stopTimerr();}
                          else {Get.offAll(() => WaitingCompletedFeedBack(data: LocaleHandler.eventdataa));}
                        });
                      }

                    }}
                  return buildSizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String reportReason="";
  customBuilderSheet(BuildContext context, String title, String btnTxt,
      {required String heading, VoidCallback? onTapp = pressed,
        VoidCallback? onTap = pressed, bool? forAdvanceTap}) {
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
                child: GestureDetector(
                  onTap: (){},
                  child: Container(
                      height: MediaQuery.of(context).size.height *0.67,
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
                                      padding: const EdgeInsets.symmetric(vertical: 7),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {selectedIndex = index;reportReason=reportingMatter[index];
                                          });
                                        },
                                        child: Container(
                                          height: 25,
                                          color: Colors.transparent,
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor: selectedIndex == index ? color.txtBlue : color.txtBlack,
                                                radius: 9,
                                                child: CircleAvatar(
                                                  radius: 8,
                                                  backgroundColor: selectedIndex == index ? color.txtWhite : color.txtWhite,
                                                  child: selectedIndex == index
                                                      ? SvgPicture.asset(AssetsPics.blueTickCheck, fit: BoxFit.cover,)
                                                      : const SizedBox(),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              buildText2(reportingMatter[index], 17, FontWeight.w500, color.txtgrey, fontFamily: FontFamily.hellix),
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
  SizedBox buildSizedBox() => const SizedBox(height: 10);
}


class WatermarkOptions {
  final int position;
  final double scale;
  final double alpha;

  WatermarkOptions({
    required this.position,
    required this.scale,
    required this.alpha,
  });
}