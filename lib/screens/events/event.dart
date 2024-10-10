import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
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
import 'package:slush/controller/chat_controller.dart';
import 'package:slush/controller/controller.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/controller/event_controller.dart';
import 'package:slush/controller/waitingroom_controller.dart';
import 'package:slush/screens/events/event_list.dart';
import 'package:slush/screens/events/eventhistory.dart';
import 'package:slush/screens/events/free_event.dart';
import 'package:slush/screens/events/you_ticket.dart';
import 'package:slush/screens/notification/notification_screen.dart';
import 'package:slush/screens/onboarding/introscreen.dart';
import 'package:slush/screens/waiting_room/waiting_room_screen.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:slush/widgets/customtoptoaster.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:slush/widgets/toaster.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:geocoding/geocoding.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({Key? key}) : super(key: key);

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  TextEditingController searchController = TextEditingController();
  int selectedIndex = 0;
  String selectedIndexItem = "seeall";
  String usergender = "";
  String userSexuality = "";
  bool _isLoadMoreRunning = false;
  String location = "";

  TextEditingController locationController = TextEditingController(text: LocaleHandler.location);
  FocusNode locationNode = FocusNode();
  List statesList = [];
  String _searchQuery = '';
  var uuid = const Uuid();
  String _sessionToken = const Uuid().toString();
  List<dynamic> _placeList = [];

  void _onChanged() {
    getLocationResults(locationController.text);
  }

  void getLocationResults(String input) async {
    String kPLACES_API_KEY = "AIzaSyAtb9qudpaPK2l0uoANyRE0zi4Nj4jNoT4";
    String type = '(regions)';
    String baseURL = "https://maps.googleapis.com/maps/api/place/autocomplete/json";
    String request = "$baseURL?input=$input&key=$kPLACES_API_KEY&sessiontoken=$_sessionToken";
    var response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      setState(() {_placeList = jsonDecode(response.body)["predictions"];});
    } else {
      throw Exception("Failed to load predictions");
    }
  }

  List<CircleAvatarItems> items = [
    CircleAvatarItems(0, "All", AssetsPics.all, AssetsPics.selectall),
    CircleAvatarItems(2, "Music", AssetsPics.music, AssetsPics.selectmusic),
    CircleAvatarItems(3, "Sport", AssetsPics.sport, AssetsPics.selectsport),
    CircleAvatarItems(4, "Food", AssetsPics.food, AssetsPics.selectfood),
    CircleAvatarItems(5, "Business", AssetsPics.business, AssetsPics.selectbusiness),
  ];

  String formattedmon="";
  late ScrollController _controller;

  @override
  void initState() {
    locationController.addListener(() {_onChanged();});
    _getCurrentPosition();
    profileData();
    Provider.of<eventController>(context, listen: false).savedEvents(context);
    getEvents();
    checkBannerStatus();
    _controller = ScrollController()..addListener(loadmore);
    LocaleHandler.insideevent=false;
    super.initState();
  }

  // Animated to container
  void checkBannerStatus() {
    if (LocaleHandler.isThereAnyEvent) {
      // startTimer();
      futuredelayed(1, true);
      futuredelayed(3, false);
      LocaleHandler.isThereAnyEvent = false;
    }
    // else if(LocaleHandler.isThereCancelEvent){
    //   futuredelayed(1, true);
    //   futuredelayed(3, false);
    //   LocaleHandler.isThereCancelEvent=false;}
    else if (LocaleHandler.unMatchedEvent) {
      futuredelayed(1, true);
      futuredelayed(3, false);
      LocaleHandler.unMatchedEvent = false;
    } else if (LocaleHandler.subScribtioonOffer) {
      futuredelayed(1, true);
      futuredelayed(3, false);
      LocaleHandler.subScribtioonOffer = false;
    } else {
      setState(() {
        LocaleHandler.isBanner = false;
      });
    }
  }

  void futuredelayed(int i, bool val) {
    Provider.of<eventController>(context, listen: false).futuredelayed(i, val);
  }
  // hit get EVents
  var data;
  List post = [];
  int _page = 1;
  var myEvent = null;
  int totalpages = 0;
  int currentpage = 0;
  bool _hasNextPage = true;
  List<int> catId = [0];
  String cateId="0";

  Future getEvents() async {
    selectedIndex = int.parse(cateId);
    // final url = "${ApiList.getEvent}${LocaleHandler.miliseconds}&distance=${LocaleHandler.distancee}&events=popular&latitude=${LocaleHandler.latitude}&longitude=${LocaleHandler.longitude}&category_id=$cateId&page=1&limit=10";
    final url = "${ApiList.getEvent}${LocaleHandler.miliseconds}&distance=${LocaleHandler.distancee}&latitude=${LocaleHandler.latitude}&longitude=${LocaleHandler.longitude}&category_id=$cateId&page=1&limit=10";
    print(url);
    var uri = Uri.parse(url);
    var response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${LocaleHandler.accessToken}'
    });
    setState(() {LoaderOverlay.hide();});
    if (response.statusCode == 200) {
      print(response.body);
      setState(() {
        data = jsonDecode(response.body)["data"];
        totalpages = data["meta"]["totalPages"];
        currentpage = data["meta"]["currentPage"];
        post = data["items"];
        _isLoadMoreRunning=false;
      });
      // List<Map<String, dynamic>> j = [];
      // for (var i = 0; i < data["items"].length; i++) {
      //   for (var ii = 0; ii < data["items"][i]["participants"].length; ii++) {
      //     if (data["items"][i]["participants"][ii]["user"]["userId"].toString() == LocaleHandler.userId) {
      //       j.add(data["items"][i]);
      //     }
      //   }
      // }
      // myEvent = j;
      // for(var i = 0; i < data["items"].length; i++){
      //   if (!catId.contains(data["items"][i]["categoryId"])) {
      //     catId.add(data["items"][i]["categoryId"]);
      //   }
      // }
      // Provider.of<eventController>(context,listen: false).setdateFormate(myEvent[0]["startsAt"]);
      if(cateId!="0" && data["meta"]["totalItems"]==0) {
        customDialogBox(
            context: context,
            title: "Coming soon",
            heading: "Events specific to this category coming soon",
            btnTxt: "Ok",
            img: AssetsPics.comingsoonpng,
            secontxt: "",
            isPng: true);
      }
      Provider.of<eventController>(context, listen: false).getmeEvent(context,"me");
      LoaderOverlay.hide();
    } else if (response.statusCode == 401) {
      // showToastMsgTokenExpired();
    } else {
      Fluttertoast.showToast(msg: 'Something Went Wrong');
      setState(() {data = "no data";});
    }
  }

  Future loadmore() async {
    _searchQuery = "";
    FocusManager.instance.primaryFocus?.unfocus();
    // setState(() {LoaderOverlay.show(context);});
    if (_page < totalpages && _hasNextPage == true && _isLoadMoreRunning == false &&
        currentpage < totalpages && _controller.position.extentAfter < 300) {
      setState(() {
        _isLoadMoreRunning = true;
      });
      _page = _page + 1;
      // final url = "${ApiList.getEvent}${LocaleHandler.miliseconds}&distance=${LocaleHandler.distancee}&events=popular&latitude=${LocaleHandler.latitude}&longitude=${LocaleHandler.longitude}&category_id=$cateId&page=$_page&limit=10";
      final url = "${ApiList.getEvent}${LocaleHandler.miliseconds}&distance=${LocaleHandler.distancee}&latitude=${LocaleHandler.latitude}&longitude=${LocaleHandler.longitude}&category_id=$cateId&page=$_page&limit=10";
      print(url);
      var uri = Uri.parse(url);
      var response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${LocaleHandler.accessToken}'
      });
      setState(() {
        _isLoadMoreRunning = false;
      });
      if (response.statusCode == 200) {
        setState(() {
          var data = jsonDecode(response.body)['data'];
          currentpage = data["meta"]["currentPage"];
          final List fetchedPosts = data["items"];
          if (fetchedPosts.isNotEmpty) {post.addAll(fetchedPosts);}
        });
      }
    }
    setState(() {
      LoaderOverlay.hide();
    });
  }

  // location
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  String latitude = "";
  String longitude = "";

  Future<void> _getCurrentPosition() async {
    if(LocaleHandler.cordinatesFetch){return;}
    final hasPermission = await _handlePermission();
    if (!hasPermission) {
      Fluttertoast.showToast(msg: "Location permission is neccessary");
    }
    final position = await _geolocatorPlatform.getCurrentPosition();
    latitude = position.latitude.toString();
    longitude = position.longitude.toString();
    await Future.delayed(const Duration(seconds: 2));
    Provider.of<nameControllerr>(context, listen: false).setLocation(latitude, longitude);
    getEvents();
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  Future<void> getCoordinates(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        setState(() {
          latitude = locations[0].latitude.toString();
          longitude = locations[0].longitude.toString();
          print("::++++++++++=$latitude,$longitude");
          Provider.of<nameControllerr>(context, listen: false).setLocation(latitude, longitude);
          getEvents();
        });
      } else {
        setState(() {
          print('No coordinates found for this address');
        });
      }
    } catch (e) {
      setState(() {
        print('Error: $e');
      });
    }
  }

  // Get Profile
  int age = 0;
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
          Map<String, dynamic> data = jsonDecode(response.body);
          userData = data["data"];
          LocaleHandler.userId = userData["userId"].toString();
          // LocaleHandler.userId = userData["id"].toString();
          LocaleHandler.name = userData["firstName"]??userData["email"];
          LocaleHandler.avatar = userData["avatar"]??userData["profilePictures"][0]["key"]??"";
          age = calculateAge(data["data"]["dateOfBirth"].toString());
          usergender = userData["gender"]??"male";
          location = userData["state"] + ", " + userData["country"];
          LocaleHandler.gender = usergender;
          userSexuality = userData["sexuality"];
          LocaleHandler.subscriptionPurchase=data["data"]["isSubscriptionPurchased"]??"no";
          LocaleHandler.isVerified=data["data"]["isVerified"]??false;
          LocaleHandler.isLikedTabUpdate=data["data"]["isLikedTabUpdate"];
          Provider.of<ChatController>(context,listen: false).getUnreadChat(data["data"]["unreadMsgCount"]!="0");
          // LocaleHandler.isUnreadMessage=data["data"]["unreadMsgCount"]=="0"?false:true;
        });
      } else if (response.statusCode == 401) {
        showToastMsgTokenExpired();
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

  int calculateAge(String dobString) {
    DateTime dob = DateTime.parse(dobString);
    DateTime now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  Future cancelEventBooking()async{
    Get.back();
    final url="${ApiList.cancelEvent}${LocaleHandler.eventId.toString()}/cancel";
    print(url);
    var uri=Uri.parse(url);
    var response= await http.post(uri,headers: {'Content-Type': 'application/json',
      "Authorization": "Bearer ${LocaleHandler.accessToken}"
    });
    var i =jsonDecode(response.body);
    if(response.statusCode==201){
      print("testtest");
      setState(() {
        getEvents();
        Provider.of<eventController>(context, listen: false).getmeEvent(context,"me");
        Provider.of<eventController>(context, listen: false).timerCancel();
        // snackBaar(context,AssetsPics.redbanner,false);
        Provider.of<eventController>(context, listen: false).showBanner();
      });
    }
    else if(response.statusCode==401){showToastMsgTokenExpired();}
    else{Fluttertoast.showToast(msg: i["message"]);
    Get.back();
    }
  }



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return RefreshIndicator(
      displacement: 100,
      backgroundColor: color.txtWhite,
      color: color.txtBlue,
      strokeWidth: 3,
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      onRefresh: () async {
        Provider.of<eventController>(context, listen: false).timerCancel();
        await Future.delayed(const Duration(seconds: 2));
        Provider.of<eventController>(context, listen: false).getmeEvent(context,"me");
        getEvents();
      },
      child: Stack(
        children: [
          Scaffold(
              body: Stack(
            children: [
              GestureDetector(
                onTap: () {_searchQuery = "";},
                child: Stack(
                  children: [
                    SizedBox(height: size.height, width: size.width,
                      child: Image.asset(AssetsPics.background, fit: BoxFit.cover),
                    ),
                    SafeArea(
                      child: userData == null
                          ? const Center(child: CircularProgressIndicator(color: color.txtBlue))
                          : Stack(
                              children: [
                                SingleChildScrollView(
                                  physics: const ClampingScrollPhysics(),
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
                                      isThereEvent(),
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
                    Positioned(top: -6, child: animatedBanner(context)),
                  ],
                ),
              ),
              _searchQuery == ""
                  ? const SizedBox()
                  : Container(
                      margin: const EdgeInsets.only(top: 200),
                      padding: const EdgeInsets.only(bottom: 10, top: 5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: color.txtWhite),
                      child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: _placeList.length,
                          itemBuilder: (context, index) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      locationController.text = _placeList[index]["description"];
                                      getCoordinates(locationController.text.trim());
                                      LocaleHandler.location = _placeList[index]["description"];
                                      _searchQuery = "";
                                      statesList.clear();
                                      FocusManager.instance.primaryFocus?.unfocus();
                                    });
                                  },
                                  child: Container(
                                      alignment: Alignment.topLeft,
                                      color: Colors.transparent,
                                      margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
                                      padding: const EdgeInsets.only(left: 8, right: 8, top: 0),
                                      // decoration:  BoxDecoration(border: Border(bottom: BorderSide(width: 0.5,color:index==statesList.length-1?color.txtWhite: color.txtBlue))),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                              padding: const EdgeInsets.only(top: 5),
                                              child: SvgPicture.asset(
                                                AssetsPics.locationIcon,
                                                width: 14,
                                              )),
                                          const SizedBox(width: 12),
                                          Flexible(
                                              child: buildText(
                                                  _placeList[index]["description"],
                                                  18,
                                                  FontWeight.w500,
                                                  color.txtgrey))
                                        ],
                                      )),
                                ),
                                index == _placeList.length - 1
                                    ? const SizedBox()
                                    : const Divider(thickness: 0.2)
                              ],
                            );
                          }),
                    ),
            ],
          )),
          // const CustomTopToaster(),
          Consumer<eventController>(builder: (context,val,child){
            return val.bookiingCancelled?  CustomredTopToaster(textt: "Booking cancelled"):const SizedBox.shrink();
          })
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
          buildContainer("Search Location", locationController,
            AutovalidateMode.onUserInteraction, locationNode,
            onChanged: (text) {
              LocaleHandler.location = locationController.text.trim();
              // _searchLocations(text);
            },
            gesture: GestureDetector(
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  customDialogBoxFilter(context, whiteTap: () {
                    Get.back();
                    date1 = "Select Date ";
                    date2 = "Select Date ";
                    LocaleHandler.miliseconds=0;
                    getEvents();
                  }, blueTap: () {
                    Get.back();
                    setState(() {LoaderOverlay.show(context);});
                    getEvents();
                  });
                },
                child: Container(
                    padding: const EdgeInsets.only(top: 5),
                    height: 20,
                    width: 30,
                    alignment: Alignment.center,
                    child: SvgPicture.asset(AssetsPics.filterIcon))),
            preImg: GestureDetector(
                child: Container(
                    padding: const EdgeInsets.only(top: 5),
                    height: 20, width: 30,
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
      height: LocaleHandler.isBanner ? 110 : 0,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width,
              child: LocaleHandler.unMatchedEvent || LocaleHandler.isThereCancelEvent
                  ? Image.asset(LocaleHandler.unMatchedEvent ? AssetsPics.unMatchedbg : AssetsPics.bookingCanceled,fit: BoxFit.cover)
                  : Image.asset(AssetsPics.bannerpng, fit: BoxFit.cover)),
          LocaleHandler.subScribtioonOffer
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 20, top: 30),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    SizedBox(width: LocaleHandler.isBanner ? 2.h : 0),
                    SvgPicture.asset(AssetsPics.crownwithround),
                    SizedBox(width: LocaleHandler.isBanner ? 2.h : 0),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildText("Slush Silver Subscription", 18, FontWeight.w600, color.txtWhite),
                        Row(
                          children: [
                            buildText("Get 50% off", 15, FontWeight.w600, color.txtWhite),
                            SizedBox(width: LocaleHandler.isBanner ? 1.h : 0),
                            SvgPicture.asset(AssetsPics.verticaldivider),
                            SizedBox(width: LocaleHandler.isBanner ? 1.h : 0),
                            buildText("Ends : 00:11:33", 15, FontWeight.w600, color.txtWhite)
                          ],
                        )
                      ],
                    )
                  ]),
                )
              : Container(
                  padding: const EdgeInsets.only(
                      top: 30, left: 10, right: 10, bottom: 15),
                  child: buildText2(
                      LocaleHandler.isThereCancelEvent ? ""
                          : LocaleHandler.unMatchedEvent ? "" : "Event starting in 15 minutes, Click Hereto join the waiting room!",
                      20, FontWeight.w600, color.txtWhite)),
        ],
      ),
    );
  }

  Widget myEventlist() {
    return Consumer<eventController>(builder: (context,val,child){
      return val.meEvent.isEmpty
          ? const SizedBox()
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildText("My Events", 20, FontWeight.w600, color.txtBlack),
                GestureDetector(
                    onTap: () {
                      Provider.of<eventController>(context, listen: false).getmeEvent(context,"me");
                      Get.to(() => MyEventListScreen(myEvent: true, pageNum: _page));
                    },
                    child: buildText("See More", 14, FontWeight.w600, color.dropDowngreytxt, fontFamily: FontFamily.hellix)),
              ],
            ),
          ),
          SizedBox(
            height: 85,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: val.meEvent.length,
                padding: const EdgeInsets.only(left: 15),
                itemBuilder: (context, index) {
                  int timestamp = val.meEvent[index]["startsAt"];
                  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
                  String formattedDate = DateFormat('dd').format(dateTime);
                  String formattedmon = DateFormat('MMM').format(dateTime);
                  String formattedTime = DateFormat.jm().format(dateTime);
                  return GestureDetector(
                    onTap: () {
                      sendtoEventDetail(val.meEvent,index);
                    },
                    child: Container(
                      padding: const EdgeInsets.only(left: 8, top: 5, bottom: 5),
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(color: color.txtWhite, borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              imagewithdate(index, formattedDate,val,formattedmon),
                              const SizedBox(width: 8),
                              details(index, formattedTime,val)
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          )
        ],
      );
    });
  }

  Widget imagewithdate(int index, String date,eventController val,String mon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 3, top: 3),
      height: 68,
      width: 96,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Stack(
        children: [
          SizedBox(
              height: 68,
              width: 96,
              // child: Image.asset(historyItem[index].img,fit: BoxFit.fill),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: CachedNetworkImage(
                    imageUrl: val.meEvent[index]["coverImage"],
                    fit: BoxFit.cover,
                    placeholder: (ctx, url) => const Center(child: SizedBox()),
                  ))),
          Container(
            margin: const EdgeInsets.only(left: 3, top: 3),
            width: 30,
            decoration: BoxDecoration(
                color: color.txtWhite, borderRadius: BorderRadius.circular(8)),
            // child: buildText2(date, 12.2, FontWeight.w600, color.txtBlack, fontFamily: FontFamily.hellix),
            child: buildText2("$date\n$mon", 12.2, FontWeight.w600, color.txtBlack, fontFamily: FontFamily.hellix),
          ),
        ],
      ),
    );
  }

  Column details(int index, String time,eventController val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 180,
            child: buildTextOverFlow(val.meEvent[index]["title"], 16, FontWeight.w600, color.txtBlack)),
        Row(
          children: [
            SvgPicture.asset(AssetsPics.blueMapPoint),
            const SizedBox(width: 4),
            buildTextOverFlow(val.meEvent[index]["country"], 13, FontWeight.w500, color.txtgrey2,
                fontFamily: FontFamily.hellix),
          ],
        ),
        Row(
          children: [
            SvgPicture.asset(AssetsPics.blueClock),
            const SizedBox(width: 4),
            buildTextOverFlow(time, 13, FontWeight.w500, color.txtgrey2, fontFamily: FontFamily.hellix),
          ],
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget isThereEvent() {
    return Consumer<eventController>(
      builder: (context,val,child){
      return  val.startTime== 0?const SizedBox():  Container(
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
                  child: SvgPicture.asset(AssetsPics.eventflower)),
            ),
            timerWidget(val),
          ],
        ),
      );
      }
    );
  }

  Widget timerWidget(eventController vall) {
    final size=MediaQuery.of(context).size;
    int timestamp = vall.startTime;
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    String formattedDate = DateFormat('dd').format(dateTime);
    String formattedmonth = DateFormat('MMMM').format(dateTime);
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildText("Next event starts in", 18, FontWeight.w600, color.txtBlack),
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: color.txtWhite),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 14, top: 14),
                  // child: buildText("Friday Frenzy - 5 Dates... ", 18,
                  child: buildText(vall.timerEventName, 18, FontWeight.w600, color.txtBlack),
                ),
                const Divider(thickness: 0.8, color: color.lightestBlue),
                Padding(
                  padding: const EdgeInsets.only(left: 14, right: 14),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildText("Time Remaining", 16, FontWeight.w600, color.txtBlack),
                          Container(padding: const EdgeInsets.only(right: 7),
                              child: buildText("Deadline", 16, FontWeight.w600, color.txtBlack)),
                        ],
                      ),
                     Consumer<eventController>(builder: (context,val,child){
                       return val.days==""?const SizedBox():  Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Row(children: [
                             val.days == "00"?const SizedBox():  Column(
                               children: [
                                 buildText(val.days, 24, FontWeight.w600, color.txtBlack),
                                 buildText("Days", 15, FontWeight.w400, color.txtgrey, fontFamily: FontFamily.hellix),
                               ],
                             ),
                             SizedBox(width:val.days == "00"?0: size.width*0.03),
                             val.days == "00"?const SizedBox():  buildText(":", 24, FontWeight.w600, color.txtBlack),
                           ],),
                           Column(
                             children: [
                               buildText(int.parse(val.hours) < 0 ? "00" : val.hours, 24, FontWeight.w600, color.txtBlack),
                               buildText("Hours", 15, FontWeight.w400, color.txtgrey, fontFamily: FontFamily.hellix),
                             ],
                           ),
                           buildText(":", 24, FontWeight.w600, color.txtBlack),
                           Column(
                             children: [
                               buildText(int.parse(val.minutes) < 0 ? "00" :val.minutes, 24, FontWeight.w600, color.txtBlack),
                               buildText("Minutes", 15, FontWeight.w400, color.txtgrey, fontFamily: FontFamily.hellix),
                             ],
                           ),
                           Row(children: [  val.days != "00"?const SizedBox():  buildText(":", 24, FontWeight.w600, color.txtBlack),
                             SizedBox(width:val.days != "00"?0: size.width*0.03),
                             val.days != "00"?const SizedBox():  Column(
                               children: [
                                 buildText(int.parse(val.seconds) < 0 ? "00" :val.seconds, 24, FontWeight.w600, color.txtBlack),
                                 buildText("Seconds", 15, FontWeight.w400, color.txtgrey, fontFamily: FontFamily.hellix),
                               ],
                             ),],),
                           Container(height: 40, width: 2,
                             decoration: BoxDecoration(color: color.hieghtGrey, borderRadius: BorderRadius.circular(12)),
                           ),
                           Padding(
                             padding: const EdgeInsets.only(right: 20),
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.center,
                               children: [
                                 buildText(formattedDate, 24, FontWeight.w600, color.txtBlack),
                                 buildText(formattedmonth, 15, FontWeight.w400, color.txtgrey, fontFamily: FontFamily.hellix),
                               ],
                             ),
                           ),
                         ],
                       );
                     }),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                              onTap: (){
                                customDialogBoxWithtwobutton(context, "Are you sure you would like to cancel event?", " ",
                                    img: AssetsPics.cancelticketpng,btnTxt1: "No",btnTxt2: "Yes",
                                    onTap2: (){
                                      cancelEventBooking();
                                    },isPng: true
                                );
                              }
                              ,child: buildText(vall.before15?"":"Unable to attend", 16, FontWeight.w600, color.txtBlack)),
                          GestureDetector(
                            onTap: () {
                               DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(vall.startEventTime * 1000);
                                DateTime timeFormat = DateTime.now();
                                var timee = DateTime.tryParse(dateTime.toString());
                                int min = timee!.difference(timeFormat).inSeconds;
                                if(min<900 && min>=0){
                                // if(min>900){
                                  Provider.of<waitingRoom>(context,listen: false).timerStart(min);
                                  Get.to(()=> WaitingRoom(data: vall.meEvent[vall.indexnum],min: min));}
                                else if(min<0){}
                                else{ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:
                                Text('Waiting room will open before 15 min of event Start')));}
                                // Get.to(()=>const EventYourTicketScreen());
                            },
                            child: Container(
                              padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
                              margin: const EdgeInsets.only(left: 10, bottom: 14, top: 14),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  gradient:vall.before15? const LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [color.gradientLightBlue, color.txtBlue],
                                  ):const LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [color.txtgrey2, color.txtgrey2],
                                  )
                              ),
                              child: buildText("Join", 18, FontWeight.w600, color.txtWhite),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
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
      child:
      Row(
        children: [
          LocaleHandler.avatar == ""
              ? Image.asset(AssetsPics.demouser, fit: BoxFit.fill)
              : ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(width: 50,height: 50, imageUrl: LocaleHandler.avatar, fit: BoxFit.fitWidth, placeholder: (ctx, url) => const Center(child: SizedBox()),
                  )),


          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                    child: buildTextOverFlow(
                        LocaleHandler.name, 20, FontWeight.w600, color.txtBlack)),
                SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                    child: buildTextOverFlow(
                        location, 13, FontWeight.w500, color.txtgrey2,
                        fontFamily: FontFamily.hellix)),
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
              onTap: () {
                Get.to(() => const EventHistoryScreen());
              },
              child: SvgPicture.asset(AssetsPics.historyIcon)),
          const SizedBox(width: 10),
          GestureDetector(
              onTap: () {
                Get.to(() => const NotificationScreen());
              },
              child: SvgPicture.asset(AssetsPics.notificationIcon)),
        ],
      ),
    );
  }

  void callCate(int index) {
    setState(() {
      if (catId.contains(items[index].Id)) {
        selectedIndex = items[index].Id;
      } else {
        customDialogBox(
            context: context,
            title: "Coming soon",
            heading: "Events specific to this category coming soon",
            btnTxt: "Ok",
            img: AssetsPics.comingsoonpng,
            secontxt: "",
            isPng: true);
      }
    });
  }

  Widget categoryList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
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
                            onTap: () {
                              setState(() {
                                _isLoadMoreRunning=true;
                                // callCate(index);
                                cateId = items[index].Id.toString();
                                // selectedIndex=index;
                                selectedIndexItem = items[index].title;
                                getEvents();
                              });
                            },
                            child: CircleAvatar(radius: 34, backgroundColor: color.txtWhite,
                              child: SvgPicture.asset(selectedIndex == items[index].Id ? items[index].selectedImg : items[index].img),
                            ),
                          ),
                          const SizedBox(height: 8),
                          buildText(items[index].title, 15, FontWeight.w500, color.txtgrey2, fontFamily: FontFamily.hellix)
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

  List<dynamic> itemList = [];

  void searchQuery() {
    if (searchController.text == "") {
      itemList.clear();
    } else {
      itemList = data["items"].where((element) => element["title"].toString().toLowerCase().contains(searchController.text.toLowerCase())).toList();
    }
    print(itemList);
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
                onTap: () {
                  Get.to(() => MyEventListScreen(myEvent: false,pageNum: _page));
                },
                child: buildText("See More", 14, FontWeight.w600, color.dropDowngreytxt,
                    fontFamily: FontFamily.hellix),
              ),
            ],
          ),
          const SizedBox(height: 15),
          data == null
              ? const CircularProgressIndicator(color: color.txtBlue)
              : data == "no data"
                  ? Center(child: buildText("no data!", 18, FontWeight.w500, color.txtgrey))
                  : ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      // controller: _controller,
                      // itemCount: eventItem.length,
                      itemCount: itemList.isEmpty ? post.length : itemList.length,
                      itemBuilder: (context, index) {
                        var item = itemList.isEmpty ? post : itemList;
                        String type = item[index]["gender"].toString().toLowerCase();
                        String typename = type == "straight"
                            ? "Straight" : type == "lesbian"
                                ? "Lesbian" : type == "queer"
                                    ? "Queer" : type == "transgender"
                                        ? "Transgender" : type == "gay"
                                            ? "Gay" : "Bisexual";
                        int timestamp = item[index]["startsAt"];
                        DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
                        String formattedDate = DateFormat('dd').format(dateTime);
                        formattedmon = DateFormat('MMM').format(dateTime);
                        String formattedTime = DateFormat.jm().format(dateTime);
                        String maleseats = getTotalMale(index, item) == "0" ? "Full" :getTotalMale(index, item) == "-1"?"Not": "Available";
                        // String maleseats = getTotalMale(index, item) == "0" ? "Full" : "Available";
                        String femaleseats = getTotalFemale(index, item) == "0" ? "Full" :getTotalFemale(index, item) == "-1"?"Not": "Available";
                        // String femaleseats = getTotalFemale(index, item) == "0" ? "Full" : "Available";
                        return selectedIndex == 0
                            ? buildContainereventDetails(item, index,
                            context, type, typename, formattedDate, formattedTime, maleseats, femaleseats)
                            : selectedIndex == item[index]["categoryId"]
                                ? buildContainereventDetails(item, index, context,
                                    type, typename, formattedDate, formattedTime,
                                    maleseats, femaleseats)
                                : const SizedBox();
                      }),
        ],
      ),
    );
  }

  Container buildContainereventDetails(List<dynamic> item, int index,
      BuildContext context, String type, String typename, String formattedDate,
      String formattedTime, String maleseats, String femaleseats) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () {
          sendtoEventDetail(item,index);
        },
        child: searchController.text == ""
            ? eventList(context, item, index, type, typename, formattedDate, formattedTime, maleseats, femaleseats)
            : itemList.isNotEmpty
                ? eventList(context, itemList, index, type, typename, formattedDate, formattedTime, maleseats, femaleseats)
                : const SizedBox(),
      ),
    );
  }

  Widget eventList(
      BuildContext context,
      item,
      int index,
      String type,
      String typename,
      String formattedDate,
      String formattedTime,
      String maleseats,
      String femaleseats) {
    final eventCntrller = Provider.of<eventController>(context, listen: false);
    return Stack(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 306,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: item[index]["coverImage"],
                fit: BoxFit.cover,
                placeholder: (ctx, url) => const Center(child: SizedBox()),
              )),
        ),
        IgnorePointer(
            child: SizedBox(
                width: MediaQuery.of(context).size.width,
                // height: 306,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SvgPicture.asset(AssetsPics.eventbg, fit: BoxFit.cover)))),
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
                      decoration: BoxDecoration(color: color.txtWhite,
                          borderRadius: BorderRadius.circular(4)),
                      height: 24,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      // width: 107,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildText("Age group: ", 12, FontWeight.w500, color.txtBlack,
                              fontFamily: FontFamily.hellix),
                          buildText(
                              "${item[index]["minAge"]}-${item[index]["maxAge"]}",
                              12,
                              FontWeight.w600,
                              color.txtBlack,
                              fontFamily: FontFamily.hellix),
                        ],
                      )),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                          padding: const EdgeInsets.only(left: 7, right: 7),
                          margin: const EdgeInsets.only(bottom: 8),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: type == "straight"
                                  ? color.straight
                                  : type == "lesbian"
                                      ? color.lesbian
                                      : type == "queer"
                                          ? color.queer
                                          : type == "transgender"
                                              ? color.transgender
                                              : type == "gay"
                                                  ? color.gay
                                                  : color.bisexual),
                          height: 24,
                          child: buildText(
                              typename, 13, FontWeight.w500, color.txtWhite,
                              fontFamily: FontFamily.hellix)),
                      item[index]["hasPassword"]
                          ? CircleAvatar(
                              radius: 15,
                              backgroundColor: color.txtWhite,
                              child: SvgPicture.asset(AssetsPics.lock),
                            ) : const SizedBox()
                    ],
                  )
                ],
              ),
              Container(height: item[index]["hasPassword"] ? 112 : 142),
              Container(
                height: 106,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6.5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color.fromRGBO(255, 255, 255, 0.5)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          width: 46,
                          decoration: BoxDecoration(color: color.txtWhite, borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildText2("$formattedDate\n$formattedmon", 14, FontWeight.w600, color.txtBlack, fontFamily: FontFamily.hellix),
                              // buildText("Nov", 16, FontWeight.w600, color.txtBlack,fontFamily: FontFamily.hellix),
                            ],),),
                        const SizedBox(width: 9),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 1.9,
                              child: buildTextOverFlow(
                                  item[index]["title"] + " - " + item[index]["type"],
                                  16, FontWeight.w700, color.txtWhite),
                            ),
                            Row(
                              children: [
                                SvgPicture.asset(AssetsPics.whitemappoint),
                                const SizedBox(width: 3),
                                SizedBox(
                                    // color: Colors.red,
                                    width: 100,
                                    child: buildTextOverFlow(item[index]["country"], 15.sp,
                                        FontWeight.w500,
                                        color.txtWhite,
                                        fontFamily: FontFamily.hellix)),
                                const SizedBox(width: 8),
                                SvgPicture.asset(AssetsPics.whitewatch),
                                const SizedBox(width: 3),
                                buildText(formattedTime, 15.sp, FontWeight.w500,
                                    color.txtWhite,
                                    fontFamily: FontFamily.hellix),
                                // buildText("12:00 PM", 15.sp, FontWeight.w500, color.txtWhite,fontFamily: FontFamily.hellix),
                              ],
                            )
                          ],
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              // savedEvent=!savedEvent;
                              if (LocaleHandler.items.contains(item[index]["eventId"])) {
                                eventCntrller.saveEvent(ApiList.unsaveEvent, item[index]["eventId"].toString());
                                LocaleHandler.items.remove(item[index]["eventId"]);
                              } else {
                                eventCntrller.saveEvent(ApiList.saveEvent, item[index]["eventId"].toString());
                                LocaleHandler.items.add(item[index]["eventId"]);
                              }
                              Preferences.setValue("EventIds", jsonEncode(LocaleHandler.items));
                            });
                          },
                          child: CircleAvatar(
                            radius: 16.3,
                            backgroundColor: color.txtWhite,
                            child: SvgPicture.asset(
                                LocaleHandler.items.contains(item[index]["eventId"])
                                    ? AssetsPics.eventbluesaved
                                    : AssetsPics.greysaved,
                                height: 16), //eventbluesaved
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        maleseats=="Not"?const SizedBox():  Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                              color: color.txtWhite,
                              borderRadius: BorderRadius.circular(18)),
                          child: Row(
                            children: [
                              SvgPicture.asset(AssetsPics.man),
                              const SizedBox(width: 5),
                              buildText(maleseats, 13, FontWeight.w500,
                                  color.txtBlack,
                                  fontFamily: FontFamily.hellix)
                            ],
                          ),
                        ),
                        SizedBox(width:maleseats=="Not"?0: 8),
                        femaleseats=="Not"?const SizedBox(): Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(color: color.txtWhite,
                              borderRadius: BorderRadius.circular(18)),
                          child: Row(
                            children: [
                              SvgPicture.asset(AssetsPics.woman),
                              const SizedBox(width: 4),
                              buildText(femaleseats, 13, FontWeight.w500, color.txtBlack, fontFamily: FontFamily.hellix),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            buildText("Available : ", 14, FontWeight.w400, color.txtWhite, fontFamily: FontFamily.hellix),
                            // buildText("2", 14, FontWeight.w600, color.txtWhite,fontFamily: FontFamily.hellix),
                            buildText(getAvailable(index, item), 14, FontWeight.w600, color.txtWhite, fontFamily: FontFamily.hellix),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  void sendtoEventDetail(var item,int index){
    LocaleHandler.eventId=item[index]["eventId"];
      LocaleHandler.isProtected = item[index]["hasPassword"];
      LocaleHandler.freeEventImage = item[index]["coverImage"];
    bool isParticipant = false;
    var dataa = item[index]["participants"];
    var i;
    for (i = 0; i < dataa.length; i++) {
      if (dataa[i]["user"]["userId"].toString() == LocaleHandler.userId) {
        isParticipant = true;
        break;
      }
    }
    if (isParticipant) {
      Get.to(() => EventYourTicketScreen(eventId: item[index]["eventId"]))!.then((value) {setState(() {});});
    } else {callNavigation(item, index);}
  }

  void callNavigation(dynamic item, int i) {
    // age = 18;
    if (age >= item[i]["minAge"] && age <= item[i]["maxAge"] && userData["sexuality"]==item[i]["gender"] ) {
      Get.to(() => EvenetFreeScreen(eventId: item[i]["eventId"]))!.then((value) {setState(() {});});
    } else {
      // Fluttertoast.showToast(msg: "You do not meet the requirements for this event");
      showToastMsg("You do not meet the requirements for this event");
    }
  }

  String getAvailable(int i, item) {
    int totalPaticipants = post[i]["type"]=="5 Dates"?10:20;
    int ii=0;
    // var total =  post[i]["totalParticipants"] - post[i]["participants"].length;
    if(post[i]["type"]=="5 Dates"){ii =post[i]["totalParticipants"]<=10?post[i]["totalParticipants"]:10;}
    else{ii =post[i]["totalParticipants"]<=20?post[i]["totalParticipants"]:20;}
    var total = totalPaticipants - ii;
    return total.toString();
  }

  String getTotalMale(int i, item) {
    var total = post[i]["maleParticipants"] < 5 ? post[i]["maleParticipants"] : 5;
    String gen = post[i]["gender"];
    int malecount = post[i]["type"] == "5 Dates" ? 5 : 10;
    total =gen=="lesbian"?-1: malecount-total;
    return total.toString();
  }

  String getTotalFemale(int i, item) {
    var total = post[i]["femaleParticipants"]<5?post[i]["femaleParticipants"]:5;
    String gen = post[i]["gender"];
    int femalecount = post[i]["type"]=="5 Dates"?5:10;
    total = gen=="gay"?-1: femalecount-total;
    return total.toString();
  }

  Widget buildContainer(
    String txt,
    TextEditingController controller,
    AutovalidateMode auto,
    FocusNode node, {
    FormFieldValidator<String>? validation,
    VoidCallback? press,
    GestureDetector? gesture,
    GestureDetector? preImg,
    final ValueChanged<String>? onChanged,
  }) {
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
          onChanged: (value) {
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
                  fontFamily: FontFamily.hellix,
                  fontSize: 16,
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

  CircleAvatarItems(this.Id, this.title, this.img, this.selectedImg);
}
