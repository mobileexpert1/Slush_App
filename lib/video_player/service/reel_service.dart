import 'dart:convert';
import 'dart:developer';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import '../config/cache_config.dart';
import 'package:http/http.dart'as http;

class ReelService {
var data;

  Future getVideos()async{
    final url=ApiList.getVideo;
    print(url);
    var uri=Uri.parse(url);
    var response=await http.get(uri,headers: {'Content-Type': 'application/json', "Authorization": "Bearer ${LocaleHandler.accessToken}"});
   var i=jsonDecode(response.body);
    if(response.statusCode==200){
      data=i["data"]["items"];
      for (var i = 0; i < data.length-1; i++) {
        _reels.add(data[i]["video"].toString());
      }
      // getVideoList();
      }
    else{}
  }


// Here, I use some stock videos as an example.
// But you need to make this list empty when you will call api for your reels.
  var _reels = <String>[
    // "https://virtual-speed-date.s3.eu-west-2.amazonaws.com/users/62db4b8f-9f0e-4abd-8c8d-4b1d94051e0a.bin",
    // "https://virtual-speed-date.s3.eu-west-2.amazonaws.com/users/c0409fc9-43c0-4095-bc28-1621e30dd95f.mp4",
    // "https://virtual-speed-date.s3.eu-west-2.amazonaws.com/users/4e70f03f-7230-4128-bb15-b02d497df7b4.mp4",
    // "https://virtual-speed-date.s3.eu-west-2.amazonaws.com/users/0c364252-0cab-4e67-b516-0d78a08a9fb5.mp4",

    'https://assets.mixkit.co/videos/preview/mixkit-aerial-panorama-of-a-landscape-with-mountains-and-a-lake-4249-large.mp4/',
    'https://assets.mixkit.co/videos/preview/mixkit-curvy-road-on-a-tree-covered-hill-41537-large.mp4',
    // 'https://assets.mixkit.co/videos/preview/mixkit-frying-diced-bacon-in-a-skillet-43063-large.mp4',
    // 'https://assets.mixkit.co/videos/preview/mixkit-fresh-apples-in-a-row-on-a-natural-background-42946-large.mp4',
    // 'https://assets.mixkit.co/videos/preview/mixkit-rain-falling-on-the-water-of-a-lake-seen-up-18312-large.mp4',
  ];

  Future getVideosFromApI(List<String> reel) async {
    // call your api here
    // then add all links to _reels variable
    _reels=reel;
    for (var i = 0; i < _reels.length; i++) {
      cacheVideos(_reels[i], i);
    //   print(_reels[i ]);
      // you can add multiple logic for to cache videos. Right now I'm caching all videos
    }
  }




  cacheVideos(String url, int i) async {
    FileInfo? fileInfo = await kCacheManager.getFileFromCache(url);
    if (fileInfo == null) {
      log('downloading file ##------->$url##');
      await kCacheManager.downloadFile(url);
      log('downloaded file ##------->$url##');
      if (i + 1 == _reels.length) {
        log('caching finished');
      }
    }
  }

  List<String> getReels(List<String> reel) {
  // List<String> getReels() {
  //   return _reels;
    return reel;
  }
}
