import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ApiService {
  final String apiUrl;

  ApiService(this.apiUrl);

/*  Future<Map<String, dynamic>> postDataMethod(Map<String, dynamic> data, BuildContext context) async {
    print(data);
    print(apiUrl);
    print("Post----");
    String? userToken = await SharedPreferencesManager.getStringValue(Constants.userTokenKey) ?? "";
    print(userToken);

    try {
      final response = await http.post(Uri.parse(apiUrl), // Replace 'endpoint' with your API endpoint
        body: jsonEncode(data),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ' + userToken},
      );



      print(response.statusCode );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      print(responseData);
      print("4444444");
      if (response.statusCode == 200) {
        // If server returns an OK response, parse the response
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print(responseData);
        return responseData;
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print(responseData);

        if(response.statusCode == 401) {

          SharedPreferencesManager.saveStringValue("", Constants.userTokenKey);
          ToastManager.showLongToast('Session expired. please login again');
          NavigationHelper.navigateToPage(context, LoginScreen());
        }
        else  if(responseData["message"] ==  "Access not provided!!! Please contact admin") {
          SharedPreferencesManager.saveStringValue("", Constants.userTokenKey);
          ToastManager.showLongToast(responseData["message"]);
          Map<String, dynamic> errormap = {
            "errorMessage": "Access not provided!!! Please contact admin",

          };
          return errormap;

        }

        throw Exception('Failed to post data: ${response.statusCode}');
      }
    } catch (error) {
      // Handle errors that may occur during the API call
      throw Exception('Failed to post data: $error');
    }
  }

  Future<Map<String, dynamic>> getDataMethod(BuildContext context) async {

    print(apiUrl);
    print("Get--");
    String? userToken = await SharedPreferencesManager.getStringValue(Constants.userTokenKey) ?? "";
    print(userToken);
    try {
      final response = await http.get(
        Uri.parse(apiUrl), // Replace 'endpoint' with your API endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ' + userToken
        },
      );


      if (response.statusCode == 200) {
        // If server returns an OK response, parse the response
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print(responseData);
        return responseData;
      } else {

        if(response.statusCode == 401) {
          SharedPreferencesManager.saveStringValue("", Constants.userTokenKey);
          ToastManager.showLongToast('Session expired. please login again');
          NavigationHelper.navigateToPage(context, LoginScreen());
        }

        // If the server did not return a 200 OK response, throw an exception
        throw Exception('Failed to post data: ${response.statusCode}');


      }
    } catch (error) {
      // Handle errors that may occur during the API call
      throw Exception('Failed to post data: $error');
    }
  }*/


 /* Future<void> signUpApi(Map<String, String> userData, BuildContext ctxt) async {



    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      print(apiUrl);


      // Biometric Images
      for (var image in  LocalDataHandler.bioMetricImages) {
        request.files.add(await http.MultipartFile.fromPath('biometric_images[]', image.path));
      }

      // Licence Images
      for (var image in  LocalDataHandler.securityLicenceImages) {
        request.files.add(await http.MultipartFile.fromPath('security_licence_images[]', image.path));
      }

      // Passport Images
      for (var image in  LocalDataHandler.passportImages) {
        request.files.add(await http.MultipartFile.fromPath('passport_images[]', image.path));
      }

      // Driving Licence Images
      for (var image in  LocalDataHandler.drivinfLicenceImages) {
        request.files.add(await http.MultipartFile.fromPath('driving_licence_images[]', image.path));
      }

      // address Proff
      for (var image in  LocalDataHandler.addressImages) {
        request.files.add(await http.MultipartFile.fromPath('address_images[]', image.path));
      }

      List<XFile> profileImagesHolder = [];
      profileImagesHolder.add(LocalDataHandler.profilePhotos["front"]!);
      profileImagesHolder.add(LocalDataHandler.profilePhotos["left"]!);
      profileImagesHolder.add(LocalDataHandler.profilePhotos["right"]!);


      // profileImagesHolder.add(LocalDataHandler.drivinfLicenceImages[0]);
      // profileImagesHolder.add(LocalDataHandler.drivinfLicenceImages[0]);
      // profileImagesHolder.add(LocalDataHandler.drivinfLicenceImages[0]);

      // Profile Images
      for (var image in  profileImagesHolder) {
        request.files.add(await http.MultipartFile.fromPath('profile_images[]', image.path));
      } // Profile Images






      Map<String, String> tempVisadata = {};
      tempVisadata =  LocalDataHandler.visaDetails;



      Map<String, String> tempUserData = {};
      tempUserData =  userData;

      // Map<String, String> userData = {
      //   'firstName' : _firstname.text.trim(),
      //   'lastName' : _lastName.text.trim(),
      //   'location' : _location.text.trim(),
      //   'passowrd' : _password.text.trim(),
      //   'referalCode' : _referalCode.text.trim(),
      //
      // };

      String jsonString = json.encode(LocalDataHandler.workHistoryDetails);
      print(jsonString);
      Map<String, String> fieldsMap = {
        'national_insurance' : LocalDataHandler.nationalInsuranceNumber,
        'share_code' : LocalDataHandler.shareCode,
        'license_type' : LocalDataHandler.licenceType,
        'sia_badge' : LocalDataHandler.licenceBadgeNumber,
        'licence_qualification' : LocalDataHandler.licenceQualification,
        "email":LocalDataHandler.userEmail  ,
        "phone_number":LocalDataHandler.userPhoneNumber  ,
        "country_code":LocalDataHandler.userCallingCode,

        // biometric resistence number
        "biometric_badge_number" : LocalDataHandler.biometricBadgeNumber,

        "first_name":tempUserData["firstName"] ?? "",
        "last_name":tempUserData["lastName"] ?? "",
        "location":tempUserData["location"] ?? "",
        "address2":tempUserData["address2"] ?? "",
        "town":tempUserData["town"] ?? "",


        "password":tempUserData["passowrd"] ?? "",
        "pincode":tempUserData["pinCode"] ?? "",
        "referalCode":tempUserData["referalCode"] ?? "",
        "latitude":tempUserData["latitude"] ?? "",
        "longitude":tempUserData["longitude"] ?? "",


        "criminalRecord":tempUserData["criminalRecord"] ?? "",
        "ccj":tempUserData["ccj"] ?? "",
        "kinName":tempUserData["kinName"] ?? "",
        "kinPhoneNumber":tempUserData["kinPhoneNumber"] ?? "",
        "kinCountryCode":tempUserData["kinCountryCode"] ?? "",
        "relationship":tempUserData["relationship"] ?? "",


        "qualification":tempUserData["qualification"] ?? "",
        "dob":tempUserData["dob"] ?? "",
        "gender":tempUserData["gender"] ?? "",
        "county" : tempUserData["county"] ?? "",
        "work_history" : jsonString,
        "address_history" : LocalDataHandler.jsonStringAddress!,



        // Visa Details
        "visa_first_name": tempVisadata["firstName"] ?? "",
        "visa_last_name": tempVisadata["lastName"] ?? "",
        "visa_date_of_birth": tempVisadata["dob"] ?? "",
        "visa_gender": tempVisadata["gender"] != "" ? (tempVisadata["gender"] == "Male" ? "1" : "2") : "",
        "visa_from": tempVisadata["origin"] ?? "",
        "visa_destination": tempVisadata["destination"] ?? "",
        "visa_departure_date": tempVisadata["departureDate"] ?? "",
        "visa_return_date": tempVisadata["returnDate"] ?? "",








      };

      print("333333333");
      print(fieldsMap);
      print(apiUrl);

      request.fields.addAll(fieldsMap);


      var response = await request.send();
      print("#333333");
      print(response.statusCode);
      //  print(response.stream.bytesToString().toString());
      print(request);
      if (response.statusCode == 200) {
        // Handle successful response from the API
        // You can parse the response if needed
        //  print('API Response: ${await response.stream.bytesToString()}');


        // final Map<String, dynamic> responseData = jsonDecode(response.stream.bytesToString());
        // print(responseData);
        // return responseData;
        showModalBottomSheet(
          backgroundColor: Colors.transparent,
          context: ctxt,


          isScrollControlled: true,

          builder: (BuildContext context) {

            return StatefulBuilder(
              builder: (BuildContext contect, StateSetter setState) {
                return Container(

                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                      color: Constants.BLACK.withOpacity(0.5),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [


                      Container(),
                      Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Constants.WHITE,
                              borderRadius: BorderRadius.circular(20)
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: Container(
                                  child: Image.asset(
                                    'assets/onboarding/verify_wait.png',
                                    width: 93.0,
                                    height: 96.0,
                                    fit: BoxFit.fitHeight,
                                  ),

                                  //    child: SvgPicture.asset("assets/help/withdraw.svg", height: 96, width: 93,  )
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 20,
                                    left: 50, right: 50),
                                child: Text(
                                  "We're Reviewing Your Documents",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.lato(
                                      color:   Constants.BLACK ,
                                      fontSize: 19,
                                      fontWeight: FontWeight.w800,
                                      fontStyle: FontStyle.normal,
                                      height: 1.7
                                  ),
                                ),
                              ),


                              Padding(
                                padding: const EdgeInsets.only(left: 30, right: 30, top: 10),
                                child: Text(
                                  "We're diligently reviewing your documents. Expect a swift response. Thank you for your patience, We will get back ASAP.",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.lato(
                                      color:   Constants.BLACK ,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      fontStyle: FontStyle.normal,
                                      height: 1.7
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.only(left: 20, right: 20, top: 30, bottom:20),
                                child:   SizedBox(
                                  width: MediaQuery.of(context).size.width - 40,
                                  height: 50.0,
                                  child: ElevatedButton(
                                      child: Text(
                                        'Okay',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.lato(
                                          color: Constants.WHITE,
                                          // textStyle: Theme.of(context).textTheme.displayLarge,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          fontStyle: FontStyle.normal,
                                        ),
                                      ),
                                      style: ButtonStyle(
                                          foregroundColor: MaterialStateProperty.all<Color>(
                                              Constants.PURPLE_THEME),
                                          backgroundColor: MaterialStateProperty.all<Color>(
                                              Constants.PURPLE_THEME),
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(25),
                                                  side: BorderSide(
                                                      color: Colors.transparent)))),
                                      onPressed: () {

                                        Navigator.pop(context);
                                        NavigationHelper.navigateToPage(
                                            context, ChooseBoarding());
                                      }),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(),


                      // Container(
                      //   height: 20,
                      //   width: 20,
                      //   color: Colors.green,
                      // )
                    ],
                  ),
                );
              },
            );
          },

        ).then((value) {
          print('Bottom sheet closed');

        });

      }
      else {
        // Handle errors
        final responseStream = response.stream.bytesToString().toString();
        final decodedStream = decodeResponseStream(responseStream as Stream<String>);

        await for (Map<String, dynamic> data in decodedStream) {
          // Handle the data as a Map
          print(data);
          print("5555555555");
          ToastManager.showToast('Message Sent Successfully' + data["error"]);
        }

        print('API Request failed with status ${response.statusCode}');
        print('API Response: ${await response.stream.bytesToString()}');
      }
    } catch (error) {

      ToastManager.showToast("Something went wrong");
      print('API Request failed: $error');
    }
  }

  Future<void> updateProfileApi(Map<String, String> userData, String userProfileImage, BuildContext ctxt) async {


    print(apiUrl);
    print(userData);
    print(userProfileImage);

    String? userToken = await SharedPreferencesManager.getStringValue(Constants.userTokenKey) ?? "";
    print(userToken);

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));



      if(userProfileImage != "") {
        request.files.add(await http.MultipartFile.fromPath('profile_image',userProfileImage));
      }

      // Driving Licence
      for (var image in  LocalDataHandler.drivinfLicenceImages) {
        request.files.add(await http.MultipartFile.fromPath('driving_licence_images[]', image.path));
      }

      // security Licence
      for (var image in  LocalDataHandler.securityLicenceImages) {
        request.files.add(await http.MultipartFile.fromPath('security_licence_images[]', image.path));
      }

      // biometric
      for (var image in  LocalDataHandler.bioMetricImages) {
        request.files.add(await http.MultipartFile.fromPath('biometric_images[]', image.path));
      }

      // passport
      for (var image in  LocalDataHandler.passportImages) {
        request.files.add(await http.MultipartFile.fromPath('passport_images[]', image.path));
      }



      request.headers['Authorization'] = 'Bearer ' + userToken;

      request.headers['Content-Type'] = 'application/json';

      request.fields.addAll(userData);


      var response = await request.send();
      print(response.statusCode);
      print(response.stream.bytesToString());
      //  print(response.stream.bytesToString().toString());

      if (response.statusCode == 200) {
        // Handle successful response from the API
        // You can parse the response if needed
        //  print('API Response: ${await response.stream.bytesToString()}');


        // final Map<String, dynamic> responseData = jsonDecode(response.stream.bytesToString());
        // print(responseData);
        // return responseData;

        ToastManager.showToast('Your change request is under review');
      }
      else  if(response.statusCode == 401) {

        SharedPreferencesManager.saveStringValue("", Constants.userTokenKey);
        ToastManager.showLongToast('Session expired. please login again');
        NavigationHelper.navigateToPage(ctxt, LoginScreen());
      }
      else {
        // // Handle errors
        // final responseStream = response.stream.bytesToString().toString();
        // final decodedStream = decodeResponseStream(responseStream as Stream<String>);
        //
        // await for (Map<String, dynamic> data in decodedStream) {
        //   // Handle the data as a Map
        //   print(data);
        //   print("5555555555");
        //   ToastManager.showToast('Message Sent Successfully' + data["error"]);
        // }
        //
        // print('API Request failed with status ${response.statusCode}');
        // print('API Response: ${await response.stream.bytesToString()}');
        ToastManager.showToast("Something went wrong");
      }
    } catch (error) {
      ToastManager.showToast("Something went wrong!");
      print('API Request failed: $error');
    }
  }

  Future<dynamic> updateBankApi(Map<String, String> bankData, String doc1Front, String doc1Back, String doc2Front, String doc2Back, BuildContext ctxt) async {


    print(apiUrl);
    print(bankData);

    String? userToken = await SharedPreferencesManager.getStringValue(Constants.userTokenKey) ?? "";
    print(userToken);

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));



      request.files.add(await http.MultipartFile.fromPath('documentFront',doc1Front));
      request.files.add(await http.MultipartFile.fromPath('documentBack',doc1Back));
      request.files.add(await http.MultipartFile.fromPath('additionalDocFront',doc2Front));
      request.files.add(await http.MultipartFile.fromPath('additionalDocBack',doc2Back));



      request.headers['Authorization'] = 'Bearer ' + userToken;

      request.headers['Content-Type'] = 'application/json';

      request.fields.addAll(bankData);

      var response = await request.send();


      //print(response.statusCode);
      // print('API Response: ${await response.stream.bytesToString()}');

      //  print('API Response: ${await response.stream.bytesToString()}');

      // var jsonString =  value.stream.bytesToString().toString();
      // print("323322332wwwwww");
      // print(jsonString);
      // // Parse the JSON string into a Map (dictionary)
      // var jsonMap = jsonDecode(jsonString);



      if (response.statusCode == 200) {
        // Handle successful response from the API
        // You can parse the response if needed
        //  print('API Response: ${await response.stream.bytesToString()}');


        // final Map<String, dynamic> responseData = jsonDecode(response.stream.bytesToString());
        // print(responseData);
        // return responseData;

        ToastManager.showToast('You account is added successfully');
        Navigator.of(ctxt).pop();
        Navigator.of(ctxt).pop();
      }
      else  if(response.statusCode == 401) {

        SharedPreferencesManager.saveStringValue("", Constants.userTokenKey);
        ToastManager.showLongToast('Session expired. please login again');
        NavigationHelper.navigateToPage(ctxt, LoginScreen());
      }
      else {
        print("323322332");
        // print('API Responseee: ${await response.stream.bytesToString()}');

        String dataVa = "";
        dataVa = 'API Responseee: ${await response.stream.bytesToString()}';
        print(dataVa.replaceAll("API Responseee:", ""));
        // print(jsonString);
        // // Parse the JSON string into a Map (dictionary)
        var jsonMap = jsonDecode(dataVa.replaceAll("API Responseee:", ""));





        ToastManager.showToast(jsonMap["error"]);
      }
    } catch (error) {
      ToastManager.showToast("Something went wrong");
      print('API Request failed: $error');
    }
  }

  Stream<Map<String, dynamic>> decodeResponseStream(Stream<String> responseStream) {
    // Use the transform method to decode the JSON data in the stream
    return responseStream.transform(utf8.decoder as StreamTransformer<String, dynamic>).transform(json.decoder as StreamTransformer<dynamic, Map<String, dynamic>>);
  }

  Future<void> multipartApi() async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      print(LocalDataHandler.bioMetricImages);
      print(apiUrl);
      for (var image in  LocalDataHandler.bioMetricImages) {
        request.files.add(await http.MultipartFile.fromPath('biometric_images[]', image.path));
      }

      // request.files.add(await http.MultipartFile.fromPath('profile_images', LocalDataHandler.bioMetricImages[0].path));
      // request.files.add(await http.MultipartFile.fromPath('passport_images', LocalDataHandler.bioMetricImages[0].path));
      // request.files.add(await http.MultipartFile.fromPath('driving_licence_images', LocalDataHandler.bioMetricImages[0].path));
      // request.files.add(await http.MultipartFile.fromPath('biometric_images', LocalDataHandler.bioMetricImages[0].path));
      // request.files.add(await http.MultipartFile.fromPath('security_licence_images', LocalDataHandler.bioMetricImages[0].path));


      Map<String, String> fieldsMap = {
        'national_insurance' : "wqeqwe",
        // 'first_name': 'name',
        // 'last_name': 'llname',
        // 'email': 'john@examp2le7.com',
        // 'phone_number' : "+9781986137",
        // 'country_code': 'in',
        // 'password': '123456',
        // 'location': '212112',
        // 'latitude' : "562",
        // 'longitude' : "2421212",
        // 'pincode': '123',
        // 'referral_code': "ABCDEF",
        "first_name":"test",
        "last_name":"user",
        "email":"tesy1@yopmail6.com",
        "phone_number":"54153344416",
        "country_code":"+91",
        "password":"121345678",
        "location":"test",
        "latitude":"421421",
        "longitude":"214214",
        "pincode":"2421212",
      };

      request.fields.addAll(fieldsMap);


      var response = await request.send();

      if (response.statusCode == 200) {
        // Handle successful response from the API
        // You can parse the response if needed
        print('API Response: ${await response.stream.bytesToString()}');


        // final Map<String, dynamic> responseData = jsonDecode(response.stream.bytesToString());
        // print(responseData);
        // return responseData;

      } else {
        // Handle errors

        print('API Request failed with status ${response.statusCode}');
        print('API Response: ${await response.stream.bytesToString()}');
      }
    } catch (error) {
      // Handle exceptions
      print('API Request failed: $error');
    }
  }

  Future<Map<String, dynamic>> getDatawithoutTokenMethod(BuildContext context) async {

    print(apiUrl);
    print("Get--");
    String? userToken = await SharedPreferencesManager.getStringValue(Constants.userTokenKey) ?? "";
    print(userToken);
    try {
      final response = await http.get(
        Uri.parse(apiUrl), // Replace 'endpoint' with your API endpoint
      );

      if (response.statusCode == 200) {
        // If server returns an OK response, parse the response
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print(responseData);
        return responseData;
      } else {

        if(response.statusCode == 401) {
          SharedPreferencesManager.saveStringValue("", Constants.userTokenKey);
          ToastManager.showLongToast('Session expired. please login again');
          NavigationHelper.navigateToPage(context, LoginScreen());
        }

        // If the server did not return a 200 OK response, throw an exception
        throw Exception('Failed to post data: ${response.statusCode}');


      }
    } catch (error) {
      // Handle errors that may occur during the API call
      throw Exception('Failed to post data: $error');
    }
  }

  Future<Map<String, dynamic>> postPushNotificationMethod(Map<String, dynamic> data, BuildContext context) async {
    print(data);
    print(apiUrl);
    print("Post----");
    String? userToken = "key=AAAAsGYWMHM:APA91bFHliH9q3Dm2OG84nSB-Z97trVxFl1CBAr7CtDuwMNWoSWm3hWL5mesE4gzaiYgovEj9Qbo5aY9RVuwSkaRj4HO8BoWW_tDevdE7tNqaCH8oDPY2Ys9B24QGrysWZ78QznWJQUS";
    print(userToken);
    try {
      final response = await http.post(Uri.parse(apiUrl),
        body: jsonEncode(data),
        headers: {'Content-Type': 'application/json', 'Authorization': userToken},
      );
      print(response.statusCode );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      print(responseData);
      print("4444444");
      if (response.statusCode == 200) {
        // If server returns an OK response, parse the response
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print(responseData);
        return responseData;
      } else {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print(responseData);
        if(response.statusCode == 401) {
          SharedPreferencesManager.saveStringValue("", Constants.userTokenKey);
          ToastManager.showLongToast('Session expired. please login again');
          NavigationHelper.navigateToPage(context, LoginScreen());
        }
        else  if(responseData["message"] ==  "Access not provided!!! Please contact admin") {
          SharedPreferencesManager.saveStringValue("", Constants.userTokenKey);
          ToastManager.showLongToast(responseData["message"]);
          Map<String, dynamic> errormap = {
            "errorMessage": "Access not provided!!! Please contact admin",
          };
          return errormap;
        }
        throw Exception('Failed to post data: ${response.statusCode}');
      }
    } catch (error) {
      // Handle errors that may occur during the API call
      throw Exception('Failed to post data: $error');
    }
  }*/
}
