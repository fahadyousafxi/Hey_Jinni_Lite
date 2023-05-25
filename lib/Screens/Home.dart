import 'dart:async';
import 'dart:io';

import 'package:ezeehome_webview/Contrlller/InternetConnectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  Home({
    super.key,
    required this.isInternetConnected,
  }) {}

  bool isInternetConnected;
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var IsInternetConnected = true;
  bool loader = false;
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  void initState() {
    checkInternetConnectionForDashboard();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
    requestPermissions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF04abf2),
        // title: Text('DriveBC'),
        //centerTitle: true,
        toolbarHeight: 10,
      ),
      body: IsInternetConnected == false
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.signal_wifi_connected_no_internet_4,
                    size: 60,
                    color: Colors.black,
                  ),
                  Container(
                    child: Text(
                      'No Internet Connection',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF04abf2),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => Home(
                          isInternetConnected: IsInternetConnected,
                        ),
                      ));
                    },
                    child: Text('Reload Page'),
                  ),
                ],
              ),
            )
          : Builder(builder: (BuildContext context) {
              return WebView(
                initialUrl: 'https://heyjinni.com/',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller.complete(webViewController);
                },
                onProgress: (int progress) {
                  print("WebView is loading (progress : $progress%)");
                },
                javascriptChannels: <JavascriptChannel>{
                  // _toasterJavascriptChannel(context),
                  JavascriptChannel(
                      name: 'Toaster',
                      onMessageReceived: (JavascriptMessage message) {
                        var snackBar = SnackBar(
                          content: Text(message.message),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      })
                },
                navigationDelegate: (NavigationRequest request) {
                  if (request.url.startsWith('https://www.youtube.com/')) {
                    print('blocking navigation to $request}');
                    return NavigationDecision.prevent;
                  }
                  print('allowing navigation to $request');
                  return NavigationDecision.navigate;
                },
                onPageStarted: (String url) {
                  print('Page started loading: $url');
                },
                onPageFinished: (String url) {
                  print('Page finished loading: $url');
                },
                gestureNavigationEnabled: true,
                geolocationEnabled: false, //support geolocation or not
                zoomEnabled: true,
              );
            }),
    );
  }

  checkInternetConnectionForDashboard() async {
    // to check the internet connection
    await CheckInternetConnection.checkInternetFunction();

    if (!CheckInternetConnection.checkInternet) {
      setState(() {
        IsInternetConnected = false;
        loader = true;
      });
    } else {
      setState(() {
        loader = true;
        IsInternetConnected = true;
      });
    }
  }

  void requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
      Permission.microphone,
      Permission.phone,
    ].request();

    if (statuses[Permission.camera]!.isGranted &&
        statuses[Permission.storage]!.isGranted &&
        statuses[Permission.microphone]!.isGranted &&
        statuses[Permission.phone]!.isGranted) {
      // All permissions granted, proceed with the functionality.
      print('All permissions granted!');
    } else {
      // Permissions not granted, handle accordingly.
      print('Some or all permissions not granted!');
    }
  }

}

