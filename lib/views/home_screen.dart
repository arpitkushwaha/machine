
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:demo_1/models/data_model.dart';
import 'package:demo_1/utilities/db.dart';
import 'package:demo_1/views/form_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int page=0;
  String imageData;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    databaseConnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<List<Images>>(
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () async {
                            await downloadImage(snapshot.data[index].xtImage, snapshot.data[index].id);
                            print(imageData);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => FormScreen(imageData)));
                          },
                          child: ListTile(
                            title:CachedNetworkImage(
                                imageUrl: snapshot.data[index].xtImage,
                              placeholder: (context, url) => Center(child: SizedBox(width:50, height: 50,child: CircularProgressIndicator())),
                            ),
                          ),
                        );
                      });
                }
              },
              future: dioCall(),
            ),

            SizedBox(
              height: 30,
            ),

            InkWell(
              onTap: (){
                setState(() {
                  page++;
                  dioCall();
                });

              },
                child: Text("Click here to load more...", style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold
                ),)),

            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }


  Future<List<Images>> dioCall() async
  {

    final Map<String, String> apiData = {
      "user_id": "108",
      "offset":"$page",
      "type":"popular"
    };
    var dio = Dio();
    try {
      FormData formData = FormData.fromMap(apiData);
      var response = await dio.post("http://dev3.xicom.us/xttest/getdata.php", data: formData);
      //print(response.data);
      DataModel data = DataModel.fromJson(json.decode(response.data));
      List<Images> imagesList = data.images;
      if(imagesList.length == 0)
        {
          page=0;
        }
      print("page === $page");
      return imagesList;

    } catch (e) {
      print(e);
    }
  }

  downloadImage(String url, String id) async
  {
      var response = await http.get(Uri.parse(url)); // <--2
      var documentDirectory = await getApplicationDocumentsDirectory();
      var firstPath = documentDirectory.path + "/images";
      var filePathAndName = documentDirectory.path + '/images/${id}.jpg';
      await Directory(firstPath).create(recursive: true); // <-- 1
      File file2 = new File(filePathAndName);             // <-- 2
      file2.writeAsBytesSync(response.bodyBytes);         // <-- 3
      setState(() {
        imageData = filePathAndName;
      });
  }

  void databaseConnect() {
    DB.initialize();
  }

}