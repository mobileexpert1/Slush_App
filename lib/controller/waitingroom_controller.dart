import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart'as http;
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';

class waitingRoom extends ChangeNotifier{
  late Timer _timer;
  int _secondsLeft = 900;
  String secondsLeft="";
  int _milisecond=0;


  void timerStart(int i){
    _secondsLeft=i;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        _secondsLeft--;
        secondsLeft= formatDuration(Duration(seconds: _secondsLeft));
        _milisecond =  Duration(seconds: _secondsLeft).inMilliseconds;
     }
      else {_timer.cancel();}
    });
    notifyListeners();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    notifyListeners();
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future getRtcToken()async{
    const url=ApiList.rtcToken;
    var uri=Uri.parse(url);
    var response=await http.post(uri,
        headers: {'Content-Type': 'application/json', "Authorization": "Bearer ${LocaleHandler.accessToken}"},
        body: jsonEncode({  "uid": 0, "channelName": LocaleHandler.channelId}));
    if(response.statusCode==201){
        LocaleHandler.rtctoken=jsonDecode(response.body)["data"]["token"];
        print("LocaleHandler.rtctoken=====${LocaleHandler.rtctoken}");
      }
  notifyListeners();
  }

  void changeValue()async{
    final camStatus = await Permission.camera.status;
    final micStatus = await Permission.microphone.status;
    if (camStatus.isGranted && micStatus.isGranted) {LocaleHandler.speeddatePermission=false;}
    else if (camStatus.isDenied || micStatus.isDenied){
      LocaleHandler.speeddatePermission=true;
      var newcamStatus = await Permission.camera.request();
      var newmicStatus = await Permission.microphone.request();
      if (newcamStatus.isGranted && newmicStatus.isGranted){LocaleHandler.speeddatePermission=false;}
      else if (newcamStatus.isPermanentlyDenied || newmicStatus.isPermanentlyDenied){
        LocaleHandler.speeddatePermission=true;openAppSettings();}
    }
    else if (camStatus.isPermanentlyDenied || micStatus.isPermanentlyDenied){
      LocaleHandler.speeddatePermission=true;openAppSettings();}
    notifyListeners();
  }


  String _price="0";
  String get price=>_price;
  void getPrice(String val){
    _price=val;
    print(";-;-;-");
    print("$price");
    notifyListeners();
  }

}