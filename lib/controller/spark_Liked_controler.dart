import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/controller/camera_screen.dart';
import 'package:http/http.dart'as http;
import 'package:slush/widgets/toaster.dart';

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
  File? _image;
  File?get image=>_image;
  var apidata;
  List<dynamic> dataList=[];
  bool _load=false;
  bool get load=>_load;

  void onTakePictureButtonPressed(BuildContext context)async {
    showToastMsg("please wait...");
    XFile? rawImage = await takePicture();
    takePicture().then((XFile? file) {});
    if (rawImage != null) {
      Get.back();
      // _image = File(rawImage.path);
      saveImge(File(rawImage.path));
      // LocaleHandler.introImage= _image;
     }
    notifyListeners();
  }

  void saveImge(File file){
    clearimg();
    _image = file;
    _load=true;
    sendImagee(file);
    // _image = file;
    notifyListeners();
  }

  void clearimg(){
    _image = null;
    dataList.clear();
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

  Future sendImagee(File fileimage)async{
    const url = ApiList.fileuploadinchat;
    var uri=Uri.parse(url);
    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = "Bearer ${LocaleHandler.accessToken}";
    // Add image file
    if (fileimage != null) {
      File imageFile = File(fileimage.path);
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile('files', stream, length, filename: fileimage.toString().split("/").last,contentType: MediaType('image','png'));
      request.files.add(multipartFile);
    }
    var response = await request.send();
    final respStr = await response.stream.bytesToString();
    apidata=jsonDecode(respStr);;
    dataList = apidata['data'];
    if(response.statusCode==201){
      _image = fileimage;
      _load=false;
      print("response.statusCode====${response.statusCode}");}
    print("response.statusCode=======${response.statusCode}");
    notifyListeners();
  }
}
