import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/controller/detail_controller.dart';
import 'package:slush/screens/feed/tutorials/tutorial.dart';
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

  // bool textValue=true;
  // int selcetedIndex=-1;
  ValueNotifier<bool> textValue = ValueNotifier(true);
  ValueNotifier<int> selcetedIndex = ValueNotifier(-1);

  void selectedValue(){
    if(LocaleHandler.sexualOreintation == "straight"){
      selcetedIndex.value = 0;
    }else if(LocaleHandler.sexualOreintation == "gay"){
      selcetedIndex.value = 1;
    }
    else if(LocaleHandler.sexualOreintation == "lesbian"){
      selcetedIndex.value = 2;
    } else if(LocaleHandler.sexualOreintation == "bisexual"){
      selcetedIndex.value = 3;
    } else if(LocaleHandler.sexualOreintation == "asexual"){
      selcetedIndex.value = 4;
    } else if(LocaleHandler.sexualOreintation == "demisexual"){
      selcetedIndex.value = 5;
    } else if(LocaleHandler.sexualOreintation == "pansexual"){
      selcetedIndex.value = 6;
    } else if(LocaleHandler.sexualOreintation == "queer"){
      selcetedIndex.value = 7;
    } else if(LocaleHandler.sexualOreintation == "questioning"){
      selcetedIndex.value = 8;
    }else{
      selcetedIndex.value = -1;
    }
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
        selcetedIndex.value=index;
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
        LocaleHandler.EditProfile?const SizedBox(): buildText("Choose one option that best represents you.", 15, FontWeight.w500, color.txtBlack,fontFamily: FontFamily.hellix),
        // const SizedBox(height: 29),
        Expanded(
          child: Consumer<detailedController>(
              builder: (context,value,child) {
                return ListView.builder(
                    padding: const EdgeInsets.only(top: 20,bottom: 100),
                    itemCount: items.length,
                    itemBuilder: (context,index){
                      return value.gender!="female" && items[index].title=="Lesbian" ? const SizedBox():
                      value.gender!="male" && items[index].title=="gay" ? const SizedBox():
                      GestureDetector(
                        onTap: (){
                          selcetedIndex.value=index;
                          LocaleHandler.sexualOreintation=items[index].title.toString().toLowerCase();
                        },
                        child: ValueListenableBuilder(valueListenable: selcetedIndex,
                            builder: (context,value,child) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 15),
                                height: 8.h-2,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                                    color: color.txtWhite,
                                    border: Border.all(width: 1,color: selcetedIndex.value==index?color.txtBlue:color.txtWhite)
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20,right: 16,top: 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      buildText(items[index].title, 18, FontWeight.w600, color.txtBlack),
                                      CircleAvatar(
                                        backgroundColor: selcetedIndex.value==index?color.txtBlue:color.txtBlack,
                                        radius: 9,
                                        child: CircleAvatar(
                                          radius: 8,
                                          backgroundColor: selcetedIndex.value==index?color.txtWhite:color.txtWhite,
                                          // backgroundImage: SvgPicture.asset(AssetsPics.arrowLeft),
                                          child: selcetedIndex.value==index?SvgPicture.asset(AssetsPics.blueTickCheck,fit: BoxFit.cover,):const SizedBox(),
                                        ),
                                      )
                                    ],),
                                ),
                              );
                            }
                        ),
                      );
                    });
              }
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 3.h+2,width: 30,
              child: ValueListenableBuilder(valueListenable: textValue,
                  builder: (context,value,child) {
                    return Checkbox(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      focusColor: Colors.white,
                      checkColor: Colors.white,
                      activeColor: color.txtBlue,
                      value:textValue.value,
                      onChanged: (bool? value) {
                        if (value != null) {
                          textValue.value = value;
                          LocaleHandler.showsexualOreintations=value.toString();
                        }
                      },
                    );
                  }
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