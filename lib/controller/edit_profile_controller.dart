/*
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart'as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/loader.dart';
import 'package:slush/widgets/toaster.dart';
import 'package:video_player/video_player.dart';

class editProfileController extends ChangeNotifier{
  String? imageBase64;
  String selcetedIndex="";
  File? _image;
  CroppedFile? croppedFile;
  String  PictureId="";
  VideoPlayerController? _controller;
  VideoPlayerController? _controller2;
  VideoPlayerController? _controller3;
  VideoPlayerController? _controller4;
  Future<void>? _initializeVideoPlayerFuture;
  Future<void>? _initializeVideoPlayerFuture2;
  Future<void>? _initializeVideoPlayerFuture3;

  // Profile API
  Future profileData(BuildContext context) async {
    LoaderOverlay.show(context);
    final url = ApiList.getUser + LocaleHandler.userId;
    print(url);
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${LocaleHandler.accessToken}'
      });
      LoaderOverlay.hide();
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
          LocaleHandler.dataa = data["data"];
          if (LocaleHandler.dataa["profileVideos"].length != 0) {
            _controller = VideoPlayerController.networkUrl(Uri.parse(LocaleHandler.dataa["profileVideos"][0]["key"]),);
            _initializeVideoPlayerFuture = _controller!.initialize();
          }
          if (LocaleHandler.dataa["profileVideos"].length >= 2) {
            _controller2 = VideoPlayerController.networkUrl(Uri.parse(LocaleHandler.dataa["profileVideos"][1]["key"]),);
            _initializeVideoPlayerFuture2 = _controller2!.initialize();
          }
          if (LocaleHandler.dataa["profileVideos"].length >= 3) {
            _controller3 = VideoPlayerController.networkUrl(Uri.parse(LocaleHandler.dataa["profileVideos"][2]["key"]),);
            _initializeVideoPlayerFuture3 = _controller3!.initialize();
          }
          notifyListeners();
          // saveDta();
      } else if (response.statusCode == 401) {
        showToastMsgTokenExpired();
        print('Token Expire:::::::::::::');
      } else {
        print('Faoled to Load Data With Status Code ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
    notifyListeners();
  }

  // Upload and Update image
  void tappedOPtion(BuildContext context,ImageSource src,String index,String picId){
    PictureId=picId;
    selcetedIndex=index;
    notifyListeners();
    Future.delayed(const Duration(seconds: 1),(){
      Get.back();
      imgFromGallery(context,src);
      selcetedIndex="";
      notifyListeners();
    });
  }

  Future imgFromGallery(BuildContext context, ImageSource src) async {
    if(src==ImageSource.camera){
      var status = await Permission.camera.status;
      if (status.isPermanentlyDenied) return openAppSettings();
      status = await Permission.camera.request();
      if (status.isDenied) return;
    }
    var image = await ImagePicker().pickImage(source: src,imageQuality: 50);
    try{
      if (image != null) {
        _image = File(image.path);
        var ImageBytes = File(image.path).readAsBytesSync();
        String imageB64 = base64Encode(ImageBytes);
        imageBase64 = imageB64;
        _cropImage(context);
        Get.back();
        selcetedIndex = "";
      }
    }catch(error) {
      print("error: $error");
    }
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
      if (croppedFilee != null) {
        croppedFile = croppedFilee;
        PictureId == "-1" ? uploadMultipleImage(croppedFile!) : updateAvatar(croppedFile!);
        // LocaleHandler.introImage=_croppedFile;
      }
    }
    notifyListeners();
  }

  Future uploadMultipleImage(CroppedFile image) async {
    const url = ApiList.multipleProfilePicture;
    print(url);
    var uri = Uri.parse(url);
    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = "Bearer ${LocaleHandler.accessToken}";
    // Add image file
    if (image != null) {
      File imageFile = File(image!.path);
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile('files', stream, length, filename: image.toString().split("/").last,contentType: MediaType('image', 'jpg'));
      request.files.add(multipartFile);
    }
    // request.fields['key'] = "files";
    // request.fields['type'] = "file";
    var response = await request.send();
    print(response.statusCode);
    if (response.statusCode == 201) {
      // profileData();
    } else if (response.statusCode == 401) {
      showToastMsgTokenExpired();
    } else {}
  }

  Future updateAvatar(CroppedFile image) async {
    final url = ApiList.updateAvatar + PictureId;
    print(url);
    var uri = Uri.parse(url);
    var request = http.MultipartRequest('PATCH', uri);
    request.headers['Authorization'] = "Bearer ${LocaleHandler.accessToken}";
    // Add image file
    if (image != null) {
      File imageFile = File(image!.path);
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile('file', stream, length, filename: image.toString().split("/").last,contentType: MediaType('image', 'jpg'));
      request.files.add(multipartFile);
    }
    // request.fields['type'] = "image/jpg";
    // request.fields['type'] = "file";
    var response = await request.send();
    print(response.statusCode);
    if (response.statusCode == 200) {
      // profileData();
    } else if (response.statusCode == 401) {
      showToastMsgTokenExpired();
    } else {}
  }
}*/


import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:http/http.dart'as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/loader.dart';
import 'package:slush/controller/camera_screen.dart';
import 'package:slush/screens/profile/edit_profile.dart';
import 'package:slush/screens/sign_up/details/video_trimmer.dart';
import 'package:slush/widgets/toaster.dart';
// import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:video_trimmer/video_trimmer.dart';

class editProfileController extends ChangeNotifier{
  String? imageBase64;
  String selcetedIndex="";
  File? _image;
  CroppedFile? croppedFile;
  String  PictureId="";
  VideoPlayerController? controller;
  VideoPlayerController? controller2;
  VideoPlayerController? controller3;
  VideoPlayerController? _controller4;
  Future<void>? initializeVideoPlayerFuture;
  Future<void>? initializeVideoPlayerFuture2;
  Future<void>? initializeVideoPlayerFuture3;

  // Profile API
  bool _fromProv=false;
  bool get fromprov => _fromProv;
  var _imagedata;
  get imagedata=>_imagedata;
  final picker = ImagePicker();
  File? galleryFile;
  Trimmer trimmer = Trimmer();
  bool _trimmerstrt=false;
  bool get trimmerstrt=>_trimmerstrt;
  bool _progressVisibility = false;
  double _startValue = 0.0;
  double _endValue = 0.0;
  bool isPlaying = false;

  List<BasicInfoclass> _basicInfo=[];
  List get basicInfo=>_basicInfo;
  List<BasicInfoclass> _moreaboutme=[];
  List get moreaboutme=>_moreaboutme;


  void saveValue(String gender,String hight,String job,String education,String sexualO,String ideal,String cook,String smoke,List enth){
    LocaleHandler.gender=gender;
    LocaleHandler.height=hight;
    print("hight==========$hight");
    LocaleHandler.jobtitle=job;
    LocaleHandler.education=education;
    LocaleHandler.sexualOreintation=sexualO;
    _basicInfo=[
      BasicInfoclass(1, "Gender", LocaleHandler.gender),
      BasicInfoclass(2, "Height", "${LocaleHandler.height} cm"),
      BasicInfoclass(3, "Work", LocaleHandler.jobtitle),
      BasicInfoclass(4, "Education", LocaleHandler.education),
      BasicInfoclass(7, "Sexual Orientation", LocaleHandler.sexualOreintation),
      // BasicInfoclass(8, "Ethnicity", "${LocaleHandler.dataa["ethnicity"].length} items"),
      BasicInfoclass(8, "Ethnicity",  "${enth.length} items"),
    ];

    LocaleHandler.ideal=ideal;
    LocaleHandler.cookingSkill=cook;
    LocaleHandler.smokingopinion=smoke;
    _moreaboutme=[
      BasicInfoclass(1, "Ideal vacation", LocaleHandler.ideal),
      BasicInfoclass(2, "Cooking skill", LocaleHandler.cookingSkill),
      BasicInfoclass(3, "Smoking", LocaleHandler.smokingopinion),
    ];

    notifyListeners();
  }


  void changevalue(){
    _fromProv=false;
    notifyListeners();
  }

  Future profileData(BuildContext context) async {
    final url = ApiList.getUser + LocaleHandler.userId;
    print(url);
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${LocaleHandler.accessToken}'
      });
      if (response.statusCode == 200) {
        _fromProv=true;
        Map<String, dynamic> data = jsonDecode(response.body);
        _imagedata = data["data"];
        videoValToCont();
        // if (_imagedata["profileVideos"].length != 0) {
        //   _controller = VideoPlayerController.networkUrl(Uri.parse(_imagedata["profileVideos"][0]["key"]),);
        //   _initializeVideoPlayerFuture = _controller!.initialize();
        // }
        // if (_imagedata["profileVideos"].length >= 2) {
        //   _controller2 = VideoPlayerController.networkUrl(Uri.parse(_imagedata["profileVideos"][1]["key"]),);
        //   _initializeVideoPlayerFuture2 = _controller2!.initialize();
        // }
        // if (_imagedata["profileVideos"].length >= 3) {
        //   _controller3 = VideoPlayerController.networkUrl(Uri.parse(_imagedata["profileVideos"][2]["key"]),);
        //   _initializeVideoPlayerFuture3 = _controller3!.initialize();
        // }

        notifyListeners();
        // saveDta();
      } else if (response.statusCode == 401) {
        showToastMsgTokenExpired();
        print('Token Expire:::::::::::::');
      } else {print('Faoled to Load Data With Status Code ${response.statusCode}');
        throw Exception('Failed to load data');}
    } catch (e) {throw Exception('Failed to fetch data: $e');}
    notifyListeners();
  }

  // Upload and Update image
  // void tappedOPtion(BuildContext context,ImageSource src,String index,String picId){
  //   PictureId=picId;
  //   selcetedIndex=index;
  //   notifyListeners();
  //   Future.delayed(const Duration(seconds: 1),(){
  //     Get.back();
  //     imgFromGallery(context,src);
  //     selcetedIndex="";
  //     notifyListeners();
  //   });
  // }

  void tappedOPtion(BuildContext context,ImageSource src,String index,String picId){
    PictureId=picId;
    selcetedIndex=index;
    if(src==ImageSource.camera && Platform.isAndroid){pickImageFromCamera(CameraLensDirection.front);}
    notifyListeners();
    Future.delayed(const Duration(seconds: 1),(){
      Get.back();
      if(Platform.isIOS){imgFromGallery(context,src);}
      else if(src==ImageSource.gallery && Platform.isAndroid){imgFromGallery(context,src);}
      else if(src==ImageSource.camera && Platform.isAndroid){Get.to(()=>CameraEditScreen());}
      selcetedIndex="";
      notifyListeners();
    });
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

  void disposecam(){
    camcontroller.dispose();
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

  Future imgFromGallery(BuildContext context, ImageSource src) async {
    if(src==ImageSource.camera){
      var status = await Permission.camera.status;
      if (status.isPermanentlyDenied) return openAppSettings();
      status = await Permission.camera.request();
      if (status.isDenied) return;
    }
    var image = await ImagePicker().pickImage(source: src,imageQuality: 50);
    try{
      if (image != null) {
        _image = File(image.path);
        var ImageBytes = File(image.path).readAsBytesSync();
        String imageB64 = base64Encode(ImageBytes);
        imageBase64 = imageB64;
        _cropImage(context);
        // Get.back();
        selcetedIndex = "";
      }
    }catch(error) {
      print("error: $error");
    }
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
      if (croppedFilee != null) {
        croppedFile = croppedFilee;
        PictureId == "-1" ? uploadMultipleImage(context,croppedFile!) : updateAvatar(context, croppedFile!);
        // LocaleHandler.introImage=_croppedFile;
      }
    }
    notifyListeners();
  }

  Future uploadMultipleImage(BuildContext context, CroppedFile image) async {
    const url = ApiList.multipleProfilePicture;
    print(url);
    var uri = Uri.parse(url);
    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = "Bearer ${LocaleHandler.accessToken}";
    // Add image file
    if (image != null) {
      File imageFile = File(image.path);
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile('files', stream, length,
          filename: image.toString().split("/").last);
      request.files.add(multipartFile);
    }
    // request.fields['key'] = "files";
    // request.fields['type'] = "file";
    var response = await request.send();
    print(response.statusCode);
    if (response.statusCode == 201) {
      disposecam();
      profileData(context);
    } else if (response.statusCode == 401) {
      showToastMsgTokenExpired();
    } else {}
    notifyListeners();
  }

  Future updateAvatar(BuildContext context, CroppedFile image) async {
    final url = ApiList.updateAvatar + PictureId;
    print(url);
    var uri = Uri.parse(url);
    var request = http.MultipartRequest('PATCH', uri);
    request.headers['Authorization'] = "Bearer ${LocaleHandler.accessToken}";
    // Add image file
    if (image != null) {
      File imageFile = File(image!.path);
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile('file', stream, length,
          filename: image.toString().split("/").last);
      request.files.add(multipartFile);
    }
    // request.fields['type'] = "image/jpg";
    // request.fields['type'] = "file";
    var response = await request.send();
    print(response.statusCode);
    if (response.statusCode == 200) {
      disposecam();
      profileData(context);
    } else if (response.statusCode == 401) {
      showToastMsgTokenExpired();
    } else {}
    notifyListeners();
  }

  Future DestroyPicture(BuildContext context, int id) async {
    const url = ApiList.destroyPicture;
    print(url);
    var uri = Uri.parse(url);
    var response = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${LocaleHandler.accessToken}"
        },
        body: jsonEncode({
          "ids": [id]
        }));
    print(response.statusCode);
    if (response.statusCode == 201) {
      profileData(context);
    } else if (response.statusCode == 401) {
      showToastMsgTokenExpired();
    } else {}
    notifyListeners();
  }

  Future getVideo(BuildContext context, ImageSource img) async {
    print(trimmer);
    if(galleryFile!=null){controller!.pause();    notifyListeners();}
    const allowedTimeLimit = Duration(seconds: 16);
    // const allowedTimeLimit = Duration(seconds: 4);
    final allowedTimeLimit2 = Duration(minutes: 20);
    Get.back();
    final pickedFile = await picker.pickVideo(source: img, preferredCameraDevice: CameraDevice.front, maxDuration: const Duration(seconds: 15));
    XFile? xfilePick = pickedFile;
      if (xfilePick != null) {
        showToastMsg("Please wait...");
        galleryFile = File(pickedFile!.path);
        if(Platform.isAndroid){_controller4 = VideoPlayerController.networkUrl(Uri.parse(galleryFile!.path));}
        else{_controller4 = VideoPlayerController.file(File(galleryFile!.path));}
        _controller4!..initialize().then((_) {
            if(_controller4!.value.duration<=allowedTimeLimit){
               UploadVideo( context,galleryFile!);
            }
            else if(_controller4!.value.duration<=allowedTimeLimit2){
              // galleryFile=null;
              _trimmerstrt=true;
              trimmer=Trimmer();
              _loadVideo(File(pickedFile.path));
            } else {ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video should be less then 15 seconds')));}});
      } else {ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nothing is selected')));}
  notifyListeners();
  }

  void _loadVideo(File file) {
    trimmer.loadVideo(videoFile: file);
    Get.to(()=>EditVideoTrimmerScreen());
    notifyListeners();
  }

  saveVideo(BuildContext context) {
    _progressVisibility = true;
    trimmer.saveTrimmedVideo(
      startValue: _startValue,
      endValue: _endValue,
      // ffmpegCommand: '-c:a aac -c:v copy',
      // customVideoFormat: '.mp4',
      onSave: (outputPath) {
        galleryFile=null;
        _progressVisibility = false;
        debugPrint('OUTPUT PATH: $trimmer.currentVideoFile!.path');
        trimmer.currentVideoFile;
        _trimmerstrt=false;
        _controller4 = VideoPlayerController.file(File(trimmer.currentVideoFile!.path))..initialize().then((_) {
          galleryFile=File(trimmer.currentVideoFile!.path);
          UploadVideo(context,galleryFile!);
          notifyListeners();
        });
        // getValueInController(context, outputPath!);
        Get.back();
        notifyListeners();
      },
    );
    notifyListeners();
  }

  Future getValueInController(BuildContext context,String outputVideoPath)async{
    // Get.back();
    _trimmerstrt=false;
    _controller4 = VideoPlayerController.file(File(outputVideoPath))..initialize().then((_) {
      galleryFile=File(trimmer.currentVideoFile!.path);
      UploadVideo(context,galleryFile!);
      notifyListeners();
    });
    notifyListeners();
  }

  Future UploadVideo(BuildContext context,File video) async {
    const url = ApiList.uploadVideo;
    var uri = Uri.parse(url);
    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = "Bearer ${LocaleHandler.accessToken}";
    if (video != null) {
      // final mediaInfo = await VideoCompress.compressVideo(video.path, quality: VideoQuality.LowQuality);
      File introVideo = File(video.path);
      // File introVideo = mediaInfo!.path as File;
      var stream = http.ByteStream(introVideo.openRead());
      var length = await introVideo.length();
      var multipartFile2 = http.MultipartFile('files', stream, length, filename: video.toString().split("/").last,contentType: MediaType('video','mp4'));
      // var multipartFile2 = await http.MultipartFile.fromPath('files',video.toString(),filename: video.toString().split("/").last,contentType: MediaType('files','mp4'));
      request.files.add(multipartFile2);
    }
    var response = await request.send();
    final respStr = await response.stream.bytesToString();
    print(respStr);
    if (response.statusCode == 201) {
      _trimmerstrt=false;
      profileData(context);
    } else if (response.statusCode == 401) {
      showToastMsgTokenExpired();
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

  void trimmVideoPLayPause(bool val){
    isPlaying=val;
    notifyListeners();
  }

  void cancelSelectedTrimVideo()async{
    _trimmerstrt=false;
    galleryFile=null;
    _controller4!.dispose();
    LocaleHandler.introVideo=null;
    trimmer.dispose();
    _startValue = 0.0;
    _endValue = 0.0;

    trimmer.videoPlayerController!.dispose();
    trimmer.currentVideoFile!.delete();

    _controller4!.removeListener((){_controller4 = null;});
    trimmer.currentVideoFile=null;
    trimmer.videoPlayerController!.removeListener((){});
    // trimmer.videoPlayerController.closedCaptionFile;

    Get.back();
    notifyListeners();
  }

  void playTrimmmervideo()async{
    await trimmer.videoPlaybackControl(startValue: _startValue, endValue: _endValue);
    notifyListeners();
  }

  Future DestroyVideo(BuildContext context,int id) async {
    const url = ApiList.destroyVideo;
    print(url);
    var uri = Uri.parse(url);
    var response = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${LocaleHandler.accessToken}"
        },
        body: jsonEncode({"ids": [id]}));
    print(response.statusCode);
    if (response.statusCode == 201) {profileData(context);
    Get.back();
    }
    else if (response.statusCode == 401) {showToastMsgTokenExpired();} else {}
  }

  void videoValToCont(){
    var data=_fromProv?imagedata:LocaleHandler.dataa;
    if (data["profileVideos"].length != 0) {
      controller = VideoPlayerController.networkUrl(Uri.parse(data["profileVideos"][0]["key"]));
      initializeVideoPlayerFuture = controller!.initialize();
    }
    if (data["profileVideos"].length >= 2) {
      controller2 = VideoPlayerController.networkUrl(Uri.parse(data["profileVideos"][1]["key"]));
      initializeVideoPlayerFuture2 = controller2!.initialize();
    }
    if (data["profileVideos"].length >= 3) {
      controller3 = VideoPlayerController.networkUrl(Uri.parse(data["profileVideos"][2]["key"]));
      initializeVideoPlayerFuture3 = controller3!.initialize();
    }
    notifyListeners();
  }

}