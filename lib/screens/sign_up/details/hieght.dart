import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:wheel_slider/wheel_slider.dart';

class DetailHieghtScreen extends StatefulWidget {
  const DetailHieghtScreen({Key? key}) : super(key: key);

  @override
  State<DetailHieghtScreen> createState() => _DetailHieghtScreenState();
}

class _DetailHieghtScreenState extends State<DetailHieghtScreen> {
  bool textValue=true;
  int hieghtCm=150;
  int hieghtFt=0;
  int hieghtInch=0;
  String hightIn="cm";

  @override
  void initState(){check();
    super.initState();
  }

  void check(){
    if(LocaleHandler.EditProfile&&LocaleHandler.dataa["height"]!=null&&LocaleHandler.height!=""){
    hieghtCm= int.parse(LocaleHandler.height);}
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         SizedBox(height:LocaleHandler.EditProfile?0: 3.h-3),
       LocaleHandler.EditProfile? buildText("How tall are you?", 28, FontWeight.w600, color.txtBlack) : buildText("Please provide your height.", 28, FontWeight.w600, color.txtBlack),
        const SizedBox(height: 8),
        LocaleHandler.EditProfile?SizedBox():  buildText("How tall are you?", 15, FontWeight.w500, color.txtBlack,fontFamily: FontFamily.hellix),
         SizedBox(height: 3.h),
        Expanded(
          flex: 12,
          child: Container(
            // height: 48.h-2,
            // height: 375,
            width: MediaQuery.of(context).size.width-30,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
              color: Colors.white),
            child:hightIn=="cm"? WheelSlider.number(
              isVibrate: false,
              // perspective: 0.0015,
              perspective: 0.0029,
              totalCount: 250,
              initValue: hieghtCm,
              unSelectedNumberStyle: const TextStyle(fontSize: 30, color: color.dropDowngreytxt, fontWeight: FontWeight.w700,
              decorationStyle: TextDecorationStyle.dashed),
              scrollPhysics: const BouncingScrollPhysics(),
              selectedNumberStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 32, color: color.txtBlack),
              currentIndex: hieghtCm,
              onValueChanged: (val) {setState(() {
                hieghtCm = val;
                LocaleHandler.height=val.toString();
                LocaleHandler.heighttype="cm";
              });},
              hapticFeedbackType: HapticFeedbackType.heavyImpact,
              horizontal: false,
              allowPointerTappable:false ,
              background: const Padding(
                padding: EdgeInsets.only(left: 90,top: 11),
                child: Text("cm"),
              ),
              animationType: Curves.bounceInOut,
              customPointer: IgnorePointer(
                child: Container(
                  // padding: EdgeInsets.only(top: 50),
                  margin: const EdgeInsets.only(bottom: 9),
                  height: 7.h,width: 150,
                  decoration: const BoxDecoration(border: Border(top: BorderSide(width: 1,
                  color: color.disableButton
                  ),bottom: BorderSide(width: 1, color: color.disableButton))),
                ),
              ),
              // enableAnimation: true,
              horizontalListHeight: 100.0,
              horizontalListWidth: 100.0,
              isInfinite: false,
              itemSize: 58.0,
              // pointerColor: Colors.red,
              showPointer: true,
            )
            :Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              WheelSlider.number(
                isVibrate: false,
                // perspective: 0.0015,
                perspective: 0.0029,
                totalCount: 8,
                initValue: 4,
                unSelectedNumberStyle: const TextStyle(fontSize: 30, color: color.dropDowngreytxt, fontWeight: FontWeight.w700),
                selectedNumberStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 32, color: color.txtBlack),
                currentIndex: hieghtFt,
                onValueChanged: (val) {
                  setState(() {
                    hieghtFt = val;
                    LocaleHandler.height=hieghtFt.toString()+"'"+hieghtInch.toString();
                    LocaleHandler.heighttype="ft";
                  });
                },
                hapticFeedbackType: HapticFeedbackType.heavyImpact,
                horizontal: false,
                allowPointerTappable:false ,
                background: const Padding(
                  padding: EdgeInsets.only(left: 40,top: 20),
                  child: Text("ft"),
                ),
                animationType: Curves.bounceInOut,
                customPointer: IgnorePointer(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 9),
                    height: 7.h,width: 150,
                    decoration: const BoxDecoration(border: Border(top: BorderSide(width: 1, color: color.disableButton),bottom: BorderSide(width: 1,
                        color: color.disableButton
                    ))),
                  ),
                ),
                enableAnimation: false,
                horizontalListHeight: 100.0,
                horizontalListWidth: 100.0,
                isInfinite: false,
                itemSize: 58.0,
                // pointerColor: Colors.red,
                showPointer: true,
                verticalListWidth: 80,
              ),
                WheelSlider.number(
                  isVibrate: false,
                  // perspective: 0.0015,
                  perspective: 0.0029,
                  totalCount: 11,
                  initValue: 4,
                  unSelectedNumberStyle: const TextStyle(fontSize: 30, color: color.dropDowngreytxt, fontWeight: FontWeight.w700),
                  selectedNumberStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 32, color: color.txtBlack),
                  currentIndex: hieghtInch,
                  onValueChanged: (val) {
                    setState(() {
                      hieghtInch = val;
                      LocaleHandler.height=hieghtFt.toString()+"'"+hieghtInch.toString();
                      LocaleHandler.heighttype="ft";
                    });
                  },
                  hapticFeedbackType: HapticFeedbackType.heavyImpact,
                  horizontal: false,
                  allowPointerTappable:false ,
                  background: const Padding(
                    padding: EdgeInsets.only(left: 40,top: 20),
                    child: Text("in"),
                  ),
                  animationType: Curves.bounceInOut,
                  customPointer: IgnorePointer(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 9),
                      height: 7.h,width: 150,
                      decoration: const BoxDecoration(border: Border(top: BorderSide(width: 1, color: color.disableButton),bottom: BorderSide(width: 1,
                          color: color.disableButton
                      ))),
                    ),
                  ),
                  enableAnimation: false,
                  horizontalListHeight: 100.0,
                  horizontalListWidth: 100.0,
                  isInfinite: false,
                  itemSize: 58.0,
                  // pointerColor: Colors.red,
                  showPointer: true,
                  verticalListWidth: 80,
                ),

            ],),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: (){
                setState(() {
                  hightIn="ft";
                  LocaleHandler.heighttype=hightIn;
                });
              },
            child: Column(
              children: [
               Icon(Icons.arrow_drop_up_rounded,color: hightIn=="ft"? color.txtBlue:Colors.transparent),
                buildText("ft in", 18, FontWeight.w500,hightIn=="ft"?color.txtBlue: color.txtBlack),
              ],
            ),
          ),
          Column(
            children: [
              const Text(""),
              Container(margin: const EdgeInsets.only(left: 8,right: 8), height: 16,width: 2,color:  color.hieghtGrey),
            ],
          ),
          GestureDetector(
            onTap: (){
              setState(() {
                hightIn="cm";
                LocaleHandler.heighttype=hightIn;
              });
            },
            child: Column(
              children: [
                Icon(Icons.arrow_drop_up_rounded,color:hightIn=="cm"? color.txtBlue:Colors.transparent),
                buildText("cm", 18, FontWeight.w500,hightIn=="cm"?color.txtBlue: color.txtBlack),
              ],
            ),
          ),
        ],),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 3.h,
              width: 30,
              child: Checkbox(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                focusColor: Colors.white,
                checkColor: Colors.white,
                activeColor: color.txtBlue,
                value:textValue,
                onChanged: (bool? value) {
                  if (value != null) {
                    setState(() {
                      textValue = value;
                      LocaleHandler.showheight=value;
                      LocaleHandler.showheights=value.toString();
                    });
                  }
                },
              ),
            ),
            buildText("Display on profile", 16, FontWeight.w500, color.txtBlack,fontFamily: FontFamily.hellix),
          ],),
         SizedBox(height: 2.h-2)
      ],);
  }
}
