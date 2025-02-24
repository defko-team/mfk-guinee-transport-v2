import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mfk_guinee_transport/helper/firebase/firebase_options.dart';
import 'package:mfk_guinee_transport/services/firebase_messaging_service.dart';
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
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Global navigator key for showing overlays and navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Constants for SharedPreferences keys
const String _kProviderAuthKey = "isProviderAuthenticated";
const String _kCustomerAuthKey = "isCustomerAuthenticated";
const String _kDriverAuthKey = "isDriverAuthenticated";
const String _kFcmTokenKey = "fcmToken";
const String _kUserIdKey = "userId";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configure system UI
  await _configureSystemUI();

  // Determine home page based on auth state
  final homePage = await _determineHomePage();

  runApp(MyApp(homePage: homePage));
}

Future<void> _configureSystemUI() async {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
}

Future<Widget> _determineHomePage() async {
  final bool isConnected = await isConnectedToInternet();
  final prefs = await SharedPreferences.getInstance();

  final bool isProviderAuthenticated =
      prefs.getBool(_kProviderAuthKey) ?? false;
  final bool isCustomerAuthenticated =
      prefs.getBool(_kCustomerAuthKey) ?? false;
  final bool isDriverAuthenticated = prefs.getBool(_kDriverAuthKey) ?? false;

  if (!isConnected) {
    return const NoNetwork(pageToGo: '/login');
  }

  if (isProviderAuthenticated) {
    return const AdminHomePage();
  } else if (isCustomerAuthenticated) {
    return const HomePage();
  } else if (isDriverAuthenticated) {
    return const DriverHomePage();
  }

  return const SplashScreen();
}

Future<void> _initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (defaultTargetPlatform == TargetPlatform.android) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<bool> isConnectedToInternet() async {
  // TODO: Implement actual network connectivity check
  return true;
}

class MyApp extends StatefulWidget {
  final Widget homePage;

  const MyApp({super.key, required this.homePage});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isSnackbarVisible = false;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Theme configuration
  static final ThemeData _theme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D7643)),
    iconTheme: const IconThemeData(size: 18.0),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    ),
  );

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _setupNotifications();
  }

  Future<void> _initializeNotifications() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_notification');
      const initSettings = InitializationSettings(android: androidSettings);

      await _notificationsPlugin.initialize(initSettings);

      // Create the notification channel for Android
      const androidChannel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      // Create the Android notification channel
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);

      debugPrint('Notification channel created');
    }
  }

  Future<void> _playAlertSound(String title, String body) async {
    if (!mounted || defaultTargetPlatform != TargetPlatform.android) return;

    try {
      const androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        showWhen: true,
        icon: '@mipmap/ic_notification',
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        0,
        title,
        body,
        notificationDetails,
      );
      debugPrint('Alert sound played successfully');
    } catch (e) {
      debugPrint('Error playing alert sound: $e');
    }
  }

  Future<void> _setupNotifications() async {
    if (!mounted) return;

    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        final messagingService = FirebaseMessagingService();
        await messagingService.initialize();
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
        debugPrint('Notifications setup complete');
      } catch (e) {
        debugPrint('Error setting up notifications: $e');
      }
    }
  }

  void _handleForegroundMessage(RemoteMessage message) async {
    if (!mounted) return;
    if (message.notification != null) {
      debugPrint('Received foreground message, playing alert...');
      await _playAlertSound(
        message.notification?.title ?? 'New Message',
        message.notification?.body ?? '',
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Guinea Transport',
      theme: _theme,
      home: widget.homePage,
      routes: getAppRoutes(),
      onGenerateRoute: (settings) {
        // Handle dynamic routes here if needed
        return MaterialPageRoute(
          builder: (context) => const NoNetwork(pageToGo: '/login'),
        );
      },
      onUnknownRoute: (settings) {
        // Fallback for unknown routes
        return MaterialPageRoute(
          builder: (context) => const NoNetwork(pageToGo: '/login'),
        );
      },
    );
  }
}
