

import 'package:flutter/material.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/prefs.dart';

class reelTutorialController with ChangeNotifier{
  int index=0;
  int get cou=>index;
  void increamnt(){
    index++;
    if(index==6){
      Preferences.setReelAlreadySeen("true");
      LocaleHandler.feedTutorials=false;
    }
    notifyListeners();
  }

  void setScrollLimit(bool val){
    LocaleHandler.scrollLimitreached=val;
    notifyListeners();
  }
}