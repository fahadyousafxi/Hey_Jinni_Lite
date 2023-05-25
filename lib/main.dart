import 'package:ezeehome_webview/Contrlller/InternetConnectivity.dart';
import 'package:ezeehome_webview/Screens/Home.dart';
import 'package:flutter/material.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await checkInternetConnectionForDashboard();
  runApp(MyApp());
}

var isInternetConnected = false;
checkInternetConnectionForDashboard() async {
  // to check the internet connection
  await CheckInternetConnection.checkInternetFunction();

  if (!CheckInternetConnection.checkInternet) {
    isInternetConnected = false;
  } else {
    isInternetConnected = true;
  }
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Hey Jinni Lite',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Home(
          isInternetConnected: isInternetConnected,
        ));
  }
}
