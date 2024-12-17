import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/widgets/text_widget.dart';

class DetailEhanceSecurity extends StatefulWidget {
  const DetailEhanceSecurity({Key? key}) : super(key: key);

  @override
  State<DetailEhanceSecurity> createState() => _DetailEhanceSecurityState();
}

class _DetailEhanceSecurityState extends State<DetailEhanceSecurity> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController confPasswordController = TextEditingController();
  FocusNode passwordFocus= FocusNode();
  FocusNode confirmPassFocus= FocusNode();
  String enableField="";
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
  String passwordErrorText="";
  String cpasswordErrorText="";
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           SizedBox(height: 3.h-3),
          buildText("Enhance your security", 28, FontWeight.w600, color.txtBlack),
          const SizedBox(height: 8),
          buildText("Choose a password", 15, FontWeight.w500, color.txtBlack,fontFamily: FontFamily.hellix),
           SizedBox(height: 4.h-2),
          Padding(
            padding: const EdgeInsets.only(left: 4,bottom: 2),
            child: buildText("Password", 16, FontWeight.w500,enableField == "Enter password"? color.txtBlue:color.txtgrey,fontFamily: FontFamily.hellix),
          ),
          buildContainer("Enter password","Enter password",
            passwordController,AutovalidateMode.onUserInteraction,passwordFocus,
            validation: (val){
            if(val==""){
             setState(() {
               passwordErrorText="";
             });
            }
              else if(passwordController.text.length<8){
              setState(() {
                passwordErrorText="Password length should be 8 Characters";
                LocaleHandler.passMatched=false;
              });
            } else if(!RegExp(LocaleKeysValidation.password).hasMatch(passwordController.text) ){
              setState(() {
                passwordErrorText="At least 1 Upper,Lower,Num and Special Character";
                LocaleHandler.passMatched=false;
              });
            }else{
              setState(() {
                LocaleHandler.passMatched=true;
                passwordErrorText="";
              });
            }
            return null;
            },
            obs: password,
            press: (){setState(() {enableField = "Enter password";});
            },
            gesture: GestureDetector(
                onTap: (){setState(() {password=!password;});
                },
                child: Container(padding: const EdgeInsets.only(top: 5),
                    height: 20,width: 30,
                    alignment: Alignment.center,
                    child: SvgPicture.asset(password?AssetsPics.eyeOff:AssetsPics.eyeOn))
            ),
          ),
          SizedBox(height: 5),

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
            validation: (val){
            if(confPasswordController.text==""){
              setState(() {
                cpasswordErrorText="";
              });
              LocaleHandler.cpassMatched=false;
            }
             else if(passwordController.text==confPasswordController.text){
              setState(() {
                cpasswordErrorText="";
                LocaleHandler.cpassMatched=true;
              });
            }else{
               setState(() {
                 LocaleHandler.cpassMatched=false;
                 cpasswordErrorText="Confirm Password Mismatched!";
               });
              }
              return null;
            },
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
          SizedBox(height: 5),
          cpasswordErrorText == "" ? const SizedBox() : Padding(
            padding: const EdgeInsets.only(left: 10),
            child: buildText(cpasswordErrorText, 12.8, FontWeight.w500, Colors.red),
          ),
          const Spacer(),
          Align(
              alignment: Alignment.center,
              child: buildText("Make sure it’s unique.", 15, FontWeight.w500, color.txtBlack,fontFamily: FontFamily.hellix)),
           SizedBox(height: 2.h-2)
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
        height: 7.h+1,
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
          // validator: validation,
          onChanged: validation,
          style: const TextStyle(fontFamily: FontFamily.hellix, fontSize: 17),
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