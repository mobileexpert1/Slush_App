import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart'as http;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/loader.dart';
import 'package:slush/constants/prefs.dart';
import 'package:slush/controller/controller.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/controller/event_controller.dart';
import 'package:slush/screens/events/event_list.dart';
import 'package:slush/screens/events/eventhistory.dart';
import 'package:slush/screens/events/free_event.dart';
import 'package:slush/screens/events/you_ticket.dart';
import 'package:slush/screens/notification/notification_screen.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:slush/widgets/toaster.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({Key? key}) : super(key: key);

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  TextEditingController searchController = TextEditingController();
  FocusNode searchNode = FocusNode();
  Timer? countdownTimer;
  Duration myDuration = const Duration(days: 5);
  var secondsss = "00";
  int selectedIndex=0;
  String selectedIndexItem="seeall";
  String usergender="";
  String userSexuality="";
  bool _isLoadMoreRunning=false;
  String location="";


  TextEditingController locationController=TextEditingController();
  FocusNode locationNode=FocusNode();
  String enableField="";
  List state=[];
  List statesList=[];
  String _searchQuery='';
  var uuid =  Uuid();
  String _sessionToken =  Uuid().toString();
  List<dynamic>_placeList = [];
  void _onChanged() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    getLocationResults(locationController.text);
  }

  void getLocationResults(String input) async {
    // AIzaSyD2x5SDImQ-4Suz9pHXBEFkTskYnefKkv0
    String kPLACES_API_KEY = "AIzaSyAtb9qudpaPK2l0uoANyRE0zi4Nj4jNoT4";
    String type = '(regions)';
    String baseURL ="https://maps.googleapis.com/maps/api/place/autocomplete/json";
    String request ="$baseURL?input=$input&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken";
    var response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      setState(() {
        _placeList = jsonDecode(response.body)["predictions"];
      });
    } else {
      throw Exception("Failed to load predictions");
    }
  }

  List<CircleAvatarItems> items = [
    CircleAvatarItems(1, "All", AssetsPics.all,AssetsPics.selectall),
    CircleAvatarItems(2, "Music", AssetsPics.music,AssetsPics.selectmusic),
    CircleAvatarItems(3, "Sport", AssetsPics.sport,AssetsPics.selectsport),
    CircleAvatarItems(4, "Food", AssetsPics.food,AssetsPics.selectfood),
    CircleAvatarItems(5, "Business", AssetsPics.business,AssetsPics.selectbusiness),
  ];

  late ScrollController _controller;
  // int _value=100;`
  // List gender = ["Male", "Female", "Everyone"];
  // bool isChecked = false;
  // bool savedEvent=false;

  @override
  void initState() {
    locationController.addListener(() {
      _onChanged();
    });
    _getCurrentPosition();
    profileData();
    Provider.of<eventController>(context,listen: false).savedEvents();
    getEvents();
    checkBannerStatus();
    _controller = ScrollController()..addListener(loadmore);
    super.initState();
  }

  // Animated to container
  void checkBannerStatus(){
  if(LocaleHandler.isThereAnyEvent){
    startTimer();
    futuredelayed(1, true);
    futuredelayed(3, false);
    LocaleHandler.isThereAnyEvent=false;
  }
  // else if(LocaleHandler.isThereCancelEvent){
  //   futuredelayed(1, true);
  //   futuredelayed(3, false);
  //   LocaleHandler.isThereCancelEvent=false;}
  else if(LocaleHandler.unMatchedEvent){
    futuredelayed(1, true);
    futuredelayed(3, false);
    LocaleHandler.unMatchedEvent=false;
  }
  else if(LocaleHandler.subScribtioonOffer){
    futuredelayed(1, true);
    futuredelayed(3, false);
    LocaleHandler.subScribtioonOffer=false;
  }
  else{
   setState(() {LocaleHandler.isBanner=false;});
  }
}

  void futuredelayed(int i,bool val){
  Provider.of<eventController>(context,listen: false).futuredelayed(i, val);
  }

  // Event Timer
  void setCountDown() {
    const reduceSecondsBy = 1;
    setState(() {
      final seconds = myDuration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {countdownTimer!.cancel();
      } else {
        myDuration = Duration(seconds: seconds);
        setState(() {secondsss = myDuration.inSeconds.remainder(60).toString();});
      }
    });
  }

  void startTimer() {countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());}

  // hit get EVents
  var data;
  List post=[];
  int _page = 1;
  var myEvent=null;
  bool eventStored=false;
  int totalpages=0;
  int currentpage=0;
  bool _hasNextPage = true;

  Future getEvents()async{
  // final url="${ApiList.getEvent}${LocaleHandler.userId}&distance=5000&events=popular&latitude=30.6990901&longitude=76.6913955&page=1&limit=15";
  final url=// LocaleHandler.latitude==""?"${ApiList.getEvent}${LocaleHandler.userId}&distance=${LocaleHandler.distancee}&events=popular":
  "${ApiList.getEvent}${LocaleHandler.miliseconds}&distance=${LocaleHandler.distancee}&events=popular&latitude=${LocaleHandler.latitude}&longitude=${LocaleHandler.longitude}&categories=$selectedIndexItem&page=$_page&limit=10";
  print(url);
  var uri=Uri.parse(url);
  var response=await http.get(uri,
  headers: {'Content-Type':'application/json', 'Authorization':'Bearer ${LocaleHandler.accessToken}'});
  if(response.statusCode==200){print(response.statusCode);
  setState(() {data=jsonDecode(response.body)["data"];
  totalpages=data["meta"]["totalPages"];
  currentpage=data["meta"]["currentPage"];
  post=data["items"];
  });
  List<Map<String, dynamic>> j=[];
  for(var i=0;i<data["items"].length;i++){
    for(var ii=0;ii<data["items"][i]["participants"].length;ii++){
      if(data["items"][i]["participants"][ii]["user"]["userId"].toString()==LocaleHandler.userId){
        j.add(data["items"][i]);
      }
    }
  }    setState(() {LoaderOverlay.hide();});
  if(eventStored==false){myEvent=j;eventStored=true;}}
  else if(response.statusCode==401){showToastMsgTokenExpired();}
  else{Fluttertoast.showToast(msg: 'Something Went Wrong');
  setState(() {data="no data";});
  }}

  Future loadmore()async{
    _searchQuery="";
    FocusManager.instance.primaryFocus?.unfocus();
    // setState(() {LoaderOverlay.show(context);});
    if (_page<totalpages && _hasNextPage == true &&  _isLoadMoreRunning == false && currentpage<totalpages&& _controller.position.extentAfter < 300) {
      setState(() {_isLoadMoreRunning=true;});
    _page=_page+1;
      final url="${ApiList.getEvent}${LocaleHandler.miliseconds}&distance=${LocaleHandler.distancee}&events=popular&latitude=${LocaleHandler.latitude}&longitude=${LocaleHandler.longitude}&categories=$selectedIndexItem&page=$_page&limit=10";
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

          List<Map<String, dynamic>> j=myEvent;
          for(var i=0;i<data["items"].length;i++){
            for(var ii=0;ii<data["items"][i]["participants"].length;ii++){
              if(data["items"][i]["participants"][ii]["user"]["userId"].toString()==LocaleHandler.userId){
                j.add(data["items"][i]);
              }
            }
          }
          myEvent=j;
          // if(eventStored==false){myEvent=j;eventStored=true;}
        });
      }}
    setState(() {LoaderOverlay.hide();});
  }

  // location
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  String latitude = "";
  String longitude = "";

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handlePermission();
    if (!hasPermission) {
      Fluttertoast.showToast(msg: "Location permission is neccessary");
      // Get.offAll(const LoginScreen());
      // exit(0);
      // SystemNavigator.pop();
    }
    final position = await _geolocatorPlatform.getCurrentPosition();
    latitude = position.latitude.toString();
    longitude = position.longitude.toString();
    Provider.of<nameControllerr>(context,listen: false).setLocation(latitude, longitude);
    getEvents();
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {return false;}
    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {return false;}
    }
    if (permission == LocationPermission.deniedForever) {return false;}
    return true;
  }

  // Get Profile
  int age=0;
  var userData;

  Future profileData() async {
    final url = ApiList.getUser + LocaleHandler.userId;
    print(url);
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${LocaleHandler.accessToken}'
      });
      if (response.statusCode == 200) {
        setState((){
          Map<String,dynamic> data = jsonDecode(response.body);
          userData=data["data"];
          LocaleHandler.name=userData["firstName"];
          LocaleHandler.avatar=userData["avatar"];
          age= calculateAge(data["data"]["dateOfBirth"].toString());
          usergender=userData["gender"];
          location=userData["state"]+", "+userData["country"];
          LocaleHandler.gender=usergender;
          userSexuality=userData["sexuality"];
          LocaleHandler.subscriptionPurchase=userData["isSubscriptionPurchased"];
          // LocaleHandler.isVerified=userData["isVerified"];
          if(userData["isVerified"]==null){LocaleHandler.isVerified = false;}
          else{LocaleHandler.isVerified=userData["isVerified"];}
        });
      } else if (response.statusCode == 401) {showToastMsgTokenExpired();
      print('Token Expire:::::::::::::');
      } else {print('Failed to Load Data With Status Code ${response.statusCode}');
      throw Exception('Failed to load data');}
    } catch (e) {throw Exception('Failed to fetch data: $e');}
  }

  int calculateAge(String dobString) {
    DateTime dob = DateTime.parse(dobString);
    DateTime now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Scaffold(
      // backgroundColor: color.backGroundClr,
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              _searchQuery="";
            },
            child: Stack(
              children: [
                SizedBox(height: size.height, width: size.width, child: Image.asset(AssetsPics.background,fit: BoxFit.cover),),
                SafeArea(
                  child:userData==null?const Center(child: CircularProgressIndicator(color: color.txtBlue)): Stack(
                    children: [
                      SingleChildScrollView(
                        physics: ClampingScrollPhysics(),
                        controller: _controller,
                        child: Center(
                            child: Column(
                              children: [
                                Stack( children: [
                                  buildProfileSection(),
                                  // animatedBanner(context)
                                ],),
                                searchContainer(),
                                LocaleHandler.isThereAnyEvent? isThereEvent():const SizedBox(),
                                // LocaleHandler.isThereAnyEvent? myEventlist():const SizedBox(),
                                myEventlist(),
                                categoryList(context),
                                buildColumn(),
                                SizedBox(height: 5.h)
                              ],
                            )),
                      ),
                      if (_isLoadMoreRunning == true)
                        const Column(
                          children: [
                            Spacer(),
                            Padding(
                              padding: EdgeInsets.only(top: 10, bottom: 40),
                              child: Center(
                                child: CircularProgressIndicator(color: color.txtBlue),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Positioned(
                    top: -6,
                    child: animatedBanner(context)),
              ],
            ),
          ),
          _searchQuery==""?SizedBox():
          Container(
            margin: const EdgeInsets.only(top: 200),
            padding: const EdgeInsets.only(bottom: 10,top: 5),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: color.txtWhite),
            child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _placeList.length,
                itemBuilder: (context,index){
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            locationController.text=_placeList[index]["description"];
                            LocaleHandler.location=_placeList[index]["description"];
                            _searchQuery="";
                            statesList.clear();
                            FocusManager.instance.primaryFocus?.unfocus();
                          });
                        },
                        child: Container(
                          alignment: Alignment.topLeft,
                          color: Colors.transparent,
                          margin: const EdgeInsets.only(left: 10,right: 10,top: 10),
                          padding: const EdgeInsets.only(left: 8,right: 8,top: 0),
                          // decoration:  BoxDecoration(border: Border(bottom: BorderSide(width: 0.5,color:index==statesList.length-1?color.txtWhite: color.txtBlue))),
                          child:Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(padding: EdgeInsets.only(top: 5),
                                  child: SvgPicture.asset(AssetsPics.locationIcon,width: 14,)),
                              SizedBox(width: 12),
                              Flexible(child: buildText(_placeList[index]["description"],18,FontWeight.w500,color.txtgrey))
                            ],)

                      ),
                      ),
                      index==_placeList.length-1?SizedBox():Divider(thickness: 0.2,)
                    ],
                  );
                }),
          ),
        ],
      )
    );
  }

  Widget searchContainer() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildContainer("Search Location",
            locationController, AutovalidateMode.onUserInteraction, locationNode,
            onChanged: (text){
              LocaleHandler.location=locationController.text.trim();
              // _searchLocations(text);
            },
            gesture: GestureDetector(
                onTap: (){customDialogBoxFilter(context,
                    whiteTap: (){Get.back();
                    date1="Select Date ";date2="Select Date ";
                    },blueTap: (){
                      Get.back();
                      setState(() {LoaderOverlay.show(context);});
                      getEvents();
                    });},
                child: Container(
                    padding: const EdgeInsets.only(top: 5),
                    height: 20,
                    width: 30,
                    alignment: Alignment.center,
                    child: SvgPicture.asset(AssetsPics.filterIcon))),
            preImg: GestureDetector(
                child: Container(
                    padding: const EdgeInsets.only(top: 5),
                    height: 20,
                    width: 30,
                    alignment: Alignment.center,
                    child: SvgPicture.asset(AssetsPics.magniferIcon))),
          ),
        ],
      ),
    );
  }

  Widget animatedBanner(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      height: LocaleHandler.isBanner?110:0,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          SizedBox(width: MediaQuery.of(context).size.width,
              child:LocaleHandler.unMatchedEvent|| LocaleHandler.isThereCancelEvent?
              Image.asset(LocaleHandler.unMatchedEvent? AssetsPics.unMatchedbg:AssetsPics.bookingCanceled,fit: BoxFit.cover):
              Image.asset(AssetsPics.bannerpng,fit: BoxFit.cover)),
          LocaleHandler.subScribtioonOffer?
          Padding(
            padding: const EdgeInsets.only(bottom: 20,top: 30),
            child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: LocaleHandler.isBanner?2.h:0),
                  SvgPicture.asset(AssetsPics.crownwithround),
                  SizedBox(width: LocaleHandler.isBanner?2.h:0),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildText("Slush Silver Subscription", 18, FontWeight.w600, color.txtWhite),
                      Row(children: [
                        buildText("Get 50% off", 15, FontWeight.w600, color.txtWhite),
                        SizedBox(width:  LocaleHandler.isBanner?1.h:0),
                        SvgPicture.asset(AssetsPics.verticaldivider),
                        SizedBox(width:  LocaleHandler.isBanner?1.h:0),
                        buildText("Ends : 00:11:33", 15, FontWeight.w600, color.txtWhite)
                      ],)
                    ],)
                ]),
          )
              : Container(padding: const EdgeInsets.only(top: 30,left: 10,right: 10,bottom: 15),
              child: buildText2(LocaleHandler.isThereCancelEvent?"":LocaleHandler.unMatchedEvent?"":
              "Event starting in 15 minutes, Click Hereto join the waiting room!", 20, FontWeight.w600,color.txtWhite)),
        ],
      ),
    );
  }

  Widget myEventlist() {
   return myEvent==null||myEvent.length==0?const SizedBox(): Column(
     children: [
       Padding(
         padding: const EdgeInsets.only(left: 15,right: 15,top: 10,bottom: 5),
         child: Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
           buildText("My Events", 20, FontWeight.w600, color.txtBlack),
           GestureDetector(onTap: (){
             Get.to(()=> MyEventListScreen(myEvent: true,myEventData: myEvent,pageNum: _page));
           },child: buildText("See More", 14, FontWeight.w600, color.dropDowngreytxt,fontFamily: FontFamily.hellix)),
         ],),
       ),
         SizedBox(
           height: 85,
           child: ListView.builder(scrollDirection: Axis.horizontal,
               itemCount: myEvent.length,
               padding: const EdgeInsets.only(left: 15),
               itemBuilder: (context,index){
                 int timestamp = myEvent[index]["startsAt"];
                 DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
                 String formattedDate = DateFormat('dd MMM').format(dateTime);
                 String formattedTime = DateFormat.jm().format(dateTime);
             return
             GestureDetector(
               onTap: (){
                 setState(() {
                   LocaleHandler.isProtected = myEvent[index]["hasPassword"];
                   LocaleHandler.freeEventImage = myEvent[index]["coverImage"];
                 });
                 Get.to(()=>EventYourTicketScreen(eventId: myEvent[index]["eventId"]));
               },
               child: Container(
                 padding: const EdgeInsets.only(left: 8,top: 5,bottom: 5),
                 margin: const EdgeInsets.only(right: 10),
                 decoration: BoxDecoration(color: color.txtWhite,borderRadius: BorderRadius.circular(8)),
                 child: Column(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     Row(mainAxisSize: MainAxisSize.min,
                       crossAxisAlignment: CrossAxisAlignment.center,
                       children: [
                         imagewithdate(index,formattedDate),
                         const SizedBox(width: 8),
                         details(index,formattedTime)
                       ],),
                   ],),
               ),
             );
           }),
         )
     ],
   );
  }

  Widget imagewithdate(int index,String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 3,top: 3),
      height: 68,
      width: 96,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Stack(children: [
        SizedBox(
            height: 68,
            width: 96,
            // child: Image.asset(historyItem[index].img,fit: BoxFit.fill),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(imageUrl:myEvent[index]["coverImage"],fit: BoxFit.cover,
                placeholder: (ctx,url)=>const Center(child: SizedBox()),
              ))
        ),
        Container(
          margin: const EdgeInsets.only(left: 3,top: 3),
          width: 30,
          decoration: BoxDecoration(color: color.txtWhite,borderRadius: BorderRadius.circular(8)),
          child: buildText2(date, 11, FontWeight.w600, color.txtBlack,fontFamily: FontFamily.hellix),
        ),
      ],),
    );
  }

  Column details(int index,String  time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            width: 180,child: buildTextOverFlow(myEvent[index]["title"], 16, FontWeight.w600, color.txtBlack)),
        Row(children: [
          SvgPicture.asset(AssetsPics.blueMapPoint),
          const SizedBox(width: 4),
          buildTextOverFlow(myEvent[index]["country"], 13, FontWeight.w500, color.txtgrey2,fontFamily: FontFamily.hellix),
        ],),
        Row(children: [
          SvgPicture.asset(AssetsPics.blueClock),
          const SizedBox(width: 4),
          buildTextOverFlow(time, 13, FontWeight.w500, color.txtgrey2,fontFamily: FontFamily.hellix),
        ],),
        const SizedBox(height: 4),
      ],);
  }

  Widget isThereEvent() {
    return Container(
      margin: const EdgeInsets.only(top: 25),
      color: color.lightestBlue,
      child: Stack(
        children: [
          Positioned(
            right: 0.0,
            bottom: 0.50,
            child: SizedBox(
              height: 80,
              width: 60,
              // color: Colors.red,
               child: SvgPicture.asset(AssetsPics.eventflower)),
          ),
          timerWidget(),
          // Positioned(bottom: 0.0,right: 0.0, child: SvgPicture.asset("assets/icons/eventflower.svg")),
        ],
      ),
    );
  }

  Widget timerWidget() {
    String strDigits(int n) => n.toString().padLeft(2, '0');
    String days = strDigits(myDuration.inDays);
    String hours = strDigits(myDuration.inHours.remainder(24));
    String minutes = strDigits(myDuration.inMinutes.remainder(60));
    String seconds = strDigits(myDuration.inSeconds.remainder(60));
    return Container(padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildText("Next event starts in", 18, FontWeight.w600, color.txtBlack),
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),color: color.txtWhite),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 14,top: 14),
                                child: buildText("Friday Frenzy - 5 Dates... ", 18, FontWeight.w600, color.txtBlack),
                              ),
                              const Divider(thickness: 0.8,color: color.lightestBlue),
                           Padding(
                             padding: const EdgeInsets.only(left: 14,right: 14),
                             child: Column(children: [
                               Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                 children: [
                                   buildText("Time Remaining", 16, FontWeight.w600, color.txtBlack),
                                   Container(
                                       padding: const EdgeInsets.only(right: 7),
                                       child: buildText("Deadline", 16, FontWeight.w600, color.txtBlack)),
                                 ],),
                               Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                 children: [
                                 Column(children: [
                                   buildText(days, 24, FontWeight.w600, color.txtBlack),
                                   buildText("Days", 15, FontWeight.w400, color.txtgrey,fontFamily: FontFamily.hellix),
                                 ],),
                                 buildText(":", 24, FontWeight.w600, color.txtBlack),
                                 Column(children: [
                                   buildText(hours, 24, FontWeight.w600, color.txtBlack),
                                   buildText("Hours", 15, FontWeight.w400, color.txtgrey,fontFamily: FontFamily.hellix),
                                 ],),
                                 buildText(":", 24, FontWeight.w600, color.txtBlack),
                                 Column(children: [
                                   buildText(minutes, 24, FontWeight.w600, color.txtBlack),
                                   buildText("Minutes", 15, FontWeight.w400, color.txtgrey,fontFamily: FontFamily.hellix),
                                 ],),
                                 Container(
                                   height: 40,width: 2,
                                   decoration: BoxDecoration(color: color.hieghtGrey,
                                     borderRadius: BorderRadius.circular(12)
                                   ),
                                 ),
                                 Column(children: [
                                   buildText("19", 24, FontWeight.w600, color.txtBlack),
                                   buildText("December", 15, FontWeight.w400, color.txtgrey,fontFamily: FontFamily.hellix),
                                 ],),
                               ],),
                               Row(
                                 crossAxisAlignment: CrossAxisAlignment.center,
                                 mainAxisAlignment: MainAxisAlignment.end,
                                 children: [
                                 buildText("Unable to attend", 16, FontWeight.w600, color.txtBlack),
                                 GestureDetector(
                                   onTap: (){
                                     setState(() {
                                       startTimer();
                                       LocaleHandler.isBanner=false;
                                     });
                                     customDialogBox(context: context, title: "Coming soon", heading: "Events specific to this category coming soon",
                                     btnTxt: "Ok",img: AssetsPics.comingsoonpng,secontxt: "",isPng: true);
                                   },
                                   child: Container(
                                     padding: const EdgeInsets.only(left: 16,right: 16,top: 4,bottom: 4),
                                     margin: const EdgeInsets.only(left: 10,bottom: 14,top: 14),
                                     alignment: Alignment.center,
                                     decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
                                         gradient:  const LinearGradient(
                                           begin: Alignment.bottomCenter,
                                           end: Alignment.topCenter,
                                           colors: [
                                             color.gradientLightBlue,
                                             color.txtBlue
                                           ],
                                         )
                                     ),
                                     child: buildText("Join",18,FontWeight.w600,color.txtWhite),
                                   ),
                                 ),
                               ],),
                             ],),
                           )
                            ],),
                          )
                        ],
                      ),
                    );
  }

  String printme(String text) {
    List<String> splitList = text.split(',');
    int startIndex = splitList.length - 2;
    if (startIndex < 0) {
      return "============== No Sufficient Commas ==============";
    } else {
      return splitList.getRange(startIndex, splitList.length).join(',');
    }
  }

  Widget buildProfileSection() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 20),
      child: Row(
        children: [
          SizedBox(
            height: 50,
            width: 50,
            child:LocaleHandler.avatar==""? Image.asset(AssetsPics.demouser, fit: BoxFit.fill):
             ClipRRect(
                 borderRadius: BorderRadius.circular(8),
                 child: CachedNetworkImage(imageUrl:LocaleHandler.avatar , fit: BoxFit.fill,
                   placeholder: (ctx,url)=>const Center(child: SizedBox()),)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: MediaQuery.of(context).size.width/2,child: buildTextOverFlow(LocaleHandler.name==""?"":LocaleHandler.name, 20, FontWeight.w600, color.txtBlack)),
                SizedBox(width: MediaQuery.of(context).size.width/2,child: buildTextOverFlow(location, 13, FontWeight.w500, color.txtgrey2, fontFamily: FontFamily.hellix)),
                // buildText(printme(LocaleHandler.location), 13, FontWeight.w500, color.txtgrey, fontFamily: FontFamily.hellix),
                // buildText(userData["address"], 13, FontWeight.w500, color.txtgrey, fontFamily: FontFamily.hellix),
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
              onTap: (){Get.to(()=>const EventHistoryScreen());},
              child: SvgPicture.asset(AssetsPics.historyIcon)),
          const SizedBox(width: 10),
          GestureDetector(
              onTap: (){Get.to(()=>const NotificationScreen());}
              ,child: SvgPicture.asset(AssetsPics.notificationIcon)),
        ],
      ),
    );
  }

  Widget categoryList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 15,right: 15),
          child: buildText("Categories", 20, FontWeight.w600, color.txtBlack),
        ),
        Row(
          children: [
            SizedBox(
              height: 120,
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  padding: const EdgeInsets.only(left: 15, top: 5),
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 18),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: (){
                              setState(() {selectedIndex=index;
                              selectedIndexItem=items[index].title;
                              getEvents();
                              });
                              if(index==0){// customReelBoxFilter(context);
                              } else if(index==1){
                                // customRatingSheet(context: context, title: " How's your\nexperience so far?", heading: "We'd love to know!",);
                              }
                              else if(index==2){// Get.to(()=>const EvenetSuscribeScreen());
                              }},
                            child: CircleAvatar(
                              radius: 34,
                              backgroundColor: color.txtWhite,
                              child: SvgPicture.asset(selectedIndex==index?items[index].selectedImg: items[index].img),
                            ),
                          ),
                          const SizedBox(height: 8),
                          buildText(items[index].title, 15, FontWeight.w500,
                              color.txtgrey2, fontFamily: FontFamily.hellix)
                        ],
                      ),
                    );
                  }),
            )
          ],
        ),
      ],
    );
  }

List<dynamic> itemList=[];

  void searchQuery(){
    if(searchController.text==""){
      itemList.clear();
    }
    else {
      itemList = data["items"].where((element) => element["title"].toString().toLowerCase().contains(
              searchController.text.toLowerCase())).toList();
    }print(itemList);
  }

  Widget buildColumn() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 30),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildText("Upcoming Events", 20, FontWeight.w600, color.txtBlack),
              GestureDetector(
                onTap: (){ Get.to(()=> MyEventListScreen(myEvent: false,myEventData: myEvent,pageNum: _page));},
                child: buildText("See More", 14, FontWeight.w600, color.dropDowngreytxt,
                    fontFamily: FontFamily.hellix),
              ),
            ],
          ),
          const SizedBox(height: 15),
         data==null?const CircularProgressIndicator(color: color.txtBlue,):data=="no data"?Center(child: buildText("no data!",18,FontWeight.w500,color.txtgrey),):
         ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
             // controller: _controller,
              // itemCount: eventItem.length,
              itemCount:itemList.isEmpty? post.length:itemList.length,
             itemBuilder: (context,index){
              var item=itemList.isEmpty?post:itemList;
              String type=item[index]["gender"].toString().toLowerCase();
              String typename=type=="straight"?"Straight": type=="lesbian"?"Lesbian": type=="queer"?"Queer": type=="transgender"?"Transgender": type=="gay"?"Gay":"Bisexual";
              int timestamp = item[index]["startsAt"];
              DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
              String formattedDate = DateFormat('dd MMM').format(dateTime);
              String formattedTime = DateFormat.jm().format(dateTime);
              String maleseats = getTotalMale(index,item)=="0"?"Full":"Available";
              String femaleseats = getTotalFemale(index,item)=="0"?"Full":"Available";
            return  Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: (){setState(() {
                    LocaleHandler.isProtected = item[index]["hasPassword"];
                    LocaleHandler.freeEventImage = item[index]["coverImage"];});
                  bool isParticipant=false;
                  var dataa=item[index]["participants"];
                  var i;
                  for(i=0;i<dataa.length;i++)
                  {if(dataa[i]["user"]["userId"].toString()==LocaleHandler.userId){
                    setState(() {isParticipant=true;});break;}
                  }
                  if(isParticipant){Get.to(()=>EventYourTicketScreen(eventId: item[index]["eventId"]))!.then((value) {setState(() {});});
                  }else{
                    callNavigation(item,index);
                    // if(userSexuality!=item[index]["gender"]) {showToastMsg("This event is not for you");} else
                    //   if(usergender=="male"){
                    //   if(maleseats=="Available"){callNavigation(item,index);}
                    // } else if(usergender=="female") {
                    //   if(femaleseats=="Available"){callNavigation(item,index);}
                    // }else{callNavigation(item,index);}
                  }
                },
                child:searchController.text==""?
                eventList(context, item, index, type, typename, formattedDate, formattedTime, maleseats, femaleseats):
                    itemList.isNotEmpty?
                eventList(context, itemList, index, type, typename, formattedDate, formattedTime, maleseats, femaleseats):
                const SizedBox(),
              ),
            );
          }),

        ],
      ),
    );
  }

  Widget eventList(BuildContext context, item, int index, String type, String typename, String formattedDate, String formattedTime, String maleseats, String femaleseats) {
    final eventCntrller=Provider.of<eventController>(context,listen: false);
    return Stack(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 306,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(imageUrl:item[index]["coverImage"], fit: BoxFit.cover,
                        placeholder: (ctx,url)=>const Center(child: SizedBox()),)),
                  ),
                  IgnorePointer(child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      // height: 306,
                      child: ClipRRect(borderRadius: BorderRadius.circular(12),child: SvgPicture.asset(AssetsPics.eventbg,fit: BoxFit.cover)))),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                    color: color.txtWhite,
                                    borderRadius: BorderRadius.circular(4)
                                ),
                                height: 24,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                // width: 107,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    buildText("Age group: ", 12, FontWeight.w500, color.txtBlack, fontFamily: FontFamily.hellix),
                                    buildText("${item[index]["minAge"]}-${item[index]["maxAge"]}", 12, FontWeight.w600, color.txtBlack, fontFamily: FontFamily.hellix),
                                  ],
                                )),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(left: 7,right: 7),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                      color: type=="straight"?color.straight:
                                      type=="lesbian"?color.lesbian: type=="queer"?color.queer:
                                      type=="transgender"?color.transgender: type=="gay"?color.gay:color.bisexual
                                    ),
                                    height: 24,
                                    child: buildText(typename, 13, FontWeight.w500, color.txtWhite, fontFamily: FontFamily.hellix)),
                                item[index]["hasPassword"]? CircleAvatar(
                                  radius: 15,
                                  backgroundColor: color.txtWhite,
                                  child: SvgPicture.asset(AssetsPics.lock),
                                ):const SizedBox()
                              ],
                            )
                          ],
                        ),
                        Container(height:item[index]["hasPassword"]?112:142),
                        Container(
                          height: 106,
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 6.5),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color:  const Color.fromRGBO(255, 255, 255, 0.5)
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 3),
                                  width: 46,
                                  decoration: BoxDecoration(color: color.txtWhite,borderRadius: BorderRadius.circular(8)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      buildText2(formattedDate, 16, FontWeight.w600, color.txtBlack,fontFamily: FontFamily.hellix),
                                      // buildText("Nov", 16, FontWeight.w600, color.txtBlack,fontFamily: FontFamily.hellix),
                                    ],),
                                ),
                                const SizedBox(width: 9),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width/1.9,
                                    child: buildTextOverFlow(
                                        item[index]["title"]+" - "+item[index]["type"],
                                        16, FontWeight.w700, color.txtWhite),
                                  ),
                                  Row(children: [
                                    SvgPicture.asset(AssetsPics.whitemappoint),
                                    const SizedBox(width: 3),
                                    SizedBox(
                                      // color: Colors.red,
                                        width: 100,
                                        child: buildTextOverFlow(item[index]["country"], 15.sp, FontWeight.w500, color.txtWhite,fontFamily: FontFamily.hellix)),
                                    const SizedBox(width: 8),
                                    SvgPicture.asset(AssetsPics.whitewatch),
                                    const SizedBox(width: 3),
                                    buildText(formattedTime, 15.sp, FontWeight.w500, color.txtWhite,fontFamily: FontFamily.hellix),
                                    // buildText("12:00 PM", 15.sp, FontWeight.w500, color.txtWhite,fontFamily: FontFamily.hellix),
                                  ],)
                                ],),
                                const Spacer(),
                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      // savedEvent=!savedEvent;
                                      if(LocaleHandler.items.contains(item[index]["eventId"]))
                                        {eventCntrller.saveEvent(ApiList.unsaveEvent, item[index]["eventId"].toString());
                                          LocaleHandler.items.remove(item[index]["eventId"]);}
                                      else{
                                        eventCntrller.saveEvent(ApiList.saveEvent, item[index]["eventId"].toString());
                                        LocaleHandler.items.add(item[index]["eventId"]);}
                                      Preferences.setValue("EventIds", jsonEncode(LocaleHandler.items));
                                    });
                                  },
                                  child: CircleAvatar(radius: 16.3,
                                    backgroundColor: color.txtWhite,
                                    child: SvgPicture.asset(LocaleHandler.items.contains(item[index]["eventId"])?AssetsPics.eventbluesaved:AssetsPics.greysaved,height: 16),//eventbluesaved
                                  ),
                                )
                              ],),
                            const SizedBox(height: 8),
                            Row(children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7,vertical: 3),
                                decoration: BoxDecoration(color: color.txtWhite,
                                    borderRadius: BorderRadius.circular(18)
                                ),
                                child: Row(children: [
                                  SvgPicture.asset(AssetsPics.man),
                                  const SizedBox(width: 5),
                                  buildText(maleseats, 13, FontWeight.w500, color.txtBlack,fontFamily: FontFamily.hellix)
                                ],),),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7,vertical: 3),
                                decoration: BoxDecoration(color: color.txtWhite,
                                    borderRadius: BorderRadius.circular(18)
                                ),
                                child: Row(children: [
                                  SvgPicture.asset(AssetsPics.woman),
                                  const SizedBox(width: 4),
                                  buildText(femaleseats, 13, FontWeight.w500, color.txtBlack,fontFamily: FontFamily.hellix)
                                ],),),
                              const Spacer(),
                              Row(children: [
                                buildText("Available : ", 14, FontWeight.w400, color.txtWhite,fontFamily: FontFamily.hellix),
                                // buildText("2", 14, FontWeight.w600, color.txtWhite,fontFamily: FontFamily.hellix),
                                buildText(getAvailable(index,item), 14, FontWeight.w600, color.txtWhite,fontFamily: FontFamily.hellix),
                              ],),
                            ],),
                          ],),
                        )
                      ],
                    ),
                  )
                ],
              );
  }

  void callNavigation(dynamic item ,int i){
    if(age>=item[i]["minAge"]){
      if(age<=item[i]["maxAge"]){Get.to(()=>EvenetFreeScreen(eventId: item[i]["eventId"]))!.then((value) {setState(() {});});}
      else{Fluttertoast.showToast(msg: "You are too Old for this Event");}
    }else{Fluttertoast.showToast(msg: "You are too Young for this Event");}
  }

  String getAvailable(int i,item){
    var total=post[i]["totalParticipants"]-post[i]["participants"].length;
    print(total);
    return total.toString();
  }

  String getTotalMale(int i,item){
    var total=post[i]["maleParticipants"];
    int malecount=0;
    for(var ii=0;ii<post[i]["participants"].length;ii++){
      if(post[i]["participants"][ii]["user"]["gender"]=="male"){malecount=malecount+1;}
    }
    total=total-malecount;
    print(total);
    return total.toString();
  }

  String getTotalFemale(int i,item){
    var total=post[i]["femaleParticipants"];
    int malecount=0;
    for(var ii=0;ii<post[i]["participants"].length;ii++){
      if(post[i]["participants"][ii]["user"]["gender"]=="female"){malecount=malecount+1;}
    }
    total=total-malecount;
    print(total);
    return total.toString();
  }


  Widget buildContainer(String txt,
      TextEditingController controller,
      AutovalidateMode auto, FocusNode node,
      {FormFieldValidator<String>? validation,
        VoidCallback? press,
        GestureDetector? gesture,
        GestureDetector? preImg,
        final ValueChanged<String>? onChanged,}) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        // padding: const EdgeInsets.only(left: 10),
        height: 56,
        margin: const EdgeInsets.only(top: 20),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: color.txtWhite,
            borderRadius: BorderRadius.circular(12),
            // border: Border.all(color:enableField == txt? color.txtBlue:color.txtWhite, width:1)
            border: Border.all(color: color.txtWhite, width: 1)),
        child: TextFormField(
          onChanged: (value){
            setState(() {
              _searchQuery = value;
            });
          },
          textInputAction: TextInputAction.done,
          onTap: press,
          focusNode: node,
          controller: controller,
          cursorColor: color.txtBlue,
          autovalidateMode: auto,
          validator: validation,
          decoration: InputDecoration(
              errorStyle: const TextStyle(height: 0, fontSize: 12),
              border: InputBorder.none,
              hintText: txt,
              hintStyle: const TextStyle(
                  fontFamily: FontFamily.hellix, fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color.txtBlack),
              contentPadding:
              const EdgeInsets.only(left: 20, right: 18, top: 12),
              suffixIcon: gesture,
              prefixIcon: preImg),
        ),
      ),
    );
  }
}


class CircleAvatarItems {
  int Id;
  String img;
  String selectedImg;
  String title;
  CircleAvatarItems(this.Id, this.title, this.img,this.selectedImg);
}

class Locations {
  final String name;
  final String address;
  Locations({required this.name, required this.address});
  factory Locations.fromJson(Map<String, dynamic> json) => Locations(
    name: json['name'],
    address: json['address'],
  );
}


/*
import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart'as http;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/loader.dart';
import 'package:slush/constants/prefs.dart';
import 'package:slush/controller/controller.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/screens/events/event_list.dart';
import 'package:slush/screens/events/event_subscribe.dart';
import 'package:slush/screens/events/eventhistory.dart';
import 'package:slush/screens/events/free_event.dart';
import 'package:slush/screens/events/you_ticket.dart';
import 'package:slush/screens/login/login.dart';
import 'package:slush/screens/notification/notification_screen.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:slush/widgets/toaster.dart';
import 'package:intl/intl.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({Key? key}) : super(key: key);

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  TextEditingController searchController = TextEditingController();
  FocusNode searchNode = FocusNode();
  Timer? countdownTimer;
  Duration myDuration = const Duration(days: 5);
  var secondsss = "00";
  int selectedIndex=0;
  String usergender="";
  String userSexuality="";
  bool _isLoadMoreRunning=false;
  String location="";

  List<CircleAvatarItems> items = [
    CircleAvatarItems(1, "Music", AssetsPics.music,AssetsPics.selectmusic),
    CircleAvatarItems(2, "Sport", AssetsPics.sport,AssetsPics.selectsport),
    CircleAvatarItems(3, "Food", AssetsPics.food,AssetsPics.selectfood),
    CircleAvatarItems(4, "Business", AssetsPics.business,AssetsPics.selectbusiness),
    CircleAvatarItems(5, "Music", AssetsPics.music,AssetsPics.selectmusic),
    CircleAvatarItems(5, "Music", AssetsPics.music,AssetsPics.selectmusic),
    CircleAvatarItems(5, "Music", AssetsPics.music,AssetsPics.selectmusic),
  ];

  late ScrollController _controller;
  // int _value=100;
  List gender = ["Male", "Female", "Everyone"];
  bool isChecked = false;
  bool savedEvent=false;



  @override
  void initState() {
    _getCurrentPosition();
    profileData();
    checkBannerStatus();
    getEvents();
    _controller = ScrollController()..addListener(loadmore);
    super.initState();
  }


  // Animated to container
  void checkBannerStatus(){
  if(LocaleHandler.isThereAnyEvent){
    startTimer();
    futuredelayed(1, true);
    futuredelayed(3, false);
  }
  // else if(LocaleHandler.isThereCancelEvent){
  //   futuredelayed(1, true);
  //   futuredelayed(3, false);
  //   LocaleHandler.isThereCancelEvent=false;}
  else if(LocaleHandler.unMatchedEvent){
    futuredelayed(1, true);
    futuredelayed(3, false);
  }
  else if(LocaleHandler.subScribtioonOffer){
    futuredelayed(1, true);
    futuredelayed(3, false);
  }
  else{
   setState(() {LocaleHandler.isBanner=false;});
  }
}

  void futuredelayed(int i,bool val){
    Future.delayed(Duration(seconds: i),(){
      setState(() {
        LocaleHandler.isBanner=val;
      });});
  }

  // Event Timer
  void setCountDown() {
    const reduceSecondsBy = 1;
    setState(() {
      final seconds = myDuration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {countdownTimer!.cancel();
      } else {
        myDuration = Duration(seconds: seconds);
        setState(() {
          secondsss = myDuration.inSeconds.remainder(60).toString();
        });
      }
    });
  }

  void startTimer() {countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());}

  // hit get EVents
  var data;
  List post=[];
  int _page = 1;
  var myEvent=null;
  bool eventStored=false;
  int totalpages=0;
  int currentpage=0;
  bool _hasNextPage = true;


  Future getEvents()async{
  // final url="${ApiList.getEvent}${LocaleHandler.userId}&distance=5000&events=popular&latitude=30.6990901&longitude=76.6913955&page=1&limit=15";
  final url=// LocaleHandler.latitude==""?"${ApiList.getEvent}${LocaleHandler.userId}&distance=${LocaleHandler.distancee}&events=popular":
  "${ApiList.getEvent}${LocaleHandler.miliseconds}&distance=${LocaleHandler.distancee}&events=popular&latitude=${LocaleHandler.latitude}&longitude=${LocaleHandler.longitude}&page=$_page&limit=10";
  print(url);
  var uri=Uri.parse(url);
  var response=await http.get(uri,
  headers: {'Content-Type':'application/json', 'Authorization':'Bearer ${LocaleHandler.accessToken}'});
  if(response.statusCode==200){print(response.statusCode);
  setState(() {data=jsonDecode(response.body)["data"];
  totalpages=data["meta"]["totalPages"];
  currentpage=data["meta"]["currentPage"];
  post=data["items"];
  });
  List<Map<String, dynamic>> j=[];
  for(var i=0;i<data["items"].length;i++){
    for(var ii=0;ii<data["items"][i]["participants"].length;ii++){
      if(data["items"][i]["participants"][ii]["user"]["userId"].toString()==LocaleHandler.userId){
        j.add(data["items"][i]);
      }
    }
  }    setState(() {LoaderOverlay.hide();});
  if(eventStored==false){myEvent=j;eventStored=true;}}
  else if(response.statusCode==401){showToastMsgTokenExpired();}
  else{Fluttertoast.showToast(msg: 'Something Went Wrong');
  setState(() {data="no data";});
  }}

  Future loadmore()async{
    // setState(() {LoaderOverlay.show(context);});
    if (_page<totalpages&&
    _hasNextPage == true &&  _isLoadMoreRunning == false && currentpage<totalpages&& _controller.position.extentAfter < 300) {
      setState(() {_isLoadMoreRunning=true;});
    _page=_page+1;
      final url="${ApiList.getEvent}${LocaleHandler.miliseconds}&distance=${LocaleHandler.distancee}&events=popular&latitude=${LocaleHandler.latitude}&longitude=${LocaleHandler.longitude}&page=$_page&limit=10";
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

          List<Map<String, dynamic>> j=myEvent;
          for(var i=0;i<data["items"].length;i++){
            for(var ii=0;ii<data["items"][i]["participants"].length;ii++){
              if(data["items"][i]["participants"][ii]["user"]["userId"].toString()==LocaleHandler.userId){
                j.add(data["items"][i]);
              }
            }
          }
          myEvent=j;
          // if(eventStored==false){myEvent=j;eventStored=true;}
        });
      }}
    setState(() {LoaderOverlay.hide();});
  }

  // location
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  String latitude = "";
  String longitude = "";

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handlePermission();
    if (!hasPermission) {
      Fluttertoast.showToast(msg: "Location permission is neccessary");
      // Get.offAll(const LoginScreen());
      // exit(0);
      // SystemNavigator.pop();
    }
    final position = await _geolocatorPlatform.getCurrentPosition();
    latitude = position.latitude.toString();
    longitude = position.longitude.toString();
    Provider.of<nameControllerr>(context,listen: false).setLocation(latitude, longitude);
    getEvents();
    updaetLocation();
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {return false;}
    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {return false;}
    }
    if (permission == LocationPermission.deniedForever) {return false;}
    return true;
  }

  Future updaetLocation()async{
    const url=ApiList.location;
    var uri=Uri.parse(url);
    var response=await http.post(uri,
        headers: <String,String>{
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${LocaleHandler.accessToken}"
        },body: jsonEncode({"latitude":latitude, "longitude":longitude})
    );
    if(response.statusCode==200){
      // Fluttertoast.showToast(msg: "Internal Server error");
    }else if(response.statusCode==401){
      showToastMsgTokenExpired();
    }
    else{
      Fluttertoast.showToast(msg: "Internal Server error");
    }
  }

  // Get Profile
  int age=0;
  var userData;
  Future profileData() async {
    final url = ApiList.getUser + LocaleHandler.userId;
    print(url);
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${LocaleHandler.accessToken}'
      });
      if (response.statusCode == 200) {
        setState(() {
          Map<String,dynamic> data = jsonDecode(response.body);
          userData=data["data"];
          age= calculateAge(data["data"]["dateOfBirth"].toString());
          usergender=userData["gender"];
          location=userData["state"]+", "+userData["country"];
          LocaleHandler.gender=usergender;
          userSexuality=userData["sexuality"];
        });
      } else if (response.statusCode == 401) {showToastMsgTokenExpired();
      print('Token Expire:::::::::::::');
      } else {print('Failed to Load Data With Status Code ${response.statusCode}');
      throw Exception('Failed to load data');}
    } catch (e) {throw Exception('Failed to fetch data: $e');}
  }

  int calculateAge(String dobString) {
    DateTime dob = DateTime.parse(dobString);
    DateTime now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Scaffold(
      // backgroundColor: color.backGroundClr,
      body: Stack(
        children: [
          SizedBox(height: size.height, width: size.width, child: Image.asset(AssetsPics.background,fit: BoxFit.cover),),
          SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  controller: _controller,
                  child: Center(
                      child: Column(
                    children: [
                      Stack(
                        children: [
                          buildProfileSection(),
                          // animatedBanner(context)
                        ],
                      ),
                      searchContainer(),
                      LocaleHandler.isThereAnyEvent? isThereEvent():const SizedBox(),
                      // LocaleHandler.isThereAnyEvent? myEventlist():const SizedBox(),
                      myEventlist(),
                      categoryList(context),
                      buildColumn(),
                      SizedBox(height: 5.h)
                    ],
                  )),
                ),
                if (_isLoadMoreRunning == true)
                  Column(
                    children: [
                      Spacer(),
                      const Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 40),
                        child: Center(
                          child: CircularProgressIndicator(color: color.txtBlue),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Positioned(
              top: -6,
              child: animatedBanner(context)),
        ],
      ),
    );
  }

  Widget animatedBanner(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      height: LocaleHandler.isBanner?110:0,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          SizedBox(width: MediaQuery.of(context).size.width,
              child:LocaleHandler.unMatchedEvent|| LocaleHandler.isThereCancelEvent?
              Image.asset(LocaleHandler.unMatchedEvent? AssetsPics.unMatchedbg:AssetsPics.bookingCanceled,fit: BoxFit.cover):
              Image.asset(AssetsPics.bannerpng,fit: BoxFit.cover)),
          LocaleHandler.subScribtioonOffer?
          Padding(
            padding: const EdgeInsets.only(bottom: 20,top: 30),
            child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: LocaleHandler.isBanner?2.h:0),
                  SvgPicture.asset(AssetsPics.crownwithround),
                  SizedBox(width: LocaleHandler.isBanner?2.h:0),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildText("Slush Silver Subscription", 18, FontWeight.w600, color.txtWhite),
                      Row(children: [
                        buildText("Get 50% off", 15, FontWeight.w600, color.txtWhite),
                        SizedBox(width:  LocaleHandler.isBanner?1.h:0),
                        SvgPicture.asset(AssetsPics.verticaldivider),
                        SizedBox(width:  LocaleHandler.isBanner?1.h:0),
                        buildText("Ends : 00:11:33", 15, FontWeight.w600, color.txtWhite)
                      ],)
                    ],)
                ]),
          )
              : Container(padding: const EdgeInsets.only(top: 30,left: 10,right: 10,bottom: 15),
              child: buildText2(LocaleHandler.isThereCancelEvent?"":LocaleHandler.unMatchedEvent?"":
              "Event starting in 15 minutes, Click Hereto join the waiting room!", 20, FontWeight.w600,color.txtWhite)),
        ],
      ),
    );
  }

  Widget myEventlist() {
   return myEvent==null||myEvent.length==00?const SizedBox(): Column(
     children: [
       Padding(
         padding: const EdgeInsets.only(left: 15,right: 15,top: 10,bottom: 5),
         child: Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
           buildText("My Events", 20, FontWeight.w600, color.txtBlack),
           GestureDetector(onTap: (){
             Get.to(()=> MyEventListScreen(myEvent: true,myEventData: myEvent));
           },child: buildText("See More", 14, FontWeight.w600, color.dropDowngreytxt,fontFamily: FontFamily.hellix)),
         ],),
       ),
         SizedBox(
           height: 85,
           child: ListView.builder(scrollDirection: Axis.horizontal,
               itemCount: myEvent.length,
               padding: const EdgeInsets.only(left: 15),
               itemBuilder: (context,index){
                 int timestamp = myEvent[index]["startsAt"];
                 DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
                 String formattedDate = DateFormat('dd MMM').format(dateTime);
                 String formattedTime = DateFormat.jm().format(dateTime);
             return
             GestureDetector(
               onTap: (){
                 setState(() {
                   LocaleHandler.isProtected = myEvent[index]["hasPassword"];
                   LocaleHandler.freeEventImage = myEvent[index]["coverImage"];
                 });
                 Get.to(()=>EventYourTicketScreen(eventId: myEvent[index]["eventId"]));
               },
               child: Container(
                 padding: const EdgeInsets.only(left: 8,top: 5,bottom: 5),
                 margin: const EdgeInsets.only(right: 10),
                 decoration: BoxDecoration(color: color.txtWhite,borderRadius: BorderRadius.circular(8)),
                 child: Column(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     Row(mainAxisSize: MainAxisSize.min,
                       crossAxisAlignment: CrossAxisAlignment.center,
                       children: [
                         imagewithdate(index,formattedDate),
                         const SizedBox(width: 8),
                         details(index,formattedTime)
                       ],),
                   ],),
               ),
             );
           }),
         )
     ],
   );
  }

  Widget imagewithdate(int index,String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 3,top: 3),
      height: 68,
      width: 96,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Stack(children: [
        SizedBox(
            height: 68,
            width: 96,
            // child: Image.asset(historyItem[index].img,fit: BoxFit.fill),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(imageUrl:myEvent[index]["coverImage"],fit: BoxFit.cover, ))
        ),
        Container(
          margin: const EdgeInsets.only(left: 3,top: 3),
          width: 30,
          decoration: BoxDecoration(color: color.txtWhite,borderRadius: BorderRadius.circular(8)),
          child: buildText2(date, 11, FontWeight.w600, color.txtBlack,fontFamily: FontFamily.hellix),
        ),
      ],),
    );
  }

  Column details(int index,String  time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            width: 180,child: buildTextOverFlow(myEvent[index]["title"], 16, FontWeight.w600, color.txtBlack)),
        Row(children: [
          SvgPicture.asset(AssetsPics.blueMapPoint),
          const SizedBox(width: 4),
          buildTextOverFlow(myEvent[index]["country"], 13, FontWeight.w500, color.txtgrey2,fontFamily: FontFamily.hellix),
        ],),
        Row(children: [
          SvgPicture.asset(AssetsPics.blueClock),
          const SizedBox(width: 4),
          buildTextOverFlow(time, 13, FontWeight.w500, color.txtgrey2,fontFamily: FontFamily.hellix),
        ],),
        const SizedBox(height: 4),
      ],);
  }

  Widget isThereEvent() {
    return Container(
      margin: const EdgeInsets.only(top: 25),
      color: color.lightestBlue,
      child: Stack(
        children: [
          Positioned(
            right: 0.0,
            bottom: 0.50,
            child: SizedBox(
              height: 80,
              width: 60,
              // color: Colors.red,
               child: SvgPicture.asset(AssetsPics.eventflower)),
          ),
          timerWidget(),
          // Positioned(bottom: 0.0,right: 0.0, child: SvgPicture.asset("assets/icons/eventflower.svg")),
        ],
      ),
    );
  }

  Widget timerWidget() {
    String strDigits(int n) => n.toString().padLeft(2, '0');
    String days = strDigits(myDuration.inDays);
    String hours = strDigits(myDuration.inHours.remainder(24));
    String minutes = strDigits(myDuration.inMinutes.remainder(60));
    String seconds = strDigits(myDuration.inSeconds.remainder(60));
    return Container(padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildText("Next event starts in", 18, FontWeight.w600, color.txtBlack),
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),color: color.txtWhite),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 14,top: 14),
                                child: buildText("Friday Frenzy - 5 Dates... ", 18, FontWeight.w600, color.txtBlack),
                              ),
                              const Divider(thickness: 0.8,color: color.lightestBlue),
                           Padding(
                             padding: const EdgeInsets.only(left: 14,right: 14),
                             child: Column(children: [
                               Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                 children: [
                                   buildText("Time Remaining", 16, FontWeight.w600, color.txtBlack),
                                   Container(
                                       padding: const EdgeInsets.only(right: 7),
                                       child: buildText("Deadline", 16, FontWeight.w600, color.txtBlack)),
                                 ],),
                               Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                 children: [
                                 Column(children: [
                                   buildText(days, 24, FontWeight.w600, color.txtBlack),
                                   buildText("Days", 15, FontWeight.w400, color.txtgrey,fontFamily: FontFamily.hellix),
                                 ],),
                                 buildText(":", 24, FontWeight.w600, color.txtBlack),
                                 Column(children: [
                                   buildText(hours, 24, FontWeight.w600, color.txtBlack),
                                   buildText("Hours", 15, FontWeight.w400, color.txtgrey,fontFamily: FontFamily.hellix),
                                 ],),
                                 buildText(":", 24, FontWeight.w600, color.txtBlack),
                                 Column(children: [
                                   buildText(minutes, 24, FontWeight.w600, color.txtBlack),
                                   buildText("Minutes", 15, FontWeight.w400, color.txtgrey,fontFamily: FontFamily.hellix),
                                 ],),
                                 Container(
                                   height: 40,width: 2,
                                   decoration: BoxDecoration(color: color.hieghtGrey,
                                     borderRadius: BorderRadius.circular(12)
                                   ),
                                 ),
                                 Column(children: [
                                   buildText("19", 24, FontWeight.w600, color.txtBlack),
                                   buildText("December", 15, FontWeight.w400, color.txtgrey,fontFamily: FontFamily.hellix),
                                 ],),
                               ],),
                               Row(
                                 crossAxisAlignment: CrossAxisAlignment.center,
                                 mainAxisAlignment: MainAxisAlignment.end,
                                 children: [
                                 buildText("Unable to attend", 16, FontWeight.w600, color.txtBlack),
                                 GestureDetector(
                                   onTap: (){
                                     setState(() {
                                       startTimer();
                                       LocaleHandler.isBanner=false;
                                     });
                                     customDialogBox(context: context, title: "Coming soon", heading: "Events specific to this category coming soon",
                                     btnTxt: "Ok",img: AssetsPics.comingsoonpng,secontxt: "",isPng: true);
                                   },
                                   child: Container(
                                     padding: const EdgeInsets.only(left: 16,right: 16,top: 4,bottom: 4),
                                     margin: const EdgeInsets.only(left: 10,bottom: 14,top: 14),
                                     alignment: Alignment.center,
                                     decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
                                         gradient:  const LinearGradient(
                                           begin: Alignment.bottomCenter,
                                           end: Alignment.topCenter,
                                           colors: [
                                             color.gradientLightBlue,
                                             color.txtBlue
                                           ],
                                         )
                                     ),
                                     child: buildText("Join",18,FontWeight.w600,color.txtWhite),
                                   ),
                                 ),
                               ],),
                             ],),
                           )
                            ],),
                          )
                        ],
                      ),
                    );
  }
  String printme(String text) {
    List<String> splitList = text.split(',');
    int startIndex = splitList.length - 2;
    if (startIndex < 0) {
      return "============== No Sufficient Commas ==============";
    } else {
      return splitList.getRange(startIndex, splitList.length).join(',');
    }
  }
  Widget buildProfileSection() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 20),
      child: Row(
        children: [
          SizedBox(
            height: 50,
            width: 50,
            child:LocaleHandler.avatar==""? Image.asset(AssetsPics.demouser, fit: BoxFit.fill):
             ClipRRect(
                 borderRadius: BorderRadius.circular(8),
                 child: CachedNetworkImage(imageUrl:LocaleHandler.avatar ,fit: BoxFit.cover,)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildText(LocaleHandler.name==""?"[UserNAme]":LocaleHandler.name, 20, FontWeight.w600, color.txtBlack),
                buildText(location, 13, FontWeight.w500, color.txtgrey, fontFamily: FontFamily.hellix),
                // buildText(printme(LocaleHandler.location), 13, FontWeight.w500, color.txtgrey, fontFamily: FontFamily.hellix),
                // buildText(userData["address"], 13, FontWeight.w500, color.txtgrey, fontFamily: FontFamily.hellix),
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
              onTap: (){Get.to(()=>const EventHistoryScreen());},
              child: SvgPicture.asset(AssetsPics.historyIcon)),
          const SizedBox(width: 10),
          GestureDetector(
              onTap: (){
                Get.to(()=>const NotificationScreen());
              }
              ,child: SvgPicture.asset(AssetsPics.notificationIcon)),
        ],
      ),
    );
  }

  Widget searchContainer() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildContainer("Search Location",
            searchController, searchNode,
            gesture: GestureDetector(
              onTap: (){customDialogBoxFilter(context,
                  whiteTap: (){Get.back();
                  date1="Select Date ";date2="Select Date ";
                  },blueTap: (){
                Get.back();
                setState(() {LoaderOverlay.show(context);});
                getEvents();
              });},
                child: Container(
                    padding: const EdgeInsets.only(top: 5),
                    height: 20,
                    width: 30,
                    alignment: Alignment.center,
                    child: SvgPicture.asset(AssetsPics.filterIcon))),
            preImg: GestureDetector(
                child: Container(
                    padding: const EdgeInsets.only(top: 5),
                    height: 20,
                    width: 30,
                    alignment: Alignment.center,
                    child: SvgPicture.asset(AssetsPics.magniferIcon))),
          ),
        ],
      ),
    );
  }

  Widget categoryList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 15,right: 15),
          child: buildText("Categories", 20, FontWeight.w600, color.txtBlack),
        ),
        Row(
          children: [
            SizedBox(
              height: 120,
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  padding: const EdgeInsets.only(left: 15, top: 5),
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 18),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                selectedIndex=index;
                              });
                              if(index==0){
                                // customReelBoxFilter(context);
                              }
                              else if(index==1){
                                customRatingSheet(context: context,
                                  title: " How's your\nexperience so far?",
                                  heading: "We'd love to know!",
                                );
                              }
                              else if(index==2){
                                // Get.to(()=>const EvenetSuscribeScreen());
                              }
                            },
                            child: CircleAvatar(
                              radius: 34,
                              backgroundColor: color.txtWhite,
                              child: SvgPicture.asset(selectedIndex==index?items[index].selectedImg: items[index].img),
                            ),
                          ),
                          const SizedBox(height: 8),
                          buildText(items[index].title, 15, FontWeight.w500,
                              color.txtgrey2, fontFamily: FontFamily.hellix)
                        ],
                      ),
                    );
                  }),
            )
          ],
        ),
      ],
    );
  }
List<dynamic> itemList=[];
  void searchQuery(){
    if(searchController.text==""){
      itemList.clear();
    }
    else {
      itemList = data["items"].where((element) =>
          element["title"].toString().toLowerCase().contains(
              searchController.text.toLowerCase())).toList();
    }print(itemList);
  }
  Widget buildColumn() {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 30),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildText("Upcoming Events", 20, FontWeight.w600, color.txtBlack),
              GestureDetector(
                onTap: (){ Get.to(()=> MyEventListScreen(myEvent: false,myEventData: myEvent));},
                child: buildText("See More", 14, FontWeight.w600, color.dropDowngreytxt,
                    fontFamily: FontFamily.hellix),
              ),
            ],
          ),
          const SizedBox(height: 8),
         data==null?const CircularProgressIndicator(color: color.txtBlue,):data=="no data"?Center(child: buildText("no data!",18,FontWeight.w500,color.txtgrey),):
         ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
             // controller: _controller,
              // itemCount: eventItem.length,
              itemCount:itemList.isEmpty? post.length:itemList.length,
             itemBuilder: (context,index){
              var item=post;
              String type=item[index]["gender"].toString().toLowerCase();
              String typename=type=="straight"?"Straight": type=="lesbian"?"Lesbian": type=="queer"?"Queer": type=="transgender"?"Transgender": type=="gay"?"Gay":"Bisexual";
              int timestamp = item[index]["startsAt"];
              DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
              String formattedDate = DateFormat('dd MMM').format(dateTime);
              String formattedTime = DateFormat.jm().format(dateTime);
              String maleseats=getTotalMale(index)=="0"?"Full":"Available";
              String femaleseats=getTotalFemale(index)=="0"?"Full":"Available";
            return  Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: (){setState(() {
                    LocaleHandler.isProtected = item[index]["hasPassword"];
                    LocaleHandler.freeEventImage = item[index]["coverImage"];});
                  bool isParticipant=false;
                  var dataa=item[index]["participants"];
                  var i;
                  for(i=0;i<dataa.length;i++)
                  {if(dataa[i]["user"]["userId"].toString()==LocaleHandler.userId){
                    setState(() {isParticipant=true;});break;}
                  }
                  if(isParticipant){Get.to(()=>EventYourTicketScreen(eventId: item[index]["eventId"]));
                  }else{
                    callNavigation(item,index);
                    // if(userSexuality!=item[index]["gender"]) {showToastMsg("This event is not for you");} else
                    //   if(usergender=="male"){
                    //   if(maleseats=="Available"){callNavigation(item,index);}
                    // } else if(usergender=="female") {
                    //   if(femaleseats=="Available"){callNavigation(item,index);}
                    // }else{callNavigation(item,index);}
                  }
                },
                child:searchController.text==""?
                eventList(context, item, index, type, typename, formattedDate, formattedTime, maleseats, femaleseats):
                    itemList.isNotEmpty?
                eventList(context, itemList, index, type, typename, formattedDate, formattedTime, maleseats, femaleseats):
                const SizedBox(),
              ),
            );
          }),

        ],
      ),
    );
  }

  Widget eventList(BuildContext context, item, int index, String type, String typename, String formattedDate, String formattedTime, String maleseats, String femaleseats) {
    return Stack(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 306,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(imageUrl:item[index]["coverImage"], fit: BoxFit.cover)),
                  ),
                  IgnorePointer(child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      // height: 306,
                      child: ClipRRect(borderRadius: BorderRadius.circular(12),child: SvgPicture.asset(AssetsPics.eventbg,fit: BoxFit.cover)))),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                    color: color.txtWhite,
                                    borderRadius: BorderRadius.circular(4)
                                ),
                                height: 24,
                                width: 107,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    buildText("Age group:", 12, FontWeight.w500, color.txtBlack, fontFamily: FontFamily.hellix),
                                    buildText("${item[index]["minAge"]}-${item[index]["maxAge"]}", 12, FontWeight.w600, color.txtBlack, fontFamily: FontFamily.hellix),
                                  ],
                                )),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(left: 7,right: 7),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                      color: type=="straight"?color.straight:
                                      type=="lesbian"?color.lesbian: type=="queer"?color.queer:
                                      type=="transgender"?color.transgender: type=="gay"?color.gay:color.bisexual
                                    ),
                                    height: 24,
                                    child: buildText(typename, 13, FontWeight.w500, color.txtWhite, fontFamily: FontFamily.hellix)),
                                item[index]["hasPassword"]? CircleAvatar(
                                  radius: 15,
                                  backgroundColor: color.txtWhite,
                                  child: SvgPicture.asset(AssetsPics.lock),
                                ):const SizedBox()
                              ],
                            )
                          ],
                        ),
                        Container(height:item[index]["hasPassword"]?112:142),
                        Container(
                          height: 106,
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color:  const Color.fromRGBO(255, 255, 255, 0.5)
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                            Row(
                              children: [
                                Container(
                                  width: 46,
                                  decoration: BoxDecoration(color: color.txtWhite,borderRadius: BorderRadius.circular(8)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      buildText2(formattedDate, 16, FontWeight.w600, color.txtBlack,fontFamily: FontFamily.hellix),
                                      // buildText("Nov", 16, FontWeight.w600, color.txtBlack,fontFamily: FontFamily.hellix),
                                    ],),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width/1.9,
                                    child: buildTextOverFlow(
                                        item[index]["title"]+" - "+item[index]["type"],
                                        16, FontWeight.w700, color.txtWhite),
                                  ),
                                  Row(children: [
                                    SvgPicture.asset(AssetsPics.whitemappoint),
                                    const SizedBox(width: 3),
                                    SizedBox(
                                      // color: Colors.red,
                                        width: 100,
                                        child: buildTextOverFlow(item[index]["country"], 15.sp, FontWeight.w500, color.txtWhite,fontFamily: FontFamily.hellix)),
                                    const SizedBox(width: 8),
                                    SvgPicture.asset(AssetsPics.whitewatch),
                                    const SizedBox(width: 3),
                                    buildText(formattedTime, 15.sp, FontWeight.w500, color.txtWhite,fontFamily: FontFamily.hellix),
                                  ],)
                                ],),
                                const Spacer(),
                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      // savedEvent=!savedEvent;
                                      if(LocaleHandler.items.contains(item[index]["eventId"]))
                                        {LocaleHandler.items.remove(item[index]["eventId"]);}
                                      else{LocaleHandler.items.add(item[index]["eventId"]);}
                                      Preferences.setValue("EventIds", jsonEncode(LocaleHandler.items));
                                    });
                                  },
                                  child: CircleAvatar(radius: 14,
                                    backgroundColor: color.txtWhite,
                                    child: SvgPicture.asset(LocaleHandler.items.contains(item[index]["eventId"])?AssetsPics.eventbluesaved:AssetsPics.greysaved),//eventbluesaved
                                  ),
                                )
                              ],),
                            const SizedBox(height: 8),
                            Row(children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7,vertical: 3),
                                decoration: BoxDecoration(color: color.txtWhite,
                                    borderRadius: BorderRadius.circular(18)
                                ),
                                child: Row(children: [
                                  SvgPicture.asset(AssetsPics.man),
                                  const SizedBox(width: 5),
                                  buildText(maleseats, 13, FontWeight.w500, color.txtBlack,fontFamily: FontFamily.hellix)
                                ],),),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7,vertical: 3),
                                decoration: BoxDecoration(color: color.txtWhite,
                                    borderRadius: BorderRadius.circular(18)
                                ),
                                child: Row(children: [
                                  SvgPicture.asset(AssetsPics.woman),
                                  const SizedBox(width: 4),
                                  buildText(femaleseats, 13, FontWeight.w500, color.txtBlack,fontFamily: FontFamily.hellix)
                                ],),),
                              const Spacer(),
                              Row(children: [
                                buildText("Available : ", 14, FontWeight.w400, color.txtWhite,fontFamily: FontFamily.hellix),
                                // buildText("2", 14, FontWeight.w600, color.txtWhite,fontFamily: FontFamily.hellix),
                                buildText(getAvailable(index), 14, FontWeight.w600, color.txtWhite,fontFamily: FontFamily.hellix),
                              ],),
                            ],),
                          ],),
                        )
                      ],
                    ),
                  )
                ],
              );
  }

  void callNavigation(dynamic item ,int i){
    if(age>=item[i]["minAge"]){
      if(age<=item[i]["maxAge"]){Get.to(()=>EvenetFreeScreen(eventId: item[i]["eventId"]));}
      else{Fluttertoast.showToast(msg: "You are too Old for this Event");}
    }else{Fluttertoast.showToast(msg: "You are too Young for this Event");}
  }

  String getAvailable(int i){
    var total=post[i]["totalParticipants"]-post[i]["participants"].length;
    print(total);
    return total.toString();
  }

  String getTotalMale(int i){
    var total=post[i]["maleParticipants"];
    int malecount=0;
    for(var ii=0;ii<post[i]["participants"].length;ii++){
      if(post[i]["participants"][ii]["user"]["gender"]=="male"){malecount=malecount+1;}
    }
    total=total-malecount;
    print(total);
    return total.toString();
  }

  String getTotalFemale(int i){
    var total=post[i]["femaleParticipants"];
    int malecount=0;
    for(var ii=0;ii<post[i]["participants"].length;ii++){
      if(post[i]["participants"][ii]["user"]["gender"]=="female"){malecount=malecount+1;}
    }
    total=total-malecount;
    print(total);
    return total.toString();
  }


  Widget buildContainer(
      String txt, TextEditingController controller, FocusNode node,
      {FormFieldValidator<String>? validation,
      VoidCallback? press,
      GestureDetector? gesture,
      GestureDetector? preImg}) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.only(left: 10),
        height: 56,
        margin: const EdgeInsets.only(top: 20),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: color.txtWhite,
            borderRadius: BorderRadius.circular(12),
            // border: Border.all(color:enableField == txt? color.txtBlue:color.txtWhite, width:1)
            border: Border.all(color: color.txtWhite, width: 1)),
        child: TextFormField(
          textInputAction: TextInputAction.done,
          onTap: press,
          focusNode: node,
          controller: controller,
          onChanged: (txt){
            if(txt.trim()==""){searchController.text="";}
            searchQuery();
            setState(() {});
          },
          // focusNode: loginFocus,
          obscureText: txt == "Enter password" ? true : false,
          obscuringCharacter: "X",
          cursorColor: color.txtBlue,
          validator: validation,
          decoration: InputDecoration(
              errorStyle: const TextStyle(height: 0, fontSize: 12),
              border: InputBorder.none,
              hintText: txt,
              hintStyle: const TextStyle(
                  fontFamily: FontFamily.hellix, fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color.txtBlack),
              contentPadding:
                  const EdgeInsets.only(left: 20, right: 18, top: 12),
              suffixIcon: gesture,
              prefixIcon: preImg),
        ),
      ),
    );
  }
}

class CircleAvatarItems {
  int Id;
  String img;
  String selectedImg;
  String title;
  CircleAvatarItems(this.Id, this.title, this.img,this.selectedImg);
}
*/