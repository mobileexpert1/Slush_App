import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/prefs.dart';
import 'package:slush/widgets/app_bar.dart';
import 'package:slush/widgets/text_widget.dart';


class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {

  List<Notification> notificationSetting=[
    Notification(1, "New matches", "Receive new match notifications",false),
    Notification(2, "Event", "Get notified about new events",false),
    Notification(3, "Message", "Never miss a message",false),
    Notification(4, "Likes", "Get notified when someone likes you",false),
  ];
  bool isSwitch=false;
  List<int> item = [];
  int selectedIndex= 0;
  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Scaffold(
      // backgroundColor: color.backGroundClr,
      appBar: commonBarWithTextleft(context, color.backGroundClr, "Notification Settings"),
      body: Stack(
        children: [
          SizedBox(
            height: size.height,
            width: size.width,
            child: Image.asset(AssetsPics.background,fit: BoxFit.cover,),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                const SizedBox(height: 30),
                Container(
                  // height: 380,
                  // height: 49.h-2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: color.txtWhite,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                      // physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(0.0),
                      itemCount: notificationSetting.length,
                      itemBuilder: (context,index){
                      if(LocaleHandler.switchitem.contains(notificationSetting[index].Id.toString())){notificationSetting[index].val=true;}
                      else{notificationSetting[index].val=false;}
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if(LocaleHandler.switchitem.contains(notificationSetting[index].Id.toString())){
                                    notificationSetting[index].val = false;
                                    LocaleHandler.switchitem.remove(notificationSetting[index].Id.toString());
                                    Preferences.setList(LocaleHandler.switchitem);
                                  }else{
                                    notificationSetting[index].val = true;
                                    LocaleHandler.switchitem.add(notificationSetting[index].Id.toString());
                                    Preferences.setList(LocaleHandler.switchitem);
                                  }
                                });
                              },
                              child: Container(color: Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 11,right: 10,top: 18,bottom: 16),
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            buildText(notificationSetting[index].title, 18, FontWeight.w600, color.txtBlack),
                                            const SizedBox(height: 5),
                                            SizedBox(
                                                width: 265,
                                                child: buildTextoneline(notificationSetting[index].subTitle, 16, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix)),
                                          ],),
                                        /*Align(
                                          alignment: Alignment.centerRight,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    isSwitch = !isSwitch;
                                                  });
                                                },
                                                child: Container(
                                                  height: 5.h-2,
                                                  width: 10.h-2,
                                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),),
                                                  child: Stack(
                                                    children: [
                                                      Positioned(
                                                        child: Stack(
                                                          children:[
                                                            Positioned(
                                                              child: Container(
                                                                margin:const EdgeInsets.all(10),
                                                                height: 3.h-3,
                                                                width: 5.h,
                                                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: isSwitch ? color.example3 : color.txtgrey4,),
                                                              ),
                                                            )],
                                                        ),
                                                      ),
                                                      // Thumb
                                                      Positioned(
                                                        left: isSwitch ? 30 : 6,
                                                        top: 7,
                                                        child: Container(
                                                          height: 3.h+1,
                                                          width: 3.h+1,
                                                          decoration: BoxDecoration(
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors.grey.withOpacity(0.9),
                                                                spreadRadius: 0,
                                                                blurRadius: 5,
                                                                offset: const Offset(0,0), // changes position of shadow
                                                              ),
                                                            ],
                                                            shape: BoxShape.circle,
                                                            color: isSwitch ? color.txtBlue : color.txtWhite,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                            ],
                                          ),
                                        )*/
                                        IgnorePointer(
                                          child: CustomAnimatedToggleSwitch<bool>(
                                            current:LocaleHandler.switchitem.contains(notificationSetting[index].Id.toString())?true:false,
                                            values: [false, true],
                                            indicatorSize: const Size.square(22.0),
                                            animationDuration: const Duration(milliseconds: 200),
                                            animationCurve: Curves.linear,
                                            onChanged: (b) => setState(() => notificationSetting[index].val = b),
                                            iconBuilder: (context, local, global) {return const SizedBox();},
                                            cursors: const ToggleCursors(defaultCursor: SystemMouseCursors.click,),
                                            onTap: (_) {
                                              setState(() {
                                                notificationSetting[index].val=!notificationSetting[index].val;
                                              });
                                              // setState(() {
                                              //   if(LocaleHandler.switchitem.contains(notificationSetting[index].Id)){
                                              //     notificationSetting[index].val = false;
                                              //     LocaleHandler.switchitem.remove(notificationSetting[index].Id);
                                              //   }else{
                                              //     notificationSetting[index].val = true;
                                              //     LocaleHandler.switchitem.add(notificationSetting[index].Id);
                                              //   }
                                              // });
                                              },
                                                // setState(() => notificationSetting[index].val = !notificationSetting[index].val),
                                            iconsTappable: false,
                                            wrapperBuilder: (context, global, child) {
                                              return Stack(alignment: Alignment.center,
                                                children: [
                                                   Positioned(left: 10.0, right: 10.0, height: 15.0,
                                                      child: DecoratedBox(
                                                        decoration: BoxDecoration(color:notificationSetting[index].val?color.example3: Colors.black26,
                                                          borderRadius: const BorderRadius.all(Radius.circular(50.0)),),
                                                      )),
                                                  child,
                                                ],
                                              );
                                            },
                                            foregroundIndicatorBuilder: (context, global) {
                                              return SizedBox.fromSize(
                                                size: global.indicatorSize,
                                                child: DecoratedBox(
                                                  decoration: BoxDecoration(
                                                    color:notificationSetting[index].val?color.txtBlue: Colors.white,
                                                    borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                                                    boxShadow: const [
                                                      BoxShadow(color: Colors.black38, spreadRadius: 0.05, blurRadius: 1.1, offset: Offset(0.0, 0.8))
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],),
                                  ),
                                ),
                              ),
                            ),
                            index == notificationSetting.length -1 ? const SizedBox() : const Divider(
                              height: 5,
                              thickness: 1,
                              indent: 20,
                              endIndent: 20,
                              color: color.example3,
                            ),
                          ],
                        );
                      }),
                ),
                const SizedBox(height: 20,),
              ],
            ),
          )
        ],
      ),
    );
  }
}
class Notification{
  int Id;
  String title;
  String subTitle;
  bool val;
  Notification(this.Id,this.title,this.subTitle,this.val);
}