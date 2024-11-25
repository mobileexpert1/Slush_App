import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
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
import 'package:slush/screens/setting/notification_settings.dart';
import 'package:slush/screens/setting/saved_event.dart';
import 'package:slush/widgets/app_bar.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/bottom_sheet.dart';
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
    Settings(12,AssetsPics.terms, "Privacy Policy", ""),
    Settings(10,AssetsPics.contactus, "Contact us", ""),
    Settings(11,AssetsPics.payment_history, "Restore Purchase", ""),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initialize();
    _iap.purchaseStream.listen((purchaseDetailsList) {
      _handlePurchaseUpdates(purchaseDetailsList);
    });
  }
  bool _available = true;
  List<ProductDetails> _products = [];
  Future<void> _initialize() async {
    final bool isAvailable = await _iap.isAvailable();
    _available = isAvailable;
    if (_available) {
      // const Set<String> _kIds = {'silversubscription','goldsubscription','platinumsubscription'};
      const Set<String> _kIds = {'silversubscription'};
      final ProductDetailsResponse response = await _iap.queryProductDetails(_kIds);
      setState(() {_products = response.productDetails;});
      if (response.notFoundIDs.isNotEmpty && response.error == null) {
        print('Products not found: ${response.notFoundIDs}');
      }
    }
  }

  // Method to handle purchase updates
  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.restored) {
        print('Purchase restored: ${purchase.productID}');
        // Handle restoring of purchased items (e.g., unlock premium features)
      }
    }
  }
  // Method to trigger restoring of purchases
  Future<void> _restorePurchases() async {
    try {
      await _iap.restorePurchases();
      print('Restoring purchases...');
      Get.back();
      showToastMsg('Restoring purchases...');
    } catch (e) {
      showToastMsg('Error restoring purchases: $e');
      print('Error restoring purchases: $e');
      Get.back();
    }
  }

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
  final InAppPurchase _iap = InAppPurchase.instance;
  Future<void> callNavigationFunction(int i) async {
         if(i==1){Get.to(()=>const NotificationSettings());}
    else if(i==2){Get.to(()=>const AccountSettings());}
    else if(i==3){Get.to(()=>const DiscoverySettings());}
    else if(i==4){Get.to(()=>const DeviceManagement());}
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
         }
    else if(i==10){
           var url = Uri.parse('https://www.slushdating.com/contact');
           if (await canLaunchUrl(url)) {await launchUrl(url, mode: LaunchMode.inAppWebView);}
           else {throw 'Could not launch $url';}}
    else if(i==12){
           var url = Uri.parse('https://www.slushdating.com/privacy-policy');
           if (await canLaunchUrl(url)) {await launchUrl(url, mode: LaunchMode.inAppWebView);}
           else {throw 'Could not launch $url';}}
    else if (i==11){
      if(LocaleHandler.subscriptionPurchase=="no"){
        showToastMsg("Didnot have any previous purchase subscription!");
      }
      else{customDialogWithPicture(context);}

     //  setState(() {LoaderOverlay.show(context);});
     // await Future.delayed(const Duration(seconds: 3));
     //  _restorePurchases();
     //  setState(() {LoaderOverlay.hide();});
         }
    else {}
  }

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


  customDialogWithPicture(BuildContext context, {VoidCallback? onTap = pressed}) {
    return showGeneralDialog(
        barrierLabel: "Label",
        transitionDuration: const Duration(milliseconds: 500),
        context: context,
        pageBuilder: (context, anim1, anim2) {
          return StatefulBuilder(builder: (context, setState) {
            return GestureDetector(
              onTap: onTap,
              child: Scaffold(
                backgroundColor: Colors.black54,
                body: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      width: MediaQuery.of(context).size.width / 1.1,
                      // margin: const EdgeInsets.symmetric(horizontal: 16,vertical: 10),
                      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: color.txtWhite,
                          borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.center,
                            height: 220,
                            width: MediaQuery.of(context).size.width,
                            // color: Colors.red,
                            child: PageView(
                              controller: controller,
                              onPageChanged: (val){
                                setState(() {indicatorIndex=val;});
                              },
                              children: [
                                // customScroller(text1: 'Plan Details', text2: 'Slush Silver for 1 month plan\nat £9.99', iconName: AssetsPics.like),
                                customScroller(text1: 'Plan Details', text2: 'Slush Silver for 1 month plan\nat ${_products[0].price}', iconName: AssetsPics.like),
                                // customScroller(text1: 'Plan Duration', text2: '30 days Subscription plan', iconName: AssetsPics.like),
                                customScroller(text1: 'More Sparks', text2: 'Get 3 Sparks now + 1 daily for 1 month.\n Boost your connection!', iconName: AssetsPics.shock),
                                customScroller(text1: 'Unlimited Swipes', text2: 'Endless swiping', iconName: AssetsPics.watch),
                                customScroller(text1: 'Rules', text2: 'For privacy policy and term & condition please go to setting section', iconName: AssetsPics.watch),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List<Widget>.generate(3, (int index) {
                              return Container(
                                margin: const EdgeInsets.only(left: 2.0, right: 2.0, bottom: 12.0),
                                width: indicatorIndex == index ? 13 : 12.0,
                                height: indicatorIndex == index ? 13 : 12.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: indicatorIndex == index ? Colors.blue : Colors.grey,
                                    width: indicatorIndex == index ? 3 : 1,
                                  ),
                                  //shape: BoxShape.circle,
                                  // color: currentIndex == index ? Colors.blue : Colors.grey,
                                ),
                              );
                            }),
                          ),
                          blue_button(context, "Restore", press: () async{
                             setState(() {LoaderOverlay.show(context);});
                            await Future.delayed(const Duration(seconds: 3));
                             _restorePurchases();
                             setState(() {LoaderOverlay.hide();});
                          })
                        ],
                      )),
                ),
              ),
            );
          });
        },
        transitionBuilder: (context, anim1, anim2, child) {
          return SlideTransition(
            position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(anim1),
            child: child,
          );
        });
  }

  int indicatorIndex = 0;
  PageController controller = PageController();

  customScroller({required String text1, required String text2, required String iconName,}){
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: SvgPicture.asset(iconName,height:12.h),
        ),
        buildText(text1, 19.sp, FontWeight.w600, color.txtBlack),
        text1=="Plan Details"?buildText2(text2, 16.sp, FontWeight.bold, color.txtgrey,fontFamily: FontFamily.hellix): buildText2(text2, 16.sp, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
      ],
    );
  }
}
class Settings{
  int id;
  String img;
  String settingsType;
  String img2;
  Settings( this.id,this.img , this.settingsType, this.img2);
}
