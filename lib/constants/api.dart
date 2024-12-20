
class ApiList {
  //-----Todo dev url
  // static const String baseUrl =  'https://dev-api.slushdating.com/api/v1/';
  // static const String baseUrl1 = 'https://dev-api.slushdating.com/';
  // static const String socket =  'http://dev-api.slushdating.com:3000';
  // static const String imgbaseUrl = 'https://virtual-speed-date.s3.eu-west-2.amazonaws.com/';
  // static const String android = 'c66eb930-a2bf-4181-b3d9-783c4330a359';
  // static const String ios = '5814e283-8616-4d02-aacb-dbfb8532c482';

  //-----Todo prod url
  static const String baseUrl = 'https://api.slushdating.com/api/v1/';
  static const String baseUrl1 = 'https://api.slushdating.com/';
  static const String socket = 'http://api.slushdating.com:3002/';
  static const String imgbaseUrl = 'https://slush-prod.s3.eu-west-2.amazonaws.com/';
  static const String android = '482a292e-4c3a-48f0-ad0b-8b0f4b653fd8';
  static const String ios = '4cee1d81-6350-4319-970d-3421754c0fa7';


  //--- Events Todode
  static const String getEvent= '${baseUrl}events?date=';
  static const String cancelEvent= '${baseUrl}events/book/';
  static const String eventDetail= '${baseUrl}events/';
  static const String eventBook= '${baseUrl}events/book';
  static const String geteventhistory= '${baseUrl}events/history?page=';
  static const String result= '${baseUrl}events/result?';
  static const String saveEvent= '${baseUrl}events/save-event/';
  static const String unsaveEvent= '${baseUrl}events/unsave-event/';
  static const String savedEvents= '${baseUrl}events/saved_events';
  static const String notification= '${baseUrl1}notifications?';
  static const String notificationSetting = '${baseUrl1}notifications/settings';
  static const String fixtures= '${baseUrl}events/';
  static const String rtcToken= '${baseUrl1}rtc/token';

  //--- Auth todo
  static const String registerUser = '${baseUrl}auth/register';
  static const String fileuploadinchat = '${baseUrl}profile-pictures/batch/file-upload';
  static const String registerUserDetails = '${baseUrl}auth/register/complete';
  static const String detailCompleted = '${baseUrl}auth/detail/complete';
  static const String location = '${baseUrl}auth/update/location';
  static const String deactivateAccount =  '${baseUrl}auth/deactivate-account';
  static const String sendverifyemail = '${baseUrl}auth/send-verify-email';
  static const String forgotPassword = '${baseUrl}auth/forgot-password';
  static const String verifyOTPpassword = '${baseUrl}auth/verify/forgot-password';
  static const String resetpassword = '${baseUrl}auth/reset-password';
  static const String checkphone = '${baseUrl}auth/check/phone';
  //--- login
  static const String login = '${baseUrl}auth/login';
  static const String logout = '${baseUrl}auth/logout';
  static const String socialLogin = '${baseUrl}auth/social-login';

  //--- user todo
  static const String reportUser= '${baseUrl}users/';
  static const String getUser= '${baseUrl}users/';
  static const String updateProfileDetail= '${baseUrl}users/me';
  static const String checkEmail = '${baseUrl}users/check/email-verified';
  static const String action= '${baseUrl}users/';
  static const String changeEmail= '${baseUrl}users/change-email';
  static const String updateInterest= '${baseUrl}users/interests';
  static const String updateEthnicity= '${baseUrl}users/ethnicity';
  static const String deleteProfile= '${baseUrl}users/delete-profile';
  static const String changePassword= '${baseUrl}users/change-password';
  static const String subscribe= '${baseUrl}users/subscribe';
  static const String updateSubscription= '${baseUrl}users/update-subscription';
  static const String cancelSubscription= '${baseUrl}users/cancel-subscription';
  static const String sparkPurchase= '${baseUrl}users/spark-purchase';
  static const String swipecount= '${baseUrl}users/swipe-count';
  static const String paymentHIstory= '${baseUrl}users/payment-history/';
  static const String remainspark= '${baseUrl}users/remain-spark';
  static const String subscriptiondetail= '${baseUrl}users/subscription-detail';
  static const String updatesubscription= '${baseUrl}users/update-subscription';
  static const String cancelsubscription= '${baseUrl}users/cancel-subscription';
  static const String imagevarificationUpload= '${baseUrl}users/verification-image-upload'; //todo not working right now

  //--- fcm todo
  static const String fcmToken = "${baseUrl}fcm-token";

  //--- Profile Picture
  static const String multipleProfilePicture= '${baseUrl}profile-pictures/batch/store';
  static const String updateAvatar= '${baseUrl}profile-pictures/';
  static const String destroyPicture= '${baseUrl}profile-pictures/batch/destroy';
  //--- Interest
  static const String getInterest= '${baseUrl}interests';
  //--- Ethencity
  static const String getEthencity= '${baseUrl}ethnicity';
  //--- Profile Video
  static const String uploadVideo= '${baseUrl}profile-videos/batch/store';
  static const String destroyVideo= '${baseUrl}profile-videos/batch/destroy';

  // -- chat todo
  static const String getChat= '${baseUrl}chats';
  static const String getSingleChat= '${baseUrl}chats/';

  // Video-verse todo
  static String getVideo= '${baseUrl}video-verse?minAge=';
  static String swippedVideo= '${baseUrl}video-verse/swiped-video';
  static String interact= '${baseUrl}video-verse/interact';




// static const String getSingleChat= baseUrl + 'chats/746/conversation?page=1&limit=10';
// static const String fixtures= baseUrl + 'events/1008/report/fixtures';
// static const String fixtures= baseUrl1 + 'events/1008/fixtures';
// static const String result= baseUrl + 'events/result?page=1&limit=10';
// static const String getVideo= baseUrl + 'video-verse?minAge=18&maxAge=50&distance=5000&latitude=37.4219983&longitude=-122.084&gender=male&page=1&limit=15';
// static String getVideo= baseUrl + 'video-verse?minAge=18&maxAge=50&distance=5000&latitude=${LocaleHandler.latitude}&longitude=${LocaleHandler.longitude}';
// static String getVideo= baseUrl + 'video-verse?minAge=18&maxAge=50&distance=5000&latitude=37.4219983&longitude=-122.084';

}