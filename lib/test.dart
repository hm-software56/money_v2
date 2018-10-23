import 'package:flutter/material.dart';
import 'dart:async';

//import OneSignal
import 'package:onesignal/onesignal.dart';

class Test extends StatefulWidget {
  @override
  _TestState createState() => new _TestState();
}

class _TestState extends State<Test> {
  String _debugLabelString = "";
  String _emailAddress;
  bool _enableConsentButton = false;

  // CHANGE THIS parameter to true if you want to test GDPR privacy consent
  bool _requireConsent = true;

  @override
  void initState() {
    super.initState();
    _initOneSignal();
  }

   _initOneSignal() async {
    OneSignal.shared.init("8611a545-6f5f-4e15-9e3a-b992ae4c6cac");
    OneSignal.shared.promptUserForPushNotificationPermission();
         var status = await OneSignal.shared.getPermissionSubscriptionState();
        var playerId = status.subscriptionStatus.userId;

print(playerId); 
print('object');
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
          appBar: new AppBar(
            title: const Text('OneSignal Flutter Demo'),
            backgroundColor: Color.fromARGB(255, 212, 86, 83),
          ),
          body: Container(
          )),
    );
  }
}
