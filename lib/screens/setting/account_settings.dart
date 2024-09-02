import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/prefs.dart';
import 'package:slush/screens/setting/change_slush_password.dart';
import 'package:slush/screens/setting/deactivate_profile.dart';
import 'package:slush/screens/setting/delete_profile.dart';
import 'package:slush/widgets/app_bar.dart';
import 'package:slush/widgets/text_widget.dart';

class AccountSettings extends StatefulWidget {
  const AccountSettings({super.key});

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  List<Notification> notificationSetting = [
    Notification(1, "Change password", "Update your account password"),
    Notification(2, "Biometric or face", "Enable Biometric/Face ID"),
    Notification(3, "Deactivate account", "Temporarily pause your account"),
    Notification(4, "Delete Account", "Permanently remove your account"),
  ];
  bool isSwitch = false;
  List<int> item = [];
  int selectedIndex = 0;

  @override
  void initState() {
    callFun();
    super.initState();
  }

  void callFun(){
    setState(() {
      isSwitch=LocaleHandler.bioAuth2=="true"?true:false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      // backgroundColor: color.backGroundClr,
      appBar: commonBarWithTextleft(
          context, color.backGroundClr, "Account Settings"),
      body: Stack(
        children: [
          SizedBox(height: size.height, width: size.width,
            child: Image.asset(AssetsPics.background, fit: BoxFit.cover)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                const SizedBox(height: 30),
                Container(
                  // height: 49.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: color.txtWhite),
                  child: ListView.builder(
                      shrinkWrap: true,
                      // physics: NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(0.0),
                      itemCount: notificationSetting.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                callNavigationFunction(index);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 20, top: 18, bottom: 16),
                                child: Container(
                                  color: Colors.transparent,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          buildText(notificationSetting[index].title, 18, FontWeight.w600, color.txtBlack),
                                          const SizedBox(height: 5),
                                          buildText(notificationSetting[index].subTitle,
                                              16, FontWeight.w500, color.txtgrey, fontFamily: FontFamily.hellix),
                                        ],
                                      ),
                                      notificationSetting[index].title == "Biometric or face" ?
                                          /* GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            isSwitch = !isSwitch;
                                          });
                                        },
                                        child: Container(
                                          height: 40,
                                          width: 58,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(50),
                                            // color: Colors.red
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                child: Stack(
                                                  children:[
                                                    Positioned(
                                                      child: Container(
                                                        margin:const EdgeInsets.only(top: 10,left: 10,bottom: 10),
                                                        height: 20,
                                                        width: 40,
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(50),
                                                          color: isSwitch ? color.example3 : color.txtgrey4,
                                                        ),
                                                      ),
                                                    )],
                                                ),
                                              ),
                                              // Thumb
                                              Positioned(
                                                left: isSwitch ? 30 : 6,
                                                top: 7,
                                                child: Container(
                                                  height: 25,
                                                  width: 25,
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey.withOpacity(0.9),
                                                        spreadRadius: 0,
                                                        blurRadius: 5,
                                                        offset: const Offset(0,0), // changes position of shadow
                                                      ),
                                                    ],
                                                    shape: BoxShape.circle,
                                                    color: isSwitch ? color.txtBlue : color.txtWhite,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ) */
                                          CustomAnimatedToggleSwitch<bool>(
                                              current: isSwitch,
                                              values: const [false, true],
                                              indicatorSize: const Size.square(26.0),
                                              animationDuration: const Duration(milliseconds: 200),
                                              animationCurve: Curves.linear,
                                              onChanged: (b) => setState(() => isSwitch = b),
                                              iconBuilder: (context, local, global) {return const SizedBox();},
                                              cursors: const ToggleCursors(defaultCursor: SystemMouseCursors.click,),
                                              onTap: (props) {
                                                setState(() {isSwitch = !isSwitch;});
                                                Preferences.setValue("BioAuth", isSwitch.toString());
                                                LocaleHandler.bioAuth2=isSwitch.toString();
                                              },
                                              iconsTappable: false,
                                              wrapperBuilder: (context, global, child) {
                                                return Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    Positioned(left: 10.0, right: 10.0, height: 17.0,
                                                        child: DecoratedBox(
                                                          decoration: BoxDecoration(
                                                            color: isSwitch ? color.example3 : Colors.black26,
                                                            borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                                                          ),
                                                        )),
                                                    child,
                                                  ],
                                                );
                                              },
                                              foregroundIndicatorBuilder: (context, global) {
                                                return SizedBox.fromSize(size: global.indicatorSize,
                                                  child: DecoratedBox(decoration: BoxDecoration(
                                                      color: isSwitch ? color.txtBlue : Colors.white,
                                                      borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                                                      boxShadow: const [
                                                        BoxShadow(color: Colors.black38, spreadRadius: 0.05, blurRadius: 1.1, offset: Offset(0.0, 0.8))],
                                                  ),),);},)
                                          : SvgPicture.asset(AssetsPics.rightArrow),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            index == notificationSetting.length - 1
                                ? const SizedBox()
                                : const Divider(
                                    height: 5,
                                    thickness: 1,
                                    indent: 20,
                                    endIndent: 20,
                                    color: color.example3,
                                  ),
                          ],
                        );
                      }),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void callNavigationFunction(int i) {
         if (i == 0) {Get.to(() => const ChangePassword());}
    else if (i == 1) {setState(() {isSwitch = !isSwitch;
         Preferences.setValue("BioAuth", isSwitch.toString());
         LocaleHandler.bioAuth2=isSwitch.toString();
         print(";-;-;-${LocaleHandler.bioAuth2}");
         });}
    else if (i == 2) {Get.to(() => const DeactivateProfile());}
    else if (i == 3) {Get.to(() => const DeleteProfile());}
    else {}
  }
}

class Notification {
  int Id;
  String title;
  String subTitle;

  Notification(this.Id, this.title, this.subTitle);
}
