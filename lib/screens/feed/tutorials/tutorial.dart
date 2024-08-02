
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/controller/controller.dart';
import 'package:slush/screens/feed/tutorials/controller_class.dart';
import 'package:slush/widgets/text_widget.dart';

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
          return LocaleHandler.scrollLimitreached?const SizedBox(): Container(
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
      Consumer<reelController>(builder: (ctx,val,child){
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
            child: Consumer<reelController>(builder: (context,val,child){
           return val.data==null?const CircleAvatar(radius: 32): SizedBox(width: 75, height: 75,child: ClipOval(child: CachedNetworkImage(imageUrl: val.data[0]["user"]["avatar"],fit: BoxFit.cover,
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
            child: Consumer<reelController>(builder: (ctx,val,child)
              {return val.data==null?SizedBox(): Column(
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
              Container(alignment: Alignment.topRight, child: SvgPicture.asset(AssetsPics.reelFilterIcon,fit: BoxFit.cover,height: 48)),
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