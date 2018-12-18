import 'package:flutter/material.dart';
import 'package:money/report/tab_pay_month.dart';
import 'package:money/report/tab_pay_week.dart';
import 'package:money/report/tab_pay_year.dart';
import 'package:money/report/tab_recive_month.dart';
import 'package:money/report/tab_recive_week.dart';
import 'package:money/report/tab_recive_year.dart';
class ReportRecive extends StatefulWidget {
  _ReportReciveState createState() => _ReportReciveState();
}

class _ReportReciveState extends State<ReportRecive> {
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
            title: Text('ລາຍ​ງານ​ລາຍ​ຮັບ'),
          ),
          body: TabBarView(
            children: [
               TabReciveWeek(),
              TabReciveMonth(),
              TabReciveYear(),
            ],
            
          ),
        ),
    
    );
  }
}