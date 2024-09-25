

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/controller/waitingroom_controller.dart';
import 'package:slush/screens/splash/splash_controller.dart';
import 'package:slush/widgets/text_widget.dart';

Widget bioAlert(BuildContext context){
  return  Consumer<SplashController>(builder: (context,val,child){return
    Visibility(
        visible: LocaleHandler.bioAuth,
        child: Container(
          height:  MediaQuery.of(context).size.height,
          width:  MediaQuery.of(context).size.height,
          color: Colors.black54,
          child: AlertDialog(
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.white,
            title: buildText2('Slush is locked', 25, FontWeight.w600, color.txtBlack),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildText2('Authentication is required to access the slush app', 18, FontWeight.w400, color.txtBlack),
                const Divider(),
                TextButton(onPressed: () {
                  Provider.of<SplashController>(context,listen: false).getAvailableBiometrics();},
                  child: buildText('Unlock Now', 17, FontWeight.w600, color.txtBlue))
              ],
            ),
          ),
        ));
  });
}

Widget connectionAlert(BuildContext context){
  return  Consumer<SplashController>(builder: (context,val,child){return
    Visibility(
        visible: LocaleHandler.noInternet,
        child: Container(
          height:  MediaQuery.of(context).size.height,
          width:  MediaQuery.of(context).size.height,
          color: Colors.black54,
          child: AlertDialog(
            surfaceTintColor: Colors.red[200],
            backgroundColor: Colors.red[400],
            // title: buildText2('Slush is locked', 25, FontWeight.w600, color.txtBlack),
            content: buildText2('No Internet connection...', 18, FontWeight.w400, color.txtBlack),
          ),
        ));
  });
}

Widget permissionSpeeddateAlert(BuildContext context){
  return  Consumer<waitingRoom>(builder: (context,val,child){return
    Visibility(
        visible: LocaleHandler.speeddatePermission,
        child: Container(
          height:  MediaQuery.of(context).size.height,
          width:  MediaQuery.of(context).size.height,
          color: Colors.black54,
          child: AlertDialog(
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.white,
            title: buildText2('Event is locked', 25, FontWeight.w600, color.txtBlack),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildText2('Please give permission for Event speed date of camera and microphone', 18, FontWeight.w400, color.txtBlack),
                const Divider(),
                TextButton(onPressed: () {
                  Provider.of<waitingRoom>(context,listen: false).changeValue();},
                    child: buildText('Go to settings', 17, FontWeight.w600, color.txtBlue))
              ],
            ),
          ),
        ));
  });
}

Widget Successdialog(){
  return Dialog(
    // backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), //this right here
    child: Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16)
      ),
      height: 300.0,
      width: 300.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Padding(
              padding:  EdgeInsets.only(top: 10),
              child: CircleAvatar(
                  radius: 25,backgroundColor: Colors.green, child: Icon(Icons.check,color: Colors.white,size: 35,))
          ),
           Padding(
            padding:  const EdgeInsets.only(top: 30.0),
            child: buildText("SUCCESS", 25, FontWeight.w600,  Colors.green)
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child:  buildText("Your payment was completed", 16,FontWeight.w500,Colors.green)
          ),
          const Padding(padding: EdgeInsets.only(top: 60.0)),
          GestureDetector(
            onTap: (){
              Get.back();
            },
            child: Container(
                height: 35,
                width: 200,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.green,borderRadius: BorderRadius.circular(25)),
                child:  buildText("Continue", 18,FontWeight.w500,Colors.white)
            ),
          )
        ],
      ),
    ),
  );
}

Widget Faildialog(){
  return Dialog(
    // backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), //this right here
    child: Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16)
      ),
      height: 300.0,
      width: 300.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Padding(
              padding:  EdgeInsets.only(top: 10),
              child: CircleAvatar(
                  radius: 25,backgroundColor: Colors.red, child: Icon(Icons.clear_outlined,color: Colors.white,size: 35,))
          ),
          Padding(
              padding:  const EdgeInsets.only(top: 30.0),
              child: buildText("ERROR!", 25, FontWeight.w600,  Colors.red)
          ),
          Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child:  buildText("We couldn't process your request!", 16,FontWeight.w500,Colors.red)
          ),
          const Padding(padding: EdgeInsets.only(top: 60.0)),
          GestureDetector(
            onTap: (){
              Get.back();
            },
            child: Container(
                height: 35,
                width: 200,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.red,borderRadius: BorderRadius.circular(25)),
                child:  buildText("Try again", 18,FontWeight.w500,Colors.white)
            ),
          )
        ],
      ),
    ),
  );
}