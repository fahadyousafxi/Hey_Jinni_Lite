import 'dart:async';
import 'dart:io';

import 'package:ezeehome_webview/Contrlller/InternetConnectivity.dart';
import 'package:ezeehome_webview/Contrlller/ad_mob_services.dart';
import 'package:ezeehome_webview/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final _webViewController = Completer<WebViewController>();
  double _progress = 0.0; // Variable to hold the progress percentage
  bool _isLoading = true;
  int _progressText = 0; // Variable to track loading state

  late BannerAd _bannerAd;
  InterstitialAd? _interstialAd;
  bool isAdLoaded = false;
  void _createBannerAd() {
    _bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: AdsMobServices.BannerAdUnitId!,
        listener: AdsMobServices.bannerAdListener,
        request: AdRequest())
      ..load();
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: AdsMobServices.InterstitialAdId!,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (ad) => _interstialAd = ad,
            onAdFailedToLoad: (LoadAdError loadAdError) =>
                _interstialAd = null));
  }

  @override
  void initState() {
    checkInternetConnectionForDashboard();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
    requestPermissions();
    super.initState();
    _createBannerAd();
    _createInterstitialAd();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
                  _showInterstitalAd();

        bool? goBack =
            await _webViewController.future.then((value) => value.canGoBack());
        if (goBack != true) {
          print('appClosed');
          return true;
        } else {
          _webViewController.future.then((controller) => controller.goBack());
          print('appnotClosed');
          return false;
        }
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: AppBar(
            backgroundColor: MyColors.kprimaryColor,
            elevation: 0,
          ),
        ),
        body: IsInternetConnected == false
            ? RefreshIndicator(
                onRefresh: () {
                  return Future.delayed(Duration(seconds: 1), () {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Home(
                        isInternetConnected: IsInternetConnected,
                      ),
                    ));
                  });
                },
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.signal_wifi_connected_no_internet_4,
                            size: 60,
                            color: MyColors.kprimaryColor,
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
                              backgroundColor: MyColors.kprimaryColor,
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
                    ),
                  ),
                ),
              )
            : Stack(
                children: [
                  WebView(
                    initialUrl: 'https://heyjinni.com/',
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (WebViewController webViewController) {
                      _webViewController.complete(webViewController);
                    },
                    javascriptChannels: <JavascriptChannel>{
                      // _toasterJavascriptChannel(context),
                      JavascriptChannel(
                          name: 'Toaster',
                          onMessageReceived: (JavascriptMessage message) {
                            var snackBar = SnackBar(
                              content: Text(message.message),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          })
                    },
                    navigationDelegate: (NavigationRequest request) {
                      if (request.url.contains('heyjinni.com')) {
                        return NavigationDecision.navigate;
                      } else if (request.url
                          .startsWith('https://www.youtube.com/')) {
                        print('blocking navigation to $request}');
                        return NavigationDecision.prevent;
                      } else {
                        print('opening external link');
                        _launchExternalUrl(request.url);
                        // launchUrl(Uri.parse(request.url));
                        return NavigationDecision.prevent;
                      }
                      print('allowing navigation to $request');
                      // return NavigationDecision.navigate;
                    },
                    onProgress: (int progress) {
                      print("WebView is loading (progress : $progress%)");
                      setState(() {
                        _progress = progress / 100;
                        _progressText = progress;
                        // Update progress based on the value received (0-100)
                      });
                    },
                    onPageStarted: (String url) {
                      print('Page started loading: $url');
                      setState(() {
                        _isLoading =
                            true; // Set loading state to true when a new page starts loading
                      });
                    },
                    onPageFinished: (String url) {
                      print('Page finished loading: $url');
                      setState(() {
                        _isLoading =
                            false; // Set loading state to false when the page finishes loading
                      });
                    },
                    gestureNavigationEnabled: true,
                    geolocationEnabled: false,
                    zoomEnabled: true,
                  ),
                  Visibility(
                    visible:
                        _isLoading, // Show the progress indicator only when loading
                    child: Center(
                      child: CircularPercentIndicator(
                        radius: 80.0,
                        lineWidth: 15.0,
                        percent: _progress,
                        center: new Text(
                          "$_progressText%",
                          style: TextStyle(
                              color: MyColors.kprimaryColor, fontSize: 40),
                        ),
                        progressColor: MyColors.kprimaryColor,
                        backgroundColor: Color.fromARGB(255, 104, 204, 247),
                        circularStrokeCap: CircularStrokeCap.round,
                      ),
                    ),
                    //  CircularProgressIndicator(value: _progress),
                  ),
                ],
              ),
        bottomNavigationBar: _bannerAd != null
            ? Container(
                decoration: BoxDecoration(color: Colors.transparent),
                height: _bannerAd.size.height.toDouble(),
                width: _bannerAd.size.width.toDouble(),
                child: AdWidget(ad: _bannerAd),
              )
            : SizedBox(),
      ),
    );
  }

  Future<void> _launchExternalUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    } else {
      throw 'Could not launch $url';
    }
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

  void _showInterstitalAd() {
    if (_interstialAd != null) {
      _interstialAd!.fullScreenContentCallback =
          FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _createInterstitialAd();
      }, onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _createInterstitialAd();
      });
      _interstialAd!.show();
      _interstialAd = null;
    }
  }
}
