import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ModelUrl{
  String url="http://dev.cyberia.la/testda/api/web/index.php?r=";
  String urlimg="http://dev.cyberia.la/testda/api/web/images/";
  
  settimeloginexpiry() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var now = new DateTime.now();
    var formatter = new DateFormat('h');
    String formatted = formatter.format(now);
    print(formatted); 
    prefs.setInt('time', int.parse(formatted)+2);
  }

}