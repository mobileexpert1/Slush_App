
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/loader.dart';
import 'package:slush/controller/profile_controller.dart';
import 'package:slush/screens/subscritption/subscription_screen1%203.dart';
import 'package:slush/widgets/alert_dialog.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:http/http.dart'as http;
import 'package:slush/widgets/toaster.dart';

class SparkPurchaseScreen extends StatefulWidget {
  const SparkPurchaseScreen({Key? key}) : super(key: key);

  @override
  State<SparkPurchaseScreen> createState() => _SparkPurchaseScreenState();
}

class _SparkPurchaseScreenState extends State<SparkPurchaseScreen> {
  int selectedIndex=2;
  String selectedIndexx=Platform.isAndroid?"3spark":"three_spark";
  String sparktext="Get 3 Sparks for ...";
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  bool _available = true;
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  bool buttonPressed=false;

  Future purchaseSpark(int sparkCount)async{
    setState(() {LoaderOverlay.show(context);});
    const url=ApiList.sparkPurchase;
    var uri=Uri.parse(url);
    var response=await http.post(uri,
        headers: {'Content-Type': 'application/json', "Authorization": "Bearer ${LocaleHandler.accessToken}"},
        body: jsonEncode({"spark_value":sparkCount}));
    setState(() {LoaderOverlay.hide();});
    if(response.statusCode==201){
      Provider.of<profileController>(context,listen: false).getTotalSparks();
    }
    else if(response.statusCode==401){showToastMsgTokenExpired();}
    else {}
  }

  @override
  void initState() {
    final Stream purchaseUpdated = _inAppPurchase.purchaseStream;
    purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    });
    _initialize();
    super.initState();
  }

  Future<void> _initialize() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (available) {
      const Set<String> _kAndroidIds = {'1spark','3spark','5spark'};
      // const Set<String> _kiOSIds = {'1_spark','3_spark','5_spark'};
      const Set<String> _kiOSIds = {'one_spark','three_spark','five_spark'};
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(Platform.isAndroid?_kAndroidIds: _kiOSIds);
      setState(() {
        _available = available;
        _products = response.productDetails;
      });
      if (response.notFoundIDs.isNotEmpty && response.error == null){
        showToastMsg("Please wait...");
      }
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Handle pending purchase
      } else if (purchaseDetails.status == PurchaseStatus.purchased) {
        // Verify the purchase
        bool valid = await _verifyPurchase(purchaseDetails);
        if (valid) {
          buttonPressed=false;
          _deliverProduct(purchaseDetails);
          int count=selectedIndex==1?1:selectedIndex==2?3:5;
          purchaseSpark(count);
        }
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        // showToastMsg("Server error! please try again after few minutes");
        showDialog(context: context, builder: (BuildContext context) => Faildialog());
        // Handle error
      }
      if (purchaseDetails.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchaseDetails);
      }
    });
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // Verify purchase with your server
    return buttonPressed; // Assuming purchase verification is successful
  }

  void _deliverProduct(PurchaseDetails purchaseDetails) {
    setState(() {_purchases.add(purchaseDetails);});
    showDialog(context: context, builder: (BuildContext context) => Successdialog());
  }


  void _buyProduct(ProductDetails product) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: size.height,width: size.width,
            child: Image.asset(AssetsPics.bluebg,fit: BoxFit.cover,),),
          SafeArea(child: Padding(
            padding: const EdgeInsets.only(left: 16,right: 16,top: 20,bottom: 18),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: (){Get.back();},
                    child: Container(
                      height: 26,width: 26,
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(shape: BoxShape.circle,color: Colors.white,
                          boxShadow:[
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 20.0,
                                offset: Offset(0.0,10.0)
                            )
                          ]
                      ),
                      child: const Icon(Icons.clear,color: color.txtBlue,size: 20),
                    ),
                  )
                ],),
              const SizedBox(height: 25),
              SvgPicture.asset(AssetsPics.sparkWhiteCirlce),
              buildText("Purchase Sparks", 28, FontWeight.w600, color.txtWhite),
              buildText("Get Noticed and Stand Out!", 25, FontWeight.w400, color.txtWhite),
              SizedBox(height: 4.h),
              subScriptionOption(context),
              const Spacer(),
              _products.isEmpty?const SizedBox(): white_button(context, sparktext,press: () async {
                if(_products.isNotEmpty){
                  buttonPressed=true;
                  int index = _products.indexWhere((item) => item.id == selectedIndexx);
                  if(Platform.isAndroid){
                    final PurchaseParam purchaseParam = PurchaseParam(productDetails: _products[index]);
                    await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
                  }else{
                    customDialogBoxx(context);
                    // setState(() {LoaderOverlay.show(context);});
                    // int val=selectedIndex==1?1:selectedIndex==2?2:0;
                    final PurchaseParam purchaseParam = PurchaseParam(productDetails: _products[index]);
                    await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
                  }}
                else{showToastMsg("please wait items are loading");}

              })
            ],),
          ))
        ],
      ),
    );
  }

  String tapped="";
  Widget subScriptionOption(BuildContext context) {
    int sprk1 = _products.indexWhere((item) => item.id == (Platform.isAndroid?"1spark":"one_spark"));
    int sprk2 = _products.indexWhere((item) => item.id == (Platform.isAndroid?"3spark":"three_spark"));
    int sprk3 = _products.indexWhere((item) => item.id == (Platform.isAndroid?"5spark":"five_spark"));
    if(tapped==""){sparktext="Get 3 Sparks for ${_products.isEmpty?"...":_products[sprk2].price}";}
    return SizedBox(
      height: 25.h+2,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(children: [
            GestureDetector(
              onTap: (){
                setState(() {selectedIndex=1;
                selectedIndexx=Platform.isAndroid?"1spark":"one_spark";
                sparktext="Get 1 Sparks for ${_products.isEmpty?"...":_products[sprk1].price}";
                tapped=sparktext;
                });},
              child: buildContainer(context, _products.isEmpty?"...":_products[sprk1].title, _products.isEmpty?"...":_products[sprk1].price),
            ),
            GestureDetector(
              onTap: (){setState(() {selectedIndex=2;
              selectedIndexx=Platform.isAndroid?"3spark":"three_spark";
              sparktext="Get 3 Sparks for ${_products.isEmpty?"...":_products[sprk2].price}";
              tapped=sparktext;
              });},
              child: buildContainer(context,_products.isEmpty?"...":_products[sprk2].title, _products.isEmpty?"...":_products[sprk2].price),
            ),
            GestureDetector(
              onTap: (){setState(() {selectedIndex=3;
              selectedIndexx=Platform.isAndroid?"5spark":"five_spark";
              sparktext="Get 5 Sparks for ${_products.isEmpty?"...":_products[sprk3].price}";
              tapped=sparktext;
              });},
              child: buildContainer(context, _products.isEmpty?"...":_products[sprk3].title, _products.isEmpty?"...":_products[sprk3].price),
            ),
          ],),
          selectedIndex==2? GestureDetector(
            onTap: () {
              setState(() {});
              selectedIndex = 2 ;
              selectedIndexx=Platform.isAndroid?"3spark":"three_spark";
            },
            child: Container(
              height: 185 ,
              // width: MediaQuery.of(context).size.width/3.5,
              width: MediaQuery.of(context).size.width/2.9,
              decoration: BoxDecoration(color: color.txtBlue ,
                  borderRadius: BorderRadius.circular(12)
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(AssetsPics.whiteSpark ,fit: BoxFit.fill,semanticsLabel: "Splash_svg",),
                  const SizedBox(height: 5),
                  // buildText("3", 20, FontWeight.w600, color.txtWhite ),
                  // buildText("Spark", 20, FontWeight.w600,color.txtWhite ),
                  buildText2(_products.isEmpty?"...":_products[sprk2].title, 15, FontWeight.w600,color.txtWhite ),
                  const SizedBox(height: 7),
                  buildText(_products.isEmpty?"...":_products[sprk2].price, 20, FontWeight.w600, color.txtWhite ),
                ],
              ),
            ),
          ):const SizedBox(),
          Positioned(
            bottom: selectedIndex == 2 ? 0 : 8,
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
              decoration: BoxDecoration(color: color.txtBlue , borderRadius: BorderRadius.circular(12)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(AssetsPics.whiteSpark ,fit: BoxFit.fill,semanticsLabel: "Splash_svg"),
                  const SizedBox(height: 5),
                  buildText2(_products.isEmpty?"...":_products[sprk1].title, 15, FontWeight.w600,color.txtWhite ),
                  // buildText("1", 20, FontWeight.w600, color.txtWhite ),
                  // buildText("Spark", 20, FontWeight.w600,color.txtWhite ),
                  const SizedBox(height: 7),
                  buildText(_products.isEmpty?"...":_products[sprk1].price, 20, FontWeight.w600, color.txtWhite ),
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
                  borderRadius: BorderRadius.circular(12)
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(AssetsPics.whiteSpark ,fit: BoxFit.fill,semanticsLabel: "Splash_svg"),
                  const SizedBox(height: 5),
                  // buildText("5", 20, FontWeight.w600, color.txtWhite ),
                  // buildText("Spark", 20, FontWeight.w600,color.txtWhite ),
                  buildText2(_products.isEmpty?"...":_products[sprk3].title, 15, FontWeight.w600,color.txtWhite ),
                  const SizedBox(height: 7),
                  buildText(_products.isEmpty?"...":_products[sprk3].price, 20, FontWeight.w600, color.txtWhite ),
                ],
              ),
            ),
          ):const SizedBox(),
        ],
      ),
    );
  }

  Widget buildContainer(BuildContext context,String count,String price) {
    return Container(
      height: 164,
      width: MediaQuery.of(context).size.width/3.3,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset( AssetsPics.greySpark,fit: BoxFit.fill,semanticsLabel: "Splash_svg"),
          const SizedBox(height: 5),
          // buildText(count, 20, FontWeight.w600, color.txtBlack),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: buildText2(count, 14, FontWeight.w600, color.txtBlack),
          ),
          // buildText("Spark", 20, FontWeight.w600, color.txtBlack,),
          const SizedBox(height: 7),
          buildText(price, 20, FontWeight.w600, color.txtBlack,),
        ],
      ),
    );
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
}