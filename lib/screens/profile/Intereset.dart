import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart'as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/loader.dart';
import 'package:slush/controller/profile_controller.dart';
import 'package:slush/widgets/blue_button.dart';
import 'package:slush/widgets/text_widget.dart';

import '../../widgets/toaster.dart';

class InterestListScreen extends StatefulWidget {
  const InterestListScreen({Key? key}) : super(key: key);

  @override
  State<InterestListScreen> createState() => _InterestListScreenState();
}

class _InterestListScreenState extends State<InterestListScreen> {
  List selectedTitle=[];
  var data;
  int selcetedIndex=-1;

  Future getINterest()async{
    final url=ApiList.getInterest;
    var uri=Uri.parse(url);
    var response=await http.get(uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${LocaleHandler.accessToken}",
        });
    var i=jsonDecode(response.body);
    if(response.statusCode==200){
      setState(() {data=i["data"];});
    }
    else if(response.statusCode==401){
      showToastMsgTokenExpired();
    }
    else{
      // Fluttertoast.showToast(msg: "");
    }
  }

  @override
  void initState() {
    checkkkk();
    getINterest();
    super.initState();
  }
  void checkkkk(){var i=0;//if(LocaleHandler.EditProfile){
      for(i=0;i<LocaleHandler.dataa["interests"].length;i++){
        selectedTitle.add(LocaleHandler.dataa["interests"][i]["id"]);
      }}//}

  Future updateInterest()async{
    setState(() {LoaderOverlay.show(context);});
    final url=ApiList.updateInterest;
    var uri=Uri.parse(url);
    var response=await http.patch(uri,
        headers: {'Content-Type': 'application/json',
          "Authorization": "Bearer ${LocaleHandler.accessToken}"},
        body: jsonEncode({
          "interests":selectedTitle
        })
    );
    setState(() {LoaderOverlay.hide();});
    if(response.statusCode==200){
      Provider.of<profileController>(context,listen: false).profileData(context).then((value)  {
        Get.back();
        Get.back();
      });
      // Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(height: size.height, width: size.width,
            child: Image.asset(AssetsPics.background, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15,right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height:5.h-3),
                Row(
                  children: [
                   GestureDetector(
                     onTap: (){Get.back();},
                     child: Container(color: Colors.transparent,
                       height: 35,width: 30,
                         padding: const EdgeInsets.all(4),
                         child: SvgPicture.asset(AssetsPics.arrowLeft)),
                   ),
                    const SizedBox(width: 40),
                    buildText("Choose your interest", 28, FontWeight.w600, color.txtBlack),
                  ],
                ),
                const SizedBox(height: 5),
                // const SizedBox(height: 29),
                data==null?const Center(child: Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: CircularProgressIndicator(color: color.txtBlue),
                )): Expanded(
                  child: ListView.builder(
                      padding: const EdgeInsets.only(top: 20,bottom: 150),
                      itemCount: data.length,
                      itemBuilder: (context,index){
                        return GestureDetector(
                          onTap: (){
                            setState(() {
                              selcetedIndex=index;
                              if(selectedTitle.contains(data[index]["id"])){
                                selectedTitle.remove(data[index]["id"]);
                                LocaleHandler.entencity.remove(data[index]["id"]);
                              }else{
                                LocaleHandler.entencity.add(data[index]["id"]);
                                selectedTitle.add(data[index]["id"]);}
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            height: 7.h-3,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                                color: selectedTitle.contains(data[index]["id"])?color.lightestBlue:color.txtWhite,
                                border: Border.all(width: 1,color: selectedTitle.contains(data[index]["id"])?color.txtBlue:color.txtWhite)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20,right: 16,top: 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SvgPicture.network(data[index]["url"],color: color.txtBlue),
                                  // CachedNetworkImage(imageUrl: data[index]["url"],color: color.txtBlue),
                                  const SizedBox(width: 15),
                                  buildText(data[index]["name"], 18, FontWeight.w600, color.txtBlack),
                                ],),
                            ),
                          ),
                        );
                      }),
                ),
                SizedBox(height: 2.h-4)
              ],),
          ),
        ],
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 15, right: 15, top: 20),
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 30,
          height: 50.0,
          child: blue_button(context, "Update",press: (){
            print(selectedTitle);
            updateInterest();
          }),
        ),
      ),
    );
  }
}
