import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:slush/widgets/toaster.dart';

class CustomCircularPercentIndicator extends StatefulWidget {
  @override
  _CustomCircularPercentIndicatorState createState() =>
      _CustomCircularPercentIndicatorState();
}

class _CustomCircularPercentIndicatorState
    extends State<CustomCircularPercentIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final int startingMinutes = 15;
  final int initialMinutes = 1;
  double initialPercent = 0.0;




  // IN APP
  InAppPurchase _inAppPurchase=InAppPurchase.instance;
  late StreamSubscription<dynamic> _streamsubcription;
  List<ProductDetails> _products=[];
   static const _varient={"1","2"};


  @override
  void initState() {
    super.initState();
    // initialPercent = initialMinutes / startingMinutes.toDouble();
    // _animationController = AnimationController(
    //   vsync: this,
    //   duration: const Duration(seconds: 30), // Adjust the duration as needed
    // );
    // _animation = Tween<double>(begin: initialPercent, end: 1.0).animate(_animationController);
    // _animationController.forward();




    //
    Stream purchaseUPdated=InAppPurchase.instance.purchaseStream;
    _streamsubcription = purchaseUPdated.listen((purchaselist) {
      _listentoPurchase(purchaselist);
    },onDone: (){
      _streamsubcription.cancel();
    },onError: (error){showToastMsg(error);},);
    initStore();

  }

  _listentoPurchase(List<PurchaseDetails> purchaseetailList){
    purchaseetailList.forEach((PurchaseDetails purchaseDetails)async {
      if(purchaseDetails.status == PurchaseStatus.pending){showToastMsg("Pending");}
      else {
        if(purchaseDetails.status == PurchaseStatus.error){showToastMsg("Error");}
        else if(purchaseDetails.status == PurchaseStatus.purchased){showToastMsg("Purchase");}
      }
    });
  }

  initStore()async{
    ProductDetailsResponse productDetailsResponse = await _inAppPurchase.queryProductDetails(_varient);
    if(productDetailsResponse.error==null){
      _products =productDetailsResponse.productDetails;
    }
  }

  _buy(){
    final PurchaseParam param= PurchaseParam(productDetails: _products[0]);
    _inAppPurchase.buyConsumable(purchaseParam: param);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Circular Percent Indicator'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(onPressed: (){_buy();}, child: Text("pay"))
          /*  AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CircularPercentIndicator(
                  radius: 120.0,
                  lineWidth: 10.0,
                  percent: _animation.value,
                  center: Text("${(_animation.value * startingMinutes).toStringAsFixed(0)} min",
                    style: const TextStyle(fontSize: 20.0),
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: Colors.blue,
                );
              },
            ),*/
          ],
        ),
      ),
    );
  }
}

class InAppPurchaseUtils extends GetxController {
  // Private constructor
  InAppPurchaseUtils._();

  // Singleton instance
  static final InAppPurchaseUtils _instance = InAppPurchaseUtils._();

  // Getter to access the instance
  static InAppPurchaseUtils get inAppPurchaseUtilsInstance => _instance;

  // Create a private variable
  final InAppPurchase _iap = InAppPurchase.instance;

  // Add your methods related to in-app purchases here

  // Example method
  void purchaseProduct(String productId) {
    // Implementation for purchasing a product
  }
}