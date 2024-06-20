import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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
        DottedBorder(
          color: color.lightestBlue,
          strokeWidth: 2,
          radius: const Radius.circular(12),
          borderType: BorderType.RRect,
          stackFit: StackFit.loose,
          dashPattern:const [
            7,
            7,
          ],
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
                            onTap: (){
                              detailcntrl.tappedOPtion(context, ImageSource.camera, "0");
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
                                      child: val.selcetedIndex=="1"?SvgPicture.asset(AssetsPics.blueTickCheck,fit: BoxFit.cover,):const SizedBox(),
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
                height: 250,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),color: Colors.white,),
              width: MediaQuery.of(context).size.width-30,
              child: Consumer<detailedController>(builder: (context,val,child){
                return  val.croppedFile != null?
                ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(File(val.croppedFile!.path),fit: BoxFit.cover,))
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

/*import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:image_cropper/image_cropper.dart';

class DetailProfilePicture extends StatefulWidget {
  const DetailProfilePicture({Key? key}) : super(key: key);

  @override
  State<DetailProfilePicture> createState() => _DetailProfilePictureState();
}

class _DetailProfilePictureState extends State<DetailProfilePicture> {
  List<DropDownOption> item=[
    DropDownOption(1, "Take a Selfie"),
    DropDownOption(2, "Choose from Gallery"),
  ];
  String selcetedIndex="";
  String? imageBase64;
  File? _image;
  CroppedFile? _croppedFile;
  // image_picker from gallery
  Future imgFromGallery(ImageSource src) async {
    var image = await ImagePicker().pickImage(source: src);
    try{
      if (image != null) {
      setState(() {
         _image = File(image.path);
         LocaleHandler.introImage= _image;
        var ImageBytes = File(image.path).readAsBytesSync();
        String imageB64 = base64Encode(ImageBytes);
        imageBase64 = imageB64;
         _cropImage();
        // Get.back();
         selcetedIndex="";
      });}
    } catch(error) {print("error: $error");}}

  Future<void> _cropImage() async {
    if (_image != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _image!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Cropper',
          ),
          WebUiSettings(
            context: context,
            presentStyle: CropperPresentStyle.dialog,
            boundary: const CroppieBoundary(
              width: 520,
              height: 520,
            ),
            viewPort:
            const CroppieViewPort(width: 480, height: 480, type: 'circle'),
            enableExif: true,
            enableZoom: true,
            showZoomer: true,
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          _croppedFile = croppedFile;
          // LocaleHandler.introImage=_croppedFile;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         SizedBox(height: 3.h-3),
        buildText("Let's make your profile shine.", 28, FontWeight.w600, color.txtBlack),
        const SizedBox(height: 8),
        buildText("Please upload your photo.", 15, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
         SizedBox(height: 3.h-2),
        DottedBorder(
          color: color.lightestBlue,
          strokeWidth: 2,
          radius: const Radius.circular(12),
          borderType: BorderType.RRect,
          stackFit: StackFit.loose,
          dashPattern:const [
            7,
            7,
          ],
          child: Container(
              height: 250,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),color: Colors.white,),
            width: MediaQuery.of(context).size.width-30,
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
                      child:  StatefulBuilder(
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
                                    Future.delayed(const Duration(seconds: 1),(){
                                      Get.back();
                                      imgFromGallery(ImageSource.camera);
                                      selcetedIndex="";
                                    });
                                  });
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    buildText("Take a Selfie", 18,selcetedIndex=="0"?FontWeight.w600:FontWeight.w500, color.txtBlack),
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
                                      Future.delayed(const Duration(seconds: 1),(){
                                        Get.back();
                                        imgFromGallery(ImageSource.gallery);
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
              },
              child:_croppedFile != null?
                  ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(File(_croppedFile!.path),fit: BoxFit.cover,))
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                SvgPicture.asset(AssetsPics.uploadPictureIcon),
                const SizedBox(height: 5),
                buildText("Upload Image", 16, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix)
              ],),
            )
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
}*/