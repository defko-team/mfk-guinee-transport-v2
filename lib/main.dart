import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  final bool isProviderAuthenticated = prefs.getBool(_kProviderAuthKey) ?? false;
  final bool isCustomerAuthenticated = prefs.getBool(_kCustomerAuthKey) ?? false;
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
    _setupNotifications();
  }

  Future<void> _setupNotifications() async {
    if (!mounted) return;
    
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        final messagingService = FirebaseMessagingService();
        await messagingService.initialize();
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      } catch (e) {
        debugPrint('Error setting up notifications: $e');
      }
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (!mounted) return;
    if (message.notification != null) {
      _showTopSnackbar(message.notification?.title, message.notification?.body);
    }
  }

  void _showTopSnackbar(String? title, String? body) {
    if (title == null || body == null || !mounted || _isSnackbarVisible) {
      return;
    }

    _isSnackbarVisible = true;
    final context = navigatorKey.currentContext;
    if (context == null) {
      _isSnackbarVisible = false;
      return;
    }

    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (context) => _buildSnackbarOverlay(title, body, entry),
    );

    Navigator.of(context).overlay?.insert(entry);

    Future.delayed(const Duration(seconds: 4), () {
      entry?.remove();
      _isSnackbarVisible = false;
    });
  }

  Widget _buildSnackbarOverlay(String title, String body, OverlayEntry? entry) {
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
            builder: (context, value, child) => Transform.translate(
              offset: Offset(0, -50 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            ),
            child: Container(
              width: 200,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                          onTap: () {
                            entry?.remove();
                            _isSnackbarVisible = false;
                          },
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
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Guinea Transport',
      theme: _theme,
      home: widget.homePage,
    );
  }
}
