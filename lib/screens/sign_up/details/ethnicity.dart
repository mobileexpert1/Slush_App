import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:http/http.dart'as http;
import 'package:slush/widgets/toaster.dart';

class DetailEthnicityScreen extends StatefulWidget {
  const DetailEthnicityScreen({Key? key}) : super(key: key);

  @override
  State<DetailEthnicityScreen> createState() => _DetailEthnicityScreenState();
}

class _DetailEthnicityScreenState extends State<DetailEthnicityScreen> {
  List<EthnicityList> items=[
    EthnicityList(1, "Asian"),
    EthnicityList(2, "White"),
    EthnicityList(3, "Black"),
    EthnicityList(4, "Indigenous"),
    EthnicityList(5, "Latin/Hispanic"),
    EthnicityList(6, "Middle Eastern"),
    EthnicityList(7, "Pacific Islander"),
    EthnicityList(8, "Southeast Asian"),
    EthnicityList(9, "East Asian"),
    EthnicityList(10, "Other"),
  ];

  // List selectedTitle=[];
  var data;

  bool textValue=true;
  int selcetedIndex=-1;

  @override
  void initState() {
    check();
    getEthencityList();
    super.initState();
  }

  void check(){
    var i=0;
    if(LocaleHandler.EditProfile&&LocaleHandler.entencityname.isEmpty){
      for(i=0;i<LocaleHandler.dataa["ethnicity"].length;i++){
        // selectedTitle.add(LocaleHandler.dataa["ethnicity"][i]["name"]);
        LocaleHandler.entencityname.add(LocaleHandler.dataa["ethnicity"][i]["name"]);
      setState(() {});
      }
    }
  }

  Future getEthencityList()async{
    const url=ApiList.getEthencity;
    var uri=Uri.parse(url);
    var response=await http.get(uri,headers: {
      'Content-Type': 'application/json',
      'Authorization': "Bearer ${LocaleHandler.accessToken}",
      // 'Authorization': "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InRlc3QxMDlAeW9wbWFpbC5jb20iLCJzdWIiOjY3OSwianRpIjoiNGU0NGQ4Zjc5ZWIxNGY3ZWM5M2FkMGZkNTA3OTk4NGE2NTA3MGRkYzRlZjI5ZDNmZmFlNzk1YTU1ZjI2NDliOCIsImlhdCI6MTcxMjU1NDQxMiwiZXhwIjoxNzQ0MDkwNDEyfQ.bmcjuIFleUbi5UenTQhe3T0rkQNj78aZkopgFm8srYA",
    });
    var i=jsonDecode(response.body);
    if(response.statusCode==200){
      setState(() {data=i["data"];});
    } else if(response.statusCode==401){
      showToastMsgTokenExpired();
    }else{}
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         SizedBox(height:LocaleHandler.EditProfile?0: 3.h-3),
     LocaleHandler.EditProfile? buildText("Share your ethnicity with us.", 28, FontWeight.w600, color.txtBlack):   buildText2("Your ethnicity?", 28, FontWeight.w600, color.txtBlack),
        const SizedBox(height: 5),
        LocaleHandler.EditProfile?const SizedBox(): buildText("Share your ethnicity with us.", 15, FontWeight.w500, color.txtBlack,fontFamily: FontFamily.hellix),
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
                      if(LocaleHandler.entencityname.contains(data[index]["name"])){
                        // selectedTitle.remove(data[index]["name"]);
                        LocaleHandler.entencity.remove(data[index]["id"]);
                        LocaleHandler.entencityname.remove(data[index]["name"]);
                      }else{
                        LocaleHandler.entencity.add(data[index]["id"]);
                        LocaleHandler.entencityname.add(data[index]["name"]);
                        // selectedTitle.add(data[index]["name"]);
                       }
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    height: 7.h-3,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                        color: LocaleHandler.entencityname.contains(data[index]["name"])?color.lightestBlue:color.txtWhite,
                        border: Border.all(width: 1,color: LocaleHandler.entencityname.contains(data[index]["name"])?color.txtBlue:color.txtWhite)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20,right: 16,top: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          buildText(data[index]["name"], 18, FontWeight.w600, color.txtBlack),
                        ]),
                    ),
                  ),
                );
              }),
        ),
      SizedBox(height: 2.h-4)
      ],);
  }
}

class EthnicityList{
  int Id;
  String title;
  EthnicityList(this.Id,this.title);
}
