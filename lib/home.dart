import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money/login.dart';
import 'package:money/models/model_url.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:money/payment/list_payment.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Dio dio = new Dio();
  ModelUrl modelurl = ModelUrl();

  /*========== Login expired ================*/
  Future<Null> checkloginexiped() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var now = new DateTime.now();
    var formatter = new DateFormat('h');
    String formatted = formatter.format(now);
    if (int.parse(formatted) > prefs.getInt('time')) {
      prefs.remove('token');
      prefs.remove('time');
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Login()));
    } else {
      prefs.setInt('time', int.parse(formatted) + 2);
    }
  }

  /*================== alert ==============*/
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

  /*========== Logout ================*/
  Future<Null> logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.setInt('time',0);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Login()));
  }

  /*============      List All details  =============*/
  var totalpay = '0';
  var totalrecive = '0';
  var percentpay = '0';
  var percentrecive = '0';
  var pay_car = '0';
  var still_car = '0';
  int userID;
  var firstName;
  var lastName;
  File _image;
  var photo_profile;
  bool isloadimg = false;
  File _imageBg;
  bool isloadimgBg = false;
  var photo_bg;
  bool isloading = true;

  Future loadAlldetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int token = await prefs.get('token');
    var first_name = await prefs.get('first_name');
    var last_name = await prefs.get('last_name');
    var profilephoto = await prefs.get('photo_profile');
    var bgphoto = await prefs.get('photo_bg');
    setState(() {
      userID = token;
      firstName = first_name;
      lastName = last_name;
      photo_profile = profilephoto;
      photo_bg = bgphoto;
    });

    dio.options.connectTimeout = 3000; //5s
    dio.options.receiveTimeout = 3000;
    try {
      Response response = await dio.get('${modelurl.url}api/home');
      if (response.statusCode == 200) {
        setState(() {
          totalpay = response.data['total_pay'];
          totalrecive = response.data['total_recieve'];
          percentpay = response.data['percent_pay'];
          percentrecive = response.data['percent_recive'];
          pay_car = response.data['pay_car'];
          still_car = response.data['still_car'];
          isloading = false;
        });
      }
    } on DioError catch (e) {
      setState(() {
        isloading = false;
      });
      alert('ມີ​ຂ​ໍ້​ຜິດ​ພາດ', 'ກວດ​ເບີ່ງ​ການ​ເຊື່ອມ​ຕໍ່​ເນັ​ດ.!');
    }
  }

/* ------------------------ Upload Ingage profile -------------------------*/

  Future getImageProfile(var type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var imageFile = (type == 'camera')
        ? await ImagePicker.pickImage(source: ImageSource.camera)
        : await ImagePicker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      setState(() {
        _image = imageFile;
        isloadimg = true;
      });
      /*============ Drop Images =================*/
      File croppedFile = await ImageCropper.cropImage(
          sourcePath: imageFile.path,
          ratioX: 1.0,
          ratioY: 1.0,
          toolbarTitle: 'Crop photo',
          toolbarColor: Colors.red);
      if (croppedFile != null) {
        imageFile = croppedFile;
        /*============ Send Images to API Save =================*/
        FormData formData = new FormData.from({
          "name": "profile_img",
          'edit': true,
          'userid': userID,
          "upfile": new UploadFileInfo(imageFile, "upload1.jpg")
        });
        try {
          var response =
              await dio.post("${modelurl.url}api/uplaodfile", data: formData);
          if (response.statusCode == 200) {
            setState(() {
              isloadimg = false;
              photo_profile = response.data;
              prefs.setString('photo_profile', response.data);
            });
          } else {
            print('Error upload image');
          }
        } on DioError catch (e) {
          alert('ມີ​ຂ​ໍ້​ຜິດ​ພາດ', 'ກວດ​ເບີ່ງ​ການ​ເຊື່ອມ​ຕໍ່​ເນັ​ດ.!');
        }
      } else {
        setState(() {
          if (photo_profile.photo == null) {
            _image = null;
          }
          isloadimg = false;
        });
      }
    }
  }

/*====================== Uplaod image profile Bg ========================*/

  Future getImageBgProfile(var type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var imageBgFile = (type == 'camera')
        ? await ImagePicker.pickImage(source: ImageSource.camera)
        : await ImagePicker.pickImage(source: ImageSource.gallery);
    if (imageBgFile != null) {
      setState(() {
        _imageBg = imageBgFile;
        isloadimgBg = true;
      });
      /*============ Drop Images =================*/
      File croppedFile = await ImageCropper.cropImage(
          sourcePath: imageBgFile.path,
          ratioX: 1.8,
          ratioY: 1.0,
          toolbarTitle: 'Crop photo',
          toolbarColor: Colors.red);
      if (croppedFile != null) {
        imageBgFile = croppedFile;
        /*============ Send Images to API Save =================*/
        Dio dio = new Dio();
        FormData formData = new FormData.from({
          "name": "profileBg_img",
          'edit': true,
          'userid': userID,
          "upfile": new UploadFileInfo(imageBgFile, "upload1.jpg")
        });
        try {
          var response =
              await dio.post("${modelurl.url}api/uplaodfile", data: formData);
          if (response.statusCode == 200) {
            setState(() {
              isloadimgBg = false;
              photo_bg = response.data;
              prefs.setString('photo_bg', response.data);
            });
          } else {
            print('Error upload image');
          }
        } on DioError catch (e) {
          alert('ມີ​ຂ​ໍ້​ຜິດ​ພາດ', 'ກວດ​ເບີ່ງ​ການ​ເຊື່ອມ​ຕໍ່​ເນັ​ດ.!');
        }
      } else {
        setState(() {
          if (photo_bg == null) {
            _imageBg = null;
          }
          isloadimgBg = false;
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkloginexiped();
    loadAlldetail();
  }

  @override
  Widget build(BuildContext context) {
    /*============== menu left ============*/
    Widget drawer = Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            onDetailsPressed: () {
              showDialog(
                  context: context,
                  child: AlertDialog(
                      content: Container(
                    height: 80.0,
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Change photo profile backgroud',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: <Widget>[
                            OutlineButton.icon(
                              label: Text('GALLERY',
                                  style: TextStyle(
                                      fontSize: 10.0, color: Colors.black)),
                              icon: Icon(
                                Icons.image,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                getImageBgProfile('gallery');

                                Navigator.of(context).pop();
                              },
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child: OutlineButton.icon(
                                label: Text('CAMERA',
                                    style: TextStyle(fontSize: 10.0)),
                                icon: Icon(
                                  Icons.camera,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  getImageBgProfile('camera');

                                  Navigator.of(context).pop();
                                },
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  )));
            },
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: photo_bg == null
                      ? AssetImage('assets/img/bg.jpg')
                      : NetworkImage('${modelurl.urlimg}small/${photo_bg}'),
                  fit: BoxFit.fill),
            ),
            currentAccountPicture: GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      child: AlertDialog(
                          content: Container(
                        height: 80.0,
                        child: Column(
                          children: <Widget>[
                            Text(
                              'Change photo profile',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: <Widget>[
                                OutlineButton.icon(
                                  label: Text('GALLERY',
                                      style: TextStyle(
                                          fontSize: 10.0, color: Colors.black)),
                                  icon: Icon(
                                    Icons.image,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    getImageProfile('gallery');

                                    Navigator.of(context).pop();
                                  },
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 10.0),
                                  child: OutlineButton.icon(
                                    label: Text('CAMERA',
                                        style: TextStyle(fontSize: 10.0)),
                                    icon: Icon(
                                      Icons.camera,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      getImageProfile('camera');

                                      Navigator.of(context).pop();
                                    },
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      )));
                },
                child: CircleAvatar(
                    backgroundImage: photo_profile == null
                        ? AssetImage('assets/img/user.jpg')
                        : NetworkImage(
                            '${modelurl.urlimg}small/${photo_profile}'))),
            accountName: Text(
              '${firstName}',
              style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            accountEmail: Text(
              '${lastName}',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.accessible_forward,
              color: Colors.red,
            ),
            title: Text(
              'ຈັດ​ການ​ເງີນ​ທີ່​ຈ່າຍ​ອອກ',
              style: TextStyle(fontSize: 18.0),
            ),
            subtitle: Text(
              '​ປ້ອນ​ລາຍ​ລະ​ອຽດເງີນ​ທີ່​ຈ່າຍ​ອອກ​ແຕ່​ລະ​ມື້',
              style: TextStyle(fontSize: 12.0),
            ),
            trailing: Icon(Icons.accessible_forward),
            onTap: () {
              //Navigator.pushReplacement(
              //  context, MaterialPageRoute(builder: (context) => ListPayment()));
              Navigator.of(context).pushNamed('/payment');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.accessible,
              color: Colors.blue,
            ),
            title: Text(
              'ຈັດ​ການ​ເງີນ​ທີ່​ຮັບ​ເຂົ້າ',
              style: TextStyle(fontSize: 18.0),
            ),
            subtitle: Text(
              '​ປ້ອນ​ລາຍ​ລະ​ອຽດເງີນ​ທີ່​ຮັບ​ເຂົ້າ​ແຕ່​ລະ​ມື້',
              style: TextStyle(fontSize: 12.0),
            ),
            trailing: Icon(Icons.accessible),
            onTap: () {
              // Navigator.of(context).pushNamed('/listhouseuser');
              Navigator.of(context).pushNamed('/recive');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.local_taxi,
              color: Colors.redAccent,
            ),
            title: Text(
              'ຈັດ​ການ​ເງີນ​​ຈ່າຍ​​ຄ່າ​ລົດ',
              style: TextStyle(fontSize: 18.0),
            ),
            subtitle: Text(
              '​ປ້ອນ​ຈຳ​ນວນເງີນ​ທີ່​​​ຄ່າ​ລົດ​ແຕ່​ລະ​ມເດືອນ',
              style: TextStyle(fontSize: 12.0),
            ),
            trailing: Icon(Icons.local_taxi),
            onTap: () {
              Navigator.of(context).pushNamed('/daocar');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.bubble_chart,
              color: Colors.blue,
            ),
            title: Text(
              '​ລາຍ​ງານ​ລາຍ​ຮັບ',
              style: TextStyle(fontSize: 18.0),
            ),
            subtitle: Text(
              '​ເບີ່ງລາຍ​ງານ​ລາຍ​ຮັບ',
              style: TextStyle(fontSize: 12.0),
            ),
            trailing: Icon(Icons.bubble_chart),
            onTap: () {
              // Navigator.of(context).pushNamed('/listhouseuser');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.insert_chart,
              color: Colors.red,
            ),
            title: Text(
              '​ລາຍ​ງານ​ລາຍ​ຈ່າຍ',
              style: TextStyle(fontSize: 18.0),
            ),
            subtitle: Text(
              '​ເບີ່ງລາຍ​ງານ​ລາຍ​​ຈ່າຍ',
              style: TextStyle(fontSize: 12.0),
            ),
            trailing: Icon(Icons.insert_chart),
            onTap: () {
              // Navigator.of(context).pushNamed('/listhouseuser');
            },
          ),
        ],
      ),
    );
    return Scaffold(
      drawer: drawer,
      appBar: AppBar(
        title: Center(child: Text("ໜ້າຫຼັກ")),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings_power),
            onPressed: logOut,
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        alignment: Alignment.center,
        child: RefreshIndicator(
          onRefresh: loadAlldetail,
          child: isloading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : ListView(
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    Container(
                      decoration: new BoxDecoration(color: Colors.blue),
                      child: ListTile(
                        onTap: () {
                          Navigator.of(context).pushNamed('/payment');
                        },
                        leading: Icon(
                          Icons.keyboard,
                          size: 50.0,
                          color: Colors.white,
                        ),
                        title: const Text(
                          'ລາຍ​ຈ່າຍ',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '${totalpay}',
                              style: TextStyle(color: Colors.white),
                            ),
                            Divider(
                              color: Colors.white,
                            ),
                            Text(
                              '${percentpay}%',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Container(
                      decoration: new BoxDecoration(color: Colors.green),
                      child: ListTile(
                        onTap: () {
                          Navigator.of(context).pushNamed('/recive');
                        },
                        leading: Icon(
                          Icons.style,
                          size: 50.0,
                          color: Colors.white,
                        ),
                        title: const Text(
                          '​ລາຍ​ຮັບ',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '${totalrecive}',
                              style: TextStyle(color: Colors.white),
                            ),
                            Divider(
                              color: Colors.white,
                            ),
                            Text(
                              '${percentrecive}%',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Container(
                      decoration: new BoxDecoration(color: Colors.pink),
                      child: ListTile(
                        onTap: () {
                          Navigator.of(context).pushNamed('/daocar');
                        },
                        leading: Icon(
                          Icons.local_taxi,
                          size: 50.0,
                          color: Colors.white,
                        ),
                        title: const Text(
                          'ຈ່າຍ​​ຄ່າ​ລົດ',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'ສ່ວນ​ຄ້າງ: ${still_car}',
                              style: TextStyle(color: Colors.white),
                            ),
                            Divider(
                              color: Colors.white,
                            ),
                            Text(
                              'ສ່ວນຈ່າຍ​ແລ້​ວ: ${pay_car}',
                              style: TextStyle(color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Container(
                      decoration: new BoxDecoration(color: Colors.lightBlue),
                      child: ListTile(
                        onTap: (){
                          Navigator.of(context).pushNamed('/mainchart');
                        },
                        leading: Icon(
                          Icons.poll,
                          size: 50.0,
                          color: Colors.white,
                        ),
                        title: const Text(
                          'ລາຍ​ງານ',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '${totalrecive}',
                              style: TextStyle(color: Colors.white),
                            ),
                            Divider(
                              color: Colors.white,
                            ),
                            Text(
                              '${totalpay}',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
