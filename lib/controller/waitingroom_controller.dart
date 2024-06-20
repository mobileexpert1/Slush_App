import 'dart:async';

import 'package:flutter/cupertino.dart';

class waitingRoom extends ChangeNotifier{
  late Timer _timer;
  int _secondsLeft = 0;
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

}