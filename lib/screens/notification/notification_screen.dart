import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/widgets/app_bar.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:http/http.dart' as http;
import '../../constants/LocalHandler.dart';
import '../../constants/api.dart';
import '../../constants/loader.dart';
import '../../widgets/toaster.dart';
import '../events/bottomNavigation.dart';
import '../profile/Profile_screem.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreen1State();
}

class _NotificationScreen1State extends State<NotificationScreen> {

  List category=["All","General","Match","Likes"];
  String selectedCategory = "All";
  int selectedIndex=0;
  List dataa=[];
  int totalitems = 0;
  int currentpage = 0;
  String status="";

  List unLiked = [];
  List liked = [];
  int _page = 1;
  int totalPages = 0;
  int currentPage = 0;
  bool _isLoadMoreRunning = false;
  ScrollController? _controller;
  var timeFormat = DateTime.now();

  Future getNotification() async {
    final url = selectedIndex == 1 ?
    "${ApiList.notification}page=1&limit=10&notification_type=general" :
    selectedIndex == 2 ?
    "${ApiList.notification}page=1&limit=10&notification_type=match" :
    selectedIndex == 3 ?
    "${ApiList.notification}page=1&limit=10&notification_type=likes" :
    "${ApiList.notification}page=1&limit=10&notification_type=";
    print(url);
    var uri = Uri.parse(url);
    var response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${LocaleHandler.accessToken}'
    });
    var data = jsonDecode(response.body)["data"];
    if (response.statusCode == 200) {
      setState(() {
        totalitems = data["meta"]["totalItems"];
        currentpage = data["meta"]["currentPage"];
        totalPages = data["meta"]["totalPages"];
        dataa = data["items"];
        // dataa.sort((a, b) => b["createdAt"].compareTo(a["createdAt"]));
      });
    } else if (response.statusCode == 401) {
      showToastMsgTokenExpired();
    } else {
      Fluttertoast.showToast(msg: 'Something Went Wrong');
    }
  }

  Future loadMore()async{
    if(_page<totalPages && _isLoadMoreRunning == false && currentPage<totalPages && _controller!.position.extentAfter < 300){
      setState(() {
        _isLoadMoreRunning =true;
      });
      _page=_page+1;
      final url= selectedIndex == 1 ?
      "${ApiList.notification}page=$_page&limit=10&notification_type=general" :
      selectedIndex == 2 ?
      "${ApiList.notification}page=$_page&limit=10&notification_type=match" :
      selectedIndex == 3 ?
      "${ApiList.notification}page=$_page&limit=10&notification_type=likes" :
      "${ApiList.notification}page=$_page&limit=10&notification_type=";
      print(url);
      var uri=Uri.parse(url);
      var response = await http.get(uri, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${LocaleHandler.accessToken}'});
      setState(() {_isLoadMoreRunning = false;});
      var data = jsonDecode(response.body)["data"];
      if(response.statusCode==200){
        totalitems = data["meta"]["totalItems"];
        currentpage = data["meta"]["currentPage"];
        // dataa = data["items"];
        final List fetchedNotifications = data["items"];
        if(fetchedNotifications.isNotEmpty){
          setState(() {dataa.addAll(fetchedNotifications);});
        }
      }
    }
  }

  @override
  void initState() {
    getNotification();
    _controller = ScrollController()..addListener(loadMore);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Scaffold(
      appBar: commonBarWithTextleft(context, color.backGroundClr, "Notification"),
      body: Stack(
        children: [
          SizedBox(
            height: size.height,
            width: size.width,
            child: Image.asset(AssetsPics.background,fit: BoxFit.cover,),
          ),
          SingleChildScrollView(
            controller: _controller,
            child: Padding(padding: const EdgeInsets.only(left: 15,right: 15,top: 20),
              child: Column(
                children: [

                  Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      height: 46,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: category.length,
                          itemBuilder: (context,index){
                            return Row(children: [
                              GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      selectedIndex=index;
                                      selectedCategory = category[index];
                                      getNotification();
                                    });},
                                  child:selectedIndex==index? selectedButton(category[index]):unselectedButton(category[index])),
                              index==0?Container(margin: const EdgeInsets.only(left: 6,right: 6),
                                height: 23,width: 2,color: const Color.fromRGBO(217, 217, 217, 1),
                              ):const SizedBox(),
                            ],);})
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12), color: color.txtWhite),
                    child: dataa == null ? const Padding(
                      padding: EdgeInsets.only(top: 200),
                      child: CircularProgressIndicator(color: color.txtBlue),
                    ): totalitems ==0 ?
                    Stack(
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
                                  child: Container(alignment: Alignment.center,
                                    child: SvgPicture.asset(AssetsPics.threeDotsLeft),),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  child:Image.asset(AssetsPics.nonotification),),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            buildText("No notification?", 30, FontWeight.w600, color.txtBlue),
                            SizedBox(height: 2.h),
                            buildText2("You have not received any \n notifications yet.", 18, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
                            SizedBox(height: 22.h)
                          ],
                        ),
                      ],
                    ):
                    ListView.builder(
                        padding: const EdgeInsets.all(0.0),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: dataa.length,
                        itemBuilder: (context,index){

                          String notificationType = dataa[index]["notification_type"].toString().capitalize!;
                          int createdAt = dataa[index]["createdAt"];
                          int currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
                          int differenceInSeconds = currentTimestamp - createdAt;
                          Duration differenceDuration = Duration(seconds: differenceInSeconds);

                          String timeAgo;
                          if (differenceDuration.inSeconds < 60) {
                            timeAgo = 'now';
                          } else if (differenceDuration.inMinutes < 60) {
                            timeAgo = '${differenceDuration.inMinutes}min ago';
                          } else if (differenceDuration.inHours < 24) {
                            timeAgo = '${differenceDuration.inHours}h ago';
                          } else {
                            timeAgo = '${differenceDuration.inDays}d ago';
                          }

                          status=dataa[index]["notification_type"]=="likes"?"Likes":
                          dataa[index]["notification_type"]=="match"?"Match":
                          dataa[index]["notification_type"]=="general"?"General":"All";
                          final lastElement= dataa.lastIndexWhere((e) =>  e["notification_type"] == selectedCategory.toLowerCase());

                          return  selectedCategory == "All" ?
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 8),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(AssetsPics.mailImg,height: 40),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                              width: 189,
                                              child: buildText(dataa[index]["notification_title"], 16, FontWeight.w600, color.txtBlack,fontFamily: FontFamily.hellix)),

                                          dataa[index]["notification_type"] == "match" || dataa[index]["notification_type"] == "likes" ? const SizedBox(height: 10,) :
                                          buildText(dataa[index]["notification_description"],
                                              15, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),

                                          const SizedBox(height: 8),
                                          dataa[index]["notification_type"] == "likes" ?  GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                LoaderOverlay.show(context);
                                                LocaleHandler.liked=true;
                                                LocaleHandler.bottomSheetIndex=3;
                                                Get.to(()=>BottomNavigationScreen());
                                                LoaderOverlay.hide();
                                              });
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              height: 36,
                                              width: 130,
                                              padding: const EdgeInsets.symmetric(horizontal: 15),
                                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(19),
                                                  gradient:  const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
                                                    colors:[color.gradientLightBlue, color.txtBlue],)
                                              ),
                                              child: buildText("View likes",16,FontWeight.w600,color.txtWhite),
                                            ),
                                          ) :
                                          dataa[index]["notification_type"] == "match"? GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                LoaderOverlay.show(context);
                                                LocaleHandler.liked=false;
                                                LocaleHandler.bottomSheetIndex=3;
                                                Get.to(()=>BottomNavigationScreen());
                                                LoaderOverlay.hide();
                                              });
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              height: 36,
                                              width: 130,
                                              padding: const EdgeInsets.symmetric(horizontal: 15),
                                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(19),
                                                  gradient:  const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
                                                    colors:[color.gradientLightBlue, color.txtBlue],)
                                              ),
                                              child: buildText("View matches",16,FontWeight.w600,color.txtWhite),
                                            ),
                                          )  :
                                          dataa[index]["notification_type"] == "general"? GestureDetector(
                                            onTap: () {
                                              Get.to(()=> const UserProfileScreen());                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              height: 36,
                                              width: 130,
                                              padding: const EdgeInsets.symmetric(horizontal: 15),
                                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(19),
                                                  gradient:  const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
                                                    colors:[color.gradientLightBlue, color.txtBlue],)
                                              ),
                                              child: buildText("Go to Profile",16,FontWeight.w600,color.txtWhite),
                                            ),
                                          ) : const SizedBox(),
                                          const SizedBox(height: 5,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                  width: 100,
                                                  child: buildText(timeAgo, 14, FontWeight.w600, color.dropDowngreytxt,fontFamily: FontFamily.hellix)),

                                              dataa[index]["notification_type"] == "general" ? const SizedBox() :  Container(
                                                padding: const EdgeInsets.only(right: 8,left: 5),
                                                alignment: Alignment.center,
                                                height: 17,
                                                color: dataa[index]["notification_type"] == "match" ? Colors.deepOrange : color.gradientLightBlue,
                                                transform: Matrix4.skewX(-.3),
                                                child: Transform(
                                                    transform: Matrix4.skewX(.2),
                                                    child: buildText(notificationType=="Likes"?"Like":notificationType, 13, FontWeight.w600, color.txtWhite,fontFamily: FontFamily.hellix)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                index == dataa.length -1 ? const SizedBox() : const Divider(height: 30, thickness: 1, color: color.example3,),
                              ],
                            ),
                          ): selectedCategory == status ?
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 8),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(AssetsPics.mailImg,height: 40),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                              width: 189,
                                              child: buildText(dataa[index]["notification_title"], 16, FontWeight.w600, color.txtBlack,fontFamily: FontFamily.hellix)),

                                          dataa[index]["notification_type"] == "match" || dataa[index]["notification_type"] == "likes" ? const SizedBox() :
                                          buildText(dataa[index]["notification_description"],
                                              15, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
                                          const SizedBox(height: 8),
                                          dataa[index]["notification_type"] == "likes" ?  GestureDetector(

                                            onTap: () {
                                              setState(() {
                                                LoaderOverlay.show(context);
                                                LocaleHandler.liked=true;
                                                LocaleHandler.bottomSheetIndex=3;
                                                Get.to(()=>BottomNavigationScreen());
                                                LoaderOverlay.hide();
                                              });
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              height: 36,
                                              width: 130,
                                              padding: const EdgeInsets.symmetric(horizontal: 15),
                                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(19),
                                                  gradient:  const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
                                                    colors:[color.gradientLightBlue, color.txtBlue],)
                                              ),
                                              child: buildText("View likes",16,FontWeight.w600,color.txtWhite),
                                            ),
                                          ) :
                                          dataa[index]["notification_type"] == "match"? GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                LoaderOverlay.show(context);
                                                LocaleHandler.liked=false;
                                                LocaleHandler.bottomSheetIndex=3;
                                                Get.to(()=>BottomNavigationScreen());
                                                LoaderOverlay.hide();
                                              });                                              },
                                            child: Container(
                                              alignment: Alignment.center,
                                              height: 36,
                                              width: 130,
                                              padding: const EdgeInsets.symmetric(horizontal: 15),
                                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(19),
                                                  gradient:  const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
                                                    colors:[color.gradientLightBlue, color.txtBlue],)
                                              ),
                                              child: buildText("View matches",16,FontWeight.w600,color.txtWhite),
                                            ),
                                          ) :
                                          dataa[index]["notification_type"] == "general"? GestureDetector(
                                            onTap: () {
                                              Get.to(()=> const UserProfileScreen());
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              height: 36,
                                              width: 124,
                                              padding: const EdgeInsets.symmetric(horizontal: 15),
                                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(19),
                                                  gradient:  const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
                                                    colors:[color.gradientLightBlue, color.txtBlue],)
                                              ),
                                              child: buildText("Go to Profile",16,FontWeight.w600,color.txtWhite),
                                            ),
                                          ): const SizedBox(),
                                          const SizedBox(height: 5,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                  width: 100,
                                                  child: buildText(timeAgo, 14, FontWeight.w600, color.dropDowngreytxt,fontFamily: FontFamily.hellix)),
                                              dataa[index]["notification_type"] == "general" ? const SizedBox() : Container(
                                                padding: const EdgeInsets.only(right: 8,left: 5),
                                                alignment: Alignment.center,
                                                height: 17,
                                                color: dataa[index]["notification_type"] == "match" ? Colors.deepOrange : color.gradientLightBlue,
                                                transform: Matrix4.skewX(-.3),
                                                child: Transform(
                                                    transform: Matrix4.skewX(.2),
                                                    child: buildText(notificationType, 13, FontWeight.w600, color.txtWhite,fontFamily: FontFamily.hellix)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                index == dataa.length -1 ? const SizedBox() :
                                lastElement==index ? const SizedBox():
                                const Divider(height: 30, thickness: 1, color: color.example3,),
                              ],
                            ),
                          ):const SizedBox();
                        }),
                  ),
                  const SizedBox(height: 50),
                  _isLoadMoreRunning? const Center(child: CircularProgressIndicator(color: color.txtBlue)):const SizedBox(),
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
          border: Border.all(
              width: 1,color: color.txtBlue
          ),
          gradient:  const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
            colors:[color.gradientLightBlue, color.txtBlue],)
      ),
      child: buildText(btntxt, 16, FontWeight.w600, color.txtWhite),
    );
  }
  Widget unselectedButton(String btntxt) {
    return Container(
      padding: const EdgeInsets.only(left: 18,right: 18,top: 6,bottom: 6),
      margin: const EdgeInsets.only(right: 4,left: 4),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
              width: 1,color: color.disableButton
          )
      ),
      child: buildText(btntxt, 16, FontWeight.w600, color.txtBlack),
    );
  }
}