import 'dart:io';

import 'package:in_app_purchase/in_app_purchase.dart';

class IAPurchases {
  final InAppPurchase _iap = InAppPurchase.instance;
  bool _available = true;

  Future<List<ProductDetails>> initialize() async {
    final bool isAvailable = await _iap.isAvailable();
    _available = isAvailable;
    if (_available) {
      // const Set<String> _kIds = {'silversubscription','goldsubscription','platinumsubscription'};
      const Set<String> _kAndroidIds = {'silversubscription'};
      // const Set<String> _kiOsIds = {'Tier1'};
      const Set<String> _kiOsIds = {'com.slush.silver.subscription'};
      final ProductDetailsResponse response = await _iap
          .queryProductDetails(Platform.isAndroid ? _kAndroidIds : _kiOsIds);
      if (response.notFoundIDs.isNotEmpty && response.error == null) {
        print('Products not found: ${response.notFoundIDs}');
        return [];
      } else {
        return response.productDetails;
      }
    }
    return [];
  }

}
