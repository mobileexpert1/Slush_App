import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:http/http.dart'as http;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/constants/loader.dart';
import 'package:slush/controller/spark_Liked_controler.dart';
import 'package:slush/screens/chat/socket_service.dart';
import 'package:slush/screens/matches/matched_person_profile.dart';
import 'package:slush/widgets/app_bar.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:slush/widgets/toaster.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class TextChatScreen extends StatefulWidget {
  const TextChatScreen({Key? key,required this.name,required this.id}) : super(key: key);
  final int id;
  final String name;

  @override
  State<TextChatScreen> createState() => _TextChatScreenState();
}

class _TextChatScreenState extends State<TextChatScreen> {
  var viewInsets=0.0;
  double hi=0.0;
  bool atachement=false;
  final chatTextField = FocusNode();
  // bool canPop=true;
  TextEditingController messageController=TextEditingController();
  ScrollController _scrollController = ScrollController();

  final SocketService _socketService = SocketService();

  List reportingMatter = [
    "Fake Account",
    "Nudity / inappropriate",
    "Swearing / Aggression",
    "Harassment","Other"
  ];

  List dataa=[];
  int totalpages=0;
  int currentpage=0;
  int totalItems=-1;
  int _page=1;
  bool _isLoadMoreRunning=false;

  var formattedTime;
  IO.Socket? socket;
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    connectToSocket();
    Future.delayed(const Duration(seconds: 2));
    getChat();
    _scrollController = ScrollController()..addListener(loadmore);
    super.initState();
  }

  Future getChat()async{
    try{
      await OneSignal.User.pushSubscription.optOut();
      final url="${ApiList.getSingleChat}${widget.id}/conversation?page=1&limit=25";
      print(url);
      var uri =Uri.parse(url);
      var response=await http.get(uri,
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${LocaleHandler.accessToken}'});
      var i =jsonDecode(response.body)["data"];
      if(response.statusCode==200){
        // if(mounted){
        setState(() {dataa=i["items"];});
        for (var item in dataa)
        {var ii={
          "content":item["content"],
          "sender":item["sender"]["userId"].toString(),
          'createdAt': item["createdAt"].toString()};
        messages.add(ii);
        }
        totalpages=i["meta"]["totalPages"];
        totalItems=i["meta"]["totalItems"];
        currentpage=i["meta"]["currentPage"];
        // }
      }
      else if(response.statusCode==401){showToastMsgTokenExpired();}
      else{}
    }
    on SocketException catch (e){print(";-;-internet issue");}
    catch(e){}
  }

  Future loadmore()async{
    if (_page<totalpages&& _isLoadMoreRunning == false && currentpage<totalpages&& _scrollController.position.extentAfter < 300) {
      setState(() {_isLoadMoreRunning=true;});
      _page=_page+1;
      final url="${ApiList.getSingleChat}${widget.id}/conversation?page=$_page&limit=25";
      print(url);
      var uri =Uri.parse(url);
      var response=await http.get(uri, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${LocaleHandler.accessToken}'});
      setState(() {_isLoadMoreRunning=false;});
      if(response.statusCode==200){
        setState(() {
          var i = jsonDecode(response.body)['data'];
          currentpage=i["meta"]["currentPage"];
          final List fetchedPosts = i["items"];
          if (fetchedPosts.isNotEmpty) {setState(() {
          for (var item in fetchedPosts)
          {var ii={
            "content":item["content"],
            "sender":item["sender"]["userId"].toString(),
            'createdAt': item["createdAt"].toString()};
          messages.add(ii);
          }
          });}
        });
      }}
  }

  void connectToSocket() {
    socket = IO.io(
      'http://dev-api.slushdating.com:3000', // Replace with your server address and port
      IO.OptionBuilder()
          .setTransports(['websocket']) // for Flutter or Dart VM
          .enableAutoConnect() // optional
          .setAuth({'userId': LocaleHandler.userId}) // Pass userId for authentication
          .build(),
    );

    socket!.connect();

    socket!.onConnect((_) {
      print('Connected');
    });

    socket!.onDisconnect((_) {
      print('Disconnected');
    });

    socket!.on('error', (data) {
      print('Error: $data');
    });

    socket!.onConnectError((data) {
      print('Connect Error: $data');
    });

    socket!.on('private message', (data) {
      print('RECEIVED MSG: $data');
      _updateData(data);
    });

  }

  // Function to send a message to the server.
  void sendMessage(String text) {
    // DateTime now = DateTime.now();
    // int timestampSeconds = (now.millisecondsSinceEpoch / 1000).floor();
    String message = text;
    if (message.isNotEmpty) {
      socket!.emit('private message', {'content': message, 'from': LocaleHandler.userId, 'to': widget.id.toString(),
        // 'createdAt': timestampSeconds,
      });
      messageController.clear();
      _scrollToEnd();
    }
  }

  void _updateData(dynamic data) {
      var ii={"content":data["content"],
        "sender":data["sender"]["userId"].toString(),
        "createdAt": data["createdAt"].toString()};
      if((widget.id==data["sender"]["userId"])||(LocaleHandler.userId==data["sender"]["userId"].toString())){setState(() {messages.insert(0, ii);});}
  }

  @override
  void dispose()async {
    socket!.disconnect();
    socket!.dispose();
    messageController.dispose();
    await OneSignal.User.pushSubscription.optIn();
    super.dispose();
  }

  String? imageBase64;

  File? _image;

  Future imgFromGallery(ImageSource src) async {
    try{
      var image = await ImagePicker().pickImage(source: src);
      if (image != null) {
        showToastMsg("please wait...");
        setState(() {
          _image = File(image.path);
          Provider.of<CamController>(context,listen: false).saveImge(_image!);
          // sendImagee(_image!);
        });}}
    catch(error) {print("error: $error");}
  }

  var apidata;
  List<dynamic> dataList=[];
  Future sendImagee(File fileimage)async{
    // https://localhost:3000/api/v1/profile-pictures/batch/file-upload
    const url = ApiList.fileuploadinchat;
    var uri=Uri.parse(url);
    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = "Bearer ${LocaleHandler.accessToken}";
    // Add image file
    if (fileimage != null) {
      File imageFile = File(fileimage.path);
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile('files', stream, length, filename: fileimage.toString().split("/").last,contentType: MediaType('image','png'));
      request.files.add(multipartFile);
    }
    var response = await request.send();
    final respStr = await response.stream.bytesToString();
    apidata=jsonDecode(respStr);;
    print(apidata);
    dataList = apidata['data'];
    print("dataList--$dataList");
    if(response.statusCode==201){
      print("response.statusCode====${response.statusCode}");}
    print("response.statusCode=======${response.statusCode}");
  }

  Future reportUser(String reason) async {
    setState(() {LoaderOverlay.show(context);});
    final url = '${ApiList.reportUser}${widget.id}/report';
    print(url);
    try {
      var uri = Uri.parse(url);
      var response = await http.post(uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${LocaleHandler.accessToken}'
          },
          body: jsonEncode({'reason': reason})
      );
      setState(() {LoaderOverlay.hide();});
      print(response.statusCode);
      if(response.statusCode==201)
      {chatDelete(widget.id);
        Fluttertoast.showToast(msg: 'User Reported Successfully');
      // Get.back(result: true);
      }
      else if(response.statusCode==401){
        showToastMsgTokenExpired();
      }
      else{
        print('Reported Failed With Status Code :${response.statusCode}');
        Fluttertoast.showToast(msg: 'Something Went Wrong');
      }
    }
    catch(error)
    {
      print('Error ::::::::::::::::::: ${error.toString()}');
      Fluttertoast.showToast(msg: 'Something Went Wrong::');
    }
  }

  void chatDelete(int id)async{
    final url="${ApiList.getSingleChat}$id/deleteconversation";
    print(url);
    var uri =Uri.parse(url);
    var response=await http.get(uri,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${LocaleHandler.accessToken}'});
    // setState(() {LoaderOverlay.hide});
    if(response.statusCode==200){
      Get.back(result: true);
    }
    else{}
  }

  void _scrollToEnd() {
    if(messages.isNotEmpty){
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );}
  }

  String formatTimestamp(int timestamp) {
    DateTime dateTime =DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    DateTime now = DateTime.now();
    DateTime yesterday = now.subtract(const Duration(days: 1));
    if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day)
    {return DateFormat.jm().format(dateTime.add(const Duration(seconds: 157)));}
    else if (dateTime.year == yesterday.year && dateTime.month == yesterday.month && dateTime.day == yesterday.day)
    {return "Yesterday ${DateFormat.jm().format(dateTime)}";}
    else {return DateFormat('dd/MM/yy, hh:mm a').format(dateTime);}


  }


  bool isEmojiPickerVisible = false;

  void toggleEmojiPicker() {
    setState(() {
      isEmojiPickerVisible = !isEmojiPickerVisible;
      if (isEmojiPickerVisible) {
        FocusScope.of(context).unfocus(); // Close the keyboard if it's open
      } else {
        chatTextField.requestFocus(); // Open the keyboard if emoji picker is closed
      }
    });
  }

  void onEmojiSelected(Emoji emoji) {
    messageController.text += emoji.emoji;
  }

  void onBackspacePressed() {
    messageController
      ..text = messageController.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: messageController.text.length),
      );
  }

  String convertEmbedUrlToGifUrl(String embedUrl) {
    // Extract the ID from the embed URL
    final RegExp regExp = RegExp(r'giphy\.com/embed/([^/]+)');
    final match = regExp.firstMatch(embedUrl);

    if (match != null && match.groupCount == 1) {
      String gifId = match.group(1)!;
      // Construct the direct URL
      return 'https://media.giphy.com/media/$gifId/giphy.gif';
    } else {
      throw 'Invalid embed URL format';
    }
  }

  bool isPng(String url) {
    // Convert the URL to lowercase and check if it ends with '.png'
    return url.toLowerCase().endsWith('.png');
  }
  String lastdatetime="";
  String time="";
  String time2="";
  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: commonBarWithTextleftforChat(context, Colors.white,data==null ?_data: data["items"][0]["sender"]["firstName"], press2: (){
      appBar: commonBarWithTextleftforChat(context, Colors.white,widget.name,press:(){ Get.back(result: false);}, press2: (){
        customBuilderSheet(context, 'Report User',"Submit",reportingMatter,onTap: (){
          Get.back(result: true);
          reportUser(reportingMatter[selectedIndex]);},);
        },
      onnametap: (){
        Get.to(() => MatchedPersonProfileScreen(id: widget.id.toString()));
      }
      ),
      body:dataa==null ? const Center(child: CircularProgressIndicator(color: color.txtBlue)) : SizedBox(
        height: size.height,
        width: size.width,
        child: Stack(
          children: [
            const Divider(thickness: 1.0, color: Color.fromRGBO(246, 246, 246, 1),),
            Column(
              children: <Widget>[
                const SizedBox(height: 5),
                _isLoadMoreRunning? const Center(child: CircularProgressIndicator(color: color.txtBlue)):const SizedBox(),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 9.h,top: 1.h),
                    child:
                    messages.isEmpty?const SizedBox():  ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      itemCount: messages.length,
                      padding:  EdgeInsets.only(top: 10,bottom:atachement||isEmojiPickerVisible?290: 90),
                      itemBuilder: (context, index){
                        time=formatTimestamp(int.parse(messages[index]["createdAt"]));
                        if(index<messages.length-1){time2=formatTimestamp(int.parse(messages[index+1]["createdAt"]));}
                        return Column(
                          children: [ time2==time && index<messages.length-1 ? const SizedBox():
                          Align(alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: buildText(time, 13, FontWeight.w500, color.dropDowngreytxt,fontFamily: FontFamily.hellix))),
                            Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 8),
                                child:
                                Align(
                                  alignment: (messages[index]["sender"].toString() == LocaleHandler.userId?Alignment.topRight:Alignment.topLeft),
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        left: messages[index]["sender"].toString() == LocaleHandler.userId ? 45 : 0,
                                        right: messages[index]["sender"].toString() == LocaleHandler.userId ? 0 : 45
                                    ),
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          spreadRadius: 1,
                                          blurRadius: 3,
                                          offset: const Offset(0,0), // changes position of shadow
                                        ),
                                      ],
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(messages[index]["sender"].toString() == LocaleHandler.userId? 20 :0),
                                          topRight: Radius.circular(messages[index]["sender"].toString() != LocaleHandler.userId? 20 : 0 ),
                                          bottomRight: const Radius.circular(20),
                                          bottomLeft: const Radius.circular(20)),
                                      color: (messages[index]["sender"].toString() == LocaleHandler.userId? color.lightestBlue:color.txtWhite),
                                    ) ,
                                    padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 10),
                                    // child: buildText(data[index]["content"],15, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
                                    child:isPng(messages[index]["content"])?
                                    GestureDetector(onTap: (){
                                      customSingleImage(context,messages[index]["content"]);},
                                        child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        // child: Image.network(messages[index]["content"], fit: BoxFit.cover,width: 100,height: 100)
                                        child: CachedNetworkImage(imageUrl:messages[index]["content"],fit: BoxFit.cover,width: 100,height: 100,filterQuality: FilterQuality.low,
                                          placeholder: (ctx, url) => const Center(child: CircularProgressIndicator(color: color.txtBlue,strokeWidth: 0.5)),
                                        ),
                                        ))
                                        : messages[index]["content"].startsWith('https://')?
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(convertEmbedUrlToGifUrl(messages[index]["content"]),
                                        fit: BoxFit.cover,width: 100,height: 100),
                                    )
                                        : buildText(messages[index]["content"],
                                        15, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
                                  ),
                                )
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                height:atachement==false?isEmojiPickerVisible?42.h:size.height*0.11:hi==0.0?40.h: hi,
                width: double.infinity,
                color: Colors.white,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 18,bottom: 8,top: 10),
                      child: Row(
                        children: <Widget>[
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                setState(() {chatTextField.unfocus();
                                  if(viewInsets!=0.0){hi=viewInsets;}});
                                atachement=!atachement;
                                isEmojiPickerVisible=false;
                              });
                            },
                            child: Container(
                              height: 56,
                              width: 56,
                              decoration: BoxDecoration(color: color.example7, borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.add, color: color.darkPurple, size: 30),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Consumer<CamController>(builder: (ctx,val,child){
                            return  val.image!=null?Expanded(
                              child: Container(
                                  alignment: Alignment.topLeft,
                                  height: 70,width: 70,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Image.file(val.image!),
                                     val.load? Container(
                                        color: Colors.black26,
                                        alignment: Alignment.center,
                                        height: 70,width: 40,
                                          child: const CircularProgressIndicator(color: color.txtBlue,strokeWidth: 2.2))
                                         :const SizedBox(),
                                    ],
                                  )),
                            ): Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: color.example7)
                                  ),
                                  child:  TextFormField(
                                    controller: messageController,
                                    cursorColor: color.curderGreen,
                                    onTap: (){
                                      setState(() {
                                        atachement=false;
                                        isEmojiPickerVisible=false;
                                        viewInsets = MediaQuery.of(context).viewInsets.bottom;
                                      });
                                    },
                                    focusNode: chatTextField,
                                    decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.only(left: 15,top: 3),
                                        hintText: "Write a message",
                                        hintStyle: TextStyle(color: color.example9,fontSize: 14,fontWeight: FontWeight.w400,),
                                        border: InputBorder.none
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),

                          GestureDetector(
                            onTap: (){
                              if(Provider.of<CamController>(context,listen: false).image==null) {
                                final text = messageController.text.trim();
                                if(text.isNotEmpty){
                                final capitalizedText = text[0].toUpperCase() + text.substring(1);
                                sendMessage(capitalizedText);}
                              }
                              else {
                                if(Provider.of<CamController>(context,listen: false).dataList.isNotEmpty && !Provider.of<CamController>(context,listen: false).load){
                                  sendMessage(Provider.of<CamController>(context,listen: false).dataList[0]);
                                  Provider.of<CamController>(context,listen: false).clearimg();}
                                else { showToastMsg("please wait..."); }
                              }
                            },
                            child: Container(
                              height: 56,
                              width: 56,
                              decoration: BoxDecoration(
                                color: color.example7,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.send, color: color.darkPurple, size: 30, ),
                            ),
                          ),
                          const SizedBox(width: 15),
                        ],
                      ),
                    ),
                    SizedBox(height:atachement? 25:0),
                    atachement? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(onTap: (){imgFromGallery(ImageSource.gallery);}, child: buildColumn(AssetsPics.gallery,"Gallery")),
                        GestureDetector(onTap: (){
                          if(Platform.isIOS){imgFromGallery(ImageSource.camera);}
                          else {Provider.of<CamController>(context,listen: false).pickImageFromCamera(CameraLensDirection.front);}
                          }, child: buildColumn(AssetsPics.camera,"Camera")),
                        GestureDetector(onTap: _searchAndPickGif,child: buildColumn(AssetsPics.giftext,"GIFs")),
                        GestureDetector(
                            onTap: (){
                              atachement=false;
                              toggleEmojiPicker();
                            },
                            child: buildColumn(AssetsPics.emoji,"Emoji")),
                      ],
                    ):const SizedBox(),
                    Visibility(
                      visible: isEmojiPickerVisible,
                      child: Expanded(
                        child: SizedBox(
                          // height: 250,
                          child: EmojiPicker(
                            onEmojiSelected: (category, emoji) => onEmojiSelected(emoji),
                            onBackspacePressed: onBackspacePressed,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildColumn(String img,String txt) {
    return Column(
                      children: [
                        Container(
                          height: 7.h,
                          width: 7.h,
                          padding: const EdgeInsets.all(14.5),
                          decoration: BoxDecoration(color: color.lightestBlue,
                          borderRadius: BorderRadius.circular(10)
                          ),
                          child: SvgPicture.asset(img),
                        ),
                        buildText(txt, 14, FontWeight.w500, color.txtBlack,fontFamily: FontFamily.hellix)
                      ],
                    );
  }

  Future<void> _searchAndPickGif() async {
    final gif = await GiphyGet.getGif(
      context: context,
      apiKey: 'rXniTs7pMFXMus9A8F6mZP7o9fgpN94V',  // Replace with your actual API key
       showEmojis: false,
      showStickers: false,
    );
    if (gif != null) {
      // print('Selected GIF URL: ${gif.url}');
      sendMessage(gif.embedUrl.toString());
    }
  }
}








