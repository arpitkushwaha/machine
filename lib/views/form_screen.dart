
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:demo_1/models/form_data_model.dart';
import 'package:demo_1/utilities/db.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class FormScreen extends StatefulWidget {
  String imagePath;
  FormScreen(this.imagePath) ;

  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {

  final _globalkey = GlobalKey<FormState>();
  TextEditingController _email = TextEditingController();
  TextEditingController _firstName = TextEditingController();
  TextEditingController _lastName = TextEditingController();
  TextEditingController _phone = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Form(
                  key: _globalkey,
                  child: ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    children: <Widget>[

                      SizedBox(
                        height: 30,
                      ),

                      Image.file(
                       File(widget.imagePath)),

                      SizedBox(
                        height: 30,
                      ),

                      _buildTF("First Name", _firstName),
                      _buildTF("Last Name", _lastName),
                      _buildEmail("Email", _email),
                      _buildPhone("Phone Number", _phone),
                      _buildSubmitBtn(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildTF(String name, TextEditingController _cntrl) {
    return TextFormField(
      keyboardType: TextInputType.name,
      controller: _cntrl,
      validator: (value) {
        if (value.isEmpty) return "$name can't be empty";
        return null;
      },
      decoration: InputDecoration(
        hintText: "Enter $name",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            const Radius.circular(15.0),
          ),
          borderSide: BorderSide(
            color: Colors.black,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildEmail(String name, TextEditingController _cntrl) {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      controller: _cntrl,
      validator: (value) {
        if (value.isEmpty) return "$name can't be empty";
        return null;
      },
      decoration: InputDecoration(
        hintText: "Enter $name",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            const Radius.circular(15.0),
          ),
          borderSide: BorderSide(
            color: Colors.black,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildPhone(String name, TextEditingController _cntrl) {
    return TextFormField(
      keyboardType: TextInputType.phone,
      controller: _cntrl,
      validator: (value) {
        if (value.isEmpty)
          return "$name can't be empty";
        else if(value.length<10 || value.length>10)
          return "Enter valid phone number";

        return null;
      },
      decoration: InputDecoration(
        hintText: "Enter $name",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            const Radius.circular(15.0),
          ),
          borderSide: BorderSide(
            color: Colors.black,
            width: 2,
          ),
        ),
      ),
    );
  }


  Widget _buildSubmitBtn() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 25.0),
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            if (_globalkey.currentState.validate()) {

              FormDataModel data = FormDataModel(email: _email.text, firstName: _firstName.text, lastName: _lastName.text, phone: _phone.text, imagePath: widget.imagePath);
              await sendData(data);
              saveDataInDb(data);
              Navigator.pop(context);
              }
          },
          style: ElevatedButton.styleFrom(
              padding:
              EdgeInsets.only(top: 12, left: 30, right: 30, bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              primary: Colors.black,
              elevation: 5.0),
          child: Text(
            'SUBMIT',
            style: TextStyle(
              color: Colors.white,
              letterSpacing: 1.5,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ));
  }

  void sendData(FormDataModel dataModel) async{

    //first_name, last_name, email, phone, user_image
    var dio = Dio();
    var response;
    print("FORMDATAMODEL +++ ${dataModel.toJson()}");
    String fileName = dataModel.imagePath.split('/').last;
    FormData formData = FormData.fromMap({
      "user_image":
      await MultipartFile.fromFile(dataModel.imagePath, filename:fileName),
      "first_name" : dataModel.firstName,
      "last_name" : dataModel.lastName,
      "email" :  dataModel.email,
      "phone" : dataModel.phone,
    });

    response = await dio.post("http://dev3.xicom.us/xttest/savedata.php", data: formData);
    print(response);

  }

  void saveDataInDb(FormDataModel dataModel)
  {
    DB db = DB();
    db.insertDataInDB("user_master", dataModel.toJson());
  }

}

