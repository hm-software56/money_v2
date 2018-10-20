import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
      Response response = await dio
          .get('${modelurl.url}api/listpayment', data: {'user_id': userID});
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
    loadlistpayment();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ລາຍ​ການ​ລາຍ​ຈ່າຍ​ທັງ​ໝົດ'),
        //automaticallyImplyLeading: true,
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
                                                listpayment[index]['date'],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: <Widget>[
                                              IconButton(
                                                icon: Icon(
                                                  Icons.border_color,
                                                  color: Colors.green,
                                                ),
                                                onPressed: () {},
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.remove_circle_outline,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {},
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
                            color: Colors.brown,
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
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => FormPayment()));
          }),
    );
  }
}
