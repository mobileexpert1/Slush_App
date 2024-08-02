import 'dart:convert';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/controller/setting_controller.dart';
import '../../constants/image.dart';
import '../../controller/login_controller.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/text_widget.dart';
import '../../widgets/thumb_class.dart';
import 'add_location.dart';

class DiscoverySettings extends StatefulWidget {
  const DiscoverySettings({super.key});

  @override
  State<DiscoverySettings> createState() => _DiscoverySettingsState();
}

List genderList = [
  "Male",
  "Female",
  "Everyone",
];
int selectedIndex = -1;
int selectedLocation = -1;
var _value = 250;
var agevalue = 30;
double _startValue = 20.0;
double _endValue = 90.0;

final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
String latitude = "";
String longitude = "";

class _DiscoverySettingsState extends State<DiscoverySettings> {
  void check() {
    if(LocaleHandler.filtergender==""){
    if (LocaleHandler.dataa["gender"] == "male" && LocaleHandler.dataa["sexuality"] == "straight")
    { selectedIndex = 1;}
    else if (LocaleHandler.dataa["gender"] == "female" && LocaleHandler.dataa["sexuality"] == "straight")
    {selectedIndex = 0;}
    else {selectedIndex = 2;}}
    else{
      if(LocaleHandler.filtergender=="male"){selectedIndex = 0;}
      else if(LocaleHandler.filtergender=="female"){selectedIndex = 1;}
      else{{selectedIndex = 2;}}
    }
  }

  @override
  void initState() {
    check();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final settingPro = Provider.of<SettingController>(context, listen: false);
    return Scaffold(
        appBar: commonBarWithTextleft(context, color.backGroundClr, "Discovery Settings"),
        body: SingleChildScrollView(
          child: Stack(children: [
            SizedBox(
              height: size.height,
              width: size.width,
              child: Image.asset(AssetsPics.background, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: color.txtWhite),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _getCurrentPosition();
                              selectedLocation = 1;
                            });
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.my_location_sharp),
                                      const SizedBox(width: 10),
                                      buildText("My current location", 18, FontWeight.w500, Colors.black),
                                    ],
                                  ),
                                  selectedLocation == 1
                                      ? const Icon(Icons.done_rounded, color: Colors.green)
                                      : const SizedBox(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedLocation = 2;
                              Get.to(() => const AddLocation());
                            });
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15, right: 15, top: 6, bottom: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.add_circle_outline, color: Colors.blue),
                                      const SizedBox(width: 4),
                                      buildText("Add a new location", 18, FontWeight.w600, Colors.black),
                                    ],
                                  ),
                                  selectedLocation == 2
                                      ? const Icon(Icons.done_rounded, color: Colors.green)
                                      : const SizedBox(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Consumer<SettingController>(builder: (contex, val, child) {
                          return val.adress == ""
                              ? const SizedBox()
                              : Container(
                                  width: size.width * 0.9,
                                  color: Colors.transparent,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 15, top: 6, bottom: 15),
                                    child: buildTextOverFlow(val.adress, 18, FontWeight.w500, Colors.black54),
                                  ),
                                );
                        })
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: color.txtWhite,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 15, bottom: 10),
                          child: buildText("Show me", 18, FontWeight.w600, Colors.black),
                        ),
                        ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: genderList.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 15, bottom: 15),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedIndex = index;
                                          // button = true;
                                        });
                                        settingPro.updateGender(index,genderList[index].toString().toLowerCase());
                                      },
                                      child: Container(
                                        color: Colors.transparent,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            buildText(
                                                genderList[index],
                                                18,
                                                FontWeight.w500,
                                                color.txtBlack),
                                            CircleAvatar(
                                              backgroundColor: selectedIndex == index ? color.txtBlue : color.txtBlack,
                                              radius: 9,
                                              child: CircleAvatar(
                                                radius: 8,
                                                backgroundColor: selectedIndex == index ? color.txtWhite : color.txtWhite,
                                                // backgroundImage: SvgPicture.asset(AssetsPics.arrowLeft),
                                                child: selectedIndex == index
                                                    ? SvgPicture.asset(AssetsPics.blueTickCheck, fit: BoxFit.cover)
                                                    : const SizedBox(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  index == genderList.length - 1
                                      ? const SizedBox()
                                      : const Divider(height: 5, thickness: 1, color: color.example3),
                                ],
                              );
                            }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: color.txtWhite),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10, top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildText("Distance", 18, FontWeight.w600, color.txtBlack),
                          Container(
                            height: 13.h,
                            width: size.width,
                            padding: const EdgeInsets.only(top: 20),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Consumer<loginControllerr>(
                                    builder: (context, valuee, index) {
                                  return SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: 5.0,
                                      inactiveTickMarkColor: Colors.transparent,
                                      trackShape: const RoundedRectSliderTrackShape(),
                                      activeTrackColor: color.txtBlue,
                                      inactiveTrackColor: color.lightestBlueIndicator,
                                      activeTickMarkColor: Colors.transparent,
                                      // thumbShape: const RoundSliderThumbShape(
                                      //     enabledThumbRadius: 14.0,
                                      //     pressedElevation: 8.0),
                                      thumbShape: CustomSliderThumb(
                                        displayValue: _value,
                                      ),
                                      thumbColor: color.txtBlue,
                                      overlayColor: const Color(0xff2280EF).withOpacity(0.2),
                                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
                                      valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                                      // valueIndicatorShape: DropSliderValueIndicatorShape(),
                                      valueIndicatorColor: Colors.blue,
                                      valueIndicatorTextStyle: const TextStyle(
                                          color: Colors.white, fontSize: 16.0),

                                      disabledThumbColor: Colors.red,
                                      disabledInactiveTrackColor: Colors.red,
                                      disabledActiveTrackColor: Colors.red,
                                      allowedInteraction: SliderInteraction.tapAndSlide,
                                      disabledActiveTickMarkColor: Colors.red,
                                      disabledInactiveTickMarkColor: Colors.red,
                                      disabledSecondaryActiveTrackColor: Colors.red,
                                      minThumbSeparation: 20.0,
                                      overlappingShapeStrokeColor: Colors.red,
                                      secondaryActiveTrackColor: Colors.red,
                                      showValueIndicator:
                                      ShowValueIndicator.never,
                                    ),
                                    child: Slider(
                                      min: 5.0,
                                      max: 500.0,
                                      value: _value.toDouble(),
                                      divisions: 99,
                                      label: '${_value.round()} km',
                                      onChanged: (value) {
                                        _value = value.toInt();
                                        Provider.of<loginControllerr>(context, listen: false).changeValue(_value);
                                        // settingPro.updateDistance(_value);
                                      },
                                    ),
                                  );
                                }),
                                Positioned(
                                  left: 13.0,
                                  child: IgnorePointer(
                                    child: CircleAvatar(
                                      radius: 10,
                                      child: SvgPicture.asset(AssetsPics.sliderleft),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: color.txtWhite),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 15, right: 15, bottom: 10, top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildText(
                              "Age Range", 18, FontWeight.w600, color.txtBlack),
                          Container(
                            height: 13.h,
                            width: size.width,
                            padding: const EdgeInsets.only(top: 20),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Consumer<loginControllerr>(
                                    builder: (context, valuee, index) {
                                      return Stack(
                                        children: [
                                          RangeSlider(
                                            activeColor: color.txtBlue,
                                            inactiveColor: color.lightestBlueIndicator,
                                            // divisions: 9,
                                            labels: RangeLabels(
                                              _startValue.round().toString(),
                                              _endValue.round().toString(),
                                            ),
                                            min: 18.0,
                                            max: 100.0,
                                            values: RangeValues(_startValue, _endValue),
                                            onChanged: (values) {
                                              setState(() {
                                                _startValue = values.start;
                                                _endValue = values.end;
                                              });
                                            },
                                          ),
                                          Positioned(
                                            left: (size.width - 50) * (_startValue - 18) / (100 - 8), // Calculate left position dynamically
                                            top: 1,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.blue,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '${_startValue.round()}',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            right: (size.width - 50) * (100 - _endValue) / (100 - 8), // Calculate right position dynamically
                                            top: 1,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.blue,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '${_endValue.round()}',
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                  // return SliderTheme(
                                  //     data: SliderTheme.of(context).copyWith(
                                  //       trackHeight: 5.0,
                                  //       inactiveTickMarkColor: Colors.transparent,
                                  //       trackShape: const RoundedRectSliderTrackShape(),
                                  //       activeTrackColor: color.txtBlue,
                                  //       inactiveTrackColor: color.lightestBlueIndicator,
                                  //       activeTickMarkColor: Colors.transparent,
                                  //       thumbShape: const RoundSliderThumbShape(
                                  //           enabledThumbRadius: 14.0,
                                  //           pressedElevation: 8.0),
                                  //       thumbColor: Colors.white,
                                  //       overlayColor: const Color(0xff2280EF).withOpacity(0.2),
                                  //       overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
                                  //       valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                                  //       // valueIndicatorShape: ,
                                  //       valueIndicatorColor: Colors.blue,
                                  //       valueIndicatorTextStyle:
                                  //           const TextStyle(
                                  //               color: Colors.white,
                                  //               fontSize: 16.0),
                                  //     ),
                                  //     child: RangeSlider(
                                  //       divisions: 82,
                                  //       labels: RangeLabels(
                                  //         _startValue.round().toString(),
                                  //         _endValue.round().toString(),
                                  //       ),
                                  //       min: 18.0,
                                  //       max: 100.0,
                                  //       values: RangeValues(_startValue, _endValue),
                                  //       onChanged: (values) {
                                  //         setState(() {
                                  //           _startValue = values.start;
                                  //           _endValue = values.end;
                                  //         });
                                  //         settingPro.updateAgeRange(_startValue, _endValue);
                                  //       },
                                  //     ));
                                }),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ]),
        ));
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handlePermission();
    if (!hasPermission) {
      openAppSettings();
    }
    final position = await _geolocatorPlatform.getCurrentPosition();
    latitude = position.latitude.toString();
    longitude = position.longitude.toString();
    Provider.of<SettingController>(context, listen: false)
        .updaetLocation(latitude, longitude);
    // Get.to(()=>VacationDetailsScreen());
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }
}
