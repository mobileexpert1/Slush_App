import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/controller/edit_profile_controller.dart';
import 'package:slush/widgets/text_widget.dart';

bool textValue = false;

class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key});

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  // int activeValue = 1;
  ValueNotifier<int>  activeValue1=ValueNotifier<int>(-1);

  @override
  void initState() {
    check();
    super.initState();
  }

  void check(){
    if(LocaleHandler.gender=="male"){activeValue1.value = 1;}
    else if(LocaleHandler.gender=="female"){activeValue1.value = 2;}
    else if(LocaleHandler.gender=="other"){activeValue1.value = 3;}
    else{activeValue1.value = -1;}
  }

  @override
  Widget build(BuildContext context) {
    final editProfile=Provider.of<editProfileController>(context,listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SizedBox(height: 3.h-2),
        buildText("How do you identify yourself?", 28, FontWeight.w600, color.txtBlack),
        SizedBox(height: 4.h+1),
        ValueListenableBuilder(valueListenable: activeValue1, builder: (Context,val,child){
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  customIdentifier(
                    context: context,
                    onTap: () {
                      activeValue1.value=1;
                      LocaleHandler.gender="male";
                      // setState(() {activeValue = 1;LocaleHandler.gender="male";});
                      // editProfile.saveValue("male");
                    },
                    icon: Icon(Icons.male_rounded, size: 60,
                      color: activeValue1.value == 1 ? color.txtWhite : color.txtgrey,
                    ),
                    color: activeValue1.value == 1 ? color.txtBlue : Colors.white,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  buildText("Male", 16,
                      activeValue1.value == 1 ? FontWeight.w600 : FontWeight.w500,
                      activeValue1.value == 1 ?color.txtBlack: color.txtgrey,
                      fontFamily: FontFamily.hellix),
                ],
              ),
              Column(
                children: [
                  customIdentifier(
                    context: context,
                    onTap: () {
                      activeValue1.value=2;
                      LocaleHandler.gender="female";
                      // setState(() {activeValue = 2;LocaleHandler.gender="female";});
                    // editProfile.saveValue("female");
                    },
                    icon: Icon(Icons.female_rounded, size: 60,
                      color: activeValue1.value == 2 ? color.txtWhite : color.txtgrey,
                    ),
                    color: activeValue1.value == 2 ? color.txtBlue : Colors.white,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  buildText("Female", 16,
                      activeValue1.value == 2 ? FontWeight.w600 : FontWeight.w500,
                      activeValue1.value == 2 ?color.txtBlack: color.txtgrey,
                      fontFamily: FontFamily.hellix),
                ],
              ),
              Column(
                children: [
                  customIdentifier(
                    context: context,
                    onTap: () {
                      activeValue1.value=3;
                      LocaleHandler.gender="other";
                      // setState(() {activeValue = 3;LocaleHandler.gender="other";});
                    // editProfile.saveValue("other");
                    },
                    // icon: Icon(Icons.transgender_rounded,size: 60, color: activeValue == 3 ? color.txtWhite : color.txtBlack),
                    icon: Container(
                        alignment: Alignment.center,
                        child: SvgPicture.asset(activeValue1.value == 3
                            ? AssetsPics.transGenderWhite
                            : AssetsPics.transGenderBlack,width: 60,height: 60,)),
                    color: activeValue1.value == 3 ? color.txtBlue : Colors.white,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  buildText(
                      "Other",
                      16,
                      activeValue1.value == 3 ? FontWeight.w600 : FontWeight.w500,
                      activeValue1.value == 3 ?color.txtBlack: color.txtgrey,
                      fontFamily: FontFamily.hellix),
                ],
              )
            ],
          );
        }),
        const Expanded(child: SizedBox()),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 3.h+2,
              width: 30,
              child: Checkbox(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
                focusColor: Colors.white,
                checkColor: Colors.white,
                activeColor: color.txtBlue,
                value: textValue,
                onChanged: (bool? value) {
                  if (value != null) {
                    setState(() {
                      textValue = value;
                      LocaleHandler.showgenders=value.toString();
                    });
                  }
                },
              ),
            ),
            const Text(
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
        SizedBox(height: 2.h-2)
      ],
    );
  }

  customIdentifier({
    required VoidCallback onTap,
    required Widget icon,
    required Color color,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(20),

        // width: 106,
        // height: 106,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(100)),
        child: icon,
      ),
    );
  }
}
