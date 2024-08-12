import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/widgets/text_widget.dart';

Widget blue_button(BuildContext context,String name,{bool validation=true,VoidCallback? press,Color clr=color.disableButton}) {
  return GestureDetector(
    onTap: press,
    child: Container(
      alignment: Alignment.center,
      height: 56,
      // height: MediaQuery.of(context).size.height*0.07,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
          gradient:  LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors:validation==false?[clr,clr]: [
                color.gradientLightBlue,
                color.txtBlue
              ],
    )
      ),
      child: buildText(name,18,FontWeight.w600,color.txtWhite),
    ),
  );
}

Widget white_button(BuildContext context,String name,{VoidCallback? press}) {
  return GestureDetector(
    onTap: press,
    child: Container(
      alignment: Alignment.center,
      height: 56,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
        color: color.txtWhite,
          border: Border.all(width: 1.5,color: color.txtBlue)
      ),
      child: buildText(name,18,FontWeight.w600,color.txtBlue),
    ),
  );
}

Widget white_button_woBorder(BuildContext context,String name,{VoidCallback? press}) {
  return GestureDetector(
    onTap: press,
    child: Container(
      alignment: Alignment.center,
      height: 56,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
          color: color.txtWhite,
          // border: Border.all(width: 1.5,color: color.txtBlue)
      ),
      child: buildText(name,18,FontWeight.w600,color.txtBlue),
    ),
  );
}

Widget blue_button_half(BuildContext context,
    String name,
    {bool validation=true,VoidCallback? press}) {
  return GestureDetector(
    onTap: press,
    child: Container(
      alignment: Alignment.center,
      height: 6.h-2,
      width: MediaQuery.of(context).size.width/2-25,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
          gradient:  LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors:validation==false?[color.disableButton,color.disableButton]: [
              color.gradientLightBlue,
              color.txtBlue
            ],
          )
      ),
      child: buildText(name,18,FontWeight.w600,color.txtWhite),
    ),
  );
}

Widget white_button_half(BuildContext context,String name,{VoidCallback? press}) {
  return GestureDetector(
    onTap: press,
    child: Container(
      alignment: Alignment.center,
      height: 6.h-2,
      width: MediaQuery.of(context).size.width/2-25,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
          color: color.txtWhite,
          border: Border.all(width: 1.0,color: color.lightestBlue)
      ),
      child: buildText(name,16,FontWeight.w600,color.txtBlack),
    ),
  );
}


Widget blue_buttonwidehi(BuildContext context,String name,{bool validation=true,VoidCallback? press,Color clr=color.disableButton}) {
  return GestureDetector(
    onTap: press,
    child: Container(
      alignment: Alignment.center,
      height: 75,
      // height: MediaQuery.of(context).size.height*0.07,
      width: MediaQuery.of(context).size.width*0.9,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
          gradient:  LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors:validation==false?[clr,clr]: [
              color.gradientLightBlue,
              color.txtBlue
            ],
          )
      ),
      child: buildText(name,18,FontWeight.w600,color.txtWhite),
    ),
  );
}