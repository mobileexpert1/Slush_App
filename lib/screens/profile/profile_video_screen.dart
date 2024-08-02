import 'dart:io';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/screens/profile/basic_info/profile_video_view.dart';
import 'package:slush/video_player/config/cache_config.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class VideoScreen extends StatefulWidget {
  final String url;
  const VideoScreen({Key? key, required this.url}) : super(key: key);

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
   VideoPlayerController? controller;
  late CachedVideoPlayerPlusController _cacheController;
  bool _isPlaying=false;

  cacheVideoPlay1(){
    _cacheController = CachedVideoPlayerPlusController.networkUrl(
      Uri.parse(widget.url),
      // httpHeaders: {'Connection': 'keep-alive'},
      invalidateCacheIfOlderThan: const Duration(seconds: 10),
    )..initialize().then((value) async {
      await _cacheController.setLooping(true);
      _cacheController.play();
      _cacheController.setVolume(0.0);
      _isPlaying=true;
      setState(() {});
    });
  }

  void initController() async {
    // if(controller.dataSource==widget.url)
  // Provider.of<profileController>(context,listen: false).initController(widget.url);
   Future.delayed(const Duration(seconds: 2),(){
     controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))..initialize().then((value) {
       controller!.play();
       controller!.setVolume(0.0);
       controller!.setLooping(true);
       _isPlaying=true;
       setState((){});
     });
   });
  }

  void initializePlayer() async {
    // await kCacheManager.emptyCache();
    String videoUrl = widget.url; // Replace with your video URL
    FileInfo? fileInfo = await kCacheManager.getFileFromCache(videoUrl);

    if (fileInfo != null) {
      print("11======================================$fileInfo");
      File cachedFile = fileInfo.file;
      if (cachedFile.existsSync()) {
        controller =await VideoPlayerController.file(cachedFile)..initialize().then((_) {
          controller!.play();
          controller!.setVolume(0.0);
          controller!.setLooping(true);
          _isPlaying=true;
          setState(() {});
        });
      } else {
        print('Cached file does not exist.');
      }
    } else {
      FileInfo? fileInfo= await kCacheManager.downloadFile(videoUrl);
      File cachedFile = fileInfo.file;
      print("22======================================$fileInfo");
      controller =await VideoPlayerController.file(cachedFile)..initialize().then((_) {
        controller!.play();
        controller!.setVolume(0.0);
        controller!.setLooping(true);
        _isPlaying=true;
        setState(() {});
      });
      print('Failed to fetch video from cache.');
    }
  }

  @override
  void initState() {
    initController();
    // initializePlayer();
    // cacheVideoPlay1();
    super.initState();
  }

  @override
  void dispose() {
    // clearCache();
    controller!.pause();
    controller!.dispose();
    // _cacheController.pause();
    // _cacheController.dispose();
    super.dispose();
  }

  void clearCache() async {
    await kCacheManager.emptyCache();
    print('Cache cleared.');
  }

  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    // if (_cacheController.value.isInitialized) {return const Center(child: CircularProgressIndicator(color: color.txtBlue));}
    return Stack(
      // fit: StackFit.expand,
      children: [_isPlaying ? SizedBox(height: double.infinity, child:
        //_cacheController.value.isInitialized?
        controller!.value.isInitialized?
        Container(
          color: Colors.black,
          child: Center(
            child: AspectRatio(aspectRatio:
            //_cacheController.value.aspectRatio, child: CachedVideoPlayerPlus(_cacheController)):
            controller!.value.aspectRatio, child: VideoPlayer(controller!)),
          ),
        ):
        buildCenter()) : buildCenter(),
        // FutureBuilder(
        //   future: profilecntrl.initializeVideoPlayerFuture,
        //   builder: (context, snapshot) {
        //     if (snapshot.connectionState == ConnectionState.done) {
        //       return Flexible(child: AspectRatio(
        //         aspectRatio: profilecntrl.controller!.value.aspectRatio,
        //         child:VideoPlayer(profilecntrl.controller!),),);
        //         } else {return Center(child: CircularProgressIndicator(color: color.txtBlue));}
        //   }, ),
        GestureDetector(
            onTap: () {
              // Provider.of<profileController>(context,listen: false).videoUrl = _cacheController.dataSource;
              Get.to(()=>ProfileVideoViewer(url:
             // _cacheController.dataSource
              controller!.dataSource
              ))!.then((value) {controller!.play();});
            },
            child:_isPlaying? Center(child:
            // _cacheController.value.isInitialized
            controller!.value.isInitialized
                ? SvgPicture.asset(AssetsPics.videoplayicon):const SizedBox()):buildCenter())
      ],
    );
    // return Consumer<profileController>(builder: (context,val,child){
    //   if (val.cntrl!.value.isInitialized) {return const Center(child: CircularProgressIndicator(color: color.txtBlue));}
    //   return Stack(
    //     fit: StackFit.expand,
    //     children: [
    //       SizedBox(height: double.infinity, child: AspectRatio(aspectRatio: val.cntrl!.value.aspectRatio, child: VideoPlayer(val.cntrl!)),),
    //       GestureDetector(
    //           onTap: () {
    //             Provider.of<profileController>(context,listen: false).videoUrl = val.cntrl!.dataSource;
    //             Get.to(()=>ProfileVideoViewer());
    //           },
    //           child: Center(child: SvgPicture.asset(AssetsPics.videoplayicon)))
    //     ],
    //   );
    // });
  }

  Center buildCenter() => const Center(child: CircularProgressIndicator(color: color.txtBlue));
}