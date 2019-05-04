import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:money/home.dart';
import 'package:money/models/model_login.dart';
import 'package:money/models/model_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onesignal/onesignal.dart';

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);
  @override
  _LoginState createState() => new _LoginState();
}

class _LoginState extends State<Login> {
  ModelLogin modellogin = ModelLogin();
  Dio dio = new Dio();
  ModelUrl modelurl = ModelUrl();

  bool isloading = false;
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
    setState(() {
      isloading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var playerID = await prefs.get('playerID');
    dio.options.connectTimeout = 12000; //5s
    dio.options.receiveTimeout = 12000;
    FormData formData = new FormData.from({
      'username': modellogin.username,
      'password': modellogin.password,
      'player_id': playerID
    });
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
          modelurl.settimeloginexpiry();
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Home()));
        } else {
          setState(() {
            isloading = false;
          });
          alert('ມີ​ຂໍ້ຜິດ​ພາດ', response.data['error']);
        }
      }
    } on DioError catch (e) {
      setState(() {
        isloading = false;
      });
      alert('ມີ​ຂໍ້ຜິດ​ພາດ', 'ກວດ​ເບີ່ງ​ການ​ເຊື່ອມ​ຕໍ່​ເນັ​ດ.!');
    }
  }

/*================= check first loading alerdy login or not ===================*/
  Future<Null> checkLoginged() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = await prefs.get('token');

    /*============ get token =============*/
    OneSignal.shared.init("8611a545-6f5f-4e15-9e3a-b992ae4c6cac");
    OneSignal.shared.promptUserForPushNotificationPermission();
    var status = await OneSignal.shared.getPermissionSubscriptionState();
    var playerId = status.subscriptionStatus.userId;
    prefs.setString('playerID', playerId);
    print(playerId);

    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      // will be called whenever a notification is opened/button pressed.
      Navigator.of(context).pushNamed('/home');
    });

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
        automaticallyImplyLeading: false,
        title: Center(child: new Text('ລະ​ບົບ​ເກັບ​ກຳ​ເງີນ')),
        // automaticallyImplyLeading: false,
      ),
      body: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(left: 24.0, right: 24.0),
        children: <Widget>[
          SizedBox(height: 20.0),
          Hero(
            tag: 'hero',
            child: CircleAvatar(
              backgroundColor: Colors.blue,
              radius: 48.0,
              child: Image(
                image: NetworkImage('${modelurl.urlimg}logo.png'),
              ),
            ),
          ),
          SizedBox(height: 20.0),
          Divider(),
          new TextField(
            decoration: InputDecoration(
              labelText: 'ປ້ອນ​ຊື່​ເຂົ້າ​ລະ​ບົບ',
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
            ),
            onChanged: (value) {
              setState(() {
                modellogin.username = value;
              });
            },
          ),
          new Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
          ),
          SizedBox(height: 20.0),
          new TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'ປ້ອນລະ​ຫັດ​ຜ່ານ',
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
            ),
            onChanged: (value) {
              setState(() {
                modellogin.password = value;
              });
            },
          ),
          SizedBox(height: 20.0),
          new Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
          ),
          isloading
              ? Center(child: CircularProgressIndicator())
              : RaisedButton.icon(
                  icon: Icon(
                    Icons.lock_open,
                    color: Colors.white,
                  ),
                  label: Text(
                    'ເຂົ້າ​ລະ​ບົບ',
                    style: TextStyle(color: Colors.white),
                  ),
                  key: null,
                  onPressed: loginpress,
                  color: Colors.blue,
                ),
        ],
      ),
    );
  }
}
