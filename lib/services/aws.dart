import 'package:aws_rekognition_api/rekognition-2016-06-27.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();

}

class _MyAppState extends State<MyApp> {
  final ImagePicker _picker = ImagePicker();
  List<Label> detectedLabels = [];

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {

      final imageBytes = await pickedFile.readAsBytes();

      final rekognition = Rekognition(
        region: 'us-east-1', // Your AWS region
        credentials: AwsClientCredentials(
          accessKey: 'AKIAXXETL7XXGO7ID3OY', // Replace with your access key
          secretKey: 'YOUR_SECRET_KEY', // Replace with your secret key
        ),
      );
      try {
        // final response = await rekognition.detectLabels(
        //   image: rekognition.Image().fromBytes(imageBytes),
        //   maxLabels: 10,
        //   minConfidence: 75,
        // );
        setState(() {
          // detectedLabels = response.labels!;
        });
      }
      catch (e) {print('Error detecting labels: $e');}

      // detectedLabels = await rekognition.detectLabels(image: imageBytes);

      setState(() {});
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Image Recognition")),
        body: Column(
            children: [
              ElevatedButton(onPressed: _pickImage, child: const Text("Select Image")),
              Expanded(
                  child: ListView.builder(
                    itemCount: detectedLabels.length,
                    itemBuilder: (context, index) {
                      return const Text('detectedLabels[index].name');
                    },))]));}
}
