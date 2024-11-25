import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:http/http.dart'as http;
import 'package:slush/screens/video_call/feedback_screen.dart';
import 'package:slush/widgets/toaster.dart';

class TimerProvider with ChangeNotifier {
  Duration _duration = const Duration(minutes: 3);
  Timer? _timer;

  Duration get duration => _duration;

  void startTimer() {
    _timer?.cancel();  // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_duration.inSeconds > 0) {
        _duration -= const Duration(seconds: 1);
        print('Time remaining: ${_duration.inMinutes}:${_duration.inSeconds % 60}');  // Debugging output
        notifyListeners();
      } else {
        _timer?.cancel();
        _duration= const Duration(minutes: 3);
        print('Timer finished');
      }
    });
  }


  void stopTimer() {
    _timer?.cancel();
    _duration = const Duration(minutes: 3);
    print('Timer stopped');
  }

  // video call timer
  Timer? _vtimerr;
  int _vmin=100;
  int get vdurationn => _vmin;

  void vstartTimerr() {
    vstopTimerr();
    _vtimerr = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_vmin > 0) {
        _vmin--;
        print(";-;-;-;-${_vmin}_vmin");
        notifyListeners();
      } else {_vtimerr?.cancel();
      vstopTimerr();
      showToastMsg("${LocaleHandler.eventParticipantData["firstName"]} is didn't Pick you call");
      Get.offAll(() => const FeedbackVideoChatScreen());}
    });
    notifyListeners();
  }

  void vstopTimerr() {
    _vtimerr?.cancel();
    _vmin=100;
  }

  void resetTimer() {
    _timer?.cancel();
    _duration = const Duration(minutes: 3);
    notifyListeners();
    print('Timer reset to 03:00');
  }

  Future videoCallReport(int participantId ,String reason)async{
    final url="${ApiList.fixtures}${LocaleHandler.eventId}/report/fixtures";
    print(url);
    var uri=Uri.parse(url);
    var response=await http.patch(uri,headers: {'Content-Type': 'application/json',
      "Authorization": "Bearer ${LocaleHandler.accessToken}"},
    body: jsonEncode({  "participantId": participantId, "reason": reason}));
    print("response.statusCode======${response.statusCode}");
    print(jsonDecode(response.body));
    if(response.statusCode==200){// showToastMsg("Reported successfully");
    }
  }

// time used due to whole event

  Duration _durationn = const Duration(minutes: 6);
  Timer? _timerr;
  int _min=360;
  int get durationn => _min;

  void startTimerr() {
    stopTimerr();
    _timerr = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_min > 0) {
        _min--;
        print(";-;-;-;-${_min}_min");
        notifyListeners();
      } else {_timerr?.cancel();
      stopTimerr();}
    });
    notifyListeners();
  }

  void stopTimerr() {
    _timerr?.cancel();
    _min=360;
    _durationn = const Duration(minutes: 6);
    notifyListeners();
  }

  Future updateFixtureStatus(int participantid, String status) async {
    final url = "${ApiList.fixtures}${LocaleHandler.eventId}/fixtures";
    print(url);
    var uri = Uri.parse(url);
    var response = await http.patch(uri,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${LocaleHandler.accessToken}'},
        body: jsonEncode({"participantId": participantid, "status": status}));
    print(response.statusCode);
    if (response.statusCode == 200) {
      print(jsonDecode(response.body)["message"]);
    }
    notifyListeners();
  }
}