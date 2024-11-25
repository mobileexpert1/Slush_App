import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/controller/login_controller.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/text_widget.dart';
// import 'package:syncfusion_flutter_sliders/sliders.dart';
// import 'package:syncfusion_flutter_core/theme.dart';
import 'package:intl/intl.dart';
import 'package:slush/widgets/thumb_class.dart';

TextEditingController fromDateController = TextEditingController(
    text: "Jan 12 ,2023");
TextEditingController toDateController = TextEditingController(
    text: "Jan 24 ,2023");
List category = ["18-20", "21-25", "26-30", "31-35", "36-40", "41-50"];
int selectedIndex = 0;

// Single Button Sheet
customDialogBox({required BuildContext context,
  String? btnTxt,
  String ?img,
  String ?secontxt,
  required String title,
  required String heading,
  VoidCallback? onTapp = pressed,
  VoidCallback? onTap = pressed,
  bool? forAdvanceTap,
  bool isPng = false}) {
  return showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: "Label",
      transitionDuration: const Duration(milliseconds: 500),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return GestureDetector(
          onTap: onTapp,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                // height: MediaQuery.of(context).size.height/2.5,
                  width: MediaQuery.of(context).size.width / 1.1,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 3.h),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: color.txtWhite,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        height: 80, width: 80,
                        child: isPng ? Image.asset(img!) : SvgPicture.asset(
                            img!),
                      ),
                      const SizedBox(height: 10),
                      buildText(title, 20, FontWeight.w600, color.txtBlack),
                      secontxt == "" ? const SizedBox() : Text(secontxt!,
                        style: const TextStyle(
                          fontFamily: FontFamily.hellix,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: color.txtgrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      buildText2(heading, 17.4, FontWeight.w500, color.txtgrey,
                          fontFamily: FontFamily.hellix),
                      const SizedBox(height: 15),
                      blue_button(context, btnTxt!, press: onTap)
                    ],
                  )),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(anim1),
          child: child,
        );
      }
  );
}

//Double Button Sheet
customDialogBoxWithtwobutton(BuildContext context, String title,
    String subtitle,
    {String? btnTxt1, String? btnTxt2,
      String ?img, String ?secontxt = "",
      VoidCallback? onTap = pressed, VoidCallback? onTap1 = pressed, VoidCallback? onTap2 = pressed, bool isPng = false}) {
  return showGeneralDialog(
      barrierLabel: "Label",
      transitionDuration: const Duration(milliseconds: 500),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return GestureDetector(
          onTap: onTap,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                // height: MediaQuery.of(context).size.height/2.5,
                  width: MediaQuery.of(context).size.width / 1.1,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 3.h),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: color.txtWhite,
                    borderRadius: BorderRadius.circular(15),),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        // color: Colors.amber,
                        alignment: Alignment.center,
                        height: isPng ? 70 : 80,
                        width: isPng ? 70 : 80,
                        child: isPng ? Image.asset(img!) : SvgPicture.asset(img!),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: FontFamily.baloo2,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: color.txtBlack,
                        ),
                      ),
                      secontxt == "" ? const SizedBox() : Text(secontxt!,
                        style: const TextStyle(
                          fontFamily: FontFamily.baloo2,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: color.txtgrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontFamily: FontFamily.baloo2,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: color.txtgrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: onTap1,
                              child: Container(
                                alignment: Alignment.center,
                                height: 56,
                                // width: MediaQuery.of(context).size.width/2-45,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: color.txtWhite,
                                    border: Border.all(
                                        width: 1.5, color: color.txtBlue)
                                ),
                                child: buildText(
                                    btnTxt1!, 16.5, FontWeight.w600,
                                    color.txtBlue),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: onTap2,
                              child: Container(
                                alignment: Alignment.center,
                                height: 56,
                                // width: MediaQuery.of(context).size.width/2-45,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: const LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        color.gradientLightBlue,
                                        color.txtBlue
                                      ],)
                                ),
                                child: buildText(btnTxt2!, 18, FontWeight.w600,
                                    color.txtWhite),
                              ),
                            ),
                          ),
                        ],),
                      const SizedBox(height: 4),
                    ],
                  )),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(anim1),
          child: child,
        );
      }
  );
}

customUnmatchBoxWithtwobutton(BuildContext context, String title,
    String subtitle,
    {String? btnTxt1,
      String? btnTxt2,
      String ?img,
      String ?secontxt = "",
      VoidCallback? onTap = pressed,
      VoidCallback? onTap1 = pressed,
      VoidCallback? onTap2 = pressed,
      bool isPng = false
    }) {
  return showGeneralDialog(
      barrierLabel: "Label",
      transitionDuration: const Duration(milliseconds: 500),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return GestureDetector(
          onTap: onTap,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                // height: MediaQuery.of(context).size.height/2.5,
                  width: MediaQuery.of(context).size.width / 1.1,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 3.h),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: color.txtWhite,
                    borderRadius: BorderRadius.circular(15),),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        // color: Colors.amber,
                        alignment: Alignment.center,
                        height: isPng ? 70 : 80,
                        width: isPng ? 70 : 80,
                        child: isPng ? Image.asset(img!) : SvgPicture.asset(
                            img!),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: FontFamily.baloo2,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: color.txtBlack,
                        ),
                      ),
                      // secontxt == "" ? const SizedBox() : Text(secontxt!,
                      //   style: const TextStyle(
                      //     fontFamily: FontFamily.baloo2,
                      //     fontSize: 18,
                      //     fontWeight: FontWeight.w500,
                      //     color: color.txtgrey,
                      //   ),
                      //   textAlign: TextAlign.center,
                      // ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontFamily: FontFamily.baloo2,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: color.txtgrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: onTap1,
                              child: Container(
                                alignment: Alignment.center,
                                height: 56,
                                // width: MediaQuery.of(context).size.width/2-45,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: color.txtWhite,
                                    border: Border.all(
                                        width: 1.5, color: color.txtBlue)
                                ),
                                child: buildText(
                                    btnTxt1!, 16.5, FontWeight.w600,
                                    color.txtBlue),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: onTap2,
                              child: Container(
                                alignment: Alignment.center,
                                height: 56,
                                // width: MediaQuery.of(context).size.width/2-45,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: const LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        color.gradientLightBlue,
                                        color.txtBlue
                                      ],)
                                ),
                                child: buildText(btnTxt2!, 18, FontWeight.w600,
                                    color.txtWhite),
                              ),
                            ),
                          ),
                        ],),
                      const SizedBox(height: 4),
                    ],
                  )),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(anim1),
          child: child,
        );
      }
  );
}

void pressed() {
  Get.back();
}

// Search Filter Bottom Sheet
var _value = 500;

String formatValue(double value) {
  return NumberFormat('#').format(value);
}

String date1 = "Select Date ";
String datee1= DateFormat('MMM dd ,yyyy').format(DateTime.now());
// DateTime? date3;
ValueNotifier<DateTime> date3 = ValueNotifier<DateTime>(DateTime.now());
String date2 = "Select Date ";

customDialogBoxFilter(BuildContext context, {VoidCallback?whiteTap = pressed, VoidCallback?blueTap = pressed}) {
  if(date2 == "Select Date "){_value=500;}
  return showGeneralDialog(
      barrierLabel: "Label",
      transitionDuration: const Duration(milliseconds: 500),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return StatefulBuilder(
            builder: (context, setState) {
              return GestureDetector(
                // onTap: onTap,
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Align(
                    alignment: Alignment.bottomCenter,
                    child: Stack(
                      children: [
                        Container(
                          // height: MediaQuery.of(context).size.height/2.5,
                            width: MediaQuery.of(context).size.width / 1.1,
                            margin: EdgeInsets.only(bottom: 3.h, top: 8, right: 7),
                            // padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: color.txtWhite, borderRadius: BorderRadius.circular(15),),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(alignment: Alignment.center,
                                        height: 10,
                                        width: 80,),
                                      const SizedBox(height: 12),
                                      buildText("Filter", 28, FontWeight.w600, color.txtBlack),
                                      const SizedBox(height: 10),
                                      buildText("Date Range", 18, FontWeight.w600, color.txtBlack),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              buildText("From", 16, FontWeight.w500,
                                                  color.txtgrey2, fontFamily: FontFamily.hellix),
                                              SizedBox(height: 1.h),
                                              /* buildContainer(context, fromDateController,    gesture: GestureDetector(onTap: (){},
                                      child: Container(padding: const EdgeInsets.only(top: 5), height: 20, width: 30, alignment: Alignment.center,
                                          child: SvgPicture.asset(AssetsPics.filterIcon))),),*/
                                              GestureDetector(
                                                onTap: (){
                                           /*       showDatePicker(
                                                    builder: (context, child) {
                                                      return Theme(data: Theme.of(context).copyWith(
                                                        colorScheme: const ColorScheme.light(
                                                          primary: color.txtBlue, // header background color
                                                          onPrimary: Colors.white, // header text color
                                                          onSurface: color.txtBlack, // body text color
                                                          surfaceTint: Colors.white, // background
                                                          surface: color.txtWhite, // background color
                                                          // onSurfaceVariant: Colors.blue, //header text color
                                                          // outlineVariant: Colors.blue,//divider
                                                          // onBackground: Colors.black,// divider color
                                                        ),),
                                                        child: child!,);},
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime.now(),
                                                    lastDate: DateTime(2500),
                                                  ).then((selectedDate) {
                                                    if (selectedDate != null) {
                                                      DateTime selectedDateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
                                                      setState(() {
                                                        LocaleHandler.miliseconds = selectedDateTime.millisecondsSinceEpoch;
                                                        date1 = DateFormat('MMM dd ,yyyy').format(selectedDateTime);
                                                        // date3=selectedDateTime;
                                                        date3.value=selectedDate;
                                                      });
                                                    }
                                                  });*/
                                                },
                                                child: Container(
                                                  height: 55, width: MediaQuery.of(context).size.width / 2 - 40,
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(8),
                                                      border: Border.all(
                                                          width: 0.2,
                                                          color: Colors.black26)
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      buildText(datee1, 16,
                                                          FontWeight.w500,
                                                          color.txtgrey2,
                                                          fontFamily: FontFamily.hellix),
                                                      SvgPicture.asset(AssetsPics.datePicker)
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              buildText("To", 16, FontWeight.w500,
                                                  color.txtgrey2, fontFamily: FontFamily.hellix),
                                              SizedBox(height: 1.h),
                                              /* buildContainer(context, fromDateController,    gesture: GestureDetector(onTap: (){},
                                      child: Container(padding: const EdgeInsets.only(top: 5), height: 20, width: 30, alignment: Alignment.center,
                                          child: SvgPicture.asset(AssetsPics.filterIcon))),),*/
                                              GestureDetector(
                                                onTap: () {
                                                  if(date1!="Select Date "){}
                                                  else{
                                                  showDatePicker(
                                                    builder: (context, child) {
                                                      return Theme(data: Theme.of(context).copyWith(
                                                        colorScheme: const ColorScheme.light(
                                                          primary: color.txtBlue, // header background color
                                                          onPrimary: Colors.white, // header text color
                                                          onSurface: color.txtBlack, // body text color
                                                          surfaceTint: Colors.white, // background
                                                          surface: color.txtWhite, // background color
                                                        ),),
                                                        child: child!,);},
                                                    context: context,
                                                    // initialDate: date3.value,
                                                    // firstDate: date3.value,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime.now(),
                                                    lastDate: DateTime(2500),
                                                  ).then((selectedDate) {
                                                    if (selectedDate != null) {
                                                      DateTime selectedDateTime = DateTime(
                                                          selectedDate.year,
                                                          selectedDate.month,
                                                          selectedDate.day);
                                                      setState(() {
                                                        LocaleHandler.miliseconds = selectedDateTime.microsecondsSinceEpoch ~/ 1000000;
                                                        date2 = DateFormat('MMM dd ,yyyy').format(selectedDateTime);
                                                      });}});
                                                  }
                                                },
                                                child: Container(
                                                  height: 55, width: MediaQuery.of(context).size.width / 2 - 40,
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(8),
                                                      border: Border.all(width: 0.2, color: Colors.black26)
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      buildText(date2, 16,
                                                          FontWeight.w500,
                                                          color.txtgrey2,
                                                          fontFamily: FontFamily.hellix),
                                                      SvgPicture.asset(AssetsPics.datePicker)
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],),
                                        ],),

                                    ],),
                                ),
                                const Divider(
                                    thickness: 0.5, color: color.lightestBlue),

                                Padding(padding: const EdgeInsets.only(
                                    left: 15, right: 15, bottom: 10, top: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      buildText("Distance", 18, FontWeight.w600, color.txtBlack),
                                      Container(
                                        height: 9.h,
                                        width: 350,
                                        padding: const EdgeInsets.only(top: 20),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                          /*  SfSliderTheme(
                                              data: SfSliderThemeData(
                                                  tooltipBackgroundColor: Colors.blue, thumbRadius: 8,
                                                  tooltipTextStyle: TextStyle(fontSize: 14)
                                              ),
                                              child: Consumer<loginControllerr>(builder: (context,valuee,index){
                                                return SfSlider(
                                                  // numberFormat: ,
                                                    shouldAlwaysShowTooltip: false,
                                                    // thumbIcon: CircleAvatar(radius: 50, child: Image.asset("assets/images/eventProfile.png")),
                                                    thumbIcon: const Stack(
                                                      alignment: Alignment.center,
                                                      children: [
                                                        CircleAvatar(backgroundColor: color.txtBlue),
                                                        CircleAvatar(radius: 5, backgroundColor: color.txtWhite),
                                                      ],
                                                    ),
                                                    min: 1000,
                                                    max: 100000.0,
                                                    value: _value.toDouble(),
                                                    // value: valuee.value.toDouble(),
                                                    interval: 100,
                                                    showTicks: false,
                                                    showLabels: false,
                                                    enableTooltip: true,
                                                    minorTicksPerInterval: 100,
                                                    // onChanged: onChangee,
                                                    onChanged: (dynamic value) {
                                                      setState(() {_value = value.toInt();});
                                                      Provider.of<loginControllerr>(context,listen: false).changeValue(_value);

                                                    },
                                                    activeColor: color.txtBlue,
                                                    dividerShape: SfDividerShape(),
                                                    tooltipShape: SfPaddleTooltipShape(),
                                                    edgeLabelPlacement: EdgeLabelPlacement.inside,
                                                    inactiveColor: color.lightestBlueIndicator,
                                                    labelPlacement: LabelPlacement.betweenTicks,
                                                    tooltipTextFormatterCallback: (
                                                        dynamic actualValue,
                                                        String formattedText) {
                                                      return formatValue(
                                                          actualValue.toDouble());
                                                    }
                                                );
                                              }),
                                            ),*/
                                     Consumer<loginControllerr>(builder: (context,valuee,index){ return SliderTheme(
                                              data: SliderTheme.of(context).copyWith(
                                                trackHeight: 4.0,
                                                inactiveTickMarkColor: Colors.transparent,
                                                trackShape: const RoundedRectSliderTrackShape(),
                                                activeTrackColor: color.txtBlue,
                                                inactiveTrackColor: color.lightestBlueIndicator,
                                                activeTickMarkColor: Colors.transparent,
                                                thumbShape: CustomSliderThumb(displayValue: _value),
                                                thumbColor: color.txtBlue,
                                                overlayColor: const Color(0xff2280EF).withOpacity(0.2),
                                                overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
                                                valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                                                // valueIndicatorShape: DropSliderValueIndicatorShape(),
                                                valueIndicatorColor: Colors.blue,
                                                showValueIndicator: ShowValueIndicator.never,
                                                valueIndicatorTextStyle: const TextStyle(color: Colors.white, fontSize: 16.0),
                                              ),
                                              child: Slider(
                                                min: 5.0,
                                                max: 500.0,
                                                value: _value.toDouble(),
                                                divisions: 99,
                                                label: '${_value.round()} KM',
                                                onChanged: (value) {
                                                    _value = value.toInt();
                                                    Provider.of<loginControllerr>(context,listen: false).changeValue(_value);
                                                },
                                              ),
                                            );}),
                                            /* Slider(value: _value.toDouble(),
                                            onChanged:  (dynamic value) {setState(() {_value = value.toInt();});},),*/
                                            Positioned(left: 13.0,
                                              child: IgnorePointer(
                                                child: CircleAvatar(radius: 7,
                                                  child: SvgPicture.asset(AssetsPics.sliderleft),
                                                ),
                                              ),
                                            ),
                                            /*      IgnorePointer(
                      child: CircleAvatar(
                        radius: 16,
                        child: SvgPicture.asset("assets/icons/sliderright.svg"),
                      ),
                    ),*/
                                            // Container(height: 20,width: 100,color: Colors.red,)
                                          ],
                                        ),
                                      )
                                    ],),
                                ),
                                const Divider(thickness: 0.5, color: color.lightestBlue),
                                /*  Padding(padding: const EdgeInsets.only(left: 15,right: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildText("Age", 18, FontWeight.w600, color.txtBlack),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GridView.builder(shrinkWrap: true,
                                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 3 / 1.2),
                                            itemCount: category.length,
                                            itemBuilder: (context,index){
                                          return  GestureDetector(
                                            onTap: (){
                                              setState(() {
                                                selectedIndex=index;
                                              });
                                            },
                                            child: Column(mainAxisSize: MainAxisSize.min, children: [
                                              selectedIndex==index? selectedButton(category[index]):unselectedButton(category[index])
                                              ],),
                                          );
                                            }),
                                      ],
                                    ),
                                  ],),
                              ),*/
                                const SizedBox(height: 20),
                                Padding(padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: whiteTap,
                                        child: Container(
                                          alignment: Alignment.center,
                                          height: 56,
                                          width: MediaQuery.of(context).size.width / 2 - 40,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              color: color.txtWhite,
                                              border: Border.all(width: 1.5, color: color.txtBlue)
                                          ),
                                          child: buildText(
                                              "Clear all", 18, FontWeight.w600,
                                              color.txtBlue),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: blueTap,
                                        child: Container(
                                          alignment: Alignment.center,
                                          height: 56,
                                          width: MediaQuery.of(context).size.width / 2 - 40,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              gradient: const LinearGradient(
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                                colors: [
                                                  color.gradientLightBlue,
                                                  color.txtBlue
                                                ],)
                                          ),
                                          child: buildText(
                                              "Apply", 18, FontWeight.w600,
                                              color.txtWhite),
                                        ),
                                      ),
                                    ],),),
                                const SizedBox(height: 4),
                              ],
                            )),
                        Positioned(
                          right: 0.15,
                          top: 0.15,
                          child: GestureDetector(
                            onTap: () {
                              Get.back();
                            },
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: color.txtWhite,
                              child: SvgPicture.asset(AssetsPics.cancel),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(anim1),
          child: child,
        );
      }
  );
}

Widget buildContainer(BuildContext context, TextEditingController controller,
    {FormFieldValidator<String>? validation,
      VoidCallback? press,
      GestureDetector? gesture,}) {
  return Align(
    alignment: Alignment.center,
    child: Container(
      padding: const EdgeInsets.only(left: 10),
      height: 56,
      margin: const EdgeInsets.only(top: 20),
      width: MediaQuery
          .of(context)
          .size
          .width / 2 - 45,
      decoration: BoxDecoration(
          color: color.txtWhite,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: color.textFieldColor, width: 1)),
      child: TextFormField(
        readOnly: true,
        textInputAction: TextInputAction.done,
        onTap: press,
        controller: controller,
        cursorColor: color.txtBlue,
        validator: validation,
        decoration: InputDecoration(
          errorStyle: const TextStyle(height: 0, fontSize: 12),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.only(left: 1, right: 1, top: 12),
          suffixIcon: gesture,),
      ),
    ),
  );
}

Widget selectedButton(String btntxt,Size size) {
  return Container(
    alignment: Alignment.center,
    height: 36,
    width: size.width*0.25,
    // width: 98,
    padding: const EdgeInsets.symmetric(horizontal: 0),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(width: 1,color: color.txtBlue),
        gradient: const LinearGradient(
          begin: Alignment.bottomCenter, end: Alignment.topCenter,
          colors: [color.gradientLightBlue, color.txtBlue],)
    ),
    child: buildText(btntxt, 16, FontWeight.w600, color.txtWhite),
  );
}

Widget unselectedButton(String btntxt,Size size) {
  return Container(
    alignment: Alignment.center,
    height: 36,
    width: size.width*0.25,
    // width: 98,
    padding: const EdgeInsets.symmetric(horizontal: 0),
    decoration: BoxDecoration(
      color: color.unSelectedColor,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(width: 1, color: color.disableButton)
    ),
    child: buildText(btntxt, 16, FontWeight.w600, color.txtgrey),
  );
}


// TextField Single Button Sheet
TextEditingController passwordController = TextEditingController();
bool password = true;

customDialogBoxTextField(BuildContext context, String title, String btnTxt,
    FocusNode node,
    {String ?img, required String heading, VoidCallback? onTap = pressed, GestureDetector ? ges,
      VoidCallback? onTapbutton = pressed,Function(String)? onchng,TextEditingController? cntroller}) {
  return showGeneralDialog(
      barrierLabel: "Label",
      transitionDuration: const Duration(milliseconds: 500),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return StatefulBuilder(
            builder: (context, setState) {
              return GestureDetector(
                onTap: onTap,
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                        width: MediaQuery.of(context).size.width / 1.1,
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 3.h),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: color.txtWhite, borderRadius: BorderRadius.circular(15)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              alignment: Alignment.center,
                              height: 80, width: 80,
                              child: SvgPicture.asset(img!),
                            ),
                            const SizedBox(height: 10),
                            buildText(title, 20, FontWeight.w600, color.txtBlack),
                            const SizedBox(height: 5),
                            buildText2(
                                heading, 18, FontWeight.w500, color.txtgrey),
                            const SizedBox(height: 10),
                            buildPasswordTextField(
                              context, "Enter password", "Enter password",
                                cntroller!,
                              AutovalidateMode.onUserInteraction, node,
                              obs: password,
                              gesture: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      password = !password;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(top: 5),
                                    height: 20,
                                    width: 30,
                                    alignment: Alignment.center,
                                    child: SvgPicture.asset(password
                                        ? AssetsPics.eyeOff
                                        : AssetsPics.eyeOn),
                                  )
                              ),
                              onchng: onchng
                            ),
                            const SizedBox(height: 10),
                            blue_button(context, btnTxt, press:onTapbutton)
                          ],
                        )),
                  ),
                ),
              );
            }
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(anim1),
          child: child,
        );
      }
  ).then((val){cntroller!.clear();});
}

Widget buildPasswordTextField(BuildContext context, String txt, String chktxt,
    TextEditingController controller,
    AutovalidateMode auto, FocusNode node,
    {FormFieldValidator<
        String>? validation, VoidCallback? press, GestureDetector? gesture,Function(String)?onchng,
      bool obs = true
    }) {
  return Align(
    alignment: Alignment.center,
    child: Container(
      height: 56,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(color: color.txtWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: LocaleHandler.passwordField == true ? color.txtBlue : color.txtgreyhex, width: 1),
        // border: Border.all(color:color.txtBlue, width:1),
      ),
      child: TextFormField(
        textInputAction: TextInputAction.done,
        onTap: press,
        focusNode: node,
        controller: controller,
        // focusNode: loginFocus,
        obscureText: obs,
        obscuringCharacter: "X",
        cursorColor: color.txtBlue,
        autovalidateMode: auto,
        validator: validation,
        onChanged: onchng,
        decoration: InputDecoration(
          errorStyle: const TextStyle(height: 0, fontSize: 12),
          border: InputBorder.none,
          hintText: txt,
          hintStyle: const TextStyle(fontFamily: FontFamily.hellix,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: color.txtgrey2),
          contentPadding: const EdgeInsets.only(left: 20, right: 18, top: 15),
          suffixIcon: gesture,
        ),
      ),
    ),
  );
}

customDialogBoxwithtitle(BuildContext context, String title, String btnTxt,
    String img, { VoidCallback? onTap = pressed, bool isPng = false}) {
  return showGeneralDialog(
      barrierLabel: "Label",
      transitionDuration: const Duration(milliseconds: 500),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width / 1.1,
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 3.h),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: color.txtWhite,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(alignment: Alignment.center,
                      height: 80, width: 80,
                      child: isPng ? Image.asset(img) : SvgPicture.asset(img),
                    ),
                    const SizedBox(height: 10),
                    buildText2(title, 20, FontWeight.w600, color.txtBlack),
                    const SizedBox(height: 15),
                    blue_button(context, btnTxt!, press: onTap)
                  ],
                )),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(anim1),
          child: child,
        );
      }
  );
}

customSparkBottomSheeet(BuildContext context, String img, String title,
    String btnTxt1, String btnTxt2, {
      VoidCallback? onTapp = pressed,
      VoidCallback? onTap1 = pressed,
      VoidCallback? onTap2 = pressed,
      bool? forAdvanceTap,
      int sparks=0}) {
  return showGeneralDialog(
      barrierLabel: "Label",
      transitionDuration: const Duration(milliseconds: 500),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return GestureDetector(
          onTap: onTapp,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  width: MediaQuery.of(context).size.width / 1.1,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: color.txtWhite,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Image.asset(img, fit: BoxFit.cover,height: 70),
                      SizedBox(height:img==AssetsPics.sparkleft? 15:0),
                      img== AssetsPics.sparkleft? FittedBox(
                        child: Container(
                          // height: size.height*0.04,
                          padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5.5),
                          decoration: BoxDecoration(color:color.example4,
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(children: [
                            SvgPicture.asset(AssetsPics.star),
                            const SizedBox(width: 5),
                            buildText("$sparks Sparks", 15, FontWeight.w500, color.txtBlack,fontFamily: FontFamily.hellix)
                          ]),
                        ),
                      ):const SizedBox(),
                      const SizedBox(height: 15),
                      buildText2(title, 20, FontWeight.w600, color.txtBlack),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: onTap1,
                            child: Container(
                              alignment: Alignment.center,
                              height: 56,
                              width: MediaQuery.of(context).size.width / 2 - 45,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: color.txtWhite,
                                  border: Border.all(width: 1.5, color: color.txtBlue)
                              ),
                              child: buildText(
                                  btnTxt1, 18, FontWeight.w600, color.txtBlue),
                            ),
                          ),
                          GestureDetector(
                            onTap: onTap2,
                            child: Container(
                              alignment: Alignment.center,
                              height: 56,
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width / 2 - 45,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: const LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      color.gradientLightBlue,
                                      color.txtBlue
                                    ],)
                              ),
                              child: buildText(
                                  btnTxt2, 18, FontWeight.w600, color.txtWhite),
                            ),
                          ),
                        ],),
                      const SizedBox(height: 8),
                    ],
                  )),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(anim1),
          child: child,
        );
      });
}





List appRating = [
  AssetsPics.smiley1svg,
  AssetsPics.smiley2svg,
  AssetsPics.smiley3svg,
  AssetsPics.smiley4svg,
  AssetsPics.smiley5svg,
  // AssetsPics.smiley1,
  // AssetsPics.smiley2,
  // AssetsPics.smiley3,
  // AssetsPics.smiley4,
  // AssetsPics.smiley5,
];
List appRatingg = [
  AssetsPics.smiley1svg,
  AssetsPics.smiley2svg,
  AssetsPics.smiley3svg,
  AssetsPics.smiley4svg,
  AssetsPics.smiley5svg,
];

int selectedIndex1 = -1;

customRatingSheet({required BuildContext context,
  required String title,
  required String heading,
  VoidCallback? onTapp = pressed,
  VoidCallback? onTap = pressed,
}) {
  return showGeneralDialog(
      barrierLabel: "Label",
      transitionDuration: const Duration(milliseconds: 500),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return GestureDetector(
          onTap: onTapp,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
// height: MediaQuery.of(context).size.height/2.5,
                  width: MediaQuery.of(context).size.width / 1.1,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 30),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: color.txtWhite,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      buildText2(title, 20, FontWeight.w600, color.txtBlack),
                      buildText2(heading, 18, FontWeight.w500, color.txtgrey,
                          fontFamily: FontFamily.hellix),
                      const SizedBox(height: 20,),
                      SizedBox(
                        height: 52,
                        child: StatefulBuilder(
                            builder: (BuildContext context, StateSetter setState) {
                              return Center(
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: appRating.length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (BuildContext context, int index) {
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() async {
                                            selectedIndex1 = index;
                                           await Future.delayed(const Duration(seconds:1));
                                            Get.back();
                                            customDialogBoxWithtwobutton(
                                                context,
                                                "Thanks for your feedback!",
                                                "We're glad you're enjoying the app.\nPlease take a few seconds to rate\nSlush in the App Store.",
                                                img: AssetsPics.matchespng,
                                                btnTxt1: "Don't Ask Again",
                                                btnTxt2: "Sure",
                                                isPng: true);
                                          });
                                        },
                                        child: CircleAvatar(
                                          radius: 29,
                                          backgroundColor: selectedIndex1 == index ? color.txtBlue : color.txtgrey4,
                                          // child: Image.asset(appRating[index],height: 45),
                                          child: CircleAvatar(
                                              radius: 15,
                                              // backgroundColor: color.txtgrey4,
                                              child: SvgPicture.asset(
                                                appRatingg[index], height: 30,
                                                width: 9,
                                                fit: BoxFit.cover,)),
                                        ),
                                      );
                                    }),
                              );
                            }),
                      ),
                      const SizedBox(height: 15),
                    ],
                  )),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(anim1),
          child: child,
        );
      }
  );
}

customBuilderSheet(BuildContext context, String title, String btnTxt, List item,
    {VoidCallback? onTap = pressed,}) {
  return showGeneralDialog(
      barrierLabel: "Label",
      transitionDuration: const Duration(milliseconds: 500),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(onTap: (){},
                child: Container(
                  // height: MediaQuery.of(context).size.height / 1.80,
                    width: MediaQuery.of(context).size.width / 1.1,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: color.txtWhite,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const SizedBox(height: 10),
                        buildText(title, 20, FontWeight.w600, color.txtBlack),
                        StatefulBuilder(
                            builder: (BuildContext context,
                                StateSetter setState) {
                              return ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemCount: item.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: GestureDetector(
                                        onTap: () {setState(() {selectedIndex = index;});},
                                        child: Container(
                                          color: Colors.transparent,
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor: selectedIndex == index ? color.txtBlue : color.txtBlack,
                                                radius: 9,
                                                child: CircleAvatar(
                                                  radius: 8,
                                                  backgroundColor: selectedIndex == index ? color.txtWhite : color.txtWhite,
                                                  // backgroundImage: SvgPicture.asset(AssetsPics.arrowLeft),
                                                  child: selectedIndex == index ? SvgPicture.asset(
                                                    AssetsPics.blueTickCheck, fit: BoxFit.cover) : const SizedBox(),
                                                ),
                                              ),
                                              const SizedBox(width: 10,),
                                              buildText2(item[index], 18, FontWeight.w500, color.txtgrey, fontFamily: FontFamily.hellix),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  });
                            }),
                        const SizedBox(height: 15),
                        blue_button(context, btnTxt, press: onTap)
                      ],
                    )),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(anim1),
          child: child,
        );
      });
}


customDialogBoxWithtwobuttonfordeletePicture(BuildContext context, String title,
    {String? btnTxt1,
      String? btnTxt2,
      VoidCallback? onTap = pressed,
      VoidCallback? onTap1 = pressed,
      VoidCallback? onTap2 = pressed,
    }) {
  return showGeneralDialog(
      barrierLabel: "Label",
      transitionDuration: const Duration(milliseconds: 500),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return GestureDetector(
          onTap: onTap,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                // height: MediaQuery.of(context).size.height/2.5,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width / 1.1,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 3.h),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: color.txtWhite,
                    borderRadius: BorderRadius.circular(15),),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const SizedBox(height: 10),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: FontFamily.baloo2,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: color.txtBlack,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: onTap1,
                              child: Container(
                                alignment: Alignment.center,
                                height: 56,
                                // width: MediaQuery.of(context).size.width/2-45,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: color.txtWhite,
                                    border: Border.all(
                                        width: 1.5, color: color.txtBlue)
                                ),
                                child: buildText(
                                    btnTxt1!, 16.5, FontWeight.w600,
                                    color.txtBlue),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: onTap2,
                              child: Container(
                                alignment: Alignment.center,
                                height: 56,
                                // width: MediaQuery.of(context).size.width/2-45,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: const LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        color.gradientLightBlue,
                                        color.txtBlue
                                      ],)
                                ),
                                child: buildText(btnTxt2!, 18, FontWeight.w600,
                                    color.txtWhite),
                              ),
                            ),
                          ),
                        ],),
                      const SizedBox(height: 4),
                    ],
                  )),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(anim1),
          child: child,
        );
      }
  );
}

customDialogBox2({required BuildContext context,
  String? btnTxt,
  String ?img,
  String ?secontxt,
  required String title,
  required String heading,
  VoidCallback? onTapp = pressed,
  VoidCallback? onTap = pressed,
  bool? forAdvanceTap,
  bool isPng = false}) {
  return showGeneralDialog(
      barrierDismissible: true,
      barrierLabel: "Label",
      transitionDuration: const Duration(milliseconds: 500),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return GestureDetector(
          onTap: onTapp,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                // height: MediaQuery.of(context).size.height/2.5,
                  width: MediaQuery.of(context).size.width / 1.1,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 3.h),
                  padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 15),
                  decoration: BoxDecoration(color: color.txtWhite,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        height: 80, width: 80,
                        child: isPng ? Image.asset(img!) : SvgPicture.asset(
                            img!),
                      ),
                      const SizedBox(height: 10),
                      buildText(title, 20, FontWeight.w600, color.txtBlack),
                      secontxt == "" ? const SizedBox() : Text(secontxt!,
                        style: const TextStyle(
                          fontFamily: FontFamily.hellix,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: color.txtgrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      buildText2(heading, 16, FontWeight.w500, color.txtgrey,
                          fontFamily: FontFamily.hellix),
                      const SizedBox(height: 15),
                      blue_button(context, btnTxt!, press: onTap)
                    ],
                  )),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(anim1),
          child: child,
        );
      }
  );
}

customWarningBox(BuildContext context, String title,
    String subtitle,
    String subtitle2,
    String subtitle3,
    {String ?img,
      String ?secontxt = "",
      VoidCallback? onTap = pressed,
      bool isPng = false
    }) {
  return showGeneralDialog(
      barrierLabel: "Label",
      transitionDuration: const Duration(milliseconds: 500),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return GestureDetector(
          onTap: onTap,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                // height: MediaQuery.of(context).size.height/2.5,
                  width: MediaQuery.of(context).size.width / 1.1,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 3.h),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: color.txtWhite,
                    borderRadius: BorderRadius.circular(15),),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        // color: Colors.amber,
                        alignment: Alignment.center,
                        height: isPng ? 70 : 80,
                        width: isPng ? 70 : 80,
                        child: isPng ? Image.asset(img!) : SvgPicture.asset(img!),
                      ),
                      const SizedBox(height: 10),
                      Text(title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: FontFamily.baloo2,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: color.txtBlack,
                        ),
                      ),
                      secontxt == "" ? const SizedBox() : Text(secontxt!,
                        style: const TextStyle(
                          fontFamily: FontFamily.baloo2,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: color.txtgrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontFamily: FontFamily.baloo2,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: color.txtgrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        subtitle2,
                        style: const TextStyle(
                          fontFamily: FontFamily.baloo2,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: color.txtgrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        subtitle3,
                        style: const TextStyle(
                          fontFamily: FontFamily.baloo2,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: color.txtgrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                    ],
                  )),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(anim1),
          child: child,
        );
      }
  );
}

//-----------------------profile image sliding

int currentIndex=0;
PageController pageController=PageController();
customSlidingImage(BuildContext context,int inedxId, List? imges, {VoidCallback? onTapp = pressed}) {
  currentIndex = inedxId;
  pageController = PageController(initialPage: inedxId);
  return showGeneralDialog(
    barrierLabel: "Label",
    transitionDuration: const Duration(milliseconds: 500),
    context: context,
    pageBuilder: (context, anim1, anim2) {
      return StatefulBuilder(builder: (context, setState) {
        return Scaffold(
          backgroundColor: Colors.black87,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                        onTap: onTapp,
                        child: SvgPicture.asset(AssetsPics.whiteCancel))),
              ),
              Container(
                  height: MediaQuery.of(context).size.height / 2,
                  width: MediaQuery.of(context).size.width,
                  // padding: EdgeInsets.only(right: 20,left: 20),
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: imges!.length,
                    onPageChanged: (indexx) {
                      setState(() {
                        currentIndex = indexx;
                        if (indexx == 0) {
                          // value = 40;
                        } else if (indexx == 1) {
                          // value = 70;
                        } else {
                          // value = 100;
                        }
                      });
                      currentIndex = indexx;
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          // child: Image.network(imges[index]["key"]!, fit: BoxFit.cover)
                          child: CachedNetworkImage(
                            imageUrl: imges[index]["key"]!,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => const SizedBox(),
                            placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: color.txtBlue)),
                          ));
                    },
                  )),
              // SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(imges.length, (int index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    width: currentIndex == index ? 15 : 12,
                    height: currentIndex == index ? 15 : 12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: currentIndex == index ? Colors.white : Colors.transparent,
                      border: Border.all(
                        color: currentIndex == index ? Colors.blue : Colors.white,
                        width: currentIndex == index ? 3.4 : 1,
                      ),
                      //shape: BoxShape.circle,
                      // color: currentIndex == index ? Colors.blue : Colors.grey,
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      });
    },
  );
}

customSingleImage(BuildContext context, String imges, {VoidCallback? onTapp = pressed}) {
  return showGeneralDialog(
    barrierLabel: "Label",
    transitionDuration: const Duration(milliseconds: 500),
    context: context,
    pageBuilder: (context, anim1, anim2) {
      return StatefulBuilder(builder: (context, setState) {
        return Scaffold(
          backgroundColor: Colors.black54,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                        onTap: onTapp,
                        child: SvgPicture.asset(AssetsPics.whiteCancel))),
              ),
              Container(
                  height: MediaQuery.of(context).size.height / 2,
                  width: MediaQuery.of(context).size.width,
                  // padding: EdgeInsets.only(right: 20,left: 20),
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      // child: Image.network(imges, fit: BoxFit.cover)
                      child: CachedNetworkImage(
                        imageUrl: imges,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => const SizedBox(),
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: color.txtBlue,strokeWidth: 0.5,)),
                      )

                  )),
              const SizedBox()
            ],
          ),
        );
      });
    },
  );
}