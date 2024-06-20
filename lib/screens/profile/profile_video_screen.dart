import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/controller/profile_controller.dart';
import 'package:slush/screens/profile/basic_info/profile_video_view.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatefulWidget {
  final String url;
  const VideoScreen({Key? key, required this.url}) : super(key: key);

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VideoPlayerController controller;

  void initController() async {
    // Provider.of<profileController>(context,listen: false).initController(widget.url);
    controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    await controller.initialize().then((value) {
      controller.play();
      controller.setVolume(0.0);
        controller.setLooping(true);
    });
  }

  @override
  void initState() {
    initController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    if (controller.value.isInitialized) {return const Center(child: CircularProgressIndicator(color: color.txtBlue));}
    return Stack(
      fit: StackFit.expand,
      children: [
        SizedBox(height: double.infinity, child: AspectRatio(aspectRatio: controller.value.aspectRatio, child: VideoPlayer(controller)),),
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
              Provider.of<profileController>(context,listen: false).videoUrl = controller.dataSource;
              Get.to(()=>ProfileVideoViewer());
            },
            child: Center(child: SvgPicture.asset(AssetsPics.videoplayicon)))
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
}