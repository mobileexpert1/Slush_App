import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/controller/controller.dart';
import 'package:slush/controller/controller.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/widgets/text_widget.dart';

import '../../../controller/controller.dart';

class DetailNameScreen extends StatefulWidget {
  const DetailNameScreen({Key? key}) : super(key: key);

  @override
  State<DetailNameScreen> createState() => _DetailNameScreenState();
}

class _DetailNameScreenState extends State<DetailNameScreen> {
  TextEditingController nameController = TextEditingController(text: LocaleHandler.name);
  FocusNode nameNode = FocusNode();
  ValueNotifier<String> enableField = ValueNotifier("");

  @override
  void initState() {
    nameNode.addListener(() {
      if (nameNode.hasFocus) {
        enableField.value = "First name";
      } else {
        enableField.value = "";
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 3.h - 2),
        buildText2(
            "Let's setup your profile.", 28, FontWeight.w600, color.txtBlack),
        const SizedBox(height: 8),
        buildText(
            "What’s your first name?", 16, FontWeight.w500, color.txtBlack,
            fontFamily: FontFamily.hellix),
        SizedBox(height: 4.h - 1),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: ValueListenableBuilder(
              valueListenable: enableField,
              builder: (context, value, child) {
                return buildText(
                    " First name",
                    16,
                    FontWeight.w500,
                    enableField.value == "First name"
                        ? color.txtBlue
                        : color.txtgrey,
                    fontFamily: FontFamily.hellix);
              }),
        ),
        buildContainer(
          "First name",
          nameController,
          AutovalidateMode.onUserInteraction,
          nameNode,
          press: () {
            enableField.value = "First name";
          },
          gesture: GestureDetector(
              child: Container(
                  padding: const EdgeInsets.only(top: 5),
                  height: 20,
                  width: 30,
                  alignment: Alignment.center,
                  child: SvgPicture.asset(AssetsPics.userIcon))),
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 3.0, backgroundColor: color.green),
            buildText(" This is how it will appear in ", 14, FontWeight.w500,
                color.txtBlack,
                fontFamily: FontFamily.hellix),
            buildText("Slush.", 14, FontWeight.w600, color.txtgrey,
                fontFamily: FontFamily.hellix),
          ],
        ),
        SizedBox(height: 2.h - 2)
      ],
    );
  }

  Widget buildContainer(String txt, TextEditingController controller,
      AutovalidateMode auto, FocusNode node,
      {FormFieldValidator<String>? validation,
      VoidCallback? press,
      GestureDetector? gesture}) {
    final nameControl = Provider.of<nameControllerr>(context, listen: false);

    return Align(
      alignment: Alignment.center,
      child: ValueListenableBuilder(
          valueListenable: enableField,
          builder: (context, value, child) {
            return Container(
              height: 7.h + 2,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: color.txtWhite,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: enableField.value == txt
                          ? color.txtBlue
                          : color.txtWhite,
                      width: 1)),
              child: TextFormField(
                textCapitalization: TextCapitalization.words,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.done,
                onTap: press,
                focusNode: node,
                controller: controller,
                cursorColor: color.txtBlue,
                autovalidateMode: auto,
                validator: validation,
                inputFormatters: <TextInputFormatter>[UpperCaseTextFormatter()],
                onChanged: (val) {
                  if (val.trim() != "") {
                    controller.text = val.trim();
                    nameControl.getName(val.trim());
                  } else {
                    controller.text = "";
                  }
                },
                decoration: InputDecoration(
                  errorStyle: const TextStyle(height: 0, fontSize: 12),
                  border: InputBorder.none,
                  hintText: txt,
                  hintStyle: const TextStyle(
                      fontFamily: FontFamily.hellix,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: color.txtgrey2),
                  contentPadding:
                      const EdgeInsets.only(left: 20, right: 18, top: 15),
                  suffixIcon: gesture,
                ),
              ),
            );
          }),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: capitalize(newValue.text),
      selection: newValue.selection,
    );
  }
}

String capitalize(String value) {
  if (value.trim().isEmpty) return "";
  return "${value[0].toUpperCase()}${value.substring(1).toLowerCase()}";
}
