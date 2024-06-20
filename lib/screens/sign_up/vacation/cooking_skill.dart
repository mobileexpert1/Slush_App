import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/widgets/text_widget.dart';

class VacationCookingSkillScreen extends StatefulWidget {
  const VacationCookingSkillScreen({Key? key}) : super(key: key);

  @override
  State<VacationCookingSkillScreen> createState() => _VacationCookingSkillScreenState();
}

class _VacationCookingSkillScreenState extends State<VacationCookingSkillScreen> {
  List<String> cooking = [
    "Master of the Spatula",
    "Microwave Magician",
    "Recipe Rescuer",
    "Burnt Offerings Specialist"
  ];
  int? selectedSkill;

@override
  void initState() {
  check();
  super.initState();
  }

  void check(){
    if(LocaleHandler.EditProfile&&LocaleHandler.dataa["cooking_skill"]!=null&&LocaleHandler.cookingSkill!=""){
      if(cooking.contains(LocaleHandler.dataa["cooking_skill"])){
        int index = cooking.indexOf(LocaleHandler.cookingSkill);
        selectedSkill=index;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           SizedBox(height: 3.h-2),
          buildText("Cooking skill", 28, FontWeight.w600, color.txtBlack),
          const SizedBox(height: 8),
          buildText("You can choose any that best describe your skill.", 16, FontWeight.w500, color.txtBlack, fontFamily: FontFamily.hellix,),
          // const SizedBox(height: 29),
          SizedBox(
            child: ListView.builder(
            shrinkWrap: true,
              padding: EdgeInsets.only(top: 10),
              physics: const NeverScrollableScrollPhysics(),
            itemCount: cooking.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedSkill = index;
                    LocaleHandler.cookingSkill=cooking[index].toString();
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  alignment: Alignment.center,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: color.txtWhite,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: selectedSkill == index
                          ? color.txtBlue
                          : color.txtWhite,
                    ),
                  ),
                  child: buildText2(cooking[index], 18, FontWeight.w600, color.txtBlack,),
                ),
              );
            },
          ),
          ),
        ],
      ),
    );
  }
}
