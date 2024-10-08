import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/loader.dart';
import 'package:slush/constants/prefs.dart';
import 'package:slush/controller/controller.dart';
import 'package:slush/controller/event_controller.dart';
import 'package:slush/controller/profile_controller.dart';
import 'package:slush/controller/spark_Liked_controler.dart';
import 'package:slush/screens/events/payment_history.dart';
import 'package:slush/screens/setting/account_settings.dart';
import 'package:slush/screens/setting/device_management.dart';
import 'package:slush/screens/setting/discovery_settings.dart';
import 'package:slush/screens/setting/faq_screen.dart';
import 'package:slush/screens/setting/notification_settings.dart';
import 'package:slush/screens/setting/saved_event.dart';
import 'package:slush/widgets/app_bar.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:slush/widgets/customtoptoaster.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:slush/widgets/toaster.dart';
import 'package:http/http.dart'as http;
import 'package:url_launcher/url_launcher.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  List<Settings> settingsType=[
    Settings(1,AssetsPics.notification, "Notification Settings", AssetsPics.rightArrow),
    Settings(2,AssetsPics.acSetting, "Account Settings", AssetsPics.rightArrow,),
    Settings(3,AssetsPics.discovery,  "Discovery Settings", AssetsPics.rightArrow,),
    // Settings(4,AssetsPics.deviceManagement,  "Device Management", AssetsPics.rightArrow,),
    Settings(5,AssetsPics.savedsetting,  "Saved Event", ""),
    Settings(6,AssetsPics.payment_history,  "Payment History", ""),
    Settings(7,AssetsPics.about,  "About Us", ""),
    Settings(8,AssetsPics.FAQ,  "FAQs", ""),
    Settings(9,AssetsPics.terms, "Terms and Conditions", ""),
    Settings(10,AssetsPics.contactus, "Contact us", ""),
  ];

  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Scaffold(
      // backgroundColor: color.backGroundClr,
      appBar: commonBarWithTextleft(context, color.backGroundClr, "Settings"),
      body: Stack(
        children: [
          SizedBox(height: size.height, width: size.width, child: Image.asset(AssetsPics.background,fit: BoxFit.cover),),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                   SizedBox(height: 2.h),
                  Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: color.txtWhite),
                    child: ListView.builder(
                        padding: const EdgeInsets.all(0.0),
                      shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: settingsType.length,
                        itemBuilder: (context,index){
                          return Column(
                            children: [
                              ListTile(
                                onTap: (){
                                  callNavigationFunction(settingsType[index].id);
                                },
                                contentPadding: const EdgeInsets.only(top: 4,left: 20,right: 20),
                                leading: SvgPicture.asset(settingsType[index].img),
                                title: buildText(settingsType[index].settingsType, 18, FontWeight.w600, color.txtBlack),
                                trailing: settingsType[index].img2 == "" ? const SizedBox() :SvgPicture.asset(settingsType[index].img2),
                              ),
                              index == settingsType.length -1 ? const SizedBox() : const Divider(height: 5, thickness: 1,
                                indent: 20, endIndent: 20, color: color.example3),
                            ],
                          );
                        }),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      customDialogBoxWithtwobutton(context, "Are you sure you want to logout?", "",img: AssetsPics.logoutpng,isPng: true,
                          btnTxt1: "Cancel",btnTxt2: "Yes, logout",onTap2: (){
                            logout();removeData();Provider.of<ReelController>(context,listen: false).removeVideoLimit(context);});
                    },
                    child: Container(
                      padding:  const EdgeInsets.only(left: 25),
                      alignment: Alignment.centerLeft,
                      // height: 60,
                      height: size.height*0.07,
                      width: size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: color.logOutRed
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(AssetsPics.logout),
                          const SizedBox(width: 8,),
                          buildText("Logout", 18, FontWeight.w600, color.txtWhite),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 5.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> callNavigationFunction(int i) async {
         if(i==1){Get.to(()=>const NotificationSettings());}
    else if(i==2){Get.to(()=>const AccountSettings());}
    else if(i==3){Get.to(()=>const DiscoverySettings());}
    else if(i==4){Get.to(()=>const DeviceManagement());
    }
    else if(i==5){Get.to(()=>MySavedEvent());}
    else if(i==6){Get.to(()=>const PaymentHistoryScreen());}
    else if(i==7){
           var url = Uri.parse('https://www.slushdating.com/');
           if (await canLaunchUrl(url)) {await launchUrl(url, mode: LaunchMode.inAppWebView);}
           else {throw 'Could not launch $url';}}
    else if(i==8){//Get.to(()=>const AboutSlush());

    }
    else if(i==9){
           // if (await canLaunch(url)) {await launch(url, forceWebView: true, enableJavaScript: true);}
           var url = Uri.parse('https://www.slushdating.com/terms-of-use');
           if (await canLaunchUrl(url)) {await launchUrl(url, mode: LaunchMode.inAppWebView);}
           else {throw 'Could not launch $url';}
      // snackBaar(context,AssetsPics.redbanner,false);
           // snackBaarblue(context,AssetsPics.banner,"Event starting in 15 minutes, Click Hereto join the waiting room!");
           // snackBaar(context, AssetsPics.verifyinprocesssvg,false);
           // snackBaar(context, AssetsPics.editBannerSvg,false);
           // snackBaarblue(context, AssetsPics.unMatchedbgsvg);
           // snackBaar(context, AssetsPics.unMatchedbgsvg,false);
         }
    else if(i==10){
           var url = Uri.parse('https://www.slushdating.com/contact');
           if (await canLaunchUrl(url)) {await launchUrl(url, mode: LaunchMode.inAppWebView);}
           else {throw 'Could not launch $url';}}
    else {}
  }

  /*  showSnackBarFun(context) {
    SnackBar snackBar = SnackBar(
      // content: const Text('Yay! A SnackBar at the top!', style: TextStyle(fontSize: 20)),
      content: Image.asset(AssetsPics.unMatchedbg,fit: BoxFit.cover),
      dismissDirection: DismissDirection.endToStart,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 60),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }*/

  Future logout() async {
    setState(() {LoaderOverlay.show(context);});
    LocaleHandler.accessToken=await Preferences.getValue("token")??"";
    LocaleHandler.bearer="Bearer ${LocaleHandler.accessToken}";
    const url = ApiList.logout;
    print(url);
    var uri=Uri.parse(url);
    var response = await http.post(uri, headers: {'Content-Type': 'application/json', 'Authorization': "Bearer ${LocaleHandler.accessToken}"},);
      // Fluttertoast.showToast(msg: "Logout Successfully"); Preferences.setToken(LocaleHandler.bearer='');
        showToastMsgTokenExpired(msg: "Logout successful");
        Provider.of<SparkLikedController>(context,listen: false).cleanSparkLike();
    setState(() {LoaderOverlay.hide();});
  }

  void removeData(){
    Provider.of<eventController>(context, listen: false).removeMyEvent();
    Provider.of<profileController>(context,listen: false).removeData();
  }

}
class Settings{
  int id;
  String img;
  String settingsType;
  String img2;
  Settings( this.id,this.img , this.settingsType, this.img2);
}
