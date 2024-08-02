import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/widgets/app_bar.dart';
import 'package:slush/widgets/text_widget.dart';

class DeviceManagement extends StatefulWidget {
  const DeviceManagement({super.key});

  @override
  State<DeviceManagement> createState() => _DeviceManagementState();
}

class _DeviceManagementState extends State<DeviceManagement> {
  List<Devices> devices = [
    Devices(
      Id: 1,
      title: 'iPhone XR',
      subTitle1: 'iOS version :11',
      subTitle2: 'Logged in on Sunday, 25 April 2020  |  7:00 AM',),
    Devices(
      Id: 2,
      title: 'OnePlus 6t',
      subTitle1: 'Android : 10 | App Version : 2.69.01',
      subTitle2: 'Logged in on Wednesday, 11 Feb 2022 |  08:00pm',),
    Devices(
      Id: 3,
      title: 'OnePlus 8t',
      subTitle1: 'Android : 10 | App Version : 2.69.01',
      subTitle2: 'Logged in on Sunday, 25 April 2020  |  7:00 AM',),
    Devices(
      Id: 3,
      title: 'OnePlus 8t',
      subTitle1: 'Android : 10 | App Version : 2.69.01',
      subTitle2: 'Logged in on Sunday, 25 April 2020  |  7:00 AM',),
  ];

  @override
  void initState() {
    initPlatformState();
    super.initState();
  }
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};

    try {
      if (kIsWeb) {
        deviceData = _readWebBrowserInfo(await deviceInfoPlugin.webBrowserInfo);
      } else {
        deviceData = switch (defaultTargetPlatform) {
    TargetPlatform.android =>_readAndroidBuildData(await deviceInfoPlugin.androidInfo),
    TargetPlatform.iOS =>_readIosDeviceInfo(await deviceInfoPlugin.iosInfo),
    TargetPlatform.linux =>_readLinuxDeviceInfo(await deviceInfoPlugin.linuxInfo),
    TargetPlatform.windows =>_readWindowsDeviceInfo(await deviceInfoPlugin.windowsInfo),
    TargetPlatform.macOS =>_readMacOsDeviceInfo(await deviceInfoPlugin.macOsInfo),
    TargetPlatform.fuchsia => <String, dynamic>{'Error:': 'Fuchsia platform isn\'t supported'},
    };}} on PlatformException {
    deviceData = <String, dynamic>{'Error:': 'Failed to get platform version.'};
    }

    if (!mounted) return;

    setState(() {
    _deviceData = deviceData;
    print('Devices:---$deviceData');
    });
  }
  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'version':build.version,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'systemFeatures': build.systemFeatures,
      'serialNumber': build.serialNumber,
      // 'isLowRamDevice': build.isLowRamDevice,
    };
  }
  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }
  Map<String, dynamic> _readLinuxDeviceInfo(LinuxDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'version': data.version,
      'id': data.id,
      'idLike': data.idLike,
      'versionCodename': data.versionCodename,
      'versionId': data.versionId,
      'prettyName': data.prettyName,
      'buildId': data.buildId,
      'variant': data.variant,
      'variantId': data.variantId,
      'machineId': data.machineId,
    };
  }
  Map<String, dynamic> _readWebBrowserInfo(WebBrowserInfo data) {
    return <String, dynamic>{
      'browserName': data.browserName.name,
      'appCodeName': data.appCodeName,
      'appName': data.appName,
      'appVersion': data.appVersion,
      'deviceMemory': data.deviceMemory,
      'language': data.language,
      'languages': data.languages,
      'platform': data.platform,
      'product': data.product,
      'productSub': data.productSub,
      'userAgent': data.userAgent,
      'vendor': data.vendor,
      'vendorSub': data.vendorSub,
      'hardwareConcurrency': data.hardwareConcurrency,
      'maxTouchPoints': data.maxTouchPoints,
    };
  }
  Map<String, dynamic> _readMacOsDeviceInfo(MacOsDeviceInfo data) {
    return <String, dynamic>{
      'computerName': data.computerName,
      'hostName': data.hostName,
      'arch': data.arch,
      'model': data.model,
      'kernelVersion': data.kernelVersion,
      'majorVersion': data.majorVersion,
      'minorVersion': data.minorVersion,
      'patchVersion': data.patchVersion,
      'osRelease': data.osRelease,
      'activeCPUs': data.activeCPUs,
      'memorySize': data.memorySize,
      'cpuFrequency': data.cpuFrequency,
      'systemGUID': data.systemGUID,
    };
  }
  Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo data) {
    return <String, dynamic>{
      'numberOfCores': data.numberOfCores,
      'computerName': data.computerName,
      'systemMemoryInMegabytes': data.systemMemoryInMegabytes,
      'userName': data.userName,
      'majorVersion': data.majorVersion,
      'minorVersion': data.minorVersion,
      'buildNumber': data.buildNumber,
      'platformId': data.platformId,
      'csdVersion': data.csdVersion,
      'servicePackMajor': data.servicePackMajor,
      'servicePackMinor': data.servicePackMinor,
      'suitMask': data.suitMask,
      'productType': data.productType,
      'reserved': data.reserved,
      'buildLab': data.buildLab,
      'buildLabEx': data.buildLabEx,
      'digitalProductId': data.digitalProductId,
      'displayVersion': data.displayVersion,
      'editionId': data.editionId,
      'installDate': data.installDate,
      'productId': data.productId,
      'productName': data.productName,
      'registeredOwner': data.registeredOwner,
      'releaseId': data.releaseId,
      'deviceId': data.deviceId,
    };
  }


  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Scaffold(
      // backgroundColor: color.backGroundClr,
      appBar: commonBarWithTextleft(context, color.backGroundClr, "Device management"),
      body: Stack(
        children: [
          SizedBox(
            height: size.height,
            width: size.width,
            child: Image.asset(AssetsPics.background,fit: BoxFit.cover,),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20,right: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height*0.03),
                  buildText("Current device", 16, FontWeight.w600, color.txtgrey2,fontFamily: FontFamily.hellix),
                  SizedBox(height: size.height*0.02-4),
                  Container(
                    padding: EdgeInsets.all(16),
                    width: size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: color.txtWhite,
                      border: Border.all(color: color.lightestBlue)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...[
                          buildText(Platform.isAndroid? "${_deviceData['brand']} (${_deviceData['model']})":_deviceData['model'], 18, FontWeight.w500, Colors.black,fontFamily: FontFamily.baloo2M),
                          buildText(Platform.isAndroid?"Android :${_deviceData['version.release']} ":"${_deviceData["systemName"]} :${_deviceData["systemVersion"]}", 15, FontWeight.w400, color.txtgrey3,fontFamily: FontFamily.hellix),
                          buildText("App Version : 3.11.02", 15, FontWeight.w400, color.txtgrey3,fontFamily: FontFamily.hellix),
                          buildText("Logged in on Friday, 11 Feb 2022 | 08:00pm", 15, FontWeight.w400, color.txtgreyhex,fontFamily: FontFamily.hellix),
                          // buildText("OnePLUS One Plus 5 (ONEPLUS A5000)", 18, FontWeight.w500, Colors.black),
                        // buildText("Android : Android 12", 15, FontWeight.w400, color.txtgrey3,fontFamily: FontFamily.hellix),
                        // buildText("App Version : 3.11.02", 15, FontWeight.w400, color.txtgrey3,fontFamily: FontFamily.hellix),
                        // buildText("Logged in on Friday, 11 Feb 2022 | 08:00pm", 15, FontWeight.w400, color.txtgrey3,fontFamily: FontFamily.hellix),
                    ].expand(
                              (widget) => [
                            widget,
                            const SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16,),
                 /* SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      width: size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: color.txtWhite,
                          border: Border.all(color: color.lightestBlue)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildText("Previous device", 16, FontWeight.w600, color.txtgrey2,fontFamily: FontFamily.hellix),
                            ListView.builder(
                                padding: EdgeInsets.all(0.0),
                              shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: devices.length,
                                itemBuilder: (context,index){
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 15,bottom: 4),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                buildText(devices[index].title, 18, FontWeight.w500, Colors.black,fontFamily: FontFamily.baloo2M),
                                                const SizedBox(height: 4),
                                                buildText(devices[index].subTitle1, 15, FontWeight.w500,Colors.black,fontFamily: FontFamily.hellix),
                                              ],),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  devices.removeLast();
                                                });
                                              },
                                                child: SvgPicture.asset(AssetsPics.delete))
                                          ],),
                                      ),
                                      buildText(devices[index].subTitle2, 14, FontWeight.w500, color.txtgreyhex,fontFamily: FontFamily.hellix),
                                      const SizedBox(height: 15,),
                                      index == devices.length -1 ? const SizedBox() : const Divider(
                                        height: 5,
                                        thickness: 1,
                                        indent: 20,
                                        endIndent: 20,
                                        color: color.example3,
                                      ),
                                    ],
                                  );
                                }),
                        ],
                      ),
                    ),
                  )*/
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
class Devices{
  int Id;
  String title;
  String subTitle1;
  String subTitle2;
  Devices({required this.Id,required this.title,required this.subTitle1,required this.subTitle2});
}