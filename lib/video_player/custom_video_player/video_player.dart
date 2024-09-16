/*
// import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/controller/controller.dart';
import 'package:video_player/video_player.dart';
import '../config/cache_config.dart';


class VideoPlayerWidget extends StatefulWidget {
  final String reelUrl;


  const VideoPlayerWidget({super.key, required this.reelUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with WidgetsBindingObserver {
   VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // initializeController();
  }

  bool _videoInitialized = false;

   var fileInfo;

   initializeController() async {

    if (mounted) {
      // _controller = VideoPlayerController.file(fileInfo!.file)
      if(Platform.isAndroid){_controller = VideoPlayerController.networkUrl(Uri.parse(widget.reelUrl));}
      else{_controller = VideoPlayerController.file(File(widget.reelUrl));}
        _controller!..initialize().then((_) {
          setState(() {
            // Future.delayed(Duration(seconds: 5),(){
            //   deleteFileFromCache(widget.reelUrl);
            // });
            _controller!.setLooping(true);
            _controller!.play();
            _videoInitialized = true;
            _controller!.setVolume(1.0);
            // _controller.setVolume(0.0);
          });
        });
      _controller!.addListener(() {
        print(_controller!.value.volume);
        if (_controller!.value.isPlaying && !_isPlaying) {
          // Video has started playing
          // setState(() {
            _isPlaying = true;
          // });
        }
      });
    }
  }
  bool _isPlaying = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // App is in the foreground
      _controller!.play();
    } else if (state == AppLifecycleState.inactive) {
      // App is partially obscured
      _controller!.pause();
    } else if (state == AppLifecycleState.paused) {
      // App is in the background
      _controller!.pause();
    } else if (state == AppLifecycleState.detached) {
      // App is terminated
      _controller!.dispose();
    }
  }

  @override
  void dispose() {
    // log('disposing a controller');
    if (mounted) {
      // _controller!.dispose();
    } // Dispose of the controller when done
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reelcntrol=Provider.of<ReelController>(context,listen: false);
    final size = MediaQuery.of(context).size;
    return SafeArea(
      top: false,
      left: false,
      right: false,
      child:   Consumer<ReelController>(
          builder: (context,value,child) {
            if(_videoInitialized){
              _controller!.setVolume(value.isMute==true?0.0:1.0);
            if(value.pause){
              if(value.pause){_controller!.pause();}else{_controller!.play();}
            }
            }
            return Stack(
            children: [
              GestureDetector(
                onTap: () {
                  if (_videoInitialized) {
                    // setState(() {
                      if(value.pause){reelcntrol.videoPause(false,0);}else{reelcntrol.videoPause(true,0);}
                      if (value.pause) {_controller!.pause();//_isPlaying = false;
                      }
                      else {_controller!.play();//_isPlaying = true;
                      }
                    // });
                  }
                },
                child: Stack(
                  fit: StackFit.expand,
                  alignment: AlignmentDirectional.bottomEnd,
                  children: [
                    !_videoInitialized
                        ? const Center(child: CircularProgressIndicator(color: color.txtBlue))
                        : Container(height: size.height, width: size.width, child: FittedBox(fit: BoxFit.cover,
                              child: Container(height: size.height, width: size.width, child: VideoPlayer(_controller!)),
                            ),
                          ),
                    !_videoInitialized
                        ? const Center(child: CircularProgressIndicator(color: color.txtBlue),)
                        : const SizedBox(),
                    if (value.pause)
                      const Center(
                        child: Icon(
                          Icons.play_arrow,
                          size: 50.0,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
              // here you can add title, user Info,
              // description, views count etc.
            ],
          );
        }
      ),
    );
  }
}
*/
