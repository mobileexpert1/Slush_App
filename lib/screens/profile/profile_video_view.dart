import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:slush/constants/color.dart';
import 'package:video_player/video_player.dart';

import '../../constants/image.dart';


class VideoViewScreen extends StatefulWidget {
  const VideoViewScreen({super.key,required this.selectedIndexId,required this.url});
  final int selectedIndexId;
  final String url;

  @override
  State<VideoViewScreen> createState() => _VideoViewScreenState();
}

class _VideoViewScreenState extends State<VideoViewScreen> {
   Future<void>? _initializeVideoPlayerFuture;
   VideoPlayerController? controller;

  @override
  void initState() {
    controller = VideoPlayerController.networkUrl(Uri.parse(widget.url),);

    _initializeVideoPlayerFuture = controller!.initialize();
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      // appBar: commonBar(context,Colors.transparent),
      // appBar: AppBar(),
      backgroundColor: color.txtBlack,
      body: Container(
          height: size.height,
          width: size.width,
          child:controller==null?CircularProgressIndicator(): Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      height: size.height/1.5,
                      width: size.width,
                      child: Stack(
                        fit: StackFit.expand,
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20)
                            ),
                            child:  buildVideoContainer(controller!, _initializeVideoPlayerFuture!)

                          )
                        ],
                      )),
                ],
              ),
              Positioned(
                top: 50,
                left: 15,
                child: GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SvgPicture.asset(AssetsPics.arrowLeft,color: Colors.white,height: 18,),
                  ),
                ),
              )
            ],
          )
      ),
    );
  }

}
Widget buildVideoContainer(VideoPlayerController cntrl, Future<void> func) {
  return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          FutureBuilder(
            future: func,
            builder: (context, snapshot) {
            /*  return AspectRatio(
                aspectRatio: cntrl.value.aspectRatio,
                child: VideoPlayer(cntrl),
              );*/
              if (snapshot.connectionState == ConnectionState.done) {
                // If the VideoPlayerController has finished initialization, use
                // the data it provides to limit the aspect ratio of the video.
                return AspectRatio(
                  aspectRatio: cntrl.value.aspectRatio,
                  // Use the VideoPlayer widget to display the video.
                  child: VideoPlayer(cntrl),
                );
              } else {
                // If the VideoPlayerController is still initializing, show a
                // loading spinner.
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

            },
          ),
          GestureDetector(
              onTap: () {cntrl.play();},
              child: cntrl.value.isInitialized?SizedBox(): Container(
                  alignment: Alignment.center,
                  child: SvgPicture.asset(AssetsPics.videoplayicon)))
        ],
      ));
}