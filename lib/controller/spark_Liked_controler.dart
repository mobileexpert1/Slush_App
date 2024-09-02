import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/controller/camera_screen.dart';

class SparkLikedController extends ChangeNotifier{
  List _liked=[];
  List get liked=> _liked;

  List _sparkLike=[];
  List get sparkLike=>_sparkLike;


  void addSparkLike(int id){
    _sparkLike.add(id);
    notifyListeners();
  }

  void addLikeD(int id){
    _liked.add(id);
    notifyListeners();
  }

  void cleanSparkLike(){
    _sparkLike.clear();
    _liked.clear();
    notifyListeners();
  }

}


class CamController extends ChangeNotifier{

  late CameraController camcontroller;
  String? imageBase64;
  // String?get base64 => imageBase64;
  File? _image;
  File?get image=>_image;

  void onTakePictureButtonPressed(BuildContext context)async {
    XFile? rawImage = await takePicture();
    takePicture().then((XFile? file) {});
    if (rawImage != null) {
      Get.back();
      // _image = File(rawImage.path);
      saveImge(File(rawImage.path));
      // LocaleHandler.introImage= _image;
      var ImageBytes = File(rawImage.path).readAsBytesSync();
      String imageB64 = base64Encode(ImageBytes);
      imageBase64 = imageB64;
      // Get.back();
     }
    notifyListeners();
  }

  void saveImge(File file){
    _image = file;
    notifyListeners();
  }

  void clearimg(){
    _image = null;
    notifyListeners();
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = camcontroller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      print('Error: select a camera first.');
      return null;
    }
    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }
    try {
      final XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      return null;
    }
    notifyListeners();
  }

  void pickImageFromCamera(CameraLensDirection lens) async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere((camera) => camera.lensDirection == lens);
    camcontroller = CameraController(front, ResolutionPreset.medium);
    await camcontroller.initialize().then((value) => Get.to(()=>const CameraChatScreen()));

    // customDialogBoxVideo(context,"I’m ready");
    // if (!mounted) {return;}setState(() {});
    notifyListeners();
  }
}