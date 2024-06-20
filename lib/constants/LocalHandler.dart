import 'dart:io';

class LocaleHandler {
  static bool bioAuth=false;
  static String bioAuth2="false";
  static bool noInternet=false;

  static int bottomindex = 0;

  // Event
  static int miliseconds = 0;

  // login Token
  static String accessToken = "";
  static String bearer = "Bearer ${accessToken}";
  static String refreshToken = "";
  static String resetPasswordtoken = "";
  static String nextAction = "";
  static String nextDetailAction = "fill_ideal_vacation";
  static String userId = "";
  static String subscriptionPurchase = "";
  static String role = "";
  static String emailVerified = "";
  static int distancee = 50000;

  // Register
  static String name = "";
  static String dateTimee = "";
  static String avatar = "";

  // static DateTime? dateTimee;
  static String height = "";
  static String education = "";
  static String heighttype = "cm";
  static bool showheight = true;
  static String showheights = "true";
  static String gender = "";
  static bool showgender = true;
  static String showgenders = "true";
  static String lookingfor = "";
  static bool showlookingfor = true;
  static String sexualOreintation = "";
  static bool showsexualOreintation = true;

  static bool isVerified = false;
  static String showsexualOreintations = "true";
  static List entencity = [];
  static String location = "";
  static File? introImage;
  static File? introVideo;
  static String password = "";
  static String jobtitle = "";
  static bool displayOnScreen = false;

  // VAcation details
  static String ideal = "";
  static String distance = "5000";
  static String cookingSkill = "";
  static String smokingopinion = "";

// location
  static String latitude = "36.7783";
  static String longitude = "119.4179";

  //String
  static Map<String, dynamic> dataa = {};
  static List items = [];
  static List itemss = [];

  // Bool
  static bool isThereAnyEvent = false;
  static bool isThereCancelEvent = false;
  static bool unMatchedEvent = false;
  static bool isBanner = false;
  static bool bannerInReel = false;
  static bool isProtected = false;
  static bool subScribtioonOffer = false;
  static bool passwordField = false;
  static bool sparkAndVerification = false;
  static bool EditProfile = false;
  static bool basicInfo = true;
  static bool noMatches = true;
  static bool nolikes = true;
  static bool withSubScription = false;
  static bool passMatched = false;
  static bool cpassMatched = false;
  static bool reportedSuccesfuly = false;

  static bool matchedd = false;
  static bool loaderr = false;
  static bool feedTutorials = true;
  static bool scrollLimitreached = false;

  //Int
  static int curentIndexNum = 0;
  static int pageIndex = 0;
  static int pageCurrentIndex = 0;

  //Double
  //List
  //Map
  //List Map

// create Account details
  static String passwordErrorText = '';
  static String freeEventImage = '';

  //Error Messaeg from APi
  static String ErrorMessage = '';

  // notification setting
  static List switchitem = [];

  // feed Filter
  static int distancevalue=250;
  static int agevalue=30;
  static int selectedIndexGender=-1;
  static bool isChecked=false;

}

class My{
  static Map<String, dynamic> i = {};
}
