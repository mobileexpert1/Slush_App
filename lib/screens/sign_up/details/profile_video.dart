
/*import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:video_player/video_player.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:video_trimmer/video_trimmer.dart';

class DeatilProfileVideoScreen extends StatefulWidget {
  const DeatilProfileVideoScreen({Key? key}) : super(key: key);

  @override
  State<DeatilProfileVideoScreen> createState() => _DeatilProfileVideoScreenState();
}

class _DeatilProfileVideoScreenState extends State<DeatilProfileVideoScreen> {
  String selcetedIndex="";
  late VideoPlayerController _controller;

  File? videoFile;
  final picker = ImagePicker();
  File? galleryFile;

  Future getVideo(ImageSource img) async {
    final allowedTimeLimit = Duration(seconds: 4);
    final allowedTimeLimit2 = Duration(minutes: 5);
    final pickedFile = await picker.pickVideo(source: img,
        preferredCameraDevice: CameraDevice.front,
        maxDuration: const Duration(seconds: 15));
    XFile? xfilePick = pickedFile;
    setState(() {
      if (xfilePick != null) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(pickedFile!.path))..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          setState(() {
            if(_controller.value.duration<=allowedTimeLimit){
              palyVideo(File(pickedFile.path));
            }else if(_controller.value.duration<=allowedTimeLimit2){
              trimmer=true;
              _loadVideo(File(pickedFile.path));
              Future.delayed(Duration(seconds: 3),(){
                // _saveVideo();
              });
            }else{
              galleryFile=null;
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: buildText("Video should be less then 15 seconds", 16, FontWeight.w500, color.txtWhite)));
            }
          });
        });
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nothing is selected')));
      }},
    );
  }

  void getValueInController(String outputVideoPath){
    _controller = VideoPlayerController.file(File(outputVideoPath))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  palyVideo(File file){
    galleryFile = file;
    LocaleHandler.introVideo=galleryFile;
    _controller.play();
    _controller.setPlaybackSpeed(0.8);
  }

  bool trimmer=false;
  final Trimmer _trimmer = Trimmer();
  double _startValue = 0.0;
  double _endValue = 0.0;
  bool _isPlaying = false;
  bool _progressVisibility = false;

  void _loadVideo(File file) {
    _trimmer.loadVideo(videoFile: file);
  }

  _saveVideo() {
    setState(() {_progressVisibility = true;});
    _trimmer.saveTrimmedVideo(
      startValue: _startValue,
      endValue: _endValue,
      ffmpegCommand: '-i input.mp4 -ss 0 -t 4 output.mp4',
      // ffmpegCommand: '-i ${_trimmer.videoPlayerController!.dataSource} -ss 00:00:00 -t 00:00:04 -c copy ${_trimmer.outputPath}/trimmed_video.mp4',
      // ffmpegCommand: '-c:a aac -c:v copy',
      customVideoFormat: '.mp4',
      onSave: (outputPath) {
        setState(() {_progressVisibility = false;});
        debugPrint('OUTPUT PATH: $outputPath');
        _trimmer.currentVideoFile;
        palyVideo(File(_trimmer.currentVideoFile!.path));
        trimmer=false;
        if(outputPath!=null){
          getValueInController(outputPath);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return trimmer?Center(
      child: Container(
        padding: const EdgeInsets.only(bottom: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Visibility(
              visible: _progressVisibility,
              child: const LinearProgressIndicator(
                backgroundColor: Colors.red,
              ),
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _progressVisibility ? null : () => _saveVideo(),
                  child: const Text("SAVE"),
                ),
                ElevatedButton(
                  onPressed: _progressVisibility ? null : () {trimmer=false;},
                  child: const Text("Cancel"),
                ),
              ],
            ),
            Expanded(child: VideoViewer(trimmer: _trimmer)),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TrimViewer(
                  trimmer: _trimmer,
                  viewerHeight: 50.0,
                  viewerWidth: MediaQuery.of(context).size.width,
                  durationStyle: DurationStyle.FORMAT_MM_SS,
                  maxVideoLength: const Duration(seconds: 4),
                  editorProperties: TrimEditorProperties(
                    borderPaintColor: Colors.yellow,
                    borderWidth: 4,
                    borderRadius: 5,
                    circlePaintColor: Colors.yellow.shade800,
                  ),
                  areaProperties: TrimAreaProperties.edgeBlur(
                    thumbnailQuality: 10,
                  ),
                  onChangeStart: (value) => _startValue = value,
                  onChangeEnd: (value) => _endValue = value,
                  onChangePlaybackState: (value) =>
                      setState(() => _isPlaying = value),
                ),
              ),
            ),
            TextButton(
              child: _isPlaying
                  ? const Icon(
                Icons.pause,
                size: 80.0,
                color: Colors.white,
              )
                  : const Icon(
                Icons.play_arrow,
                size: 80.0,
                color: Colors.white,
              ),
              onPressed: () async {
                bool playbackState = await _trimmer.videoPlaybackControl(
                  startValue: _startValue,
                  endValue: _endValue,
                );
                setState(() => _isPlaying = playbackState);
              },
            )
          ],
        ),
      ),
    ): Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 3.h-3),
        buildText("Show yourself with a video.", 28, FontWeight.w600, color.txtBlack),
        const SizedBox(height: 8),
        buildText("Please upload a photo.", 15, FontWeight.w500, color.txtBlack,fontFamily: FontFamily.hellix),
        SizedBox(height: 4.h-10),
        DottedBorder(
          color: color.lightestBlue,
          strokeWidth: 2,
          radius: const Radius.circular(12),
          borderType: BorderType.RRect,
          stackFit: StackFit.loose,
          dashPattern:const [7, 7],
          child: GestureDetector(
            onTap: (){
              buildShowModalBottomSheet(context);
            },
            child: Container(
                height: 240,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),color: Colors.white,),
                width: MediaQuery.of(context).size.width-30,
                child: galleryFile != null ?ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        VideoPlayer(_controller),
                        GestureDetector(
                            onLongPress: (){
                              buildShowModalBottomSheet(context);
                            },
                            onTap: (){
                              _controller.play();
                            },
                            child: SvgPicture.asset(AssetsPics.videoplayicon)),
                      ],
                    ),
                  ),
                ): Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(AssetsPics.uploadVideoIcon),
                    const SizedBox(height: 6),
                    buildText("Upload Video", 16, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix)
                  ],)
            ),
          ),
        ),
        // Spacer(),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.only(top: 12,bottom: 12,left: 10,right: 10),
          // color: Colors.amber,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(width: 1,color: color.lightestBlue),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildText("Don't know what to show? ", 18, FontWeight.w600, color.txtBlack),
                  CircleAvatar(
                    radius: 9,
                    backgroundColor: color.txtWhite,
                    child: SvgPicture.asset(AssetsPics.iIcon,fit: BoxFit.cover,),
                  ),
                ],),
              SizedBox(height: 5),
              buildText("Some examples include : ", 15, FontWeight.w400, color.txtgrey2,fontFamily: FontFamily.hellix),
              SizedBox(height: 5),
              Row(children: [
                const SizedBox(width: 8),
                const CircleAvatar(
                  radius: 2,
                  backgroundColor: color.txtgrey2,
                ),
                buildText("  Showcase a talent", 15, FontWeight.w400, color.txtgrey2,fontFamily: FontFamily.hellix),
              ],),
              SizedBox(height: 4),
              Row(children: [
                const SizedBox(width: 8),
                const CircleAvatar(
                  radius: 2,
                  backgroundColor: color.txtgrey2,
                ),
                buildText("  A day in your life", 15, FontWeight.w400, color.txtgrey2,fontFamily: FontFamily.hellix),
              ],),
              SizedBox(height: 4),
              Row(children: [
                const SizedBox(width: 8),
                const CircleAvatar(
                  radius: 2,
                  backgroundColor: color.txtgrey2,
                ),
                buildText("  A hobby you like to do", 15, FontWeight.w400, color.txtgrey2,fontFamily: FontFamily.hellix),
              ],),
              SizedBox(height: 4),

            ],
          ),
        ),
        SizedBox(height: 2.h-10)
      ],);


  }

  Future<void> buildShowModalBottomSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          margin:  EdgeInsets.only(left: 16,right: 16,bottom: 3.h-2),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: color.txtWhite,
              borderRadius: BorderRadius.circular(16)
          ),
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 18),
                height: 220,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(AssetsPics.videodemo,fit: BoxFit.cover,alignment: Alignment.topCenter,)),
              ),
              blue_button(context, "ok",press: (){
                Get.back();
                showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (BuildContext context) {
                    return Container(
                      margin:  EdgeInsets.only(left: 16,right: 16,bottom: 3.h-2),
                      padding: const EdgeInsets.only(top: 25,bottom: 25),
                      decoration: BoxDecoration(color: color.txtWhite,
                          borderRadius: BorderRadius.circular(16)
                      ),
                      width: MediaQuery.of(context).size.width,
                      child: StatefulBuilder(
                          builder: (BuildContext context, StateSetter setState) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 20,right: 20),
                                  child: GestureDetector(
                                    onTap: (){
                                      setState(() {
                                        selcetedIndex="0";
                                        Future.delayed(Duration(seconds: 1),(){
                                          getVideo(ImageSource.camera);
                                          Get.back();
                                          selcetedIndex="";
                                        });
                                      });
                                    },
                                    child: Container(color: Colors.transparent,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          buildText("Take a Video", 18,selcetedIndex=="0"?FontWeight.w600:FontWeight.w500, color.txtBlack),
                                          CircleAvatar(
                                            backgroundColor: selcetedIndex=="0"?color.txtBlue:color.txtWhite,
                                            radius: 9,
                                            child: CircleAvatar(
                                              radius: 8,
                                              backgroundColor: selcetedIndex=="0"?color.txtWhite:color.txtWhite,
                                              // backgroundImage: SvgPicture.asset(AssetsPics.arrowLeft),
                                              child: selcetedIndex=="0"?SvgPicture.asset(AssetsPics.blueTickCheck,fit: BoxFit.cover,):const SizedBox(),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const Divider(thickness: 0.2),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20,right: 20),
                                  child: GestureDetector(
                                    onTap: (){
                                      setState(() {
                                        selcetedIndex="1";
                                        Future.delayed(Duration(seconds: 1),(){
                                          getVideo(ImageSource.gallery);
                                          Get.back();
                                          selcetedIndex="";
                                        });
                                      });
                                    },
                                    child: Container(color: Colors.transparent,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          buildText("Choose from Gallery", 18,selcetedIndex=="1"? FontWeight.w600:FontWeight.w500, color.txtBlack),
                                          CircleAvatar(
                                            backgroundColor: selcetedIndex=="1"?color.txtBlue:color.txtWhite,
                                            radius: 9,
                                            child: CircleAvatar(
                                              radius: 8,
                                              backgroundColor: selcetedIndex=="1"?color.txtWhite:color.txtWhite,
                                              // backgroundImage: SvgPicture.asset(AssetsPics.arrowLeft),
                                              child: selcetedIndex=="1"?SvgPicture.asset(AssetsPics.blueTickCheck,fit: BoxFit.cover,):const SizedBox(),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // buildText("Choose from Gallery", 18, FontWeight.w500, color.txtBlack),
                              ],);
                          }
                      ),
                    );
                  },
                );
              })
            ],),
        );
      },
    );
  }
}*/


//=---------------------------TOdo

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/controller/detail_controller.dart';
import 'package:slush/screens/sign_up/details/video_trimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/text_widget.dart';

class DeatilProfileVideoScreen extends StatefulWidget {
  const DeatilProfileVideoScreen({Key? key}) : super(key: key);

  @override
  State<DeatilProfileVideoScreen> createState() => _DeatilProfileVideoScreenState();
}

class _DeatilProfileVideoScreenState extends State<DeatilProfileVideoScreen> {
  // String selcetedIndex="";
  // late VideoPlayerController _controller;

  // File? videoFile;
  // final picker = ImagePicker();
  // File? galleryFile;
  //
  // Future getVideo(ImageSource img) async {
  //   final allowedTimeLimit = Duration(seconds: 16);
  //   final allowedTimeLimit2 = Duration(minutes: 10);
  //   final pickedFile = await picker.pickVideo(source: img,
  //       preferredCameraDevice: CameraDevice.front,
  //       maxDuration: const Duration(seconds: 15));
  //   XFile? xfilePick = pickedFile;
  //   setState(() {
  //       if (xfilePick != null) {
  //         _controller = VideoPlayerController.networkUrl(Uri.parse(pickedFile!.path))..initialize().then((_) {
  //             // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
  //             setState(() {
  //                 if(_controller.value.duration<=allowedTimeLimit){
  //                   palyVideo(File(pickedFile.path));
  //                 }else if(_controller.value.duration<=allowedTimeLimit2){
  //                 trimmer=true;
  //                 _loadVideo(File(pickedFile.path));
  //                 }else{
  //                   galleryFile=null;
  //                   setState(() {});
  //                   ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: buildText("Video should be less then 15 seconds", 16, FontWeight.w500, color.txtWhite)));
  //                 }
  //               });
  //           });
  //       } else {
  //         // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nothing is selected')));
  //       }},
  //   );
  // }
  //
  // palyVideo(File file){
  //   galleryFile = file;
  //   LocaleHandler.introVideo=galleryFile;
  //   _controller.play();
  //   _controller.setPlaybackSpeed(0.8);
  // }
  //
  // bool trimmer=false;
  // final Trimmer _trimmer = Trimmer();
  // double _startValue = 0.0;
  // double _endValue = 0.0;
  // bool _isPlaying = false;
  // bool _progressVisibility = false;
  //
  // void _loadVideo(File file) {
  //   _trimmer.loadVideo(videoFile: file);
  // }
  //
  // _saveVideo() {
  //   setState(() {_progressVisibility = true;});
  //   _trimmer.saveTrimmedVideo(
  //     startValue: _startValue,
  //     endValue: _endValue,
  //     // ffmpegCommand: '-i ${_trimmer.videoPlayerController!.dataSource} -ss ${_startValue.toString()} -t ${_endValue.difference(_startValue).inSeconds} -c copy ${_trimmer.outputPath}/trimmed_video.mp4',
  //     ffmpegCommand: '-c:a aac -c:v copy',
  //     customVideoFormat: '.mp4',
  //     onSave: (outputPath) {
  //       setState(() {_progressVisibility = false;});
  //       debugPrint('OUTPUT PATH: $outputPath');
  //       _trimmer.currentVideoFile;
  //       palyVideo(File(_trimmer.currentVideoFile!.path));
  //       trimmer=false;
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final detailcntrl=Provider.of<detailedController>(context,listen: false);
    return Consumer<detailedController>(builder: (context,valuee,child){
      return valuee.trimmerstrt ?
      VideoTrimmerScreen() : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 3.h-3),
            buildText(valuee.trimmerstrt?"":"Show yourself with a video.", 28, FontWeight.w600, color.txtBlack),
            const SizedBox(height: 8),
            buildText(valuee.trimmerstrt?"":"Please upload a video.", 15, FontWeight.w500, color.txtBlack,fontFamily: FontFamily.hellix),
            SizedBox(height: 4.h-10),
            valuee.trimmerstrt?SizedBox():DottedBorder(
              color: color.lightestBlue,
              strokeWidth: 2,
              radius: const Radius.circular(12),
              borderType: BorderType.RRect,
              stackFit: StackFit.loose,
              dashPattern:const [7, 7],
              child: GestureDetector(
                onTap: (){
                  buildShowModalBottomSheet(context);
                },
                child: Container(
                    height: 240,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),color: Colors.white,),
                    width: MediaQuery.of(context).size.width-30,
                    child: Consumer<detailedController>(builder: (context,val,child){
                      return val.galleryFile != null ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: val.controller.value.aspectRatio,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              VideoPlayer(val.controller),
                              GestureDetector(
                                  onTap: (){val.controller.play();},
                                  // child:val.controller.value.isPlaying?SizedBox(): SvgPicture.asset(AssetsPics.videoplayicon)),
                                  child: SvgPicture.asset(AssetsPics.videoplayicon)),
                            ],
                          ),
                        ),
                      ): Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(AssetsPics.uploadVideoIcon),
                          const SizedBox(height: 6),
                          buildText("Upload Video", 16, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix)
                        ],);
                    })
                ),
              ),
            ),
            // Spacer(),
            const SizedBox(height: 28),
            valuee.trimmerstrt?SizedBox(): Container(
              padding: const EdgeInsets.only(top: 12,bottom: 12,left: 10,right: 10),
              // color: Colors.amber,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(width: 1,color: color.lightestBlue),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ElevatedButton(onPressed: (){
                  //   detailcntrl.cancelSelectedTrimVideo();
                  // }, child: Text("remove")),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildText("Don't know what to show? ", 18, FontWeight.w600, color.txtBlack),
                      CircleAvatar(
                        radius: 9,
                        backgroundColor: color.txtWhite,
                        child: SvgPicture.asset(AssetsPics.iIcon,fit: BoxFit.cover,),
                      ),
                    ],),
                  SizedBox(height: 5),
                  buildText("Some examples include : ", 15, FontWeight.w400, color.txtgrey2,fontFamily: FontFamily.hellix),
                  SizedBox(height: 5),
                  Row(children: [
                    const SizedBox(width: 8),
                    const CircleAvatar(
                      radius: 2,
                      backgroundColor: color.txtgrey2,
                    ),
                    buildText("  Showcase a talent", 15, FontWeight.w400, color.txtgrey2,fontFamily: FontFamily.hellix),
                  ],),
                  SizedBox(height: 4),
                  Row(children: [
                    const SizedBox(width: 8),
                    const CircleAvatar(
                      radius: 2,
                      backgroundColor: color.txtgrey2,
                    ),
                    buildText("  A day in your life", 15, FontWeight.w400, color.txtgrey2,fontFamily: FontFamily.hellix),
                  ],),
                  SizedBox(height: 4),
                  Row(children: [
                    const SizedBox(width: 8),
                    const CircleAvatar(
                      radius: 2,
                      backgroundColor: color.txtgrey2,
                    ),
                    buildText("  A hobby you like to do", 15, FontWeight.w400, color.txtgrey2,fontFamily: FontFamily.hellix),
                  ],),
                  SizedBox(height: 4),

                ],
              ),
            ),
            SizedBox(height: 2.h-10)
          ],),
      );
    });

  }

  Future<void> buildShowModalBottomSheet(BuildContext context) {
    final detailcntrl=Provider.of<detailedController>(context,listen: false);
    return showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (BuildContext context) {
                    return Container(
                      margin:  EdgeInsets.only(left: 16,right: 16,bottom: 3.h-2),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(color: color.txtWhite,
                          borderRadius: BorderRadius.circular(16)
                      ),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 18),
                            height: 220,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(AssetsPics.videodemo,fit: BoxFit.cover,alignment: Alignment.topCenter,)),
                          ),
                          blue_button(context, "Ok",press: (){
                            Get.back();
                            showModalBottomSheet<void>(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (BuildContext context) {
                                return Container(
                                  margin:  EdgeInsets.only(left: 16,right: 16,bottom: 3.h-2),
                                  padding: const EdgeInsets.only(top: 25,bottom: 25),
                                  decoration: BoxDecoration(color: color.txtWhite,
                                      borderRadius: BorderRadius.circular(16)
                                  ),
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 20,right: 20),
                                        child: GestureDetector(
                                          onTap: (){
                                            detailcntrl.tappedOption(context, ImageSource.camera, "0");
                                          },
                                          child: Consumer<detailedController>(
                                            builder: (context,val,child){
                                              return Container(color: Colors.transparent,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    buildText("Take a Video", 18,val.selcetedIndex=="0"?FontWeight.w600:FontWeight.w500, color.txtBlack),
                                                    CircleAvatar(
                                                      backgroundColor: val.selcetedIndex=="0"?color.txtBlue:color.txtWhite,
                                                      radius: 9,
                                                      child: CircleAvatar(
                                                        radius: 8,
                                                        backgroundColor: val.selcetedIndex=="0"?color.txtWhite:color.txtWhite,
                                                        // backgroundImage: SvgPicture.asset(AssetsPics.arrowLeft),
                                                        child: val.selcetedIndex=="0"?SvgPicture.asset(AssetsPics.blueTickCheck,fit: BoxFit.cover,):const SizedBox(),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      const Divider(thickness: 0.2),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 20,right: 20),
                                        child: GestureDetector(
                                          onTap: (){
                                            detailcntrl.tappedOption(context, ImageSource.gallery, "1");
                                          },
                                          child: Consumer<detailedController>(builder: (context,val,child){
                                            return Container(color: Colors.transparent,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  buildText("Choose from Gallery", 18,val.selcetedIndex=="1"? FontWeight.w600:FontWeight.w500, color.txtBlack),
                                                  CircleAvatar(
                                                    backgroundColor: val.selcetedIndex=="1"?color.txtBlue:color.txtWhite,
                                                    radius: 9,
                                                    child: CircleAvatar(
                                                      radius: 8,
                                                      backgroundColor: val.selcetedIndex=="1"?color.txtWhite:color.txtWhite,
                                                      // backgroundImage: SvgPicture.asset(AssetsPics.arrowLeft),
                                                      child: val.selcetedIndex=="1"?SvgPicture.asset(AssetsPics.blueTickCheck,fit: BoxFit.cover,):const SizedBox(),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            );
                                          },),
                                        ),
                                      ),
                                      // buildText("Choose from Gallery", 18, FontWeight.w500, color.txtBlack),
                                    ],),
                                );
                              },
                            );
                          })
                        ],),
                    );
                  },
                );
  }

}

/*import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:video_player/video_player.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/text_widget.dart';

class DeatilProfileVideoScreen extends StatefulWidget {
  const DeatilProfileVideoScreen({Key? key}) : super(key: key);

  @override
  State<DeatilProfileVideoScreen> createState() => _DeatilProfileVideoScreenState();
}

class _DeatilProfileVideoScreenState extends State<DeatilProfileVideoScreen> {
  String selcetedIndex="";
  late VideoPlayerController _controller;

  File? videoFile;
  final picker = ImagePicker();
  File? galleryFile;

  Future getVideo(ImageSource img) async {
    final allowedTimeLimit = Duration(seconds: 16);
    final pickedFile = await picker.pickVideo(source: img,
        preferredCameraDevice: CameraDevice.front,
        maxDuration: const Duration(seconds: 15));
    XFile? xfilePick = pickedFile;
    setState(() {
        if (xfilePick != null) {
          if(Platform.isAndroid){_controller = VideoPlayerController.networkUrl(Uri.parse(pickedFile!.path));}
          else{_controller = VideoPlayerController.file(File(pickedFile!.path));}
          _controller..initialize().then((_) {
            setState(() {
                  if(_controller.value.duration<=allowedTimeLimit){
                    galleryFile = File(pickedFile.path);
                    LocaleHandler.introVideo=galleryFile;
                    _controller.play();
                    // _controller.setLooping(true);
                    _controller.setPlaybackSpeed(0.8);
                  } else {
                    galleryFile=null;
                   setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: buildText("Video should be less then 15 seconds", 16, FontWeight.w500, color.txtWhite)));}
                });
            });
        } else {
          // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nothing is selected')));
        }},
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           SizedBox(height: 3.h-3),
          buildText("Show yourself with a video.", 28, FontWeight.w600, color.txtBlack),
          const SizedBox(height: 8),
          buildText("Please upload a photo.", 15, FontWeight.w500, color.txtBlack,fontFamily: FontFamily.hellix),
           SizedBox(height: 4.h-10),
          DottedBorder(
            color: color.lightestBlue,
            strokeWidth: 2,
            radius: const Radius.circular(12),
            borderType: BorderType.RRect,
            stackFit: StackFit.loose,
            dashPattern:const [7, 7],
            child: GestureDetector(
              onTap: (){
                buildShowModalBottomSheet(context);
              },
              child: Container(
                  height: 240,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),color: Colors.white),
                  width: MediaQuery.of(context).size.width-30,
                  child: galleryFile != null ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          VideoPlayer(_controller),
                          GestureDetector(
                              onTap: (){
                                _controller.play();
                              },
                              child: SvgPicture.asset(AssetsPics.videoplayicon)),
                        ],
                      ),
                    ),
                  ): Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(AssetsPics.uploadVideoIcon),
                      const SizedBox(height: 6),
                      buildText("Upload Video", 16, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix)
                    ],)
              ),
            ),
          ),
          // Spacer(),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.only(top: 12,bottom: 12,left: 10,right: 10),
            // color: Colors.amber,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(width: 1,color: color.lightestBlue),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildText("Don't know what to show? ", 18, FontWeight.w600, color.txtBlack),
                    CircleAvatar(
                      radius: 9,
                      backgroundColor: color.txtWhite,
                      child: SvgPicture.asset(AssetsPics.iIcon,fit: BoxFit.cover,),
                    ),
                  ],),
                SizedBox(height: 5),
                buildText("Some examples include : ", 15, FontWeight.w400, color.txtgrey2,fontFamily: FontFamily.hellix),
                SizedBox(height: 5),
                Row(children: [
                  const SizedBox(width: 8),
                  const CircleAvatar(
                    radius: 2,
                    backgroundColor: color.txtgrey2,
                  ),
                  buildText("  Showcase a talent", 15, FontWeight.w400, color.txtgrey2,fontFamily: FontFamily.hellix),
                ],),
                SizedBox(height: 4),
                Row(children: [
                  const SizedBox(width: 8),
                  const CircleAvatar(
                    radius: 2,
                    backgroundColor: color.txtgrey2,
                  ),
                  buildText("  A day in your life", 15, FontWeight.w400, color.txtgrey2,fontFamily: FontFamily.hellix),
                ],),
                SizedBox(height: 4),
                Row(children: [
                  const SizedBox(width: 8),
                  const CircleAvatar(
                    radius: 2,
                    backgroundColor: color.txtgrey2,
                  ),
                  buildText("  A hobby you like to do", 15, FontWeight.w400, color.txtgrey2,fontFamily: FontFamily.hellix),
                ],),
                SizedBox(height: 4),
      
              ],
            ),
          ),
           SizedBox(height: 2.h-10)
        ],),
    );


  }

  Future<void> buildShowModalBottomSheet(BuildContext context) {
    return showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (BuildContext context) {
                    return Container(
                      margin:  EdgeInsets.only(left: 16,right: 16,bottom: 3.h-2),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(color: color.txtWhite,
                          borderRadius: BorderRadius.circular(16)
                      ),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 18),
                            height: 220,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(AssetsPics.videodemo,fit: BoxFit.cover,alignment: Alignment.topCenter,)),
                          ),
                          blue_button(context, "ok",press: (){
                            Get.back();
                            showModalBottomSheet<void>(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (BuildContext context) {
                                return Container(
                                  margin:  EdgeInsets.only(left: 16,right: 16,bottom: 3.h-2),
                                  padding: const EdgeInsets.only(top: 25,bottom: 25),
                                  decoration: BoxDecoration(color: color.txtWhite,
                                      borderRadius: BorderRadius.circular(16)
                                  ),
                                  width: MediaQuery.of(context).size.width,
                                  child: StatefulBuilder(
                                      builder: (BuildContext context, StateSetter setState) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 20,right: 20),
                                            child: GestureDetector(
                                              onTap: (){
                                                setState(() {
                                                  selcetedIndex="0";
                                                  Future.delayed(Duration(seconds: 1),(){
                                                    getVideo(ImageSource.camera);
                                                    Get.back();
                                                    selcetedIndex="";
                                                  });
                                                });
                                              },
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  buildText("Take a Video", 18,selcetedIndex=="0"?FontWeight.w600:FontWeight.w500, color.txtBlack),
                                                  CircleAvatar(
                                                    backgroundColor: selcetedIndex=="0"?color.txtBlue:color.txtWhite,
                                                    radius: 9,
                                                    child: CircleAvatar(
                                                      radius: 8,
                                                      backgroundColor: selcetedIndex=="0"?color.txtWhite:color.txtWhite,
                                                      // backgroundImage: SvgPicture.asset(AssetsPics.arrowLeft),
                                                      child: selcetedIndex=="0"?SvgPicture.asset(AssetsPics.blueTickCheck,fit: BoxFit.cover,):const SizedBox(),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          const Divider(thickness: 0.2),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 20,right: 20),
                                            child: GestureDetector(
                                              onTap: (){
                                                setState(() {
                                                  selcetedIndex="1";
                                                  Future.delayed(Duration(seconds: 1),(){
                                                    getVideo(ImageSource.gallery);
                                                    Get.back();
                                                    selcetedIndex="";
                                                  });
                                                });
                                              },
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  buildText("Choose from Gallery", 18,selcetedIndex=="1"? FontWeight.w600:FontWeight.w500, color.txtBlack),
                                                  CircleAvatar(
                                                    backgroundColor: selcetedIndex=="1"?color.txtBlue:color.txtWhite,
                                                    radius: 9,
                                                    child: CircleAvatar(
                                                      radius: 8,
                                                      backgroundColor: selcetedIndex=="1"?color.txtWhite:color.txtWhite,
                                                      // backgroundImage: SvgPicture.asset(AssetsPics.arrowLeft),
                                                      child: selcetedIndex=="1"?SvgPicture.asset(AssetsPics.blueTickCheck,fit: BoxFit.cover,):const SizedBox(),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          // buildText("Choose from Gallery", 18, FontWeight.w500, color.txtBlack),
                                        ],);
                                    }
                                  ),
                                );
                              },
                            );
                          })
                        ],),
                    );
                  },
                );
  }
}*/
