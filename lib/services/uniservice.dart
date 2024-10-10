import 'package:uni_links/uni_links.dart';

class UniServices{
  static String _code="";
  static String get code=>_code;
  static bool get hascode=>_code.isNotEmpty;

  static void reset()=> _code="";

  static uniHandler(Uri? uri){
    if(uri==null||uri.queryParameters.isEmpty)return ;

    Map <String,String>param=uri.queryParameters;

    String recievecode=param["code"]??"";

    print(recievecode);
    print(param);
  }

  static init()async{
    try{
      final Uri? uri =await getInitialUri();
      uniHandler(uri);
    } catch (e){}
    uriLinkStream.listen((Uri? uri){
      uniHandler(uri);
    });
  }
}