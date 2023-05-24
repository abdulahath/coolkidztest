import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import './myWebViewWidget.dart';


TargetPlatform? platform;
String? defaultUserAgent;


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // This allows to use async methods in the main method without any problem.

  // for enable debugging the app on inappwebview
  if (!kIsWeb && kDebugMode && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);}

  // This is for get the default user agent and pass it to inappwebview settings.
  defaultUserAgent = await InAppWebViewController.getDefaultUserAgent();
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyWebViewWidget(platform: platform, defaultUserAgent: defaultUserAgent,)
    );
  }
}