import 'package:get/get.dart' hide FormData hide MultipartFile;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/controller/detail_controller.dart';
import 'package:slush/screens/sign_up/details/age.dart';
import 'package:slush/screens/sign_up/details/ethnicity.dart';
import 'package:slush/screens/sign_up/details/hieght.dart';
import 'package:slush/screens/sign_up/details/identify_yourself.dart';
import 'package:slush/screens/sign_up/details/location.dart';
import 'package:slush/screens/sign_up/details/lokking_for.dart';
import 'package:slush/screens/sign_up/details/name.dart';
import 'package:slush/screens/sign_up/details/profile_picture.dart';
import 'package:slush/screens/sign_up/details/profile_video.dart';
import 'package:slush/screens/sign_up/details/sexual_oreintation.dart';
import 'package:slush/widgets/app_bar.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/toaster.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({Key? key}) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  List pages=const[
     DetailNameScreen(),
    DetailAgeScreen(),
    DetailHieghtScreen(),
    IdentifyYourself(),
    DetailLookingForScreen(),
    DetailSexualOreintScreen(),
    DetailEthnicityScreen(),
    DetailLocationScreen(),
    DetailProfilePicture(),
    DeatilProfileVideoScreen(),
    // DetailEhanceSecurity(),
  ];

  int currentIndex=0;
  bool trimmerstrt =false;

/*
@override
  void initState() {
  Provider.of<detailedController>(context,listen: false).setCurrentIndex();
    super.initState();
 }*/

  @override
  Widget build(BuildContext context) {
    final detailcntrl=Provider.of<detailedController>(context,listen: false);
    final size=MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      // backgroundColor: color.backGroundClr,
      appBar:currentIndex==2?
          commonBarWithText(context, Colors.transparent,press: (){
            detailcntrl.setIndex(1);
            },press2: (){
            detailcntrl.setIndex(currentIndex+1);
          }) : commonBar(context, Colors.transparent,press: (){
          if(currentIndex!=0){
            if(!trimmerstrt){detailcntrl.setIndex(currentIndex-1);}
            Provider.of<detailedController>(context,listen: false).pauseVideo();
          }
          else{Get.back();}
      }),
      body: Selector<detailedController,int>(
          selector: (ctx,pro)=>currentIndex=pro.currentIndex,
        builder: (context,val,child){
        return  Stack(
          children: [
            SizedBox(height: size.height, width: size.width,
              child: Image.asset(AssetsPics.background,fit: BoxFit.cover),
            ),
            Padding(
              padding:  EdgeInsets.only(left: 20,right: 20,top: 11.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 3.h-2),
                  // buildText2("- - - - - - - -", 28, FontWeight.w600, color.txtBlack),
                  SizedBox(
                    height: 2.h,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: pages.length,
                        shrinkWrap: true,
                        itemBuilder: (context,index){
                          return index==currentIndex?
                          SizedBox(height: 3.h+2, width: 20, child: CircleAvatar(radius: 9,child: SvgPicture.asset(AssetsPics.Ellipse)))
                              : Container(height: 2.h-4, margin: const EdgeInsets.all(4),
                            width: 14,decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),color:
                          index<currentIndex? color.txtBlue:color.lightestBlue),);
                        }),
                  ),
                  Expanded(child: IndexedStack(
                    index: currentIndex,
                    children: const [
                      DetailNameScreen(),
                      DetailAgeScreen(),
                      DetailHieghtScreen(),
                      IdentifyYourself(),
                      DetailLookingForScreen(),
                      DetailSexualOreintScreen(),
                      DetailEthnicityScreen(),
                      DetailLocationScreen(),
                      DetailProfilePicture(),
                      DeatilProfileVideoScreen(),
                      // DetailEhanceSecurity(),
                    ],
                  ),),
                  Selector<detailedController,bool>(builder: (ctx,value,child){return
                    trimmerstrt?SizedBox():
                    blue_button(context,currentIndex==8 ||currentIndex==9?"Upload":currentIndex==10?"Create Account":
                  "Continue",press: (){
                    buttonPressedFun(detailcntrl);
                  });},
                  selector: (ctx,pro)=>trimmerstrt=pro.trimmerstrt,
                  ),
                  SizedBox(height: defaultTargetPlatform == TargetPlatform.iOS?3.h: 2.h),
                ],
              ),
            ),
          ],
        );
      }, ),
    );
  }

  void buttonPressedFun(detailedController detailcntrl){
      if(currentIndex<pages.length){
           if(LocaleHandler.name!="" && currentIndex==0){hitApi(detailcntrl,"fill_firstname");}
      else if(LocaleHandler.dateTimee!="" && currentIndex==1){hitApi(detailcntrl,"fill_dateofbirth");}
      else if(LocaleHandler.height!="" && currentIndex==2){hitApi(detailcntrl,"fill_height");}
      else if(LocaleHandler.gender!="" && currentIndex==3){hitApi(detailcntrl,"choose_gender");}
      else if(LocaleHandler.lookingfor!="" && currentIndex==4){hitApi(detailcntrl,"fill_lookingfor");}
      else if(LocaleHandler.sexualOreintation!="" && currentIndex==5){hitApi(detailcntrl,"fill_sexual_orientation");}
      else if(LocaleHandler.entencity.length!=0 && currentIndex==6){hitApi(detailcntrl,"fill_ethnicity");}
      else if(LocaleHandler.location!="" && currentIndex==7){detailcntrl.setIndex(currentIndex+1);}
      else if(LocaleHandler.introImage!=null && currentIndex==8){hitApi(detailcntrl,"upload_avatar");}
      else if(LocaleHandler.introVideo!=null && currentIndex==9){hitApi(detailcntrl,"upload_video");
           // currentIndex = currentIndex+1;
      }else{
             if(currentIndex==0){showToastMsg("Please enter your name");}
        else if(currentIndex==3){showToastMsg("Please select your gender");}
        else if(currentIndex==4){showToastMsg("Please select you looking for");}
        else if(currentIndex==5){showToastMsg("Please select your sexual orientation");}
        else if(currentIndex==6){showToastMsg("Please select your ethnicity");}
        else if(currentIndex==7){showToastMsg("Please select your location");}
        else if(currentIndex==8 || currentIndex==9){showToastMsg("Please upload the file");}
      }
      // else if(LocaleHandler.password!="" && currentIndex==10){currentIndex = currentIndex+1;}
      } else if(currentIndex==10){
        // if(LocaleHandler.passMatched==true && LocaleHandler.cpassMatched==true){
        //   if(LocaleHandler.showheight==true&&LocaleHandler.showgender==true&&LocaleHandler.showlookingfor==true&&LocaleHandler.showsexualOreintation==true){
        //     setState(() {LocaleHandler.displayOnScreen=true;});
        //   }else{setState(() {LocaleHandler.displayOnScreen=false;});}
        //   // registerUserDetail(LocaleHandler.nextAction);
        // }
        // else if(LocaleHandler.passMatched==false && LocaleHandler.cpassMatched==false) {
        //   showToastMsg("please Enter both fields");}
        // else if(LocaleHandler.passMatched==true && LocaleHandler.cpassMatched==false) {
        //   showToastMsg("Confirm password Mismatched!");
        // }
        // else{}
       }
  }

  void hitApi(detailedController detailcntrl,String action){
  if(currentIndex!=9){detailcntrl.setIndex(currentIndex+1);}
  if(currentIndex==9){Provider.of<detailedController>(context,listen: false).pauseVideo();}
  detailcntrl.registerUserDetail(context, action);
  }
}


/*
* import 'dart:async';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:get/get.dart' hide FormData hide MultipartFile;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/loader.dart';
import 'package:slush/constants/prefs.dart';
import 'package:slush/screens/login/login.dart';
import 'package:slush/screens/sign_up/details/age.dart';
import 'package:slush/screens/sign_up/details/enhace_security.dart';
import 'package:slush/screens/sign_up/details/ethnicity.dart';
import 'package:slush/screens/sign_up/details/hieght.dart';
import 'package:slush/screens/sign_up/details/identify_yourself.dart';
import 'package:slush/screens/sign_up/details/location.dart';
import 'package:slush/screens/sign_up/details/lokking_for.dart';
import 'package:slush/screens/sign_up/details/name.dart';
import 'package:slush/screens/sign_up/details/profile_picture.dart';
import 'package:slush/screens/sign_up/details/profile_video.dart';
import 'package:slush/screens/sign_up/details/sexual_oreintation.dart';
import "package:http/http.dart"as http;
import 'package:slush/screens/sign_up/details_completed.dart';
import 'package:slush/widgets/app_bar.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/toaster.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({Key? key}) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  List pages=const[
     DetailNameScreen(),
    DetailAgeScreen(),
    DetailHieghtScreen(),
    IdentifyYourself(),
    DetailLookingForScreen(),
    DetailSexualOreintScreen(),
    DetailEthnicityScreen(),
    DetailLocationScreen(),
    DetailProfilePicture(),
    DeatilProfileVideoScreen(),
    // DetailEhanceSecurity(),
  ];

  int currentIndex=0;

  void deleteAlldata(){
    if(LocaleHandler.nextAction=="fill_firstname"){currentIndex=0;}
    if(LocaleHandler.nextAction=="fill_dateofbirth"){currentIndex=1;}
    if(LocaleHandler.nextAction=="fill_height"){currentIndex=2;}
    if(LocaleHandler.nextAction=="choose_gender"){currentIndex=3;}
    if(LocaleHandler.nextAction=="fill_lookingfor"){currentIndex=4;}
    if(LocaleHandler.nextAction=="fill_sexual_orientation"){currentIndex=5;}
    if(LocaleHandler.nextAction=="fill_ethnicity"){currentIndex=6;}
    if(LocaleHandler.nextAction=="upload_avatar"){currentIndex=7;}
    if(LocaleHandler.nextAction=="upload_video"){currentIndex=8;}
    setState(() {});
  }
@override
  void initState() {
  deleteAlldata();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      // backgroundColor: color.backGroundClr,
      appBar:currentIndex==2?
          commonBarWithText(context, Colors.transparent,press: (){setState(() {
            currentIndex=1;
          });},press2: (){setState(() {currentIndex= currentIndex+1;});})
          : commonBar(context, Colors.transparent,press: (){
        setState(() {
          if(currentIndex!=0){
          currentIndex = currentIndex-1;}else{
            Get.back();
          }});
      }),
      body: Stack(
        children: [
          SizedBox(
            height: size.height,
            width: size.width,
            child: Image.asset(AssetsPics.background,fit: BoxFit.cover,),
          ),
          Padding(
            padding:  EdgeInsets.only(left: 20,right: 20,top: 11.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 SizedBox(height: 3.h-2),
                // buildText2("- - - - - - - -", 28, FontWeight.w600, color.txtBlack),
                SizedBox(
                  height: 2.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                      itemCount: pages.length,
                      shrinkWrap: true,
                      itemBuilder: (context,index){
                      return index==currentIndex?
                      SizedBox(
                          height: 3.h+2, width: 20, child: CircleAvatar(radius: 9,child: SvgPicture.asset(AssetsPics.Ellipse),))
                          : Container(
                        height: 2.h-4,
                        margin: const EdgeInsets.all(4),
                        width: 14,decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),color:
                      index<currentIndex?
                      color.txtBlue:color.lightestBlue),
                      );
                      }),
                ),
                Expanded(child: IndexedStack(
                  index: currentIndex,
                  children: const [
                    DetailNameScreen(),
                    DetailAgeScreen(),
                    DetailHieghtScreen(),
                    IdentifyYourself(),
                    DetailLookingForScreen(),
                    DetailSexualOreintScreen(),
                    DetailEthnicityScreen(),
                    DetailLocationScreen(),
                    DetailProfilePicture(),
                    DeatilProfileVideoScreen(),
                    // DetailEhanceSecurity(),
                  ],
                ),),
                blue_button(context,currentIndex==8 ||currentIndex==9?"Upload":currentIndex==10?"Create Account":
                "Continue",press: (){
                  setState(() {
                  buttonPressedFun();
                  });
                }),
                 SizedBox(height: defaultTargetPlatform == TargetPlatform.iOS?3.h: 2.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void buttonPressedFun(){
    setState(() {
      if(currentIndex<pages.length){
           if(LocaleHandler.name!="" && currentIndex==0){currentIndex = currentIndex+1;}
      else if(LocaleHandler.dateTimee!="" && currentIndex==1){currentIndex = currentIndex+1;}
      else if(LocaleHandler.height!="" && currentIndex==2){currentIndex = currentIndex+1;}
      else if(LocaleHandler.gender!="" && currentIndex==3){currentIndex = currentIndex+1;}
      else if(LocaleHandler.lookingfor!="" && currentIndex==4){currentIndex = currentIndex+1;}
      else if(LocaleHandler.sexualOreintation!="" && currentIndex==5){currentIndex = currentIndex+1;}
      else if(LocaleHandler.entencity.length!=0 && currentIndex==6){currentIndex = currentIndex+1;}
      else if(LocaleHandler.location!="" && currentIndex==7){currentIndex = currentIndex+1;}
      else if(LocaleHandler.introImage!=null && currentIndex==8){currentIndex = currentIndex+1;}
      else if(LocaleHandler.introVideo!=null && currentIndex==9){registerUserDetail(LocaleHandler.nextAction);
           // currentIndex = currentIndex+1;
      }else{
             if(currentIndex==0){showToastMsg("Please enter your name");}
        else if(currentIndex==3){showToastMsg("Please select your gender");}
        else if(currentIndex==4){showToastMsg("Please select you looking for");}
        else if(currentIndex==5){showToastMsg("Please select your sexual orientation");}
        else if(currentIndex==6){showToastMsg("Please select your ethnicity");}
        else if(currentIndex==7){showToastMsg("Please select your location");}
        else {showToastMsg("Please upload the file");}
           }
      // else if(LocaleHandler.password!="" && currentIndex==10){currentIndex = currentIndex+1;}
      } else if(currentIndex==10){
        if(LocaleHandler.passMatched==true && LocaleHandler.cpassMatched==true){
          if(LocaleHandler.showheight==true&&LocaleHandler.showgender==true&&LocaleHandler.showlookingfor==true&&LocaleHandler.showsexualOreintation==true){
            setState(() {LocaleHandler.displayOnScreen=true;});
          }else{setState(() {LocaleHandler.displayOnScreen=false;});}
          registerUserDetail(LocaleHandler.nextAction);
        }
        else if(LocaleHandler.passMatched==false && LocaleHandler.cpassMatched==false) {
          showToastMsg("please Enter both fields");}
        else if(LocaleHandler.passMatched==true && LocaleHandler.cpassMatched==false) {
          showToastMsg("Confirm password Mismatched!");
        }
        else{}
       }
    });
  }

  Future registerUserDetail(String action)async{
    setState(() {LoaderOverlay.show(context);});
    print(action);
    Preferences.setNextAction(action);
    Preferences.setToken(LocaleHandler.accessToken);
    final url= ApiList.registerUserDetails;
    print(url);
    var uri=Uri.parse(url);
    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = "Bearer ${LocaleHandler.accessToken}";
     // Add image file
      if (LocaleHandler.introImage != null) {
        File imageFile = File(LocaleHandler.introImage!.path);
        var stream = http.ByteStream(imageFile.openRead());
        var length = await imageFile.length();
        var multipartFile = http.MultipartFile('avatar', stream, length, filename: LocaleHandler.introImage.toString().split("/").last);
        request.files.add(multipartFile);
      }
      if (LocaleHandler.introVideo != null) {
        File introVideo = File(LocaleHandler.introVideo!.path);
        var stream = http.ByteStream(introVideo.openRead());
        var length = await introVideo.length();
        var multipartFile2 = http.MultipartFile('video', stream, length, filename: LocaleHandler.introVideo.toString().split("/").last);
        request.files.add(multipartFile2);
      }

      // Add other parameters
      request.fields['action'] = action;
      request.fields['firstName'] = LocaleHandler.name.toString();
      request.fields['dateOfBirth'] = LocaleHandler.dateTimee;
      request.fields['height'] = LocaleHandler.height.toString();
      request.fields['height_unit'] = LocaleHandler.heighttype;
      request.fields['gender'] = LocaleHandler.gender.toString();
      request.fields['lookingFor'] = LocaleHandler.lookingfor.toString();
      request.fields['sexuality'] = LocaleHandler.sexualOreintation.toString();
      List.generate(LocaleHandler.entencity.length, (i) => request.fields['ethnicity[$i]'] = LocaleHandler.entencity[i].toString());
      // request.fields['ethnicity[0]'] = "1";
    request.fields['password'] = LocaleHandler.password.toString();
      request.fields['confirm_password'] = LocaleHandler.password.toString();
      request.fields['displayOnProfile'] = LocaleHandler.displayOnScreen.toString();
      // Send the request
      var response = await request.send();
      setState(() {LoaderOverlay.hide();});
      if (response.statusCode == 201) {
        if(action=="fill_firstname"){registerUserDetail("fill_dateofbirth");}
        else if(action=="fill_dateofbirth"){registerUserDetail("fill_height");}
        else if(action=="fill_height"){registerUserDetail("choose_gender");}
        else if(action=="choose_gender"){registerUserDetail("fill_lookingfor");}
        else if(action=="fill_lookingfor"){registerUserDetail("fill_sexual_orientation");}
        else if(action=="fill_sexual_orientation"){registerUserDetail("fill_ethnicity");}
        else if(action=="fill_ethnicity"){registerUserDetail("upload_avatar");}
        else if(action=="upload_avatar"){registerUserDetail("upload_video");}
        else if(action=="upload_video"){registerUserDetail("none");}
        else if(action=="fill_password"){registerUserDetail("none");}
        else if(action=="none"){
          print("Succefull Register");
          Get.to(()=>const SignUpDetailsCompletedScreen());
        }
      } else{
        Get.offAll(()=>LoginScreen());
        Fluttertoast.showToast(msg:"Server Error! Please sing in again");}
}
}



*/
