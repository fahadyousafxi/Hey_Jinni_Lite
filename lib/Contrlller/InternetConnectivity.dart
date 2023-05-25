import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ezeehome_webview/constants.dart';

import 'package:flutter/material.dart';

class CheckInternetConnection {
  static bool checkInternet = true;
  static Future<bool> isConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      // I am connected to a mobile network.
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a wifi network.
      return true;
    }
    return false;
  }

//for cheking internet connection
  static checkInternetFunction() async {
    if (await CheckInternetConnection.isConnected()) {
      checkInternet = true;
    } else {
      checkInternet = false;
    }
  }
}

// when there in no internet connection then show this widget
Widget noInternetConnectionMessage() {
  return Scaffold(
    backgroundColor: Colors.white,
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.signal_wifi_connected_no_internet_4,
            size: 60,
            color:MyColors.kprimaryColor,
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
            onPressed: () {},
            child: Text('Reload Page'),
          ),
        ],
      ),
    ),
  );
}
