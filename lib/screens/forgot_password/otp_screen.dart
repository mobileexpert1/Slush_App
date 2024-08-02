import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:http/http.dart' as http;
import 'package:slush/controller/controller.dart';
import 'package:slush/screens/forgot_password/create_password.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:slush/widgets/toaster.dart';
import '../../constants/loader.dart';
import '../../widgets/blue_button.dart';
class TimerDialog extends StatefulWidget {
  var text;
  TimerDialog({this.text});
  @override
  _TimerDialogState createState() => _TimerDialogState();
}
class _TimerDialogState extends State<TimerDialog> {
  int _seconds = 300; // 5 minutes
  Timer? _timer;
  bool buttonClr=false;
  bool isOtpWrong = false;
  @override
  void initState() {
    super.initState();
    _startTimer();
  }
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() {
          _seconds--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    var time = '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    if(time == "00:00"){
      buttonClr = true;
    }
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
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
            body: jsonEncode({"email": widget.text})
        );
        var data =jsonDecode(response.body);
        setState(() {LoaderOverlay.hide();});
        if(response.statusCode==201){
          showToastMsg("Password link sent");
        }
        else if(response.statusCode==400){Fluttertoast.showToast(msg: data["message"]);}
        else{Fluttertoast.showToast(msg: "Servre Error");}
      }
    } on SocketException catch (_) {
      showToastMsg("No Interenet Connection...",clrbg: Colors.red,clrtxt: color.txtWhite);
    }
  }
  Future confirmOtp(BuildContext context, String txt, int otp) async {
    final nameControl = Provider.of<nameControllerr>(context, listen: false);
    final url = ApiList.verifyOTPpassword;
    var uri = Uri.parse(url);
    var response = await http.post(uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"email": txt, "passwordResetCode": otp}));
    var data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      Fluttertoast.showToast(msg: "OTP verified");
      nameControl.getResetPasswordToken(data["data"]["token"]);
      print(LocaleHandler.resetPasswordtoken);
      _timer?.cancel();
      Get.to(() => const CreatePassword());
    } else if (response.statusCode == 400) {
      Fluttertoast.showToast(msg: data["message"]);
    } else {
      Fluttertoast.showToast(msg: "Server Error");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: Align(
          alignment: Alignment.center,
          child: Container(
              width: MediaQuery.of(context).size.width / 1.1,
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 3.h),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.txtWhite,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  buildText("OTP Input", 24, FontWeight.w500, Colors.black),
                  buildText("Enter your one-time password", 18, FontWeight.w500, Colors.black),
                  Padding(
                    padding: const EdgeInsets.only(top: 20, left: 0, right: 0),
                    child: OTPTextField(
                      length: 6,
                      hasError: isOtpWrong,
                      width: MediaQuery.of(context).size.width,
                      fieldWidth: (MediaQuery.of(context).size.width - 100) / 6,
                      style: TextStyle(fontSize: 17),
                      textFieldAlignment: MainAxisAlignment.spaceAround,
                      fieldStyle: FieldStyle.box,
                      outlineBorderRadius: 10,
                      onChanged: (val) {
                        print(val);
                      },
                      onCompleted: (pin) {
                        int otpp = int.parse(pin);
                        confirmOtp(context, widget.text, otpp);
                      },
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Text(  formatTime(seconds),
                  //   style: TextStyle(fontSize: 20, color: Colors.black),
                  // ),
                  buildText(_formatTime(_seconds), 20, FontWeight.w500, Colors.black),
                  const SizedBox(height: 10,),
                  blue_button(context,"Resend OTP",press: (){
                    FocusManager.instance.primaryFocus?.unfocus();
                    if(buttonClr==true){
                      _seconds = 300;
                      buttonClr = false;
                      setState(() {});
                      _startTimer();
                      forgotPassword();
                    }
                  },validation: buttonClr ),
                ],
              )
          ),
        ),
      ),
    );
  }
}


// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:get/get.dart';
// import 'package:otp_text_field/otp_text_field.dart';
// import 'package:otp_text_field/style.dart';
// import 'package:provider/provider.dart';
// import 'package:responsive_sizer/responsive_sizer.dart';
// import 'package:slush/constants/LocalHandler.dart';
// import 'package:slush/constants/api.dart';
// import 'package:slush/constants/color.dart';
// import 'package:http/http.dart'as http;
// import 'package:slush/controller/controller.dart';
// import 'package:slush/screens/forgot_password/create_password.dart';
// import 'package:slush/widgets/text_widget.dart';
//
// bool isOtpWrong = false;
//
// customDialogOTPBox(BuildContext context,String txt) {
//   return showGeneralDialog(
//       barrierLabel: "Label",
//       transitionDuration: const Duration(milliseconds: 500),
//       context: context,
//       pageBuilder: (context, anim1, anim2) {
//         return GestureDetector(
//           onTap: (){},
//           child: Scaffold(
//             backgroundColor: Colors.transparent,
//             body: Align(
//               alignment: Alignment.center,
//               child: Container(
//                 // height: MediaQuery.of(context).size.height/2.5,
//                   width: MediaQuery.of(context).size.width/1.1,
//                   margin:  EdgeInsets.symmetric(horizontal: 16,vertical: 3.h),
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(color: color.txtWhite,
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     mainAxisSize: MainAxisSize.min,
//                     children: <Widget>[
//                       buildText("OTP input", 24, FontWeight.w500, Colors.black),
//                       buildText("Enter your one-time password", 18, FontWeight.w500, Colors.black),
//                     Padding(
//                     padding: const EdgeInsets.only(top: 20, left: 0, right: 0),
//                     child: OTPTextField(
//                     length: 6,
//                     hasError: isOtpWrong,
//                     width: MediaQuery.of(context).size.width,
//                     fieldWidth: (MediaQuery.of(context).size.width - 100) / 6,
//                     style: TextStyle(fontSize: 17),
//                     textFieldAlignment: MainAxisAlignment.spaceAround,
//                     fieldStyle: FieldStyle.box,
//                     outlineBorderRadius: 10,
//                     onChanged: (val) {print(val);},
//                     onCompleted: (pin) {
//                       int otpp=int.parse(pin);
//                       confirmOtp(context,txt,otpp);
//                     },
//                     )),
//                       SizedBox(height: 2.h),
//                     ],
//                   )),
//             ),
//           ),
//         );
//       },
//       transitionBuilder: (context, anim1, anim2, child) {
//         return SlideTransition(
//           position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(anim1),
//           child: child,
//         );}
//   );
// }
//
// Future confirmOtp(BuildContext context,String txt,int otp)async{
//   final nameControl=Provider.of<nameControllerr>(context,listen: false);
//
//   final url=ApiList.verifyOTPpassword;
//   var uri=Uri.parse(url);
//   var response=await http.post(uri,
//       headers: <String, String>{
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode({
//         "email": txt,
//         "passwordResetCode":otp
//       })
//   );
//   var data =jsonDecode(response.body);
//   if(response.statusCode==201){
//     Fluttertoast.showToast(msg: "OTP verified");
//     nameControl.getResetPasswordToken(data["data"]["token"]);
//     print(LocaleHandler.resetPasswordtoken);
//     Get.to(()=>CreatePassword());
//   }
//   else if(response.statusCode==400){
//     Fluttertoast.showToast(msg: data["message"]);
//   }
//   else{
//     Fluttertoast.showToast(msg: "Server Error");
//   }
// }