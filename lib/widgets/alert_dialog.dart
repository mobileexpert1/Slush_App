

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
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
                Divider(),
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