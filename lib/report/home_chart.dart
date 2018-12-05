import 'package:flutter/material.dart';
//import 'package:flutter_plugin_webview/webview_scaffold.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
class HomeChart extends StatefulWidget {
  _HomeChartState createState() => _HomeChartState();
}

class _HomeChartState extends State<HomeChart> {
  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
        url: "http://dev.cyberia.la/testda/api/web/",
          appBar: new AppBar(
            title: new Text("ລາຍ​ງານ"),
          ),
    );
  }
}