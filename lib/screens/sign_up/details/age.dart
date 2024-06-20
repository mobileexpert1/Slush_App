import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/controller/controller.dart';
import 'package:slush/widgets/text_widget.dart';import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';


class DetailAgeScreen extends StatefulWidget {
  const DetailAgeScreen({Key? key}) : super(key: key);

  @override
  State<DetailAgeScreen> createState() => _DetailAgeScreenState();
}

class _DetailAgeScreenState extends State<DetailAgeScreen> {
  DateTime? _selectedDate;
  // DateTime d = Jiffy(DateTime.now()).subtract(years: 18, months: 1).dateTime;
  DateTime d = Jiffy.now().subtract(years: 18, months: 1).dateTime;

  @override
  void initState() {
    callFunction();
    // TODO: implement initState
    super.initState();
  }
  void callFunction(){
    setState(() {
      LocaleHandler.dateTimee=convertDateTimeDisplay(d.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         SizedBox(height: 3.h-2),
        LocaleHandler.EditProfile? buildText2("What is your date of birth?", 28, FontWeight.w600, color.txtBlack)
            : Consumer<nameControllerr>(
            builder: (context,value,child){return
          buildText2("Hi, ${value.namr}", 28, FontWeight.w600, color.txtBlack);
            }),
        const SizedBox(height: 8),
        LocaleHandler.EditProfile?SizedBox(): buildText("What is your date of birth?", 15, FontWeight.w500, color.txtBlack,fontFamily: FontFamily.hellix),
       SizedBox(height: 4.h-1),
        Stack(
          children: [
            Container(height: 36.h,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),color: Colors.white,),
            width: MediaQuery.of(context).size.width-30,
            // color: color.txtWhite,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: DatePickerWidget(
                looping: false,
                firstDate: DateTime(1950, 01, 01),
                lastDate: d,
                initialDate: d,
                dateFormat: "dd-MMM-yyyy",
                locale: DatePicker.localeFromString('en'),
                onChange: (DateTime newDate, _){
                  // _selectedDate = newDate;
                  LocaleHandler.dateTimee= convertDateTimeDisplay(newDate.toString());
                  setState(() {});
                },
                pickerTheme:  DateTimePickerTheme(
                  itemTextStyle: const TextStyle(
                      letterSpacing: 1.0,
                      height: 2.0,
                      color: color.dateTxtColor, fontSize: 55,fontFamily: FontFamily.baloo2,fontWeight: FontWeight.w600),
                  dividerColor: Colors.transparent,
                  pickerHeight: 36.h,
                itemHeight: 6.h+2,
                )),
            ),
            ),
            defaultTargetPlatform == TargetPlatform.iOS?
            IgnorePointer(
              child: Container(
                margin: const EdgeInsets.only(top: 125,left: 15,right: 15),
                height: 7.h-2,width: MediaQuery.of(context).size.width-40,
                decoration: const BoxDecoration(border: Border(top: BorderSide(width: 1, color: color.disableButton
                ),bottom: BorderSide(width: 1, color: color.disableButton))),
              ),
            )
                :  IgnorePointer(
                  child: Container(
                                margin: const EdgeInsets.only(top: 114,left: 15,right: 15),
                                height: 7.h-4,width: MediaQuery.of(context).size.width-40,
                                decoration: const BoxDecoration(border: Border(top: BorderSide(width: 1, color: color.disableButton
                                ),bottom: BorderSide(width: 1, color: color.disableButton))),
                              ),
                ),
          ],
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius:3.0,backgroundColor: color.green),
          buildText(" We use this to show your age.", 14, FontWeight.w500, color.txtBlack,fontFamily: FontFamily.hellix),
        ],),
         SizedBox(height: 2.h-2)
      ],);
  }
  String convertDateTimeDisplay(String date) {
    final DateFormat displayFormater = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
    final DateFormat serverFormater = DateFormat('yyyy-MM-dd');
    final DateTime displayDate = displayFormater.parse(date);
    final String formatted = serverFormater.format(displayDate);
    return formatted;
  }
}
