import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
import 'package:slush/controller/detail_controller.dart';
import 'package:slush/screens/events/bottomNavigation.dart';
import 'package:slush/screens/sign_up/details.dart';
import 'package:slush/widgets/toaster.dart';

class loginControllerr with ChangeNotifier{

  int value=50000;
  int get val=>value;

  void changeValue(vall){
    value=vall;
    LocaleHandler.distancee=vall;
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

  Future loginUser(BuildContext context,String email,String password)async{
    LoaderOverlay.show(context);
    final url=ApiList.login;
    print(url);
    var uri=Uri.parse(url);
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var response = await http.post(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({"email": email, "password": password})).timeout(const Duration(seconds: 10));
        var data = jsonDecode(response.body);
        print(data);
        if(response.statusCode == 201){
          saveDAta(data);
          print(LocaleHandler.accessToken);
          LoaderOverlay.hide();
          if(data["data"]["emailVerifiedAt"]==true){
            if(data["data"]["nextAction"]=="none"){
              Get.offAll(()=>BottomNavigationScreen());
            }
            else{
              Provider.of<detailedController>(context,listen: false).setCurrentIndex();
              Get.offAll(()=>const DetailScreen());}
          }
          else{
            Fluttertoast.showToast(msg: "Please verify the link send to your entered email");
            sentEmailToverify(email);
          }
        } else if (response.statusCode==401){
          LoaderOverlay.hide();
          Fluttertoast.showToast(msg: data["message"]);
          Fluttertoast.showToast(msg: "dasdsdadd");
        } else {
          LoaderOverlay.hide();
          Fluttertoast.showToast(msg: data["message"]);
          Fluttertoast.showToast(msg: "SASASSASSASS");
        }
      }
    } on SocketException catch (_) {
      LoaderOverlay.hide();
      showToastMsg("No Interenet Connection...",clrbg: Colors.red,clrtxt: color.txtWhite);
      // LocaleHandler.noInternet=true;
    }
    notifyListeners();
  }

  Future sentEmailToverify(String email)async{
    final url=ApiList.sendverifyemail;
    var uri=Uri.parse(url);
    print(url);
    var response=await http.post(uri,
        headers: <String,String>{'Content-Type': 'application/json',
          "Authorization":LocaleHandler.bearer},
        body: jsonEncode({"email": email})
    );
    var data=jsonDecode(response.body);
    if(response.statusCode==201){
      Fluttertoast.showToast(msg: data["message"]);
    }else if(response.statusCode==401){
      Fluttertoast.showToast(msg: "Invalid Email");
    }
    else{
      Fluttertoast.showToast(msg: "Server Error");
    }
    LoaderOverlay.hide();
    notifyListeners();
  }

  saveDAta(data){
    LocaleHandler.accessToken = data["data"]["authenticate"]["accessToken"];
    LocaleHandler.refreshToken = data["data"]["authenticate"]["refreshToken"];
    LocaleHandler.nextAction = data["data"]["nextAction"];
    LocaleHandler.nextDetailAction = data["data"]["nextDetailAction"];
    LocaleHandler.emailVerified = data["data"]["emailVerifiedAt"].toString();
    LocaleHandler.name = data["data"]["firstName"]??"";
    LocaleHandler.lookingfor = data["data"]["lookingFor"]??"";
    LocaleHandler.sexualOreintation = data["data"]["sexuality"]??"";
    // LocaleHandler.avatar = data["data"]["avatar"]??"";
    // LocaleHandler.location = data["data"]["address"]??"";
    // LocaleHandler.location = data["data"]["country"]??"";
    LocaleHandler.userId = data["data"]["userId"].toString();
    // LocaleHandler.role = data["data"]["role"];
    LocaleHandler.latitude = data["data"]["latitude"]??"";
    LocaleHandler.longitude = data["data"]["longitude"]??"";
    LocaleHandler.gender = data["data"]["gender"]??"";
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
    notifyListeners();
  }


  Future socialLoginUser(String type,{required String socialToken,providerName})async{
    final url=ApiList.socialLogin;
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
      final GoogleSignInAccount? googleSignInAccount =
      await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;
      // loginUser();
      print("User -- -> ${user.toString()}");
      // print("User Credentials -- -> ${user}");
      print("User Credentials -- -> ${userCredential}");
      socialLoginUser("GOOGLE", socialToken: credential.accessToken.toString());
      // Use the user object for further operations or navigate to a new screen.
    } catch (e) {
      print(e.toString());
    }
    notifyListeners();
  }
}