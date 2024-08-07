import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/controller/video_call_controller.dart';
import 'package:slush/screens/video_call/didnofind.dart';
import 'package:slush/screens/waiting_room/firebase_firestore_service.dart';
import 'package:slush/screens/waiting_room/readytocall.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:http/http.dart' as http;

class WaitingCompleted extends StatefulWidget {
  WaitingCompleted({super.key, required this.data, required this.min});

  var data;
  int min;

  @override
  State<WaitingCompleted> createState() => _WaitingCompletedState();
}

class _WaitingCompletedState extends State<WaitingCompleted> with SingleTickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final int startingMinutes = 4;
  int initialMinutes = 0;
  double initialPercent = 0.0;
  int min = 0;

  @override
  void initState() {
    super.initState();
    min = widget.min < 0 ? 0 : widget.min;
    double reaming = min / 60;
    int x = 4 - reaming.toInt();
    initialMinutes = x;
    initialPercent = initialMinutes / startingMinutes.toDouble();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: min));
    _animation = Tween<double>(begin: initialPercent, end: 1.0)
        .animate(_animationController);
    _animationController.forward();
    settimer();
    getFixtures();
  }

  var data;
  int num = -1;

  Future getFixtures() async {
    LocaleHandler.eventdataa = widget.data;
    print(LocaleHandler.eventdataa);
    final url = "${ApiList.fixtures}${LocaleHandler.eventId}/fixtures";
    print(url);
    var uri = Uri.parse(url);
    var response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${LocaleHandler.accessToken}'
    });
    var dataa = jsonDecode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        for (var i = 0; i < dataa["data"].length; i++) {
          print(i);
          if (dataa["data"][i]["status"] == "NOT_JOINED") {
            LocaleHandler.channelId = dataa["data"][i]["channelName"];
            num = i;
            break;
          } else if (dataa["data"][i]["status"] == "BY") {
            if (!LocaleHandler.fixtureParticipantId
                .contains(dataa["data"][i]["fixtureId"])) {
              LocaleHandler.fixtureParticipantId
                  .add(dataa["data"][i]["fixtureId"]);
              LocaleHandler.channelId = "";
              num = -1;
              break;
            }
          } else {}
        }
        getRtcToken();
        data = dataa["data"];
        LocaleHandler.totalDate = data.length;
        LocaleHandler.dateno = LocaleHandler.dateno + 1;
      });
    } else {}
    print("====dateno.===${LocaleHandler.dateno}");
    print("====totalDAte===${LocaleHandler.totalDate}");
  }

  Future getRtcToken() async {
    const url = ApiList.rtcToken;
    var uri = Uri.parse(url);
    var response = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${LocaleHandler.accessToken}"
        },
        body: jsonEncode({"uid": 0, "channelName": LocaleHandler.channelId}));
    if (response.statusCode == 201) {
      setState(() {
        LocaleHandler.rtctoken = jsonDecode(response.body)["data"]["token"];
        print("LocaleHandler.rtctoken=====${LocaleHandler.rtctoken}");
      });
    }
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (widget.min > 0) {
        setState(() {
          widget.min--;
        });
      } else {
        if (num == -1) {
          Get.to(() => const DidnotFindAnyoneScreen());
        } else {
          Get.to(() => ReadyToCallScreen(data: data[num]));
        }
        _timer.cancel();
      }
    });
  }

  void settimer() {
    setState(() {
      //_secondsLeft=widget.data["startsAt"];
      startTimer();
    });
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(image: DecorationImage(image: AssetImage(AssetsPics.background), fit: BoxFit.cover)),
          child: data == null
              ? const Center(child: CircularProgressIndicator(color: color.txtBlue))
              : Stack(
                  children: [
                    Stack(
                      fit: StackFit.expand,
                      alignment: Alignment.center,
                      children: [
                        Column(
                          children: [
                            SizedBox(height: 8.h),
                            buildText2("Starting Soon\n${widget.data["title"]} - ${widget.data["type"]}", 28, FontWeight.w600, color.txtBlack),
                            SizedBox(height: 6.h),
                            buildText2("We are almost there.", 20, FontWeight.w600, color.txtBlack),
                            SizedBox(height: 3.h),
                            AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  return CircularPercentIndicator(
                                    // widgetIndicator: const Icon(Icons.album_outlined,size: 35,color: color.purpleColor,),
                                    widgetIndicator: Container(
                                        padding: const EdgeInsets.only(top: 10, left: 8),
                                        height: 5,
                                        width: 5,
                                        alignment: Alignment.center,
                                        child: SvgPicture.asset(AssetsPics.timerCircle)),
                                    arcType: ArcType.HALF,
                                    circularStrokeCap: CircularStrokeCap.round,
                                    arcBackgroundColor: color.waitingremainingpurple,
                                    radius: 120.0,
                                    //fillColor: Colors.lightGreen,
                                    lineWidth: 18.0,
                                    animation: true,
                                    // animationDuration: 300000,
                                    animationDuration: initialPercent.toInt(),
                                    percent: _animation.value,
                                    center: Column(
                                      children: [
                                        const SizedBox(height: 45),
                                        buildText2(widget.min < 0 ? "00:00" : formatDuration(Duration(seconds: widget.min)),
                                            36, FontWeight.w700, color.txtBlack),
                                        buildText2("mins", 20, FontWeight.w500, color.txtBlack),
                                      ],
                                    ),
                                    backgroundColor: Colors.grey,
                                    progressColor: color.purpleColor,
                                  );
                                }),
                          ],
                        ),
                        Column(
                          children: [
                            // Spacer(),
                            SizedBox(height: MediaQuery.of(context).size.height / 2 + 40),
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
                                        TextSpan(text: widget.data["totalParticipants"].toString(),
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: color.txtBlue,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: FontFamily.baloo2))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(alignment: Alignment.centerLeft,
                                //  color: Colors.grey,
                                height: 80,
                                child: widget.data["participants"].length == 0 ? const SizedBox()
                                    : ListView.builder(
                                        padding: const EdgeInsets.only(left: 15),
                                        shrinkWrap: true,
                                        itemCount: widget.data["participants"].length,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (BuildContext context, int index) {
                                          return Container(
                                            width: 70,
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
                            const SizedBox(height: 30),
                            data == null ? const Center(child: CircularProgressIndicator(color: color.txtBlue))
                                : Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: blue_button(context, "Join the event", press: () {
                                        // Provider.of<waitingRoom>(context).updateFixtureStatus(data[0]["participantId"], "NOT_JOINED");
                                        if (num == -1) {
                                          Get.to(() => const DidnotFindAnyoneScreen());
                                        } else {
                                          Get.to(() => ReadyToCallScreen(data: data[num]));
                                        }
                                    }),
                                  ),
                            const SizedBox(height: 20),
                          ],
                        )
                      ],
                    ),
                    Positioned(top: 60, left: 10,
                      child: GestureDetector(
                          onTap: () {Get.back();},
                          child: Container(
                              padding: const EdgeInsets.all(9),
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                              child: SvgPicture.asset(AssetsPics.arrowLeft))),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  item(String name, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(name, style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// TODO AFter videoCAll feedback screen
class WaitingCompletedFeedBack extends StatefulWidget {
  WaitingCompletedFeedBack({super.key, required this.data});

  var data;

  @override
  State<WaitingCompletedFeedBack> createState() =>
      _WaitingCompletedFeedBackState();
}

class _WaitingCompletedFeedBackState extends State<WaitingCompletedFeedBack>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  bool timerCompleted = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final int startingMinutes = 5;
  int initialMinutes = 0;
  double initialPercent = 0.0;
  int min = 0;

  @override
  void initState() {
    super.initState();
    final int mins =
        Provider.of<TimerProvider>(context, listen: false).durationn;
    min = mins < 0 ? 0 : mins;
    double reaming = min / 60;
    int x = 5 - reaming.toInt();
    initialMinutes = x;
    initialPercent = initialMinutes / startingMinutes.toDouble();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: min));
    _animation = Tween<double>(begin: initialPercent, end: 1.0)
        .animate(_animationController);
    _animationController.forward();
    settimer();
    getFixtures();
  }

  var data;
  int num = -1;

  Future getFixtures() async {
    final url = "${ApiList.fixtures}${LocaleHandler.eventId}/fixtures";
    print(url);
    var uri = Uri.parse(url);
    var response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${LocaleHandler.accessToken}'
    });
    var dataa = jsonDecode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        for (var i = 0; i < dataa["data"].length; i++) {
          print(i);
          if (dataa["data"][i]["status"] == "NOT_JOINED") {
            LocaleHandler.channelId = dataa["data"][i]["channelName"];
            num = i;
            break;
          } else if (dataa["data"][i]["status"] == "BY") {
            if (!LocaleHandler.fixtureParticipantId
                .contains(dataa["data"][i]["fixtureId"])) {
              LocaleHandler.fixtureParticipantId
                  .add(dataa["data"][i]["fixtureId"]);
              LocaleHandler.channelId = "";
              num = -1;
              break;
            }
          } else {}
        }
        getRtcToken();
        data = dataa["data"];
        LocaleHandler.dateno = LocaleHandler.dateno + 1;
      });
    } else {}
    print("====dateno.===${LocaleHandler.dateno}");
    print("====totalDAte===${LocaleHandler.totalDate}");
  }

  Future getRtcToken() async {
    const url = ApiList.rtcToken;
    var uri = Uri.parse(url);
    var response = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${LocaleHandler.accessToken}"
        },
        body: jsonEncode({"uid": 0, "channelName": LocaleHandler.channelId}));
    if (response.statusCode == 201) {
      setState(() {
        LocaleHandler.rtctoken = jsonDecode(response.body)["data"]["token"];
        print("LocaleHandler.rtctoken=====${LocaleHandler.rtctoken}");
      });
    }
  }

  void startTimer() {
    int mins = Provider.of<TimerProvider>(context, listen: false).durationn;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mins > 0) {
        setState(() {
          mins--;
        });
      } else {
        if (num == -1) {
          Get.to(() => const DidnotFindAnyoneScreen());
        } else {
          Get.to(() => ReadyToCallScreen(data: data[num]));
        }
        _timer.cancel();
      }
    });
  }

  void settimer() {
    setState(() {
      //_secondsLeft=widget.data["startsAt"];
      startTimer();
    });
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

  @override
  Widget build(BuildContext context) {
    // final duration = Duration(seconds: mins);
    // final milliseconds = duration.inMilliseconds;
    int mins = Provider.of<TimerProvider>(context, listen: false).durationn;
    return PopScope(
      canPop: true,
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AssetsPics.background),
              fit: BoxFit.cover,
            ),
          ),
          child: data == null
              ? const Center(
                  child: CircularProgressIndicator(color: color.txtBlue),
                )
              : Stack(
                  children: [
                    Stack(
                      fit: StackFit.expand,
                      alignment: Alignment.center,
                      children: [
                        Column(
                          children: [
                            SizedBox(height: 8.h),
                            buildText2(
                                "Wait Next Round\n Starting Soon\n${widget.data["title"]} - ${widget.data["type"]}",
                                28,
                                FontWeight.w600,
                                color.txtBlack),
                            SizedBox(height: 6.h),
                            buildText2("We are almost there.", 20,
                                FontWeight.w600, color.txtBlack),
                            SizedBox(height: 3.h),
                            AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  return CircularPercentIndicator(
                                    // widgetIndicator: const Icon(Icons.album_outlined,size: 35,color: color.purpleColor,),
                                    widgetIndicator: Container(
                                        padding: const EdgeInsets.only(
                                            top: 10, left: 8),
                                        height: 5,
                                        width: 5,
                                        alignment: Alignment.center,
                                        child: SvgPicture.asset(
                                            AssetsPics.timerCircle)),
                                    arcType: ArcType.HALF,
                                    circularStrokeCap: CircularStrokeCap.round,
                                    arcBackgroundColor:
                                        color.waitingremainingpurple,
                                    radius: 120.0,
                                    //fillColor: Colors.lightGreen,
                                    lineWidth: 18.0,
                                    animation: true,
                                    // animationDuration: 300000,
                                    animationDuration: initialPercent.toInt(),
                                    percent: _animation.value,
                                    center: Column(
                                      children: [
                                        const SizedBox(height: 45),
                                        buildText2(
                                            mins < 0
                                                ? "00:00"
                                                : formatDuration(
                                                    Duration(seconds: mins)),
                                            36,
                                            FontWeight.w700,
                                            color.txtBlack),
                                        buildText2("mins", 20, FontWeight.w500,
                                            color.txtBlack),
                                      ],
                                    ),
                                    backgroundColor: Colors.grey,
                                    progressColor: color.purpleColor,
                                  );
                                }),
                          ],
                        ),
                        Column(
                          children: [
                            // Spacer(),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height / 2 + 40,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  buildText2("Event participants", 18,
                                      FontWeight.w600, color.txtBlack),
                                  RichText(
                                    text: TextSpan(
                                      // text: '10/',
                                      text:
                                          '${widget.data["participants"].length}/',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: color.txtBlack,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: FontFamily.baloo2),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: widget
                                                .data["totalParticipants"]
                                                .toString(),
                                            style: const TextStyle(
                                                fontSize: 16,
                                                color: color.txtBlue,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: FontFamily.baloo2))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                                alignment: Alignment.centerLeft,
                                //  color: Colors.grey,
                                height: 80,
                                child: widget.data["participants"].length == 0
                                    ? const SizedBox()
                                    : ListView.builder(
                                        padding:
                                            const EdgeInsets.only(left: 15),
                                        shrinkWrap: true,
                                        itemCount:
                                            widget.data["participants"].length,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Container(
                                            width: 70,
                                            margin: const EdgeInsets.all(6),
                                            child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: ImageFiltered(
                                                  imageFilter: ImageFilter.blur(
                                                      sigmaX: 5.0, sigmaY: 5.0),
                                                  child: CachedNetworkImage(
                                                      imageUrl: widget.data[
                                                                      "participants"]
                                                                  [
                                                                  index]["user"]
                                                              [
                                                              "profilePictures"]
                                                          [0]["key"],
                                                      fit: BoxFit.cover),
                                                )),
                                          );
                                        })),
                            const SizedBox(height: 30),

                            const SizedBox(height: 20),
                          ],
                        )
                      ],
                    ),
                    Positioned(
                      top: 60,
                      left: 10,
                      child: GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: Container(
                              padding: const EdgeInsets.all(9),
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20)),
                              child: SvgPicture.asset(AssetsPics.arrowLeft))),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  item(String name, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
