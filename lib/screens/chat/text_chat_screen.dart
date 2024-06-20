import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart'as http;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
import 'package:slush/widgets/app_bar.dart';
import 'package:slush/widgets/bottom_sheet.dart';
import 'package:slush/widgets/text_widget.dart';
import 'package:slush/widgets/toaster.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


class TextChatScreen extends StatefulWidget {
  const TextChatScreen({Key? key}) : super(key: key);

  @override
  State<TextChatScreen> createState() => _TextChatScreenState();
}

class _TextChatScreenState extends State<TextChatScreen> {
  var viewInsets=0.0;
  double hi=0.0;
  bool atachement=false;
  final chatTextField = FocusNode();
  bool canPop=true;
  TextEditingController messageController=TextEditingController();

  List reportingMatter = [
    "Fake Account",
    "Nudity / inappropriate",
    "Swearing / Aggression",
    "Harassment","Other"
  ];

  var data;
  var formattedTime;
  List<String> messages = [];
  // final String serverUrl = 'https://socketio-chat-h9jt.herokuapp.com/some';
  final String serverUrl = 'ws://dev-api.slushdating.com:3000/socket.io/?EIO=4&transport=websocket';
  IO.Socket? socket;

  @override
  void initState() {
    connectToSocket();
    getChat();
    // _channel.stream.listen((data) {print('Received message:==== $data');});
    super.initState();
  }

  Future getChat()async{
    final url=ApiList.getSingleChat+"746/conversation?page=1&limit=10";
    print(url);
    var uri =Uri.parse(url);
    var response=await http.get(uri,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${LocaleHandler.accessToken}'});
    var i =jsonDecode(response.body);
    if(response.statusCode==200){
      setState(() {data=i["data"]["items"];});
    }
    else if(response.statusCode==401){showToastMsgTokenExpired();}
    else{}
  }

  void connectToSocket() {
    socket = IO.io(serverUrl, <String, dynamic>{
      'transport': ['websocket'],
      'autoConnect': true,
    });
    socket!.connect();
    socket!.onConnect((data) {print(':::::========================Connected to the socket server $data');});
    socket!.emit('client_event', {'message': 'Hello from Flutter!'});
    // Listen for events
    socket!.on('event_name', (data) {
      print(':::::=======================Received data for event_name: $data');
      _updateData(data);
    });

    socket!.onDisconnect((data) {print(':::::========================Disconnected from the socket server $data');});
    socket!.on('message', (data) {setState(() {messages.add(data);});});
  }

  // Function to send a message to the server.
  void sendMessage() {
    String message = messageController.text.trim();
    if (message.isNotEmpty) {
      // socket!.emit('chatMessage', message);
      socket!.emit('chatMessage', {message});
      print(":===========$message");
      messageController.clear();
    }
  }

  String _data = '';
  void _updateData(dynamic data) {
    setState(() {
      _data = data.toString(); // Type safety (if data is String)
    });
  }

  @override
  void dispose() {
    // socket.disconnect();
    // socket.dispose();
    _channel.sink.close();
    messageController.dispose();
    super.dispose();
  }

  String? imageBase64;
  File? _image;
  Future imgFromGallery(ImageSource src) async {
    try{
      var image = await ImagePicker().pickImage(source: src);
      if (image != null) {
        setState(() {
          _image = File(image.path);
          var ImageBytes = File(image.path).readAsBytesSync();
          String imageB64 = base64Encode(ImageBytes);
          imageBase64 = imageB64; // PictureId == "-1" ? uploadMultipleImage(_image!) : updateAvatar(_image!);
          Get.back();// selcetedIndex = "";
        });}}
    catch(error) {
      print("error: $error");
    }
  }

  final _channel = WebSocketChannel.connect(
    Uri.parse('ws://dev-api.slushdating.com:3000/socket.io/?EIO=4&transport=websocket'),
  );

  void _sendMessage() {
    _channel.sink.add(messageController.text.trim());
    // if (messageController.text.isNotEmpty) {
    //   _channel.sink.add(messageController.text);
    //   print("Meesage send==============${messageController.text.trim()}");
    // }
  }
  
  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return PopScope(
      canPop: canPop,
      onPopInvoked : (didPop){
     setState(() {
       if(atachement){
         canPop=false;
         atachement=false;
         canPop=true;
       }
     });
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: commonBarWithTextleftforChat(context, Colors.white, _data, press2: (){
          customBuilderSheet(context, 'Report User',"Submit",reportingMatter);
        }),
        body:data==null?Center(child: CircularProgressIndicator(color: color.txtBlue),): SizedBox(
          height: size.height,
          width: size.width,
          child: Stack(
            children: [
              const Divider(thickness: 1.0, color: Color.fromRGBO(246, 246, 246, 1),),
              Column(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding:  EdgeInsets.only(bottom: 9.h,top: 1.h),
                      child:
                      ListView.builder(
                        itemCount: data.length,
                        padding: const EdgeInsets.only(top: 10,bottom: 90),
                        itemBuilder: (context, index){
                          int timestamp = data[index]["createdAt"];
                          DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
                          var timee = DateTime.tryParse(dateTime.toString());
                          int hours = DateTime.now().difference(timee!).inHours;
                          // if (hours <= 24){
                          String formattedTimee = DateFormat.jm().format(dateTime);
                          // }
                          // String formattedTime = DateFormat('dd MMM').format(dateTime);

                          return Column(
                            children: [
                              index == 0 ? Align(
                                  alignment: Alignment.topCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: buildText(
                                      // "Yesterday 10:31AM",
                                        formattedTimee,
                                        13, FontWeight.w500, color.dropDowngreytxt,fontFamily: FontFamily.hellix),
                                  )): const SizedBox(),
                              Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 8),
                                  child:
                                  Align(
                                    alignment: (data[index]["sender"]["userId"].toString() == LocaleHandler.userId?Alignment.topLeft:Alignment.topRight),
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          left: data[index]["sender"]["userId"].toString() == LocaleHandler.userId ? 0 : 45,
                                          right: data[index]["sender"]["userId"].toString() == LocaleHandler.userId ? 45 : 0
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
                                            topLeft: Radius.circular(data[index]["sender"]["userId"].toString() == LocaleHandler.userId? 0 :20),
                                            topRight: Radius.circular(data[index]["sender"]["userId"].toString() != LocaleHandler.userId? 0 : 20 ),
                                            bottomRight: const Radius.circular(20),
                                            bottomLeft: const Radius.circular(20)),
                                        color: (data[index]["sender"]["userId"].toString() == LocaleHandler.userId? color.txtWhite:color.lightestBlue),
                                      ) ,
                                      padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 10),
                                      child: buildText(data[index]["content"],15, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
                                      // child: buildText(snapshot.data,15, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
                                    ),
                                  )
                              ),
                            ],
                          );
                        },
                      )
                      /*StreamBuilder(
                        stream: _channel.stream,
                        builder: (context, snapshot) {
                          return  snapshot.hasData?
                          ListView.builder(
                            itemCount: data.length,
                            padding: const EdgeInsets.only(top: 10,bottom: 90),
                            itemBuilder: (context, index){
                              int timestamp = data[index]["createdAt"];
                              DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
                              var timee = DateTime.tryParse(dateTime.toString());
                              int hours = DateTime.now().difference(timee!).inHours;
                              // if (hours <= 24){
                              String formattedTimee = DateFormat.jm().format(dateTime);
                              // }
                              // String formattedTime = DateFormat('dd MMM').format(dateTime);

                              return Column(
                                children: [
                                  index == 0 ? Align(
                                      alignment: Alignment.topCenter,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child: buildText(
                                          // "Yesterday 10:31AM",
                                            formattedTimee,
                                            13, FontWeight.w500, color.dropDowngreytxt,fontFamily: FontFamily.hellix),
                                      )): const SizedBox(),
                                  Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 8),
                                      child:
                                      Align(
                                        alignment: (data[index]["sender"]["userId"].toString() == LocaleHandler.userId?Alignment.topLeft:Alignment.topRight),
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              left: data[index]["sender"]["userId"].toString() == LocaleHandler.userId ? 0 : 45,
                                              right: data[index]["sender"]["userId"].toString() == LocaleHandler.userId ? 45 : 0
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
                                                topLeft: Radius.circular(data[index]["sender"]["userId"].toString() == LocaleHandler.userId? 0 :20),
                                                topRight: Radius.circular(data[index]["sender"]["userId"].toString() != LocaleHandler.userId? 0 : 20 ),
                                                bottomRight: const Radius.circular(20),
                                                bottomLeft: const Radius.circular(20)),
                                            color: (data[index]["sender"]["userId"].toString() == LocaleHandler.userId? color.txtWhite:color.lightestBlue),
                                          ) ,
                                          padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 10),
                                          // child: buildText(data[index]["content"],15, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
                                          child: buildText(snapshot.data,15, FontWeight.w500, color.txtgrey,fontFamily: FontFamily.hellix),
                                        ),
                                      )
                                  ),
                                ],
                              );
                            },
                          ):
                          CircularProgressIndicator(color: color.txtBlue);
                        },)*/
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  // height:atachement==false?10.h:hi==0.0?40.h: hi,
                  height:atachement==false?size.height*0.11:hi==0.0?40.h: hi,
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
                                  canPop=false;atachement=!atachement;
                                  // sendMessage();
                                });
                              },
                              child: Container(
                                height: 56,
                                width: 56,
                                decoration: BoxDecoration(
                                  color: color.example7,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.add, color: color.darkPurple, size: 30, ),
                              ),
                            ),
                            const SizedBox(width: 15,),
                            Expanded(
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
                                     canPop=true;
                                     atachement=false;
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
                            ),
                            GestureDetector(
                              onTap: (){
                                // _sendMessage();
                                sendMessage();
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

                          ],
                        ),
                      ),
                      SizedBox(height:atachement? 25:0),
                      atachement?Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(onTap: (){imgFromGallery(ImageSource.gallery);}, child: buildColumn(AssetsPics.gallery,"Gallery")),
                          GestureDetector(onTap: (){imgFromGallery(ImageSource.camera);}, child: buildColumn(AssetsPics.camera,"Camera")),
                          buildColumn(AssetsPics.giftext,"GIFs"),
                          buildColumn(AssetsPics.emoji,"Emoji"),
                        ],
                      ):const SizedBox()
                    ],
                  ),
                ),
              ),
            ],
          ),
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
}

