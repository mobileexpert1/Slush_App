/*
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:slush/constants/color.dart';
import 'package:slush/constants/image.dart';


class ImageViewScreen extends StatefulWidget {
  const ImageViewScreen({super.key,required this.indexId,required this.pictureItems});
  final int indexId;
  final List pictureItems;
  @override
  State<ImageViewScreen> createState() => _ImageViewScreenState();
}

class _ImageViewScreenState extends State<ImageViewScreen> {
  int currentPage = 0;
  int indicatorIndex = 0;
  PageController? iController;
  @override
  void initState() {
    iController = PageController(initialPage: widget.indexId);

    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      // appBar: commonBar(context,Colors.transparent),
      // appBar: AppBar(),
      backgroundColor: color.txtBlack,
      body: Container(
        height: size.height,
        width: size.width,
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    height: size.height/1.5,
                    width: size.width,
                    child: Stack(
                      fit: StackFit.expand,
                      alignment: Alignment.center,
                      children: [
                        PageView.builder(
                          controller: iController,
                          itemCount:widget.pictureItems.length,
                          // onPageChanged: (indexx) {
                          //   setState(() {
                          //     // currentPage = indexx;
                          //   });
                          //   // indicatorIndex = indexx;
                          // },
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {},
                              child: CachedNetworkImage(
                                imageUrl: widget.pictureItems[index]["key"],
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                                placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: color.txtBlue)),
                              ),
                            );
                            // child: Image.network(LocaleHandler.dataa["profilePictures"][index]["key"],fit: BoxFit.cover,));
                          },
                        ),

                        // IgnorePointer(
                        //     child: SvgPicture.asset(AssetsPics.eventbg,
                        //         fit: BoxFit.cover)),
                        // Positioned(
                        //   bottom: 40.0,
                        //   child: IgnorePointer(
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.center,
                        //       children: List<Widget>.generate(
                        //           LocaleHandler.dataa["profilePictures"].length,
                        //               (int index) {
                        //             return Container(
                        //               margin: const EdgeInsets.only(
                        //                   left: 2.5, right: 2.5, bottom: 12.0),
                        //               width: indicatorIndex == index ? 15 : 12.0,
                        //               height: indicatorIndex == index ? 15 : 12.0,
                        //               decoration: BoxDecoration(
                        //                 color: indicatorIndex == index
                        //                     ? color.txtWhite
                        //                     : Colors.transparent,
                        //                 borderRadius: BorderRadius.circular(20),
                        //                 border: Border.all(
                        //                   color: indicatorIndex == index
                        //                       ? Colors.blue
                        //                       : Colors.white,
                        //                   width: indicatorIndex == index ? 3 : 1.5,
                        //                 ),
                        //               ),
                        //             );
                        //           }),
                        //     ),
                        //   ),
                        // ),
                      ],
                    )),
              ],
            ),
            Positioned(
              top: 50,
              left: 15,
              child: GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SvgPicture.asset(AssetsPics.arrowLeft,color: Colors.white,height: 18,),
                ),
              ),
            )
          ],
        )
      ),
    );
  }

}
*/
