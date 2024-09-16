
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/prefs.dart';
import 'package:slush/controller/controller.dart';
import 'package:slush/controller/login_controller.dart';
import 'package:slush/screens/feed/tutorials/controller_class.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:slush/widgets/thumb_class.dart';

int indexx=0;

Widget feedTutorials(BuildContext context){
  final reelTutorial=Provider.of<reelTutorialController>(context,listen: false);
  final size=MediaQuery.of(context).size;
  return GestureDetector(
    onTap: (){
      reelTutorial.increamnt();
    },
    child: Stack(children: [
      Container(
        height: size.height,
        width: size.width,
        color: Colors.black.withOpacity(0.6),
      ),
      // seventh(context),
      Consumer<reelTutorialController>(
        builder: (context,value,child){
          // return LocaleHandler.scrollLimitreached ?const SizedBox(): Container(
          return Provider.of<ReelController>(context).stopReelScroll ?const SizedBox(): Container(
          child:  value.cou==0? first(context):
          value.cou==1? second(context):
          value.cou==2? third(context):
          value.cou==3? fourth(context):
          value.cou==4?fifth(context):
          value.cou==5? sixth(context):const SizedBox()
          // :seventh(context),
          );
        },
      ),
      Consumer<ReelController>(builder: (ctx,val,child){
        return val.count==0?seventh(context):const SizedBox();
      })
      ],
    ),
  );
}

TextSpan buildTextSpan(String txt, Color clr) {
  return TextSpan(
      text: txt,
      style: TextStyle(color: clr,
        fontWeight: FontWeight.w900, fontSize:defaultTargetPlatform==TargetPlatform.iOS?26: 30,
        fontFamily: FontFamily.hellixExtraBold,));
}

Widget first(BuildContext context){
  return SafeArea(
    child: Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(left: 18,right: 18,top: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DottedBorder(
            color: color.txtWhite,
            strokeWidth: 2,
            borderType: BorderType.RRect,
            stackFit: StackFit.loose,
            dashPattern:const [10, 10],
            child: Container(
              height: 53.h,
              width: 25.h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(height: 70, width: 40, alignment: Alignment.center,
                      child: SvgPicture.asset(AssetsPics.arrow)),
                  Container(child: Image.asset(AssetsPics.pointingFingerpng)),
                  SizedBox(height: 2.h),
                  RotationTransition(
                    turns:  const AlwaysStoppedAnimation(180 / 360),
                    child: Container(height: 70, width: 40, alignment: Alignment.center,
                        child: SvgPicture.asset(AssetsPics.arrow)),
                  ),
                ],),
            ),
          ),
          SizedBox(height: 2.h),
          Text.rich(
              textAlign: TextAlign.center,
              TextSpan(children: [
                buildTextSpan('Swipe ', color.txtWhite),
                buildTextSpan('up ', color.txtBlue),
                buildTextSpan('and ', color.txtWhite),
                buildTextSpan('down ', color.txtBlue),
                buildTextSpan('to view ', color.txtWhite),
                buildTextSpan('different people ', color.txtWhite),
              ])),
        ],),),
  );
}

Widget second(BuildContext context){
  final size=MediaQuery.of(context).size;
  return SafeArea(
    child: Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(left: 18,right: 18,top: 25),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text.rich(
                  textAlign: TextAlign.center,
                  TextSpan(children: [
                    buildTextSpan('Tap ', color.txtWhite),
                    buildTextSpan('here ', color.txtBlue),
                    buildTextSpan('to see their\n profile', color.txtWhite),
                    // buildTextSpan('different people ', color.txtWhite),
                  ])),
              Container(
                padding: const EdgeInsets.only(left: 80,bottom: 40),
                  // color: Colors.red,
                  width: size.width,
                  alignment: Alignment.centerLeft,
                  child: RotationTransition(
                      turns:  const AlwaysStoppedAnimation(245 / 360),
                      child: SvgPicture.asset(AssetsPics.leftup,height: 100,))
              ),
              Container(
                  padding: const EdgeInsets.only(bottom: 15,left: 15),
                  // color: Colors.red,
                  width: size.width,
                  height: 12.h-5,
                  alignment: Alignment.centerLeft,
                  child: RotationTransition(
                      turns:  const AlwaysStoppedAnimation(0 / 360),
                      child: Image.asset(AssetsPics.pointingFingerpng,fit: BoxFit.fitHeight,)))
            ],),
           Positioned(
            bottom: 95.0,
            child: CircleAvatar(radius: 32,
            backgroundColor: Colors.transparent,
            child: Consumer<ReelController>(builder: (context,val,child){
              print("val.data");
              print(val.data);
           return val.data==null ||val.data.isEmpty?const CircleAvatar(radius: 32,backgroundImage: AssetImage(AssetsPics.demouser)):
           val.data[0]["user"]["avatar"]==null? const CircleAvatar(radius: 32,backgroundImage: AssetImage(AssetsPics.demouser)):
           SizedBox(width: 75, height: 75,child: ClipOval(child: CachedNetworkImage(imageUrl: val.data[0]["user"]["avatar"],fit: BoxFit.cover,
             placeholder: (ctx, url) => const Center(child: SizedBox()),
           )));
            })
            // AssetImage(AssetsPics.demouser),
            ),
          ),
        ],
      ),),
  );
}

Widget third(BuildContext context){
  final size=MediaQuery.of(context).size;
  return SafeArea(
    child: Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(left: 18,right: 15,top: 25),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: size.height/2-5.h),
              Text.rich(
                  textAlign: TextAlign.center,
                  TextSpan(children: [
                    buildTextSpan('If you ', color.txtWhite),
                    buildTextSpan('like ', color.txtBlue),
                    buildTextSpan(defaultTargetPlatform==TargetPlatform.iOS?'them, tap the heart button': 'them, tap the\n heart button', color.txtWhite),
                    // buildTextSpan('different people ', color.txtWhite),
                  ])),
              Container(
                  padding: const EdgeInsets.only(right: 70),
                  // color: Colors.red,
                  width: size.width,
                  height: 20.h,

                  alignment: Alignment.centerRight,
                  child: RotationTransition(
                      turns:  const AlwaysStoppedAnimation(120 / 360),
                      child: SvgPicture.asset(AssetsPics.rightup,height: 120,))
              ),
            ],),
           Positioned(
            bottom: 12.0,
            right: 0.0,
            child: SvgPicture.asset(AssetsPics.inactive,fit: BoxFit.cover,height: 75),
          ),
          Positioned(
            bottom: 0.0,
            right: 55.0,
            child: Container(
                height: 9.h-5,
                alignment: Alignment.bottomCenter,
                child: RotationTransition(
                    turns:  const AlwaysStoppedAnimation(40 / 360),
                    child: Image.asset(AssetsPics.pointingFingerpng,fit: BoxFit.fitHeight,))),
          )
        ],
      ),),
  );
}

Widget fourth(BuildContext context){
  final size=MediaQuery.of(context).size;
  return SafeArea(
    child: Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(left: 18,right: 18,top: 25),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // SizedBox(height: size.height/2-5.h),
              SizedBox(height:defaultTargetPlatform==TargetPlatform.iOS?size.height/2-8.h: size.height/2-5.h),
              Text.rich(
                  textAlign: TextAlign.center,
                  TextSpan(children: [
                    buildTextSpan('Tap ', color.txtWhite),
                    buildTextSpan('here ', color.txtBlue),
                    buildTextSpan('to see their ', color.txtWhite),
                    buildTextSpan('bio ', color.txtBlue),

                    // buildTextSpan('different people ', color.txtWhite),
                  ])),
              Container(
                  padding: const EdgeInsets.only(left: 10,top: 30,right: 140),
                  width: size.width,
                  height: 20.h,
                  // alignment: Alignment.centerRight,
                  child: RotationTransition(
                      turns:  const AlwaysStoppedAnimation(220 / 360),
                      child: SvgPicture.asset(AssetsPics.leftup)
                  )
              ),
            ],),
          Positioned(
            bottom: 28.0,
            left: 0.0,
            child: Consumer<ReelController>(builder: (ctx,val,child)
              {return val.data==null||val.data.isEmpty?const SizedBox(): Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                SizedBox(height: 1.h),
                buildText(val.data[0]["user"]["fullName"] ?? val.data[0]["user"]["nickName"]??"", 17, FontWeight.w600, color.txtWhite),
                SizedBox(height: 1.h-5),
                SizedBox(
                width: MediaQuery.of(context).size.width/1.5,
                child:  IgnorePointer(
                child: ExpandableText(val.data[0]["user"]["bio"]??"",
                style: const TextStyle(color: color.txtWhite,fontWeight: FontWeight.w500,fontSize: 15,fontFamily: FontFamily.hellix),
              expandText: '',
              expandOnTextTap: true,
              collapseOnTextTap: true,
              maxLines: 3,
              linkColor: color.txtWhite),),),],);}
            ),
          ),
          Positioned(
            bottom: 8.0,
            left: 50.0,
            child: Container(
                height: 8.h-5,
                alignment: Alignment.bottomCenter,
                child: RotationTransition(
                    turns:  const AlwaysStoppedAnimation(-40 / 360),
                    child: Image.asset(AssetsPics.pointingFingerpng,fit: BoxFit.fitHeight))),
          )
        ],
      ),),
  );
}

Widget fifth(BuildContext context){
  final size=MediaQuery.of(context).size;
  return SafeArea(
    child: Container(
      alignment: Alignment.center,
      padding:  EdgeInsets.only(left: 16,right: 18,top:defaultTargetPlatform==TargetPlatform.iOS?11: 17),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(alignment: Alignment.topLeft, child: SvgPicture.asset(AssetsPics.unMute,fit: BoxFit.cover,height: 50)),
              Container(
                  padding: const EdgeInsets.only(left: 37,top: 20),
                  width: size.width,
                  alignment: Alignment.centerLeft,
                  child: SvgPicture.asset(AssetsPics.leftup)),
              Text.rich(
                  textAlign: TextAlign.center,
                  TextSpan(children: [
                    buildTextSpan('Tap ', color.txtWhite),
                    buildTextSpan('here ', color.txtBlue),
                    buildTextSpan('to mute audio', color.txtWhite),
                    // buildTextSpan('different people ', color.txtWhite),
                  ])),
            ],),
          Positioned(
            top: 40.0,
            left: 0.0,
            child: Container(
                height: 9.h-5,
                alignment: Alignment.bottomCenter,
                child: Image.asset(AssetsPics.pointingFingerpng,fit: BoxFit.fitHeight,)),
          )
        ],
      ),),
  );
}

Widget sixth(BuildContext context){
  final size=MediaQuery.of(context).size;
  return SafeArea(
    child: Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(left: 18,right: 16,top: 17),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(alignment: Alignment.topRight, child: SvgPicture.asset(AssetsPics.reelFilterIcon,fit: BoxFit.cover,height: 50)),
              Container(
                  padding: const EdgeInsets.only(right: 55,top: 20),
                  width: size.width,
                  alignment: Alignment.centerRight,
                  child: SvgPicture.asset(AssetsPics.rightup)),
              Text.rich(
                  textAlign: TextAlign.center,
                  TextSpan(children: [
                    buildTextSpan("You're good to go, set\nyour ", color.txtWhite),
                    buildTextSpan('preferences ', color.txtBlue),
                  ])),
            ],),
          Positioned(
            top: 40.0,
            right: 10.0,
            child: Container(
                height: 9.h-5,
                alignment: Alignment.bottomCenter,
                child: Image.asset(AssetsPics.pointingFingerpng,fit: BoxFit.fitHeight,)),
          )
        ],
      ),),
  );
}


bool isChecked = false;
int selectedIndex = -1;
int distancevalue = 250;
double _startValue = 18.0;
double _endValue = 90.0;
String selectedGender = "";
List gender = ["Male", "Female", "Everyone"];
List<dynamic> _items = [];
Widget seventh(BuildContext context){
  final size=MediaQuery.of(context).size;
  return SafeArea(
    child: Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(left: 18,right: 18,top: 17),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
          onTap: () {
               selectedIndex = LocaleHandler.selectedIndexGender;
               _startValue = LocaleHandler.startage.toDouble();
               _endValue = LocaleHandler.endage.toDouble();
               distancevalue = LocaleHandler.distancevalue;
               isChecked = LocaleHandler.isChecked;
               print("LocaleHandler.startage;-;-;-${LocaleHandler.endage}");
               customReelBoxFilte(context);
               },
              child: Container(alignment: Alignment.topRight, child: SvgPicture.asset(AssetsPics.reelFilterIcon,fit: BoxFit.cover,height: 48))),
              Container(
                alignment: Alignment.centerRight,
                  // padding: const EdgeInsets.only(left: 140,top: 5),
                  width: size.width,
                  height: 25.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(child: SizedBox()),
                      Container(alignment: Alignment.bottomCenter,child: SvgPicture.asset(AssetsPics.smiley)),
                      SizedBox(width: 1.h),
                      SvgPicture.asset(AssetsPics.rightupLong),
                      SizedBox(width: 2.h),
                    ],
                  )),
             Column(children: [
               SizedBox(height: 2.h),
               buildText("Looks like you have gone through\neveryone within your preferences!", 20, FontWeight.w600,
                   color.txtWhite,fontFamily: FontFamily.hellix),
               SizedBox(height: 3.h),
               buildText2("Come back tommorrow or adjust your preferences to see more poeple", 19, FontWeight.w600,
                   color.txtWhite,fontFamily: FontFamily.hellix),
             ],)
            ],),
        ],
      ),),
  );
}

customReelBoxFilte(BuildContext context) {
  final size = MediaQuery.of(context).size;
  return showGeneralDialog(
      barrierLabel: "Label",
      transitionDuration: const Duration(milliseconds: 500),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return StatefulBuilder(builder: (context, setState) {
          return GestureDetector(
            // onTap: onTap,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Align(
                alignment: Alignment.bottomCenter,
                child: Stack(
                  children: [
                    Container(
                      // height: MediaQuery.of(context).size.height/2.5,
                        width: MediaQuery.of(context).size.width / 1.1,
                        margin: EdgeInsets.only(
                            bottom: defaultTargetPlatform == TargetPlatform.iOS ? 24 : 12,
                            top: 8, right: 7),
                        // padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: color.txtWhite,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10, top: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(alignment: Alignment.center,
                                    height: 10,
                                    width: 80,
                                  ),
                                  // SizedBox(height: 10,),
                                  buildText("Filter", 28, FontWeight.w600, color.txtBlack),
                                  const SizedBox(height: 10),
                                  buildText("Distance", 18, FontWeight.w600, color.txtBlack),
                                  const SizedBox(height: 50),
                                  Container(
                                    height: 30,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: color.txtWhite),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SliderTheme(
                                          data: SliderTheme.of(context).copyWith(
                                            trackHeight: 5.0,
                                            inactiveTickMarkColor: Colors.transparent,
                                            trackShape: const RoundedRectSliderTrackShape(),
                                            activeTrackColor: color.txtBlue,
                                            inactiveTrackColor: color.lightestBlueIndicator,
                                            activeTickMarkColor: Colors.transparent,
                                            thumbShape: CustomSliderThumb(
                                              displayValue: distancevalue,
                                            ),
                                            thumbColor: color.txtBlue,
                                            overlayColor: const Color(0xff2280EF).withOpacity(0.2),
                                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
                                            valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                                            valueIndicatorColor: Colors.blue,
                                            showValueIndicator: ShowValueIndicator.never,
                                            valueIndicatorTextStyle:
                                            const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20.0,
                                            ),
                                          ),
                                          child: Slider(
                                            min: 5.0,
                                            max: 500.0,
                                            value: distancevalue.toDouble(),
                                            divisions: 99,
                                            label: '${distancevalue.round()} km',
                                            onChanged: (value) {
                                              setState(() {
                                                distancevalue = value.toInt();
                                              });
                                            },
                                          ),
                                        ),
                                        Positioned(
                                          left: 13.0,
                                          child: IgnorePointer(
                                            child: CircleAvatar(
                                              radius: 7,
                                              child: SvgPicture.asset(AssetsPics.sliderleft),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: color.txtWhite),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10, top: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildText("Age Range", 18,
                                        FontWeight.w600, color.txtBlack),
                                    Container(
                                      height: 13.h,
                                      width: size.width,
                                      padding: const EdgeInsets.only(top: 20),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Consumer<loginControllerr>(builder:
                                              (context, valuee, index) {
                                            return Stack(
                                              children: [
                                                RangeSlider(
                                                  activeColor: color.txtBlue,
                                                  inactiveColor: color.lightestBlueIndicator,
                                                  // divisions: 9,
                                                  labels: RangeLabels(
                                                    _startValue.round().toString(),
                                                    _endValue.round().toString(),
                                                  ),
                                                  min: 18.0,
                                                  max: 100.0,
                                                  values: RangeValues(_startValue, _endValue),
                                                  onChanged: (values) {
                                                    setState(() {
                                                      _startValue = values.start;
                                                      _endValue = values.end;
                                                    });
                                                  },
                                                ),
                                                Positioned(
                                                  left: (size.width - 50) * (_startValue - 18) / (100 - 8), // Calculate left position dynamically
                                                  top: 1,
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue,
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      '${_startValue.round()}',
                                                      style: const TextStyle(color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  right: (size.width - 50) * (100 - _endValue) / (100 - 8), // Calculate right position dynamically
                                                  top: 1,
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue,
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      '${_endValue.round()}',
                                                      style: const TextStyle(color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 0, top: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildText("Show me", 18, FontWeight.w600, color.txtBlack),
                                  Container(
                                      padding: const EdgeInsets.only(left: 5),
                                      //   alignment: Alignment.center,
                                      height: 46,
                                      width: MediaQuery.of(context).size.width,
                                      // color: Colors.red,
                                      child: Row(
                                        // mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          ListView.builder(
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              scrollDirection: Axis.horizontal,
                                              itemCount: gender.length,
                                              itemBuilder: (context, index) {
                                                return Row(
                                                  children: [
                                                    GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            selectedIndex = index;
                                                            selectedGender = gender[index];
                                                          });
                                                        },
                                                        child: selectedIndex == index
                                                            ? selectedButton(gender[index], size)
                                                            : unselectedButton(gender[index], size)),
                                                    SizedBox(width: size.width * 0.02)
                                                  ],
                                                );
                                              })
                                        ],
                                      )),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Divider(thickness: 0.5, color: color.lightestBlue),
                            const SizedBox(height: 4),
                            Padding(padding: const EdgeInsets.only(left: 15, right: 15, bottom: 0, top: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildText("Verified users only", 18, FontWeight.w600, color.txtBlack),
                                  GestureDetector(
                                      onTap: () {setState(() {isChecked = !isChecked;});},
                                      child: SvgPicture.asset(isChecked == true ? AssetsPics.checkbox : AssetsPics.blankCheckbox)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Divider(thickness: 0.5, color: color.lightestBlue),
                            const SizedBox(height: 11),
                            Padding(
                              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      LocaleHandler.selectedIndexGender = -1;
                                      LocaleHandler.startage = 18;
                                      LocaleHandler.endage = 90;
                                      LocaleHandler.distancevalue = 250;
                                      LocaleHandler.isChecked = false;
                                      Get.back();
                                      _items=[LocaleHandler.selectedIndexGender,LocaleHandler.startage,LocaleHandler.endage,LocaleHandler.distancevalue,LocaleHandler.isChecked];
                                      String jsonString = jsonEncode(_items);
                                      await Preferences.setValue('filterList', jsonString);
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 56,
                                      width: MediaQuery.of(context).size.width / 2 - 40,
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          color: color.txtWhite,
                                          border: Border.all(
                                              width: 1.5,
                                              color: color.txtBlue)),
                                      child: buildText("Clear all", 18, FontWeight.w600, color.txtBlue),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      int min = _startValue.toInt();
                                      int max = _endValue.toInt();
                                      setState(() {
                                        LocaleHandler.selectedIndexGender = selectedIndex;
                                        LocaleHandler.startage = min;
                                        LocaleHandler.endage = max;
                                        LocaleHandler.distancevalue = distancevalue;
                                        LocaleHandler.isChecked = isChecked;
                                        LocaleHandler.pageIndex = 0;
                                      });
                                      Provider.of<ReelController>(context, listen: false).videoPause(true, LocaleHandler.pageIndex);
                                      Provider.of<ReelController>(context, listen: false).getVidero(context, 1, min, max, distancevalue, LocaleHandler.latitude,
                                          LocaleHandler.longitude, selectedGender == "Everyone" ? "" : selectedGender.toLowerCase());
                                      Get.back();
                                      _items=[LocaleHandler.selectedIndexGender,LocaleHandler.startage,LocaleHandler.endage,LocaleHandler.distancevalue,LocaleHandler.isChecked];
                                      String jsonString = jsonEncode(_items);
                                      await Preferences.setValue('filterList', jsonString);
                                    },
                                    // onTap: onTap2,
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 56,
                                      width: MediaQuery.of(context).size.width / 2 - 40,
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          gradient: const LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              color.gradientLightBlue,
                                              color.txtBlue
                                            ],
                                          )),
                                      child: buildText("Apply", 18, FontWeight.w600, color.txtWhite),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                        )),
                    Positioned(
                      right: 0.15,
                      top: 0.15,
                      child: GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: color.txtWhite,
                          child: SvgPicture.asset(AssetsPics.cancel),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(anim1),
          child: child,
        );
      });
}
