import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart'as http;
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/loader.dart';
import 'package:slush/screens/feed/tutorials/controller_class.dart';
import 'package:video_player/video_player.dart';
import '../ad_manager.dart';
import '../widgets/toaster.dart';


class nameControllerr with ChangeNotifier{
  String accountHolderName="";
  String get namr=>accountHolderName;

  void getName(String val){
    accountHolderName=val.trim();
    LocaleHandler.name=val.trim();
    notifyListeners();
  }

  void getResetPasswordToken(String val){
    LocaleHandler.resetPasswordtoken=val;
    notifyListeners();
  }

  void setLocation(String lat,String long){
    LocaleHandler.latitude=lat;
    LocaleHandler.longitude=long;
    updaetLocation(lat, long);
    notifyListeners();
  }


  Future updaetLocation(String latitude,String longitude)async{
    const url=ApiList.location;
    var uri=Uri.parse(url);
    var response = await http.post(uri,
        headers: {'Content-Type': 'application/json', "Authorization": "Bearer ${LocaleHandler.accessToken}"},
        body: jsonEncode({"latitude":latitude, "longitude":longitude})
    );
    if(response.statusCode==200){
      // Fluttertoast.showToast(msg: "Internal Server error");
    }else if(response.statusCode==401){showToastMsgTokenExpired();}
    else{Fluttertoast.showToast(msg: "Internal Server error");}
    notifyListeners();
  }

  String _image="";
  String get image=>_image;

  void getImage(){
     ClipRRect(
         borderRadius: BorderRadius.circular(8),
         child: CachedNetworkImage(
           imageUrl: LocaleHandler.avatar,
           fit: BoxFit.fill,
           placeholder: (ctx, url) =>
           const Center(child: SizedBox()),
         ));
     notifyListeners();
  }





}

class reelController with ChangeNotifier{
  List<String> reel=[];
  List<String> get reels=>reel;

  bool isMuted=false;
  bool get isMute=>isMuted;

  bool paused=false;
  bool get pause=>paused;
  bool _congo=false;
  bool get congo=>_congo;
  String _name="";
  String get name=>_name;
  int _id=0;
  int get id=>_id;

  void addReel(String val){
    // reel.contains(val)
    reel.add(val);
    notifyListeners();
  }

  void remove(){
    reel.clear();
    videoPlayerController.clear();
    notifyListeners();
  }

  String _imgUrl='';
  String get imgurl=>_imgUrl;

  void congoScreen(bool val,String img,String naam,int uid){
    LocaleHandler.matchedd=val;
    _imgUrl=img;
    _congo=val;
    _name=naam;
    _id=uid;
    notifyListeners();
  }


  Future setVolumne(bool val,int index)async{
    isMuted=val;
   await videoPlayerController[index].setVolume(val?0.0:1.0);
    // for(var i=0;i<videoPlayerController.length;i++){
    //   // videoPlayerController[i].pause();
    //   videoPlayerController[i].setVolume(0.0);}
    notifyListeners();
  }

  void videoPause(bool val,int index)async{
    paused=val;
    if(videoPlayerController.length==0){}
    else if(val){await videoPlayerController[index].pause();}
    else{videoPlayerController[index].play();
    videoPlayerController[index].setLooping(true);}
    // for(var i=0;i<videoPlayerController.length;i++){
    //   val? videoPlayerController[i].pause():videoPlayerController[i].play(); }
    LocaleHandler.pageCurrentIndex=index;
    notifyListeners();
  }

  void cntrlDispose(){
    for(var i=0;i<videoPlayerController.length;i++){
       videoPlayerController[i].dispose();
    }
    notifyListeners();
  }

  var dataa;
  get data=>dataa;
  List posts=[];
  int total=0;
  int get totallen=>total;
  int pages=1;
  bool isPlaying= false;
  var videoPlayerController = <VideoPlayerController>[];
  // ChewieController? chewieController;
  get videocntroller=>videoPlayerController;
  String genderparam="";


  int _count=-1;
  int get count=>_count;

  Future getVideoCount(BuildContext context)async{
    final url=ApiList.swipecount;
    print(url);
    var uri=Uri.parse(url);
    var resposne=await http.post(uri, headers: {'Content-Type': 'application/json', "Authorization": "Bearer ${LocaleHandler.accessToken}"},);
    var i=jsonDecode(resposne.body);
    if(resposne.statusCode==201){
      if(LocaleHandler.subscriptionPurchase=="no"){
        _count=i["left_Swipes"];
        if(_count==0){Provider.of<reelTutorialController>(context,listen: false).setScrollLimit(true);}
        }
      else{Provider.of<reelTutorialController>(context,listen: false).setScrollLimit(false);}
    }
    notifyListeners();
  }

  void _countM(BuildContext context){
    if(LocaleHandler.subscriptionPurchase=="no"){
      _count--;
      if(_count % 10 == 0){
        AdManager.loadInterstitialAd(() {});
      }
      print("_count===$_count");
      if(_count==0){Provider.of<reelTutorialController>(context,listen: false).setScrollLimit(true);}
    } else{Provider.of<reelTutorialController>(context,listen: false).setScrollLimit(false);}
    notifyListeners();
  }


  List _userId=[];
  List get userId=>_userId;

  void storeId(BuildContext context,int id){
    if(!_userId.contains(id)){
      swippedVideo(context, id);
      _userId.add(id);
    }
    notifyListeners();
  }

  Future swippedVideo(BuildContext context,int id)async{
    final url=ApiList.swippedVideo;
    print(url);
    var uri=Uri.parse(url);
    var response=await http.post(uri,
        headers: {'Content-Type': 'application/json', "Authorization": "Bearer ${LocaleHandler.accessToken}"},
        body: jsonEncode({"profile_video_id":id})
    );
    if(response.statusCode==201){print("response.statusCode===201=ApiList.swippedVideo");
    // getVideoCount(context);
    _countM(context);
    }
    else if(response.statusCode==401){showToastMsgTokenExpired();}
    else{}
  }

  Future getVidero(BuildContext context,int pageI,int minage,int maxage,int distance,String lat,String lon,String gender)async{
    pages=1;
    genderparam=gender==""?"": "&gender=$gender";
    videoPlayerController.clear();
    dataa=null;
    posts.clear();
    notifyListeners();
    /*    if(genderparam==""){
      videoPlayerController.clear();
      dataa=null;posts.clear();LoaderOverlay.show(context);notifyListeners();}*/
    final reelcntrol=Provider.of<reelController>(context,listen: false);
    // final url=ApiList.getVideo+"&maxAge=50&distance=5000&latitude=37.4219983&longitude=-122.084&gender=male&page=$i&limit=15";
    final url="${ApiList.getVideo}$minage&maxAge=$maxage&distance=$distance&latitude=$lat&longitude=$lon$genderparam&isVerified=${LocaleHandler.isChecked}&page=1&limit=4";
    print(url);
    var uri=Uri.parse(url);
    var response=await http.get(uri,headers: {'Content-Type': 'application/json',
      "Authorization": "Bearer ${LocaleHandler.accessToken}"});
    var ii=jsonDecode(response.body);
    LoaderOverlay.hide();
    notifyListeners();
    if(response.statusCode==200){
      getVideoCount(context);
        dataa=ii["data"]["items"];
      total=ii["data"]["meta"]["totalItems"];
        posts=dataa;
        for (var i = 0; i < posts.length; i++) {
          videoPlayerController.add(VideoPlayerController.networkUrl(Uri.parse(posts[i]["video"].toString())));
          // chewieController =ChewieController(videoPlayerController: videoPlayerController[i]);
          reelcntrol.addReel(posts[i]["video"].toString());}
        playNextReel(LocaleHandler.pageIndex);
    } else{total=0;
    dataa=ii;}notifyListeners();}

  Future loadmore(BuildContext context,int i,int age,int distance,String lat,String lon,String gender)async{
    pages=pages+1;
    final reelcntrol=Provider.of<reelController>(context,listen: false);
    final url="${ApiList.getVideo}&maxAge=$age&distance=$distance&latitude=$lat&longitude=$lon$genderparam&isVerified=${LocaleHandler.isChecked}&page=$pages&limit=4";
    print(url);
    var uri=Uri.parse(url);
    var response=await http.get(uri,headers: {'Content-Type': 'application/json',
      "Authorization": "Bearer ${LocaleHandler.accessToken}"});
    var ii=jsonDecode(response.body);
    if(response.statusCode==200){
      // await kCacheManager.emptyCache();
      // final List fetchedPosts = ii["data"]["items"];
      // if (fetchedPosts.isNotEmpty) {posts.addAll(fetchedPosts);}
      // total=ii["data"]["meta"]["totalItems"];
      // posts=dataa;
      dataa=dataa+ii["data"]["items"];
      for (var i = 0; i < ii["data"]["items"].length; i++) {
        if(LocaleHandler.isChecked && posts[i]["user"]["isVerified"]==true){
          videoPlayerController.add(VideoPlayerController.networkUrl(Uri.parse(posts[i]["video"].toString())));
          reelcntrol.addReel(posts[i]["video"].toString());
        }else{
        videoPlayerController.add(VideoPlayerController.networkUrl(Uri.parse(ii["data"]["items"][i]["video"].toString())));
        reelcntrol.addReel(ii["data"]["items"][i]["video"].toString());}
      }
    } else{total=0;
    dataa=ii;
    }
    notifyListeners();}


    bool intializedd=false;

  void playNextReel(int index) {
    /// Stop [index - 1] controller
    _stopControllerAtIndex(index - 1);
    /// Dispose [index - 2,3] controller
    _disposeControllerAtIndex(index - 2);
    /// Play current video (already initialized)
    playControllerAtIndex(index);
    /// Initialize [index + 1] controller
    _initializeControllerAtIndex(index + 1);
    LocaleHandler.pageIndex=index;
    notifyListeners();
  }

  void playPreviousReel(int index) {
    /// Stop [index + 1] controller
    _stopControllerAtIndex(index + 1);
    /// Dispose [index + 2] controller
    _disposeControllerAtIndex(index + 2);
    /// Play current video (already initialized)
    playControllerAtIndex(index);
    /// Initialize [index - 1] controller
    _initializeControllerAtIndex(index - 1);
    LocaleHandler.pageIndex=index;
    notifyListeners();
  }

  void _stopControllerAtIndex(int index) {
    if (videoPlayerController.length > index && index >= 0) {
      /// Get controller at [index]
      var controller = videoPlayerController[index];
      /// Pause
      controller.pause();
      videoPlayerController[index].pause();
      for(var i=0;i<videoPlayerController.length;i++){
        videoPlayerController[i].pause();
        notifyListeners();
      }
      /// Reset postiton to beginning
      controller.seekTo(const Duration());
      // log('stopped $index');
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

  void playControllerAtIndex(int index) {
    paused=false;
    // videoPlayerController[index].pause();
    // videoPlayerController[index-1].pause();
    // videoPlayerController[index+1].pause();
    LocaleHandler.pageIndex=index;
    if (videoPlayerController.length > index && index >= 0) {
      /// Get controller at [index]
      var controller = videoPlayerController[index];
      if (controller.value.isInitialized) {
        /// Play controller
        controller.setVolume(isMuted?0.0:1.0);
        controller.play();
        controller.setLooping(true);
        notifyListeners();
      } else {
        _initializeControllerAtIndex(index).then((value) {
          videoPlayerController[index].play();
          videoPlayerController[index].setVolume(isMuted?0.0:1.0);
          // pause? videoPlayerController[index].pause():videoPlayerController[index].play();
          videoPlayerController[index].setLooping(true);
          // videoPlayerController[index].setVolume(isMuted?0.0:1.0);
          notifyListeners();
        });
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
        // chewieController = ChewieController(
        //   videoPlayerController: controller,
        //   // aspectRatio: MediaQuery.of(context).size.width/ MediaQuery.of(context).size.height,
        //   autoPlay: false, // Set to true for automatic playback
        //   looping: true, // Set to true for continuous looping
        // );
        notifyListeners();
      });
      // log('initialized $index');
    }
    paused=false;
    notifyListeners();
  }

  bool bioH=false;
  bool get biohieght=>bioH;

  void changeBioHieght(val){
    bioH=val;
    notifyListeners();
  }

  void alreadySparkLiked(int i){
    LocaleHandler.sparkLiked.add(i);
    notifyListeners();
  }
}