import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:money/daocar/form_daocar.dart';
import 'package:money/home.dart';
import 'package:money/login.dart';
import 'package:money/models/model_url.dart';
import 'package:money/payment/form_payment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ListDaocar extends StatefulWidget {
  @override
  _ListDaocarState createState() => _ListDaocarState();
}

class _ListDaocarState extends State<ListDaocar> {
  Dio dio = new Dio();
  ModelUrl modelurl = ModelUrl();

  int userID;
  var listdaocar;
  var sumdaocar;
  bool isloading = true;
/*========== Login expired ================*/
  Future<Null> checkloginexiped() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyyMMddhm');
    String formatted = formatter.format(now);
    if (int.parse(formatted) >= prefs.getInt('time')) {
      prefs.remove('token');
      prefs.remove('time');
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Login()));
    } else {
      prefs.setInt('time', int.parse(formatted) + 10);
    }
  }
  /* ============================= alert ================*/
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

    dio.options.connectTimeout = 12000; //5s
    dio.options.receiveTimeout = 12000;
    try {
      Response sumresponse = await dio.get('${modelurl.url}api/sumdaocar');
      Response response = await dio.get('${modelurl.url}api/listdaocar');
      if (response.statusCode == 200) {
        //  print(response.data);
        setState(() {
          listdaocar = response.data;
          sumdaocar = sumresponse.data;
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
    dio.options.connectTimeout = 12000; //5s
    dio.options.receiveTimeout = 12000;
    try {
      Response response =
          await dio.get('${modelurl.url}api/daocardelete', data: {'id': id});
      if (response.statusCode == 200) {
        //print(response.data);
        setState(() {
          listdaocar = response.data;
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
        title: Text('ລາຍ​ການ​ສຳ​ລ​ະ​ຄ່າ​ລົດ'),
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
                : ListView.builder(
                    itemCount: listdaocar != null ? listdaocar.length : 0,
                    itemBuilder: (BuildContext context, int index) {
                      int count = listdaocar.length - index;
                      final formatter = new NumberFormat("#,###.00");
                      var status;
                      if (listdaocar[index]['status'] == "Paid") {
                        status = "​ຈ່າຍ​ແລ້ວ";
                      } else if (listdaocar[index]['status'] == "Saving") {
                        status =
                            "​ເກັບ​ໄວ້ ( ${listdaocar[index]['remark']} ) ";
                      } else {
                        status =
                            "​ເອົາ​ໄປ​ເຮັດ​ແນວອື່ນ ( ${listdaocar[index]['remark']} ) ";
                      }
                      return new Column(
                        children: <Widget>[
                          count != listdaocar.length
                              ? Divider()
                              : Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: SizedBox(
                                        height: 30.0,
                                        child: Container(
                                          padding: EdgeInsets.only(top: 5.0),
                                          color: Colors.yellow,
                                          child: Column(
                                            children: <Widget>[
                                              Text(formatter.format(int.parse(
                                                      sumdaocar['saving'])) +
                                                  ' ​ໂດ​ລາ'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                     Expanded(
                                      child: SizedBox(
                                        height: 30.0,
                                        child: Container(
                                          padding: EdgeInsets.only(top: 5.0),
                                          color: Colors.green,
                                          child: Column(
                                            children: <Widget>[
                                              Text(formatter.format(int.parse(
                                                      sumdaocar['paid'])) +
                                                  ' ​ໂດ​ລາ'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                     Expanded(
                                      child: SizedBox(
                                        height: 30.0,
                                        child: Container(
                                          padding: EdgeInsets.only(top: 5.0),
                                          color: Colors.red,
                                          child: Column(
                                            children: <Widget>[
                                              Text(formatter.format(int.parse(
                                                      sumdaocar['remark'])) +
                                                  ' ​ໂດ​ລາ'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                          new ListTile(
                            leading: Text('${count}'),
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
                                                formatter.format(int.parse(
                                                        listdaocar[index]
                                                            ['amount'])) +
                                                    ' ​ໂດ​ລາ',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                              Text(
                                                '${status}',
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: true,
                                                maxLines: 2,
                                              ),
                                              Text(
                                                listdaocar[index]['date'],
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 30.0,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: <Widget>[
                                              IconButton(
                                                icon: Icon(
                                                  Icons.edit_location,
                                                  color: Colors.green,
                                                ),
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          fullscreenDialog:
                                                              true,
                                                          builder: (context) =>
                                                              FormDaocar(
                                                                  listdaocar[
                                                                          index]
                                                                      ['id'])));
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
                    builder: (context) => FormDaocar(null)));
          }),
    );
  }
}
