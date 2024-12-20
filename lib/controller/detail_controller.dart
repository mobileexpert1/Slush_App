import 'dart:async';
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
import 'package:provider/provider.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/loader.dart';
import 'package:slush/constants/prefs.dart';
import 'package:http/http.dart' as http;
import 'package:slush/controller/camera_screen.dart';
import 'package:slush/controller/login_controller.dart';
import 'package:slush/screens/login/login.dart';
import 'package:slush/screens/sign_up/details_completed.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:slush/widgets/toaster.dart';
import 'package:video_player/video_player.dart';
import 'package:video_trimmer/video_trimmer.dart';

class detailedController extends ChangeNotifier {
  int currentIndex = 0;
  String selcetedIndex = "";
  String? imageBase64;
  File? _image;
  CroppedFile? croppedFile;

  late VideoPlayerController _controller;

  VideoPlayerController get controller => _controller;
  final picker = ImagePicker();
  File? galleryFile;

  bool _trimmerstrt = false;

  bool get trimmerstrt => _trimmerstrt;
  Trimmer trimmer = Trimmer();
  double _startValue = 0.0;
  double _endValue = 15.0;
  bool isPlaying = false;
  bool _progressVisibility = false;
  String _gender = "";

  String get gender => _gender;

  late CameraController camcontroller;

  void setCurrentIndex() {
    if (LocaleHandler.nextAction == "fill_firstname") {
      LocaleHandler.nextAction = "fill_firstname";
      currentIndex = 0;
    } else if (LocaleHandler.nextAction == "fill_dateofbirth") {
      LocaleHandler.nextAction = "fill_dateofbirth";
      currentIndex = 1;
    } else if (LocaleHandler.nextAction == "fill_height") {
      LocaleHandler.nextAction = "fill_height";
      currentIndex = 2;
    } else if (LocaleHandler.nextAction == "choose_gender") {
      LocaleHandler.nextAction = "choose_gender";
      currentIndex = 3;
    } else if (LocaleHandler.nextAction == "fill_lookingfor") {
      LocaleHandler.nextAction = "fill_lookingfor";
      currentIndex = 4;
      setIndex(currentIndex);
    } else if (LocaleHandler.nextAction == "fill_sexual_orientation") {
      LocaleHandler.nextAction = "fill_sexual_orientation";
      currentIndex = 5;
      setIndex(currentIndex);
    } else if (LocaleHandler.nextAction == "fill_ethnicity") {
      LocaleHandler.nextAction = "fill_ethnicity";
      currentIndex = 6;
    } else if (LocaleHandler.nextAction == "upload_avatar") {
      LocaleHandler.nextAction = "upload_avatar";
      currentIndex = 8;
    } else if (LocaleHandler.nextAction == "upload_video") {
      LocaleHandler.nextAction = "upload_video";
      currentIndex = 9;
    }
    notifyListeners();
  }

  void setIndex(val) {
    currentIndex = val;
    if (currentIndex > 3) {
      _gender = LocaleHandler.gender;
    }
    notifyListeners();
  }

  Future registerUserDetail(BuildContext context, String action) async {
    LoaderOverlay.show(context);
    print(action);
    Preferences.setNextAction(action);
    Preferences.setValue("token", LocaleHandler.accessToken);
    const url = ApiList.registerUserDetails;
    print(url);
    var uri = Uri.parse(url);
    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = "Bearer ${LocaleHandler.accessToken}";
    // Add image file
    if (croppedFile != null) {
      File imageFile = File(croppedFile!.path);
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile('avatar', stream, length, filename: croppedFile.toString().split("/").last, contentType: MediaType('image', 'jpeg'));
      request.files.add(multipartFile);
    }
    // if (LocaleHandler.introVideo != null && action=="upload_video") {
    if (galleryFile != null) {
      File introVideo = File(galleryFile!.path);
      var stream = http.ByteStream(introVideo.openRead());
      var length = await introVideo.length();
      var multipartFile2 = http.MultipartFile('video', stream, length,
          filename: galleryFile.toString().split("/").last,
          contentType: MediaType('video', 'mp4'));
      request.files.add(multipartFile2);
    }

    // Add other parameters
    request.fields['action'] = action;
    if (LocaleHandler.name != "" && action == "fill_firstname") {
      request.fields['firstName'] = LocaleHandler.name.toString();
    }

    if (LocaleHandler.dateTimee != "" && action == "fill_dateofbirth") {
      request.fields['dateOfBirth'] = LocaleHandler.dateTimee;
    }

    if (LocaleHandler.height != "" && action == "fill_height") {
      request.fields['height'] = LocaleHandler.height;
      request.fields['height_unit'] = LocaleHandler.heighttype;
      request.fields['displayOnProfile'] = LocaleHandler.showheights;
    }

    if (LocaleHandler.gender != "" && action == "choose_gender") {
      request.fields['gender'] = LocaleHandler.gender;
      request.fields['displayOnProfile'] = LocaleHandler.showgender.toString();
    }

    if (LocaleHandler.lookingfor != "" && action == "fill_lookingfor") {
      request.fields['lookingFor'] = LocaleHandler.lookingfor;
      request.fields['displayOnProfile'] =
          LocaleHandler.showlookingfor.toString();
    }

    if (LocaleHandler.sexualOreintation != "" &&
        action == "fill_sexual_orientation") {
      request.fields['sexuality'] = LocaleHandler.sexualOreintation;
      request.fields['displayOnProfile'] =
          LocaleHandler.showsexualOreintations.toString();
    }

    if (LocaleHandler.entencity.length != 0 && LocaleHandler.entencity.isNotEmpty && action == "fill_ethnicity") {
      List.generate(LocaleHandler.entencity.length, (i) => request.fields['ethnicity[$i]'] = LocaleHandler.entencity[i].toString());
    }

    // Send the request
    var response = await request.send();
    LoaderOverlay.hide();
    final respStr = await response.stream.bytesToString();
    print(respStr);
    if (response.statusCode == 201) {
      // if(action=="upload_video"){registerUserDetail(context, "none");} else
      if (action == "upload_video") {
        Get.offAll(() => const SignUpDetailsCompletedScreen());
        deleteAllData();
        Preferences.setNextAction("none");
        Preferences.setReelAlreadySeen("false");
        Provider.of<loginControllerr>(context,listen: false).initPlatformState();
      }
    } else {
      Get.offAll(() => const LoginScreen());
      Fluttertoast.showToast(msg: "Server Error! Please sign in again");
    }
    notifyListeners();
  }

  void deleteAllData() {
    LocaleHandler.name = "";
    LocaleHandler.dateTimee = "";
    LocaleHandler.height = "";
    LocaleHandler.heighttype = "cm";
    LocaleHandler.showheights = "false";
    LocaleHandler.gender = "";
    LocaleHandler.showgender = false;
    LocaleHandler.lookingfor = "";
    LocaleHandler.showlookingfor = false;
    LocaleHandler.sexualOreintation = "";
    LocaleHandler.showsexualOreintations = "false";
    LocaleHandler.entencity.clear();
    LocaleHandler.introImage = null;
    LocaleHandler.introVideo = null;
    LocaleHandler.subscriptionPurchase="no";
    croppedFile = null;
    galleryFile = null;
    _controller.dispose();
    notifyListeners();
  }

  Future imgFromGallery(BuildContext context, ImageSource src) async {
    var image = await ImagePicker().pickImage(
        source: src,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.front);
    if (image != null) {
      _image = File(image.path);
      LocaleHandler.introImage = _image;
      var ImageBytes = File(image.path).readAsBytesSync();
      String imageB64 = base64Encode(ImageBytes);
      imageBase64 = imageB64;
      _cropImage(context);
      // Get.back();
      selcetedIndex = "";
    }
    notifyListeners();
  }

  void pickImageFromCamera(CameraLensDirection lens) async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere((camera) => camera.lensDirection == lens);
    camcontroller = CameraController(front, ResolutionPreset.medium);
    await camcontroller.initialize();
    // customDialogBoxVideo(context,"I’m ready");
    // if (!mounted) {return;}setState(() {});
    notifyListeners();
  }

  void onTakePictureButtonPressed(BuildContext context) async {
    XFile? rawImage = await takePicture();
    takePicture().then((XFile? file) {});
    if (rawImage != null) {
      Get.back();
      _image = File(rawImage.path);
      LocaleHandler.introImage = _image;
      var ImageBytes = File(rawImage.path).readAsBytesSync();
      String imageB64 = base64Encode(ImageBytes);
      imageBase64 = imageB64;
      _cropImage(context);
      // Get.back();
      selcetedIndex = "";
    }
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
          // WebUiSettings(
          //   context: context,
          //   presentStyle: CropperPresentStyle.dialog,
          //   boundary: const CroppieBoundary(width: 520, height: 520),
          //   viewPort: const CroppieViewPort(width: 480, height: 480, type: 'circle'),
          //   enableExif: true,
          //   enableZoom: true,
          //   showZoomer: true,
          // ),
        ],
      );
      if (croppedFilee != null) {
        croppedFile = croppedFilee;
        LocaleHandler.avatar = croppedFile!.path;
        // LocaleHandler.introImage=_croppedFile;
      }
    }
    notifyListeners();
  }

  void tappedOPtion(BuildContext context, ImageSource src, String index) {
    selcetedIndex = index;
    if (src == ImageSource.camera && Platform.isAndroid) {pickImageFromCamera(CameraLensDirection.front);}
    notifyListeners();
    Future.delayed(const Duration(seconds: 1), () {
      Get.back();
      if (Platform.isIOS) {imgFromGallery(context, src);}
      else if (src == ImageSource.gallery && Platform.isAndroid) {imgFromGallery(context, src);}
      else if (src == ImageSource.camera && Platform.isAndroid) {Get.to(() => const CameraScreen());}
      selcetedIndex = "";
      notifyListeners();
    });
  }

  // Working
  Future getVideo(BuildContext context, ImageSource img) async {
    // controller.removeListener(null);
    if (galleryFile != null) {
      _controller.pause();
      notifyListeners();
    }
    const allowedTimeLimit = Duration(seconds: 16);
    // final allowedTimeLimit = Duration(seconds: 4);
    const allowedTimeLimit2 = Duration(minutes: 15);
    final pickedFile = await picker.pickVideo(source: img, preferredCameraDevice: CameraDevice.front, maxDuration: const Duration(seconds: 15));
    XFile? xfilePick = pickedFile;
    if (xfilePick != null) {
      showToastMsg("Please wait...");
      if (Platform.isAndroid) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(pickedFile!.path));
      } else {
        _controller = VideoPlayerController.file(File(pickedFile!.path));
      }
      _controller
        ..initialize().then((_) {
          if (_controller.value.duration <= allowedTimeLimit) {palyVideo(File(pickedFile.path));}
          else if (_controller.value.duration <= allowedTimeLimit2) {
            // galleryFile=null;
            _trimmerstrt = true;
            trimmer = Trimmer();
            _loadVideo(File(pickedFile.path));
          } else {
            // galleryFile=null;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: buildText("Video should be less then 15 seconds", 16, FontWeight.w500, color.txtWhite)));
          }
        });
    } else {}
    notifyListeners();
  }

  void saveVlue(int i, val) {
    if (i == 0) {
      _startValue = val;
    } else {
      _endValue = val;
    }
    notifyListeners();
  }

  palyVideo(File file) {
    galleryFile = file;
    LocaleHandler.introVideo = galleryFile;
    if (_controller.value.isInitialized) {
      if (Platform.isAndroid) {_controller.play();}
      // _controller.setPlaybackSpeed(0.8);
    }
    notifyListeners();
  }

  void _loadVideo(File file) {
    _startValue=0.0;
    _endValue = 15.0;
    trimmer.loadVideo(videoFile: file);
    notifyListeners();
  }

  saveVideo() {
    _progressVisibility = true;
    trimmer.saveTrimmedVideo(
      startValue: _startValue,
      endValue: _endValue,
      // ffmpegCommand: '-i ${trimmer.videoPlayerController!.dataSource} -ss ${_startValue.toString()} -t ${_endValue.compareTo(_startValue).seconds} -c:v copy -c:a aac ${trimmer.currentVideoFile}/trimmed_video.mp4',
      // ffmpegCommand: '-i input.mp4 -ss 0 -t 4 -c:v copy output.mp4',
      // ffmpegCommand: '-i ${_trimmer.videoPlayerController!.dataSource} -ss ${_startValue.toString()} -t ${_endValue.difference(_startValue).inSeconds} -c copy ${_trimmer.outputPath}/trimmed_video.mp4',
      // ffmpegCommand: '-c:a aac -c:v copy',
      // customVideoFormat: '.mp4',
      onSave: (outputPath) {
        galleryFile = File(outputPath!);
        _progressVisibility = false;
        debugPrint('OUTPUT PATH: $outputPath');
        trimmer.currentVideoFile;
        _trimmerstrt = false;
        palyVideo(File(outputPath!));
        getValueInController(outputPath!);
        // trimmer=false;
        notifyListeners();
      },
    ).then((value){});
    notifyListeners();
  }

  void callVideoRecordFunction(BuildContext context, ImageSource img,String index){
    if(Platform.isAndroid){_initializeCamera(context);}
    else{ tappedOption(context,ImageSource.camera,index);}
  }

  late CameraController _camcontrollerr;
  CameraController get cam=>_camcontrollerr;
  int _secondsLeft = 0;
  int get secondsLeft=>_secondsLeft;
  XFile? file;
  late Timer _timer;
  bool _running=false;
  bool get running=>_running;
  int _videoFinished=0; //0-not started yet , 1-pause, 2-finished
  int get videoFinished=>_videoFinished;
  VideoPlayerController? controllerr;
  Future<void>? _initializeVideoPlayerFuture;

  void _initializeCamera(BuildContext context) async {
    _secondsLeft=0;
    _videoFinished=0;
    _running=false;
    final cameras = await availableCameras();
    final front = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back);
    _camcontrollerr = CameraController(front, ResolutionPreset.veryHigh);
    Get.back();
    await _camcontrollerr.initialize().then((onValue)=> Get.to(()=>const AddVideoScreen()));;
    // customDialogBoxVideo(context,"I’m ready",getControl);
    if (!context.mounted) {return;}
    notifyListeners();
  }

  void pickVideoFromCamera(CameraLensDirection lens) async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere((camera) => camera.lensDirection == lens);
    _camcontrollerr = CameraController(front, ResolutionPreset.medium);
    await _camcontrollerr.initialize();
    // customDialogBoxVideo(context,"I’m ready");
    // if (!mounted) {return;}setState(() {});
    notifyListeners();
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void cancelrecording()async{
    Get.back();
    _running=false;
    _videoFinished=0;
    _secondsLeft=0;
    await _camcontrollerr.pauseVideoRecording();
    _camcontrollerr.dispose();
    controllerr!.dispose();
    notifyListeners();
  }

  void startvideorecording(BuildContext context)async{
    await _camcontrollerr.prepareForVideoRecording();
    await _camcontrollerr.startVideoRecording();
    startTimer();
    notifyListeners();
  }

  void storeRecord(BuildContext context){
    showToastMsg("Please wait...");
    // _controller = VideoPlayerController.file(File(file!.path))..initialize().then((_) {palyVideo(File(galleryFile!.path));});
    _controller= VideoPlayerController.networkUrl(Uri.parse(file!.path))..initialize().then((_) {palyVideo(File(file!.path));});
    Get.back();
    // UploadVideo( context,galleryFile!);
  }

  void startTimer() {
    _secondsLeft=0;
    _running=false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_secondsLeft <15) {_secondsLeft++;notifyListeners();}
      else {pauseresumetimer(true);}
    });
    notifyListeners();
  }

  void finishedRecording()async{
    _videoFinished=2;
    file = await _camcontrollerr.stopVideoRecording();
    controllerr = VideoPlayerController.file(File(file!.path));
    _initializeVideoPlayerFuture = controllerr!.initialize().then((value)async {
      controllerr!.setVolume(0.0);
      controllerr!.play();
    });
    notifyListeners();
  }

  void pauseresumetimer(bool val) async {
    _running=val;
    if(_running){_timer.cancel();
    if(_secondsLeft==15){_videoFinished=2;
    finishedRecording();
    }else{_videoFinished=1;
    await _camcontrollerr.pauseVideoRecording();
    }}
    else{ _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <15) {_secondsLeft++;notifyListeners();}
      else {pauseresumetimer(true);}
    });}
    notifyListeners();
  }

  void tappedOption(BuildContext context, ImageSource src, String index) {
    // controller.removeListener(() { });
    selcetedIndex = index;
    notifyListeners();
    Future.delayed(const Duration(seconds: 1), () {
      Get.back();
      getVideo(context, src);
      selcetedIndex = "";
      notifyListeners();
    });
  }

  Future getValueInController(String outputVideoPath) async {
    _trimmerstrt = false;
    _controller = VideoPlayerController.file(File(outputVideoPath))
      ..initialize().then((_) {
        palyVideo(File(outputVideoPath));
        // palyVideo(File(_controller.dataSource));
        notifyListeners();
      });
    notifyListeners();
  }

  void playTrimmmervideo() async {
    await trimmer.videoPlaybackControl(startValue: _startValue, endValue: _endValue);
    notifyListeners();
  }

  void trimmVideoPLayPause(bool val) {
    isPlaying = val;
    notifyListeners();
  }

  void cancelSelectedTrimVideo() async {
    _trimmerstrt = false;
    // galleryFile=null;
    // controller.dispose();
    LocaleHandler.introVideo = null;
    trimmer.dispose();
    _startValue = 0.0;
    _endValue = 15.0;
    if (galleryFile != null) {
      if (Platform.isAndroid) {
        _controller =
            VideoPlayerController.networkUrl(Uri.parse(galleryFile!.path));
      } else {
        _controller = VideoPlayerController.file(File(galleryFile!.path));
      }
      _controller
        ..initialize().then((_) {
          palyVideo(File(galleryFile!.path));
        });
    }
    notifyListeners();
  }

  void pauseVideo() {
    _controller.pause();
    notifyListeners();
  }

  //--not used
}
