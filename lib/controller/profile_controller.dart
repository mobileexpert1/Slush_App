import 'dart:convert';
import 'package:slush/video_player//config/cache_config.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:http/http.dart' as http;
import 'package:slush/widgets/toaster.dart';
import 'package:video_player/video_player.dart';


class profileController extends ChangeNotifier {
  Map<String, dynamic> dataa = {};

  Map<String, dynamic> get data => dataa;
  double value = 0.0;
  var percent;
  int selectedIndex = 2;

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
        Map<String, dynamic> data = jsonDecode(response.body);
        dataa = data["data"];
        LocaleHandler.dataa = dataa;
        percantage();
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
    } else if (dataa["nextAction"] == "fill_dateofbirth") {
      value = 0.1;
    } else if (dataa["nextAction"] == "fill_height") {
      value = 0.2;
    } else if (dataa["nextAction"] == "choose_gender") {
      value = 0.3;
    } else if (dataa["nextAction"] == "fill_lookingfor") {
      value = 0.4;
    } else if (dataa["nextAction"] == "fill_sexual_orientation") {
      value = 0.5;
    } else if (dataa["nextAction"] == "fill_ethnicity") {
      value = 0.6;
    } else if (dataa["nextAction"] == "upload_avatar") {
      value = 0.7;
    } else if (dataa["nextAction"] == "upload_video") {
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

  void stopVideo() {
    // _controller!.pause();
    // _controller2!.pause();
    // _controller2!.dispose();
    notifyListeners();
  }

  // CachedVideoPlayerPlusController? _controller;
  // CachedVideoPlayerPlusController? get controller => _controller;
  VideoPlayerController? _controller2;
  VideoPlayerController? get controller2 => _controller2;
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

  cacheVideos(String url) async {
    FileInfo? fileInfo = await kCacheManager.getFileFromCache(url);
    if (fileInfo == null) {
      print('downloading file ##------->$url##');
      await kCacheManager.downloadFile(url);
      print('downloaded file ##------->$url##');
    }
  }


  _initializeVideoPlayer() {
    // _controller = CachedVideoPlayerPlusController.networkUrl(Uri.parse(_videoUrl));
    _controller2=VideoPlayerController.networkUrl(Uri.parse(_videoUrl))..initialize().then((value) {
      initializeVideoPlayerFuture = _controller2!.initialize();
    });
    isPlaying = true;
    notifyListeners();
  }

  // @override
  // void dispose() {
  //   // _controller!.dispose();
  //   _controller2!.dispose();
  //   super.dispose();
  // }

  //--not used
  VideoPlayerController? _cntrl;
  VideoPlayerController? get cntrl => _cntrl;
  void initController(url) async {
    _cntrl = VideoPlayerController.networkUrl(Uri.parse(url));
    await _cntrl!.initialize().then((value) {
      _cntrl!.play();
      _cntrl!.setVolume(0.0);
      _cntrl!.setLooping(true);
      notifyListeners();
    });
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
    notifyListeners();
  }

  Future actionForHItLike(String action,String id)async{
    final url= "${ApiList.action}$id/action";
    var uri=Uri.parse(url);
    var response=await http.post(uri,
        headers: {'Content-Type': 'application/json', "Authorization": "Bearer ${LocaleHandler.accessToken}"},
        body: jsonEncode({"action":action})
    );
    if(response.statusCode==201){getTotalSparks();}
    else if(response.statusCode==401){}
    else{}
  }
}
