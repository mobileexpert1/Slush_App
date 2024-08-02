import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart'as http;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/loader.dart';
import 'package:slush/constants/localkeys.dart';
import 'package:slush/screens/setting/settings_screen.dart';
import 'package:slush/widgets/app_bar.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:slush/widgets/toaster.dart';
import '../../widgets/blue_button.dart';
import '../../widgets/text_widget.dart';


class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confPasswordController = TextEditingController();
  FocusNode oldPasswordFocus= FocusNode();
  FocusNode passwordFocus= FocusNode();
  FocusNode confirmPassFocus= FocusNode();
  String enableField="";
  String passwordErrorText="";
  bool oldPassword=true;
  bool password=true;
  bool cnfrmpassword=true;

  @override
  void initState() {
    oldPasswordFocus.addListener(() {
      if(oldPasswordFocus.hasFocus){
        enableField = "Enter opassword";
      }else{
        enableField = "";
      }
    });
    passwordFocus.addListener(() {
      if(passwordFocus.hasFocus){
        enableField = "Enter password";
      }else{
        enableField = "";
      }
    });
    confirmPassFocus.addListener(() {
      if(confirmPassFocus.hasFocus){
        enableField="Enter cpassword";
      }else{
        enableField="";
      }
    });
    super.initState();
  }

  Future changePassword()async{
    try{
      const url=ApiList.changePassword;
      final uri=Uri.parse(url);
      var response =await http.post(uri,
        headers: {
          'Content-Type':'application/json',
          'Authorization':'Bearer ${LocaleHandler.accessToken}'
        },
        body: jsonEncode({
          'password':oldPasswordController.text,
          'newpassword':passwordController.text,
          'confirm_password':confPasswordController.text
        }),
      );
      setState(() {LoaderOverlay.hide();});
      if(response.statusCode==201)
      {
        print('Password Changed::::::::::::');
        Fluttertoast.showToast(msg: 'Password Changed');
        customDialogBox(context: context,
            title: 'Password changed',
            secontxt: "",
            heading: "Your password has been changed.",
            btnTxt: "Ok",onTap: (){
              // Get.off(SettingsScreen());
              Get.back();
              Get.back();
            },
            onTapp: (){},
            img: AssetsPics.mailImg2);
        // Get.offAll(LoginScreen());
      }
      else if(response.statusCode==400)
      {
        print('Incorrect Password - Failed With Status Code :${response.statusCode}');
        Fluttertoast.showToast(msg: 'Incorrect Password');
      }
      else if(response.statusCode==401)
      {
        showToastMsgTokenExpired();
      }
      else
      {
        print('Failed With Status Code :${response.statusCode}');
        Fluttertoast.showToast(msg: 'Something Went Wrong');
      }
    }
    catch(error)
    {
      print('Error::::::::::::::::$error');
      Fluttertoast.showToast(msg: 'Something Went Wrong-');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // backgroundColor: color.backGroundClr,
      appBar: commonBarWithTextleft(context, color.backGroundClr, "Change password"),
      body: Stack(
        children: [
          SizedBox(
            height: size.height,
            width: size.width,
            child: Image.asset(AssetsPics.background,fit: BoxFit.cover,),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 15,right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 29),
                Padding(
                  padding: const EdgeInsets.only(left: 4,bottom: 2),
                  child: buildText("Old Password", 16, FontWeight.w500,enableField == "Enter opassword"? color.txtBlue:color.txtgrey,fontFamily: FontFamily.hellix),
                ),
                buildContainer("Enter password","Enter opassword",
                  oldPasswordController,AutovalidateMode.onUserInteraction,oldPasswordFocus,
                  obs: oldPassword,
                  press: (){
                    setState(() {
                      enableField = "Enter opassword";
                    });
                  },
                  gesture: GestureDetector(
                      onTap: (){
                        setState(() {
                          oldPassword=!oldPassword;
                        });
                      },
                      child: Container(
                          padding: const EdgeInsets.only(top: 5),
                          height: 20,width: 30,
                          alignment: Alignment.center,
                          child: SvgPicture.asset(oldPassword?AssetsPics.eyeOff:AssetsPics.eyeOn))
                  ),
                ),
                passwordErrorText == "" ? const SizedBox() : Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: buildText(passwordErrorText, 12.8, FontWeight.w500, Colors.red),
                ),

                const SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.only(left: 4,bottom: 2),
                  child: buildText("New Password", 16, FontWeight.w500,enableField == "Enter password"? color.txtBlue:color.txtgrey,fontFamily: FontFamily.hellix),
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

                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 4,bottom: 2),
                  child: buildText("Confirm Password", 16, FontWeight.w500,enableField == "Enter cpassword"? color.txtBlue:color.txtgrey,fontFamily: FontFamily.hellix),
                ),
                buildContainer("Enter password","Enter cpassword",
                  confPasswordController,AutovalidateMode.onUserInteraction,confirmPassFocus,
                  obs: cnfrmpassword,
                  press: (){
                    setState(() {
                      enableField = "Enter cpassword";
                    });
                  },
                  gesture: GestureDetector(
                      onTap: (){
                        setState(() {
                          cnfrmpassword=!cnfrmpassword;
                        });
                      },
                      child: Container(
                          padding: const EdgeInsets.only(top: 5),
                          height: 20,width: 30,
                          alignment: Alignment.center,
                          child: SvgPicture.asset(cnfrmpassword?AssetsPics.eyeOff:AssetsPics.eyeOn))
                  ),
                ),
                const Expanded(child: SizedBox()),
                blue_button(context, 'Change',
                  press: () {
                    if(passwordController.text.trim()=="" || confPasswordController.text.trim()==""){
                      showToastMsg("Please Enter all fields");
                    }
                    else if(passwordController.text.length<8){
                      setState(() {
                        passwordErrorText="Password length should be 8 Characters";
                      });}
                    else if(!RegExp(LocaleKeysValidation.password).hasMatch(passwordController.text) ){
                      showToastMsg("Password is too weak!");
                      setState(() {
                        passwordErrorText="Your password must include at least one uppercase letter, one lowercase letter, one number, and one special character.";
                      });
                    }
                    else if(passwordController.text==confPasswordController.text) {
                      setState(() {
                        passwordErrorText="";
                        LoaderOverlay.show(context);
                      });
                      changePassword();
                    }
                    else{
                      setState(() {
                        passwordErrorText="";
                      });
                      showToastMsg("The passwords do not match. Please try again.");
                    }
                  },
                ),
                const SizedBox(height: 20,)
              ],
            ),
          ),
        ],
      ),
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
            border: Border.all(color:enableField == chktxt? color.txtBlue:color.txtWhite, width:1)),
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