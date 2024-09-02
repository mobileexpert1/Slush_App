import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:slush/constants/color.dart';

Widget buildText(String stxt,double num,FontWeight wt,Color clr,{
  String fontFamily=FontFamily.baloo2,
  double spacing=0.4,}) {
  return Text(stxt,
    style:  TextStyle(
        fontSize: num,
        fontWeight: wt,
        color: clr,
        fontFamily: fontFamily,
        letterSpacing: spacing),
  );
}


Widget buildText2(String stxt,double num,FontWeight wt,Color clr,{
  String fontFamily=FontFamily.baloo2,
  double spacing=0.4,TextAlign txtA=TextAlign.center}) {
  return Text(
    stxt,
    textAlign: txtA,
    style:  TextStyle(
        fontSize: num,
        fontWeight: wt,
        color: clr,
        fontFamily: fontFamily,
        letterSpacing: spacing),
  );
}

Widget buildTextOverFlow(String stxt,double num,FontWeight wt,Color clr,{
  String fontFamily=FontFamily.baloo2,
  double spacing=0.4}) {
  return Text(
    stxt,
    overflow: TextOverflow.ellipsis,
    textAlign: TextAlign.left,
    style:  TextStyle(
        fontSize: num,
        fontWeight: wt,
        color: clr,
        fontFamily: fontFamily,
        letterSpacing: spacing),
  );
}

Widget buildTextOverFlow2(String stxt,double num,FontWeight wt,Color clr,{
  String fontFamily=FontFamily.baloo2,
  double spacing=0.4}) {
  return Text(
    stxt,
    overflow: TextOverflow.ellipsis,
    textAlign: TextAlign.right,
    style:  TextStyle(
        fontSize: num,
        fontWeight: wt,
        color: clr,
        fontFamily: fontFamily,
        letterSpacing: spacing),
  );
}

Widget buildTextoneline(String stxt,double num,FontWeight wt,Color clr,{
  String fontFamily=FontFamily.baloo2,
  double spacing=0.4,}) {
  return Text(
    stxt,
    maxLines: 1,
    style:  TextStyle(
        fontSize: num,
        fontWeight: wt,
        color: clr,
        fontFamily: fontFamily,
        letterSpacing: spacing),
  );
}

Widget buildTextOverFlowwithMaxLine(String stxt,double num,FontWeight wt,Color clr,{
  String fontFamily=FontFamily.baloo2,
  double spacing=0.4}) {
  return Text(
    stxt,
    overflow: TextOverflow.ellipsis,
    maxLines: 7,
    style:  TextStyle(
        fontSize: num,
        fontWeight: wt,
        color: clr,
        fontFamily: fontFamily,
        letterSpacing: spacing),
  );
}