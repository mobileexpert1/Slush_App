
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
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

  @override
  Widget build(BuildContext context) {
    final detailcntrl=Provider.of<detailedController>(context,listen: false);
    return Consumer<detailedController>(builder: (context,valuee,child){
      return valuee.trimmerstrt ?
      const VideoTrimmerScreen() : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 3.h-3),
            buildText(valuee.trimmerstrt?"":"Show yourself with a video.", 28, FontWeight.w600, color.txtBlack),
            const SizedBox(height: 8),
            buildText(valuee.trimmerstrt?"":"Please upload a video.", 15, FontWeight.w500, color.txtBlack,fontFamily: FontFamily.hellix),
            SizedBox(height: 4.h-10),
            valuee.trimmerstrt?const SizedBox():DottedBorder(
              color: color.lightestBlue,
              strokeWidth: 2,
              radius: const Radius.circular(12),
              borderType: BorderType.RRect,
              stackFit: StackFit.loose,
              dashPattern:const [7, 7],
              child: GestureDetector(
                onTap: (){
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
                                onTap: ()async{
                                  var camstatus = await Permission.camera.status;
                                  var micstatus = await Permission.microphone.status;
                                  if (camstatus.isGranted && micstatus.isGranted) {
                                    // detailcntrl.tappedOption(context, ImageSource.camera, "0");
                                    detailcntrl.callVideoRecordFunction(context, ImageSource.camera, "0");
                                  }
                                  else if (camstatus.isDenied || micstatus.isDenied){
                                    var newStatus = await Permission.camera.request();
                                    var newmStatus = await Permission.microphone.request();
                                    if (newStatus.isGranted && newmStatus.isGranted){
                                      // detailcntrl.tappedOption(context, ImageSource.camera, "0");
                                      detailcntrl.callVideoRecordFunction(context, ImageSource.camera, "0");
                                    }
                                    else if (newStatus.isPermanentlyDenied || newmStatus.isPermanentlyDenied){openAppSettings();}
                                  }
                                  else if (camstatus.isPermanentlyDenied || micstatus.isPermanentlyDenied){openAppSettings();}
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
                              AspectRatio(
                                  aspectRatio: val.controller.value.aspectRatio,
                                  child: VideoPlayer(val.controller)),
                              GestureDetector(
                                  onTap: (){
                                    val.controller.play();
                                  },
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
            valuee.trimmerstrt?const SizedBox(): Container(
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
                      GestureDetector(
                        onTap: () {
                          // buildShowModalBottomSheet(context);
                        },
                        child: CircleAvatar(
                          radius: 9,
                          backgroundColor: color.txtWhite,
                          child: SvgPicture.asset(AssetsPics.iIcon,fit: BoxFit.cover,),
                        ),
                      ),
                    ],),
                  const SizedBox(height: 5),
                  buildText("Some examples include : ", 15, FontWeight.w400, color.txtgrey2,fontFamily: FontFamily.hellix),
                  const SizedBox(height: 5),
                  Row(children: [
                    const SizedBox(width: 8),
                    const CircleAvatar(
                      radius: 2,
                      backgroundColor: color.txtgrey2,
                    ),
                    buildText("  Showcase a talent", 15, FontWeight.w400, color.txtgrey2,fontFamily: FontFamily.hellix),
                  ],),
                  const SizedBox(height: 4),
                  Row(children: [
                    const SizedBox(width: 8),
                    const CircleAvatar(
                      radius: 2,
                      backgroundColor: color.txtgrey2,
                    ),
                    buildText("  A day in your life", 15, FontWeight.w400, color.txtgrey2,fontFamily: FontFamily.hellix),
                  ],),
                  const SizedBox(height: 4),
                  Row(children: [
                    const SizedBox(width: 8),
                    const CircleAvatar(
                      radius: 2,
                      backgroundColor: color.txtgrey2,
                    ),
                    buildText("  A hobby you like to do", 15, FontWeight.w400, color.txtgrey2,fontFamily: FontFamily.hellix),
                  ],),
                  const SizedBox(height: 4),

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

              })
            ],),
        );
      },
    );
  }
}
