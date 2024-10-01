import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/loader.dart';
import 'package:slush/widgets/app_bar.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:slush/widgets/toaster.dart';
import '../../constants/api.dart';

class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({Key? key}) : super(key: key);

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  FocusNode emailNode = FocusNode();
  String enableField = "";
  bool button = false;
  String emailText = "";

  @override
  void initState() {
    emailNode.addListener(() {
      if (emailNode.hasFocus) {
        enableField = "Enter email";
      } else {
        enableField = "";
      }
    });
    super.initState();
  }

  Future changeUserEmail() async {
    const url = ApiList.changeEmail;
    print(url);
    var uri = Uri.parse(url);
    try {
      final response = await http.patch(uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':'Bearer ${LocaleHandler.accessToken}'
         },
        body: jsonEncode({"email": emailController.text.trim()}),
      );
      var data = jsonDecode(response.body);
      setState(() {LoaderOverlay.hide();});
      if (response.statusCode == 201) {
        Fluttertoast.showToast(msg: "Email Changed Successfully");
        print(LocaleHandler.accessToken);
        return response;
      } else if (response.statusCode == 400) {
        setState(() {
          LoaderOverlay.hide();
          LocaleHandler.ErrorMessage = data["message"];
        });
        Fluttertoast.showToast(msg: LocaleHandler.ErrorMessage);
        print(LocaleHandler.ErrorMessage);
      } else {
        Fluttertoast.showToast(msg: "Server error");
      }
    } catch (e) {
      setState(() {LoaderOverlay.hide();});
      Fluttertoast.showToast(msg: "Server error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
            child: Image.asset(
              AssetsPics.background,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 80),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 35),
                  buildText("Do you want to update your email?", 28, FontWeight.w600, color.txtBlack),
                  const SizedBox(height: 29),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: buildText("Email", 16, FontWeight.w500,
                        enableField == "Enter email" ? color.txtBlue : color.txtgrey,
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
                  const Expanded(child: SizedBox(height: 40)),
                  blue_button(context, "Continue", validation: button,
                      press: () {
                    if (emailController.text.trim() == "") {
                      showToastMsg("Please Enter email");
                    } else if (!RegExp(LocaleKeysValidation.email).hasMatch(emailController.text)) {
                      showToastMsg("Please enter valid email!");
                    } else {
                      emailNode.unfocus();
                      setState(() {LoaderOverlay.show(context);});
                      changeUserEmail();
                    }
                  }),
                  const SizedBox(height: 40)
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
      GestureDetector? gesture,
      bool obs = false}) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        height: 7.h,
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
          // focusNode: loginFocus,
          obscureText: obs,
          obscuringCharacter: "X",
          cursorColor: color.txtBlue,
          autovalidateMode: auto,
          validator: validation,
          onChanged: (val) {
            setState(() {
              if (_form.currentState!.validate()) {
                button = true;
              } else {
                button = false;
              }
            });
          },
          style: TextStyle(fontFamily: FontFamily.hellix, fontSize: 17),
          decoration: InputDecoration(
            errorStyle: const TextStyle(height: 0, fontSize: 12),
            border: InputBorder.none,
            hintText: txt,
            hintStyle: const TextStyle(
                fontFamily: FontFamily.hellix,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color.txtgrey2),
            contentPadding: const EdgeInsets.only(left: 20, right: 18, top: 10),
            suffixIcon: gesture,
          ),
        ),
      ),
    );
  }
}

