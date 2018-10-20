import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:money/home.dart';
import 'package:money/models/model_login.dart';
import 'package:money/models/model_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);
  @override
  _LoginState createState() => new _LoginState();
}

class _LoginState extends State<Login> {
  ModelLogin modellogin = ModelLogin();
  Dio dio = new Dio();
  ModelUrl modelurl = ModelUrl();

  /* ============== function alert ========*/
  void alert(var title, var detail) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Center(
              child: new Text("${title}",
                  style: TextStyle(fontSize: 20.0, color: Colors.red))),
          content: new Text("${detail}"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("ປິດ"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /*============      Login =============*/
  Future loginpress() async {
    dio.options.connectTimeout = 3000; //5s
    dio.options.receiveTimeout = 3000;
    FormData formData = new FormData.from(
        {'username': modellogin.username, 'password': modellogin.password});
    try {
      Response response =
          await dio.post('${modelurl.url}api/login', data: formData);
      if (response.statusCode == 200) {
        if (response.data.length > 1) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setInt('token', int.parse(response.data['id']));
          prefs.setString('last_name', response.data['last_name']);
          prefs.setString('first_name', response.data['first_name']);
          prefs.setString('photo_profile', response.data['photo']);
          prefs.setString('photo_bg', response.data['bg_photo']);

          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Home()));
        } else {
          alert('ມີ​ຂ​ໍ້​ຜິດ​ພາດ', response.data['error']);
        }
      }
    } on DioError catch (e) {
      alert('ມີ​ຂ​ໍ້​ຜິດ​ພາດ', 'ກວດ​ເບີ່ງ​ການ​ເຊື່ອມ​ຕໍ່​ເນັ​ດ.!');
    }
  }

/*================= check first loading alerdy login or not ===================*/
  Future<Null> checkLoginged() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = await prefs.get('token');
    if (token != null) {
    //  Navigator.pushReplacement(
       //   context, MaterialPageRoute(builder: (context) => Home()));
        Navigator.of(context).pushNamed('/home');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLoginged();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Center(child: new Text('ລະ​ບົບ​ເກັບ​ກຳ​ລາຍ​ຈ່າຍ​ລາຍ​ຮັບ')),
      ),
      body: new Container(
        child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Text(
                "​ປ້ອນ​ຊື່​ແລ​ະ​ລະຫັດຜ່ານ", 
                style: new TextStyle(
                    fontSize: 18.0,
                    color: Colors.black,
                    fontWeight: FontWeight.w200,
                    fontFamily: "Roboto"),
              ),
              Divider(),
              new TextField(
                decoration: InputDecoration(labelText: 'ປ້ອນ​ຊື່​ເຂົ້າ​ລະ​ບົບ'),
                onChanged: (value) {
                  setState(() {
                    modellogin.username = value;
                  });
                },
              ),
              new Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
              ),
              new TextField(
                obscureText: true,
                decoration: InputDecoration(labelText: 'ປ້ອນລະ​ຫັດ​ຜ່ານ'),
                onChanged: (value) {
                  setState(() {
                    modellogin.password = value;
                  });
                },
              ),
              new Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
              ),
              new RaisedButton.icon(
                icon: Icon(Icons.lock_open,color:Colors.white,),
                
                label: Text('ເຂົ້າ​ລະ​ບົບ'),
                key: null,
                onPressed: loginpress,
                color: Colors.blue,
              )
            ]),
        padding: const EdgeInsets.all(10.0),
        alignment: Alignment.center,
      ),
    );
  }
}
