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
  String enableField = "";
  bool button = false;

  TextEditingController passwordController = TextEditingController();
  TextEditingController confPasswordController = TextEditingController();
  FocusNode passwordFocus = FocusNode();
  FocusNode confirmPassFocus = FocusNode();

  bool password = true;
  bool cnfrmpassword = true;
  String passwordErrorText = "";
  String cpasswordErrorText = "";
  bool _keyboardvisible = false;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  void initState() {
    emailNode.addListener(() {
      if (emailNode.hasFocus) {enableField = "Enter email";} else {enableField = "";}
    });
    passwordFocus.addListener(() {
      if (passwordFocus.hasFocus) {enableField = "Enter password";} else {enableField = "";}
    });
    confirmPassFocus.addListener(() {
      if (confirmPassFocus.hasFocus) {enableField = "Enter cpassword";} else {enableField = "";}
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final acccntrl=Provider.of<createAccountController>(context,listen: false);
    final size = MediaQuery.of(context).size;
    _keyboardvisible = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: commonBar(context, Colors.transparent),
      body: Stack(
        children: [
          SizedBox(height: size.height, width: size.width, child: Image.asset(AssetsPics.background, fit: BoxFit.cover)),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  buildText2("Create an account", 28, FontWeight.w600, color.txtBlack,),
                  const SizedBox(height: 8),
                  buildText(LocaleText.createNewAccount, 15, FontWeight.w500, color.txtgrey, fontFamily: FontFamily.hellix),
                  const SizedBox(height: 29),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: buildText(
                        "Email", 16,
                        FontWeight.w500,
                        enableField == "Enter email" ? color.txtBlue : color.txtgrey,
                        fontFamily: FontFamily.hellix),
                  ),
                  buildContainer(
                    "Enter email",
                    emailController,
                    AutovalidateMode.onUserInteraction,
                    emailNode,
                    press: () {
                      // acccntrl.emailFieldText("Enter email");
                      setState(() {enableField = "Enter email";});
                    },
                    gesture: GestureDetector(
                        child: Container(
                            padding: const EdgeInsets.only(top: 5),
                            height: 20,
                            width: 30,
                            alignment: Alignment.center,
                            child: SvgPicture.asset(AssetsPics.mailIcon))),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2, top: 15),
                    child: buildText("Password", 16, FontWeight.w500,
                        enableField == "Enter password" ? color.txtBlue : color.txtgrey,
                        fontFamily: FontFamily.hellix),
                  ),
                  buildContainerPass(
                    "Enter password",
                    "Enter password",
                    passwordController,
                    AutovalidateMode.onUserInteraction,
                    passwordFocus,
                    validation: (val) {
                      if (val == "") {
                        setState(() {passwordErrorText = "";});
                      } else if (passwordController.text.length < 8) {
                        setState(() {
                          button = false;
                          passwordErrorText = "Password length should be 8 Characters";
                        });
                      } else if (!RegExp(LocaleKeysValidation.password).hasMatch(passwordController.text)) {
                        setState(() {
                          button = false;
                          passwordErrorText = "At least 1 Upper,Lower,Num and Special Character";
                        });
                      } else if (passwordController.text == confPasswordController.text &&
                          !RegExp(LocaleKeysValidation.email).hasMatch(emailController.text) == false &&
                          emailController.text != "" &&
                          !RegExp(LocaleKeysValidation.password).hasMatch(passwordController.text) == false) {
                        setState(() {
                          button = true;
                          passwordErrorText = "";
                        });
                      } else {
                        setState(() {
                          button = false;
                          passwordErrorText = "";
                        });
                      }
                      return null;
                    },
                    obs: password,
                    press: () {
                      setState(() {
                        enableField = "Enter password";
                      });
                    },
                    gesture: GestureDetector(
                        onTap: () {
                          setState(() {
                            password = !password;
                          });
                        },
                        child: Container(
                            padding: const EdgeInsets.only(top: 5),
                            height: 20,
                            width: 30,
                            alignment: Alignment.center,
                            child: SvgPicture.asset(password ? AssetsPics.eyeOff : AssetsPics.eyeOn))),
                  ),
                  const SizedBox(height: 5),
                  passwordErrorText == "" ? const SizedBox()
                      : Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: buildText(passwordErrorText, 12.8, FontWeight.w500, Colors.red)),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2, top: 15),
                    child: buildText("Confirm Password", 16, FontWeight.w500,
                        enableField == "Enter cpassword" ? color.txtBlue : color.txtgrey,
                        fontFamily: FontFamily.hellix),
                  ),
                  buildContainerPass(
                    "Enter password",
                    "Enter cpassword",
                    confPasswordController,
                    AutovalidateMode.onUserInteraction,
                    confirmPassFocus,
                    obs: cnfrmpassword,
                    validation: (val) {
                      if (confPasswordController.text == "") {
                        setState(() {
                          button = false;
                          cpasswordErrorText = "";
                        });
                      } else if (passwordController.text ==
                          confPasswordController.text) {
                        if (!RegExp(LocaleKeysValidation.email).hasMatch(emailController.text) == false &&
                            emailController.text != "" &&
                            !RegExp(LocaleKeysValidation.password).hasMatch(passwordController.text) == false) {
                          setState(() {
                            button = true;
                          });
                        } else {
                          button = false;
                        }
                        setState(() {
                          cpasswordErrorText = "";
                          // button = false;
                        });
                      } else {
                        setState(() {
                          button = false;
                          cpasswordErrorText = "Confirm Password Mismatched!";
                        });
                      }
                      return null;
                    },
                    press: () {
                      setState(() {
                        enableField = "Enter cpassword";
                      });
                    },
                    gesture: GestureDetector(
                        onTap: () {
                          setState(() {
                            cnfrmpassword = !cnfrmpassword;
                          });
                        },
                        child: Container(
                            padding: const EdgeInsets.only(top: 5),
                            height: 20,
                            width: 30,
                            alignment: Alignment.center,
                            child: SvgPicture.asset(cnfrmpassword ? AssetsPics.eyeOff : AssetsPics.eyeOn))),
                  ),
                  cpasswordErrorText == "" ? const SizedBox()
                      : Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: buildText(cpasswordErrorText, 12.8, FontWeight.w500, Colors.red),
                        ),
                  const SizedBox(height: 25),
                  blue_button(context, "Continue", validation: button,clr: Colors.grey,
                      press: () async {
                    if (emailController.text.trim() == "") {showToastMsg("Please Enter email");}
                    else if (!RegExp(LocaleKeysValidation.email).hasMatch(emailController.text)) {
                      showToastMsg("Please enter valid email!");}
                    else {
                      if (button) {
                        emailNode.unfocus();
                        FocusManager.instance.primaryFocus?.unfocus();
                        // registerUser();
                        acccntrl.registerUser(context, emailController.text.trim(), passwordController.text.trim());
                      } else if (cpasswordErrorText == "" && passwordErrorText == "") {
                        showToastMsg("All fields are mandatory");
                      }
                    }
                  }),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildColorContainer(color.example2, color.example),
                      Container(
                        margin: const EdgeInsets.only(left: 7, right: 7, bottom: 2),
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
                      buildCircleAvatar(AssetsPics.facebook,(){acccntrl.loginWithFacebook();}),
                      const SizedBox(width: 15),
                      buildCircleAvatar(AssetsPics.google,(){acccntrl.signInWithGoogle(googleSignIn);}),
                      const SizedBox(width: 15),
                      buildCircleAvatar(AssetsPics.apple,(){}),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildTextSpan2('Already have an account? ', color.txtgrey),
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
      child: Container(
        height: 56,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: color.txtWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: enableField == txt ? color.txtBlue : color.txtWhite,
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
            setState(() {
              if (passwordController.text == confPasswordController.text &&
                  !RegExp(LocaleKeysValidation.email).hasMatch(emailController.text) == false &&
                  emailController.text != "" && !RegExp(LocaleKeysValidation.password).hasMatch(passwordController.text) == false) {
                button = true;
              } else {
                button = false;
              }
            });
          },
          decoration: InputDecoration(
            errorStyle: const TextStyle(height: 0, fontSize: 12),
            border: InputBorder.none,
            hintText: txt,
            hintStyle: const TextStyle(
                fontFamily: FontFamily.hellix,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color.txtgrey2),
            contentPadding: const EdgeInsets.only(left: 20, right: 18, top: 13),
            suffixIcon: gesture,
          ),
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

  Widget buildCircleAvatar(String img,onTap) {
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
      child: Container(
        height: 56,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: color.txtWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: enableField == chktxt ? color.txtBlue : color.txtWhite,
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
          decoration: InputDecoration(
            errorStyle: const TextStyle(height: 0, fontSize: 12),
            border: InputBorder.none,
            hintText: txt,
            hintStyle: const TextStyle(
                fontFamily: FontFamily.hellix,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color.txtgrey2),
            contentPadding: const EdgeInsets.only(left: 20, right: 18, top: 13),
            suffixIcon: gesture,
          ),
        ),
      ),
    );
  }
}


/*
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/loader.dart';
import 'package:slush/constants/localkeys.dart';
import 'package:slush/constants/prefs.dart';
import 'package:slush/screens/events/bottomNavigation.dart';
import 'package:slush/screens/login/login.dart';
import 'package:slush/screens/sign_up/details.dart';
import 'package:slush/widgets/app_bar.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/bottom_sheet.dart';
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
  String enableField = "";
  bool button = false;
  String emailText = "";

  TextEditingController passwordController = TextEditingController();
  TextEditingController confPasswordController = TextEditingController();
  FocusNode passwordFocus = FocusNode();
  FocusNode confirmPassFocus = FocusNode();

  // String enableField="";
  bool password = true;
  bool cnfrmpassword = true;
  String passwordErrorText = "";
  String cpasswordErrorText = "";
  bool _keyboardvisible=false;

  @override
  void initState() {
    emailNode.addListener(() {
      if (emailNode.hasFocus) {
        enableField = "Enter email";
      } else {
        enableField = "";
      }
    });

    passwordFocus.addListener(() {
      if (passwordFocus.hasFocus) {
        enableField = "Enter password";
      } else {
        enableField = "";
      }
    });
    confirmPassFocus.addListener(() {
      if (confirmPassFocus.hasFocus) {
        enableField = "Enter cpassword";
      } else {
        enableField = "";
      }
    });
    super.initState();
  }

  String getInitials(bankaccountname) {
    emailText = emailController.text;
    int a = emailText.lastIndexOf("@");
    emailText = emailText.substring(a - 2);
    for (var i = 0; i < a - 2; i++) {
      emailText = "*" + emailText;
    }
    return emailText;
  }

  void bottomsheett() {
    customDialogBox(
        context: context,
        title: 'Confirm your email',
        secontxt:
            "We have sent a confirmation email  to:  ${getInitials(emailController.text)}",
        heading:
            'Please check your email and click on the confirmation link to continue.',
        btnTxt: "Go to email",
        img: AssetsPics.mailImg2,
        onTap: () async {
          if (LocaleHandler.emailVerified == "true") {
            Get.to(() => const DetailScreen());
          } else {
            Fluttertoast.showToast(msg: "Not Verified yet!");
          }
          Get.back();
          // String email = emailController.text.trim();
          // Uri emailUrl = Uri.parse("mailto:$email");
          // if (await canLaunchUrl(emailUrl)) {
          // await launchUrl(emailUrl);
          // } else {
          // throw "Error occured sending an email";
          // }

          var result = await OpenMailApp.openMailApp();
          if (!result.didOpen && !result.canOpen) {
            // showNoMailAppsDialog(context);
          } else if (!result.didOpen && result.canOpen) {
            showDialog(context: context, builder: (_) {
              return MailAppPickerDialog(mailApps: result.options);
            },);
          }
        });
  }

  Future registerUser() async {
    setState(() {LoaderOverlay.show(context);});
    // LocaleHandler.accessToken="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InRlc3QxNjBAeW9wbWFpbC5jb20iLCJzdWIiOjc3MiwianRpIjoiZDRmYTZhYjk3ZDgxN2NhZDg4ODY3MzM4NmJlNzk4YWYzNDIxNjYxZjczYmQ3MDg4NjhmZjFjYzVmNzAwYWY0MiIsImlhdCI6MTcxMzQzNDQ2OSwiZXhwIjoxNzQ0OTcwNDY5fQ.J02h3VlTQZAJW98NEb7QG0KnroqLoWfUdFj0wBmrKG8";
    const url = ApiList.registerUser;
    print(url);
    var uri = Uri.parse(url);
    try {
      final response = await http.post(
        uri,
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode({"receiveOffers": false, "email": emailController.text, "password":passwordController.text}),
      );
      var data = jsonDecode(response.body);
      setState(() {
        LoaderOverlay.hide();
      });
      if (response.statusCode == 201) {
        saveDetailsToLocal(data);
        print(LocaleHandler.accessToken);
        bottomsheett();
        return response;
      } else if (response.statusCode == 409) {
        getDetails();
        setState(() {
          LoaderOverlay.show(context);
          LocaleHandler.ErrorMessage = data["message"];
        });
        checkEmailVerifies();
        // Fluttertoast.showToast(msg: data["message"]);
      } else {
        setState(() {
          LoaderOverlay.hide();
        });
        Fluttertoast.showToast(msg: "Server Error");
        throw Exception("sdsdds");
      }
    } catch (e) {
      setState(() {
        LoaderOverlay.hide();
      });
      Fluttertoast.showToast(msg: "Server error");
    }
  }

  Future checkEmailVerifies() async {
    const url = ApiList.checkEmail;
    print(url);
    var uri = Uri.parse(url);
    try {
      final response = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${LocaleHandler.accessToken}'
          // 'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InRlc3QxNjBAeW9wbWFpbC5jb20iLCJzdWIiOjc3MiwianRpIjoiZDRmYTZhYjk3ZDgxN2NhZDg4ODY3MzM4NmJlNzk4YWYzNDIxNjYxZjczYmQ3MDg4NjhmZjFjYzVmNzAwYWY0MiIsImlhdCI6MTcxMzQzNDQ2OSwiZXhwIjoxNzQ0OTcwNDY5fQ.J02h3VlTQZAJW98NEb7QG0KnroqLoWfUdFj0wBmrKG8'
        },
        body: jsonEncode({"email": emailController.text}),
      );
      var data = jsonDecode(response.body);
      setState(() {
        LoaderOverlay.hide();
      });
      if (response.statusCode == 201) {
        LocaleHandler.emailVerified = data["data"]["verified"].toString();
        Preferences.setValue("emailVerified", LocaleHandler.emailVerified);
        print(LocaleHandler.emailVerified);
        if (LocaleHandler.emailVerified == "true") {
          Get.to(() => const DetailScreen());
        } else {
          sentEmailToverify();
          Fluttertoast.showToast(
              msg: "Not Verified yet! please check your email");
        }
        return response;
      }
      else {
        Fluttertoast.showToast(msg: LocaleHandler.ErrorMessage);
        // throw Exception("Server Error");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Server error");
    }
  }

  Future sentEmailToverify() async {
    final url = ApiList.sendverifyemail;
    print(url);
    var uri = Uri.parse(url);
    var response = await http.post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
          "Authorization": LocaleHandler.bearer
        },
        body: jsonEncode({
          "email": emailController.text,
        }));
    if (response.statusCode == 201) {
    } else if (response.statusCode == 401) {
      Fluttertoast.showToast(msg: "Invalid Email");
    } else {
      Fluttertoast.showToast(msg: "Server Error");
    }
    print(response.statusCode);
  }

  void saveDetailsToLocal(var data) {
    setState(() {
      LocaleHandler.accessToken = data["data"]["authenticate"]["accessToken"];
      LocaleHandler.refreshToken = data["data"]["authenticate"]["refreshToken"];
      LocaleHandler.nextAction = data["data"]["nextAction"];
      LocaleHandler.nextDetailAction = data["data"]["nextDetailAction"];
      LocaleHandler.emailVerified = data["data"]["emailVerifiedAt"].toString();
      LocaleHandler.userId = data["data"]["userId"].toString();
      LocaleHandler.role = data["data"]["role"];
      LocaleHandler.subscriptionPurchase = data["data"]["isSubscriptionPurchased"];

      Preferences.setToken(LocaleHandler.accessToken);
      Preferences.setrefreshToken(data["data"]["authenticate"]["refreshToken"]);
      Preferences.setNextAction(data["data"]["nextAction"]);
      Preferences.setNextDetailAction(data["data"]["nextDetailAction"]);
      Preferences.setValue("emailVerified", LocaleHandler.emailVerified);
      Preferences.setValue("userId", LocaleHandler.userId);
      Preferences.setValue("role", LocaleHandler.role);
      Preferences.setValue("subscriptionPurchase", LocaleHandler.subscriptionPurchase);
    });
  }

  void getDetails() async {
    LocaleHandler.accessToken = await Preferences.gettoken() ?? "";
    LocaleHandler.refreshToken = await Preferences.getrefreshToken() ?? "";
    LocaleHandler.nextAction = await Preferences.getNextAction() ?? "";
    LocaleHandler.nextDetailAction =
        await Preferences.getNextDetailAction() ?? "";
    LocaleHandler.emailVerified =
        await Preferences.getValue("emailVerified") ?? "";
    LocaleHandler.userId = await Preferences.getValue("userId") ?? "";
    LocaleHandler.role = await Preferences.getValue("role") ?? "";
    LocaleHandler.subscriptionPurchase =
        await Preferences.getValue("subscriptionPurchase") ?? "";
  }


  final GoogleSignIn googleSignIn = GoogleSignIn();
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;
      // loginUser();
      print("User -- -> ${user.toString()}");
      // print("User Credentials -- -> ${user}");
      print("User Credentials -- -> ${userCredential}");
      socialLoginUser("GOOGLE",socialToken: credential.accessToken.toString());
      // Use the user object for further operations or navigate to a new screen.
    } catch (e) {
      print(e.toString());
    }
  }
  Future socialLoginUser(String type,{required String socialToken,providerName})async{
    final url=ApiList.socialLogin;
    print(url);
    var uri=Uri.parse(url);
    var response=await http.post(uri,
        headers: <String,String>{'Content-Type': 'application/json'},
        body: jsonEncode({
          "socialProvider": type,
          "token": socialToken,
        })
    );
    var data = jsonDecode(response.body);
    print("response.statusCode======${response.statusCode}");
    print(data);
    if(response.statusCode==201){

      print(LocaleHandler.accessToken);
      setState(() {LoaderOverlay.hide();});
      if(data["data"]["emailVerifiedAt"]==true){
        Get.offAll(()=>BottomNavigationScreen());}
      else{
        Fluttertoast.showToast(msg: "Please verify the link send to your entered email");
        sentEmailToverify();
      }
    }else if(response.statusCode==401){
      setState(() {LoaderOverlay.hide();});
      Fluttertoast.showToast(msg: data["message"]);
    }
    else{
      setState(() {LoaderOverlay.hide();});
      Fluttertoast.showToast(msg: data["message"]);
    }
    print(response.statusCode);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _keyboardvisible=MediaQuery.of(context).viewInsets.bottom!=0;
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      // backgroundColor: color.backGroundClr,
      appBar: commonBar(context, Colors.transparent),
      body: Stack(
        children: [
          SizedBox(
            height: size.height,
            width: size.width,
            child: Image.asset(AssetsPics.background, fit: BoxFit.cover),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  buildText2(
                      "Create an account", 28, FontWeight.w600, color.txtBlack),
                  const SizedBox(height: 8),
                  buildText(LocaleText.createNewAccount, 15, FontWeight.w500,
                      color.txtBlack,
                      fontFamily: FontFamily.hellix),
                  const SizedBox(height: 29),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: buildText("Email", 16, FontWeight.w500,
                        enableField == "Enter email"
                            ? color.txtBlue
                            : color.txtgrey,
                        fontFamily: FontFamily.hellix),
                  ),
                  buildContainer(
                    "Enter email",
                    emailController,
                    AutovalidateMode.onUserInteraction,
                    emailNode,
                    press: () {
                      setState(() {
                        enableField = "Enter email";
                      });
                    },
                    gesture: GestureDetector(
                        child: Container(
                            padding: const EdgeInsets.only(top: 5),
                            height: 20,
                            width: 30,
                            alignment: Alignment.center,
                            child: SvgPicture.asset(AssetsPics.mailIcon))),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2, top: 15),
                    child: buildText(
                        "Password",
                        16,
                        FontWeight.w500,
                        enableField == "Enter password"
                            ? color.txtBlue
                            : color.txtgrey,
                        fontFamily: FontFamily.hellix),
                  ),
                  buildContainerPass(
                    "Enter password",
                    "Enter password",
                    passwordController,
                    AutovalidateMode.onUserInteraction,
                    passwordFocus,
                    validation: (val) {
                      if (val == "") {
                        setState(() {
                          passwordErrorText = "";
                        });
                      } else if (passwordController.text.length < 8) {
                        setState(() {
                          button = false;
                          passwordErrorText = "Password length should be 8 Characters";
                        });
                      } else if (!RegExp(LocaleKeysValidation.password)
                          .hasMatch(passwordController.text)) {
                        setState(() {                        button = false;
                        passwordErrorText = "At least 1 Upper,Lower,Num and Special Character";
                        });
                      } else if (passwordController.text == confPasswordController.text &&
                          !RegExp(LocaleKeysValidation.email).hasMatch(emailController.text) == false &&
                          emailController.text != "" &&
                          !RegExp(LocaleKeysValidation.password).hasMatch(passwordController.text) == false) {
                        setState(() {
                          button = true;
                          passwordErrorText = "";
                        });
                      } else {
                        setState(() {
                          button = false;
                          passwordErrorText = "";
                        });
                      }
                      return null;
                    },
                    obs: password,
                    press: () {
                      setState(() {
                        enableField = "Enter password";
                      });
                    },
                    gesture: GestureDetector(
                        onTap: () {
                          setState(() {
                            password = !password;
                          });
                        },
                        child: Container(
                            padding: const EdgeInsets.only(top: 5),
                            height: 20,
                            width: 30,
                            alignment: Alignment.center,
                            child: SvgPicture.asset(password ? AssetsPics.eyeOff : AssetsPics.eyeOn))),
                  ),
                  SizedBox(height: 5),
                  passwordErrorText == "" ? const SizedBox()
                      : Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: buildText(passwordErrorText, 12.8, FontWeight.w500, Colors.red),
                        ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2, top: 15),
                    child: buildText("Confirm Password", 16,
                        FontWeight.w500,
                        enableField == "Enter cpassword" ? color.txtBlue : color.txtgrey,
                        fontFamily: FontFamily.hellix),
                  ),
                  buildContainerPass(
                    "Enter password",
                    "Enter cpassword",
                    confPasswordController,
                    AutovalidateMode.onUserInteraction,
                    confirmPassFocus,
                    obs: cnfrmpassword,
                    validation: (val) {
                      if (confPasswordController.text == "") {
                        setState(() {
                          button = false;
                          cpasswordErrorText = "";
                        });
                      } else if (passwordController.text == confPasswordController.text) {
                        if(!RegExp(LocaleKeysValidation.email).hasMatch(emailController.text) == false && emailController.text != "" && !RegExp(LocaleKeysValidation.password).hasMatch(passwordController.text) == false){
                         setState(() {
                           button = true;
                         });
                        }else{
                          button=false;
                        }
                        setState(() {
                          cpasswordErrorText = "";
                          // button = false;
                        });
                      } else {
                        setState(() {
                          button = false;
                          cpasswordErrorText = "Confirm Password Mismatched!";
                        });
                      }
                      return null;
                    },
                    press: () {
                      setState(() {
                        enableField = "Enter cpassword";
                      });
                    },
                    gesture: GestureDetector(
                        onTap: () {
                          setState(() {
                            cnfrmpassword = !cnfrmpassword;
                          });
                        },
                        child: Container(
                            padding: const EdgeInsets.only(top: 5),
                            height: 20,
                            width: 30,
                            alignment: Alignment.center,
                            child: SvgPicture.asset(cnfrmpassword
                                ? AssetsPics.eyeOff
                                : AssetsPics.eyeOn))),
                  ),
                  cpasswordErrorText == ""
                      ? const SizedBox()
                      : Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: buildText(cpasswordErrorText, 12.8,
                              FontWeight.w500, Colors.red),
                        ),
                  const SizedBox(height: 25),
                  blue_button(context, "Continue", validation: button, press: ()async {
                    if (emailController.text.trim() == "") {
                      showToastMsg("Please Enter email");
                    } else if (!RegExp(LocaleKeysValidation.email).hasMatch(emailController.text)) {
                      showToastMsg("Please enter valid email!");
                    } else {
                      if(button){
                      emailNode.unfocus();
                      registerUser();}
                      else if(cpasswordErrorText==""&&passwordErrorText==""){
                        showToastMsg("All fields are mandatory");
                      }
                    }
                  }),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildColorContainer(color.example2, color.example),
                      Container(
                        margin: const EdgeInsets.only(left: 7, right: 7, bottom: 2),
                        child: buildText("or continue with", 16, FontWeight.w500,
                            color.txtBlack,
                            fontFamily: FontFamily.hellix),
                      ),
                      buildColorContainer(color.example, color.example2)
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildCircleAvatar(AssetsPics.facebook),
                      const SizedBox(width: 15),
                      GestureDetector(onTap: (){signInWithGoogle();},
                          child: buildCircleAvatar(AssetsPics.google)),
                      const SizedBox(width: 15),
                      buildCircleAvatar(AssetsPics.apple),
                    ],
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildTextSpan2('Already have an account? ', color.txtgrey),
                        GestureDetector(
                            onTap: () {
                              Get.off(() => const LoginScreen());
                            },
                            child: buildTextSpan2('Sign in', color.txtBlue)),
                      ],
                    ),
                  ),
                   SizedBox(height:_keyboardvisible?200: 25)
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
      child: Container(
        height: 56,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: color.txtWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: enableField == txt ? color.txtBlue : color.txtWhite,
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
            setState(() {
              if (passwordController.text == confPasswordController.text &&
                  !RegExp(LocaleKeysValidation.email)
                          .hasMatch(emailController.text) ==
                      false &&
                  emailController.text != "" &&
                  !RegExp(LocaleKeysValidation.password)
                          .hasMatch(passwordController.text) ==
                      false) {
                button = true;
              } else {
                button = false;
              }
            });
          },
          decoration: InputDecoration(
            errorStyle: const TextStyle(height: 0, fontSize: 12),
            border: InputBorder.none,
            hintText: txt,
            hintStyle: const TextStyle(
                fontFamily: FontFamily.hellix,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color.txtgrey2),
            contentPadding: const EdgeInsets.only(left: 20, right: 18, top: 13),
            suffixIcon: gesture,
          ),
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

  Widget buildCircleAvatar(String img) {
    return CircleAvatar(
      radius: 25,
      backgroundColor: color.txtWhite,
      child: Image.asset(img, height: 23),
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
      child: Container(
        height: 56,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: color.txtWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: enableField == chktxt ? color.txtBlue : color.txtWhite,
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
          decoration: InputDecoration(
            errorStyle: const TextStyle(height: 0, fontSize: 12),
            border: InputBorder.none,
            hintText: txt,
            hintStyle: const TextStyle(
                fontFamily: FontFamily.hellix,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color.txtgrey2),
            contentPadding: const EdgeInsets.only(left: 20, right: 18, top: 13),
            suffixIcon: gesture,
          ),
        ),
      ),
    );
  }
}
*/