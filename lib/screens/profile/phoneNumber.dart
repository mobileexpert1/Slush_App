// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:responsive_sizer/responsive_sizer.dart';
// import 'package:slush/constants/LocalHandler.dart';
// import 'package:slush/constants/api.dart';
// import 'package:slush/constants/color.dart';
// import 'package:slush/constants/image.dart';
// import 'package:slush/widgets/blue_button.dart';
// import 'package:slush/widgets/text_widget.dart';
// import 'package:intl_phone_field/intl_phone_field.dart';
// import 'package:http/http.dart'as http;
// import 'package:slush/widgets/toaster.dart';
//
// class PhoneNumberScreen extends StatefulWidget {
//   const PhoneNumberScreen({Key? key}) : super(key: key);
//
//   @override
//   State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
// }
//
// class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
//   TextEditingController phoneController = TextEditingController();
//   FocusNode phoneeNode = FocusNode();
//   String enableField = "";
//   String phoneNUmber="";
//
//   @override
//   void initState() {
//     phoneeNode.addListener(() {
//       if (phoneeNode.hasFocus) {enableField = "Enter Phone Number";}
//       else {enableField = "";}
//     });
//     print(LocaleHandler.dataa);
//     super.initState();
//   }
//
// checkPhone(String num)async{
//   final url=ApiList.checkphone;
//   print(url);
//   var uri=Uri.parse(url);
//     var response=await http.post(uri,
//     headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${LocaleHandler.accessToken}'},
//         body: jsonEncode({"phoneNumber":num})
//         // body: jsonEncode({"phoneNumber":"+91 9988320205"})
//     );
//   FocusManager.instance.primaryFocus?.unfocus();
//   var i=jsonDecode(response.body);
//   if(response.statusCode==201){
//     print(i);
//     if(i["data"]["exist"]==true){
//       showToastMsg("Number Exists");
//     }else{showToastMsg("Number not Exists");                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      }
//     }
//     else if(response.statusCode==401){showToastMsgTokenExpired();}
//     else{showToastMsg(i["message"][0]);}
// }
//
//   @override
//   Widget build(BuildContext context) {
//     final size=MediaQuery.of(context).size;
//     return Scaffold(
//       body: Stack(
//         children: [
//           SizedBox(height: size.height, width: size.width,
//             child: Image.asset(AssetsPics.background,fit: BoxFit.cover),
//           ),
//           Padding(
//             padding: EdgeInsets.only(left: 20, right: 20, top: 40),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: 3.h-3),
//                 Row(
//                   children: [
//                     GestureDetector(
//                         onTap: (){Get.back();},
//                         child: SizedBox(height: 20,width: 20,
//                             child: SvgPicture.asset(AssetsPics.arrowLeft))),
//                   ],
//                 ),
//                 SizedBox(height: 7.h-3),
//                 buildText2("Update your mobile number", 28, FontWeight.w600, color.txtBlack),
//                 SizedBox(height: 3.h),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 4, bottom: 4),
//                   child: buildText("Phone Number", 16,
//                       FontWeight.w500,
//                       enableField == "Enter Phone Number" ? color.txtBlue : color.txtgrey,
//                       fontFamily: FontFamily.hellix),
//                 ),
//                 buildIntlPhoneField(
//                   "Enter Phone Number",
//                   phoneController,
//                   AutovalidateMode.onUserInteraction,
//                   phoneeNode,
//                 ),
//                 const Spacer(),
//                 // blue_button(context, "Update",press: (){
//                 blue_button(context, "Check number is exists",press: (){
//                   checkPhone(phoneNUmber);
//                 }),
//                 SizedBox(height: 2.h - 3)
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget buildIntlPhoneField(String txt, TextEditingController controller,
//       AutovalidateMode auto, FocusNode node,
//       {FormFieldValidator<String>? validation, VoidCallback? press}) {
//     return Align(
//       alignment: Alignment.center,
//       child: Container(
//         padding: EdgeInsets.only(top: 6),
//         height: 56,
//         width: MediaQuery.of(context).size.width,
//         decoration: BoxDecoration(
//             color: color.txtWhite,
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(
//                 color: enableField == txt ? color.txtBlue : color.txtWhite,
//                 width: 1)),
//         child: IntlPhoneField(
//           decoration: const InputDecoration(
//               counter: Offstage(),
//               errorStyle: TextStyle(height: 0, fontSize: 0),
//               border: InputBorder.none,
//               hintText: 'Enter Phone Number',
//               hintStyle: TextStyle(
//                   fontFamily: FontFamily.hellix,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                   color: color.txtgrey2),
//               contentPadding: EdgeInsets.only(left: 20, right: 18, top: 15),
//               isDense: true,
//           ),
//           initialCountryCode: 'IN',
//           onChanged: (phone) {
//             // phoneController.text=phone.completeNumber;
//             print(phoneController.text);
//             print(phone.completeNumber);
//             setState(() {phoneNUmber=phone.completeNumber;});
//             },
//           controller: controller,
//           autovalidateMode: auto,
//           focusNode: node,
//           onTap: press,
//         ),
//       ),
//     );
//   }
// }
