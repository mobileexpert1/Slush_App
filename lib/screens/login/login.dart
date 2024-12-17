import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/localkeys.dart';
import 'package:slush/controller/login_controller.dart';
import 'package:slush/screens/forgot_password/forgot_password.dart';
import 'package:slush/screens/sign_up/create_account.dart';
import 'package:slush/widgets/app_bar.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController loginController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  FocusNode loginFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  ValueNotifier<String> enableField = ValueNotifier<String>("");
  ValueNotifier<bool> password = ValueNotifier<bool>(true);
  ValueNotifier<bool> button = ValueNotifier<bool>(false);

  @override
  void initState() {
    loginFocus.addListener(() {
      if (loginFocus.hasFocus) {enableField.value = "Enter email";}
      else {enableField.value = "";}
    });
    passwordFocus.addListener(() {
      if (passwordFocus.hasFocus) {enableField.value = "Enter password";}
      else {enableField.value = "";}
    });
    super.initState();
  }

  Future sentEmailToverify() async {
    const url = ApiList.sendverifyemail;
    var uri = Uri.parse(url);
    var response = await http.post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
          "Authorization": LocaleHandler.bearer
        },
        body: jsonEncode({"email": loginController.text}));
    var data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      Fluttertoast.showToast(msg: data["message"]);
    } else if (response.statusCode == 401) {
      Fluttertoast.showToast(msg: "Invalid Email");
    } else {
      Fluttertoast.showToast(msg: "Server Error");
    }
    print(response.statusCode);
  }

  final GoogleSignIn googleSignIn = GoogleSignIn();

  // final facebookLogin = FacebookLogin();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final lgincntrl = Provider.of<loginControllerr>(context, listen: false);
    return PopScope(
      canPop: false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        // backgroundColor: color.backGroundClr,
        appBar: commonBar(context, Colors.transparent),
        body: Stack(
          children: [
            SizedBox(
              height: size.height,
              width: size.width,
              child: Image.asset(AssetsPics.background, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 80),
              child: SingleChildScrollView(
                child: Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5.h),
                      buildText2("Welcome Back", 28, FontWeight.w600, color.txtBlack),
                      const SizedBox(height: 8),
                      buildText(
                          LocaleText.signIn, 16, FontWeight.w500, Colors.black,
                          fontFamily: FontFamily.hellix),
                      SizedBox(height: 4.h),
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 2),
                        child: ValueListenableBuilder(valueListenable: enableField, builder: (context,value,child){
                          return buildText("Email", 16, FontWeight.w500,
                              enableField.value == "Enter email" ? color.txtBlue : color.txtgrey,
                              fontFamily: FontFamily.hellix);
                        }),
                      ),
                      buildContainer("Enter email", loginController,
                        AutovalidateMode.onUserInteraction, loginFocus,
                        press: () {enableField.value = "Enter email";},
                        gesture: GestureDetector(
                            child: Container(
                                padding: const EdgeInsets.only(top: 5),
                                height: 20,
                                width: 30,
                                alignment: Alignment.center,
                                child: SvgPicture.asset(AssetsPics.mailIcon))),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 2),
                        child:ValueListenableBuilder(valueListenable: enableField, builder: (context,value,child){return
                          buildText(
                              "Password", 16, FontWeight.w500,
                              enableField.value == "Enter password" ? color.txtBlue : color.txtgrey,
                              fontFamily: FontFamily.hellix);}),
                      ),

                      ValueListenableBuilder(valueListenable: password, builder: (context,value,child){return
                        buildContainer(
                          "Enter password",
                          passwordController,
                          AutovalidateMode.onUserInteraction,
                          passwordFocus,
                          obs: password.value,
                          press: () {enableField.value = "Enter password";},
                          gesture: GestureDetector(
                              onTap: () {password.value = !password.value;},
                              child: Container(
                                  padding: const EdgeInsets.only(top: 5),
                                  height: 20,
                                  width: 30,
                                  alignment: Alignment.center,
                                  child: SvgPicture.asset(password.value ? AssetsPics.eyeOff : AssetsPics.eyeOn))),
                        );
                      }),
                      Container(
                          padding: const EdgeInsets.only(top: 15),
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                              onTap: () {
                                Get.to(() => const ForgotPassword());
                              },
                              child: buildText2("Forgot password ?", 16,
                                  FontWeight.w500, color.txtBlack,
                                  fontFamily: FontFamily.hellix))),
                      const SizedBox(height: 30),
                      ValueListenableBuilder(valueListenable: button, builder: (context,value,child){return
                        blue_button(context, "Login", validation: button.value,
                            press: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              if (button.value == true) {
                                LocaleHandler.isThereAnyEvent = false;
                                LocaleHandler.isThereCancelEvent = false;
                                LocaleHandler.unMatchedEvent = false;
                                LocaleHandler.subScribtioonOffer = false;
                                lgincntrl.loginUser(context, loginController.text.trim(), passwordController.text.trim());
                              }
                            });}),
                      SizedBox(height: 5.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildColorContainer(color.example2, color.example),
                          Container(
                              margin: const EdgeInsets.only(left: 7, right: 7, bottom: 2),
                              child: buildText("or continue with", 16, FontWeight.w500, color.txtBlack, fontFamily: FontFamily.hellix)),
                          buildColorContainer(color.example, color.example2)
                        ],
                      ),
                      const SizedBox(height: 35),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildCircleAvatar(AssetsPics.facebook, () {
                            lgincntrl.loginWithFacebook(context);
                          }),
                          const SizedBox(width: 15),
                          buildCircleAvatar(AssetsPics.google, () {
                            lgincntrl.signInWithGoogle(context,googleSignIn);
                          }),
                          Platform.isAndroid?const SizedBox(): const SizedBox(width: 15),
                          Platform.isAndroid?const SizedBox(): buildCircleAvatar(AssetsPics.apple, () {lgincntrl.signInWithApple(context);}),
                        ],
                      ),
                      SizedBox(height: 5.h),
                      Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildTextSpan2('New user? ', color.txtgrey),
                            GestureDetector(
                                onTap: () {Get.off(() => const CreateNewAccount());},
                                child: buildTextSpan2('Create Account', color.txtBlue)),
                          ],
                        ),
                      ),
                      // buildText("version:1.0(16)", 12, FontWeight.w500, color.txtBlack)
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildColorContainer(Color clr1, Color clr2) {
    return Expanded(
      child: Container(
        // width: 100,
        height: 4,
        decoration:
        BoxDecoration(gradient: LinearGradient(colors: [clr1, clr2])),
      ),
    );
  }

  Widget buildCircleAvatar(String img, onTap) {
    return GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          radius: 25,
          backgroundColor: color.txtWhite,
          child: Image.asset(img, height: 23),
        ));
  }

  Widget buildTextSpan2(String txt, Color clr) {
    return Text(txt,
        style: TextStyle(
            color: clr,
            fontWeight: FontWeight.w500,
            fontSize: 16,
            fontFamily: FontFamily.hellix));
  }

  Widget buildContainer(String txt, TextEditingController controller,
      AutovalidateMode auto, FocusNode node,
      {FormFieldValidator<String>? validation,
        VoidCallback? press,
        GestureDetector? gesture,
        bool obs = false}) {
    return Align(
      alignment: Alignment.center,
      child:ValueListenableBuilder(valueListenable: enableField, builder: (context,value,child){return
        Container(
          padding: const EdgeInsets.only(left: 20),
          height: 56,
          // height: MediaQuery.of(context).size.height*0.07+1,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: color.txtWhite,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: enableField.value == txt ? color.txtBlue : color.txtWhite, width: 1)),
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
            onChanged: (val) {
                if (_form.currentState!.validate()) {
                  if (passwordController.text.isNotEmpty && RegExp(LocaleKeysValidation.email).hasMatch(loginController.text)) {button.value = true;}
                  else{button.value = false;}
                } else {
                  button.value = false;
                }
            },
            style: const TextStyle(fontFamily: FontFamily.hellix, fontSize: 17),
            decoration: InputDecoration(
              errorStyle: const TextStyle(height: 0, fontSize: 12),
              border: InputBorder.none,
              hintText: txt,
              hintStyle: const TextStyle(
                  fontFamily: FontFamily.hellix,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color.txtgrey2),
              contentPadding: const EdgeInsets.only(right: 18, top: 13),
              suffixIcon: gesture,
            ),
          ),
        );}),
    );
  }
}

