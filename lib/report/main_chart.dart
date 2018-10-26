import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money/login.dart';
import 'package:money/models/model_url.dart';
import 'package:money/report/chart.dart';
import 'package:money/report/chart_m.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainChart extends StatefulWidget {
  @override
  _MainChartState createState() => _MainChartState();
}

class _MainChartState extends State<MainChart> {
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

  bool isloading = true;
  var pay;
  var recive;
  var paym;
  var recivem;
  Future getallhart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dio.options.connectTimeout = 6000; //5s
    dio.options.receiveTimeout = 6000;
    try {
      Response response = await dio.get('${modelurl.url}api/charty');
      Response responsem = await dio.get('${modelurl.url}api/chartm');
      if (response.statusCode == 200 || responsem.statusCode==200) {

        var p = [
          OrdinalSales(response.data[0]['year'], response.data[0]['pay']),
          OrdinalSales(response.data[1]['year'], response.data[1]['pay']),
          OrdinalSales(response.data[2]['year'], response.data[2]['pay']),
        ];
        var r = [
          OrdinalSales(response.data[0]['year'], response.data[0]['recive']),
          OrdinalSales(response.data[1]['year'], response.data[1]['recive']),
          OrdinalSales(response.data[2]['year'], response.data[2]['recive']),
        ];

        var pm = [
          OrdinalSalesM(responsem.data[0]['year'], responsem.data[0]['pay']),
          OrdinalSalesM(responsem.data[1]['year'], responsem.data[1]['pay']),
          OrdinalSalesM(responsem.data[2]['year'], responsem.data[2]['pay']),
          OrdinalSalesM(responsem.data[2]['year'], responsem.data[3]['pay']),
          OrdinalSalesM(responsem.data[2]['year'], responsem.data[4]['pay']),
        ];
        var rm = [
          OrdinalSalesM(responsem.data[0]['year'], responsem.data[0]['recive']),
          OrdinalSalesM(responsem.data[1]['year'], responsem.data[1]['recive']),
          OrdinalSalesM(responsem.data[2]['year'], responsem.data[2]['recive']),
          OrdinalSalesM(responsem.data[2]['year'], responsem.data[3]['recive']),
          OrdinalSalesM(responsem.data[2]['year'], responsem.data[4]['recive']),
        ];
        setState(() {
          isloading = false;
          pay = p;
          recive = r;
          paym = pm;
          recivem = rm; 
        });
      }
    } on DioError catch (e) {
      setState(() {
        isloading = false;
      });
      alert('ມີ​ຂ​ໍ້​ຜິດ​ພາດ', 'ກວດ​ເບີ່ງ​ການ​ເຊື່ອມ​ຕໍ່​ເນັ​ດ.!');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getallhart();
  }

  final a = [
    new OrdinalSales('2016', 100),
    new OrdinalSales('2017', 75), 
  ];

  final b = [
    new OrdinalSales('2016', 10),
    new OrdinalSales('2017', 20),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Chart'),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 10.0),
          child: isloading
              ? Center(child: CircularProgressIndicator())
              : ListView(
                  children: <Widget>[
                    SizedBox(
                      height: 150.0,
                      child:
                          HorizontalPatternForwardHatchBarChart.withSampleData(
                              recive, pay),
                    ),
                    Divider(),
                    SizedBox(
                      height: 150.0,
                      child:
                          HorizontalPatternForwardHatchBarChartM.withSampleData(
                              recivem, paym),
                    )
                  ],
                ),
        ));
  }
}
 