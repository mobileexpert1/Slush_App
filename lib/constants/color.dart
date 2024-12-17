import 'package:flutter/material.dart';

class color{
  static const txtBlack = Color.fromRGBO(28, 29, 32, 1);
  static const txtgrey = Color.fromRGBO(69, 70, 72, 1);
  static const chatDeleteIcon = Color.fromRGBO(255, 92, 71, 1);
  static const txtgreyhex = Color(0xFF929394);
  static const txtgrey2 = Color.fromRGBO(105, 106, 108, 1);
  static const txtBlue = Color.fromRGBO(7, 140, 254, 1);
  static const txtGetVeirfy = Color.fromRGBO(16, 156, 241, 1);
  static const backGroundClr= Color.fromRGBO(246, 249, 255, 1);// TODO org
  static const dropDowngreytxt= Color.fromRGBO(146, 147, 148, 1);
  static const txtWhite = Color.fromRGBO(255, 255, 255, 1);
  static const subscribeButton = Color.fromRGBO(179, 111, 43, 1);
  static const unSelectedColor= Color.fromRGBO(242, 247, 255, 1);
  static const orangeColor= Color.fromRGBO(219, 59, 33, 1);
  static const dateTxtColor = Color.fromRGBO(18, 25, 44, 1);
  static const gradientLightBlue= Color.fromRGBO(40, 80, 255, 1);
  static const gradientDarkBlue= Color.fromRGBO(49, 160, 254, 1);
  static const disableButton= Color.fromRGBO(150, 192, 255, 1);
  static const green= Color.fromRGBO(58, 140, 91, 1);
  static const lightestBlue= Color.fromRGBO(230, 240, 255, 1);
  static const lightestBlueIndicator= Color.fromRGBO(192, 219, 251, 1);
  static const canceltxtOrange= Color.fromRGBO(225, 92, 71, 1);
  static const completedtxtGreen= Color.fromRGBO(58, 140, 91, 1);
  static const hieghtGrey= Color.fromRGBO(217, 217, 217, 1);
  static const purpleColor= Color.fromRGBO(77, 110, 255, 1);
  static const waitingremainingpurple = Color.fromRGBO(231, 237, 255, 1);
  static const lightPurpleColor= Color.fromRGBO(223, 225, 245, 1.0);
  static const example4= Color.fromRGBO(239, 230, 243, 1);
  static const darkPink= Color.fromRGBO(171, 89, 185, 1);

  // Event People type
  static const straight= Color.fromRGBO(40, 80, 255, 1);
  static const lesbian= Color.fromRGBO(255, 53, 53, 1);
  static const queer= Color.fromRGBO(1, 112, 219, 1);
  static const transgender= Color.fromRGBO(1, 204, 76, 1);
  static const gay= Color.fromRGBO(217, 136, 57, 1);
  static const bisexual= Color.fromRGBO(197, 177, 28, 1);
  static const example= Color.fromRGBO(150, 192, 255, 1);
  static const example2= Color.fromRGBO(230, 240, 255, 0);
  static const example3= Color.fromRGBO(230, 240, 255, 1);
  static const example5= Color.fromRGBO(234, 238, 255, 1);
  static const example6= Color.fromRGBO(212, 230, 255, 1);
  static const example7= Color.fromRGBO(241, 241, 241, 1);
  static const example8= Color.fromRGBO(234, 236, 244, 0.6);
  static const example9= Color.fromRGBO(104, 104, 104, 1);
  static const darkPurple= Color.fromRGBO(28, 39, 76, 1);
  static const curderGreen= Color.fromRGBO(52,211,153, 1);
  static const darkcrossgrey= Color.fromRGBO(211, 211, 211, 1);
  static const peachColor= Color.fromRGBO(234, 141, 126, 1);
  static const logOutRed= Color(0xffE15C47);
  static const sparkPurple= Color(0xff8A2387);
  static const textFieldColor= Color.fromRGBO(246, 246, 246, 1);
  static const txtgrey3 = Color.fromRGBO(112, 112, 112, 1);
  static const txtgrey4 = Color.fromRGBO(239, 240, 246, 1);
  static const example10= Color.fromRGBO(255, 255, 255, 0.15);

}

class FontFamily{
  static const baloo = "baloo";
  static const baloo2 = "baloo_2";
  static const baloo2M = "baloo2_Medium";
  static const hellix = "hellix";
  static const hellixExtraBold = "hellixExtraBold";
}

abstract class LocaleKeysValidation{
  static const email=r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  static const password=r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{4,}$';
}