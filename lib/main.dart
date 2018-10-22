import 'package:flutter/material.dart';
import 'package:money/daocar/list_daocar.dart';
import 'package:money/home.dart';
import 'package:money/login.dart';
import 'package:money/payment/list_payment.dart';
import 'package:money/recive/list_recive.dart';

void main() {
  runApp(new MyApp());
}

final routes = <String, WidgetBuilder>{
    '/login': (context) => Login(),
    '/home': (context) => Home(),
    '/payment':(context) =>ListPayment(),
    '/recive':(context) =>ListRecive(),
    '/daocar':(context) =>ListDaocar(),
    
  };
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Money',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new Login(),
      routes: routes,
    );
  }
}

