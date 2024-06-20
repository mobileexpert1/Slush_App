import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/controller/edit_profile_controller.dart';
import 'package:slush/screens/profile/basic_info/education.dart';
import 'package:slush/screens/profile/basic_info/work_screen.dart';
import 'package:slush/screens/sign_up/details/age.dart';
import 'package:slush/screens/sign_up/details/ethnicity.dart';
import 'package:slush/screens/sign_up/details/hieght.dart';
import 'package:slush/screens/sign_up/details/location.dart';
import 'package:slush/screens/sign_up/details/sexual_oreintation.dart';
import 'package:slush/screens/sign_up/vacation/cooking_skill.dart';
import 'package:slush/screens/sign_up/vacation/ideal_vacatioon.dart';
import 'package:slush/screens/sign_up/vacation/smoking_opinion.dart';
import 'package:slush/widgets/app_bar.dart';

import 'basic_info/gender_screen.dart';

class EditProfileBasicInfoScreen extends StatefulWidget {
  const EditProfileBasicInfoScreen({Key? key,required this.index}) : super(key: key);
final int index;
  @override
  State<EditProfileBasicInfoScreen> createState() => _EditProfileBasicInfoScreenState();
}

class _EditProfileBasicInfoScreenState extends State<EditProfileBasicInfoScreen> {
  List pages=const[
    GenderScreen(),
    DetailHieghtScreen(),
    WorkScreen(),
    EducationQualificationScreen(),
    // DetailAgeScreen(),
    // DetailLocationScreen(),
    DetailSexualOreintScreen(),
    DetailEthnicityScreen(),

  ];

  List pages2=const[
    VacationBestIdealScreen(),
    VacationCookingSkillScreen(),
    VacationSmokinOpinionScreen(),
  ];

  bool textValue = false;
  int currentIndex=0;
  PageController controller = PageController();
  int indicatorIndex = 0;

@override
  void initState() {
  callFunction();
    // TODO: implement initState
    super.initState();
  }
  void callFunction(){
  setState(() {
    controller = PageController(initialPage: widget.index);
    currentIndex=widget.index;
    indicatorIndex=widget.index;
  });
  }

  bool checkchkBox(){
   bool value=false;
    if(currentIndex==0&&LocaleHandler.showgenders=="true"){value=true;}
    else if(currentIndex==1&&LocaleHandler.showheights=="true"){value=true;}
    else if(currentIndex==4&&LocaleHandler.showsexualOreintations=="true"){value=true;}
    else{value=false;}
    return value;
  }

  Future callFunctio(bool val)async{
    Provider.of<editProfileController>(context,listen: false).saveValue(LocaleHandler.gender,LocaleHandler.height,LocaleHandler.jobtitle,
        LocaleHandler.education,LocaleHandler.sexualOreintation,LocaleHandler.ideal,LocaleHandler.cookingSkill,LocaleHandler.smokingopinion);
  }

  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return PopScope(
      canPop: true,
      onPopInvoked: callFunctio,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        // backgroundColor: color.backGroundClr,
        appBar:commonBar(context, Colors.transparent,press: (){Get.back();callFunctio(false);}),
        body: Stack(
          children: [
            SizedBox(
              height: size.height,
              width: size.width,
              child: Image.asset(AssetsPics.background,fit: BoxFit.cover,),
            ),
            Padding(
              padding:  EdgeInsets.only(left: 20,right: 20,top: 11.h,bottom: 3.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 3.h-2),
                      Expanded(
                        child: PageView.builder(
                          controller: controller,
                          itemCount: LocaleHandler.basicInfo? pages.length:pages2.length,
                          onPageChanged: (indexx) {
                            setState(() {currentIndex = indexx;});
                            indicatorIndex = indexx;
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          itemBuilder: (BuildContext context, int index) {
                            return LocaleHandler.basicInfo? pages[index]:pages2[index];
                          },
                        ),
                      ),
                ],
              ),
            ),
            Positioned(bottom: 0.0,child: Container(height: 11.h,width: size.width,
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(
                    color: color.hieghtGrey,
                    blurRadius: 5.0,
                  ),]
              ),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                LocaleHandler.basicInfo==false?SizedBox(): currentIndex==3||currentIndex==2||currentIndex==5?SizedBox(): Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 3.h+2,
                      width: 30,
                      child: Checkbox(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        focusColor: Colors.white,
                        checkColor: Colors.white,
                        activeColor: color.txtBlue,
                        value: checkchkBox(),
                        onChanged: (bool? value) {
                          if (value != null) {
                            setState(() {
                              if(currentIndex==0){LocaleHandler.showgenders=value.toString();}
                              else if(currentIndex==1){LocaleHandler.showheights=value.toString();}
                              else if(currentIndex==4){LocaleHandler.showsexualOreintations=value.toString();}
                              // textValue = value;
                            });
                          }
                        },
                      ),
                    ),
                     Text(currentIndex==4?"Display your orientation in profile":
                      "Display on profile",
                      style: TextStyle(
                        fontFamily: FontFamily.hellix,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: color.txtgrey,
                        //height: 15/12,
                      ),
                      textAlign: TextAlign.left,
                    )
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(LocaleHandler.basicInfo?pages.length:pages2.length, (int index) {
                    return Container(
                      margin: const EdgeInsets.only(left: 2.5,right: 2.5,bottom: 12.0),
                      width: indicatorIndex == index?15: 12.0,
                      height: indicatorIndex == index?15: 12.0,
                      decoration: BoxDecoration(
                        color:indicatorIndex == index? color.txtWhite:Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: indicatorIndex == index ? Colors.blue : color.txtgrey, width: indicatorIndex == index ? 3 : 1.5 ,),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 1.h),
              ],
            ),
            )),
          ],
        ),
      ),
    );
  }

  void buttonPressedFun(){
    setState(() {
      if(currentIndex+1<pages.length){
          currentIndex = currentIndex+1;
      }else{
        // Get.to(()=>const SignUpDetailsCompletedScreen());
      }
/*      if(currentIndex==1){}
      else if(currentIndex==2){}
      else if(currentIndex==3){}
      else if(currentIndex==4){}
      else if(currentIndex==5){}
      else if(currentIndex==6){}
      else if(currentIndex==7){}
      else if(currentIndex==8){}
      else if(currentIndex==9){}
      else if(currentIndex==10){
        if(LocaleHandler.passMatched==true && LocaleHandler.cpassMatched==true){
          Get.to(()=>const SignUpDetailsCompletedScreen());}else{showToastMsg("Conrfirm Password is Matched!");} }*/
    });
  }
}
