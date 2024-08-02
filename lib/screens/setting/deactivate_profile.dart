import 'dart:convert';
import 'package:http/http.dart'as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/loader.dart';
import 'package:slush/constants/prefs.dart';
import 'package:slush/screens/getstarted/slider_scree.dart';
import 'package:slush/screens/setting/account_suspended.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/widgets/app_bar.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:slush/widgets/toaster.dart';

class DeactivateProfile extends StatefulWidget {
  const DeactivateProfile({super.key});

  @override
  State<DeactivateProfile> createState() => _DeactivateProfileState();
}

class _DeactivateProfileState extends State<DeactivateProfile> {

  List deleteProfile = [
    "Trouble getting started",
    "Concerned about my data",
    "Too busy",
    "Can’t find people"
  ];
  int selectedIndex= -1;
  bool button=false;

  Future deactivateAccount(String reason)async
  {
    const url=ApiList.deactivateAccount;
    var uri=Uri.parse(url);
    var response=await http.post(uri,
      headers: {
        'Content-Type':'application/json',
        'Authorization':'Bearer ${LocaleHandler.accessToken}'
      },
      body: jsonEncode({
        'reason':reason
      }),
    );
    print('Status Code :::::${response.statusCode}');
    setState(() {
      LoaderOverlay.hide();
    });
    if(response.statusCode==201)
    {
      setState(() {
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

        // Preferences.setToken(LocaleHandler.bearer='');
      });
      print('Account Deactivated');
      Fluttertoast.showToast(msg: 'Account Deactivated');
      // Get.offAll(() => AccountSuspended());
      Get.offAll(() => const SliderScreen());
    }else if(response.statusCode==401){showToastMsgTokenExpired();}
    else
    {print('Account Deactivation Failed with Status Code ${response.statusCode}');
      Fluttertoast.showToast(msg: 'Something Went Wrong');}
  }

  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // backgroundColor: color.backGroundClr,
      appBar: commonBarWithTextleft(context, color.backGroundClr, "Deactivate Profile"),
      body: Stack(
        children: [
          SizedBox(
            height: size.height,
            width: size.width,
            child: Image.asset(AssetsPics.background,fit: BoxFit.cover,),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20,right: 20,top: 30,bottom: 20),
                  child: Column(
                    children: [
                      buildText("Deactivating your slush account is temporary, and it means that your profile will be hidden on Slush until you reactivate it through logging in to your Slush Account",
                          16, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
                      const SizedBox(height: 30,),
                      Container(
                        padding: const EdgeInsets.only(left: 15,right: 15),
                        // height: 240,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: color.txtWhite,
                        ),
                        child: ListView.builder(
                            shrinkWrap: true,
                            // physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.all(0.0),
                            itemCount: deleteProfile.length,
                            itemBuilder: (context,index){
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 15,bottom: 15),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedIndex = index;
                                          button = true;
                                        });
                                      },
                                      child: Container(
                                        color: Colors.transparent,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            buildText(deleteProfile[index], 18, FontWeight.w500, color.txtBlack),
                                            selectedIndex==index?SvgPicture.asset(AssetsPics.checkbox) : SvgPicture.asset(AssetsPics.blankCheckbox),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  index == deleteProfile.length -1 ? const SizedBox() : const Divider(
                                    height: 5,
                                    thickness: 1,
                                    color: color.example3,
                                  ),

                                ],
                              );
                            }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.only(bottom:defaultTargetPlatform==TargetPlatform.iOS? 20:0),
                padding: const EdgeInsets.only(left: 15,right: 15,bottom: 15),
                child: blue_button(context, "Next",validation: button,press:
                    () {
                  setState(() {
                    LoaderOverlay.show(context);
                  });
                      deactivateAccount(deleteProfile[selectedIndex]);
                  // Get.offAll(()=>AccountSuspended());
                },),
              ))
        ],
      ),
    );
  }

}
class Settings{
  String img;
  String settingsType;
  String img2;
  Settings(  this.img , this.settingsType, this.img2);
}