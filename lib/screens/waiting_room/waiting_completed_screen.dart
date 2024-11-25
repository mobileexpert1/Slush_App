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
import 'package:slush/screens/events/bottomNavigation.dart';
import 'package:slush/screens/video_call/didnofind.dart';
import 'package:slush/screens/waiting_room/enablecameramicrophone.dart';
import 'package:slush/screens/waiting_room/readytocall.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:http/http.dart' as http;
import 'package:slush/widgets/toaster.dart';

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
    _animationController = AnimationController(vsync: this, duration: Duration(seconds: min));
    _animation = Tween<double>(begin: initialPercent, end: 1.0).animate(_animationController);
    _animationController.forward();
    settimer();
    getFixtures();
  }

  var data=[];
  int num = -2;

  Future getFixtures() async {
    LocaleHandler.eventdataa = widget.data;
    print(LocaleHandler.eventdataa);
    final url = "${ApiList.fixtures}${LocaleHandler.eventId}/fixtures";
    print(url);
    var uri = Uri.parse(url);
    var response = await http.get(uri, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${LocaleHandler.accessToken}'});
    var dataa = jsonDecode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        if(dataa["data"].length != 0){
        fixtureEmpty=false;
        data = dataa["data"];
        print(data);
        LocaleHandler.totalDate = data.length;
        for (var i = 0; i < dataa["data"].length; i++)
        {if(dataa["data"][i]["participantId"]!=null){
          Provider.of<TimerProvider>(context,listen: false).updateFixtureStatus(dataa["data"][i]["participantId"], "NOT_JOINED");}}
        for (var i = 0; i < dataa["data"].length; i++) {
          LocaleHandler.dateno = i + 1;
          print('dataa["data"][i]["status"];-;-;-;-${dataa["data"][i]["status"]}');
          print("dateno;-;-;-;-${LocaleHandler.dateno}");
          print("totalDAte;-;-;-;-${LocaleHandler.totalDate}");
          if (dataa["data"][i]["status"] == "NOT_JOINED") {
            if (!LocaleHandler.fixtureParticipantId.contains(dataa["data"][i]["fixtureId"])) {
            LocaleHandler.fixtureParticipantId.add(dataa["data"][i]["fixtureId"]);
            LocaleHandler.channelId = dataa["data"][i]["channelName"];
            num = i;}
            break;
          } else if (dataa["data"][i]["status"] == "BY") {
            if (!LocaleHandler.fixtureParticipantId.contains(dataa["data"][i]["fixtureId"])) {
              LocaleHandler.fixtureParticipantId.add(dataa["data"][i]["fixtureId"]);
              LocaleHandler.channelId = "";
              num = -1;
              break;
            }
            else if(LocaleHandler.dateno==dataa["data"].length){
              LocaleHandler.dateno=0;
              LocaleHandler.totalDate = 1;
              showToastMsg("Event is over");
              Get.offAll(()=>BottomNavigationScreen());
              Provider.of<TimerProvider>(context,listen: false).stopTimerr();
            }
          }
        }   getRtcToken();}
        else{num=-1;LocaleHandler.totalDate=0;}
      });
    } else {}
  }

  Future getRtcToken() async {
    const url = ApiList.rtcToken;
    var uri = Uri.parse(url);
    var response = await http.post(uri, headers: {'Content-Type': 'application/json', "Authorization": "Bearer ${LocaleHandler.accessToken}"},
        body: jsonEncode({"uid": 0, "channelName": LocaleHandler.channelId}));
    if (response.statusCode == 201) {
        LocaleHandler.rtctoken = jsonDecode(response.body)["data"]["token"];
        print("LocaleHandler.rtctoken=====${LocaleHandler.rtctoken}");
    }
  }

  bool fixtureEmpty=true;

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (widget.min > 0) {
        setState(() {widget.min--;});
        if( widget.min<10&&widget.min>7 && fixtureEmpty){
          getFixtures();
        }} else {
        LocaleHandler.insideevent=true;
        if (num == -1) {//Get.to(() => const DidnotFindAnyoneScreen());
        customDialogBoxx(context, "It looks like we’ve got an uneven number of participants this round, but don’t worry – your next date will be lined up shortly.",
            "Ok", AssetsPics.guide1,
            isPng: true, onTap: () {
              // Get.back();
              if(LocaleHandler.dateno==LocaleHandler.totalDate){
                LocaleHandler.dateno=0;
                LocaleHandler.totalDate = 1;
                showToastMsg("Event is over");
                Get.offAll(()=>BottomNavigationScreen());
                Provider.of<TimerProvider>(context,listen: false).stopTimerr();}

              else{Get.offAll(()=>WaitingCompletedFeedBack(data: LocaleHandler.eventdataa));}
            });
        }
        else {print("data[num];-;-;-;-${data[num]}");
          Get.to(() => ReadyToCallScreen(data: data[num]));}
        _timer.cancel();
      }
    });
  }

  void settimer() {setState((){startTimer();});}

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
    final size=MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
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
                                        // const SizedBox(height: 45),
                                        Container(height: MediaQuery.of(context).size.height*0.07),
                                        buildText2(widget.min < 0 ? "00:00" : formatDuration(Duration(seconds: widget.min)),
                                            36, FontWeight.w700, color.txtBlack),
                                        buildText2("minutes", 20, FontWeight.w500, color.txtBlack),
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
                                                  child:widget.data["participants"][index]["user"]["profilePictures"].length==0?
                                                  Image.asset(AssetsPics.demouser,height: 35): CachedNetworkImage(
                                                      imageUrl: widget.data["participants"][index]["user"]["profilePictures"][0]["key"],
                                                      fit: BoxFit.cover,
                                                      errorWidget: (context, url, error) => Image.asset(AssetsPics.demouser,height: 35,width: 50)
                                                  ),
                                                )),
                                          );
                                        })),
                            const SizedBox(height: 30),
                            data == null ? const Center(child: CircularProgressIndicator(color: color.txtBlue))
                                : Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: blue_button(context, "Join the event", press: () {
                                      showToastMsg("Please wait for everyone to be joined");

                                    }),
                                  ),
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
                                margin: const EdgeInsets.symmetric(horizontal: 20),
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
  final int startingMinutes = 6;
  int initialMinutes = 0;
  double initialPercent = 0.0;
  int min = 0;

  @override
  void initState() {
    super.initState();
    final int mins = Provider.of<TimerProvider>(context, listen: false).durationn;
    min = mins < 0 ? 0 : mins;
    double reaming = min / 60;
    int x = 6 - reaming.toInt();
    initialMinutes = x;
    initialPercent = initialMinutes / startingMinutes.toDouble();
    _animationController = AnimationController(vsync: this, duration: Duration(seconds: min));
    _animation = Tween<double>(begin: initialPercent, end: 1.0).animate(_animationController);
    _animationController.forward();
    settimer();
    getFixtures();
    Provider.of<TimerProvider>(context, listen: false).startTimerr();
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
        if(dataa["data"].length != 0){
        data = dataa["data"];
        LocaleHandler.totalDate = data.length;
        for (var i = 0; i < dataa["data"].length; i++) {
          LocaleHandler.dateno=i+1;
          print('dataa["data"][i]["status"];-;-;-;-${dataa["data"][i]["status"]}');
          print("dateno;-;-;-;-${LocaleHandler.dateno}");
          print("totalDAte;-;-;-;-${LocaleHandler.totalDate}");
          if (dataa["data"][i]["status"] == "NOT_JOINED") {
            if (!LocaleHandler.fixtureParticipantId.contains(dataa["data"][i]["fixtureId"])) {
              LocaleHandler.fixtureParticipantId.add(dataa["data"][i]["fixtureId"]);
              LocaleHandler.channelId = dataa["data"][i]["channelName"];
              num = i;
              break;}
          } else if (dataa["data"][i]["status"] == "BY") {
            if (!LocaleHandler.fixtureParticipantId.contains(dataa["data"][i]["fixtureId"])) {
              LocaleHandler.fixtureParticipantId.add(dataa["data"][i]["fixtureId"]);
              LocaleHandler.channelId = "";
              num = -1;
              break;
            }
            else if(LocaleHandler.dateno==dataa["data"].length){
              LocaleHandler.dateno=0;
              LocaleHandler.totalDate = 1;
              showToastMsg("Event is over");
              Get.offAll(()=>BottomNavigationScreen());
              Provider.of<TimerProvider>(context,listen: false).stopTimerr();
            }
          }
        } getRtcToken();}
      });
    } else {num=-1;}
  }

  Future getRtcToken() async {
    const url = ApiList.rtcToken;
    var uri = Uri.parse(url);
    var response = await http.post(uri,
        headers: {'Content-Type': 'application/json', "Authorization": "Bearer ${LocaleHandler.accessToken}"},
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
      if (mins > 0) {setState(() {mins--;});}
      else {
        if (num == -1) {
          // Get.to(() => const DidnotFindAnyoneScreen());
          customDialogBoxx(context, "It looks like we’ve got an uneven number of participants this round, but don’t worry – your next date will be lined up shortly.",
              "Ok", AssetsPics.guide1,
              isPng: true, onTap: () {
                Get.back();
                setState(() {
                  LocaleHandler.isThereAnyEvent=false;
                  LocaleHandler.isThereCancelEvent=false;
                  LocaleHandler.unMatchedEvent=false;
                  LocaleHandler.subScribtioonOffer=false;
                });
                if(LocaleHandler.dateno==LocaleHandler.totalDate){
                  LocaleHandler.dateno=0;
                  LocaleHandler.totalDate = 1;
                  showToastMsg("Event is over");
                  Get.offAll(()=>BottomNavigationScreen());
                  Provider.of<TimerProvider>(context,listen: false).stopTimerr();}
                else{Get.offAll(()=>WaitingCompletedFeedBack(data: LocaleHandler.eventdataa));}
              });

        }
        else {Get.to(() => ReadyToCallScreen(data: data[num]));}
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
    int mins = Provider.of<TimerProvider>(context, listen: false).durationn;
    final size=MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
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
                            buildText2("Wait Next Round\n Starting Soon\n${widget.data["title"]} - ${widget.data["type"]}", 28, FontWeight.w600, color.txtBlack),
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
                                        padding: const EdgeInsets.only(top: 10, left: 8),
                                        height: 5, width: 5,
                                        alignment: Alignment.center,
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
                                    animationDuration: initialPercent.toInt(),
                                    percent: _animation.value,
                                    center: Column(
                                      children: [
                                        // const SizedBox(height: 45),
                                        Container(height: MediaQuery.of(context).size.height*0.07),
                                        buildText2(mins < 0 ? "00:00" : formatDuration(Duration(seconds: mins)),
                                            36, FontWeight.w700, color.txtBlack),
                                        buildText2("minutes", 20, FontWeight.w500, color.txtBlack),
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
                                      style: const TextStyle(fontSize: 16, color: color.txtBlack,
                                          fontWeight: FontWeight.w600, fontFamily: FontFamily.baloo2),
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
                                                      fit: BoxFit.cover,
                                                      errorWidget: (context, url, error) => Image.asset(AssetsPics.demouser,height: 35,width: 50)),
                                                )),
                                          );
                                        })),
                            const SizedBox(height: 30),
                            Padding(
                              padding: const EdgeInsets.only(left: 20,right: 20),
                              child: white_button(context, "Leave Event", press: () {
                                customSparkBottomSheeet(context,
                                    AssetsPics.guide2, "Are you sure you want to leave the event", "Cancel", "Leave", onTap2: () {
                                  Get.back();
                                  Provider.of<TimerProvider>(context,listen: false).stopTimerr();
                                  _timer.cancel();
                                  LocaleHandler.bottomSheetIndex = 0;
                                  LocaleHandler.totalDate = 1;
                                  LocaleHandler.dateno = 0;
                                  Get.offAll(BottomNavigationScreen());
                                  _timer.cancel();
                                });
                              }),
                            ),
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
                                margin: const EdgeInsets.symmetric(horizontal: 20),
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
                          ],
                        )
                      ],
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

customDialogBoxx(BuildContext context, String title,
    String btnTxt, String img, {VoidCallback? onTap = pressed, bool isPng = false}) {
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
                    buildText2(title, 18, FontWeight.w500, color.txtBlack),
                    SizedBox(height: 1.h),
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