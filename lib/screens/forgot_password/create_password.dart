import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/loader.dart';
import 'package:slush/constants/localkeys.dart';
import 'package:slush/screens/login/login.dart';
import 'package:slush/widgets/app_bar.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:slush/widgets/toaster.dart';
import '../../widgets/blue_button.dart';
import '../../widgets/text_widget.dart';
import 'package:http/http.dart'as http;

class CreatePassword extends StatefulWidget {
  const CreatePassword({super.key});

  @override
  State<CreatePassword> createState() => _CreatePasswordState();
}

class _CreatePasswordState extends State<CreatePassword> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController confPasswordController = TextEditingController();
  FocusNode passwordFocus= FocusNode();
  FocusNode confirmPassFocus= FocusNode();
  String enableField="";
  String passwordErrorText="";
  bool password=true;
  bool cnfrmpassword=true;

  @override
  void initState() {
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

  Future createNewPassword()async{
    final url=ApiList.resetpassword;
    var uri=Uri.parse(url);
    var response=await http.post(uri,
    headers: <String,String>{'Content-Type': 'application/json'},
      body: jsonEncode({"confirmPassword": passwordController.text.trim(),
          "passwordResetToken": LocaleHandler.resetPasswordtoken,
          "password":  passwordController.text.trim()}));
var data =jsonDecode(response.body);
setState(() {LoaderOverlay.hide();});
    if(response.statusCode==201){
      customDialogBox(context: context,
          title: 'Successfully reset',
          secontxt: "",
          heading: "Your password has been reset. Please login to continue.",
          btnTxt: "Continue",
          img: AssetsPics.lockImg,onTap: (){
            Get.offAll(()=>LoginScreen());
          });}
    else if(response.statusCode==401){Fluttertoast.showToast(msg: data["message"]);}
    else{
      Fluttertoast.showToast(msg: "Server Error");
    }
  }

   goBack(){
    Get.back();
    Get.back();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        goBack();
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
          extendBodyBehindAppBar: true,
        // backgroundColor: color.backGroundClr,
        appBar: commonBar(context, Colors.transparent,press: () {
          goBack();
        },),
        body: Stack(
          children: [
            SizedBox(
              height: size.height,
              width: size.width,
              child: Image.asset(AssetsPics.background,fit: BoxFit.cover,),
            ),
            Padding(
              padding: EdgeInsets.only(left: 15,right: 15,top: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   SizedBox(height: 5.h),
                  buildText2("Create new password", 28, FontWeight.w600, color.txtBlack),
                  const SizedBox(height: 8),
                  buildText(LocaleText.createPassword, 16, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
                   SizedBox(height: 4.h),
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
                    child: buildText("Confirm New Password", 16, FontWeight.w500,enableField == "Enter cpassword"? color.txtBlue:color.txtgrey,fontFamily: FontFamily.hellix),
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
                  blue_button(context, 'Save new password',
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
                        LoaderOverlay.show(context);
                        passwordErrorText="";
                      });
                    createNewPassword();
                    }
                    else{
                      setState(() {
                        passwordErrorText="";
                      });
                      showToastMsg("The passwords do not match. Please try again.");
                    }
                    },
                  ),
                   SizedBox(height: 3.h)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget customTextField(
      {required String text,
        required String icon,
        VoidCallback? iconOnTap,
        GestureDetector? counter,
        bool obscureText = false,
        controller,
        validator,
        VoidCallback?onTap,
        TextInputType? keyboardType}) {
    return TextFormField(
      style: const TextStyle(color: color.txtgrey,fontSize: 16,fontWeight: FontWeight.w500,fontFamily: FontFamily.hellix),
      obscureText: obscureText,
      obscuringCharacter: "X",
      controller: controller,
      keyboardType: TextInputType.text,
      validator: validator,
      maxLength: 50,
      onChanged: (val) {},
      maxLines: 1,
      autofocus: false,
      decoration: InputDecoration(
        //contentPadding: EdgeInsets.symmetric(horizontal: 15,vertical: 20),
        isDense: true,
        hintText: text,
        counter: counter,
        hintStyle: const TextStyle(
            fontFamily: FontFamily.hellix,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: color.txtgrey),
        suffixIcon: GestureDetector(
          onTap: iconOnTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13.0),
            child: Image(
              image: AssetImage(icon.toString()),
              height: 8,
              width: 8,
            ),
          ),
        ) /*Icon(icon,color: AppColor.blackColor,)*/,
        errorMaxLines: 3,
        counterText: " ",
        filled: true,
        fillColor: Colors.white,
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(
            width: 1,
            color: Color(0xffE5E5E5),
          ),
        ),
        // disabledBorder: OutlineInputBorder(
        //   borderRadius: BorderRadius.all(Radius.circular(4)),
        //   borderSide: BorderSide(
        //     width: 1,
        //     color: Color(0xffE5E5E5),
        //   ),
        // ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(
            width: 1,
            color: Color(0xffE5E5E5),
          ),
        ),
        // border: OutlineInputBorder(
        //   borderRadius: BorderRadius.all(Radius.circular(4)),
        //   borderSide: BorderSide(
        //     width: 1,
        //   ),
        // ),
        errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(
              width: 1,
              //color: Colors.red,
            )),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(
            width: 1,
            color: Colors.red,
          ),
        ),
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
          style: const TextStyle(fontFamily: FontFamily.hellix, fontSize: 17),
          decoration: InputDecoration(
            errorStyle: const TextStyle(height: 0, fontSize: 12),
            border: InputBorder.none,
            hintText: txt,hintStyle: const TextStyle(fontFamily: FontFamily.hellix,fontSize: 16,fontWeight: FontWeight.w500,color: color.txtgrey2),
            contentPadding: const EdgeInsets.only(left: 20,right: 18,top: 13),
            suffixIcon: gesture,
          ),
        ),
      ),
    );
  }
}