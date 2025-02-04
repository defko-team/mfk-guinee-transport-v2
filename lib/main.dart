import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mfk_guinee_transport/helper/firebase/firebase_options.dart';
import 'package:mfk_guinee_transport/models/user_model.dart';
import 'package:mfk_guinee_transport/services/firebase_messaging_service.dart';
import 'package:mfk_guinee_transport/services/user_service.dart';
import 'package:mfk_guinee_transport/views/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mfk_guinee_transport/views/admin_home_page.dart';
import 'package:mfk_guinee_transport/views/driver_home_page.dart';
import 'package:mfk_guinee_transport/views/home_page.dart';
import 'package:mfk_guinee_transport/views/no_network.dart';
import 'package:mfk_guinee_transport/views/login.dart';
import 'package:mfk_guinee_transport/helper/router/router.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/scheduler.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initFirebase();

  bool isConnected = await isConnectedToInternet();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SharedPreferences preferences = await SharedPreferences.getInstance();

  // preferences.clear();
  var isProviderAuthenticated = preferences.getBool("isProviderAuthenticated");
  var isCustomerAuthenticated = preferences.getBool("isCustomerAuthenticated");
  var isDriverAuthenticated = preferences.getBool("isDriverAuthenticated");
  var fcmToken = preferences.getString('fcmToken');
  var userId = preferences.getString('userId');
  print('userId ${userId}');
  print('FCM TOKEN ${fcmToken}');

  Widget homePage;

  if (!isConnected) {
    if (isProviderAuthenticated == true) {
      homePage = const NoNetwork(pageToGo: "/providerHome");
    } else if (isCustomerAuthenticated == true) {
      homePage = const NoNetwork(pageToGo: "/customerHome");
    } else if (isDriverAuthenticated == true) {
      homePage = const NoNetwork(pageToGo: "/driverHome");
    } else {
      homePage = const NoNetwork(pageToGo: "/login");
    }
  } else if (isProviderAuthenticated == true) {
    homePage = const AdminHomePage();
  } else if (isCustomerAuthenticated == true) {
    homePage = HomePage();
  } else if (isDriverAuthenticated == true) {
    homePage = const DriverHomePage();
  } else {
    // homePage = const Login();
    homePage = const SplashScreen();
  }

  runApp(MyApp(homePage: homePage));
}

Future<void> _initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (defaultTargetPlatform == TargetPlatform.android) {
    // Set the background message handler first
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Need to initialize Firebase here as well
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling background message: ${message.messageId}');
}

Future<bool> isConnectedToInternet() async {
  // Implémentez la logique pour vérifier la connexion Internet
  // Par exemple, vous pouvez utiliser le package 'connectivity_plus'
  // pour vérifier l'état de la connexion.
  return true; // Remplacez par la logique réelle
}

class MyApp extends StatefulWidget {
  final Widget homePage;

  const MyApp({super.key, required this.homePage});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupNotifications();
  }

  Future<void> _setupNotifications() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Initialize Firebase Messaging Service
      final messagingService = FirebaseMessagingService();
      await messagingService.initialize();

      // Setup foreground notification listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');
        print('Message notification: ${message.notification}');
        if (message.notification != null) {
          print(
              'Message also contained a notification: ${message.notification}');
          _showTopSnackbar(
              message.notification?.title, message.notification?.body);
        }
      });
    }
  }

  void _showTopSnackbar(String? title, String? body) {
    if (title != null && body != null && mounted) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        OverlayEntry? entry;
        entry = OverlayEntry(
          builder: (context) {
            final mediaQuery = MediaQuery.of(context);
            return SafeArea(
              child: Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Material(
                  color: Colors.transparent,
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, -50 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.green.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.notifications_none_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        body,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => entry?.remove(),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );

        Navigator.of(context).overlay?.insert(entry);

        // Auto-dismiss after 4 seconds
        Future.delayed(const Duration(seconds: 4), () {
          entry?.remove();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Guinea Transport',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.green),
        iconTheme: const IconThemeData(size: 18.0),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
      ),
      home: widget.homePage,
      routes: getAppRoutes(),
    );
  }
}
