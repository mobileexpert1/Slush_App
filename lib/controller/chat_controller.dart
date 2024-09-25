import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:slush/constants/LocalHandler.dart';
import 'package:slush/constants/api.dart';
import 'package:http/http.dart'as http;
import 'package:slush/constants/image.dart';
import 'package:slush/widgets/toaster.dart';

class ChatController extends ChangeNotifier{
  bool isListEmpty = true;
  bool itemDelted = false;
  List data = [];
  int totalpages = 0;
  int currentpage = 0;
  int totalItems = -1;
  int _page = 1;
  bool _isLoadMoreRunning = false;
  ScrollController? _controller;
  Timer? _timer;
  SlidableController _slidableController = SlidableController();


  Future getChat() async {
    final url = "${ApiList.getSingleChat}?page=$_page&limit=50";
    print(url);
    var uri = Uri.parse(url);
    var response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${LocaleHandler.accessToken}'
    });
    var i = jsonDecode(response.body)["data"];
    if (response.statusCode == 200) {
        data = i["items"];
        if (i["meta"]["totalItems"] == 0) {isListEmpty = true;
        } else {isListEmpty = false;}
        totalpages = i["meta"]["totalPages"];
        totalItems = i["meta"]["totalItems"];
        currentpage = i["meta"]["currentPage"];
        if (totalItems == 0) {
          data.length = 1;
        }
    } else if (response.statusCode == 401) {
      showToastMsgTokenExpired();
    } else {}
    notifyListeners();
  }

  Future loadmore() async {
    if (_page < totalpages &&
        _isLoadMoreRunning == false &&
        currentpage < totalpages &&
        _controller!.position.extentAfter < 300) {
        _isLoadMoreRunning = true;
      _page = _page + 1;
      final url = "${ApiList.getSingleChat}?page=$_page&limit=50";
      print(url);
      var uri = Uri.parse(url);
      var response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${LocaleHandler.accessToken}'
      });
        _isLoadMoreRunning = false;
      if (response.statusCode == 200) {
          var i = jsonDecode(response.body)['data'];
          currentpage = i["meta"]["currentPage"];
          final List fetchedPosts = i["items"];
          if (fetchedPosts.isNotEmpty) {
              data.addAll(fetchedPosts);
          }
      }
    }
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    getChat();
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      getChat();
    });
    notifyListeners();
  }

  void chatDelete(BuildContext context ,int id, int i) async {
    final url = "${ApiList.getSingleChat}$id/deleteconversation";
    print(url);
    var uri = Uri.parse(url);
    var response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${LocaleHandler.accessToken}'
    });
    if (response.statusCode == 200) {
      snackBaar(context, AssetsPics.removed, false);
      getChat();
    } else {}
    notifyListeners();
  }

}