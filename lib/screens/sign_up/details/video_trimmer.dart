import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/controller/detail_controller.dart';
import 'package:slush/controller/edit_profile_controller.dart';
import 'package:video_trimmer/video_trimmer.dart';

class VideoTrimmerScreen extends StatefulWidget {
  const VideoTrimmerScreen({Key? key}) : super(key: key);

  @override
  State<VideoTrimmerScreen> createState() => _VideoTrimmerScreenState();
}

class _VideoTrimmerScreenState extends State<VideoTrimmerScreen> {
  @override
  void initState() {
    callSetState();
    super.initState();
  }
  callSetState(){Future.delayed(Duration(seconds: 2),(){    setState(() {});});
  }

  @override
  Widget build(BuildContext context) {
    final detailcntrl=Provider.of<detailedController>(context,listen: false);
    return Consumer<detailedController>(builder: (context,valuee,child){return Center(
      child: Container(
        padding: const EdgeInsets.only(bottom: 30.0),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(child: VideoViewer(trimmer: valuee.trimmer)),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      children: [
                        TrimViewer(
                          trimmer: valuee.trimmer,
                          viewerHeight: 50.0,
                          viewerWidth: MediaQuery.of(context).size.width,
                          durationStyle: DurationStyle.FORMAT_MM_SS,
                          maxVideoLength: const Duration(seconds: 15),
                          editorProperties: TrimEditorProperties(
                            borderPaintColor: Colors.yellow,
                            borderWidth: 4,
                            borderRadius: 5,
                            circlePaintColor: Colors.yellow.shade800,
                          ),
                          areaProperties: TrimAreaProperties.edgeBlur(thumbnailQuality: 10),
                          onChangeStart: (value) => detailcntrl.saveVlue(0, value),
                          onChangeEnd: (value) => detailcntrl.saveVlue(1, value),
                          // onChangePlaybackState: (value) => setState(() => _isPlaying = value),
                          onChangePlaybackState: (value)  =>detailcntrl.trimmVideoPLayPause(value),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                    onTap: (){detailcntrl.cancelSelectedTrimVideo();}, child: const Icon(Icons.clear, size: 45.0, color: color.txtBlue)),
                    GestureDetector(child: valuee.isPlaying
                          ? const Icon(Icons.pause, size: 60.0, color: color.txtBlue)
                          : const Icon(Icons.play_arrow, size: 60.0, color: color.txtBlue),
                      onTap: ()async {
                        detailcntrl.trimmVideoPLayPause(valuee.isPlaying?false:true);
                        detailcntrl.playTrimmmervideo(); } ),
                    GestureDetector( onTap: (){detailcntrl.saveVideo();},child: const Icon(Icons.check, size: 45.0, color: color.txtBlue)),
                  ],)
              ],
            ),

          ],
        ),
      ),
    );});
  }
}

//------------------------------------------------------------- Edit profile trimmer
class EditVideoTrimmerScreen extends StatefulWidget {
  const EditVideoTrimmerScreen({Key? key}) : super(key: key);

  @override
  State<EditVideoTrimmerScreen> createState() => _EditVideoTrimmerScreenState();
}

class _EditVideoTrimmerScreenState extends State<EditVideoTrimmerScreen> {
  @override
  Widget build(BuildContext context) {
    final editcntrl=Provider.of<editProfileController>(context,listen: false);
    return Scaffold(
      body: Consumer<editProfileController>(builder: (context,valuee,child){return Center(
        child: Container(
          padding: const EdgeInsets.only(bottom: 30.0,top: 60.0),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(child: VideoViewer(trimmer: valuee.trimmer)),
                  Center(
                    child: Container(
                      // color: Colors.red,
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          TrimViewer(
                            trimmer: valuee.trimmer,
                            durationTextStyle: const TextStyle(color: Colors.black),
                            viewerHeight: 50.0,
                            viewerWidth: MediaQuery.of(context).size.width,
                            durationStyle: DurationStyle.FORMAT_MM_SS,
                            maxVideoLength: const Duration(seconds: 15),
                            editorProperties: TrimEditorProperties(
                              borderPaintColor: Colors.yellow,
                              borderWidth: 4,
                              borderRadius: 5,
                              circlePaintColor: Colors.yellow.shade800,
                            ),
                            areaProperties: TrimAreaProperties.edgeBlur(thumbnailQuality: 10),
                            onChangeStart: (value) => editcntrl.saveVlue(0, value),
                            onChangeEnd: (value) => editcntrl.saveVlue(1, value),
                            // onChangePlaybackState: (value) => setState(() => _isPlaying = value),
                            onChangePlaybackState: (value)  =>editcntrl.trimmVideoPLayPause(value),

                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                          onTap: (){editcntrl.cancelSelectedTrimVideo();}, child: const Icon(Icons.clear, size: 45.0, color: color.txtBlue)),
                      GestureDetector(child: valuee.isPlaying
                          ? const Icon(Icons.pause, size: 60.0, color: color.txtBlue)
                          : const Icon(Icons.play_arrow, size: 60.0, color: color.txtBlue),
                          onTap: ()async {
                            editcntrl.trimmVideoPLayPause(valuee.isPlaying?false:true);
                            editcntrl.playTrimmmervideo();
                      } ),
                      GestureDetector( onTap: (){editcntrl.saveVideo(context);},child: const Icon(Icons.check, size: 45.0, color: color.txtBlue)),
                    ],)
                ],
              ),

            ],
          ),
        ),
      );}),
    );
  }
}
