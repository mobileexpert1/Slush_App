import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/controller/detail_controller.dart';
import 'package:slush/controller/edit_profile_controller.dart';
import 'package:slush/controller/spark_Liked_controler.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:video_player/video_player.dart';

import '../constants/color.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    // TODO: implement initState
    super.initState();
  }

bool front=true;

  @override
  Widget build(BuildContext context) {
    final pr=Provider.of<detailedController>(context,listen: false);
    final size=MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<detailedController>(builder: (ctx,val,child){
        return Stack(
          children: [
            Positioned(
              top: 50,
              child: Container(
                height: size.height/1.5,
                width: size.width,
                color: Colors.grey,
                child: CameraPreview(val.camcontroller!),
              ),
            ),
            Positioned(
              left: 50.0,
              right: 50.0,
              bottom: 40.0,
              child: GestureDetector(
                  onTap: (){
                    pr.onTakePictureButtonPressed(context);},
                  child: const Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.circle,color: Colors.white70,size: 100),
                      Icon(Icons.circle,color: Colors.white,size: 80),
                    ],
                  )),
            ),
            Positioned(
              // left: 0.0,
              right: 60.0,
              bottom: 70.0,
              child: GestureDetector(
                onTap: () {
                  front=!front;
                  if(front){pr.pickImageFromCamera(CameraLensDirection.front);}
                  else{pr.pickImageFromCamera(CameraLensDirection.back);}
                },
                child: SvgPicture.asset(AssetsPics.camrotate,height: 40),
              ),
            )
          ],
        );
      })
    );
  }
}


//--------------------- Edit profile
class CameraEditScreen extends StatefulWidget {
  const CameraEditScreen({Key? key}) : super(key: key);
  @override
  State<CameraEditScreen> createState() => _CameraEditScreenState();
}

class _CameraEditScreenState extends State<CameraEditScreen> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    // TODO: implement initState
    super.initState();
  }
  @override
  void dispose() {
    // Provider.of<detailedController>(context,listen: false).disposecam();
    // Provider.of<editProfileController>(context,listen: false).disposecam();
    super.dispose();
  }
  bool front=true;
  @override
  Widget build(BuildContext context) {
    final pr=Provider.of<editProfileController>(context,listen: false);
    final size=MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.black,
        body: Consumer<editProfileController>(builder: (ctx,val,child){
          return Stack(
            children: [
              Positioned(
                top: 50,
                child: Container(
                  height: size.height/1.5,
                  width: size.width,
                  color: Colors.grey,
                  child: CameraPreview(val.camcontroller!),
                ),
              ),
              Positioned(
                left: 50.0,
                right: 50.0,
                bottom: 40.0,
                child: GestureDetector(
                    onTap: (){
                      pr.onTakePictureButtonPressed(context);},
                    child: const Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.circle,color: Colors.white70,size: 100),
                        Icon(Icons.circle,color: Colors.white,size: 80),
                      ],
                    )),
              ),
              Positioned(
                // left: 0.0,
                right: 60.0,
                bottom: 70.0,
                child: GestureDetector(
                  onTap: () {
                    front=!front;
                    if(front){pr.pickImageFromCamera(CameraLensDirection.front);}
                    else{pr.pickImageFromCamera(CameraLensDirection.back);}
                  },
                  child: SvgPicture.asset(AssetsPics.camrotate,height: 40),
                ),
              )
            ],
          );
        })
    );
  }
}

//--------------------- Chat Image
class CameraChatScreen extends StatefulWidget {
  const CameraChatScreen({Key? key}) : super(key: key);
  @override
  State<CameraChatScreen> createState() => _CameraChatScreenState();
}

class _CameraChatScreenState extends State<CameraChatScreen> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    // TODO: implement initState
    super.initState();
  }

  bool front=true;
  @override
  Widget build(BuildContext context) {
    final pr=Provider.of<editProfileController>(context,listen: false);
    final size=MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.black,
        body: Consumer<CamController>(builder: (ctx,val,child){
          return Stack(
            children: [
              Positioned(
                top: 50,
                child: Container(
                  height: size.height/1.5,
                  width: size.width,
                  color: Colors.grey,
                  child: CameraPreview(val.camcontroller),
                ),
              ),
              Positioned(
                left: 50.0,
                right: 50.0,
                bottom: 40.0,
                child: GestureDetector(
                    onTap: (){pr.onTakePictureButtonPressed(context);},
                    child: const Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.circle,color: Colors.white70,size: 100),
                        Icon(Icons.circle,color: Colors.white,size: 80),
                      ],
                    )),
              ),
              Positioned(
                // left: 0.0,
                right: 60.0,
                bottom: 70.0,
                child: GestureDetector(
                  onTap: () {
                    front=!front;
                    if(front){pr.pickImageFromCamera(CameraLensDirection.front);}
                    else{pr.pickImageFromCamera(CameraLensDirection.back);}
                  },
                  child: SvgPicture.asset(AssetsPics.camrotate,height: 40),
                ),
              )
            ],
          );
        })
    );
  }
}

//--------------------- edit profile camera
class RecordVideoScreeb extends StatefulWidget {
  const RecordVideoScreeb({Key? key}) : super(key: key);
  @override
  State<RecordVideoScreeb> createState() => _RecordVideoScreebState();
}

class _RecordVideoScreebState extends State<RecordVideoScreeb> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    // TODO: implement initState
    super.initState();
  }

  bool front=true;
  @override
  Widget build(BuildContext context) {
    final pr=Provider.of<editProfileController>(context,listen: false);
    final size=MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.black,
        body: Consumer<editProfileController>(builder: (ctx,val,child){
          return val.videoFinished==2?
          Stack(
            children: [
              Positioned(
                top: 50,
                child: Container(
                  height: size.height/1.5,
                  width: size.width,
                  color: Colors.grey,
                  child:VideoPlayer(val.controllerr!),
                ),
              ),
              Positioned(
                  left: 50.0,
                  right: 50.0,
                  bottom: 40.0,
                  child: GestureDetector(
                    onTap: (){pr.storeRecord(ctx);},
                    child: const SizedBox(
                        width: 50,
                        // color: Colors.red,
                        child: Icon(Icons.check,color: Colors.white,size: 80)),
                  )),
              Positioned(left: 30.0,
                  top: 11.0,
                  child:val.running && val.secondsLeft!=0? GestureDetector(
                    onTap: (){pr.cancelrecording();},
                    child: Container(
                        width: 45,height: 45,
                        color: Colors.transparent,
                        child: const Icon(Icons.clear,color: Colors.white,size: 30)),
                  ):const SizedBox()),
            ],
          ) : Stack(
            children: [
              Positioned(
                top: 50,
                child: Container(
                  // height: size.height/1.5,
                  width: size.width,
                  color: Colors.grey,
                  child: CameraPreview(val.cam),
                ),
              ),
              Positioned(
                left: 50.0,
                right: 50.0,
                bottom: 40.0,
                child: GestureDetector(
                    onTap: (){if(val.secondsLeft==0){pr.startvideorecording(context);}
                    else{if(val.running){pr.pauseresumetimer(false);}
                      else{pr.pauseresumetimer(true);}}},
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        val.secondsLeft<15? const Icon(Icons.circle,color: Colors.white70,size: 100):const SizedBox(),
                        val.secondsLeft==0?const Icon(Icons.circle,color: Colors.white,size: 80):
                        val.running && val.secondsLeft<15? const Icon(Icons.play_arrow,color: Colors.white,size: 80):
                        val.secondsLeft<15? const Icon(Icons.pause,color: Colors.white,size: 80):const SizedBox(),
                      ],
                    )),
              ),
              Positioned(
                // left: 0.0,
                right: 60.0,
                bottom: 70.0,
                child:val.secondsLeft==0?
                GestureDetector(
                  onTap: () {
                    front=!front;
                    if(front){pr.pickImageFromCamera(CameraLensDirection.front);}
                    else{pr.pickImageFromCamera(CameraLensDirection.back);}
                  },
                  child: SvgPicture.asset(AssetsPics.camrotate,height: 40),
                ):
                const SizedBox(),
              ),
              Positioned(top: 18,
                  left: MediaQuery.of(context).size.width*0.4,
                  child: Container(width: MediaQuery.of(context).size.width*0.2,height: 30,
                  decoration: BoxDecoration(color: Colors.white70,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: buildText(pr.formatTime(val.secondsLeft),18,FontWeight.w500,color.txtBlack),
                  )),
              Positioned(left: 40.0,
                  bottom: 70.0,
                  child: val.running && val.secondsLeft!=0? GestureDetector(
                    onTap: (){pr.finishedRecording();},
                    child: Container(
                        width: 45,height: 45,
                        color: Colors.transparent,
                        child: const Icon(Icons.check,color: Colors.white,size: 40)),
                  ):const SizedBox()),
              Positioned(left: 30.0,
                  top: 11.0,
                  child:val.running && val.secondsLeft!=0? GestureDetector(
                    onTap: (){pr.cancelrecording();},
                    child: Container(
                        width: 45,height: 45,
                        color: Colors.transparent,
                        child: const Icon(Icons.clear,color: Colors.white,size: 30)),
                  ):const SizedBox()),
            ],
          );
        })
    );
  }
}
