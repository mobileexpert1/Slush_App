import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/localkeys.dart';
import 'package:slush/controller/create_account_controller.dart';
import 'package:slush/screens/login/login.dart';
import 'package:slush/widgets/app_bar.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:slush/widgets/toaster.dart';

class CreateNewAccount extends StatefulWidget {
  const CreateNewAccount({Key? key}) : super(key: key);

  @override
  State<CreateNewAccount> createState() => _CreateNewAccountState();
}

class _CreateNewAccountState extends State<CreateNewAccount> {
  TextEditingController emailController = TextEditingController();
  FocusNode emailNode = FocusNode();
  ValueNotifier<String> enableField = ValueNotifier<String>("");
  ValueNotifier<bool> button = ValueNotifier<bool>(false);
  TextEditingController passwordController = TextEditingController();
  TextEditingController confPasswordController = TextEditingController();
  FocusNode passwordFocus = FocusNode();
  FocusNode confirmPassFocus = FocusNode();
  ValueNotifier<bool> password = ValueNotifier<bool>(true);
  ValueNotifier<bool> cnfrmpassword = ValueNotifier<bool>(true);
  ValueNotifier<String> passwordErrorText = ValueNotifier<String>("");
  ValueNotifier<String> cpasswordErrorText = ValueNotifier<String>("");
  bool _keyboardvisible = false;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  void initState() {
    emailNode.addListener(() {
      if (emailNode.hasFocus) {
        enableField.value = "Enter email";
      } else {
        enableField.value = "";
      }
    });
    passwordFocus.addListener(() {
      if (passwordFocus.hasFocus) {
        enableField.value = "Enter password";
      } else {
        enableField.value = "";
      }
    });
    confirmPassFocus.addListener(() {
      if (confirmPassFocus.hasFocus) {
        enableField.value = "Enter cpassword";
      } else {
        enableField.value = "";
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final acccntrl = Provider.of<createAccountController>(context, listen: false);
    final size = MediaQuery.of(context).size;
    _keyboardvisible = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: commonBar(context, Colors.transparent),
      body: Stack(
        children: [
          SizedBox(
              height: size.height,
              width: size.width,
              child: Image.asset(AssetsPics.background, fit: BoxFit.cover)),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  buildText2(
                    "Create an account",
                    28,
                    FontWeight.w600,
                    color.txtBlack,
                  ),
                  const SizedBox(height: 8),
                  buildText(LocaleText.createNewAccount, 15, FontWeight.w500,
                      color.txtgrey,
                      fontFamily: FontFamily.hellix),
                  const SizedBox(height: 29),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: ValueListenableBuilder(
                      valueListenable: enableField,
                      builder: (context, value, child) {
                        return buildText(
                            "Email",
                            16,
                            FontWeight.w500,
                            enableField.value == "Enter email" ? color.txtBlue : color.txtgrey,
                            fontFamily: FontFamily.hellix);
                      },
                    ),
                  ),
                  buildContainer(
                    "Enter email",
                    emailController,
                    AutovalidateMode.onUserInteraction,
                    emailNode,
                    press: () {enableField.value = "Enter email";},
                    gesture: GestureDetector(
                        child: Container(padding: const EdgeInsets.only(top: 5),
                            height: 20, width: 30,
                            alignment: Alignment.center,
                            child: SvgPicture.asset(AssetsPics.mailIcon))),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2, top: 15),
                    child: ValueListenableBuilder(
                        valueListenable: enableField,
                        builder: (context, value, child) {
                          return buildText(
                              "Password", 16, FontWeight.w500,
                              enableField.value == "Enter password" ? color.txtBlue : color.txtgrey,
                              fontFamily: FontFamily.hellix);
                        }),
                  ),
                  ValueListenableBuilder(
                      valueListenable: password,
                      builder: (context, value, child) {
                        return buildContainerPass(
                          "Enter password",
                          "Enter password",
                          passwordController,
                          AutovalidateMode.onUserInteraction,
                          passwordFocus,
                          validation: (val) {
                            if (val == "") {passwordErrorText.value = "";}
                            else if (passwordController.text.length < 8) {
                              button.value = false;
                              passwordErrorText.value = "Password length should be 8 Characters";
                            } else if (!RegExp(LocaleKeysValidation.password).hasMatch(passwordController.text)) {
                              button.value = false;
                              passwordErrorText.value = "Your password must include at least one uppercase letter, one lowercase letter, one number, and one special character.";
                            } else if (passwordController.text == confPasswordController.text &&
                                !RegExp(LocaleKeysValidation.email).hasMatch(emailController.text) == false &&
                                emailController.text != "" && !RegExp(LocaleKeysValidation.password).hasMatch(passwordController.text) == false) {
                              button.value = true;
                              passwordErrorText.value = "";
                            } else {
                              button.value = false;
                              passwordErrorText.value = "";
                            }
                            return null;
                          },
                          obs: password.value,
                          press: () {
                            enableField.value = "Enter password";
                          },
                          gesture: GestureDetector(
                              onTap: () {
                                password.value = !password.value;
                              },
                              child: Container(
                                  padding: const EdgeInsets.only(top: 5),
                                  height: 20,
                                  width: 30,
                                  alignment: Alignment.center,
                                  child: SvgPicture.asset(password.value
                                      ? AssetsPics.eyeOff
                                      : AssetsPics.eyeOn))),
                        );
                      }),
                  const SizedBox(height: 5),
                  ValueListenableBuilder(
                      valueListenable: passwordErrorText,
                      builder: (context, value, child) {
                        return passwordErrorText.value == ""
                            ? const SizedBox()
                            : Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: buildText(passwordErrorText.value, 12.8,
                                    FontWeight.w500, Colors.red));
                      }),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2, top: 15),
                    child: ValueListenableBuilder(
                        valueListenable: enableField,
                        builder: (context, value, child) {
                          return buildText(
                              "Confirm Password",
                              16,
                              FontWeight.w500,
                              enableField.value == "Enter cpassword"
                                  ? color.txtBlue
                                  : color.txtgrey,
                              fontFamily: FontFamily.hellix);
                        }),
                  ),
                  ValueListenableBuilder(
                      valueListenable: cnfrmpassword,
                      builder: (context, value, child) {
                        return buildContainerPass(
                          "Enter password",
                          "Enter cpassword",
                          confPasswordController,
                          AutovalidateMode.onUserInteraction,
                          confirmPassFocus,
                          obs: cnfrmpassword.value,
                          validation: (val) {
                            if (confPasswordController.text == "") {
                              button.value = false;
                              cpasswordErrorText.value = "";
                            } else if (passwordController.text ==
                                confPasswordController.text) {
                              if (!RegExp(LocaleKeysValidation.email)
                                          .hasMatch(emailController.text) ==
                                      false &&
                                  emailController.text != "" &&
                                  !RegExp(LocaleKeysValidation.password)
                                          .hasMatch(passwordController.text) ==
                                      false) {
                                button.value = true;
                              } else {
                                button.value = false;
                              }
                              cpasswordErrorText.value = "";
                            } else {
                              button.value = false;
                              cpasswordErrorText.value =
                                  "The passwords do not match. Please try again.";
                            }
                            return null;
                          },
                          press: () {
                            enableField.value = "Enter cpassword";
                          },
                          gesture: GestureDetector(
                              onTap: () {
                                cnfrmpassword.value = !cnfrmpassword.value;
                              },
                              child: Container(
                                  padding: const EdgeInsets.only(top: 5),
                                  height: 20,
                                  width: 30,
                                  alignment: Alignment.center,
                                  child: SvgPicture.asset(cnfrmpassword.value
                                      ? AssetsPics.eyeOff
                                      : AssetsPics.eyeOn))),
                        );
                      }),
                  ValueListenableBuilder(
                      valueListenable: cpasswordErrorText,
                      builder: (context, value, child) {
                        return cpasswordErrorText.value == ""
                            ? const SizedBox()
                            : Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: buildText(cpasswordErrorText.value, 12.8,
                                    FontWeight.w500, Colors.red),
                              );
                      }),
                  const SizedBox(height: 25),
                  ValueListenableBuilder(
                      valueListenable: button,
                      builder: (context, value, child) {
                        return blue_button(context, "Continue",
                            validation: button.value,
                            clr: Colors.grey, press: () async {
                          if (emailController.text.trim() == "") {
                            showToastMsg("Please Enter email");
                          } else if (!RegExp(LocaleKeysValidation.email).hasMatch(emailController.text)) {
                            showToastMsg("Please enter valid email!");
                          } else {
                            if (button.value) {
                              emailNode.unfocus();
                              FocusManager.instance.primaryFocus?.unfocus();
                              // registerUser();
                              acccntrl.registerUser(context, emailController.text.trim(), passwordController.text.trim());
                            } else if (cpasswordErrorText.value == "" && passwordErrorText.value == "") {
                              showToastMsg("All fields are mandatory");
                            }
                          }
                        });
                      }),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildColorContainer(color.example2, color.example),
                      Container(
                        margin:
                            const EdgeInsets.only(left: 7, right: 7, bottom: 2),
                        child: buildText("or continue with", 16,
                            FontWeight.w500, color.txtBlack,
                            fontFamily: FontFamily.hellix),
                      ),
                      buildColorContainer(color.example, color.example2)
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildCircleAvatar(AssetsPics.facebook, () {
                        acccntrl.loginWithFacebook(context);
                      }),
                      const SizedBox(width: 15),
                      buildCircleAvatar(AssetsPics.google, () {
                        acccntrl.signInWithGoogle(context, googleSignIn);
                      }),
                      Platform.isAndroid
                          ? const SizedBox()
                          : const SizedBox(width: 15),
                      Platform.isAndroid
                          ? const SizedBox()
                          : buildCircleAvatar(AssetsPics.apple, () {
                              acccntrl.signInWithApple(context);
                            }),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildTextSpan2(
                            'Already have an account? ', color.txtgrey),
                        GestureDetector(
                            onTap: () {
                              Get.off(() => const LoginScreen());
                            },
                            child: buildTextSpan2('Sign in', color.txtBlue)),
                      ],
                    ),
                  ),
                  SizedBox(height: _keyboardvisible ? 200 : 25)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildContainer(String txt, TextEditingController controller,
      AutovalidateMode auto, FocusNode node,
      {FormFieldValidator<String>? validation,
      VoidCallback? press,
      GestureDetector? gesture}) {
    return Align(
      alignment: Alignment.center,
      child: ValueListenableBuilder(
          valueListenable: enableField,
          builder: (context, value, child) {
            return Container(
              height: 56,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: color.txtWhite,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: enableField.value == txt
                          ? color.txtBlue
                          : color.txtWhite,
                      width: 1)),
              child: TextFormField(
                textInputAction: TextInputAction.done,
                onTap: press,
                focusNode: node,
                controller: controller,
                cursorColor: color.txtBlue,
                autovalidateMode: auto,
                validator: validation,
                onChanged: (val) {
                  if (passwordController.text == confPasswordController.text &&
                      !RegExp(LocaleKeysValidation.email)
                              .hasMatch(emailController.text) ==
                          false &&
                      emailController.text != "" &&
                      !RegExp(LocaleKeysValidation.password)
                              .hasMatch(passwordController.text) ==
                          false) {
                    button.value = true;
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
                  contentPadding:
                      const EdgeInsets.only(left: 20, right: 18, top: 13),
                  suffixIcon: gesture,
                ),
              ),
            );
          }),
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
      ),
    );
  }

  Widget buildTextSpan2(String txt, Color clr) {
    return Text(txt,
        style: TextStyle(
            color: clr,
            fontWeight: FontWeight.w500,
            fontSize: 16,
            fontFamily: FontFamily.hellix));
  }

  Widget buildContainerPass(String txt, String chktxt,
      TextEditingController controller, AutovalidateMode auto, FocusNode node,
      {FormFieldValidator<String>? validation,
      VoidCallback? press,
      GestureDetector? gesture,
      bool obs = true}) {
    return Align(
      alignment: Alignment.center,
      child: ValueListenableBuilder(
          valueListenable: enableField,
          builder: (context, value, child) {
            return Container(
              height: 56,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: color.txtWhite,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: enableField.value == chktxt
                          ? color.txtBlue
                          : color.txtWhite,
                      width: 1)),
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
                // validator: validation,
                onChanged: validation,
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
                  contentPadding:
                      const EdgeInsets.only(left: 20, right: 18, top: 13),
                  suffixIcon: gesture,
                ),
              ),
            );
          }),
    );
  }
}
