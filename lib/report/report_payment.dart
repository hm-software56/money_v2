import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money/login.dart';
import 'package:money/report/search_payment.dart';
import 'package:money/report/tab_pay_month.dart';
import 'package:money/report/tab_pay_week.dart';
import 'package:money/report/tab_pay_year.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportPayment extends StatefulWidget {
  _ReportPaymentState createState() => _ReportPaymentState();
}

class _ReportPaymentState extends State<ReportPayment> {
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

  void initState() {
    super.initState();
    checkloginexiped();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (context) => SearchPayment()));
              },
            )
          ],
          bottom: TabBar(
            tabs: [
              Tab(
                  child: Column(
                children: <Widget>[
                  Icon(
                    Icons.devices,
                  ),
                  Text('ອາ​ທິດ')
                ],
              )),
              Tab(
                  child: Column(
                children: <Widget>[
                  Icon(Icons.important_devices),
                  Text('​ເດືອນ')
                ],
              )),
              Tab(
                  child: Column(
                children: <Widget>[Icon(Icons.computer), Text('​ປີ')],
              )),
            ],
          ),
          title: Text('ລາຍ​ງານ​ລາຍ​ຈ່າຍ'),
        ),
        body: TabBarView(
          children: [
            TabPayWeek(),
            TabPayMonth(),
            TabPayYear(),
          ],
        ),
      ),
    );
  }
}
