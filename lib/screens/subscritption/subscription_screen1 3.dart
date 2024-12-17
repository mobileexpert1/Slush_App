import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/loader.dart';
import 'package:slush/screens/events/bottomNavigation.dart';
import 'package:slush/widgets/alert_dialog.dart';
import 'package:slush/widgets/app_bar.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:http/http.dart'as http;
import 'package:slush/widgets/toaster.dart';
import 'package:intl/intl.dart';

import '../../widgets/bottom_sheet.dart';

class Subscription1 extends StatefulWidget {
  const Subscription1({super.key});

  @override
  State<Subscription1> createState() => _Subscription1State();
}

class _Subscription1State extends State<Subscription1> {
  PageController _pageController = PageController(initialPage: 0);
  int currentIndex = 0;
  int selectedIndex = 2;
  bool upgradepressed=true;
  bool showALert=false;
  bool buttonPressed=false;

  final InAppPurchase _iap = InAppPurchase.instance;
  bool _available = true;
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  @override
  void initState() {
    subscriptionDetails();
    // _pageController.addListener(() {
    //   setState(() {currentIndex = _pageController.page!.round();});
    // });
    print(LocaleHandler.subscriptionPurchase);
    super.initState();
    _initialize();
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen((purchases) {
      _handlePurchaseUpdates(purchases);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // handle error here
    });
  }

  Future<void> _initialize() async {
    final bool isAvailable = await _iap.isAvailable();
    _available = isAvailable;
    if (_available) {
      // const Set<String> _kIds = {'silversubscription','goldsubscription','platinumsubscription'};
      const Set<String> _kAndroidIds = {'silversubscription'};
      // const Set<String> _kiOsIds = {'Tier1'};
      const Set<String> _kiOsIds = {'com.slush.silver.subscription'};
      // const Set<String> _kiOsIds = {'silver_subscription'};
      final ProductDetailsResponse response = await _iap.queryProductDetails(Platform.isAndroid?_kAndroidIds:_kiOsIds);
      setState(() {_products = response.productDetails;});
      if (response.notFoundIDs.isNotEmpty && response.error == null) {print('Products not found: ${response.notFoundIDs}');}
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (var purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        bool valid = await _verifyPurchase(purchase);
        print("valid;-;-;-$valid");
        if (valid) {
          buttonPressed = false;
         selectedIndex == 2 ? subscribeApi(1) : showToastMsg("Coming soon...");
          _deliverProduct(purchase);
        } else {
          _handleInvalidPurchase(purchase);
          return;
        }
      }
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
    setState(() {LoaderOverlay.hide();});
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
    // Verify the purchase here (usually by checking with your server)
    return buttonPressed; // assuming the purchase is valid
  }

  void _deliverProduct(PurchaseDetails purchase) {
    // Deliver the product to the user
    setState(() {_purchases.add(purchase);});
    if(showALert){showDialog(context: context, builder: (BuildContext context) => Successdialog());}
  }

  void _handleInvalidPurchase(PurchaseDetails purchase) {
    if(showALert){ showDialog(context: context, builder: (BuildContext context) => Faildialog());}
    // Handle invalid purchase here
  }

  void buySubscription(ProductDetails product) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);

  }




  Future purchaseSpark(int sparkCount)async{
    const url=ApiList.sparkPurchase;
    print(url);
    var uri=Uri.parse(url);
    var response=await http.post(uri,
        headers: {'Content-Type': 'application/json', "Authorization": "Bearer ${LocaleHandler.accessToken}"},
        body: jsonEncode({"spark_value":sparkCount})
    );
    if(response.statusCode==201){}
    else if(response.statusCode==401){}
    else{}
  }

  Future subscribeApi(int num)async{
    setState(() {LoaderOverlay.show(context);});
    const url=ApiList.subscribe;
    print(url);
    var uri=Uri.parse(url);
    var response=await http.post(uri,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${LocaleHandler.accessToken}'},
        body: jsonEncode({"packageId":num})
    );
    var i =jsonDecode(response.body);
    setState(() {LoaderOverlay.hide();});
    if(response.statusCode==201){
      showALert=true;
      Fluttertoast.showToast(msg: i["message"]);
      purchaseSpark(3);
      // int count=selectedIndex==2?1:selectedIndex==1?3:5;
      // if(count==5){
      //   purchaseSpark(5);
      //   purchaseSpark(5);}
      // else if(count==3){purchaseSpark(5);}
      // else if(count==1){ purchaseSpark(3);}
      // purchaseSpark()
      callFunction();
    }
    else if(response.statusCode==401){showToastMsgTokenExpired();}
    else{Fluttertoast.showToast(msg: i["message"]);}
  }

  Future upgradePlanApi(int num)async{
    setState(() {LoaderOverlay.show(context);});
    const url=ApiList.updateSubscription;
    print(url);
    var uri=Uri.parse(url);
    var response=await http.post(uri,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${LocaleHandler.accessToken}'},
        body: jsonEncode({"packageId":num})
    );
    var i =jsonDecode(response.body);
    setState(() {LoaderOverlay.hide();});
    if(response.statusCode==201){
      Fluttertoast.showToast(msg: i["message"]);
      callFunction();
    }
    else if(response.statusCode==401){showToastMsgTokenExpired();}
    else{Fluttertoast.showToast(msg: i["message"]);}
  }

  Future cancelPlanApi()async{
    setState(() {LoaderOverlay.show(context);});
    const url=ApiList.cancelSubscription;
    print(url);
    var uri=Uri.parse(url);
    var response=await http.post(uri,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${LocaleHandler.accessToken}'},
        body: jsonEncode({"remark":"Remark"})
    );
    var i =jsonDecode(response.body);
    setState(() {LoaderOverlay.hide();});
    if(response.statusCode==201){
      Fluttertoast.showToast(msg: i["message"]);
      callFunction();
    }
    else if(response.statusCode==401){showToastMsgTokenExpired();}
    else{Fluttertoast.showToast(msg: i["message"]);}
  }

  var data;
  String startDates="";
  String endDates="";

  Future subscriptionDetails()async{
    const url=ApiList.subscriptiondetail;
    print(url);
    final uri=Uri.parse(url);
    var response=await http.get(uri,headers: {'Content-Type': 'application/json',
      'Authorization': 'Bearer ${LocaleHandler.accessToken}'});
    var dat =jsonDecode(response.body);
    if(response.statusCode==200){
      if(mounted){
        setState(() {data=dat["data"];
        if(data!=null){
          DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(data["startsAt"] * 1000);
          startDates = DateFormat('MMM dd, yyyy').format(dateTime);
          DateTime dateTime2 = DateTime.fromMillisecondsSinceEpoch(data["endsAt"] * 1000);
          endDates = DateFormat('MMM dd, yyyy').format(dateTime2);
        }});
      }
    }
    else if(response.statusCode==401){showToastMsgTokenExpired();}
    else{}
  }

  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Scaffold(
      appBar: commonBarWithTextleft(context,color.backGroundClr,"Subscription"),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Image.asset(AssetsPics.background,fit: BoxFit.cover,),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  Container(height:defaultTargetPlatform==TargetPlatform.iOS?15: size.height*0.03),
                  Container(
                    // height: 158,
                    decoration: BoxDecoration(color:  color.example3, borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buildText("Your current plan", 18.sp, FontWeight.w600, color.txtBlack),
                              buildText(data==null?"No Plan":capitalize(data["package"]["name"]), 17.sp, FontWeight.w500, color.txtgrey2,fontFamily: FontFamily.hellix),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buildText("Time period", 18.sp, FontWeight.w600, color.txtBlack),
                              buildText("$startDates- $endDates", 16.sp, FontWeight.w500, color.txtgrey2,fontFamily: FontFamily.hellix),
                            ],
                          ),
                          SizedBox(height: size.height*0.02),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // todo unsubscribe and upgrade butttons but api not available yet
                              data==null?const SizedBox():
                              GestureDetector(
                                onTap: (){//setState(() {upgradepressed=false;
                                customDialogBoxWithtwobutton(context, "Are you sure to Unsubscribe?", " ",
                                    img: AssetsPics.cancelticketpng,btnTxt1: "No",btnTxt2: "Yes",
                                    onTap2: (){
                                      cancelPlanApi();
                                    },isPng: true
                                );
                                // cancelPlanApi();
                                // });
                                  },
                                child: Container(
                                  alignment: Alignment.center,
                                  height: size.height*0.055,
                                  width: MediaQuery.of(context).size.width/2-37,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration:upgradepressed?
                                  BoxDecoration(borderRadius: BorderRadius.circular(12),
                                      color: Colors.transparent, border: Border.all(width: 1.5,color: color.txtBlue)
                                  ) : BoxDecoration(borderRadius: BorderRadius.circular(12),
                                      gradient: const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
                                          colors:[color.gradientLightBlue, color.txtBlue])
                                  ),
                                  child: buildText("Unsubscribe",18,FontWeight.w600, upgradepressed? color.txtBlue:color.txtWhite),
                                ),
                              ),
                             /* data==null?const SizedBox(): GestureDetector(onTap: (){setState(() {upgradepressed=true;
                               selectedIndex == 2 ? upgradePlanApi(selectedIndex=2): showToastMsg("Coming soon...");
                                });}, child: Container(
                                  alignment: Alignment.center,
                                  height: size.height*0.055,
                                  width: MediaQuery.of(context).size.width/2-37,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration:upgradepressed? BoxDecoration(borderRadius: BorderRadius.circular(12),
                                      gradient: const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
                                          colors:[color.gradientLightBlue, color.txtBlue])
                                  ):BoxDecoration(borderRadius: BorderRadius.circular(12),
                                      color: Colors.transparent, border: Border.all(width: 1.5,color: color.txtBlue)
                                  ),
                                  child: buildText("Upgrade",18,FontWeight.w600,upgradepressed?color.txtWhite:color.txtBlue),
                                )),*/
                            ],),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            Column(children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.only(left: 15,right: 15,top: 10),
                decoration: BoxDecoration(
                    color: color.txtWhite,
                    borderRadius: BorderRadius.circular(15)
                ),
                child: Column(
                  children: [
                  SizedBox(
                    // height:defaultTargetPlatform==TargetPlatform.iOS? size.height*0.20:size.height*0.21,
                    height:size.height*0.26,
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (val){setState(() {currentIndex=val;});},
                      children: [
                        customScroller(text1: 'See who has Liked you', text2: 'See everyone that likes you', iconName: AssetsPics.like),
                        customScroller(text1: 'Plan Details', text2: '1 month Subscription plan', iconName: AssetsPics.like),
                        customScroller(text1: 'More Sparks', text2: 'Get 3 Sparks now + 1 daily for 1 month.\n Boost your connection!', iconName: AssetsPics.shock),
                        customScroller(text1: 'Unlimited Swipes', text2: 'Endless swiping', iconName: AssetsPics.watch),
                        // customScroller(text1: 'Rules', text2: 'For privacy policy and term & condition please go to setting section', iconName: AssetsPics.watch),
                        cutomTextforPrivacyPolicy(iconName: AssetsPics.watch)
                      ],
                    )
                  ),
                  Container(height: size.height*0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                    List<Widget>.generate( 5, (int index) {
                      return Container(
                        margin: const EdgeInsets.only(left: 2.5,right: 2.5,bottom: 12.0),
                        width: currentIndex == index?14: 12.0,
                        height: currentIndex == index?14: 12.0,
                        decoration: BoxDecoration(
                          color:currentIndex == index? color.txtWhite:Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: currentIndex == index ?
                          Colors.blue : color.txtgrey, width: currentIndex == index ? 3 : 1.5 ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: size.height*0.01),
                  SizedBox(
                    // height: 25.h,
                    height: 18.h,
                    width: MediaQuery.of(context).size.width,
                    // color: Colors.green,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                       /* Row(children: [
                          GestureDetector(
                            onTap: (){setState(() {selectedIndex=1;});},
                            child: Container(
                              height: 164,
                              width: MediaQuery.of(context).size.width/3.3,
                              decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(color: color.example3),
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset( AssetsPics.crownOff,fit: BoxFit.fill,semanticsLabel: "Splash_svg",),
                                  buildText("Slush", 20, FontWeight.w600, color.txtBlack,),
                                  buildText("Gold", 20, FontWeight.w600, color.txtBlack,),
                                  const SizedBox(height: 10,),
                                  buildText("£19.99", 20, FontWeight.w600, color.txtBlack,),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: (){setState(() {selectedIndex=2;});},
                            child: Container(
                              height: 164,
                              width: MediaQuery.of(context).size.width/3.3,
                              decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(color: color.example3),
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset( AssetsPics.crownOff,fit: BoxFit.fill,semanticsLabel: "Splash_svg",),
                                  buildText("Slush", 20, FontWeight.w600, color.txtBlack,),
                                  buildText("Silver", 20, FontWeight.w600, color.txtBlack,),
                                  const SizedBox(height: 10,),
                                  buildText("£9.99", 20, FontWeight.w600, color.txtBlack,),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: (){setState(() {selectedIndex=3;});},
                            child: Container(
                              height: 164,
                              width: MediaQuery.of(context).size.width/3.3,
                              decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(color: color.example3),
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset( AssetsPics.crownOff,fit: BoxFit.fill,semanticsLabel: "Splash_svg",),
                                  buildText("Slush", 20, FontWeight.w600, color.txtBlack,),
                                  buildText("Platinum", 20, FontWeight.w600, color.txtBlack,),
                                  const SizedBox(height: 10,),
                                  buildText("£29.99", 20, FontWeight.w600, color.txtBlack,),
                                ],
                              ),
                            ),
                          ),
                        ],),*/
                        Container(
                          // height: 185 ,
                          height: MediaQuery.of(context).size.width*0.4-28 ,
                          // width: MediaQuery.of(context).size.width/2.9,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(color: color.txtBlue ,
                              border: Border.all(color: color.example3),
                              borderRadius: BorderRadius.circular(12)
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // SvgPicture.asset(AssetsPics.crownOn ,fit: BoxFit.fill,semanticsLabel: "Splash_svg",height: 40),
                              // Spacer(),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // SvgPicture.asset(AssetsPics.crownOn ,fit: BoxFit.fill,semanticsLabel: "Splash_svg",),
                                  buildText(_products.isEmpty?"...":_products[0].title, 15, FontWeight.w600, color.txtWhite ),
                                  // buildText("1 month subscription plan", 25, FontWeight.w600,color.txtWhite ),
                                  buildText(_products.isEmpty?"...":_products[0].description, 15, FontWeight.w600,color.txtWhite ),
                                  const SizedBox(height: 2),
                                  // buildText("£9.99", 25, FontWeight.w600, color.txtWhite ),
                                  buildText(_products.isEmpty?"...":"${_products[0].price}", 18, FontWeight.w600, color.txtWhite ),
                                  // buildText("privacy policy", 25, FontWeight.w600,color.txtWhite ),
                                  Text.rich(textAlign: TextAlign.center,
                                    TextSpan(
                                      children: <TextSpan>[
                                        TextSpan(text: 'Privacy Policy', style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500, color: color.txtWhite,fontFamily:FontFamily.hellix,
                                            decoration: TextDecoration.underline,decorationColor: color.txtWhite,decorationThickness: 1),
                                            recognizer: TapGestureRecognizer()..onTap=() async {
                                              var url = Uri.parse('https://www.slushdating.com/privacy-policy');
                                              if (await canLaunchUrl(url)) {await launchUrl(url, mode: LaunchMode.inAppWebView);}
                                              else {throw 'Could not launch $url';}}),
                                        TextSpan(text: ' and ', style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500, color: color.txtWhite,fontFamily:FontFamily.hellix ),),
                                        TextSpan(text: 'Terms & Conditions', style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500, color:color.txtWhite,fontFamily:FontFamily.hellix,
                                            decoration: TextDecoration.underline,decorationColor: color.txtWhite,decorationThickness: 1),
                                            recognizer: TapGestureRecognizer()..onTap=() async {
                                              var url = Uri.parse('https://www.slushdating.com/terms-of-use');
                                              if (await canLaunchUrl(url)) {await launchUrl(url, mode: LaunchMode.inAppWebView);}
                                              else {throw 'Could not launch $url';}}),
                                      ],
                                    ),
                                  ),

                                ],
                              ),
                              // SvgPicture.asset(AssetsPics.crownOn ,fit: BoxFit.fill,semanticsLabel: "Splash_svg",height: 40),
                            ],
                          ),
                          /*Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(AssetsPics.crownOn ,fit: BoxFit.fill,semanticsLabel: "Splash_svg",),
                                buildText("Slush", 20, FontWeight.w600, color.txtWhite ),
                                buildText("Silver", 20, FontWeight.w600,color.txtWhite ),
                                const SizedBox(height: 10,),
                                buildText("£9.99", 20, FontWeight.w600, color.txtWhite ),
                              ],
                            ),*/
                        )
                       /* Positioned(
                          // bottom: selectedIndex == 2 ? 0 : 8,
                          bottom:Platform.isAndroid ? selectedIndex == 2 ? 0 : 8 :selectedIndex == 2 ? 11 : 22,
                          child: Container(
                            alignment: Alignment.center,
                            height: 22,
                            width: 82,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: selectedIndex == 2 ? color.txtWhite : color.txtBlue
                            ),
                            child: buildText("Popular", 13, FontWeight.w600,selectedIndex == 2 ? color.txtBlue : color.txtWhite,fontFamily: FontFamily.hellix),
                          ),
                        ),*/
                     /*   selectedIndex==1? Positioned(
                          left: 0.0,
                          child: Container(
                            height: 185 ,
                            width: MediaQuery.of(context).size.width/3.1,
                            decoration: BoxDecoration(color: color.txtBlue , border: Border.all(color: color.example3), borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(AssetsPics.crownOn ,fit: BoxFit.fill,semanticsLabel: "Splash_svg",),
                                buildText("Slush", 20, FontWeight.w600, color.txtWhite ),
                                // buildText("Silver", 20, FontWeight.w600,color.txtWhite ),
                                buildText("Gold", 20, FontWeight.w600,color.txtWhite ),
                                const SizedBox(height: 10,),
                                // buildText("£9.99", 20, FontWeight.w600, color.txtWhite ),
                                buildText("£19.99", 20, FontWeight.w600, color.txtWhite ),
                              ],
                            ),
                          ),
                        ):const SizedBox(),
                        selectedIndex==3? Positioned(
                          right: 0.0,
                          child: Container(
                            height: 185 ,
                            width: MediaQuery.of(context).size.width/3.1,
                            decoration: BoxDecoration(color: color.txtBlue ,
                                border: Border.all(color: color.example3),
                                borderRadius: BorderRadius.circular(12)
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(AssetsPics.crownOn ,fit: BoxFit.fill,semanticsLabel: "Splash_svg",),
                                buildText("Slush", 20, FontWeight.w600, color.txtWhite ),
                                buildText("Platinum", 20, FontWeight.w600,color.txtWhite ),
                                const SizedBox(height: 10,),
                                buildText("£29.99", 20, FontWeight.w600, color.txtWhite ),
                              ],
                            ),
                          ),
                        ):const SizedBox(),*/
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  clrchangeBUtton(context,selectedIndex==2? "Continue":"Coming soon",press: (){
                    if(selectedIndex==2  && _products.isNotEmpty){
                    int num=selectedIndex==1?2:selectedIndex==2?0:1;
                    print(LocaleHandler.subscriptionPurchase);
                    if(LocaleHandler.subscriptionPurchase=="no" && selectedIndex == 2){
                      buttonPressed=true;
                      if (Platform.isAndroid) {
                        // _showDialog(context);
                        customDialogBoxx(context);
                        // _buySubscription(_products[2]);
                        buySubscription(_products.first);
                        } else {_showDialog(context);}

                    }else if(selectedIndex != 2){showToastMsg("Coming soon...");}
                    else {showToastMsg("Aready purchased");}
                    }
                  },
                  validation: selectedIndex==2 && _products.isNotEmpty
                  ),
                  SizedBox(height:defaultTargetPlatform==TargetPlatform.iOS?25: 25)
                ],),
              )
            ],)
          ],
        ),
      ),
    );
  }
  customScroller({
    required String text1,
    required String text2,
    required String iconName,
  }){
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          child: selectedIndex== 3 ? Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: SvgPicture.asset(iconName,height:12.h),
              ),
              currentIndex == 3 ? Positioned(
                left: 8,
                bottom: 5,
                child: Container(
                  alignment: Alignment.center,
                  height: 20,
                  width: 98,
                  decoration: BoxDecoration(
                    color: color.orangeColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: buildText("Coming soon", 14, FontWeight.w600, color.txtWhite,fontFamily: FontFamily.hellix),
                ),
              )  : const SizedBox.shrink(),
            ],
          ) : Padding(
            padding: const EdgeInsets.only(left: 16),
            child: SvgPicture.asset(iconName,height:12.h),
          ),
        ),
        buildText(text1, 19.sp, FontWeight.w600, color.txtBlack),
        buildText2(text2, 16.sp, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
        const SizedBox(height: 20)
      ],
    );
  }

  cutomTextforPrivacyPolicy({required String iconName}){
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: SvgPicture.asset(iconName,height:12.h),
        ),
        buildText("Rules", 19.sp, FontWeight.w600, color.txtBlack),
        Text.rich(textAlign: TextAlign.center,
          TextSpan(
            children: <TextSpan>[
              TextSpan(text: 'For ', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: color.txtgrey,fontFamily:FontFamily.hellix ),),
              TextSpan(text: 'privacy policy', style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500, color: color.txtBlue,fontFamily:FontFamily.hellix,
                  decoration: TextDecoration.underline,decorationColor: Colors.blue,decorationThickness: 1),
              recognizer: TapGestureRecognizer()..onTap=() async {
                var url = Uri.parse('https://www.slushdating.com/privacy-policy');
                if (await canLaunchUrl(url)) {await launchUrl(url, mode: LaunchMode.inAppWebView);}
                else {throw 'Could not launch $url';}}),
              TextSpan(text: ' and ', style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500, color: color.txtgrey,fontFamily:FontFamily.hellix ),),
              TextSpan(text: 'term & condition', style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500, color: color.txtBlue,fontFamily:FontFamily.hellix,
                  decoration: TextDecoration.underline,decorationColor: Colors.blue,decorationThickness: 1),
                  recognizer: TapGestureRecognizer()..onTap=() async {
                    var url = Uri.parse('https://www.slushdating.com/terms-of-use');
                    if (await canLaunchUrl(url)) {await launchUrl(url, mode: LaunchMode.inAppWebView);}
                    else {throw 'Could not launch $url';}}),
              // TextSpan(text: 'please go to setting section', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: color.txtgrey,fontFamily:FontFamily.hellix ),),
            ],
          ),
        ),
        // buildText2("For privacy policy and term & condition please go to setting section", 16.sp, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
      ],
    );
  }



  void callFunction(){
    setState(() {
      LocaleHandler.subscriptionPurchase="no";
      LocaleHandler.isThereAnyEvent=false;
      LocaleHandler.isThereCancelEvent=false;
      LocaleHandler.unMatchedEvent=false;
      LocaleHandler.subScribtioonOffer=false;
      Get.to(()=>BottomNavigationScreen());
    });
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: buildText("Payment will be charged to iTunes Account at confirmation of purchase. Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period. Account will be charged for renewal within 24-hours prior to the end of the current period, and identify the cost of the renewal. Subscriptions may be managed by the user and auto-renewal may be turned off by going to the user's Account Settings after purchase. No cancellation of the current subscription is allowed during active subscription period. Any unused portion of a free trial period, if offered will be forfeited when the user purchases a subscription to that publication, where applicable.", 16, FontWeight.w500, Colors.black),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              GestureDetector(
                  onTap: () async {
                    var url = Uri.parse('https://www.slushdating.com/terms-of-use');
                    if (await canLaunchUrl(url)) {await launchUrl(url, mode: LaunchMode.inAppWebView);}
                    else {throw 'Could not launch $url';}
                  }
                  ,child: buildText("Term of service   ", 15, FontWeight.w500, Colors.black54)),
              buildText("|", 15, FontWeight.w500, Colors.black54),
              GestureDetector(onTap: () async {
                var url = Uri.parse('https://www.slushdating.com/privacy-policy');
                if (await canLaunchUrl(url)) {await launchUrl(url, mode: LaunchMode.inAppWebView);}
                else {throw 'Could not launch $url';}
              },child: buildText("   Privacy policy", 15, FontWeight.w500, Colors.black54)),
            ],),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: (){
                    Get.back();
                  }, child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(color: color.logOutRed,
                    borderRadius: BorderRadius.circular(10)),
                      child: buildText("Cancel", 15, FontWeight.w500, Colors.white)),
                ),
                GestureDetector(
                  onTap: (){
                    Get.back();
                    customDialogBoxx(context);
                    buySubscription(_products.first);
                  },
                  child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(color: color.txtBlue,
                          borderRadius: BorderRadius.circular(10)),
                      child: buildText("    Pay    ", 15, FontWeight.w500, Colors.white)),
                ),
              ],),
          ],
        );
      },
    );
  }
}


class ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5, // Adjust the count based on your needs
        itemBuilder: (context, index) {
          return ListTile(
            title: Container(
              height: 20,
              width: 200,
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }
}

String capitalize(String input) {
  if (input == null || input.isEmpty) {
    return '';
  }

  return input.split(' ').map((word) {
    if (word.isNotEmpty) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }
    return '';
  }).join(' ');
}

customDialogBoxx(BuildContext context) {
  return showGeneralDialog(
      barrierLabel: "Label",
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 500),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return LoadingDialog();
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height/2.5,
                width: MediaQuery.of(context).size.width ,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: color.txtWhite,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      height: 80,
                      width: 80
                    ),
                    SizedBox(height: 1.h),
                    const SizedBox(height: 15),
                  ],
                )),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(anim1),
          child: child,
        );
      });
}

class LoadingDialog extends StatefulWidget {
  @override
  _LoadingDialogState createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate a network request or loading process
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        isLoading = false; // Stop loading
      });

      // Close the dialog after loading is complete
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
            height: MediaQuery.of(context).size.height/2.5,
            width: MediaQuery.of(context).size.width ,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: color.txtWhite,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (isLoading) const CircularProgressIndicator(),
                if (!isLoading) const Icon(Icons.check, color: Colors.green),
                const SizedBox(width: 20),
                Text(isLoading ? 'Please wait...' : 'Loading complete!'),
                Container(
                    alignment: Alignment.center,
                    height: 80,
                    width: 80
                ),
                SizedBox(height: 1.h),
                const SizedBox(height: 15),
              ],
            )),
      ),
    );
    return AlertDialog(
      title: const Text('Loading'),
      content: Row(
        children: [
          if (isLoading) const CircularProgressIndicator(),
          if (!isLoading) const Icon(Icons.check, color: Colors.green),
          const SizedBox(width: 20),
          Text(isLoading ? 'Please wait...' : 'Loading complete!'),
        ],
      ),
    );
  }
}

