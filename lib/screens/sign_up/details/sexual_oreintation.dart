import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/widgets/text_widget.dart';

class DetailSexualOreintScreen extends StatefulWidget {
  const DetailSexualOreintScreen({Key? key}) : super(key: key);

  @override
  State<DetailSexualOreintScreen> createState() => _DetailSexualOreintScreenState();
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}

class _DetailSexualOreintScreenState extends State<DetailSexualOreintScreen> {
  List<SexualOreintation> items=[
    SexualOreintation(1, "Straight"),
    SexualOreintation(2, "Gay"),
    SexualOreintation(3, "Lesbian"),
    SexualOreintation(4, "Bisexual"),
    SexualOreintation(5, "Asexual"),
    SexualOreintation(6, "Demisexual"),
    SexualOreintation(7, "Pansexual"),
    SexualOreintation(8, "Queer"),
    SexualOreintation(9, "Questioning"),
  ];

  List itemss=[
    "Straight","Gay","Lesbian","Bisexual","Asexual","Demisexual","Pansexual","Queer","Questioning"
  ];

  bool textValue=true;
  int selcetedIndex=-1;

  void selectedValue(){
    if(LocaleHandler.sexualOreintation == "straight"){
      selcetedIndex = 0;
    }else if(LocaleHandler.sexualOreintation == "gay"){
      selcetedIndex = 1;
    }
    else if(LocaleHandler.sexualOreintation == "lesbian"){
      selcetedIndex = 2;
    } else if(LocaleHandler.sexualOreintation == "bisexual"){
      selcetedIndex = 3;
    } else if(LocaleHandler.sexualOreintation == "asexual"){
      selcetedIndex = 4;
    } else if(LocaleHandler.sexualOreintation == "demisexual"){
      selcetedIndex = 5;
    } else if(LocaleHandler.sexualOreintation == "pansexual"){
      selcetedIndex = 6;
    } else if(LocaleHandler.sexualOreintation == "queer"){
      selcetedIndex = 7;
    } else if(LocaleHandler.sexualOreintation == "questioning"){
      selcetedIndex = 8;
    }else{
      selcetedIndex = -1;
    }
    setState(() {});
  }


  @override
  void initState() {
    check();
    selectedValue();

    super.initState();
  }
  void check(){
    if(LocaleHandler.EditProfile){
      if(itemss.contains(LocaleHandler.dataa["sexuality"].toString().capitalize())){
        int index = itemss.indexOf(LocaleHandler.sexualOreintation.toString().capitalize());
        selcetedIndex=index;
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         SizedBox(height:LocaleHandler.EditProfile?0: 3.h-2),
        LocaleHandler.EditProfile? buildText("Choose one option that best represents you.", 28, FontWeight.w600, color.txtBlack):
        buildText2("Your sexual orientation?", 28, FontWeight.w600, color.txtBlack),
        const SizedBox(height: 8),
        LocaleHandler.EditProfile?SizedBox(): buildText("Choose one option that best represents you.", 15, FontWeight.w500, color.txtBlack,fontFamily: FontFamily.hellix),
        // const SizedBox(height: 29),
        Expanded(
          child: ListView.builder(
              padding: EdgeInsets.only(top: 20,bottom: 100),
              itemCount: items.length,
              itemBuilder: (context,index){
                return GestureDetector(
                  onTap: (){
                    setState(() {
                      selcetedIndex=index;
                      LocaleHandler.sexualOreintation=items[index].title.toString().toLowerCase();
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    height: 8.h-2,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                        color: color.txtWhite,
                        border: Border.all(width: 1,color: selcetedIndex==index?color.txtBlue:color.txtWhite)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20,right: 16,top: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          buildText(items[index].title, 18, FontWeight.w600, color.txtBlack),
                          CircleAvatar(
                            backgroundColor: selcetedIndex==index?color.txtBlue:color.txtBlack,
                            radius: 9,
                            child: CircleAvatar(
                              radius: 8,
                              backgroundColor: selcetedIndex==index?color.txtWhite:color.txtWhite,
                              // backgroundImage: SvgPicture.asset(AssetsPics.arrowLeft),
                              child: selcetedIndex==index?SvgPicture.asset(AssetsPics.blueTickCheck,fit: BoxFit.cover,):SizedBox(),
                            ),
                          )
                        ],),
                    ),
                  ),
                );
              }),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 3.h+2,width: 30,
              child: Checkbox(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                focusColor: Colors.white,
                checkColor: Colors.white,
                activeColor: color.txtBlue,
                value:textValue,
                onChanged: (bool? value) {
                  if (value != null) {
                    setState(() {
                      textValue = value;
                      LocaleHandler.showsexualOreintation=value;
                      LocaleHandler.showsexualOreintations=value.toString();
                    });
                  }
                },
              ),
            ),
            const Text(
              "Show your orientation on profile?",
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
        SizedBox(height: 2.h-4)
      ],);
  }
}

class SexualOreintation{
  int Id;
  String title;
  SexualOreintation(this.Id,this.title);
}