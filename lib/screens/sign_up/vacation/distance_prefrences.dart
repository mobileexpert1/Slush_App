/*
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:intl/intl.dart';
// import 'package:getwidget/components/progress_bar/gf_progress_bar.dart';
import 'package:getwidget/getwidget.dart';

class VacationDistancePrefScreen extends StatefulWidget {
  const VacationDistancePrefScreen({Key? key}) : super(key: key);

  @override
  State<VacationDistancePrefScreen> createState() =>
      _VacationDistancePrefScreenState();
}

class _VacationDistancePrefScreenState
    extends State<VacationDistancePrefScreen> {

  var _value = 500;
  var _value2 = 5;
  var paddingVal = 140.0;
  String formatValue(double value) {
    return NumberFormat('#').format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         SizedBox(height: 3.h-2),
        buildText("Distance Preference", 28, FontWeight.w600, color.txtBlack),
        const SizedBox(height: 8),
        buildText(
          "Use slide to set the maximum distance you like potential matches to be located.",
          16,
          FontWeight.w500,
          color.txtgrey,
          fontFamily: FontFamily.hellix,
        ),
         SizedBox(height: 4.h-2),
        Container(
          height: 180,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: color.txtWhite),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SfSliderTheme(
                data: SfSliderThemeData(tooltipBackgroundColor: Colors.blue, thumbRadius: 0,
                tooltipTextStyle: const TextStyle(fontSize: 0),
                  overlayRadius: 15.0,
                ),
                child: SfSlider(
                  shouldAlwaysShowTooltip: false,
                    thumbIcon: SizedBox(),
                  min: 0,
                  max: 10.0,
                  value: _value2.toDouble(),
                  interval: 1,
                  showTicks: false,
                  showLabels: false,
                  enableTooltip: false,
                  minorTicksPerInterval: 100,
                  onChanged: (dynamic value) {setState(() {
                    _value2 = value.toInt();
                    if(value<=1){_value=100;_value2=0;paddingVal=0.0;}
                    else if(value>1&&value<2){_value=200;paddingVal = 25.0;}
                    else if(value>2&&value<3){_value=300; paddingVal = 50.0;}
                    else if(value>3&&value<4){_value=400;paddingVal=80.0;}
                    else if(value>4&&value<5){_value=500;paddingVal = 110.0;}
                    else if(value>5&&value<6){_value=600;paddingVal = 150.0;}
                    else if(value>6&&value<7){_value=700;paddingVal=180.0;}
                    else if(value>7&&value<8){_value=800;paddingVal = 210.0;}
                    else if(value>8&&value<9){_value=900;paddingVal = 240.0;}
                    else if(value>9&&value<10){_value=1000;paddingVal = 305.0;_value2=10;}
                  });},
                  activeColor: color.txtBlue,
                  dividerShape: const SfDividerShape(),
                  tooltipShape: const SfPaddleTooltipShape(),
                  edgeLabelPlacement: EdgeLabelPlacement.inside,
                  inactiveColor: color.lightestBlueIndicator,
                  labelPlacement: LabelPlacement.betweenTicks,

                  tooltipTextFormatterCallback: (dynamic actualValue, String formattedText) {
                  return formatValue(actualValue.toDouble());}
                ),
              ),

             */
/* GFProgressBar(
                percentage: _value,
                radius: 50,
                isDragable: true,
                type: GFProgressType.linear,
                backgroundColor : color.lightestBlueIndicator,
                progressBarColor: color.txtBlue,
                animation: true,
                width: 310,
                padding: EdgeInsets.only(right: 10,left: 15),

                autoLive: true,
                alignment: MainAxisAlignment.spaceBetween,
                circleStartAngle: 100.0,
                circleWidth: 50.0,
                clipLinearGradient: true,
                lineHeight: 8.0,
                progressHeadType: GFProgressHeadType.circular,
                animateFromLastPercentage: true,
                reverse: true,

                onProgressChanged: (val){
                  print(val);
                  // _value=val;
                  setState(() {
                    if(val<=0.1){}
                  });
                },
              ),*//*

                 IgnorePointer(
                   child: AnimatedContainer(
                     alignment: Alignment.centerLeft,
                     duration: Duration(milliseconds: 10),
                       padding: EdgeInsets.only(left: paddingVal),
                       child: Column(
                         children: [
                           Stack(
                             alignment: Alignment.center,
                             children: [
                               SvgPicture.asset(AssetsPics.meterbox,height: 10),
                               buildText("${_value}m", 19, FontWeight.w500, color.txtWhite)
                             ],
                           ),
                           SvgPicture.asset(AssetsPics.progressbullet),
                         ],
                       )),
                 ),

              Positioned(left: 13.0,
                child: IgnorePointer(
                  child: Container(
                    padding: EdgeInsets.only(bottom: 0),
                    child: CircleAvatar(
                      radius: 7,
                      child: SvgPicture.asset("assets/icons/sliderleft.svg"),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 3.0, backgroundColor: color.green),
            buildText(" You can change later in setting", 14, FontWeight.w500,
                color.txtBlack,
                fontFamily: FontFamily.hellix),
          ],
        ),
         SizedBox(height: 2.h-2)
      ],
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:intl/intl.dart';

class VacationDistancePrefScreen extends StatefulWidget {
  const VacationDistancePrefScreen({Key? key}) : super(key: key);

  @override
  State<VacationDistancePrefScreen> createState() => _VacationDistancePrefScreenState();
}

class _VacationDistancePrefScreenState extends State<VacationDistancePrefScreen> {

  var _value = 250;
  String formatValue(double value) {
    return NumberFormat('#').format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 3.h-2),
        buildText("Distance Preference", 28, FontWeight.w600, color.txtBlack),
        const SizedBox(height: 8),
        buildText(
          "Use slide to set the maximum distance you like potential matches to be located.",
          16, FontWeight.w500, color.txtgrey, fontFamily: FontFamily.hellix),
        SizedBox(height: 4.h-2),
        Container(
          height: 180,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: color.txtWhite),
          child: Stack(
            alignment: Alignment.center,
            children: [
             /* SfSliderTheme(
                data: SfSliderThemeData(tooltipBackgroundColor: Colors.blue, thumbRadius: 8,
                  tooltipTextStyle: const TextStyle(fontSize: 16),
                ),
                child: SfSlider(
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
                    min: 100,
                    max: 1000.0,
                    value: _value.toDouble(),
                    interval: 100,
                    showTicks: false,
                    showLabels: false,
                    enableTooltip: true,
                    minorTicksPerInterval: 100,
                    onChanged: (dynamic value) {setState(() {_value = value.toInt();
                    LocaleHandler.distance=_value.toString();
                    });},
                    activeColor: color.txtBlue,
                    dividerShape: const SfDividerShape(),
                    tooltipShape: const SfPaddleTooltipShape(),
                    edgeLabelPlacement: EdgeLabelPlacement.inside,
                    inactiveColor: color.lightestBlueIndicator,
                    labelPlacement: LabelPlacement.betweenTicks,
                    tooltipTextFormatterCallback: (dynamic actualValue, String formattedText) {
                      return formatValue(actualValue.toDouble());}
                ),
              ),*/
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4.0,
                  inactiveTickMarkColor: Colors.transparent,
                  trackShape: const RoundedRectSliderTrackShape(),
                  activeTrackColor: color.txtBlue,
                  inactiveTrackColor: color.lightestBlueIndicator,
                  activeTickMarkColor: Colors.transparent,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 14.0,
                    pressedElevation: 8.0,
                  ),
                  thumbColor: Colors.white,
                  overlayColor: const Color(0xff2280EF).withOpacity(0.2),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
                  valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                  valueIndicatorColor: Colors.blue,
                  valueIndicatorTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
                child: Slider(
                  min: 5.0,
                  max: 500.0,
                  value: _value.toDouble(),
                  divisions: 99,
                  label: '${_value.round()} KM',
                  onChanged: (value) {
                    setState(() {_value = value.toInt();
                    LocaleHandler.distance=_value.toString();
                    });},
                ),
              ),
              Positioned(left: 13.0,
                child: IgnorePointer(
                  child: CircleAvatar(radius: 9, child: SvgPicture.asset(AssetsPics.sliderleft)),
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
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 3.0, backgroundColor: color.green),
            buildText(" You can change later in settings", 14, FontWeight.w500,
                color.txtBlack,
                fontFamily: FontFamily.hellix),
          ],
        ),
        SizedBox(height: 2.h-2)
      ],
    );
  }
}
