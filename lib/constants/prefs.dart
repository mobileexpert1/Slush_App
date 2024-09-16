import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  // Method to get,save,remove the loggin referesh token
  static setrefreshToken(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("refreshToken", value);
  }

  static getrefreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken');
  }


  // Method to get,save,remove the feedTutorial screen
  static setReelAlreadySeen(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("already", value);
  }

  static getReelAlreadySeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('already');
  }

  // Method to set and get nextAction register complete
  static setNextAction(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("nextAction", value);
  }

  static getNextAction() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('nextAction');
  }
  // Method to set and get nextDetailAction vacation complete
  static setNextDetailAction(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("nextDetailAction", value);
  }

  static getNextDetailAction() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('nextDetailAction');
  }
  // ============================================================================================================================================
  static setValue(String key,String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  static getValue(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static setList(List<String> list) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('notificationlist', list);
  }

  static Future<List<String>> getList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('notificationlist') ?? [];
  }

/*  static setListValue(String key,String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(key, value);
  }
  static getListValue(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }*/
// =========================================================================================================================


  static clearPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }

}