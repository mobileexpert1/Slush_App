import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/widgets/text_widget.dart';

class WorkScreen extends StatefulWidget {
  const WorkScreen({Key? key}) : super(key: key);

  @override
  State<WorkScreen> createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {
  TextEditingController jobTitleControler= TextEditingController(text: LocaleHandler.jobtitle);
  TextEditingController companyNameControler= TextEditingController(text: LocaleHandler.companyName);
  FocusNode jobTitleNode=FocusNode();
  FocusNode companyNameNode=FocusNode();
  String enableField="";

  @override
  void initState() {
    check();
    jobTitleNode.addListener(() {
      if(jobTitleNode.hasFocus){
        enableField="Enter job title";
      }else{
        enableField="";
      }
    });

    companyNameNode.addListener(() {
      if(companyNameNode.hasFocus){
        enableField="Enter company name";
      }else{
        enableField="";
      }
    });
    super.initState();
  }

  void check(){
    // if(LocaleHandler.EditProfile&&LocaleHandler.dataa["jobTitle"]!=null){
    if(LocaleHandler.EditProfile&&LocaleHandler.dataa["jobTitle"]!=null&&LocaleHandler.jobtitle!=""){
      jobTitleControler.text= LocaleHandler.jobtitle;}
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SizedBox(height: 3.h-3),
        buildText2("What do you do for work?", 28, FontWeight.w600, color.txtBlack),
         SizedBox(height: 3.h),
        Padding(
          padding: const EdgeInsets.only(left: 4,bottom: 4),
          child: buildText("Job title", 16, FontWeight.w500,enableField =="Enter job title"? color.txtBlue:color.txtgrey,fontFamily: FontFamily.hellix),
        ),
        buildContainer(
          "Enter job title", jobTitleControler, AutovalidateMode.onUserInteraction, jobTitleNode,
           (value){LocaleHandler.jobtitle=value;},
          gesture: GestureDetector(
              child: Container(
                  padding: const EdgeInsets.only(top: 5),
                  height: 20,width: 30,
                  alignment: Alignment.center,
                  child: SvgPicture.asset(AssetsPics.mailIcon))
          ),
        ),
        SizedBox(height: 3.h),
        Padding(
          padding: const EdgeInsets.only(left: 4,bottom: 4),
          child: buildText("Company name", 16, FontWeight.w500,enableField =="Enter company name"? color.txtBlue:color.txtgrey,fontFamily: FontFamily.hellix),
        ),
        buildContainer(
          "Enter company name", companyNameControler, AutovalidateMode.onUserInteraction, companyNameNode,(val){LocaleHandler.companyName=val;},
          gesture: GestureDetector(
              child: Container(
                  padding: const EdgeInsets.only(top: 5),
                  height: 20,width: 30,
                  alignment: Alignment.center,
                  child: SvgPicture.asset(AssetsPics.Buildings))
          ),
        ),
        const Spacer(),
        SizedBox(height: 2.h-3)
      ],);
  }

  Widget buildContainer(String txt,
      TextEditingController controller,
      AutovalidateMode auto,FocusNode node,
      Function(String) onchange,
      {FormFieldValidator<String>? validation,VoidCallback? press,GestureDetector? gesture,}) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        height: 56,
        width: MediaQuery.of(context).size.width,
        decoration:  BoxDecoration(color: color.txtWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color:enableField == txt? color.txtBlue:color.txtWhite, width:1)),
        child: TextFormField(
          textInputAction: TextInputAction.done,
          onTap: press,
          focusNode: node,
          onChanged: onchange,
          controller: controller,
          cursorColor: color.txtBlue,
          autovalidateMode: auto,
          validator: validation,
          decoration: InputDecoration(
            errorStyle: const TextStyle(height: 0, fontSize: 12),
            border: InputBorder.none,
            hintText: txt,hintStyle: const TextStyle(fontFamily: FontFamily.hellix,fontSize: 16,fontWeight: FontWeight.w500,color: color.txtgrey2),
            contentPadding: const EdgeInsets.only(left: 20,right: 18,top: 15),
            suffixIcon: gesture,
          ),
        ),
      ),
    );
  }
}
