import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/loader.dart';
import 'package:slush/screens/events/bottomNavigation.dart';
import 'package:slush/screens/sign_up/vacation/cooking_skill.dart';
import 'package:slush/screens/sign_up/vacation/distance_prefrences.dart';
import 'package:slush/screens/sign_up/vacation/ideal_vacatioon.dart';
import 'package:slush/screens/sign_up/vacation/smoking_opinion.dart';
import 'package:slush/widgets/app_bar.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:http/http.dart'as http;
import 'package:slush/widgets/toaster.dart';

class VacationDetailsScreen extends StatefulWidget {
  const VacationDetailsScreen({Key? key}) : super(key: key);

  @override
  State<VacationDetailsScreen> createState() => _VacationDetailsScreenState();
}

class _VacationDetailsScreenState extends State<VacationDetailsScreen> {
  List pages=const[
    VacationBestIdealScreen(),
    VacationDistancePrefScreen(),
    VacationCookingSkillScreen(),
    VacationSmokinOpinionScreen(),
  ];

  int currentIndex=0;
  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      // backgroundColor: color.backGroundClr,
      appBar: commonBarWithText(context, Colors.transparent,press: (){
        setState(() {
          if(currentIndex!=0){
            currentIndex = currentIndex-1;}else{
            Get.back();
          }});
      },
      press2: (){
        Get.offAll(()=>BottomNavigationScreen());
      }
      ),
      body: Stack(
        children: [
          SizedBox(
            height: size.height,
            width: size.width,
            child: Image.asset(AssetsPics.background,fit: BoxFit.cover,),
          ),
          Padding(
            padding:  EdgeInsets.only(left: 15,right: 15,top: 11.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 3.h-2),
                // buildText2("- - - - - - - -", 28, FontWeight.w600, color.txtBlack),
                Container(
                  height: 2.h,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: pages.length,
                      shrinkWrap: true,
                      itemBuilder: (context,index){
                        return index==currentIndex?
                        Container(height: 3.h+2, width: 20, child: CircleAvatar(radius: 9,child: SvgPicture.asset(AssetsPics.Ellipse),))
                            : Container(
                          height: 2.h-4,
                          margin: EdgeInsets.all(4),
                          width: 14,decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),color:
                        index<currentIndex?
                        color.txtBlue:color.lightestBlue),
                        );
                      }),
                ),
                Expanded(child: IndexedStack(
                  index: currentIndex,
                  children: const [
                    VacationBestIdealScreen(),
                    VacationDistancePrefScreen(),
                    VacationCookingSkillScreen(),
                    VacationSmokinOpinionScreen(),
                  ],
                ),),
                blue_button(context, "Next",press: (){
                  setState(() {
                    if(currentIndex+1<pages.length){
                      if(LocaleHandler.ideal!="" && currentIndex==0){currentIndex = currentIndex+1;}
                      else if(LocaleHandler.distance!="" && currentIndex==1){currentIndex = currentIndex+1;}
                      else if(LocaleHandler.cookingSkill!="" && currentIndex==2){currentIndex = currentIndex+1;}
                      else{showToastMsg("Please Select the Value");}
                      // else if(LocaleHandler.smokingopinion!="" && currentIndex==3){currentIndex = currentIndex+1;}
                    }
                    else{
                      if(LocaleHandler.smokingopinion!=""){
                        // hitDetailompletedAPi(LocaleHandler.nextDetailAction);
                        hitDetailompletedAPi("fill_ideal_vacation");
                      }
                      // Get.to(()=>BottomNavigationScreen());
                    }
                  });
                }),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future hitDetailompletedAPi(String action)async{
    setState(() {LoaderOverlay.show(context);});
    final url=ApiList.detailCompleted;
    print(url);
    var uri=Uri.parse(url);
    var response=await http.post(uri,
    headers:<String,String>{
      'Content-Type': 'application/json',
      "Authorization":"Bearer ${LocaleHandler.accessToken}"
      // "Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InRlc3QxMDVAeW9wbWFpbC5jb20iLCJzdWIiOjY3NSwianRpIjoiMzdmNDMxMGNkNDI5ODkyYTMzMjYwNjdjYWYzODE0YjhmM2ViNGUzNDMyYjEyYjI0ZDUzMzAwOWVlMWNkNjk3NiIsImlhdCI6MTcxMTk3MzQ2NSwiZXhwIjoxNzQzNTA5NDY1fQ.y3YxH0b4vdrnVszdyawK6wrhsD1rpouSGOqIsvgGhLU"
    },
      body: jsonEncode({
        "action":action,
        "ideal_vacation":LocaleHandler.ideal,
        "distance":LocaleHandler.distance,
        "cooking_skill":LocaleHandler.cookingSkill,
        "smoking_opinion":LocaleHandler.smokingopinion
      })
    );
    var data=jsonDecode(response.body)["data"];
    setState(() {LoaderOverlay.hide();});
    if(response.statusCode==201){
        if(data["nextDetailAction"]=="none"){
          Get.offAll(()=>BottomNavigationScreen());
        }
      else{hitDetailompletedAPi(data["nextDetailAction"]);}
    }
    print(data);
  }
}