import 'dart:convert';

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
import 'package:slush/screens/login/login.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:http/http.dart'as http;
import 'package:slush/constants/image.dart';
import 'package:slush/widgets/app_bar.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:slush/widgets/toaster.dart';

class DeleteProfile extends StatefulWidget {
  const DeleteProfile({super.key});

  @override
  State<DeleteProfile> createState() => _DeleteProfileState();
}

class _DeleteProfileState extends State<DeleteProfile> {

  List deleteProfile = [
    "I met someone on Slush",
    "I'm not interested using",
    "I have a privacy concern",
    "Other"
  ];
  int selectedIndex= -1;
  bool button=false;
  String enableField="";
  TextEditingController passwordController = TextEditingController();
  String passwordErrorText="";
  bool password=true;
  FocusNode passwordFocus= FocusNode();

  Future deleteAccount(String reason) async
  {
    try {
      const url = ApiList.deleteProfile;
      var uri = Uri.parse(url);
      var response = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${LocaleHandler.accessToken}'
        },
        body: jsonEncode({
          'reason': reason,
          'password': passwordController.text
        }),
      );
      setState(() {
        LoaderOverlay.hide();
      });
      print('Status Code :::::${response.statusCode}');
      var data=jsonDecode(response.body);
      if (response.statusCode == 201) {
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
        });
        print('Account Deleted');
        Fluttertoast.showToast(msg: data["message"]);
        Get.offAll(() => LoginScreen());
      }
      else if (response.statusCode == 401) {
        showToastMsgTokenExpired();
      }
      else if(response.statusCode==400)
      {
        print('Incorrect Password :::::::::::::::::::::::::::::');
        Fluttertoast.showToast(msg:passwordController.text.trim()==""? data["message"][0]:data["message"]);
      }
      else {
        print(
            'Account Deletion Failed with Status Code ${response.statusCode}');
        Fluttertoast.showToast(msg: 'Something Went Wrong');
      }
    }
    catch(error)
    {
      print('Error ::::::::::::::::::: $error');
      Fluttertoast.showToast(msg: 'Something Went Wrong::');
    }
  }
  @override
  void initState() {
    passwordFocus.addListener(() {
      if(passwordFocus.hasFocus){
        enableField = "Enter password";
      }else{
        enableField = "";
      }
    });


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // backgroundColor: color.backGroundClr,
      appBar: commonBarWithTextleft(context, color.backGroundClr, "Delete Profile"),
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
                      buildText("We are sorry to see you go, We’d  like to know why you’re deleting your account as we may be able to help with common issues.",
                          16, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
                      const SizedBox(height: 30,),
                      Container(
                        padding: const EdgeInsets.only(left: 15,right: 15),
                        // height: selectedIndex == 3 ? 370 : 240,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: color.txtWhite,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                            padding: EdgeInsets.zero,
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
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          buildText(deleteProfile[index], 18, FontWeight.w500, color.txtBlack),
                                          selectedIndex==index?SvgPicture.asset(AssetsPics.checkbox) : SvgPicture.asset(AssetsPics.blankCheckbox),
                                        ],
                                      ),
                                    ),
                                  ),
                                  deleteProfile[index] == "Other" &&selectedIndex == 3 ?
                                   SizedBox(
                                   //  height: 110,
                                     child: TextFormField(
                                      maxLines: 3,
                                       style: const TextStyle(color: color.txtBlack,fontSize: 16,fontWeight: FontWeight.w500,fontFamily: FontFamily.hellix),
                                       keyboardType: TextInputType.multiline,
                                       decoration: InputDecoration(
                                         enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: color.textFieldColor),borderRadius: BorderRadius.circular(8)),
                                         focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: color.textFieldColor),borderRadius: BorderRadius.circular(8)),
                                         border: const OutlineInputBorder(),
                                           hintText: 'Enter your text here...',
                                         hintStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500,fontFamily: FontFamily.hellix,color: color.txtgrey2)
                                       ),
                                     ),
                                   )
                                  : const SizedBox(),
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
              if(button == false){}
              else{
                customPasswordDialogBox(context: context,
                    title: 'Confirm deletion of your account',
                    secontxt: "",
                    heading: "This action cannot be undone.",
                    btnTxt: "Delete",
                    img: AssetsPics.mailImg2,
                onTap: (){
                  LoaderOverlay.show(context);
                  deleteAccount(deleteProfile[selectedIndex]);
                }
                );
              }
            },),
          ))
        ],
      ),
    );
  }
  customPasswordDialogBox(
      {required BuildContext context,
        String? btnTxt,
        String ?img,
        String ?secontxt,
        required String title,
        required String heading,
        TextEditingController? controller,
        VoidCallback? onTapp=pressed,
        VoidCallback? onTap=pressed,
        bool? forAdvanceTap,
        bool obs=true
      }) {
    return showGeneralDialog(
        barrierLabel: "Label",
        transitionDuration: const Duration(milliseconds: 500),
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return GestureDetector(
            onTap: onTapp,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    width: MediaQuery.of(context).size.width/1.1,
                    padding: const EdgeInsets.only(bottom: 20,top: 20),
                    margin: const EdgeInsets.only(bottom: 25),
                    decoration: BoxDecoration(color: color.txtWhite,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          height: 80, width: 80,
                          child: SvgPicture.asset(img!),
                        ),
                        const SizedBox(height: 10),
                        buildText(title, 20, FontWeight.w600, color.txtBlack),
                        secontxt==""?const SizedBox():Text(secontxt!,
                          style: const TextStyle(
                            fontFamily: FontFamily.hellix,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: color.txtgrey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        buildText2(heading, 18, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
                        Padding(
                            padding: const EdgeInsets.only(left: 15,right: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 29),
                                Padding(
                                  padding: const EdgeInsets.only(left: 4,bottom: 2),
                                  child: buildText("Password", 16, FontWeight.w500,enableField == "Enter password"? color.txtBlue:color.txtgrey,fontFamily: FontFamily.hellix),
                                ),
                                buildContainer("Enter password","Enter password",
                                  passwordController,AutovalidateMode.onUserInteraction,passwordFocus,
                                  obs: password,
                                  press: (){
                                    setState(() {
                                      enableField = "Enter password";
                                    });
                                  },
                                  gesture: GestureDetector(
                                      onTap: (){
                                        setState(() {
                                          password=!password;
                                        });
                                      },
                                      child: Container(
                                          padding: const EdgeInsets.only(top: 5),
                                          height: 20,width: 30,
                                          alignment: Alignment.center,
                                          child: SvgPicture.asset(password?AssetsPics.eyeOff:AssetsPics.eyeOn))
                                  ),
                                ),
                                passwordErrorText == "" ? const SizedBox() : Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: buildText(passwordErrorText, 12.8, FontWeight.w500, Colors.red),
                                ),
                                const SizedBox(height: 15),
                                blue_button(context, btnTxt!,press: onTap)
                              ],
                            )),
              ]),
            ),
          ),
            ),
          );

        },
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
            position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(anim1),
            child: child,
          );}
    );
  }
  Widget buildContainer(String txt,String chktxt,
      TextEditingController controller,
      AutovalidateMode auto,FocusNode node,
      {FormFieldValidator<String>? validation,VoidCallback? press,GestureDetector? gesture,
        bool obs=true
      }) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        height: 56,
        width: MediaQuery.of(context).size.width,
        decoration:  BoxDecoration(color: color.txtWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color:enableField == chktxt? color.txtBlue:color.txtgrey, width:1)),
        child: TextFormField(
          textInputAction: TextInputAction.done,
          onTap: press,
          focusNode: node,
          controller: controller,
          // focusNode: loginFocus,
          obscureText: obs,
          obscuringCharacter: "X",
          cursorColor: color.txtBlue,
          autovalidateMode: auto,
          validator: validation,
          onChanged: (val) {},
          decoration: InputDecoration(
            errorStyle: const TextStyle(height: 0, fontSize: 12),
            border: InputBorder.none,
            hintText: txt,hintStyle: const TextStyle(fontFamily: FontFamily.hellix,fontSize: 16,fontWeight: FontWeight.w500,color: color.txtgrey2),
            contentPadding: const EdgeInsets.only(left: 20,right: 18,top: 15),
            suffixIcon: gesture,
          ),
        ),
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

