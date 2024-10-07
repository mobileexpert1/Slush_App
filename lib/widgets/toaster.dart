import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/prefs.dart';
import 'package:slush/screens/getstarted/slider_scree.dart';
import 'package:slush/screens/login/login.dart';
import 'package:slush/widgets/text_widget.dart';

Future showToastMsg(String msg,{Color clrbg=Colors.grey,Color clrtxt=Colors.white}) {
  return Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_LONG, // You can also use Toast.LENGTH_LONG
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1, // Only necessary for iOS and web
    backgroundColor: clrbg,
    textColor: clrtxt,
    fontSize: 15.0,
  );
}

Future showToastMsgTokenExpired({String msg="Token Expired"}) {
  return Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_LONG, // You can also use Toast.LENGTH_LONG
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1, // Only necessary for iOS and web
    backgroundColor: Colors.red,
    textColor: Colors.white,
    fontSize: 15.0,
  ).then((value) {
    Get.offAll(() => const SliderScreen());
        LocaleHandler.accessToken='';
        LocaleHandler.refreshToken='';
        LocaleHandler.bearer='';
        LocaleHandler.nextAction = "";
        LocaleHandler.nextDetailAction = "";
        LocaleHandler.emailVerified = "";
        LocaleHandler.name = "";
        LocaleHandler.location = "";
        LocaleHandler.userId = "";
        LocaleHandler.role = "";
        LocaleHandler.subscriptionPurchase = "";
    Preferences.setValue("token", LocaleHandler.accessToken);
    Preferences.setrefreshToken(LocaleHandler.refreshToken);
        Preferences.setNextAction("");
        Preferences.setNextDetailAction("");
        Preferences.setValue("emailVerified", LocaleHandler.emailVerified);
        Preferences.setValue("name", LocaleHandler.name);
        Preferences.setValue("location", LocaleHandler.location);
        Preferences.setValue("userId", LocaleHandler.userId);
        Preferences.setValue("role", LocaleHandler.role);
        Preferences.setValue("subscriptionPurchase", LocaleHandler.subscriptionPurchase);
  });
}

Future showAlertMsg(context, String msg ){
  return QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      text: msg,
      autoCloseDuration: const Duration(seconds: 5)
  );
}

SnackbarController snackBaar(BuildContext context,String img,bool isPng){
  return Get.snackbar('', '',
    snackPosition: SnackPosition.TOP,
    margin: const EdgeInsets.all(0),
    padding: const EdgeInsets.all(0),
    backgroundColor: Colors.transparent,
    borderRadius: 0.0,
    titleText: Stack(alignment: Alignment.center,
      children: [
        SizedBox(width: MediaQuery.of(context).size.width,
            child:isPng?Image.asset(img,fit: BoxFit.cover): SvgPicture.asset(img,fit: BoxFit.cover)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
           isPng?const SizedBox(): Container(color: Colors.transparent,
              transform: Matrix4.translationValues(MediaQuery.of(context).size.width * -.11, 0, 0.0),
              child: SvgPicture.asset(AssetsPics.bannerheart),
            ),
            isPng?const SizedBox():   Container(color: Colors.transparent,
              transform: Matrix4.translationValues(MediaQuery.of(context).size.width * .01, 0, 10.0),
              child: SvgPicture.asset(AssetsPics.bannerheart)),
          ],)],
    ),
    shouldIconPulse: true,
    maxWidth: MediaQuery.of(context).size.width,
    borderWidth: 0.0,
    overlayBlur: 0.0,
    barBlur: 0.0,
    isDismissible: true,);
}

SnackbarController snackBaarblue(BuildContext context,String img,String txt){
  return Get.snackbar('', '',
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      borderRadius: 0.0,
      titleText: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width,
              child: SvgPicture.asset(img,fit: BoxFit.cover)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                transform: Matrix4.translationValues(MediaQuery.of(context).size.width * -.11, 0, 0.0),
                child: SvgPicture.asset(AssetsPics.bannerheart),
              ),
              Container(
                transform: Matrix4.translationValues(MediaQuery.of(context).size.width * .01, 0, 10.0),
                child: SvgPicture.asset(AssetsPics.bannerheart),
              ),
            ],),
          Container(padding: const EdgeInsets.only(top: 0,left: 10,right: 10,bottom: 15),
              child: buildText2(txt, 20, FontWeight.w600,color.txtWhite)),
        ],
      ),
      shouldIconPulse: true,
      maxWidth: MediaQuery.of(context).size.width,
      snackStyle: SnackStyle.FLOATING,
      borderWidth: 0.0,
      overlayBlur: 0.0,

      barBlur: 0.0
    // progressIndicatorBackgroundColor: Colors.red,
    // icon: Icon(Icons.add),

  );
}

