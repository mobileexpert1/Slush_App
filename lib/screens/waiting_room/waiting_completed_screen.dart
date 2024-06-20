import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/screens/waiting_room/readytocall.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/text_widget.dart';

class WaitingCompleted extends StatefulWidget {
  WaitingCompleted({super.key, required this.data, required this.min});
  var data;
  int min;

  @override
  State<WaitingCompleted> createState() => _WaitingCompletedState();
}

class _WaitingCompletedState extends State<WaitingCompleted> {
  late Timer _timer;
  int _secondsLeft = 300;
  bool timerCompleted =false;

  @override
  void initState() {
    super.initState();
    settimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (widget.min > 0) {
        setState(() {
          widget.min--;
        });
      } else {
        timerCompleted=true;
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
    final duration = Duration(seconds: widget.min);
    final milliseconds = duration.inMilliseconds;
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AssetsPics.background),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                    SizedBox(height: 8.h),
                    buildText2(
                        "Starting Soon\n${widget.data["title"]} - ${widget.data["type"]}",
                        28,
                        FontWeight.w600,
                        color.txtBlack),
                    SizedBox(height: 6.h),
                    buildText2("We are almost there.", 20, FontWeight.w600,
                        color.txtBlack),
                    SizedBox(height: 3.h),
                    CircularPercentIndicator(
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
                      animationDuration: milliseconds,
                      percent: 1,
                      center: Column(
                        children: [
                          const SizedBox(
                            height: 45,
                          ),
                          buildText2(formatDuration(Duration(seconds: widget.min)),
                              36, FontWeight.w700, color.txtBlack),
                          buildText2("mins", 20, FontWeight.w500, color.txtBlack),
                        ],
                      ),
                      backgroundColor: Colors.grey,
                      progressColor: color.purpleColor,
                    ),
                  ],
                ),
                Column(
                  children: [
                    // Spacer(),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 2 + 40,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildText2("Event participants", 18, FontWeight.w600,
                              color.txtBlack),
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
                                          imageFilter: ImageFilter.blur(
                                              sigmaX: 5.0, sigmaY: 5.0),
                                          child: CachedNetworkImage(
                                              imageUrl: widget.data["participants"][index]["user"]["profilePictures"][0]["key"],
                                              fit: BoxFit.cover),
                                        )),
                                  );
                                })),
                    const SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: blue_button(context, "Join the event", press: () {
                        if(timerCompleted){Get.to(() => const ReadyToCallScreen());}
                      }),
                    ),
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
                  child: Container(padding: const EdgeInsets.all(9), height: 35,
                      width: 35,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
                      child: SvgPicture.asset(AssetsPics.arrowLeft))),
            ),
          ],
        ),
      ),
    );
  }
}
