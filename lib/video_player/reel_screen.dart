import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';
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

  @override
  void initState() {
    callFunction();
    super.initState();
  }

  void callFunction()async{
    await Future.delayed(const Duration(milliseconds: 100));
    Provider.of<ReelController>(context,listen: false).getVidero(context,1,
        LocaleHandler.startage, LocaleHandler.endage,LocaleHandler.distancevalue,
        // LocaleHandler.latitude,LocaleHandler.longitude,LocaleHandler.filtergender==""?gender:LocaleHandler.filtergender);
        LocaleHandler.latitude,LocaleHandler.longitude,LocaleHandler.filtergender);
  }

  @override
  Widget build(BuildContext context) {
    final size=MediaQuery.of(context).size;
    return Stack(
      children: [
        SizedBox(height: size.height, width: size.width, child: Image.asset(AssetsPics.background, fit: BoxFit.cover)),
        Consumer<ReelController>(
            builder: (context,value,child){ return
              value.data == null ? const Center(child: CircularProgressIndicator(color: color.txtBlue)) :
              // value.totallen==-2?buildBuildText():
              FeedScreen(index: 0, reels: ReelService().getReels(value.reels), data: value.data);
            }),
        Consumer<reelTutorialController>(
            builder: (context,value,child){
              print(LocaleHandler.feedTutorials);
              print(Provider.of<ReelController>(context).stopReelScroll);
              return
              mounted? Container(
              child: LocaleHandler.feedTutorials || Provider.of<ReelController>(context).stopReelScroll ?
              feedTutorials(context):const SizedBox(),
        ):const SizedBox();}),
      ],
    );
  }

  Widget buildBuildText() => SizedBox(
    width: MediaQuery.of(context).size.width,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(height: 300, width: 300, alignment: Alignment.center, child: SvgPicture.asset("assets/images/nodata.svg",color:  const Color(0xff009F9D))),
        buildText("No Data Availabe", 20, FontWeight.w600, color.txtBlack),
        buildText2("There is no data to show you\n right now.", 20, FontWeight.w600, color.txtgrey2),
        GestureDetector(
          onTap: (){setState(() {
          LocaleHandler.distancevalue=500;
          LocaleHandler.startage=18;
          LocaleHandler.endage=100;
          LocaleHandler.filtergender="";
          LocaleHandler.isChecked=false;
          LocaleHandler.distancee=500;
          LocaleHandler.selectedIndexGender=-1;
          });
          Provider.of<ReelController>(context,listen: false).getVidero(context,1,LocaleHandler.startage,
              LocaleHandler.endage, LocaleHandler.distancevalue,
              LocaleHandler.latitude,LocaleHandler.longitude, LocaleHandler.filtergender);
          },
          child: Container(
            margin: const EdgeInsets.only(top: 40),
            decoration:  BoxDecoration(color: const Color(0xff009F9D),
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 20),
            child: const Text("Refresh",style: TextStyle(
              color: color.txtWhite,
              fontSize: 18,fontWeight: FontWeight.w500,
              fontFamily: FontFamily.baloo2,
              decoration: TextDecoration.underline,
              decorationColor: color.txtBlue,
            ),),
          ),
        ),
      ],
    ),
  );
}

class Debounce {
  final int milliseconds;
  Timer? _timer;
  Debounce({required this.milliseconds});
  void run(VoidCallback action) {if (_timer != null) {_timer!.cancel();}
  _timer = Timer(Duration(milliseconds: milliseconds), action);}}