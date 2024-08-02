import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart'as http;
import 'package:flutter/cupertino.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';

class waitingRoom extends ChangeNotifier{
  late Timer _timer;
  int _secondsLeft = 900;
  int get seconds=>_secondsLeft;
  String secondsLeft="";
  String get sec=> secondsLeft;
  int _milisecond=0;
  int get milisecond=>_milisecond;


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

  var _data;
  get data=>_data;
  int _num=0;
  int get num=>_num;

  Future getFixtures()async{
    final url="${ApiList.fixtures}${LocaleHandler.eventId}/fixtures";
    print(url);
    var uri=Uri.parse(url);
    var response=await http.get(uri,headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${LocaleHandler.accessToken}'} );
    var dataa=jsonDecode(response.body);
    if(response.statusCode==200){
        for(var i=0;i<=dataa["data"].length;i++){print(i);
        if(dataa["data"][i]["status"]=="NOT_JOINED"){
          LocaleHandler.channelId=dataa["data"][i]["channelName"];
          _num=i;
          break;}}
        getRtcToken();
        _data=dataa["data"];}
    else {}
    notifyListeners();
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

  Future updateFixtureStatus(int participantid,String status)async{
    final url="${ApiList.fixtures}${LocaleHandler.eventId}/fixtures";
    print(url);
    var uri=Uri.parse(url);
    var response=await http.patch(uri,headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${LocaleHandler.accessToken}'},
    body: jsonEncode({"participantId": participantid, "status": status}));
    print(response.statusCode);
    // if(response.statusCode==200)
    getFixtures();
    notifyListeners();
  }

}