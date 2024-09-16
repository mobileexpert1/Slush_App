import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/localkeys.dart';
import 'package:slush/constants/prefs.dart';
import 'package:slush/controller/event_controller.dart';
import 'package:slush/screens/events/bottomNavigation.dart';
import 'package:slush/screens/events/payment_history.dart';
import 'package:slush/screens/events/view_ticket.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:slush/widgets/toaster.dart';
import 'package:http/http.dart' as http;

class EventYourTicketScreen extends StatefulWidget {
  const EventYourTicketScreen({Key? key, required this.eventId}) : super(key: key);
  final eventId;

  @override
  State<EventYourTicketScreen> createState() => _EventYourTicketScreenState();
}

class _EventYourTicketScreenState extends State<EventYourTicketScreen> {
  Timer? countdownTimer;

  // Duration myDuration = Duration(days: 1);
  Duration? myDuration;
  // bool savedEvent = false;

  String strDigits(int n) => n.toString().padLeft(2, '0');

  void setCountDown() {
    final reduceSecondsBy = 1;
    setState(() {
      final seconds = myDuration!.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        countdownTimer!.cancel();
      } else {
        myDuration = Duration(seconds: seconds);
      }
    });
  }

  void startTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
  }

  @override
  void initState() {
    getEventDetail();
    super.initState();
  }

  @override
  void dispose() {
    countdownTimer!.cancel();
    super.dispose();
  }

  var data;
  String formattedDate = "";
  String formattedTime = "";

  Future getEventDetail() async {
    print(LocaleHandler.accessToken);
    final url = ApiList.eventDetail + widget.eventId.toString();
    print(url);
    var uri = Uri.parse(url);
    var response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      "Authorization": "Bearer ${LocaleHandler.accessToken}"
    });
    var i = jsonDecode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        data = i["data"];
      });
      int timestamp = data["startsAt"];
      int timestamp2 = data["endsAt"];
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      DateTime dateTime2 = DateTime.fromMillisecondsSinceEpoch(timestamp2 * 1000);
      formattedDate = DateFormat('dd MMMM, yyyy').format(dateTime);
      String formattedDay = DateFormat('EEEE').format(dateTime);
      String formattedstart = DateFormat.jm().format(dateTime);
      String formattedend = DateFormat.jm().format(dateTime2);
      formattedTime = "$formattedDay, $formattedstart - $formattedend";
      setdateFormate(data["startsAt"]);
      // for(var i=0;i<data["participants"].length;i++)
      // {if(data["participants"][i]["user"]["userId"].toString()==LocaleHandler.userId){setState(() {isParticipant=true;});break;}}
    } else if (response.statusCode == 401) {
      showToastMsgTokenExpired();
    } else {}
  }

  void setdateFormate(int duration) {
    int timestamp = duration;
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    DateTime timeFormat = DateTime.now();
    var timee = DateTime.tryParse(dateTime.toString());
    int sec = timee!.difference(timeFormat).inSeconds;
    int min = timee.difference(timeFormat).inMinutes;
    int hours = timee.difference(timeFormat).inHours;
    int days = timee.difference(timeFormat).inDays;
    int sec1 = sec % 60;
    int min1 = min % 60;
    int hour1 = hours % 24;
    startTimer();
    if (sec < 60) {
      myDuration = Duration(seconds: sec);
    } else if (min < 60) {
      myDuration = Duration(minutes: min, seconds: sec1);
    } else if (hours <= 24) {
      myDuration = Duration(hours: hours, minutes: min1, seconds: sec1);
    } else {
      myDuration = Duration(days: days, hours: hour1, minutes: min1, seconds: sec1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    String days = data == null ? "" : strDigits(myDuration!.inDays);
    String hours = data == null ? "" : strDigits(myDuration!.inHours.remainder(24));
    String minutes = data == null ? "" : strDigits(myDuration!.inMinutes.remainder(60));
    String seconds = data == null ? "" : strDigits(myDuration!.inSeconds.remainder(60));
    print(seconds);
    return Scaffold(
      // backgroundColor: color.backGroundClr,
      body: data == null
          ? const Center(child: CircularProgressIndicator(color: color.txtBlue))
          : Stack(
              children: [
                SizedBox(
                  height: size.height,
                  width: size.width,
                  child: Image.asset(AssetsPics.background, fit: BoxFit.cover),
                ),
                SingleChildScrollView(
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          imagesSection(size),
                          aboutSection(size),
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15, top: 8, bottom: 15),
                            child: buildText("Event participants", 18, FontWeight.w600, color.txtBlack),
                          ),
                          imageList(),
                          SizedBox(height: 13.h, width: 13.h)
                        ],
                      ),
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 200),
                            FittedBox(
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                width: 350,
                                decoration: BoxDecoration(
                                    color: const Color.fromRGBO(235, 239, 255, 1),
                                    borderRadius: BorderRadius.circular(12)),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          buildText("Time", 18, FontWeight.w600, color.txtBlack),
                                          buildText("Remaining", 18, FontWeight.w600, color.txtBlack),
                                        ],
                                      ),
                                    ),
                                    days == "00" ? const SizedBox() : Column(
                                            children: [
                                              buildText(days, 28, FontWeight.w600, color.txtBlack),
                                              buildText("Days", 16, FontWeight.w400, color.txtgrey, fontFamily: FontFamily.hellix),
                                            ],
                                          ),
                                    days == "00"
                                        ? const SizedBox()
                                        : Container(
                                            margin: const EdgeInsets.only(left: 9, right: 9),
                                            child: buildText(":", 28, FontWeight.w600, color.txtBlack)),
                                    Column(
                                      children: [
                                        buildText(int.parse(hours) < 0 ? "00" : hours,
                                            28, FontWeight.w600, color.txtBlack),
                                        buildText("Hours", 16, FontWeight.w400, color.txtgrey,
                                            fontFamily: FontFamily.hellix),
                                      ],
                                    ),
                                    Container(
                                        margin: const EdgeInsets.only(left: 8, right: 8),
                                        child: buildText(":", 28, FontWeight.w600, color.txtBlack)),
                                    Column(
                                      children: [
                                        buildText(int.parse(minutes) < 0 ? "00" : minutes,
                                            28, FontWeight.w600, color.txtBlack),
                                        buildText("Minutes", 16, FontWeight.w400, color.txtgrey,
                                            fontFamily: FontFamily.hellix),
                                      ],
                                    ),
                                    days != "00"
                                        ? const SizedBox()
                                        : Container(
                                            margin: const EdgeInsets.only(left: 8, right: 8),
                                            child: buildText(":", 28, FontWeight.w600, color.txtBlack)),
                                    days != "00"
                                        ? const SizedBox()
                                        : Column(
                                            children: [
                                              buildText(int.parse(seconds) < 0 ? "00" : seconds, 28, FontWeight.w600, color.txtBlack),
                                              buildText("seconds", 16, FontWeight.w400, color.txtgrey,
                                                  fontFamily: FontFamily.hellix),
                                            ],
                                          ),
                                    const SizedBox(width: 5),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                bottomBooksection(size)
              ],
            ),
    );
  }

  Widget imagesSection(Size size) {
    final eventCntrller = Provider.of<eventController>(context, listen: false);
    return SizedBox(
      height: 246,
      width: size.width,
      child: Stack(
        children: [
          Container(
              height: 246,
              width: size.width,
              child: CachedNetworkImage(imageUrl: LocaleHandler.freeEventImage, fit: BoxFit.cover)),
          IgnorePointer(
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: SvgPicture.asset(AssetsPics.eventbg, fit: BoxFit.cover))),
          Container(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 50),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Container(
                            height: 20,
                            width: 20,
                            child: SvgPicture.asset(AssetsPics.whitearrowleft))),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        // Get.to(()=>PaymentHistoryScreen());
                        if (LocaleHandler.items.contains(data["eventId"])) {
                          eventCntrller.saveEvent(ApiList.unsaveEvent, data["eventId"].toString());
                          LocaleHandler.items.remove(data["eventId"]);
                        } else {
                          eventCntrller.saveEvent(ApiList.saveEvent, data["eventId"].toString());
                          LocaleHandler.items.add(data["eventId"]);
                        }
                        Preferences.setValue("EventIds", jsonEncode(LocaleHandler.items));
                        setState(() {});
                      },
                      child: CircleAvatar(
                          radius: 18,
                          backgroundColor: color.txtWhite,
                          child: SvgPicture.asset(LocaleHandler.items.contains(data["eventId"])
                                  ? AssetsPics.eventbluesaved : AssetsPics.greysaved)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget headlines(Size size) {
    return SizedBox(
      width: size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: size.width*0.8,
                child: buildText(data["title"] + " - " + data["type"],
                    28, FontWeight.w600, color.txtBlack),
              ),
              SizedBox(
                  height: 3.h + 1,
                  width: 24,
                  child: !data["hasPassword"]
                      ? SvgPicture.asset(AssetsPics.lock)
                      : const SizedBox())
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              SvgPicture.asset(AssetsPics.evntfreeicon),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // buildText("30 November, 2023", 18, FontWeight.w600, color.txtBlack),
                  buildText(formattedDate, 18, FontWeight.w600, color.txtBlack),
                  // buildText("Tuesday, 10:00AM - 11:03AM", 14, FontWeight.w600, color.dropDowngreytxt,fontFamily: FontFamily.hellix),
                  buildText(
                      formattedTime, 14, FontWeight.w600, color.dropDowngreytxt,
                      fontFamily: FontFamily.hellix),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SvgPicture.asset(AssetsPics.eventmappoint),
              const SizedBox(width: 12),
              // buildText("London, UK", 18, FontWeight.w600, color.txtBlack),
              buildText(data["country"], 18, FontWeight.w600, color.txtBlack),
            ],
          ),
        ],
      ),
    );
  }

  Column aboutSection(Size size) {
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 15, right: 15, top: 80, bottom: 14),
          child: headlines(size),
        ),
        const Divider(thickness: 0.7, color: color.lightestBlue),
        Container(
          padding:
              const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 9),
          width: size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildText("About Event", 18, FontWeight.w600, color.txtBlack),
              buildText(
                  data["description"], 16, FontWeight.w500, color.txtgrey2,
                  fontFamily: FontFamily.hellix),
            ],
          ),
        ),
        const Divider(thickness: 0.7, color: color.lightestBlue),
      ],
    );
  }

  Widget imageList() {
    return SizedBox(
      height: 9.h,
      child: data["participants"].length == 0
          ? const SizedBox()
          : ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.only(left: 15),
              scrollDirection: Axis.horizontal,
              itemCount: data["participants"].length,
              itemBuilder: (context, index) {
                return Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 70,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        // child: Image.asset(AssetsPics.eventProfile,fit: BoxFit.cover),
                        child: ImageFiltered(
                          imageFilter:
                              ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                          // child: Image.asset(AssetsPics.eventProfile, fit: BoxFit.cover),
                          child:data["participants"][index]["user"]["profilePictures"].length==0?Image.asset(AssetsPics.demouser,height: 35): CachedNetworkImage(
                              imageUrl: data["participants"][index]["user"]["profilePictures"][0]["key"],
                              fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Image.asset(AssetsPics.demouser,height: 35),
                          ),
                        )));
              }),
    );
  }

  Widget bottomBooksection(Size size) {
    return Positioned(
      bottom: 0.0,
      child: Container(
        alignment: defaultTargetPlatform == TargetPlatform.iOS ? Alignment.topCenter : Alignment.center,
        // height: 10.h,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        width: size.width,
        color: color.txtWhite,
        child: Row(
          crossAxisAlignment: defaultTargetPlatform == TargetPlatform.iOS ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: EdgeInsets.only(top: defaultTargetPlatform == TargetPlatform.iOS ? 2 : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildText("Booked", 20, FontWeight.w600, color.txtBlack),
                  buildText("View your ticket", 16, FontWeight.w500, color.txtgrey, fontFamily: FontFamily.hellix),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => EventViewTicketScreen(data: data));
                // callFunction();
              },
              child: Container(
                alignment: Alignment.center,
                // height: defaultTargetPlatform == TargetPlatform.iOS ? 7.h - 4 : 7.h,
                padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 15),
                // margin: EdgeInsets.only(top: defaultTargetPlatform == TargetPlatform.iOS ? 2 : 0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [color.gradientLightBlue, color.txtBlue])),
                child: buildText("Your ticket", 18, FontWeight.w600, color.txtWhite),
              ),
            )
          ],
        ),
      ),
    );
  }

  /*Widget bottomBooksection(Size size) {
    return Positioned(
      bottom: 0.0,
      child: Container(
        alignment:defaultTargetPlatform==TargetPlatform.iOS? Alignment.topCenter:Alignment.center,
        height: 10.h,
        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 8),
        width: size.width,
        color: color.txtWhite,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildText("FREE", 25, FontWeight.w600, color.txtBlack),
            Container(
              alignment: Alignment.center,
              height: 7.h,
              padding: const EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                  color: color.subscribeButton
              ),
              child: buildText("Waiting list",18,FontWeight.w600,color.txtWhite),
            )
          ],),
      ),
    );
  }*/

  void callFunction() {
    setState(() {
      // snackBaarblue(context,AssetsPics.banner,"Event starting in 15 minutes, Click Hereto join the waiting room!");
      LocaleHandler.isThereAnyEvent = true;
      LocaleHandler.isThereCancelEvent = false;
      LocaleHandler.unMatchedEvent = false;
      LocaleHandler.subScribtioonOffer = false;
      Get.to(() => BottomNavigationScreen());
    });
  }
}
