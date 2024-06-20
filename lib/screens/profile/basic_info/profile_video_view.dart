import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/controller/profile_controller.dart';
import 'package:video_player/video_player.dart';

class ProfileVideoViewer extends StatefulWidget {
  ProfileVideoViewer({Key? key}) : super(key: key);
  @override
  State<ProfileVideoViewer> createState() => _ProfileVideoViewerState();
}

class _ProfileVideoViewerState extends State<ProfileVideoViewer> {

  Future disposeVideo(bool val)async{
    Provider.of<profileController>(context,listen: false).stopVideo();
  }

  @override
  Widget build(BuildContext context) {
    final profilecntrl=Provider.of<profileController>(context,listen: false);
    final size = MediaQuery.of(context).size;
    return PopScope(
      canPop: true,
      onPopInvoked: disposeVideo,
      child: Scaffold(
        backgroundColor: color.txtBlack,
        body: Center(
          child: Container(
              height: size.height,
              width: size.width,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FutureBuilder(
                        future: profilecntrl.initializeVideoPlayerFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            return Flexible(
                              child: AspectRatio(
                                aspectRatio: profilecntrl.controller!.value.aspectRatio,
                                child:VideoPlayer(profilecntrl.controller!),
                                // Stack(
                                //   children: [
                                //     VideoPlayer(profilecntrl.controller!),
                                    // Align(
                                    //   alignment: Alignment.bottomRight,
                                    //   child: IconButton(
                                    //     icon: Icon(
                                    //       profilecntrl.isPlaying ? Icons.pause : Icons.play_arrow,
                                    //     ),
                                    //     onPressed: () => profilecntrl.isPlaying = !profilecntrl.isPlaying,
                                    //   ),
                                    // ),
                                //   ],
                                // ),
                              ),
                            );
                          } else {
                            return Center(child: CircularProgressIndicator(color: color.txtBlue));
                          }
                        },
                      ),
                    ],
                  ),
                  Positioned(
                    top: 50,
                    left: 8,
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                        // _controller!.pause();
                        profilecntrl.stopVideo();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Container(
                            padding: EdgeInsets.all(9),
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              // color: Colors.red,
                                borderRadius: BorderRadius.circular(20)
                            ),
                            child: SvgPicture.asset(AssetsPics.arrowLeft,color: color.txtWhite))
                        // SvgPicture.asset(AssetsPics.arrowLeft,height: 18,color: color.txtWhite),
                      ),
                    ),
                  )
                ],
              )
          ),
        ),
      ),
    );
  }
}
