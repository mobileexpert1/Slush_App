import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/widgets/text_widget.dart';

class IdentifyYourself extends StatefulWidget {
  const IdentifyYourself({super.key});

  @override
  State<IdentifyYourself> createState() => _IdentifyYourselfState();
}

class _IdentifyYourselfState extends State<IdentifyYourself> {
  // int activeValue = -1;
  ValueNotifier<int> activeValue = ValueNotifier(-1);
  ValueNotifier<bool> textValue = ValueNotifier(true);
  // bool textValue = true;

  void selectedValue() {
    if (LocaleHandler.gender == "male") {
      activeValue.value = 1;
    } else if (LocaleHandler.gender == "female") {
      activeValue.value = 2;
    } else if (LocaleHandler.gender == "other") {
      activeValue.value = 3;
    } else {
      activeValue.value = -1;
    }
  }

  @override
  void initState() {
    selectedValue();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 3.h - 2),
        buildText2("Got it!", 28, FontWeight.w600, color.txtBlack),
        buildText("How do you identify yourself?", 16, FontWeight.w500,
            color.txtBlack),
        SizedBox(height: 4.h + 1),
        ValueListenableBuilder(valueListenable: activeValue,
            builder: (context,value,child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      customIdentifier(
                        context: context,
                        onTap: () {
                          activeValue.value = 1;
                          LocaleHandler.gender = "male";
                        },
                        icon: Icon(
                          Icons.male_rounded,
                          size: 60,
                          color: activeValue.value == 1 ? color.txtWhite : color.txtgrey,
                        ),
                        color: activeValue.value == 1 ? color.txtBlue : Colors.white,
                      ),
                      const SizedBox(height: 20),
                      buildText(
                          "Male",
                          16,
                          activeValue.value == 1 ? FontWeight.w600 : FontWeight.w500,
                          activeValue.value == 1 ? color.txtBlack : color.txtgrey,
                          fontFamily: FontFamily.hellix),
                    ],
                  ),
                  Column(
                    children: [
                      customIdentifier(
                        context: context,
                        onTap: () {
                          activeValue.value = 2;
                          LocaleHandler.gender = "female";
                        },
                        icon: Icon(
                          Icons.female_rounded,
                          size: 60,
                          color: activeValue.value == 2 ? color.txtWhite : color.txtgrey,
                        ),
                        color: activeValue.value == 2 ? color.txtBlue : Colors.white,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      buildText(
                          "Female",
                          16,
                          activeValue.value == 2 ? FontWeight.w600 : FontWeight.w500,
                          activeValue.value == 2 ? color.txtBlack : color.txtgrey,
                          fontFamily: FontFamily.hellix),
                    ],
                  ),
                  Column(
                    children: [
                      customIdentifier(
                        context: context,
                        onTap: () {
                          activeValue.value = 3;
                          LocaleHandler.gender = "other";
                        },
                        // icon: Icon(Icons.transgender_rounded,size: 60, color: activeValue.value == 3 ? color.txtWhite : color.txtBlack),
                        icon: Container(
                            height: 65,
                            width: 65,
                            alignment: Alignment.center,
                            child: SvgPicture.asset(activeValue.value == 3
                                ? AssetsPics.transGenderWhite
                                : AssetsPics.transGenderBlack)),
                        color: activeValue.value == 3 ? color.txtBlue : Colors.white,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      buildText(
                          "Other",
                          16,
                          activeValue.value == 3 ? FontWeight.w600 : FontWeight.w500,
                          activeValue.value == 3 ? color.txtBlack : color.txtgrey,
                          fontFamily: FontFamily.hellix),
                    ],
                  )
                ],
              );
            }
        ),
        const Expanded(child: SizedBox()),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 3.h + 2,
              width: 30,
              child: ValueListenableBuilder(valueListenable: textValue,
                  builder: (context,value,child) {
                    return Checkbox(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      focusColor: Colors.white,
                      checkColor: Colors.white,
                      activeColor: color.txtBlue,
                      value: textValue.value,
                      onChanged: (bool? value) {
                        if (value != null) {
                          textValue.value = value;
                          LocaleHandler.showgender = value;
                        }
                      },
                    );
                  }
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
        SizedBox(height: 2.h - 2)
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
        width: 106,
        height: 106,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(100)),
        child: icon,
      ),
    );
  }
}
