import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/widgets/app_bar.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:http/http.dart'as http;
import 'package:slush/widgets/toaster.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({Key? key}) : super(key: key);

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {

  List category=["All","Completed","Cancelled"];
  int selectedIndex=0;
  String selectedCat="All";
  var data;
  var capitalizedString;
  var totallen;
  String formattedDate="";
  String status="";
  ScrollController? _controller;


  @override
  void initState() {
    getPaymentHistory();
    _controller = ScrollController()..addListener(loadmore);
    super.initState();
  }

  int totalpages=0;
  int currentpage=0;
  List post=[];
  int _page = 1;
  bool _isLoadMoreRunning=false;
  bool _hasNextPage = true;

  Future getPaymentHistory()async{
    final url=ApiList.paymentHIstory+"${LocaleHandler.userId}?page=1&limit=15&filter=";
    print(url);
    var uri=Uri.parse(url);
    var response=await http.get(uri, headers: {'Content-Type': 'application/json', "Authorization": "Bearer ${LocaleHandler.accessToken}"});
    var i=jsonDecode(response.body)["data"];
    if(response.statusCode==200){
      if(mounted){
        setState(() {
          data=i["items"];
          totallen=i["meta"]["totalItems"];
          totalpages=i["meta"]["totalPages"];
          currentpage=i["meta"]["currentPage"];
          post=i["items"];
        });
      }
    }
    else if(response.statusCode==401){showToastMsgTokenExpired();}
    else{}
  }

  Future loadmore()async{
    if (_page<totalpages&&
        _hasNextPage == true &&  _isLoadMoreRunning == false && currentpage<totalpages&& _controller!.position.extentAfter < 300) {
      setState(() {_isLoadMoreRunning=true;});
      _page=_page+1;
      final url=ApiList.paymentHIstory+"${LocaleHandler.userId}?page=$_page&limit=15&filter=";
      print(url);
      var uri=Uri.parse(url);
      var response=await http.get(uri, headers: {'Content-Type':'application/json', 'Authorization':'Bearer ${LocaleHandler.accessToken}'});
      setState(() {_isLoadMoreRunning=false;});
      if(response.statusCode==200){
        setState(() {
          var data = jsonDecode(response.body)['data'];
          currentpage=data["meta"]["currentPage"];
          final List fetchedPosts = data["items"];
          if (fetchedPosts.isNotEmpty) {setState(() {post.addAll(fetchedPosts);});}
        });
      }}
  }

  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Scaffold(
      // extendBodyBehindAppBar: true,
      // backgroundColor: color.backGroundClr,
      appBar: commonBarWithTextleft(context,Colors.transparent, "Payment History"),
      body: Stack(
        children: [
          SizedBox(
            height: size.height,
            width: size.width,
            child: Image.asset(AssetsPics.background,fit: BoxFit.cover,),
          ),
          SingleChildScrollView(
            controller: _controller,
            child: Padding(padding: const EdgeInsets.only(left: 15,right: 15,top: 15),
              child: Column(children: [
                Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    height: 36,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: category.length,itemBuilder: (context,index){
                      return Row(children: [
                        GestureDetector(
                            onTap: (){setState(() {
                              selectedIndex=index;
                              selectedCat=category[index];
                            });},
                            child:selectedIndex==index? selectedButton(category[index]):unselectedButton(category[index])),
                        index==0?Container(margin: const EdgeInsets.only(left: 6,right: 6),
                          height: 23,width: 1,color: color.hieghtGrey,
                        ):const SizedBox(),
                      ],);})
                ),
               data==null?Padding(padding: const EdgeInsets.only(top: 200), child: CircularProgressIndicator(color: color.txtBlue,))
                   :totallen==0?const Padding(padding: EdgeInsets.only(top: 200), child: Text("no payment history!")): Container(
                  padding: const EdgeInsets.only(left: 15,right: 15),
                  margin: const EdgeInsets.only(bottom: 25),
                  decoration: BoxDecoration(color: color.txtWhite,borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: post.length,
                          padding: const EdgeInsets.only(top: 10,bottom: 10),
                          itemBuilder: (context,index){
                            capitalizedString = post[index]["p_purchase_type"].toString().split(' ').map((word) => word.capitalize()).join(' ');
                            String dateString = post[index]["p_created_at"];
                            DateTime dateTime = DateTime.parse(dateString);
                            formattedDate = DateFormat('MMM dd, yyyy').format(dateTime);
                            status=post[index]["p_payment_status"]=="cancelled"?"Cancelled":"Completed";
                            final LastElement= post.lastIndexWhere((e) =>  e["p_payment_status"] == selectedCat);
                            return selectedCat=="All"?  Column(children: [Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [imagewithdate(index),
                                      buildText("£"+post[index]["p_amount"], 20, FontWeight.w600, color.txtgrey2,fontFamily: FontFamily.hellix)
                                    ],
                                  ),
                                  index==post.length-1 ?const SizedBox():const Divider(color: color.lightestBlue),
                                ],
                              ):selectedCat==status?Column(children: [Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [imagewithdate(index),
                                  buildText("£"+post[index]["p_amount"], 20, FontWeight.w600, color.txtgrey2,fontFamily: FontFamily.hellix)
                                ],
                              ),
                                index==post.length-1 ?const SizedBox():
                                LastElement==index?const SizedBox(): const Divider(color: color.lightestBlue),
                              ],
                              ):SizedBox();
                          }),
                      _isLoadMoreRunning? Center(child: CircularProgressIndicator(color: color.txtBlue)):SizedBox(),

                    ],
                  ),
                )
              ],),
            ),
          ),
        ],
      ),
    );
  }

  Widget selectedButton(String btntxt) {
    return Container(
      padding: const EdgeInsets.only(left: 18,right: 18,top: 6,bottom: 6),
      margin: const EdgeInsets.only(right: 4,left: 4),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(19),
          gradient:  const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
            colors:[color.gradientLightBlue, color.txtBlue],)
      ),
      child: buildText(btntxt, 16, FontWeight.w600, color.txtWhite),
    );
  }

  Widget unselectedButton(String btntxt) {
    return Container(
      padding: const EdgeInsets.only(left: 17,right: 17,top: 5,bottom: 5),
      margin: const EdgeInsets.only(right: 4,left: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
            width: 1,color: color.disableButton
        ),
        // color: Color.fromARGB(242, 247, 255, 1)
      ),
      child: buildText(btntxt, 16, FontWeight.w600, color.txtBlack),
    );
  }

  Widget imagewithdate(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 3,top: 3),
      height: 84,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child:  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(height: 2),
          Row(children: [
            SvgPicture.asset(AssetsPics.outlinecalender),
            SizedBox(width: 1.h),
            buildText(formattedDate, 13, FontWeight.w500, color.txtgrey2,fontFamily: FontFamily.hellix)
          ],),
          SizedBox(height: 2),
          buildText(capitalizedString, 16, FontWeight.w600, color.txtBlack),
          SizedBox(height: 2),
          buildText(status, 16, FontWeight.w600, status=="Cancelled"?
          color.canceltxtOrange:color.completedtxtGreen),
          SizedBox(height: 1.h-5),
        ],),
    );
  }
}

extension StringExtensions on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}