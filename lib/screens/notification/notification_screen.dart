import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/widgets/app_bar.dart';
import 'package:slush/widgets/text_widget.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreen1State();
}

class _NotificationScreen1State extends State<NotificationScreen> {
  List<Notification> items=[
    Notification(1, "Ashwin Bose has liked you", "Would you match now ?","2m ago","","Likes"),
    Notification(2, "Profile Update ", "Only 15% of profile if updated ","4m ago","Go to Profile",""),
    Notification(3, "Aahan has liked you back", "It’s a match","4m ago","Chat Now","Match"),
    Notification(4,
        "Account Security Alert", "We’ve detected unsual activity. Please\nverify your accounr for added security.",
        "4m ago","",""),
  ];

  bool textValue=false;

  List category=["All","General","Match","Likes"];
  int selectedIndex=0;
bool noNotification=true;

@override
  void initState() {
  Future.delayed(Duration(seconds: 10),(){
    setState(() {
      // noNotification=false;
    });
  });
  super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;

    return Scaffold(
      // backgroundColor: color.backGroundClr,
      appBar: commonBarWithTextleft(context, color.backGroundClr, "Notification"),
      body: Stack(
        children: [
          SizedBox(
            height: size.height,
            width: size.width,
            child: Image.asset(AssetsPics.background,fit: BoxFit.cover,),
          ),
          SingleChildScrollView(
            child: Padding(padding: const EdgeInsets.only(left: 15,right: 15,top: 20),
              child: Column(
                children: [
                  Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      height: 46,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        // shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: category.length,
                          itemBuilder: (context,index){
                            return Row(children: [
                              GestureDetector(
                                  onTap: (){setState(() {selectedIndex=index;});},
                                  child:selectedIndex==index? selectedButton(category[index]):unselectedButton(category[index])),
                              index==0?Container(margin: const EdgeInsets.only(left: 6,right: 6),
                                height: 23,width: 2,color: const Color.fromRGBO(217, 217, 217, 1),
                              ):const SizedBox(),
                            ],);})
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12), color: color.txtWhite),
                    child:noNotification?Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top:120.0,
                          child: Container(
                            // color: Colors.red,
                              height: 22.h,
                              width: 23.h,
                              alignment: Alignment.center,
                              child: SvgPicture.asset(AssetsPics.bigheart,fit: BoxFit.cover,)),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 15.h),
                            Stack(
                              children: [
                                Positioned(
                                  left: 130,
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: SvgPicture.asset(AssetsPics.threeDotsLeft),),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  child:Image.asset(AssetsPics.nonotification),),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            buildText("No notification? ", 30, FontWeight.w600, color.txtBlue),
                            SizedBox(height: 2.h),
                            buildText2("You have not recieved any \n notifications yet.", 18, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
                            SizedBox(height: 22.h)
                          ],
                        ),
                      ],
                    ): ListView.builder(
                        padding: EdgeInsets.all(0.0),
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        itemBuilder: (context,index){
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 8),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  // mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(AssetsPics.mailImg,height: 40),
                                    const SizedBox(width: 15),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            buildText(items[index].title, 16, FontWeight.w600, color.txtBlack,fontFamily: FontFamily.hellix),
                                            const SizedBox(width: 10,),
                                            items[index].pContainer == "" ? const SizedBox() : Container(
                                              padding: const EdgeInsets.only(right: 3),
                                              alignment: Alignment.center,
                                              width: 55,
                                              height: 17,
                                              color: color.gradientLightBlue,
                                              transform: Matrix4.skewX(-.3),
                                              child: Transform(
                                                  transform: Matrix4.skewX(.2),
                                                  child: buildText(items[index].pContainer, 13, FontWeight.w600, color.txtWhite,fontFamily: FontFamily.hellix)),
                                            ),
                                          ],
                                        ),
                                        buildText(items[index].subTitle, 15, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
                                        const SizedBox(height: 8),
                                        index == 0 ?  Row(
                                          children: [
                                            Container(
                                              height: 48,
                                              width: 48,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(100),
                                                  border: Border.all(color: color.lightestBlue)
                                              ),
                                              child: const Icon(Icons.heart_broken_sharp),
                                            ),
                                            const SizedBox(width: 15,),
                                            Container(
                                              height: 48,
                                              width: 48,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(100),
                                                  border: Border.all(color: color.lightestBlue)
                                              ),
                                              child: const Icon(Icons.heart_broken_sharp),
                                            ),
                                          ],
                                        ) :
                                        items[index].button == ""? const SizedBox() : Container(
                                          alignment: Alignment.center,
                                          height: 36,
                                          padding: const EdgeInsets.symmetric(horizontal: 15),
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(19),
                                              gradient:  const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
                                                colors:[color.gradientLightBlue, color.txtBlue],)
                                          ),
                                          child: buildText(items[index].button,16,FontWeight.w600,color.txtWhite),
                                        ),

                                        const SizedBox(height: 10,),
                                        buildText(items[index].time, 14, FontWeight.w600, color.dropDowngreytxt,fontFamily: FontFamily.hellix),
                                      ],
                                    )
                                  ],
                                ),
                                index == items.length -1 ? const SizedBox() : const Divider(
                                  height: 30,
                                  thickness: 1,
                                  color: color.example3,
                                ),

                              ],
                            ),
                          );
                        }),
                  ),
                  const SizedBox(height: 50),
                ],),
            ),
          ),
        ],
      ),
    );
  }

  Widget selectedButton(String btntxt) {
    return Container(
      padding: const EdgeInsets.only(left: 18,right: 18,top: 6,bottom: 6),
      margin: const EdgeInsets.only(right: 4,left: 4),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
              width: 1,color: color.txtBlue
          ),
          gradient:  const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
            colors:[color.gradientLightBlue, color.txtBlue],)
      ),
      child: buildText(btntxt, 16, FontWeight.w600, color.txtWhite),
    );
  }

  Widget unselectedButton(String btntxt) {
    return Container(
      padding: const EdgeInsets.only(left: 18,right: 18,top: 6,bottom: 6),
      margin: const EdgeInsets.only(right: 4,left: 4),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
              width: 1,color: color.disableButton
          )
      ),
      child: buildText(btntxt, 16, FontWeight.w600, color.txtBlack),
    );
  }
}
class Notification{
  int id;
  String title;
  String subTitle;
  String time;
  String button;
  String pContainer;
  Notification(this.id,this.title,this.subTitle,this.time,this.button,this.pContainer);
}