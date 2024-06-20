import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:http/http.dart'as http;
import 'package:slush/controller/login_controller.dart';
import 'package:slush/screens/profile/basic_info/profile_video_view.dart';
import 'package:slush/widgets/toaster.dart';
import 'package:video_player/video_player.dart';

class profileController extends ChangeNotifier{

  Map<String,dynamic> dataa={};
  Map<String,dynamic> get data=>dataa;
  double value = 0.0;
  var percent;
  int selectedIndex=2;

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
        Map<String,dynamic> data = jsonDecode(response.body);
          dataa=data["data"];
          LocaleHandler.dataa=dataa;
          percantage();
      } else if (response.statusCode == 401) {showToastMsgTokenExpired();
      print('Token Expire:::::::::::::');
      } else {print('Faoled to Load Data With Status Code ${response.statusCode}');
      throw Exception('Failed to load data');}
    } catch (e) {throw Exception('Failed to fetch data: $e');}
 notifyListeners();
  }

  void percantage(){
    if(dataa["nextAction"]=="fill_firstname"){value=0.0;}
    else if(dataa["nextAction"]=="fill_dateofbirth"){value=0.1;}
    else if(dataa["nextAction"]=="fill_height"){value=0.2;}
    else if(dataa["nextAction"]=="choose_gender"){value=0.3;}
    else if(dataa["nextAction"]=="fill_lookingfor"){value=0.4;}
    else if(dataa["nextAction"]=="fill_sexual_orientation"){value=0.5;}
    else if(dataa["nextAction"]=="fill_ethnicity"){value=0.6;}
    else if(dataa["nextAction"]=="upload_avatar"){value=0.7;}
    else if(dataa["nextAction"]=="upload_video"){value=0.9;}
    // else if(dataa["nextAction"]=="fill_password"){value=0.0909*11;}
    else if(dataa["nextAction"]=="none"){value=1.0;}
    percent=value*100;
    notifyListeners();
  }
   setSelectedIndex(int value){
    selectedIndex=value;
    notifyListeners();
   }



   void stopVideo(){
    // _controller!.pause();
    _controller!.dispose();
    notifyListeners();
   }

  // void _initializeCamera(BuildContext context,loginControllerr getControl,CameraController _controller) async {
  //   final cameras = await availableCameras();
  //   final front = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front);
  //   _controller = CameraController(front, ResolutionPreset.medium);
  //   await _controller.initialize();
  //   // customDialogBoxVideo(context,"I’m ready",getControl);
  //   // if (!mounted) {return;}
  //   notifyListeners();
  // }

  VideoPlayerController? _controller;
  VideoPlayerController? get  controller=>_controller;
  String _videoUrl = "";
  Future<void>? initializeVideoPlayerFuture;
  bool _isPlaying = false;
  String get videoUrl => _videoUrl;
  set videoUrl(String url) {
    _videoUrl = url;
    _initializeVideoPlayer();
    notifyListeners();
  }
  bool get isPlaying => _isPlaying;
  set isPlaying(bool playing) {
    _isPlaying = playing;
    if (playing) {_controller?.play();
    _controller?.setLooping(true);
    } else {_controller?.pause();}
    notifyListeners();
  }

  _initializeVideoPlayer() {
    _controller?.dispose();
    _controller = VideoPlayerController.networkUrl(Uri.parse(_videoUrl));
    initializeVideoPlayerFuture = _controller!.initialize();
    isPlaying=true;
    notifyListeners();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }


  VideoPlayerController? _cntrl;
  VideoPlayerController? get cntrl=>_cntrl;
  void initController(url) async {
    _cntrl = VideoPlayerController.networkUrl(Uri.parse(url));
    await _cntrl!.initialize().then((value) {
      _cntrl!.play();
      _cntrl!.setVolume(0.0);
      _cntrl!.setLooping(true);
      notifyListeners();
    });
  }


}
