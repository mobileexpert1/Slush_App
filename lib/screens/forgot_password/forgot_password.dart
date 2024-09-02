import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/loader.dart';
import 'package:slush/constants/localkeys.dart';
import 'package:slush/screens/forgot_password/otp_screen.dart';
import 'package:slush/widgets/app_bar.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:slush/widgets/toaster.dart';
import 'package:http/http.dart'as http;

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController loginController = TextEditingController();
  FocusNode emailNode=FocusNode();
  String enableField="";
  String passwordText="";
  @override
  void initState() {
    emailNode.addListener(() {
      if(emailNode.hasFocus){
        enableField = "Enter email";
      }else{
        enableField = "";
      }
    });
    // TODO: implement initState
    super.initState();
  }

  Future forgotPassword()async{
    final url=ApiList.forgotPassword;
    var uri=Uri.parse(url);
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {LoaderOverlay.show(context);});
        var response=await http.post(uri,
            headers: <String, String>{'Content-Type': 'application/json'},
            body: jsonEncode({"email": loginController.text})
        );
        var data =jsonDecode(response.body);
        setState(() {LoaderOverlay.hide();});
        if(response.statusCode==201){
          customDialogBox(context: context, title: 'Password link sent',
              secontxt: getInitials(loginController.text),
              heading: 'Please go to your email and click the\n link to reset your password.',
              // btnTxt: "Go back to login",
              btnTxt: "Go back to OTP screen",
              img: AssetsPics.mailImg,onTap: (){Get.back();
              // customDialogOTPBox(context,loginController.text.trim());
              showGeneralDialog(
                  context: context,
                  pageBuilder: (context, anim1, anim2) => TimerDialog(text:loginController.text.trim()),
                  barrierDismissible: false,
                  barrierLabel: '',
                  transitionDuration: Duration(milliseconds: 300),
                  transitionBuilder: (context, anim1, anim2, child) {
                    return FadeTransition(
                      opacity: anim1,
                      child: child,
                    );
                  });
              });
        }
        else if(response.statusCode==400){Fluttertoast.showToast(msg: data["message"]);}
        else{Fluttertoast.showToast(msg: "Servre Error");}
      }
    } on SocketException catch (_) {
      setState(() {LoaderOverlay.hide();});
      showToastMsg("No Interenet Connection...",clrbg: Colors.red,clrtxt: color.txtWhite);
    }
  }
  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      // backgroundColor: color.backGroundClr,
        appBar: commonBar(context,Colors.transparent),
      body: Stack(
        children: [
          SizedBox(
            height: size.height,
            width: size.width,
            child: Image.asset(AssetsPics.background,fit: BoxFit.cover,),
          ),
          Padding(
            padding:  EdgeInsets.only(left: 15,right: 15,top: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 SizedBox(height: 5.h),
                buildText2("Reset your password", 28, FontWeight.w600, color.txtBlack),
                const SizedBox(height: 8),
                buildText(LocaleText.pleaseprovide, 16, FontWeight.w500, color.txtBlack,fontFamily: FontFamily.hellix),
                 SizedBox(height: 4.h),
                Padding(
                  padding: const EdgeInsets.only(left: 4,bottom: 2),
                  child: buildText("Email", 16, FontWeight.w500,enableField == "Enter email"? color.txtBlue:color.txtgrey,fontFamily: FontFamily.hellix),
                ),
                buildContainer("Enter email",loginController,AutovalidateMode.onUserInteraction,emailNode,
                    press: (){
                      setState(() {
                        enableField = "Enter email";
                      });
                    },
                  gesture: GestureDetector(
                      child: Container(
                          padding: EdgeInsets.only(top: 5),
                          height: 20,width: 30,
                          alignment: Alignment.center,
                          child: SvgPicture.asset(AssetsPics.mailIcon))
                  ),
                ),
                const SizedBox(height: 10),
                const Expanded(child: SizedBox()),
                blue_button(context,"Continue",press: (){
                  if(loginController.text.trim()==""){
                    showToastMsg("Please enter your email");
                  }else if (!RegExp(LocaleKeysValidation.email).hasMatch(loginController.text.trim())){
                    showToastMsg("Please enter valid email!");
                  }else{
                    forgotPassword();
                  }
                }),
                 SizedBox(height: 3.h),
              ],
            ),),
        ],
      ),
    );
  }

  String getInitials(bank_account_name) {
    passwordText=loginController.text;
    int a =passwordText.lastIndexOf("@");
    passwordText= passwordText.substring(a-2);
    for(var i=0;i<a-2;i++){
      passwordText="*"+passwordText;
    }
    return passwordText;
  }

  Widget buildContainer(String txt,
      TextEditingController controller,
      AutovalidateMode auto,FocusNode node,
      {FormFieldValidator<String>? validation,VoidCallback? press,GestureDetector? gesture}) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        height: 56,
        width: MediaQuery.of(context).size.width,
        decoration:  BoxDecoration(color: color.txtWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color:enableField == txt? color.txtBlue:color.txtWhite, width:1)),
        child: TextFormField(
          textInputAction: TextInputAction.done,
          onTap: press,
          focusNode: node,
          controller: controller,
          // focusNode: loginFocus,
          obscureText: txt=="Enter password"?true:false,
          obscuringCharacter: "X",
          cursorColor: color.txtBlue,
          autovalidateMode: auto,
          validator: validation,
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
