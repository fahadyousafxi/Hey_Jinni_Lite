import 'dart:async';

import 'package:ezeehome_webview/Contrlller/InternetConnectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Home extends StatefulWidget {
  Home({
    super.key,
    required this.isInternetConnected,
    // required this.interstitialAd01,
    // required this.isloadedIntAd
  }) {
    if (this.isInternetConnected) {
      initInterstitialAd();
      Future.delayed(Duration(seconds: 4), () async {
        if (this.isloadedIntAd == true) {
          this.interstitialAd.show();
        }
      });
    }
  }

  bool isInternetConnected;
  // InterstitialAd interstitialAd01;

  late InterstitialAd interstitialAd;
  bool isloadedIntAd = false;
//bool IsInternetConnectedforAds = true;

  initInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-4371054866340571/6418410324',
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: (Error) {
          print('My Eror  ////////////////=/////////////////  $Error');
        },
      ),
    );
  }

  void onAdLoaded(InterstitialAd ad) {
    interstitialAd = ad;
    isloadedIntAd = true;

    interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        interstitialAd.dispose();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        interstitialAd.dispose();
      },
    );
  }

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late InterstitialAd interstitialAd;
  bool _isloadedIntAd = false;
  //=================
  var IsInternetConnected = true;
  bool loader = false;

  @override
  void initState() {
    // interstitialAd = widget.interstitialAd;
    // _isloadedIntAd = widget._isloadedIntAd;
    // TODO: implement initState
    checkInternetConnectionForDashboard();
    if (IsInternetConnected) {
      widget.initInterstitialAd();
      Future.delayed(Duration(seconds: 4), () async {
        if (widget.isloadedIntAd == true) {
          widget.interstitialAd.show();
        }
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // if (IsInternetConnected == true) {
    widget.initInterstitialAd();
    if (widget.isloadedIntAd == true) {
      widget.interstitialAd.show();
    }
    //}

    return WillPopScope(
      onWillPop: () async {
        bool? goBack = await controller.canGoBack();
        if (goBack != true)
          return true;
        else {
          controller.goBack();
          return false;
        }
      },
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFF34dce7),
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
                          backgroundColor: Color.fromARGB(255, 181, 12, 219),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Home(
                              isInternetConnected: IsInternetConnected,
                              // interstitialAd01: widget.interstitialAd01,
                              // isloadedIntAd: widget.isloadedIntAd,
                              // interstitialAd: interstitialAd,
                              // isloadedIntAd: _isloadedIntAd,
                            ),
                          ));
                        },
                        child: Text('Reload Page'),
                      ),
                    ],
                  ),
                )
              : WebViewWidget(controller: controller)),
    );
  }

//=============================================
  var controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..reload()
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Update loading bar.
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith('https://www.youtube.com/')) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    )
    // ..loadRequest(Uri.parse('https://cellphonestars.com/'));
    ..loadRequest(Uri.parse('https://influencerswithlikes.com/'));

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
}
