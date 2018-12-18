import 'package:flutter/material.dart';
import 'package:money/report/tab_pay_month.dart';
import 'package:money/report/tab_pay_week.dart';
import 'package:money/report/tab_pay_year.dart';
class ReportPayment extends StatefulWidget {
  _ReportPaymentState createState() => _ReportPaymentState();
}

class _ReportPaymentState extends State<ReportPayment> {
  @override
  Widget build(BuildContext context) {
    return  DefaultTabController(
        length:3,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(child: Column(children: <Widget>[
                  Icon(Icons.devices,),
                  Text('ອາ​ທິດ')
                ],)),
                Tab(child: Column(children: <Widget>[
                  Icon(Icons.important_devices),
                  Text('​ເດືອນ')
                ],)),
                Tab(child: Column(children: <Widget>[
                  Icon(Icons.computer),
                  Text('​ປີ')
                ],)),
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