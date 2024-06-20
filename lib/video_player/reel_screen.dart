import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/controller/controller.dart';
import 'package:slush/screens/feed/feed_screen.dart';
import 'package:slush/screens/feed/tutorials/controller_class.dart';
import 'package:slush/screens/feed/tutorials/tutorial.dart';
import 'package:slush/video_player/service/reel_service.dart';
import '../widgets/text_widget.dart';

class ReelViewScreen extends StatefulWidget {
  const ReelViewScreen({Key? key}) : super(key: key);

  @override
  State<ReelViewScreen> createState() => _ReelViewScreenState();
}

class _ReelViewScreenState extends State<ReelViewScreen> {
  var gender;
  @override
  void initState() {
    if(LocaleHandler.gender=="male"){gender="female";}
    else if(LocaleHandler.gender=="female"){gender="male";}
    else{gender="";}
    callFunction();
    super.initState();
  }

  void callFunction(){
    Provider.of<reelController>(context,listen: false).getVidero(context,1,50,5000,LocaleHandler.latitude,LocaleHandler.longitude,gender);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer<reelController>(
            builder: (context,value,child){
              return
              value.data==null?const Center(child: CircularProgressIndicator(color: color.txtBlue)):
              value.totallen==0?Center(child: buildText("no data!",18,FontWeight.w500,color.txtgrey)):
              FeedScreen(index: 0, reels: ReelService().getReels(value.reels), data: value.data);
            }),
        Consumer<reelTutorialController>(
            builder: (context,value,child){return Container(
          child: LocaleHandler.feedTutorials || LocaleHandler.scrollLimitreached ?
          feedTutorials(context):const SizedBox(),
        );}),
      ],
    );
  }
}

class Debounce {
  final int milliseconds;
  Timer? _timer;
  Debounce({required this.milliseconds});
  void run(VoidCallback action) {if (_timer != null) {_timer!.cancel();}
  _timer = Timer(Duration(milliseconds: milliseconds), action);}}