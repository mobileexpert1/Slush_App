import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:http/http.dart' as http;
import 'package:slush/constants/color.dart';
import 'package:slush/constants/loader.dart';
import 'package:slush/controller/controller.dart';
import 'package:slush/controller/waitingroom_controller.dart';
import 'package:slush/screens/events/event_list.dart';
import 'package:slush/screens/waiting_room/waiting_room_screen.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:slush/widgets/toaster.dart';

import '../constants/image.dart';

//---- after added banner
class eventController extends ChangeNotifier {
  var data;
  int _page = 1;

  List _myevent = [];

  List get meEvent => _myevent;
  String _timerEventName = "";

  String get timerEventName => _timerEventName;

  int _startEventTime = 0;

  int get startEventTime => _startEventTime;
  int _indexnum = 0;

  int get indexnum => _indexnum;

  int _timeRemain = 0;
  int _likeCount = 0;

  int get likeCount => _likeCount;

  void removeMyEvent() {
    _myevent.clear();
    _startTime = 0;
    notifyListeners();
  }

  Future getmeEvent(BuildContext context, String eventType) async {
    _page = 1;
    final url =
        "${ApiList.getEvent}${LocaleHandler.miliseconds}&distance=${LocaleHandler.distancee}&events=$eventType&latitude=${LocaleHandler.latitude}&longitude=${LocaleHandler.longitude}&page=$_page&limit=10";
    print(url);
    var uri = Uri.parse(url);
    var response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${LocaleHandler.accessToken}'
    });
    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (eventType == "me") {
        _myevent = data["data"]["items"];
        DateTime now = DateTime.now();
        timestampSeconds = now.microsecondsSinceEpoch ~/ 1000000;
        for (var i = 0; i < _myevent.length; i++) {
          if (timestampSeconds < _myevent[i]["startsAt"]) {
            // Future.delayed(const Duration(seconds: 5));
            // setDateFormat(_myevent[i]["startsAt"]);

            setDateFormatForApi(_myevent[i]["startsAt"], context);
            _timeRemain = _myevent[i]["startsAt"];

            _timerEventName =
                _myevent[i]["title"] + " - " + _myevent[i]["type"] + "...";
            _startEventTime = _myevent[i]["startsAt"];
            LocaleHandler.eventId = _myevent[i]["eventId"];
            _indexnum = i;
            break;
          }
        }
      }
      if (eventType == "") {}
      notifyListeners();
      // return  jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      showToastMsgTokenExpired();
    } else {
      Fluttertoast.showToast(msg: 'Something Went Wrong');
    }
    notifyListeners();
    // return  jsonDecode(response.body);
  }

  void futuredelayed(int i, bool val) {
    Future.delayed(Duration(seconds: i), () {
      LocaleHandler.isBanner = val;
      notifyListeners();
    });
    notifyListeners();
  }

  Future saveEvent(String api, String event) async {
    final url = api + event;
    print(url);
    var response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${LocaleHandler.accessToken}'
      },
    );
    if (response.statusCode == 201) {
      var data = jsonDecode(response.body);
      LocaleHandler.ErrorMessage = data["message"];
    } else {
      return Error();
    }
    notifyListeners();
  }

  Future savedEvents(BuildContext context) async {
    LocaleHandler.items.clear();
    final url = ApiList.savedEvents;
    print(url);
    final uri = Uri.parse(url);
    var response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${LocaleHandler.accessToken}',
      },
    );
    data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      for (var i = 0; i < data.length; i++) {
        LocaleHandler.items.add(data[i]["event"]["eventId"]);
      }
      Provider.of<eventController>(context, listen: false).getmeEvent(context, "me");
      getListData();
      return "Ok";
    } else if (response.statusCode == 401) {
      showToastMsg(data["message"]);
    } else {
      LocaleHandler.ErrorMessage = data["message"];
      return Error();
    }
    notifyListeners();
  }

  Future getListData() async {
    final url = "${ApiList.result}page=1&limit=100&type=liked";
    // final url = isLiked ? "${ApiList.result}page=1&limit=10&type=liked" : "${ApiList.result}page=1&limit=10";
    print(url);
    var uri = Uri.parse(url);
    var response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${LocaleHandler.accessToken}'
    });
    var i = jsonDecode(response.body)["data"];
    if (response.statusCode == 200) {
      print(i["items"].length);
      _likeCount = i["items"].length;
    } else if (response.statusCode == 401) {
      showToastMsgTokenExpired();
    } else {
      if (LocaleHandler.subscriptionPurchase == "yes") {
        Fluttertoast.showToast(msg: 'Something Went Wrong');
      }
    }
    notifyListeners();
  }

//-----------------------------------------
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  String latitude = "";
  String longitude = "";

  Future<void> _getCurrentPosition(BuildContext context) async {
    final hasPermission = await _handlePermission();
    if (!hasPermission) {
      Fluttertoast.showToast(msg: "Location permission is neccessary");
    }
    final position = await _geolocatorPlatform.getCurrentPosition();
    latitude = position.latitude.toString();
    longitude = position.longitude.toString();
    Provider.of<nameControllerr>(context, listen: false)
        .setLocation(latitude, longitude);
    // getEvents();
    updaetLocation();
    notifyListeners();
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    notifyListeners();
    return true;
  }

  Future updaetLocation() async {
    const url = ApiList.location;
    var uri = Uri.parse(url);
    var response = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${LocaleHandler.accessToken}"
        },
        body: jsonEncode({"latitude": latitude, "longitude": longitude}));
    if (response.statusCode == 200) {
    } else if (response.statusCode == 401) {
      showToastMsgTokenExpired();
    } else {
      Fluttertoast.showToast(msg: "Internal Server error");
    }
    notifyListeners();
  }
//-----------------------------------------

  Duration? _myDuration;

  int _startTime = 0;

  int get startTime => _startTime;
  bool _before15 = false;

  bool get before15 => _before15;
  int timestampSeconds = 0;

  String? timestampString;

  /// before 15 min
  String? durationString;

  void beforeFifteenMinutes(int duration) {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(duration * 1000);
    Duration fifteenMinutes = const Duration(minutes: 15);
    DateTime newTime = time.subtract(fifteenMinutes);
    int timestamp = newTime.millisecondsSinceEpoch;
    print('Timestamp:--------------------------------- $timestamp');
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    timestampString = dateTime.toString();
    print('Timestamp String:::::::::::::::::::::::::: $timestampString');
  }

  bool checkTimeDifference(DateTime dateTime1, DateTime dateTime2) {
    Duration difference = dateTime1.difference(dateTime2).abs();
    return difference.inMinutes <= 15;
  }

  bool checkTimeDifference1(DateTime dateTime1, DateTime dateTime2) {
    Duration difference = dateTime1.difference(dateTime2).abs();
    return difference.inSeconds == 0;
  }

  void setDateFormatForApi(int duration, context) {
    DateTime dateTime1 = DateTime.fromMillisecondsSinceEpoch(duration * 1000);
    durationString = dateTime1.toString();
    beforeFifteenMinutes(duration);

    /// 15 min time of the event start
    print("Duration============$duration");
    DateTime dateTime11 = DateTime.now();
    DateTime dateTime22 = DateTime.parse(durationString!);
    print('duration String1:::::::::::::::::::::::::: $durationString');
    print('duration String2:::::::::::::::::::::::::: $timestampString');
    bool isDifferenceLessThan15Minutes = checkTimeDifference(dateTime11, dateTime22);
    bool cutTimer = checkTimeDifference1(dateTime11, dateTime22);
    print("Difference String:::::::::::::::::::::::::$isDifferenceLessThan15Minutes");

    if (duration > _startTime) {
      _startTime = duration;

      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(duration * 1000);
      DateTime timeFormat = DateTime.now();
      var timee = DateTime.tryParse(dateTime.toString());
      int sec = timee!.difference(timeFormat).inSeconds;
      int min = timee.difference(timeFormat).inMinutes;
      int hours = timee.difference(timeFormat).inHours;
      int days = timee.difference(timeFormat).inDays;
      int sec1 = sec % 60;
      int min1 = min % 60;
      int hour1 = hours % 24;

      startTimer(context);

      if (sec <= 0) {
        countdownTimer!.cancel();
        _startTime = 0;
      } else if (sec < 60) {
        _myDuration = Duration(seconds: sec);
      } else if (min < 60) {
        _myDuration = Duration(minutes: min, seconds: sec1);
      } else if (hours <= 24) {
        _myDuration = Duration(hours: hours, minutes: min1, seconds: sec1);
      } else {
        _myDuration =
            Duration(days: days, hours: hour1, minutes: min1, seconds: sec1);
      }
    }
    notifyListeners();
  }

  // not in used yet
  void setDateFormat(int duration, context) {
    DateTime dateTime1 = DateTime.fromMillisecondsSinceEpoch(duration * 1000);
    durationString = dateTime1.toString();
    beforeFifteenMinutes(duration);

    /// 15 min time of the event start
    print("Duration============$duration");
    DateTime dateTime11 = DateTime.now();
    DateTime dateTime22 = DateTime.parse(durationString!);
    print('duration String1:::::::::::::::::::::::::: $durationString');
    print('duration String2:::::::::::::::::::::::::: $timestampString');
    bool isDifferenceLessThan15Minutes = checkTimeDifference(dateTime11, dateTime22);
    bool cutTimer = checkTimeDifference1(dateTime11, dateTime22);
    print("Difference String:::::::::::::::::::::::::$isDifferenceLessThan15Minutes");

    if (duration > _startTime) {
      _startTime = duration;

      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(duration * 1000);
      DateTime timeFormat = DateTime.now();
      var timee = DateTime.tryParse(dateTime.toString());
      int sec = timee!.difference(timeFormat).inSeconds;
      int min = timee.difference(timeFormat).inMinutes;
      int hours = timee.difference(timeFormat).inHours;
      int days = timee.difference(timeFormat).inDays;
      int sec1 = sec % 60;
      int min1 = min % 60;
      int hour1 = hours % 24;

      startTimer(context);

      if (sec <= 0) {countdownTimer!.cancel();
        _startTime = 0;
      } else if (sec < 60) {
        _myDuration = Duration(seconds: sec);
      } else if (min < 60) {
        _myDuration = Duration(minutes: min, seconds: sec1);
      } else if (hours <= 24) {
        _myDuration = Duration(hours: hours, minutes: min1, seconds: sec1);
      } else {
        _myDuration = Duration(days: days, hours: hour1, minutes: min1, seconds: sec1);
      }
    } else if (isDifferenceLessThan15Minutes == true) {
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(duration * 1000);
      DateTime timeFormat = DateTime.now();
      var timee = DateTime.tryParse(dateTime.toString());
      int min = timee!.difference(timeFormat).inMinutes;
      print("This Code Is Working Fine------------------------------------------!!!");
      if (min <= 0 ) {}
      else {Get.snackbar('', '',
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.TOP,
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            backgroundColor: Colors.transparent, onTap: (snack) {},
            borderRadius: 0.0,
            titleText: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Image.asset(AssetsPics.bannerpng, fit: BoxFit.cover)),
                Container(
                    padding: const EdgeInsets.only(top: 0, left: 10, right: 10, bottom: 15),
                    child: buildText2(
                        'Event starting in ${min} minutes, Click Here\nto join the waiting room!',
                        18,
                        FontWeight.w600,
                        color.txtWhite)),
              ],
            ),
            shouldIconPulse: true,
            maxWidth: MediaQuery.of(context).size.width,
            snackStyle: SnackStyle.FLOATING,
            borderWidth: 0.0,
            overlayBlur: 0.0,
            barBlur: 0.0);}
    }
    notifyListeners();
  }

  Timer? countdownTimer;

  void startTimer(BuildContext context) {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setCountDown(context);
    });
  }

  String strDigits(int n) => n.toString().padLeft(2, '0');
  String _days = "";

  String get days => _days;
  String _hours = "";

  String get hours => _hours;
  String _minutes = "";

  String get minutes => _minutes;
  String _seconds = "";

  String get seconds => _seconds;

  void setCountDown(BuildContext context) {
    final seconds = _myDuration!.inSeconds - 1;
    // if(timestampSecondsCurrent<timestampSeconds){}
    if (seconds < 0) {
      countdownTimer!.cancel();
    } else {
      _myDuration = Duration(seconds: seconds);
      if (seconds < 900) {
        _before15 = true;
      } else {
        _before15 = false;
      }
    }
    _days = strDigits(_myDuration!.inDays);
    _hours = strDigits(_myDuration!.inHours.remainder(24));
    _minutes = strDigits(_myDuration!.inMinutes.remainder(60));
    _seconds = strDigits(_myDuration!.inSeconds.remainder(60));
    if (_myDuration!.inSeconds % 60 == 0 && seconds < 900 && seconds > 2 && !LocaleHandler.insideevent) {
      Get.snackbar('', '',
          duration: const Duration(seconds: 5),
          snackPosition: SnackPosition.TOP,
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          onTap: (snack) {},
          borderRadius: 0.0,
          titleText: GestureDetector(
            onTap: (){
              DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(_startEventTime * 1000);
              DateTime timeFormat = DateTime.now();
              var timee = DateTime.tryParse(dateTime.toString());
              int min = timee!.difference(timeFormat).inSeconds;
              Provider.of<waitingRoom>(context,listen: false).timerStart(min);
              Get.to(()=> WaitingRoom(data: _myevent[_indexnum],min: min));
            }, child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                    width: double.infinity,
                    child: Image.asset(AssetsPics.bannerpng, fit: BoxFit.cover)),
                Container(
                    padding: const EdgeInsets.only(
                        top: 0, left: 10, right: 10, bottom: 15),
                    child: buildText2(
                        'Event starting in ${strDigits(_myDuration!.inMinutes.remainder(60))} minutes, Click Here\nto join the waiting room!',
                        18, FontWeight.w600, color.txtWhite)),
              ],
            ),
          ),
          shouldIconPulse: true,
          // maxWidth: MediaQuery.of(context).size.width,
          snackStyle: SnackStyle.FLOATING,
          borderWidth: 0.0,
          overlayBlur: 0.0,
          barBlur: 0.0);
    }
    notifyListeners();
  }

  timerCancel() {
    _startTime = 0;
    _days = "";
    _hours = "";
    _minutes = "";
    _seconds = "";
    if (countdownTimer != null) {
      countdownTimer!.cancel();
    }
  }
}
