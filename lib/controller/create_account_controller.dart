import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
// import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:provider/provider.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/loader.dart';
import 'package:http/http.dart' as http;
import 'package:slush/constants/prefs.dart';
import 'package:slush/controller/controller.dart';
import 'package:slush/controller/detail_controller.dart';
import 'package:slush/controller/event_controller.dart';
import 'package:slush/controller/login_controller.dart';
import 'package:slush/controller/profile_controller.dart';
import 'package:slush/screens/events/bottomNavigation.dart';
import 'package:slush/screens/sign_up/details.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:slush/widgets/toaster.dart';

class createAccountController extends ChangeNotifier {
  String email = "";
  String enableField = "";

  // void emailFieldText(val){enableField=val;notifyListeners();}

  Future registerUser(BuildContext context, String mail, String password) async {
    email = mail;
    const url = ApiList.registerUser;
    print(url);
    print(LocaleHandler.accessToken);
    var uri = Uri.parse(url);
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        LoaderOverlay.show(context);
        try {
          final response = await http.post(uri,
            headers: <String, String>{'Content-Type': 'application/json'},
            body: jsonEncode({"receiveOffers": false, "email": email, "password": password}),
          );
          var data = jsonDecode(response.body);
          LoaderOverlay.hide();
          if (response.statusCode == 201) {
            saveDetailsToLocal(data);
            bottomsheett(context);
            return response;
          } else if (response.statusCode == 409) {
            getDetails();
            LoaderOverlay.show(context);
            LocaleHandler.ErrorMessage = data["message"];
            checkEmailVerifies(context);
          } else {
            LoaderOverlay.hide();
            Fluttertoast.showToast(msg: "Server Error");
            throw Exception("sdsdds");
          }
        } catch (e) {
          LoaderOverlay.hide();
          Fluttertoast.showToast(msg: "Server error");
        }
      }
    } on SocketException catch (_) {
      showToastMsg("No Interenet Connection...",clrbg: Colors.red,clrtxt: color.txtWhite);
    }
    notifyListeners();
  }

  Future checkEmailVerifies(BuildContext context) async {
    const url = ApiList.checkEmail;
    print(url);
    var uri = Uri.parse(url);
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${LocaleHandler.accessToken}'
        },
        body: jsonEncode({"email": email}),
      );
      var data = jsonDecode(response.body);
      LoaderOverlay.hide();
      if (response.statusCode == 201) {
        LocaleHandler.emailVerified = data["data"]["verified"].toString();
        Preferences.setValue("emailVerified", LocaleHandler.emailVerified);
        print(LocaleHandler.emailVerified);
        if (LocaleHandler.emailVerified == "true") {
          Provider.of<detailedController>(context, listen: false).setCurrentIndex();
          LocaleHandler.EditProfile = false;
          Get.to(() => const DetailScreen());
        } else {
          sentEmailToverify();
          Fluttertoast.showToast(msg: "Email verification pending. Please check your email.");
        }
        return response;
      } else {
        Fluttertoast.showToast(msg: LocaleHandler.ErrorMessage);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Server error");
    }
    notifyListeners();
  }

  Future sentEmailToverify() async {
    const url = ApiList.sendverifyemail;
    print(url);
    var uri = Uri.parse(url);
    var response = await http.post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
          "Authorization": LocaleHandler.bearer
        },
        body: jsonEncode({"email": email}));
    if (response.statusCode == 201) {
    } else if (response.statusCode == 401) {
      Fluttertoast.showToast(msg: "Invalid Email");
    } else {
      Fluttertoast.showToast(msg: "Server Error");
    }
    LoaderOverlay.hide();
    notifyListeners();
  }

  Future<void> loginWithFacebookk() async {
    // final result = await FacebookLogin().logIn(customPermissions: ['email']);
    // switch (result.status) {
    //   case FacebookLoginStatus.success:
    //     result.accessToken;
    //     result.status;
    //     // final AuthCredential credential = FacebookAuthProvider.credential(
    //     //   enableField,
    //     //
    //     //   // idToken: result.accessToken?.userId,
    //     // );
    //     // final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    //     // final User? user = userCredential.user;
    //     // print('User  ----------- ${user.toString()}');
    //     // print('Credential ----------- ${credential.toString()}');
    //     final OAuthCredential facebookAuthCredential =
    //         FacebookAuthProvider.credential(result.accessToken!.token);
    //     // Once signed in, return the UserCredential
    //     FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
    //     socialLoginUser(
    //       "FACEBOOK",
    //       socialToken: result.accessToken.toString(),
    //     );
    //     print('Status ----------- ${result.accessToken}');
    //     print('Status ----------- ${result.status}');
    //     // You're logged in with Facebook, use result.accessToken to make API calls.
    //     print('Facebook Logged in Successfully-----');
    //     break;
    //   case FacebookLoginStatus.cancel:
    //     print('Status Cancel By User  ----------- ${result.status}');
    //     // User cancelled the login.
    //     break;
    //   case FacebookLoginStatus.error:
    //     // There was an error during login.
    //     print('Error ----------- ${result.error.toString()}');
    //     break;
    // }
    // notifyListeners();
  }

  Future<Resource?> loginWithFacebook(BuildContext context,) async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      switch (result.status) {
        case LoginStatus.success:
          final AuthCredential facebookCredential = FacebookAuthProvider.credential(result.accessToken!.token);
          final userCredential = await FirebaseAuth.instance.signInWithCredential(facebookCredential);
          print("1;-;-;-$facebookCredential");
          print("2;-;-;-$userCredential");
          print("3;-;-;-${Status}");
          LoaderOverlay.show(context);
          socialLoginUser(context,"FACEBOOK",socialToken: facebookCredential.accessToken.toString(),);
          return Resource(status: Status.Success);
        case LoginStatus.cancelled:
          print("4;-;-;-${Status}");
          return Resource(status: Status.Cancelled);
        case LoginStatus.failed:
          print("5;-;-;-${Status}");
          return Resource(status: Status.Error);
        default:
          print("6;-;-;-${Status}");
          return null;
      }
    } on FirebaseAuthException catch (e) {
      throw e;
    }
    notifyListeners();
  }

  Future<void> signInWithGoogle(BuildContext context,GoogleSignIn googleSignIn) async {
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
      socialLoginUser(context,"GOOGLE", socialToken: credential.accessToken.toString());
      // Use the user object for further operations or navigate to a new screen.
    } catch (e) {
      print(e.toString());
    }
    notifyListeners();
  }

  Future socialLoginUser(BuildContext context, String type, {required String socialToken, providerName}) async {
    final url = ApiList.socialLogin;
    print(url);
    var uri = Uri.parse(url);
    var response = await http.post(uri,
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode({
          "socialProvider": type,
          "token": socialToken,
        }));
    var data = jsonDecode(response.body);
    print("response.statusCode======${response.statusCode}");
    print(data);
    LoaderOverlay.hide();
    if (response.statusCode == 201) {
      LocaleHandler.socialLogin="yes";
      print(LocaleHandler.accessToken);
      LoaderOverlay.hide();
      if (data["data"]["emailVerifiedAt"] == true) {
        Provider.of<ReelController>(context,listen: false).getVideoCount(context);
        Provider.of<profileController>(context,listen: false).getTotalSparks();
        saveDetailsToLocal(data);
        Get.offAll(() => BottomNavigationScreen());}

      else if(data["data"]["nextAction"]=="none"){
        Provider.of<ReelController>(context,listen: false).getVideoCount(context);
        Provider.of<profileController>(context,listen: false).getTotalSparks();
        saveDetailsToLocal(data);
        Get.offAll(() => BottomNavigationScreen());}

      else {
        saveDetailsToLocal(data);
        Provider.of<detailedController>(context, listen: false).setCurrentIndex();
        LocaleHandler.EditProfile = false;
        Get.to(() => const DetailScreen());
      }
    } else if (response.statusCode == 401) {
      LoaderOverlay.hide();
      Fluttertoast.showToast(msg: data["message"]);
    } else {
      LoaderOverlay.hide();
      Fluttertoast.showToast(msg: data["message"]);
    }
    notifyListeners();
  }

  void saveDetailsToLocal(var data) {
    LocaleHandler.accessToken = data["data"]["authenticate"]["accessToken"];
    LocaleHandler.refreshToken = data["data"]["authenticate"]["refreshToken"];
    LocaleHandler.nextAction = data["data"]["nextAction"];
    LocaleHandler.nextDetailAction = data["data"]["nextDetailAction"];
    LocaleHandler.emailVerified = data["data"]["emailVerifiedAt"].toString();
    LocaleHandler.userId = data["data"]["userId"].toString();
    // LocaleHandler.role = data["data"]["role"];
    // LocaleHandler.subscriptionPurchase =data["data"]["isSubscriptionPurchased"];
    Preferences.setValue("token", LocaleHandler.accessToken);
    Preferences.setValue("socialLogin", LocaleHandler.socialLogin);
    Preferences.setrefreshToken(data["data"]["authenticate"]["refreshToken"]);
    Preferences.setNextAction(data["data"]["nextAction"]);
    // Preferences.setNextDetailAction(data["data"]["nextDetailAction"]);
    Preferences.setValue("emailVerif`ied", LocaleHandler.emailVerified);
    Preferences.setValue("userId", LocaleHandler.userId);
    // Preferences.setValue("role", LocaleHandler.role);
    // Preferences.setValue("subscriptionPurchase", LocaleHandler.subscriptionPurchase);
    notifyListeners();
  }

  void getDetails() async {
    LocaleHandler.accessToken = await Preferences.getValue("token") ?? "";
    LocaleHandler.refreshToken = await Preferences.getrefreshToken() ?? "";
    LocaleHandler.nextAction = await Preferences.getNextAction() ?? "";
    // LocaleHandler.nextDetailAction = await Preferences.getNextDetailAction() ?? "";
    LocaleHandler.emailVerified = await Preferences.getValue("emailVerified") ?? "";
    LocaleHandler.userId = await Preferences.getValue("userId") ?? "";
    LocaleHandler.role = await Preferences.getValue("role") ?? "";
    LocaleHandler.subscriptionPurchase = await Preferences.getValue("subscriptionPurchase") ?? "";
    notifyListeners();
  }

  void bottomsheett(BuildContext context) {
    customDialogBox(
        context: context,
        title: 'Confirm your email',
        secontxt: "We have sent a confirmation email  to:  ${getInitials(email)}",
        heading: 'Please check your email and click on the confirmation link to continue.',
        btnTxt: "Go to email",
        img: AssetsPics.mailImg2,
        onTap: () async {
          if (LocaleHandler.emailVerified == "true") {
            Provider.of<detailedController>(context, listen: false).setCurrentIndex();
            LocaleHandler.EditProfile = false;
            Get.to(() => const DetailScreen());}
          else { Fluttertoast.showToast(msg: "Not Verified yet!"); }
          Get.back();
          var result = await OpenMailApp.openMailApp();
          if (!result.didOpen && !result.canOpen) {
            // showNoMailAppsDialog(context);
          } else if (!result.didOpen && result.canOpen) {
            showDialog(context: context, builder: (_) {
                return MailAppPickerDialog(mailApps: result.options);
              },
            );
          }
        });
  }

  String getInitials(bankaccountname) {
    String emailText = bankaccountname;
    int a = emailText.lastIndexOf("@");
    emailText = emailText.substring(a - 2);
    for (var i = 0; i < a - 2; i++) {
      emailText = "*" + emailText;
    }
    return emailText;
  }
}
