// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';


// import '../services/api_service.dart';
// import '../services/device_utils.dart';

// import 'dart:io';
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   late final WebViewController webController;
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   bool _isLoading = true;
//   bool _hasError = false;

//   @override
//   void initState() {
//     super.initState();

//     webController = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onProgress: (progress) {},
//           onPageStarted: (url) {
//             setState(() {
//               _isLoading = true;
//               _hasError = false;
//             });
//           },

//           onPageFinished: (url) async {
//             setState(() {
//               _isLoading = false;
//             });

//             try {
//               final deviceId = await DeviceUtils.getOrCreateDeviceId();
//               final token = await FirebaseMessaging.instance.getToken(); // FCM token
//               final jwtToken = await DeviceUtils.getAccessToken();
//               final uri = Uri.parse(url);
//               final relativePath = uri.path; // /about-us/

//               // Use the actual URL as the path
//               await ApiService.logActivity(
//                 deviceId: deviceId,
//                 path: relativePath, // dynamic path here
//                 method: "GET",
//                 token: token,
//                 jwtToken: jwtToken,
//               );
//             } catch (e) {
//               print("❌ Failed to log activity: $e");
//             }
//           },

          
          
//           onWebResourceError: (error) {
//             setState(() {
//               _isLoading = false;
//               _hasError = true;
//             });
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse('https://jobs.academy'));

//     _setupFirebaseMessaging();

    
//   }

//   void _setupFirebaseMessaging() async {
//     FirebaseMessaging messaging = FirebaseMessaging.instance;

//     await messaging.requestPermission();

//     String? token = await messaging.getToken();
//     print("FCM Token: $token");

//     if (token != null) {
//       final deviceId = await DeviceUtils.getOrCreateDeviceId();
//       final ipAddress = await DeviceUtils.getPublicIP();
//       final jwt = await DeviceUtils.getAccessToken();

//       await ApiService.registerDeviceToken(
//         token: token,
//         deviceId: deviceId,
//         deviceType: Platform.isAndroid ? "android" : "ios",
//         ipAddress: ipAddress,
//         jwtToken: jwt,
//       );
//     }


//     const AndroidInitializationSettings androidInit =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     await flutterLocalNotificationsPlugin.initialize(
//       const InitializationSettings(android: androidInit),
//       onDidReceiveNotificationResponse: (response) {
//         final payload = response.payload ?? 'https://jobs.academy';
//         webController.loadRequest(Uri.parse(payload));
//       },
//     );

//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       if (message.notification != null) {
//         flutterLocalNotificationsPlugin.show(
//           message.hashCode,
//           message.notification!.title,
//           message.notification!.body,
//           const NotificationDetails(
//             android: AndroidNotificationDetails(
//               'default_channel',
//               'General Notification',
//               channelDescription: 'This channel is used for general notifications',
//               importance: Importance.max,
//               priority: Priority.high,
//             ),
//           ),
//           payload: message.data['url'] ?? 'https://jobs.academy',
//         );
//       }
//     });

//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       final url = message.data['url'] ?? 'https://jobs.academy';
//       webController.loadRequest(Uri.parse(url));
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       onPopInvoked: (didPop) async {
//         if (await webController.canGoBack()) {
//           webController.goBack();
//           return;
//         }
//       },
//       child: Scaffold(
//         body: SafeArea(
//           child: Stack(
//             children: [
//               if (!_hasError) WebViewWidget(controller: webController),

//               // Loader
//               if (_isLoading)
//                 Container(
//                   color: Theme.of(context).scaffoldBackgroundColor,
//                   child: const Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         CircularProgressIndicator(color: Colors.deepPurple),
//                         SizedBox(height: 20),
//                         Text(
//                           'Loading content...',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey,
//                             fontStyle: FontStyle.italic,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//               // Error Page
//               if (_hasError)
//                 Container(
//                   color: Theme.of(context).scaffoldBackgroundColor,
//                   padding: const EdgeInsets.all(24.0),
//                   child: Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(Icons.cloud_off,
//                             size: 100, color: Colors.redAccent),
//                         const SizedBox(height: 24),
//                         const Text(
//                           'Network Error',
//                           style: TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         const Text(
//                           'Could not connect to the internet. Please check your connection and try again.',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.black54,
//                           ),
//                         ),
//                         const SizedBox(height: 32),
//                         ElevatedButton.icon(
//                           onPressed: () {
//                             webController.reload();
//                             setState(() {
//                               _isLoading = true;
//                               _hasError = false;
//                             });
//                           },
//                           icon: const Icon(Icons.refresh),
//                           label: const Text('Reload Page'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.deepPurple,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 24,
//                               vertical: 12,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/api_service.dart';
import '../services/device_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final WebViewController webController;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isLoading = true; // True only for the initial page load (controlled by WebView)
  bool _isInitialized = false; // NEW: True when all initial setup (Ads, FCM) is complete
  bool _hasError = false;

  // AdMob variables
  late BannerAd _bannerAdTop;
  late BannerAd _bannerAdBottom;
  bool _isBannerTopLoaded = false;
  bool _isBannerBottomLoaded = false;
  InterstitialAd? _interstitialAd;
  int _pageViewCount = 0; // Track number of pages visited

  @override
  void initState() {
    super.initState();
    // Start the asynchronous initialization process.
    // This allows the build method to run while setup is in progress.
    _initializeAllFeatures(); 
  }

  // ⭐ FIX: Handles all async setup and initializes the WebView LAST.
  Future<void> _initializeAllFeatures() async {
    // 1. Initialize AdMob (starts loading ads in the background)
    _initAds();
    
    // 2. Setup Firebase Messaging (waits for async token registration/permissions)
    await _setupFirebaseMessaging(); 

    // 3. Mark the general app initialization as complete
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }

    // 4. Finally, initialize and load the WebView.
    _initWebView();
  }


  void _initWebView() {
    webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {},
          onPageStarted: (url) {
            // Loader MUST NOT be shown on subsequent page loads/navigations.
            setState(() {
              _hasError = false;
            });
          },
          onPageFinished: (url) async {
            // ⭐ CRITICAL FIX: The loader ONLY hides here, when the web content loads.
            setState(() => _isLoading = false); 
            _pageViewCount++;

            // log user activity (logic remains the same)
            try {
              final deviceId = await DeviceUtils.getOrCreateDeviceId();
              final token = await FirebaseMessaging.instance.getToken();
              final jwtToken = await DeviceUtils.getAccessToken();
              final uri = Uri.parse(url);
              final relativePath = uri.path;

              await ApiService.logActivity(
                deviceId: deviceId,
                path: relativePath,
                method: "GET",
                token: token,
                jwtToken: jwtToken,
              );
            } catch (e) {
              if (kDebugMode) {
                 print("❌ Failed to log activity: $e");
              }
            }

            // Show interstitial ad every 3rd page load
            if (_pageViewCount % 3 == 0) {
              _showInterstitialAd();
            }
          },
          onWebResourceError: (error) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse('https://jobs.academy'));
  }

  // ⭐ CORRECTED METHOD: Must be async for the await calls
  Future<void> _setupFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();

    String? token = await messaging.getToken();
    if (kDebugMode) {
      print("FCM Token: $token");
    }

    if (token != null) {
      final deviceId = await DeviceUtils.getOrCreateDeviceId();
      final ipAddress = await DeviceUtils.getPublicIP();
      final jwt = await DeviceUtils.getAccessToken();
      await ApiService.registerDeviceToken(
        token: token,
        deviceId: deviceId,
        deviceType: Platform.isAndroid ? "android" : "ios",
        ipAddress: ipAddress,
        jwtToken: jwt,
      );
    }

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(android: androidInit),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload ?? 'https://jobs.academy';
        webController.loadRequest(Uri.parse(payload));
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        flutterLocalNotificationsPlugin.show(
          message.hashCode,
          message.notification!.title,
          message.notification!.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'default_channel',
              'General Notification',
              channelDescription:
                  'This channel is used for general notifications',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          payload: message.data['url'] ?? 'https://jobs.academy',
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final url = message.data['url'] ?? 'https://jobs.academy';
      webController.loadRequest(Uri.parse(url));
    });
  }

  void _initAds() {
    final String bannerTopId = kDebugMode
        ? 'ca-app-pub-3940256099942544/6300978111'
        : 'ca-app-pub-2887876230461314/6448609451';

    final String bannerBottomId = kDebugMode
        ? 'ca-app-pub-3940256099942544/6300978111'
        : 'ca-app-pub-2887876230461314/4138140883';

    final String interstitialId = kDebugMode
        ? 'ca-app-pub-3940256099942544/1033173712'
        : 'ca-app-pub-2887876230461314/7259128248';

    _bannerAdTop = BannerAd(
      adUnitId: bannerTopId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isBannerTopLoaded = true),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (kDebugMode) {
            print('❌ Top banner failed: $error');
          }
        },
      ),
    )..load();

    _bannerAdBottom = BannerAd(
      adUnitId: bannerBottomId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isBannerBottomLoaded = true),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (kDebugMode) {
            print('❌ Bottom banner failed: $error');
          }
        },
      ),
    )..load();

    _loadInterstitial(interstitialId);
  }

  void _loadInterstitial(String interstitialId) {
    InterstitialAd.load(
      adUnitId: interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialAd?.setImmersiveMode(true);
          if (kDebugMode) {
            print("✅ Interstitial Ad Loaded");
          }
        },
        onAdFailedToLoad: (err) {
          if (kDebugMode) {
            print('❌ Interstitial failed to load: $err');
          }
          _interstitialAd = null;
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;

      // Load next ad for later
      final String interstitialId = kDebugMode
          ? 'ca-app-pub-3940256099942544/1033173712'
          : 'ca-app-pub-2887876230461314/7259128248';
      _loadInterstitial(interstitialId);
    } else {
      if (kDebugMode) {
        print("⚠️ Interstitial not ready yet");
      }
    }
  }

  @override
  void dispose() {
    _bannerAdTop.dispose();
    _bannerAdBottom.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (await webController.canGoBack()) {
          webController.goBack();

          // Occasionally show interstitial when going back
          if (_pageViewCount % 4 == 0) {
            _showInterstitialAd();
          }
          return;
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Show banner ads only if they are loaded
              if (_isBannerTopLoaded)
                SizedBox(
                  width: _bannerAdTop.size.width.toDouble(),
                  height: _bannerAdTop.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAdTop),
                ),
              Expanded(
                child: Stack(
                  children: [
                    // ⭐ Webview only renders when initialized and no error exists
                    if (_isInitialized && !_hasError) WebViewWidget(controller: webController), 
                    
                    // ⭐ LOADER LOGIC: Shows if setup is incomplete OR initial page is loading
                    if (_isLoading || !_isInitialized) 
                      const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.deepPurple),
                            SizedBox(height: 20),
                            Text(
                              'Loading content...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_hasError)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cloud_off,
                                  size: 100, color: Colors.redAccent),
                              const SizedBox(height: 24),
                              const Text(
                                'Network Error',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Please check your internet connection and try again.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 32),
                              ElevatedButton.icon(
                                onPressed: () {
                                  webController.reload();
                                  // Set _isLoading to true to show the loader during manual reload
                                  setState(() {
                                    _isLoading = true; 
                                    _hasError = false;
                                  });
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reload Page'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (_isBannerBottomLoaded)
                SizedBox(
                  width: _bannerAdBottom.size.width.toDouble(),
                  height: _bannerAdBottom.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAdBottom),
                ),
            ],
          ),
        ),
      ),
    );
  }
}