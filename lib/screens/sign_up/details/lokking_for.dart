import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/widgets/text_widget.dart';

class DetailLookingForScreen extends StatefulWidget {
  const DetailLookingForScreen({Key? key}) : super(key: key);

  @override
  State<DetailLookingForScreen> createState() => _DetailLookingForScreenState();
}

class _DetailLookingForScreenState extends State<DetailLookingForScreen> {
  List<lookingFor> items=[
    lookingFor(1, "Meet new people", "I want to have a good time."),
    lookingFor(2, "Casual Dating", "No stress, just going with the flow"),
    lookingFor(3, "Ready for relationship", "Seeking a lasting connection."),
  ];

  bool textValue=true;
  int selcetedIndex=-1;

  void selectedValue(){
    if(LocaleHandler.lookingfor == "meet new people"){
      selcetedIndex = 0;
    }else  if(LocaleHandler.lookingfor == "casual dating"){
      selcetedIndex = 1;
    } else  if(LocaleHandler.lookingfor == "ready for relationship"){
      selcetedIndex = 2;
    }else {
      selcetedIndex = -1;
    }
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    selectedValue();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        buildText2("What are you looking for?", 28, FontWeight.w600, color.txtBlack),
        const SizedBox(height: 8),
        buildText("Please share your reason for joining us.", 15, FontWeight.w500, color.txtBlack,fontFamily: FontFamily.hellix),
        // const SizedBox(height: 29),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(top: 30),
              itemCount: items.length,
              itemBuilder: (context,index){
                return GestureDetector(
                  onTap: (){
                    setState(() {
                      LocaleHandler.lookingfor=items[index].title.toString().toLowerCase();
                      selcetedIndex=index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    height: 75,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                    color: color.txtWhite,
                      border: Border.all(width: 1,color: selcetedIndex==index?color.txtBlue:color.txtWhite)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16,right: 16,top: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          buildText(items[index].title, 16, FontWeight.w600, color.txtBlack),
                          const SizedBox(height: 5),
                          buildText(items[index].subTitle, 15, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
                        ],),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: selcetedIndex==index?color.txtBlue:color.txtBlack,
                                radius: 9,
                                child: CircleAvatar(
                                  radius: 8,
                                  backgroundColor: selcetedIndex==index?color.txtWhite:color.txtWhite,
                                  // backgroundImage: SvgPicture.asset(AssetsPics.arrowLeft),
                                  child: selcetedIndex==index?SvgPicture.asset(AssetsPics.blueTickCheck,fit: BoxFit.cover,):const SizedBox(),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
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
                      LocaleHandler.showlookingfor=value;
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
      ],);
  }
}

class lookingFor{
  int Id;
  String title;
  String subTitle;
  lookingFor(this.Id,this.title,this.subTitle);
}