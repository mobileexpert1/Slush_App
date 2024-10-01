import 'dart:convert';
import 'package:slush/constants/prefs.dart';
import 'package:flutter/cupertino.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:http/http.dart' as http;
import 'package:slush/widgets/toaster.dart';
import 'package:video_player/video_player.dart';


class profileController extends ChangeNotifier {
  Map<String, dynamic> dataa = {};
  double value = 0.0;
  var percent;
  int selectedIndex = 2;
  VideoPlayerController? _controller2;
  String _videoUrl = "";
  Future<void>? initializeVideoPlayerFuture;
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  Future profileData(BuildContext context) async {
    dataa.clear();
    final url = ApiList.getUser + LocaleHandler.userId;
    print(url);
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${LocaleHandler.accessToken}'
      });
      if (response.statusCode == 200) {
        dataa.clear();
        var data = jsonDecode(response.body);
        dataa = data["data"];
        LocaleHandler.dataa = dataa;
        // percantage();
        value= dataa["profileCompletion"] / 100.0;
        getTotalSparks();
      } else if (response.statusCode == 401) {
        showToastMsgTokenExpired();
        print('Token Expire:::::::::::::');
      } else {
        print('Faoled to Load Data With Status Code ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
    notifyListeners();
  }

  void percantage() {
    if (dataa["nextAction"] == "fill_firstname") {
      value = 0.0;
    }
    else if (dataa["nextAction"] == "fill_dateofbirth") {
      value = 0.1;
    }
    else if (dataa["nextAction"] == "fill_height") {
      value = 0.2;
    }
    else if (dataa["nextAction"] == "choose_gender") {
      value = 0.3;
    }
    else if (dataa["nextAction"] == "fill_lookingfor") {
      value = 0.4;
    }
    else if (dataa["nextAction"] == "fill_sexual_orientation") {
      value = 0.5;
    }
    else if (dataa["nextAction"] == "fill_ethnicity") {
      value = 0.6;
    }
    else if (dataa["nextAction"] == "upload_avatar") {
      value = 0.7;
    }
    else if (dataa["nextAction"] == "upload_video") {
      value = 0.9;
    }
    // else if(dataa["nextAction"]=="fill_password"){value=0.0909*11;}
    else if (dataa["nextAction"] == "none") {
      value = 1.0;
    }
    percent = value * 100;
    notifyListeners();
  }

  setSelectedIndex(int value) {
    selectedIndex = value;
    notifyListeners();
  }

  set isPlaying(bool playing) {
    _isPlaying = playing;
    if (playing) {
      // _controller?.play();
      _controller2?.play();
      // _controller?.setLooping(true);
      _controller2?.setLooping(true);
    } else {
      // _controller?.pause();
      _controller2?.pause();
    }
    notifyListeners();
  }

  int _spark=0;
  int get sparks=>_spark;

  void getTotalSparks()async{
    const url=ApiList.remainspark;
    print(url);
    var uri=Uri.parse(url);
    var response=await http.get(uri,headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${LocaleHandler.accessToken}'});
    var i =jsonDecode(response.body);
    if(response.statusCode==200){
      if(i["remain_sparks"]!=null){
        _spark=i["remain_sparks"];
        notifyListeners();
      }
    }
    else{print("Exception");}
    notifyListeners();
  }

  void removeData(){
    _spark=0;
    LocaleHandler.entencity.clear();
    LocaleHandler.entencityname.clear();

    LocaleHandler.avatar="";
    LocaleHandler.isChecked=false;
    LocaleHandler.accessToken='';
    LocaleHandler.refreshToken='';
    LocaleHandler.bearer='';
    LocaleHandler.nextAction = "";
    LocaleHandler.nextDetailAction = "";
    LocaleHandler.emailVerified = "";
    LocaleHandler.name = "";
    LocaleHandler.gender = "";
    LocaleHandler.lookingfor = "";
    LocaleHandler.sexualOreintation = "";
    LocaleHandler.location = "";
    LocaleHandler.userId = "";
    LocaleHandler.role = "";
    LocaleHandler.subscriptionPurchase = "";
    LocaleHandler.bottomSheetIndex=0;
    LocaleHandler.socialLogin="no";
    Preferences.setValue("token",LocaleHandler.accessToken);
    Preferences.setrefreshToken(LocaleHandler.refreshToken);
    Preferences.setNextAction("");
    Preferences.setNextDetailAction("");
    Preferences.setValue("emailVerified", LocaleHandler.emailVerified);
    Preferences.setValue("name", LocaleHandler.name);
    Preferences.setValue("location", LocaleHandler.location);
    Preferences.setValue("userId", LocaleHandler.userId);
    Preferences.setValue("role", LocaleHandler.role);
    Preferences.setValue("subscriptionPurchase", LocaleHandler.subscriptionPurchase);
    Preferences.setValue('filterList', "");
    Preferences.setValue("socialLogin", LocaleHandler.socialLogin);
    notifyListeners();
  }

}
