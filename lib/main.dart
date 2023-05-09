import 'package:ezeehome_webview/Contrlller/InternetConnectivity.dart';
import 'package:ezeehome_webview/Screens/Home.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await checkInternetConnectionForDashboard();
  // if (isInternetConnected) {
  //   Future.delayed(Duration(seconds: 4), () async {
  //     initInterstitialAd();
  //   });
  // }
  // Future.delayed(Duration(seconds: 4), () async {
  //   runApp(MyApp());
  // });
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

// late InterstitialAd interstitialAd;
// bool _isloadedIntAd = false;

// initInterstitialAd() {
//   InterstitialAd.load(
//     adUnitId: 'ca-app-pub-4371054866340571/4866124695',
//     request: AdRequest(),
//     adLoadCallback: InterstitialAdLoadCallback(
//       onAdLoaded: onAdLoaded,
//       onAdFailedToLoad: (Error) {
//         print('My Eror  ////////////////=/////////////////  $Error');
//       },
//     ),
//   );
// }

// void onAdLoaded(InterstitialAd ad) {
//   interstitialAd = ad;
//   _isloadedIntAd = true;

//   interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
//     onAdDismissedFullScreenContent: (ad) {
//       interstitialAd.dispose();
//     },
//     onAdFailedToShowFullScreenContent: (ad, error) {
//       interstitialAd.dispose();
//     },
//   );
// }

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Influencers with Likes',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Home(
          isInternetConnected: isInternetConnected,
          // interstitialAd01: interstitialAd, isloadedIntAd: _isloadedIntAd,
          // interstitialAd: interstitialAd,
          // isloadedIntAd: _isloadedIntAd,
        ));
  }
}
