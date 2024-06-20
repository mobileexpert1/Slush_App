import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/widgets/text_widget.dart';

class EducationQualificationScreen extends StatefulWidget {
  const EducationQualificationScreen({Key? key}) : super(key: key);

  @override
  State<EducationQualificationScreen> createState() => _EducationQualificationScreenState();
}

class _EducationQualificationScreenState extends State<EducationQualificationScreen> {
  TextEditingController jobTitleControler= TextEditingController();
  FocusNode jobTitleNode=FocusNode();
  FocusNode companyNameNode=FocusNode();
  String enableField="";

  @override
  void initState() {
    if(LocaleHandler.education!=""){
      jobTitleControler.text=LocaleHandler.education;
    }
    jobTitleNode.addListener(() {
      if(jobTitleNode.hasFocus){
        enableField="Enter job title";
      }else{
        enableField="";
      }
    });
    print(LocaleHandler.dataa);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SizedBox(height: 3.h-3),
        buildText2("What did you study?", 28, FontWeight.w600, color.txtBlack),
        SizedBox(height: 3.h),
        Padding(
          padding: const EdgeInsets.only(left: 4,bottom: 4),
          child: buildText("School or university", 16, FontWeight.w500,enableField =="Enter job title"? color.txtBlue:color.txtgrey,fontFamily: FontFamily.hellix),
        ),
        buildContainer(
          "Enter job title", jobTitleControler, AutovalidateMode.onUserInteraction, jobTitleNode,
          gesture: GestureDetector(
              child: Container(
                  padding: const EdgeInsets.only(top: 5),
                  height: 20,width: 30,
                  alignment: Alignment.center,
                  child: SvgPicture.asset(AssetsPics.education))
          ),
        ),
        const Spacer(),
        SizedBox(height: 2.h-3)
      ],);
  }

  Widget buildContainer(String txt,
      TextEditingController controller,
      AutovalidateMode auto,FocusNode node,
      {FormFieldValidator<String>? validation,VoidCallback? press,GestureDetector? gesture}) {
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
          controller: controller,
          cursorColor: color.txtBlue,
          onChanged: (val){
              LocaleHandler.education=val;
          },
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
