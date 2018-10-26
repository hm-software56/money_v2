import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:money/home.dart';
import 'package:money/login.dart';
import 'package:money/models/model_url.dart';
import 'package:money/payment/form_payment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ListPayment extends StatefulWidget {
  @override
  _ListPaymentState createState() => _ListPaymentState();
}

class _ListPaymentState extends State<ListPayment> {
  Dio dio = new Dio();
  ModelUrl modelurl = ModelUrl();

  int userID;
  var listpayment;
  bool isloading = true;

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
  /* ==================== alert ==============*/
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

  Future loadlistpayment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int token = await prefs.get('token');
    setState(() {
      userID = token;
    });

    dio.options.connectTimeout = 3000; //5s
    dio.options.receiveTimeout = 3000;
    try {
      Response response = await dio.get('${modelurl.url}api/listpayment');
      if (response.statusCode == 200) {
        //  print(response.data);
        setState(() {
          listpayment = response.data;
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

/*====================Cormfirt delete ====================*/
  void delcomfirm(var title, var detail, var id) {
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
            FlatButton(
              child: new Text("Yes"),
              onPressed: () {
                delete(id);
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: new Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

/*================= delete ===================*/
  Future delete(var id) async {
    dio.options.connectTimeout = 3000; //5s
    dio.options.receiveTimeout = 3000;
    try {
      Response response =
          await dio.get('${modelurl.url}api/paymentdelete', data: {'id': id});
      if (response.statusCode == 200) {
        //print(response.data);
        setState(() {
          listpayment = response.data;
        });
        isloading = false;
      }
    } on DioError catch (e) {
      isloading = false;
      alert('ມີ​ຂ​ໍ້​ຜິດ​ພາດ', 'ກວດ​ເບີ່ງ​ການ​ເຊື່ອມ​ຕໍ່​ເນັ​ດ.!');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkloginexiped();
    loadlistpayment();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ລາຍ​ການ​ລາຍ​ຈ່າຍ​ທັງ​ໝົດ'),
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => Home()));
            }),
      ),
      body: Container(
          padding: const EdgeInsets.all(5.0),
          alignment: Alignment.center,
          child: RefreshIndicator(
            onRefresh: loadlistpayment,
            child: isloading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                :ListView.builder(
                    itemCount: listpayment != null ? listpayment.length : 0,
                    itemBuilder: (BuildContext context, int index) {
                      final formatter = new NumberFormat("#,###");
                      // listpayment[index]['amount']
                      return new Column(
                        children: <Widget>[ 
                          new ListTile(
                            leading: SizedBox(
                                width: 60.0,
                                height: 60.0,
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      '${modelurl.urlimg}${listpayment[index]['user']['photo']}'),
                                )),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                IntrinsicHeight(
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                listpayment[index]['typePay']
                                                    ['name'],
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14.0,
                                                    color: Colors.black),
                                              ),
                                              Text(
                                                formatter.format(int.parse(
                                                        listpayment[index]
                                                            ['amount'])) +
                                                    ' ກີບ',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                              Text(
                                                listpayment[index]
                                                    ['description'],
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: true,
                                                maxLines: 2,
                                              ),
                                              Text(
                                                listpayment[index]['date'],
                                              ),
                                            ],
                                          ),
                                        ),
                                        userID !=
                                                int.parse(listpayment[index]
                                                    ['user_id'])
                                            ? Text('')
                                            : SizedBox(
                                                width: 30.0,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: <Widget>[
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.border_color,
                                                        color: Colors.green,
                                                      ),
                                                      onPressed: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                fullscreenDialog:
                                                                    true,
                                                                builder: (context) =>
                                                                    FormPayment(
                                                                        listpayment[index]
                                                                            [
                                                                            'id'])));
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons
                                                            .remove_circle_outline,
                                                        color: Colors.red,
                                                      ),
                                                      onPressed: () {
                                                        delcomfirm(
                                                            'ແຈ້ງ​ເຕືອນ',
                                                            'ທ່ານ​ຕ້ອງ​ການ​ລຶບ​ລາຍ​ການນີ້​ແມ​່ນ​ບໍ.?',
                                                            listpayment[index]
                                                                ['id']);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              )
                                      ]),
                                ),
                              ],
                            ),
                          ),
                          new Divider(
                            height: 2.0,
                          ),
                        ],
                      );
                    },
                  ),
          )),
      floatingActionButton: new FloatingActionButton(
          backgroundColor: Colors.red,
          child: new Icon(Icons.add_circle),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => FormPayment(null)));
            /* Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => FormPayment()));*/
          }),
    );
  }
}
