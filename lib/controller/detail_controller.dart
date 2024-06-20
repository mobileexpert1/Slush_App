import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/loader.dart';
import 'package:slush/constants/prefs.dart';
import 'package:http/http.dart'as http;
import 'package:slush/controller/camera_screen.dart';
import 'package:slush/screens/login/login.dart';
import 'package:slush/screens/sign_up/details/video_trimmer.dart';
// import 'package:slush/screens/sign_up/details/trim_video.dart';
import 'package:slush/screens/sign_up/details_completed.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:slush/widgets/toaster.dart';
// import 'package:video_compress/video_compress.dart';
// import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:video_trimmer/video_trimmer.dart';
// import 'package:video_trimmer/video_trimmer.dart';

class detailedController extends ChangeNotifier{
  int currentIndex=0;
  String selcetedIndex="";
  String? imageBase64;
  File? _image;
  CroppedFile? croppedFile;

  late VideoPlayerController controller;
  File? videoFile;
  final picker = ImagePicker();
  File? galleryFile;

  bool trimmerstrt=false;
  final Trimmer trimmer = Trimmer();
  double _startValue = 0.0;
  double _endValue = 0.0;
  bool isPlaying = false;
  bool _progressVisibility = false;

  void setCurrentIndex(){
    if(LocaleHandler.nextAction=="fill_firstname"){currentIndex=0;}
    if(LocaleHandler.nextAction=="fill_dateofbirth"){currentIndex=1;}
    if(LocaleHandler.nextAction=="fill_height"){currentIndex=2;}
    if(LocaleHandler.nextAction=="choose_gender"){currentIndex=3;}
    if(LocaleHandler.nextAction=="fill_lookingfor"){currentIndex=4;}
    if(LocaleHandler.nextAction=="fill_sexual_orientation"){currentIndex=5;}
    if(LocaleHandler.nextAction=="fill_ethnicity"){currentIndex=6;}
    if(LocaleHandler.nextAction=="upload_avatar"){currentIndex=8;}
    if(LocaleHandler.nextAction=="upload_video"){currentIndex=9;}
    notifyListeners();
  }

  void setIndex(val){
    currentIndex=val;
    notifyListeners();
  }

  Future registerUserDetail(BuildContext context,String action)async{
    LoaderOverlay.show(context);
    print(action);
    Preferences.setNextAction(action);
    Preferences.setValue("token", LocaleHandler.accessToken);
    final url= ApiList.registerUserDetails;
    print(url);
    var uri=Uri.parse(url);
    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = "Bearer ${LocaleHandler.accessToken}";
    // Add image file
    if (LocaleHandler.introImage != null) {
      File imageFile = File(LocaleHandler.introImage!.path);
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile('avatar', stream, length, filename: LocaleHandler.introImage.toString().split("/").last);
      request.files.add(multipartFile);
    }
    // if (LocaleHandler.introVideo != null && action=="upload_video") {
    if (LocaleHandler.introVideo != null ) {
      File introVideo = File(LocaleHandler.introVideo!.path);
      var stream = http.ByteStream(introVideo.openRead());
      var length = await introVideo.length();
      var multipartFile2 = http.MultipartFile('video', stream, length, filename: LocaleHandler.introVideo.toString().split("/").last,contentType: MediaType('video','mp4'));
      request.files.add(multipartFile2);
    }

    // Add other parameters
    request.fields['action'] = action;
    if(LocaleHandler.name!=""&& action=="fill_firstname"){request.fields['firstName'] = LocaleHandler.name.toString();}

    if(LocaleHandler.dateTimee!=""&& action=="fill_dateofbirth"){request.fields['dateOfBirth'] = LocaleHandler.dateTimee;}

    if(LocaleHandler.height!="" && action=="fill_height"){
      request.fields['height'] = LocaleHandler.height;
      request.fields['height_unit'] = LocaleHandler.heighttype;
      request.fields['displayOnProfile'] = LocaleHandler.showheights;
    }

    if(LocaleHandler.gender!="" && action=="choose_gender"){
      request.fields['gender'] = LocaleHandler.gender;
      request.fields['displayOnProfile'] = LocaleHandler.showgender.toString();
    }

    if(LocaleHandler.lookingfor!=""  && action=="fill_lookingfor"){
      request.fields['lookingFor'] = LocaleHandler.lookingfor;
      request.fields['displayOnProfile'] = LocaleHandler.showlookingfor.toString();
    }

    if(LocaleHandler.sexualOreintation!="" && action=="fill_sexual_orientation"){
      request.fields['sexuality'] = LocaleHandler.sexualOreintation;
      request.fields['displayOnProfile'] = LocaleHandler.showsexualOreintations.toString();
    }

    if(LocaleHandler.entencity.length!=0&&LocaleHandler.entencity.isNotEmpty  && action=="fill_ethnicity") {
      List.generate(LocaleHandler.entencity.length, (i) => request.fields['ethnicity[$i]'] = LocaleHandler.entencity[i].toString());
    }

    // Send the request
    var response = await request.send();
    LoaderOverlay.hide();
    final respStr = await response.stream.bytesToString();
    print(respStr);
    if (response.statusCode == 201) {
      // if(action=="upload_video"){registerUserDetail(context, "none");} else
        if(action=="upload_video"){
        Get.to(()=>const SignUpDetailsCompletedScreen());
        deleteAllData();
      }
    } else{
      Get.offAll(()=>LoginScreen());
      Fluttertoast.showToast(msg:"Server Error! Please sign in again");}
    notifyListeners();
  }

  void deleteAllData(){
    LocaleHandler.name="";
    LocaleHandler.dateTimee="";
    LocaleHandler.height="";
    LocaleHandler.heighttype="cm";
    LocaleHandler.showheights="false";
    LocaleHandler.gender="";
    LocaleHandler.showgender=false;
    LocaleHandler.lookingfor="";
    LocaleHandler.showlookingfor=false;
    LocaleHandler.sexualOreintation="";
    LocaleHandler.showsexualOreintations="false";
    LocaleHandler.entencity.clear();
    LocaleHandler.introImage=null;
    LocaleHandler.introVideo=null;
    croppedFile=null;
    galleryFile=null;
    controller.dispose();
    notifyListeners();
  }

  Future imgFromGallery(BuildContext context,ImageSource src) async {
    var image = await ImagePicker().pickImage(source: src,imageQuality: 80,preferredCameraDevice:  CameraDevice.front);
      if (image != null) {
        _image = File(image.path);
        LocaleHandler.introImage= _image;
        var ImageBytes = File(image.path).readAsBytesSync();
        String imageB64 = base64Encode(ImageBytes);
        imageBase64 = imageB64;
        _cropImage(context);
        // Get.back();
        selcetedIndex="";}
    notifyListeners();
  }

  late CameraController camcontroller;
  void pickImageFromCamera(CameraLensDirection lens) async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere((camera) => camera.lensDirection == lens);
    camcontroller = CameraController(front, ResolutionPreset.medium);
    await camcontroller.initialize();
    // customDialogBoxVideo(context,"I’m ready");
    // if (!mounted) {return;}setState(() {});
    notifyListeners();
  }


  void onTakePictureButtonPressed(BuildContext context)async {
    XFile? rawImage = await takePicture();
    takePicture().then((XFile? file) {});
    if (rawImage != null) {
      Get.back();
      _image = File(rawImage.path);
      LocaleHandler.introImage= _image;
      var ImageBytes = File(rawImage.path).readAsBytesSync();
      String imageB64 = base64Encode(ImageBytes);
      imageBase64 = imageB64;
      _cropImage(context);
      // Get.back();
      selcetedIndex="";}
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



  Future<void> _cropImage(BuildContext context) async {
    if (_image != null) {
      final croppedFilee = await ImageCropper().cropImage(
        sourcePath: _image!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: color.txtBlue,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(title: 'Cropper'),
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
      if (croppedFilee != null) {
        croppedFile = croppedFilee;
        // LocaleHandler.introImage=_croppedFile;
      }
    }
    notifyListeners();
  }

  void tappedOPtion(BuildContext context,ImageSource src,String index){
    selcetedIndex=index;
    if(src==ImageSource.camera && Platform.isAndroid){pickImageFromCamera(CameraLensDirection.front);}
    notifyListeners();
    Future.delayed(const Duration(seconds: 1),(){
      Get.back();
      if(Platform.isIOS){imgFromGallery(context,src);}
      else if(src==ImageSource.gallery && Platform.isAndroid){imgFromGallery(context,src);}
      else if(src==ImageSource.camera && Platform.isAndroid){Get.to(()=>CameraScreen());}
      selcetedIndex="";
      notifyListeners();
    });
  }

  // Working
  Future getVideo(BuildContext context,ImageSource img) async {
    // controller.removeListener(null);
    if(galleryFile!=null){controller.pause();    notifyListeners();}
    final allowedTimeLimit = Duration(seconds: 16);
    // final allowedTimeLimit = Duration(seconds: 4);
    final allowedTimeLimit2 = Duration(minutes: 15);
    final pickedFile = await picker.pickVideo(source: img, preferredCameraDevice: CameraDevice.front, maxDuration: const Duration(seconds: 15));
    XFile? xfilePick = pickedFile;
    if (xfilePick != null) {
      // LoaderOverlay.show(context);
      showToastMsg("Please wait...");
      // final compressedFile = await VideoCompress.compressVideo(
      //   pickedFile!.path,
      //   quality: VideoQuality.LowQuality,
      //   deleteOrigin: false,
      //   includeAudio: true,
      //   // duration: 15
      // );
      // LoaderOverlay.hide();
      if(Platform.isAndroid){controller = VideoPlayerController.networkUrl(Uri.parse(pickedFile!.path));}
      else{controller = VideoPlayerController.file(File(pickedFile!.path));}
      controller..initialize().then((_) {
        if(controller.value.duration<=allowedTimeLimit){
          palyVideo(File(pickedFile.path));
        }else if(controller.value.duration<=allowedTimeLimit2){
          galleryFile=null;
          trimmerstrt=true;
          _loadVideo(File(pickedFile.path));
          // _loadVideo(compressedFile.file);
          // Future.delayed(Duration(seconds: 3),(){ saveVideo();
          // notifyListeners();});
        }
        else{
          galleryFile=null;
          ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: buildText("Video should be less then 15 seconds", 16, FontWeight.w500, color.txtWhite)));
        }});
    } else {}
    notifyListeners();
  }

  void saveVlue(int i,val){
    if(i==0){
      _startValue=val;
    }else{
      _endValue=val;
    }
    notifyListeners();
  }

  palyVideo(File file){
    galleryFile = file;
    LocaleHandler.introVideo=galleryFile;
    controller.play();
    controller.setPlaybackSpeed(0.8);
    notifyListeners();
  }

  void _loadVideo(File file) {
    trimmer.loadVideo(videoFile: file);
    notifyListeners();
  }

  saveVideo() {
    _progressVisibility = true;
    trimmer.saveTrimmedVideo(
      startValue: _startValue,
      endValue: _endValue,
      // ffmpegCommand: '-i input.mp4 -ss 0 -t 4 -c:v copy output.mp4',
      // ffmpegCommand: '-i ${_trimmer.videoPlayerController!.dataSource} -ss ${_startValue.toString()} -t ${_endValue.difference(_startValue).inSeconds} -c copy ${_trimmer.outputPath}/trimmed_video.mp4',
      // ffmpegCommand: '-c:a aac -c:v copy',
      // customVideoFormat: '.mp4',
      onSave: (outputPath) {
        galleryFile=null;
        _progressVisibility = false;
        debugPrint('OUTPUT PATH: $outputPath');
        trimmer.currentVideoFile;
        palyVideo(File(trimmer.currentVideoFile!.path));
        getValueInController(outputPath!);
        // trimmer=false;
        notifyListeners();
      },
    );
    notifyListeners();
  }

  void tappedOption(BuildContext context,ImageSource src,String index){
    // controller.removeListener(() { });
    selcetedIndex=index;
    notifyListeners();
    Future.delayed(Duration(seconds: 1),(){
      getVideo(context, src);
      Get.back();
      selcetedIndex="";
      notifyListeners();
    });
  }

  Future getValueInController(String outputVideoPath)async{
    trimmerstrt=false;
    controller = VideoPlayerController.file(File(outputVideoPath))..initialize().then((_) {
        palyVideo(File(trimmer.currentVideoFile!.path));
        notifyListeners();
      });
    notifyListeners();
  }

  void playTrimmmervideo()async{
    await trimmer.videoPlaybackControl(startValue: _startValue, endValue: _endValue);
    notifyListeners();
  }

  void trimmVideoPLayPause(bool val){
    isPlaying=val;
    notifyListeners();
  }

  void cancelSelectedTrimVideo()async{
    trimmerstrt=false;
    galleryFile=null;
    controller.dispose();
    LocaleHandler.introVideo=null;
    trimmer.dispose();
    _startValue = 0.0;
    _endValue = 0.0;
    notifyListeners();
  }

}