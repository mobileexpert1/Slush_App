import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
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

class RestoreSubscripton extends StatefulWidget {
  const RestoreSubscripton({super.key});

  @override
  State<RestoreSubscripton> createState() => _RestoreSubscriptonState();
}

class _RestoreSubscriptonState extends State<RestoreSubscripton> {
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
      const Set<String> _kIds = {'silversubscription'};
      final ProductDetailsResponse response = await _iap.queryProductDetails(_kIds);
      setState(() {_products = response.productDetails;});
      if (response.notFoundIDs.isNotEmpty && response.error == null) {
        print('Products not found: ${response.notFoundIDs}');
      }
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
    return buttonPressed; // assuming the purchase is valid
  }

  void _deliverProduct(PurchaseDetails purchase) {
    setState(() {_purchases.add(purchase);});
    if(showALert){showDialog(context: context, builder: (BuildContext context) => Successdialog());}
  }

  void _handleInvalidPurchase(PurchaseDetails purchase) {
    if(showALert){ showDialog(context: context, builder: (BuildContext context) => Faildialog());}
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
      appBar: commonBarWithTextleft(context,color.backGroundClr,"Restore Subscription"),
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
                              buildText("Your Restore plan", 18.sp, FontWeight.w600, color.txtBlack),
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
                      height:defaultTargetPlatform==TargetPlatform.iOS? size.height*0.20:size.height*0.21,
                      child:
                      PageView(
                        controller: _pageController,
                        onPageChanged: (val){
                          setState(() {currentIndex=val;});
                        },
                        children: [
                          customScroller(text1: 'See who has Liked you', text2: 'See everyone that likes you', iconName: AssetsPics.like),
                          customScroller(text1: 'Plan Details', text2: '30 days Subscription plan', iconName: AssetsPics.like),
                          customScroller(text1: 'More Sparks', text2: 'Get 3 Sparks now + 1 daily for 30 days.\n Boost your connection!', iconName: AssetsPics.shock),
                          customScroller(text1: 'Unlimited Swipes', text2: 'Endless swiping', iconName: AssetsPics.watch),
                        ],
                      )
                  ),
                  Container(height: size.height*0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                    List<Widget>.generate( 4, (int index) {
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
                        selectedIndex==2? GestureDetector(
                            onTap: () {
                              selectedIndex = 2 ;
                            },
                            child: Container(
                              height: 185 ,
                              // width: MediaQuery.of(context).size.width/2.9,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(color: color.txtBlue ,
                                  border: Border.all(color: color.example3),
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  SvgPicture.asset(AssetsPics.crownOn ,fit: BoxFit.fill,semanticsLabel: "Splash_svg",height: 50),
                                  // Spacer(),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // SvgPicture.asset(AssetsPics.crownOn ,fit: BoxFit.fill,semanticsLabel: "Splash_svg",),
                                      buildText("Slush", 30, FontWeight.w600, color.txtWhite ),
                                      buildText("Silver", 30, FontWeight.w600,color.txtWhite ),
                                      const SizedBox(height: 10,),
                                      buildText("£9.99", 30, FontWeight.w600, color.txtWhite ),
                                    ],
                                  ),
                                  SvgPicture.asset(AssetsPics.crownOn ,fit: BoxFit.fill,semanticsLabel: "Splash_svg",height: 50),
                                ],
                              ),
                            ) ):const SizedBox(),
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
                                buildText("Gold", 20, FontWeight.w600,color.txtWhite ),
                                const SizedBox(height: 10,),
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
                        ):const SizedBox(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  clrchangeBUtton(context,selectedIndex==2? "Restore":"Coming soon",press: (){
                    if(selectedIndex==2){
                      if(LocaleHandler.subscriptionPurchase=="no" && selectedIndex == 2){
                        buttonPressed=true;
                        if (Platform.isAndroid) {
                          customDialogBoxx(context);
                          // _buySubscription(_products[2]);
                          buySubscription(_products[0]);
                        } else {
                          // setState(() {LoaderOverlay.show(context);});
                          customDialogBoxx(context);
                          buySubscription(_products[0]);
                        }
                      }else if(selectedIndex != 2){showToastMsg("Coming soon...");}}
                  },
                      validation: selectedIndex==2
                  ),
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
        buildText2(text2, 16.sp, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
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
  }
}
