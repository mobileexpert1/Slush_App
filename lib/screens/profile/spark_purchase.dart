import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:http/http.dart'as http;
import 'package:slush/widgets/toaster.dart';

class SparkPurchaseScreen extends StatefulWidget {
  const SparkPurchaseScreen({Key? key}) : super(key: key);

  @override
  State<SparkPurchaseScreen> createState() => _SparkPurchaseScreenState();
}

class _SparkPurchaseScreenState extends State<SparkPurchaseScreen> {
  int selectedIndex=2;
  String sparktext="Get 3 Sparks for £4.99";
  Future purchaseSpark(int sparkCount)async{
    final url=ApiList.sparkPurchase;
    var uri=Uri.parse(url);
    var response=await http.post(uri,
        headers: {'Content-Type': 'application/json', "Authorization": "Bearer ${LocaleHandler.accessToken}"},
    body: jsonEncode({"spark_value":sparkCount})
    );
    if(response.statusCode==201){}
    else if(response.statusCode==401){showToastMsgTokenExpired();}
    else{}
  }
  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: size.height,width: size.width,
            child: Image.asset(AssetsPics.bluebg,fit: BoxFit.cover,),),
          SafeArea(child: Padding(
            padding: const EdgeInsets.only(left: 16,right: 16,top: 20,bottom: 18),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: (){Get.back();},
                    child: Container(
                      height: 26,width: 26,
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(shape: BoxShape.circle,color: Colors.white,
                          boxShadow:[
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 20.0,
                                offset: Offset(0.0,10.0)
                            )
                          ]
                      ),
                      child: Icon(Icons.clear,color: color.txtBlue,size: 20),
                    ),
                  )
                ],),
              SizedBox(height: 25),
              SvgPicture.asset(AssetsPics.sparkWhiteCirlce),
              buildText("Purchase Sparks", 28, FontWeight.w600, color.txtWhite),
              buildText("Get Noticed and Stand Out!", 25, FontWeight.w400, color.txtWhite),
              SizedBox(height: 4.h),
              subScriptionOption(context),
              Spacer(),
              white_button(context, sparktext,press: (){
                setState(() {
                  int count=selectedIndex==1?1:selectedIndex==2?3:5;
                  LocaleHandler.sparkAndVerification=true;
                  purchaseSpark(count);
                  Get.back(result: true);
                });
              })
            ],),
          ))
        ],
      ),
    );
  }

  Widget subScriptionOption(BuildContext context) {
    return Container(
      height: 25.h+2,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(children: [
            GestureDetector(
              onTap: (){setState(() {selectedIndex=1;
              sparktext="Get 1 Sparks for £0.99";
              });},
              child: buildContainer(context, "1", "£0.99"),
            ),
            GestureDetector(
              onTap: (){setState(() {selectedIndex=2;
              sparktext="Get 3 Sparks for £1.99";
              });},
              child: buildContainer(context, "3", "£1.99"),
            ),
            GestureDetector(
              onTap: (){setState(() {selectedIndex=3;
              sparktext="Get 5 Sparks for £.99";
              });},
              child: buildContainer(context, "5", "£2.99"),
            ),
          ],),
          selectedIndex==2? GestureDetector(
            onTap: () {
              setState(() {});
              selectedIndex = 2 ;
            },
            child: Container(
              height: 185 ,
              // width: MediaQuery.of(context).size.width/3.5,
              width: MediaQuery.of(context).size.width/2.9,
              decoration: BoxDecoration(color: color.txtBlue ,
                  borderRadius: BorderRadius.circular(12)
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(AssetsPics.whiteSpark ,fit: BoxFit.fill,semanticsLabel: "Splash_svg",),
                  const SizedBox(height: 5),
                  buildText("3", 20, FontWeight.w600, color.txtWhite ),
                  buildText("Spark", 20, FontWeight.w600,color.txtWhite ),
                  const SizedBox(height: 7),
                  buildText("£1.99", 20, FontWeight.w600, color.txtWhite ),
                ],
              ),
            ),
          ):SizedBox(),
          Positioned(
            bottom: selectedIndex == 2 ? 0 : 8,
            child: Container(
              alignment: Alignment.center,
              height: 22,
              width: 82,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: selectedIndex == 2 ? color.txtWhite : color.txtBlue
              ),
              child: buildText("Popular", 13, FontWeight.w600,selectedIndex == 2 ? color.txtBlue : color.txtWhite,fontFamily: FontFamily.hellix),
            ),
          ),
          selectedIndex==1? Positioned(
            left: 0.0,
            child: Container(
              height: 185 ,
              width: MediaQuery.of(context).size.width/3.1,
              decoration: BoxDecoration(color: color.txtBlue , borderRadius: BorderRadius.circular(12)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(AssetsPics.whiteSpark ,fit: BoxFit.fill,semanticsLabel: "Splash_svg"),
                  const SizedBox(height: 5),
                  buildText("1", 20, FontWeight.w600, color.txtWhite ),
                  buildText("Spark", 20, FontWeight.w600,color.txtWhite ),
                  const SizedBox(height: 7),
                  buildText("£0.99", 20, FontWeight.w600, color.txtWhite ),
                ],
              ),
            ),
          ):SizedBox(),
          selectedIndex==3? Positioned(
            right: 0.0,
            child: Container(
              height: 185 ,
              width: MediaQuery.of(context).size.width/3.1,
              decoration: BoxDecoration(color: color.txtBlue ,
                  borderRadius: BorderRadius.circular(12)
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(AssetsPics.whiteSpark ,fit: BoxFit.fill,semanticsLabel: "Splash_svg"),
                  const SizedBox(height: 5),
                  buildText("3", 20, FontWeight.w600, color.txtWhite ),
                  buildText("Spark", 20, FontWeight.w600,color.txtWhite ),
                  const SizedBox(height: 7),
                  buildText("£2.99", 20, FontWeight.w600, color.txtWhite ),
                ],
              ),
            ),
          ):SizedBox(),
        ],
      ),
    );
  }

  Widget buildContainer(BuildContext context,String count,String price) {
    return Container(
      height: 164,
      width: MediaQuery.of(context).size.width/3.3,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset( AssetsPics.greySpark,fit: BoxFit.fill,semanticsLabel: "Splash_svg"),
          const SizedBox(height: 5),
          buildText(count, 20, FontWeight.w600, color.txtBlack,),
          buildText("Spark", 20, FontWeight.w600, color.txtBlack,),
          const SizedBox(height: 7),
          buildText(price, 20, FontWeight.w600, color.txtBlack,),
        ],
      ),
    );
  }
}
