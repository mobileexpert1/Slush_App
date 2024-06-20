import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/widgets/text_widget.dart';

class VacationSmokinOpinionScreen extends StatefulWidget {
  const VacationSmokinOpinionScreen({Key? key}) : super(key: key);

  @override
  State<VacationSmokinOpinionScreen> createState() => _VacationSmokinOpinionScreenState();
}

class _VacationSmokinOpinionScreenState extends State<VacationSmokinOpinionScreen> {
  List<String> smoking = [
    "Can't stand it.",
    "Don't mind it.",
    "I love and embrace it."
  ];
  int? selectedSmoking;

  @override
  void initState() {
    check();
    super.initState();
  }
  void check(){
    if(LocaleHandler.EditProfile&&LocaleHandler.dataa["smoking_opinion"]!=null&&LocaleHandler.smokingopinion!=""){
      if(smoking.contains(LocaleHandler.dataa["smoking_opinion"]+".")){
        int index = smoking.indexOf(LocaleHandler.smokingopinion+".");
        selectedSmoking=index;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         SizedBox(height: 3.h-2),
        buildText("Your opinion on smoking.", 28, FontWeight.w600, color.txtBlack),
        const SizedBox(height: 8),
        buildText("What's your thoughts?", 16, FontWeight.w500, color.txtBlack, fontFamily: FontFamily.hellix,),
        // const SizedBox(height: 29),
        SizedBox(
          child:  ListView.builder(
            padding: EdgeInsets.only(top: 10),
            shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: smoking.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedSmoking = index;
                  LocaleHandler.smokingopinion=smoking[index].replaceAll(".", "").toString();
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
                    color: selectedSmoking == index
                        ? color.txtBlue
                        : color.txtWhite,
                  ),
                ),
                child: buildText2(smoking[index], 18, FontWeight.w600, color.txtBlack),
              ),
            );
          },
        ),
        ),
      ],
    );
  }
}
