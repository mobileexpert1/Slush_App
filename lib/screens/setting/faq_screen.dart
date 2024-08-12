import 'package:flutter/material.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/widgets/app_bar.dart';
import 'package:slush/widgets/text_widget.dart';

class AboutSlush extends StatefulWidget {
  const AboutSlush({Key? key}) : super(key: key);

  @override
  State<AboutSlush> createState() => _AboutSlushState();
}

class _AboutSlushState extends State<AboutSlush> {
  List<String> category = [
    "About Slush",
    "Profile",
    "Subscription",
    "Payments",
    "Messages",
    "Verification"
  ];

  int selectedIndex = 0;
  int expandedIndex = -1;

  List<String> aboutSlush = [
    "What is Slush?",
    "How do I create a Slush account?",
    "Is slush free to use?",
    "How do I report user?",
    "How does matching work on Slush?",
    "Can I change Location?",
    "Is Slush free to use?"
  ];

  List<String> slushProfile = [
    "How do I delete my profile?",
    "Why should I verify profile pictures?",
    "How can I change my location?",
    "How can I add interests to profile?",
    "How can I change my gender?",
  ];

  List<String> slushSubscription = [
    "What is Slush subscription?",
    "How can I buy subscription?",
    "How do I unsubscribe?",
    "What is my payment method?",
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    List<String> currentList = selectedIndex == 0
        ? aboutSlush
        : selectedIndex == 1
        ? slushProfile
        : slushSubscription;

    return Scaffold(
      appBar: commonBarWithTextleft(context, color.backGroundClr, "FAQs"),
      body: Stack(
        children: [
          SizedBox(
            height: size.height,
            width: size.width,
            child: Image.asset(
              AssetsPics.background,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  height: 46,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: category.length,
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                                expandedIndex = -1; // Reset the expanded index
                              });
                            },
                            child: selectedIndex == index
                                ? selectedButton(category[index])
                                : unselectedButton(category[index]),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: color.txtWhite,
                    ),
                    child: Theme(
                      data: ThemeData(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: currentList.length,
                        itemBuilder: (context, index) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ExpansionTile(
                                key: Key('$selectedIndex-$index'),
                                initiallyExpanded: index == expandedIndex,
                                onExpansionChanged: (bool expanded) {
                                  setState(() {
                                    expandedIndex = expanded ? index : -1;
                                  });
                                },
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                ),
                                title: buildText(
                                  currentList[index],
                                  18,
                                  FontWeight.w600,
                                  color.txtBlack,
                                ),
                                backgroundColor: Colors.transparent,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15, right: 10, bottom: 5),
                                    child: buildText(
                                      "Slush is a dating app designed to help you meet new people, make meaningful connections, and find potential matches based on your interest and preferences.",
                                      16,
                                      FontWeight.w500,
                                      color.txtgrey,
                                      fontFamily: FontFamily.hellix,
                                    ),
                                  ),
                                ],
                              ),
                              index == currentList.length - 1
                                  ? const SizedBox()
                                  : const Divider(
                                height: 5,
                                thickness: 1,
                                indent: 20,
                                endIndent: 20,
                                color: color.example3,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget selectedButton(String btntxt) {
    return Container(
      padding: const EdgeInsets.only(left: 18, right: 18, top: 6, bottom: 6),
      margin: const EdgeInsets.only(right: 4, left: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(width: 1, color: color.txtBlue),
        gradient: const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [color.gradientLightBlue, color.txtBlue],
        ),
      ),
      child: buildText(btntxt, 16, FontWeight.w600, color.txtWhite),
    );
  }

  Widget unselectedButton(String btntxt) {
    return Container(
      padding: const EdgeInsets.only(left: 18, right: 18, top: 6, bottom: 6),
      margin: const EdgeInsets.only(right: 4, left: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(width: 1, color: color.disableButton),
      ),
      child: buildText(btntxt, 16, FontWeight.w600, color.txtBlack),
    );
  }
}