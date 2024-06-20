import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/widgets/text_widget.dart';

class VacationBestIdealScreen extends StatefulWidget {
  const VacationBestIdealScreen({Key? key}) : super(key: key);

  @override
  State<VacationBestIdealScreen> createState() => _VacationBestIdealScreenState();
}

class _VacationBestIdealScreenState extends State<VacationBestIdealScreen> {
  List<String> vacation = [
    "Beach Bum Bliss",
    "Mountain Marvels",
    "City Slicker Escapades",
    "Cultural Quests & Feasts"
  ];
  int? selectedVacation;

  @override
  void initState() {
    check();
    super.initState();
  }

  void check(){
    if(LocaleHandler.EditProfile&&LocaleHandler.dataa["ideal_vacation"]!=null&&LocaleHandler.ideal!=""){
      // if(vacation.contains(LocaleHandler.dataa["ideal_vacation"])){
      if(vacation.contains(LocaleHandler.dataa["ideal_vacation"])){
        int index = vacation.indexOf(LocaleHandler.ideal);
        selectedVacation=index;
        // selcetedIndex=index;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 3.h-2),
        buildText("Best ideal vacation", 28, FontWeight.w600, color.txtBlack),
        const SizedBox(height: 8),
        buildText("You can choose any that best describe your\nideal vacation.", 16, FontWeight.w500, color.txtBlack, fontFamily: FontFamily.hellix,),
        // const SizedBox(height: 29),
        SizedBox(
          child: ListView.builder(
            padding: EdgeInsets.only(top: 10),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: vacation.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedVacation = index;
                    LocaleHandler.ideal=vacation[index].toString();
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(top: 10),
                  alignment: Alignment.center,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: color.txtWhite,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: selectedVacation == index ? color.txtBlue : color.txtWhite,
                    ),
                  ),
                  child: buildText2(vacation[index], 18, FontWeight.w600, color.txtBlack,),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
