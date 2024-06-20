import 'dart:math';

import 'package:slush/constants/LocalHandler.dart';

// double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
// double calculateDistance(double lat2, double lon2) {
//   double lat1=double.parse(LocaleHandler.latitude);
//   double lon1=double.parse(LocaleHandler.longitude);
//   final R = 6371e3; // meters (Earth's radius)
//   var dLat = radians(lat2 - lat1);
//   var dLon = radians(lon2 - lon1);
//   var a = sin(dLat / 2) * sin(dLat / 2) + cos(radians(lat1)) * cos(radians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
//   var c = 2 * atan2(sqrt(a), sqrt(1 - a));
//   var distance = R * c;
//   return distance;
// }
//
// double radians(double degrees) {
//   return degrees * pi / 180;
// }

double distance(double lat2, double lon2) {
  double lat1=double.parse(LocaleHandler.latitude);
  double lon1=double.parse(LocaleHandler.longitude);
  // double lat1=30.7046;
  // double lon1=76.7179;
  const r = 6372.8; // Earth radius in kilometers

  final dLat = _toRadians(lat2 - lat1);
  final dLon = _toRadians(lon2 - lon1);
  final lat1Radians = _toRadians(lat1);
  final lat2Radians = _toRadians(lat2);

  final a = _haversin(dLat) + cos(lat1Radians) * cos(lat2Radians) * _haversin(dLon);
  final c = 2 * asin(sqrt(a));

  return r * c;
}

double _toRadians(double degrees) => degrees * pi / 180;

num _haversin(double radians) => pow(sin(radians / 2), 2);