import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

void main() => runApp(MaterialApp(
      home: new HomePage(),
    ));

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage> {
  Map responseJson;
  Map mapResponse;
  http.StreamedResponse imager;
  File _image;
  String url = 'https://c1eb31bb279f.ngrok.io/predict';

  /* void fetchData() async {
    http.Response response;
    response = await http.get('https://c1eb31bb279f.ngrok.io/test');
    if (response.statusCode == 200) {
      setState(() {
        mapResponse = jsonDecode(response.body);
      });
    }
  }*/

  void imageFromGallery() async {
    PickedFile pickedFile = await ImagePicker()
        .getImage(source: ImageSource.gallery, imageQuality: 100);
    var image = File(pickedFile.path);
    setState(() {
      _image = image;
    });
    /*http.Response response;
    response = await uploadImageHTTP(_image, url);
    
    if (response.statusCode == 200) {
      fetchData();
    }
*/
    await uploadImageHTTP(_image, url);
    //fetchData();
  }

  void imageFromCamera() async {
    PickedFile pickedFile = await ImagePicker()
        .getImage(source: ImageSource.camera, imageQuality: 100);
    var image = File(pickedFile.path);
    setState(() {
      _image = image;
    });

    await uploadImageHTTP(_image, url);
  }

  Future uploadImageHTTP(file, url) async {
    setState(() {
      mapResponse = null;
    });
    String fileName = file.path.split('/').last;
    print(fileName);

    FormData data = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });

    Dio dio = new Dio();

    dio.post(url, data: data).then((response) {
      var jsonResponse = jsonDecode(response.toString());
      print("\n\n\n\n\nits\n\n\n\n\n $jsonResponse");

      setState(() {
        mapResponse = jsonResponse;
      });
      return jsonResponse;
    }).catchError((error) => print(error));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fetch Data Form internet'),
        backgroundColor: Colors.red[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Center(
                child: _image == null
                    ? Container()
                    : Text("the picture has been sent")),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: mapResponse == null
                    ? Text('no Response')
                    : Image.network(mapResponse['image_link']),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: imageFromGallery,
        child: Icon(
          Icons.camera_alt,
          size: 25,
        ),
      ),
    );
  }
}
