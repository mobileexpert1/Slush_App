import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/controller/detail_controller.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:image_cropper/image_cropper.dart';

class DetailProfilePicture extends StatefulWidget {
  const DetailProfilePicture({Key? key}) : super(key: key);

  @override
  State<DetailProfilePicture> createState() => _DetailProfilePictureState();
}

class _DetailProfilePictureState extends State<DetailProfilePicture> {
  @override
  Widget build(BuildContext context) {
    final detailcntrl=Provider.of<detailedController>(context,listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         SizedBox(height: 3.h-3),
        buildText("Let's make your profile shine.", 28, FontWeight.w600, color.txtBlack),
        const SizedBox(height: 8),
        buildText("Please upload your photo.", 15, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
         SizedBox(height: 3.h-2),
        Center(
          child: DottedBorder(
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
                      child:  Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20,right: 20),
                            child: GestureDetector(
                              onTap: ()async{
                                var status = await Permission.camera.status;
                                if (status.isGranted) {detailcntrl.tappedOPtion(context, ImageSource.camera, "0");}
                                else if (status.isDenied){
                                  var newStatus = await Permission.camera.request();
                                  if (newStatus.isGranted){detailcntrl.tappedOPtion(context, ImageSource.camera, "0");}
                                  else if (newStatus.isPermanentlyDenied){  openAppSettings();}}
                                else if (status.isPermanentlyDenied){  openAppSettings();}
                              },
                              child: Consumer<detailedController>(builder: (ctx,val,child){
                                return Container(color: Colors.transparent,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      buildText("Take a Selfie", 18,val.selcetedIndex=="0"?FontWeight.w600:FontWeight.w500, color.txtBlack),
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
                              },),
                            ),
                          ),
                          const Divider(thickness: 0.2),
                          Consumer<detailedController>(builder: (ctx,val,child){return Padding(
                            padding: const EdgeInsets.only(left: 20,right: 20),
                            child: GestureDetector(
                              onTap: (){
                                detailcntrl.tappedOPtion(context, ImageSource.gallery, "1");
                              },
                              child: Container(color: Colors.transparent,
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
                                        child: val.selcetedIndex=="1"?SvgPicture.asset(AssetsPics.blueTickCheck, fit: BoxFit.cover):const SizedBox(),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );}),
                          // buildText("Choose from Gallery", 18, FontWeight.w500, color.txtBlack),
                        ],),
                    );
                  },
                );
              },
              child: Container(
                  height: MediaQuery.of(context).size.width*0.7,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),color: Colors.white,),
                width: MediaQuery.of(context).size.width*0.7,
                child: Consumer<detailedController>(builder: (context,val,child){
                  return  val.croppedFile != null?
                  ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      // child: Image.file(File(val.croppedFile!.path),fit: BoxFit.cover)
                      child: Image.file(File(val.croppedFile!.path),fit: BoxFit.cover)
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(AssetsPics.uploadPictureIcon),
                      const SizedBox(height: 5),
                      buildText("Upload Image", 16, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix)
                    ],);
                },)
              ),
            ),
          ),
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildText("This will be your profile photo", 15, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
          ],),
         SizedBox(height: 2.h-2)
      ],);
  }
}

class DropDownOption{
  int Id;
  String title;
  DropDownOption(this.Id,this.title);
}
