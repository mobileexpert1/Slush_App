import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

// import 'package:chewie/chewie.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/loader.dart';
import 'package:slush/controller/chat_controller.dart';
import 'package:slush/screens/feed/tutorials/controller_class.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:video_player/video_player.dart';
import '../ad_manager.dart';
import '../widgets/toaster.dart';

class nameControllerr with ChangeNotifier {
  String accountHolderName = "";

  String get namr => accountHolderName;

  void getName(String val) {
    accountHolderName = val.trim();
    LocaleHandler.name = val.trim();
    notifyListeners();
  }

  void getResetPasswordToken(String val) {
    LocaleHandler.resetPasswordtoken = val;
    notifyListeners();
  }

  void setLocation(String lat, String long) {
    LocaleHandler.latitude = lat;
    LocaleHandler.longitude = long;
    LocaleHandler.cordinatesFetch = true;
    updaetLocation(lat, long);
    notifyListeners();
  }

  Future updaetLocation(String latitude, String longitude) async {
    const url = ApiList.location;
    var uri = Uri.parse(url);
    var response = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${LocaleHandler.accessToken}"
        },
        body: jsonEncode({"latitude": latitude, "longitude": longitude}));
    if (response.statusCode == 200) {
      // Fluttertoast.showToast(msg: "Internal Server error");
    } else if (response.statusCode == 401) {
      // showToastMsgTokenExpired();
    } else {
      Fluttertoast.showToast(msg: "Internal Server error");
    }
    notifyListeners();
  }
}

class ReelController with ChangeNotifier {
  List<String> reel = [];

  List<String> get reels => reel;
  bool isMuted = false;

  bool get isMute => isMuted;
  bool paused = false;

  bool get pause => paused;
  bool _congo = false;

  bool get congo => _congo;
  String _name = "";

  String get name => _name;
  int _id = 0;

  int get id => _id;
  var dataa;

  get data => dataa;
  List posts = [];
  int total = -1;

  int get totallen => total;
  int pages = 1;
  var videoPlayerController = <VideoPlayerController>[];

  // ChewieController? chewieController;
  get videocntroller => videoPlayerController;
  String genderparam = "";
  List _userId = [];

  List get userId => _userId;

  // int _indexid=-1;
  int _indexid2 = -1;
  int _count = -1;

  int get count => _count;
  bool _adstart = false;

  bool get adstart => _adstart;
  bool bioH = false;

  bool get biohieght => bioH;
  bool _stopReelScroll = false;

  bool get stopReelScroll => _stopReelScroll;
  String _imgUrl = '';

  String get imgurl => _imgUrl;
  bool played = false;

  void addReel(String val) {
    // reel.contains(val)
    reel.add(val);
    notifyListeners();
  }

  void remove() {
    played = false;
    reel.clear();
    videoPlayerController.clear();
    notifyListeners();
  }

  void congoScreen(bool val, String img, String naam, int uid) {
    LocaleHandler.matchedd = val;
    _imgUrl = img;
    _congo = val;
    _name = naam;
    _id = uid;
    notifyListeners();
  }

  Future setVolumne(bool val, int index) async {
    isMuted = val;
    await videoPlayerController[index].setVolume(val ? 0.0 : 1.0);
    // for(var i=0;i<videoPlayerController.length;i++){
    //   // videoPlayerController[i].pause();
    //   videoPlayerController[i].setVolume(0.0);}
    notifyListeners();
  }

  void videoPause(bool val, int index) async {
    paused = val;
    if (videoPlayerController.length == 0) {
    } else if (val) {
      played = true;
      await videoPlayerController[index].pause();
    } else {
      // if(index==0){
      //   await videoPlayerController[0].pause();
      //   if(played){played=false;videoPlayerController[0].play();
      //   videoPlayerController[0].setLooping(true);
      //   videoPlayerController[0].setVolume(isMuted?0.0:1.0);}}
      // else {videoPlayerController[index].play();
      // videoPlayerController[index].setLooping(true);
      // videoPlayerController[index].setVolume(isMuted?0.0:1.0);}

      videoPlayerController[index].play();
      videoPlayerController[index].setLooping(true);
      videoPlayerController[index].setVolume(isMuted ? 0.0 : 1.0);
    }
    // LocaleHandler.pageCurrentIndex = index;
    notifyListeners();
  }

  Future getVideoCount(BuildContext context) async {
    const url = ApiList.swipecount;
    print(url);
    var uri = Uri.parse(url);
    var resposne = await http.post(uri, headers: {
      'Content-Type': 'application/json',
      "Authorization": "Bearer ${LocaleHandler.accessToken}"
    });
    var i = jsonDecode(resposne.body);
    if (resposne.statusCode == 201) {
      if (LocaleHandler.subscriptionPurchase == "no") {
        _count = i["left_Swipes"];
        if (_count == 0) {
          //Provider.of<reelTutorialController>(context,listen: false).setScrollLimit(true);
          _stopReelScroll = true;
        }
      } else {
        //Provider.of<reelTutorialController>(context,listen: false).setScrollLimit(false);
        _stopReelScroll = false;
      }
    }
    notifyListeners();
  }

  void _countM(BuildContext context) {
    if (LocaleHandler.subscriptionPurchase == "no") {
      _count--;
      if (_count % 10 == 0) {
        adstarted(true);
        AdManager.loadInterstitialAd(context, () {});
      }
      if (_count == 0) {
        //Provider.of<reelTutorialController>(context,listen: false).setScrollLimit(true);
        customDialogBox2(
            context: context,
            title: 'Maximum limit reached',
            secontxt: "",
            heading:
                "You've swipped your way to the limit today, Want to keep the momentum going? Upgrade now for unlimited swipes.",
            btnTxt: "ok",
            img: AssetsPics.guide1,
            isPng: true,
            onTap: () {
              Get.back();
            });
        _stopReelScroll = true;
      }
    } else {
      //Provider.of<reelTutorialController>(context,listen: false).setScrollLimit(false);
      _stopReelScroll = false;
    }
    notifyListeners();
  }

  void adstarted(bool val) {
    videoPlayerController[_indexid2].pause();
    _adstart = val;
    notifyListeners();
  }

  Future swippedVideo(BuildContext context, int id) async {
    _indexid2 = id;
    _countM(context);
    final url = ApiList.swippedVideo;
    print(url);
    var uri = Uri.parse(url);
    var response = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${LocaleHandler.accessToken}"
        },
        body: jsonEncode({"profile_video_id": id}));
    if (response.statusCode == 201) {
      print(
          "response.statusCode===201=ApiList.swippedVideo"); // getVideoCount(context);
    } else if (response.statusCode == 401) {
      showToastMsgTokenExpired();
    } else {}
  }

  Future getVidero(BuildContext context, int pageI, int minage, int maxage,
      int distance, String lat, String lon, String gender,
      {bool filter = false}) async {
    LocaleHandler.matchedd = true;
    // removeVideoLimit(context);
    pages = 1;
    genderparam = gender == "" ? "" : "&gender=$gender";
    videoPlayerController.clear();
    dataa = null;
    posts.clear();
    final reelcntrol = Provider.of<ReelController>(context, listen: false);
    final url =
        "${ApiList.getVideo}$minage&maxAge=$maxage&distance=$distance&latitude=$lat&longitude=$lon$genderparam&isVerified=${LocaleHandler.isChecked}&page=1&limit=5";
    print(url);
    var uri = Uri.parse(url);
    var response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      "Authorization": "Bearer ${LocaleHandler.accessToken}"
    });
    var ii = jsonDecode(response.body);
    LoaderOverlay.hide();
    notifyListeners();
    if (response.statusCode == 200) {
      dataa = ii["data"]["items"];
      posts = dataa;
      for (var i = 0; i < posts.length; i++) {
        videoPlayerController.add(VideoPlayerController.networkUrl(Uri.parse(posts[i]["video"].toString())));
        reelcntrol.addReel(posts[i]["video"].toString());
      }
      playNextReel(LocaleHandler.pageIndex);
      total = ii["data"]["meta"]["totalItems"];
      if (total == 0) {
        LocaleHandler.matchedd = false;
        stopReels(context);
      } else {
        LocaleHandler.matchedd = false;
        removeVideoLimit(context);
        getVideoCount(context);
      }
    } else {
      total = -1;
      dataa = ii;
    }
    notifyListeners();
  }

  Future loadmore(BuildContext context, int i, int minage, int maxage,
      int distance, String lat, String lon, String gender) async {
    pages = pages + 1;
    final reelcntrol = Provider.of<ReelController>(context, listen: false);
    final url =
        "${ApiList.getVideo}$minage&maxAge=$maxage&distance=$distance&latitude=$lat&longitude=$lon$genderparam&isVerified=${LocaleHandler.isChecked}&page=$pages&limit=5";
    print(url);
    var uri = Uri.parse(url);
    var response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      "Authorization": "Bearer ${LocaleHandler.accessToken}"
    });
    var ii = jsonDecode(response.body);
    if (response.statusCode == 200) {
      // await kCacheManager.emptyCache();
      // final List fetchedPosts = ii["data"]["items"];
      // if (fetchedPosts.isNotEmpty) {posts.addAll(fetchedPosts);}
      // total=ii["data"]["meta"]["totalItems"];
      // posts=dataa;
      dataa = dataa + ii["data"]["items"];
      for (var i = 0; i < ii["data"]["items"].length; i++) {
        if (LocaleHandler.isChecked && posts[i]["user"]["isVerified"] == true) {
          videoPlayerController.add(VideoPlayerController.networkUrl(
              Uri.parse(posts[i]["video"].toString())));
          reelcntrol.addReel(posts[i]["video"].toString());
        } else {
          videoPlayerController.add(VideoPlayerController.networkUrl(
              Uri.parse(ii["data"]["items"][i]["video"].toString())));
          reelcntrol.addReel(ii["data"]["items"][i]["video"].toString());
        }
      }
    } else {
      total = 0;
      dataa = ii;
    }
    notifyListeners();
  }

  void playNextReel(int index) {
    print("index;-;-;-;-$index");
    /// Stop [index - 1] controller
    if (index > 0) {
      _stopControllerAtIndex(index - 1);
    }
    /// Dispose [index - 2,3] controller
    if (index > 1) {
      _disposeControllerAtIndex(index - 2);
    }
    /// Play current video (already initialized)
    playControllerAtIndex(index);
    /// Initialize [index + 1] controller
    _initializeControllerAtIndex(index + 1);
    LocaleHandler.pageIndex = index;
    notifyListeners();
  }

  void playPreviousReel(int index) {
    print("index;-;-;-;-$index");
    // _indexid=index-1;
    /// Stop [index + 1] controller
    _stopControllerAtIndex(index + 1);

    /// Dispose [index + 2] controller
    _disposeControllerAtIndex(index + 2);

    /// Play current video (already initialized)
    playControllerAtIndex(index);

    /// Initialize [index - 1] controller
    if (index > 0) {
      _initializeControllerAtIndex(index - 1);
    }
    LocaleHandler.pageIndex = index;
    notifyListeners();
  }

  void _stopControllerAtIndex(int index) {
    if (videoPlayerController.length > index && index >= 0) {
      /// Get controller at [index]
      // /// Pause
      videoPlayerController[index].pause();
      for (var i = 0; i < videoPlayerController.length; i++) {
        videoPlayerController[i].pause();
      }

      /// Reset postiton to beginning
      videoPlayerController[index].seekTo(const Duration());

      /// log('stopped $index');
      notifyListeners();
    }
  }

  void _disposeControllerAtIndex(int index) {
    if (videoPlayerController.length > index && index >= 0) {
      /// Get controller at [index]
      var controller = videoPlayerController[index];

      /// Dispose controller
      controller.dispose();
      // log('Disposed $index');
    }
    notifyListeners();
  }

  // ChewieController? _chewieController;
  // ChewieController? get chewieController => _chewieController;
  void playControllerAtIndex(int index) {
    paused = false;
    if (videoPlayerController.length > index && index >= 0) {
      /// Get controller at [index]
      var controller = videoPlayerController[index];
      if (controller.value.isInitialized) {
        /// Play controller
        controller.play();
        controller.setLooping(true);
        print("aspect---${videoPlayerController[index].value.aspectRatio}");
        if (controller.value.isPlaying) {
          controller.setVolume(isMuted ? 0.0 : 1.0);
        } else {
          controller.setVolume(0.0);
        }
      } else {
        _initializeControllerAtIndex(index).then((value) {
          if (index != 0) {
            videoPlayerController[index].play();
            videoPlayerController[index].setLooping(true);
            print("aspect---${videoPlayerController[index].value.aspectRatio}");
          }else{
            Future.delayed(const Duration(seconds: 6));
            if(index == LocaleHandler.pageIndex){
              videoPlayerController[index].play();
              videoPlayerController[index].setLooping(true);
            }
          }

          if (videoPlayerController[index].value.isPlaying) {
            videoPlayerController[index].setVolume(isMuted ? 0.0 : 1.0);
          } else {
            videoPlayerController[index].setVolume(0.0);
          }
          // _chewieController = ChewieController(videoPlayerController: videoPlayerController[index], autoPlay: true, looping: true,);
        });
        notifyListeners();
      }
      // log('playing $index');
    }
    notifyListeners();
  }

  Future _initializeControllerAtIndex(int index) async {
    if (videoPlayerController.length > index && index >= 0) {
      /// Create new controller
      var controller = VideoPlayerController.networkUrl(Uri.parse(videoPlayerController[index].dataSource));
      // final controller = VideoPlayerController.network(videoUrls[index]);
      /// Add to [controllers] list
      videoPlayerController[index] = controller;

      /// Initialize
      await controller.initialize().then((value) {
        notifyListeners();
      });
      // log('initialized $index');
    }
    paused = false;
    notifyListeners();
  }

  void changeBioHieght(val) {
    bioH = val;
    notifyListeners();
  }

  void removeVideoLimit(BuildContext context) {
    Provider.of<ChatController>(context,listen: false).getUnreadChat(false);
    _count = -1;
    // Provider.of<reelTutorialController>(context,listen: false).setScrollLimit(false);
    _stopReelScroll = false;
    notifyListeners();
  }

  void stopReels(BuildContext context) {
    _count = 0;
    _stopReelScroll = true;
    // Provider.of<reelTutorialController>(context,listen: false).setScrollLimit(true);
    notifyListeners();
  }

  void reelInilizedstop() async {
    LocaleHandler.matchedd = true;
    await Future.delayed(const Duration(seconds: 1));
    LocaleHandler.matchedd = false;
    // if(videoPlayerController[_indexid].value.isInitialized){_intilized=false;} else{_intilized=true;}
    notifyListeners();
  }
}
