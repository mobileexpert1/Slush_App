import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
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
import 'package:slush/controller/profile_controller.dart';
import 'package:slush/screens/events/bottomNavigation.dart';
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

  final InAppPurchase _iap = InAppPurchase.instance;
  bool _available = true;
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  @override
  void initState() {
    subscriptionDetails();
    _pageController.addListener(() {
      setState(() {
        currentIndex = _pageController.page!.round();
      });
    });
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
    setState(() {
      _available = isAvailable;
    });

    if (_available) {
      const Set<String> _kIds = {'silversubscription','goldsubscription','platinumsubscription'};
      final ProductDetailsResponse response = await _iap.queryProductDetails(_kIds);
      setState(() {
        _products = response.productDetails;
      });
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (var purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        // Verify purchase here and deliver the product
        bool valid = await _verifyPurchase(purchase);
        if (valid) {
         selectedIndex == 1 ? subscribeApi(selectedIndex = 1) : showToastMsg("Coming soon...");
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
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
    // Verify the purchase here (usually by checking with your server)
    return true; // assuming the purchase is valid
  }

  void _deliverProduct(PurchaseDetails purchase) {
    // Deliver the product to the user
    setState(() {
      _purchases.add(purchase);
    });
  }

  void _handleInvalidPurchase(PurchaseDetails purchase) {
    // Handle invalid purchase here
  }

  void _buySubscription(ProductDetails product) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future purchaseSpark(int sparkCount)async{
    const url=ApiList.sparkPurchase;
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
    var uri=Uri.parse(url);
    var response=await http.post(uri,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${LocaleHandler.accessToken}'},
        body: jsonEncode({"packageId":num})
    );
    var i =jsonDecode(response.body);
    setState(() {LoaderOverlay.hide();});
    if(response.statusCode==201){
      Fluttertoast.showToast(msg: i["message"]);
      int count=selectedIndex==1?1:selectedIndex==2?3:5;
      if(count==5){purchaseSpark(5);
        purchaseSpark(5);}
      else if(count==3){purchaseSpark(5);}
      else if(count==1){ purchaseSpark(3);}
      // purchaseSpark()
      callFunction();
    }
    else if(response.statusCode==401){showToastMsgTokenExpired();}
    else{Fluttertoast.showToast(msg: i["message"]);}
  }

  Future upgradePlanApi(int num)async{
    setState(() {LoaderOverlay.show(context);});
    const url=ApiList.updateSubscription;
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
    if(response.statusCode==200){setState(() {data=dat["data"];
    if(data!=null){
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(data["startsAt"] * 1000);
      startDates = DateFormat('MMM dd, yyyy').format(dateTime);
      DateTime dateTime2 = DateTime.fromMillisecondsSinceEpoch(data["endsAt"] * 1000);
      endDates = DateFormat('MMM dd, yyyy').format(dateTime2);
    }});}
    else if(response.statusCode==401){showToastMsgTokenExpired();}
    else{}
  }

  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Scaffold(
      // backgroundColor: color.backGroundClr,
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
                                onTap: (){setState(() {upgradepressed=false;
                                customDialogBoxWithtwobutton(context, "Are you sure to Unsubscribe?", " ",
                                    img: AssetsPics.cancelticketpng,btnTxt1: "No",btnTxt2: "Yes",
                                    onTap2: (){
                                      cancelPlanApi();
                                    },isPng: true
                                );
                                // cancelPlanApi();
                                });},
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
                                  // child: buildText(LocaleHandler.subscriptionPurchase=="yes"?"Unsubscribe":"Subscribe",18,FontWeight.w600, upgradepressed? color.txtBlue:color.txtWhite),
                                  child: buildText("Unsubscribe",18,FontWeight.w600, upgradepressed? color.txtBlue:color.txtWhite),
                                ),
                              ),
                              data==null?const SizedBox(): GestureDetector(
                                onTap: (){setState(() {upgradepressed=true;
                               selectedIndex == 1 ? upgradePlanApi(selectedIndex=1): showToastMsg("Coming soon...");
                                });
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  height: size.height*0.055,
                                  width: MediaQuery.of(context).size.width/2-37,
                                  //width: MediaQuery.of(context).size.width/2-45,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration:upgradepressed? BoxDecoration(borderRadius: BorderRadius.circular(12),
                                      gradient: const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
                                          colors:[color.gradientLightBlue, color.txtBlue])
                                  ):BoxDecoration(borderRadius: BorderRadius.circular(12),
                                      color: Colors.transparent, border: Border.all(width: 1.5,color: color.txtBlue)
                                  ),
                                  child: buildText("Upgrade",18,FontWeight.w600,upgradepressed?color.txtWhite:color.txtBlue),
                                ),
                              ),
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
                child: Column(children: [
                  SizedBox(
                    height:defaultTargetPlatform==TargetPlatform.iOS? size.height*0.20:size.height*0.19,
                    child:
                    selectedIndex ==1 ?
                    PageView(
                      controller: _pageController,
                      children: [
                        customScroller(text1: 'See who has Liked you', text2: 'See everyone that likes you', iconName: AssetsPics.like),
                        customScroller(text1: 'Sparks', text2: '3 sparks a day', iconName: AssetsPics.shock),
                        customScroller(text1: 'Unlimited Swipes', text2: 'Endless swiping', iconName: AssetsPics.watch),
                      ],
                    ) : selectedIndex ==2 ?  PageView(
                      controller: _pageController,
                      children: [
                        customScroller(text1: 'See who has Liked you', text2: 'See everyone that likes you', iconName: AssetsPics.like),
                        customScroller(text1: 'Sparks', text2: '5 sparks a day', iconName: AssetsPics.shock),
                        customScroller(text1: 'Unlimited Swipes', text2:  'Endless swiping', iconName: AssetsPics.watch),
                        customScroller(text1: 'AI Dating Coach', text2: 'Your dating coach', iconName: AssetsPics.dating),
                        customScroller(text1: 'No ads', text2: 'Your dating coach', iconName: AssetsPics.noAds),
                      ],
                    ) : PageView(
                      controller: _pageController,
                      children: [
                        customScroller(text1: 'See who has Liked you', text2: 'See everyone that likes you', iconName: AssetsPics.like),
                        customScroller(text1: 'Sparks', text2: '10 sparks a day', iconName: AssetsPics.shock),
                        customScroller(text1: 'Unlimited Swipes', text2:  'Endless swiping', iconName: AssetsPics.watch),
                        customScroller(text1: 'AI Dating Coach', text2: 'Your dating coach', iconName: AssetsPics.dating),
                        customScroller(text1: 'No ads', text2: 'Your dating coach', iconName: AssetsPics.noAds),
                      ],
                    ),
                  ),
                  Container(height: size.height*0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                    List<Widget>.generate( selectedIndex == 1 ? 3 : 5, (int index) {
                      return Container(
                        margin: const EdgeInsets.only(left: 2.5,right: 2.5,bottom: 12.0),
                        width: currentIndex == index?14: 12.0,
                        height: currentIndex == index?14: 12.0,
                        decoration: BoxDecoration(
                          color:currentIndex == index? color.txtWhite:Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: currentIndex == index ?
                          Colors.blue : color.txtgrey, width: currentIndex == index ? 3 : 1.5 ,),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: size.height*0.01),
                  SizedBox(
                    height: 25.h,
                    width: MediaQuery.of(context).size.width,
                    // color: Colors.green,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(children: [
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
                                  buildText("Silver", 20, FontWeight.w600, color.txtBlack,),
                                  const SizedBox(height: 10,),
                                  buildText("£9.99", 20, FontWeight.w600, color.txtBlack,),
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
                                  buildText("Gold", 20, FontWeight.w600, color.txtBlack,),
                                  const SizedBox(height: 10,),
                                  buildText("£19.99", 20, FontWeight.w600, color.txtBlack,),
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
                        ],),
                        selectedIndex==2? GestureDetector(
                          onTap: () {
                            setState(() {});
                            selectedIndex = 2 ;
                          },
                          child: Container(
                            height: 185 ,
                            // width: MediaQuery.of(context).size.width/3.5,
                            width: MediaQuery.of(context).size.width/2.9,
                            decoration: BoxDecoration(color: color.txtBlue ,
                                border: Border.all(color: color.example3),
                                borderRadius: BorderRadius.circular(12)
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(AssetsPics.crownOn ,fit: BoxFit.fill,semanticsLabel: "Splash_svg",),
                                buildText("Slush", 20, FontWeight.w600, color.txtWhite ),
                                buildText("Gold", 20, FontWeight.w600,color.txtWhite ),
                                const SizedBox(height: 10,),
                                buildText("£19.99", 20, FontWeight.w600, color.txtWhite ),
                              ],
                            ),
                          ),
                        ):const SizedBox(),
                        Positioned(
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
                        ),
                        selectedIndex==1? Positioned(
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
                                buildText("Silver", 20, FontWeight.w600,color.txtWhite ),
                                const SizedBox(height: 10,),
                                buildText("£9.99", 20, FontWeight.w600, color.txtWhite ),
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
                        ):const SizedBox(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  blue_button(context, "Continue",press: (){
                    selectedIndex == 1 ? subscribeApi(selectedIndex = 1) : showToastMsg("Coming soon...");

                    // subscribeApi(selectedIndex);
                    int num=selectedIndex==1?2:selectedIndex==2?0:1;
                    if(LocaleHandler.subscriptionPurchase!="yes"){

                      // if(Platform.isAndroid){_buySubscription(_products[num]);}
                      // else{subscribeApi(selectedIndex);}
                    }
                    else{Fluttertoast.showToast(msg: "Already purchased a subscription");}
                    // callFunction();
                  }),
                  SizedBox(height:defaultTargetPlatform==TargetPlatform.iOS?25: 10)
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
        buildText(text2, 16.sp, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
      ],
    );
  }

  void callFunction(){
    setState(() {
      LocaleHandler.isThereAnyEvent=false;
      LocaleHandler.isThereCancelEvent=false;
      LocaleHandler.unMatchedEvent=false;
      LocaleHandler.subScribtioonOffer=false;
      Get.to(()=>BottomNavigationScreen());
    });
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