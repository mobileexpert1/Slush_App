import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:http/http.dart'as http;
import 'package:slush/widgets/app_bar.dart';
import 'package:slush/widgets/text_widget.dart';

class EventHistoryScreen extends StatefulWidget {
  const EventHistoryScreen({Key? key}) : super(key: key);

  @override
  State<EventHistoryScreen> createState() => _EventHistoryScreenState();
}

class _EventHistoryScreenState extends State<EventHistoryScreen> {

  List category=["All","Completed","Cancelled"];
  int selectedIndex=0;
  String selectedCat="All";
  List data=[];
  var itemlen;
  String formattedDate="";
  String formattedmon="";
  String status="";

  ScrollController? _controller;
  int totalpages=0;
  int currentpage=0;
  int _page = 1;
  bool _isLoadMoreRunning=false;

  @override
  void initState() {
    getEventHistory();
    _controller = ScrollController()..addListener(loadmore);
    super.initState();
  }

  Future getEventHistory()async{
    // final url =ApiList.geteventhistory?page=1&limit=15&filter=popular;
    const url ="${ApiList.geteventhistory}1&limit=10";
    print(url);
    var uri=Uri.parse(url);
    var response=await http.post(uri,
    headers: {'Content-Type': 'application/json', 'Authorization':'Bearer ${LocaleHandler.accessToken}'});
    var i=jsonDecode(response.body);
    if(response.statusCode==201){
      if(mounted){
        setState(() {
          data=i["items"];
          itemlen=i["meta"]["totalItems"];
          totalpages=i["meta"]["totalPages"];
          currentpage=i["meta"]["currentPage"];});
      }
    }
  }

  Future loadmore()async{
    if (_page<totalpages&& _isLoadMoreRunning == false && currentpage<totalpages&& _controller!.position.extentAfter < 300) {
      setState(() {_isLoadMoreRunning=true;});
      _page=_page+1;
      final url="${ApiList.geteventhistory}$_page&limit=10";
      print(url);
      var uri=Uri.parse(url);
      var response=await http.get(uri, headers: {'Content-Type':'application/json', 'Authorization':'Bearer ${LocaleHandler.accessToken}'});
      setState(() {_isLoadMoreRunning=false;});
      if(response.statusCode==200){
        setState(() {
          var i = jsonDecode(response.body)['data'];
          currentpage=i["meta"]["currentPage"];
          final List fetchedPosts = i["items"];
          if (fetchedPosts.isNotEmpty) {setState(() {data.addAll(fetchedPosts);});}
        });
      }}
  }


  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Scaffold(
      // extendBodyBehindAppBar: true,
      // backgroundColor: color.backGroundClr,
      appBar: commonBarWithTextleft(context,Colors.transparent, "Event History"),
      body: Stack(
        children: [
          SizedBox(
            height: size.height,
            width: size.width,
            child: Image.asset(AssetsPics.background,fit: BoxFit.cover,),
          ),
          SingleChildScrollView(
            controller: _controller,
            child: Padding(padding: const EdgeInsets.only(left: 15,right: 15,top: 2),
            child: Column(children: [
              Container(
                margin: const EdgeInsets.only(bottom: 14,top: 10),
                height: 36,
                // color: Colors.red,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
              data==null?const Padding(
                padding: EdgeInsets.only(top: 200),
                child: CircularProgressIndicator(color: color.txtBlue),
              ):itemlen==0?
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: color.txtWhite),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top:120.0,
                      child: Container(
                        // color: Colors.red,
                          height: 22.h,
                          width: 23.h,
                          alignment: Alignment.center,
                          child: SvgPicture.asset(AssetsPics.bigheart,fit: BoxFit.cover,)),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 15.h),
                        Stack(
                          children: [
                            Positioned(
                              left: 130,
                              child: Container(
                                alignment: Alignment.center,
                                child: SvgPicture.asset(AssetsPics.threeDotsLeft),),
                            ),
                            Container(
                                margin: EdgeInsets.only(top: 20,left: 20),
                                alignment: Alignment.center,
                              child:Image.asset(AssetsPics.noevent)),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        buildText("No events yet? ", 30, FontWeight.w600, color.txtBlue),
                        SizedBox(height: 2.h),
                        buildText2("You have not attend any \n event yet.", 18, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
                        SizedBox(height: 22.h)
                      ],
                    ),
                  ],
                ),
              ) : Container(
                padding: const EdgeInsets.only(left: 15,right: 15),
                margin: const EdgeInsets.only(bottom: 25),
                decoration: BoxDecoration(color: color.txtWhite,borderRadius: BorderRadius.circular(12)),
                child: ListView.builder(
                  shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.length,
                    padding: const EdgeInsets.only(top: 10,bottom: 10),
                    itemBuilder: (context,index){
                    // final LastElement= historyItem.lastWhere((e) =>  e.status == selectedCat);
                    // final LastElement= historyItem.lastIndexWhere((e) =>  e.status == selectedCat);
                    String dateString = data[index]["e_starts_at"];
                    DateTime dateTime = DateTime.parse(dateString);
                    formattedDate = DateFormat('dd').format(dateTime);
                    formattedmon = DateFormat('MMM').format(dateTime);
                    status=data[index]["p_status"]=="cancelled"?"Cancelled":"Completed";
                    final LastElement= data.lastIndexWhere((e) =>  e["p_status"] == selectedCat.toLowerCase());
                    return selectedCat=="All" ?  Container(
                        // color: Colors.red,
                        padding: const EdgeInsets.only(top: 3),
                        child: Column(children: [
                         Row(children: [imagewithdate(index),
                          const SizedBox(width: 10), details(index)
                        ],), const SizedBox(height: 3),
                        index==data.length-1 ?const SizedBox():const Divider(color: color.lightestBlue),],),
                      ) : selectedCat==status?
                      Container(
                        padding: const EdgeInsets.only(top: 3),
                        child: Column(children: [
                          Row(children: [
                            imagewithdate(index),
                            const SizedBox(width: 10),
                            details(index)
                          ],),
                          const SizedBox(height: 3),
                          index==data.length-1 ?const SizedBox():
                          LastElement==index?const SizedBox():
                          const Divider(color: color.lightestBlue),
                        ],),
                      ):const SizedBox();
                }),
              ),
              _isLoadMoreRunning? const Center(child: CircularProgressIndicator(color: color.txtBlue)):SizedBox(),
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
        color: Color.fromRGBO(242, 247, 255, 1)
      ),
      child: buildText(btntxt, 16, FontWeight.w600, color.txtBlack),
    );
  }

  Column details(int index) {
    final size=MediaQuery.of(context).size;
    return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        // width: 190,child: buildTextOverFlow(historyItem[index].title, 16, FontWeight.w600, color.txtBlack)),
                        width: size.width*0.4,child: buildTextOverFlow(data[index]["e_title"], 16, FontWeight.w600, color.txtBlack)),
                  Row(children: [
                    SvgPicture.asset(AssetsPics.blueMapPoint),
                    const SizedBox(width: 4),
                    // buildTextOverFlow(historyItem[index].location, 13, FontWeight.w500, color.txtgrey2,fontFamily: FontFamily.hellix),
                    buildTextOverFlow(data[index]["e_country"], 13, FontWeight.w500, color.txtgrey2,fontFamily: FontFamily.hellix),
                  ],),
                    const SizedBox(height: 8),
                    // buildText(historyItem[index].status, 16, FontWeight.w600, historyItem[index].status=="Cancelled"?
                    buildText(status, 16, FontWeight.w600, status.toString().toLowerCase()=="cancelled"?
                        color.canceltxtOrange:color.completedtxtGreen)
                ],);
  }

  Widget imagewithdate(int index) {
    return Container(
                  margin: const EdgeInsets.only(bottom: 3,top: 3),
                  height: 84,
                  width: 118,
                    decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    ),
                  child: Stack(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                          height: 84,
                          width: 118,
                          // child: Image.asset(historyItem[index].img,fit: BoxFit.fill)
                          child: CachedNetworkImage(imageUrl: "https://virtual-speed-date.s3.eu-west-2.amazonaws.com/"+data[index]["e_cover_image"],fit: BoxFit.fill)
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 5,top: 4),
                          width: 46,
                          decoration: BoxDecoration(color: color.txtWhite,borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // buildText("30", 15, FontWeight.w600, color.txtBlack,fontFamily: FontFamily.hellix),
                              buildText2("$formattedDate\n$formattedmon", 16, FontWeight.w600, color.txtBlack,fontFamily: FontFamily.hellix),
                            ],),
                        ),Expanded(child: Container())
                      ],
                    ),
                                          
                ],),
                );
  }
}
