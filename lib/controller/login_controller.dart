import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart'as http;
import 'package:provider/provider.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/loader.dart';
import 'package:slush/constants/prefs.dart';
import 'package:slush/controller/controller.dart';
import 'package:slush/controller/detail_controller.dart';
import 'package:slush/controller/event_controller.dart';
import 'package:slush/controller/profile_controller.dart';
import 'package:slush/screens/events/bottomNavigation.dart';
import 'package:slush/screens/sign_up/details.dart';
import 'package:slush/widgets/toaster.dart';

class loginControllerr with ChangeNotifier{

  int value=50000;
  int get val=>value;

  void changeValue(vall){
    value=vall;
    LocaleHandler.distancee=vall;
    LocaleHandler.distancevalue=vall;
    notifyListeners();
  }

  bool recordingOff=false;
  bool get recordingOfff=>recordingOff;
  void changebool(BuildContext context, val){
    recordingOff=val;
    notifyListeners();
  }

  late Timer _timer;
  int _secondsLeft = 5;
  int get secondsLeft=>_secondsLeft;

  void startTimer() {
    _secondsLeft=5;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {_secondsLeft--;notifyListeners();}
      else {_timer.cancel();}
    });
    notifyListeners();
  }

  String _refereshToken="";
  Future loginUser(BuildContext context,String email,String password)async{
    LoaderOverlay.show(context);
    const url=ApiList.login;
    print(url);
    var uri=Uri.parse(url);
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var response = await http.post(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({"email": email, "password": password}));
        var data = jsonDecode(response.body);
        print(data);
        if(response.statusCode == 201){
          _refereshToken=data["data"]["authenticate"]["refreshToken"];
          Provider.of<reelController>(context,listen: false).getVideoCount(context);
          Provider.of<profileController>(context,listen: false).getTotalSparks();
          saveDAta(context,data);
          print(LocaleHandler.accessToken);
          LoaderOverlay.hide();
          if(data["data"]["emailVerifiedAt"]==true){
            if(data["data"]["nextAction"]=="none"){
              Get.offAll(()=>BottomNavigationScreen());
            }
            else{
              Provider.of<detailedController>(context,listen: false).setCurrentIndex();
              LocaleHandler.EditProfile = false;
              Get.offAll(()=>const DetailScreen());}
          }
          else{
            Fluttertoast.showToast(msg: "Please verify the link send to your entered email");
            sentEmailToverify(email);
          }
          initPlatformState();
        }
        else if (response.statusCode==401){
          LoaderOverlay.hide();
          Fluttertoast.showToast(msg: data["message"]);
        }
        else {
          LoaderOverlay.hide();
          Fluttertoast.showToast(msg: data["message"]);
        }
      }
    } on SocketException catch (_) {
      LoaderOverlay.hide();
      showToastMsg("No Interenet Connection...",clrbg: Colors.red,clrtxt: color.txtWhite);
      // LocaleHandler.noInternet=true;
    }
    notifyListeners();
  }

  Future hitFCMTOken(String id,String name)async{
    const url=ApiList.fcmToken;
    print(url);
    var uri=Uri.parse(url);
    var response=await http.post(uri,headers: {'Content-Type': 'application/json', 
      'Authorization': 'Bearer ${LocaleHandler.accessToken}'},
    body: jsonEncode({
      "token":_refereshToken,
      "deviceId":id,
      "deviceName":name
    }));
    if(response.statusCode==201){

    }
    else if(response.statusCode==401){}
    else{}
    notifyListeners();
  }



  Future sentEmailToverify(String email)async{
    const url=ApiList.sendverifyemail;
    var uri=Uri.parse(url);
    print(url);
    var response=await http.post(uri,
        headers: <String,String>{'Content-Type': 'application/json',
          "Authorization":LocaleHandler.bearer},
        body: jsonEncode({"email": email})
    );
    var data=jsonDecode(response.body);
    if(response.statusCode==201){Fluttertoast.showToast(msg: data["message"]);}
    else if(response.statusCode==401){Fluttertoast.showToast(msg: "Invalid Email");}
    else{Fluttertoast.showToast(msg: "Server Error");}
    LoaderOverlay.hide();
    notifyListeners();
  }

  saveDAta(BuildContext context, data){
    LocaleHandler.accessToken = data["data"]["authenticate"]["accessToken"];
    LocaleHandler.refreshToken = data["data"]["authenticate"]["refreshToken"];
    LocaleHandler.nextAction = data["data"]["nextAction"];
    LocaleHandler.nextDetailAction = data["data"]["nextDetailAction"]??"none";
    LocaleHandler.emailVerified = data["data"]["emailVerifiedAt"].toString();
    LocaleHandler.name = data["data"]["firstName"]??"";
    LocaleHandler.lookingfor = data["data"]["lookingFor"]??"";
    LocaleHandler.sexualOreintation = data["data"]["sexuality"]??"";
    LocaleHandler.avatar = data["data"]["avatar"]??"";
    // LocaleHandler.location = data["data"]["address"]??"";
    // LocaleHandler.location = data["data"]["country"]??"";
    LocaleHandler.userId = data["data"]["userId"].toString();
    // LocaleHandler.role = data["data"]["role"];
    LocaleHandler.latitude = data["data"]["latitude"]??"";
    LocaleHandler.longitude = data["data"]["longitude"]??"";
    LocaleHandler.gender = data["data"]["gender"]??"male";
    // LocaleHandler.subscriptionPurchase = data["data"]["isSubscriptionPurchased"];
    if(data["data"]["latitude"]!=null){LocaleHandler.latitude=data["data"]["latitude"];}
    if(data["data"]["longitude"]!=null){LocaleHandler.longitude=data["data"]["longitude"];}

    Preferences.setValue("token", LocaleHandler.accessToken);
    Preferences.setrefreshToken(data["data"]["authenticate"]["refreshToken"]);
    Preferences.setNextAction(data["data"]["nextAction"]);
    // Preferences.setNextDetailAction(data["data"]["nextDetailAction"]);
    Preferences.setValue("emailVerified", LocaleHandler.emailVerified);
    // Preferences.setValue("name", LocaleHandler.name);
    // Preferences.setValue("location", LocaleHandler.location);
    Preferences.setValue("userId", LocaleHandler.userId);
    // Preferences.setValue("role", LocaleHandler.role);
    // Preferences.setValue("subscriptionPurchase", LocaleHandler.subscriptionPurchase);
    // Preferences.setValue("avatar", LocaleHandler.avatar);
    Preferences.setValue("latitude", LocaleHandler.latitude);
    Preferences.setValue("longitude", LocaleHandler.longitude);
    Provider.of<eventController>(context, listen: false).getmeEvent(context,"me");
    notifyListeners();
  }


  Future socialLoginUser(String type,{required String socialToken,providerName})async{
    const url=ApiList.socialLogin;
    print(url);
    var uri=Uri.parse(url);
    var response=await http.post(uri,
        headers: <String,String>{'Content-Type': 'application/json'},
        body: jsonEncode({
          "socialProvider": type,
          "token": socialToken,
        })
    );
    var data = jsonDecode(response.body);
    print("response.statusCode======${response.statusCode}");
    print(data);
    if(response.statusCode==201){
      print(LocaleHandler.accessToken);
      LoaderOverlay.hide();
      if(data["data"]["emailVerifiedAt"]==true){
        Get.offAll(()=>BottomNavigationScreen());}
      else{
        Fluttertoast.showToast(msg: "Please verify the link send to your entered email");
        // sentEmailToverify();
      }
    }else if(response.statusCode==401){
      LoaderOverlay.hide();
      Fluttertoast.showToast(msg: data["message"]);
    }
    else{
      LoaderOverlay.hide();
      Fluttertoast.showToast(msg: data["message"]);
    }
    notifyListeners();
  }

  Future<void> loginWithFacebook() async {
    final result = await FacebookLogin().logIn(customPermissions: ['email']);
    switch (result.status) {
      case FacebookLoginStatus.success:
        result.accessToken;
        result.status;
        // final AuthCredential credential = FacebookAuthProvider.credential(
        //   enableField,
        //
        //   // idToken: result.accessToken?.userId,
        // );
        // final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        // final User? user = userCredential.user;
        // print('User  ----------- ${user.toString()}');
        // print('Credential ----------- ${credential.toString()}');
        final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(result.accessToken!.token);
        // Once signed in, return the UserCredential
        FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
        socialLoginUser("FACEBOOK",socialToken: result.accessToken.toString(),);
        print('Status ----------- ${result.accessToken}');
        print('Status ----------- ${result.status}');
        // You're logged in with Facebook, use result.accessToken to make API calls.
        print('Facebook Logged in Successfully-----');
        break;
      case FacebookLoginStatus.cancel:
        print('Status Cancel By User  ----------- ${result.status}');
        // User cancelled the login.
        break;
      case FacebookLoginStatus.error:
      // There was an error during login.
        print('Error ----------- ${result.error.toString()}');
        break;
    }
  }

  Future<void> signInWithGoogle(GoogleSignIn googleSignIn) async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(accessToken: googleSignInAuthentication.accessToken, idToken: googleSignInAuthentication.idToken);
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;
      // loginUser();
      print("User -- -> ${user.toString()}");
      print("\nUser Credentials -- -> ${userCredential}");
      socialLoginUser("GOOGLE", socialToken: credential.accessToken.toString());
      // Use the user object for further operations or navigate to a new screen.
    } catch (e) {
      print(e.toString());
    }
    notifyListeners();
  }



  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};
    try {
      if (kIsWeb) {deviceData = _readWebBrowserInfo(await deviceInfoPlugin.webBrowserInfo);
      } else {
        deviceData = switch (defaultTargetPlatform) {
        TargetPlatform.android =>_readAndroidBuildData(await deviceInfoPlugin.androidInfo),
    TargetPlatform.iOS =>_readIosDeviceInfo(await deviceInfoPlugin.iosInfo),
    TargetPlatform.linux =>_readLinuxDeviceInfo(await deviceInfoPlugin.linuxInfo),
    TargetPlatform.windows =>_readWindowsDeviceInfo(await deviceInfoPlugin.windowsInfo),
    TargetPlatform.macOS =>_readMacOsDeviceInfo(await deviceInfoPlugin.macOsInfo),
    TargetPlatform.fuchsia => <String, dynamic>{'Error:': 'Fuchsia platform isn\'t supported'},
    };}} on PlatformException {
      deviceData = <String, dynamic>{'Error:': 'Failed to get platform version.'};
    }

    // if (!mounted) return;

    _deviceData = deviceData;
    print('Devices:---$deviceData');
    String id=_deviceData['id'];
    String name =Platform.isAndroid? "${_deviceData['brand']} (${_deviceData['model']})":_deviceData['model'];
    hitFCMTOken(id,name);
    notifyListeners();
  }
  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'version':build.version,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'systemFeatures': build.systemFeatures,
      'serialNumber': build.serialNumber,
      // 'isLowRamDevice': build.isLowRamDevice,
    };
  }
  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }
  Map<String, dynamic> _readLinuxDeviceInfo(LinuxDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'version': data.version,
      'id': data.id,
      'idLike': data.idLike,
      'versionCodename': data.versionCodename,
      'versionId': data.versionId,
      'prettyName': data.prettyName,
      'buildId': data.buildId,
      'variant': data.variant,
      'variantId': data.variantId,
      'machineId': data.machineId,
    };
  }
  Map<String, dynamic> _readWebBrowserInfo(WebBrowserInfo data) {
    return <String, dynamic>{
      'browserName': data.browserName.name,
      'appCodeName': data.appCodeName,
      'appName': data.appName,
      'appVersion': data.appVersion,
      'deviceMemory': data.deviceMemory,
      'language': data.language,
      'languages': data.languages,
      'platform': data.platform,
      'product': data.product,
      'productSub': data.productSub,
      'userAgent': data.userAgent,
      'vendor': data.vendor,
      'vendorSub': data.vendorSub,
      'hardwareConcurrency': data.hardwareConcurrency,
      'maxTouchPoints': data.maxTouchPoints,
    };
  }
  Map<String, dynamic> _readMacOsDeviceInfo(MacOsDeviceInfo data) {
    return <String, dynamic>{
      'computerName': data.computerName,
      'hostName': data.hostName,
      'arch': data.arch,
      'model': data.model,
      'kernelVersion': data.kernelVersion,
      'majorVersion': data.majorVersion,
      'minorVersion': data.minorVersion,
      'patchVersion': data.patchVersion,
      'osRelease': data.osRelease,
      'activeCPUs': data.activeCPUs,
      'memorySize': data.memorySize,
      'cpuFrequency': data.cpuFrequency,
      'systemGUID': data.systemGUID,
    };
  }
  Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo data) {
    return <String, dynamic>{
      'numberOfCores': data.numberOfCores,
      'computerName': data.computerName,
      'systemMemoryInMegabytes': data.systemMemoryInMegabytes,
      'userName': data.userName,
      'majorVersion': data.majorVersion,
      'minorVersion': data.minorVersion,
      'buildNumber': data.buildNumber,
      'platformId': data.platformId,
      'csdVersion': data.csdVersion,
      'servicePackMajor': data.servicePackMajor,
      'servicePackMinor': data.servicePackMinor,
      'suitMask': data.suitMask,
      'productType': data.productType,
      'reserved': data.reserved,
      'buildLab': data.buildLab,
      'buildLabEx': data.buildLabEx,
      'digitalProductId': data.digitalProductId,
      'displayVersion': data.displayVersion,
      'editionId': data.editionId,
      'installDate': data.installDate,
      'productId': data.productId,
      'productName': data.productName,
      'registeredOwner': data.registeredOwner,
      'releaseId': data.releaseId,
      'deviceId': data.deviceId,
    };
  }
}