import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:prime/providers/bank_account_provider.dart';
import 'package:prime/providers/car_provider.dart';
import 'package:prime/providers/car_rental_provider.dart';
import 'package:prime/providers/issue_report_provider.dart';
import 'package:prime/providers/notification_provider.dart';
import 'package:prime/providers/search_cars_provider.dart';
import 'package:prime/providers/search_issue_reports_provider.dart';
import 'package:prime/providers/stripe_payment_method_provider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'providers/search_rentals_provider.dart';
import 'providers/search_users_provider.dart';
import 'providers/status_history_provider.dart';
import 'providers/verification_document_provider.dart';
import 'providers/address_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/user_provider.dart';
import 'providers/theme_provider.dart';
import 'services/notification_service.dart';
import 'views/auth/auth_screen.dart';

// Firebase Messaging Variable
RemoteMessage? currentMessageData;

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on Exception catch (e) {
    if (kDebugMode) {
      print(e.toString());
    }
  }
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await dotenv.load();
  _stripeInitialization();

  // Firebase Messaging Setup
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings notificationSettings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  debugPrint('Permission Result: ${notificationSettings.authorizationStatus}');

  try {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('Initial Message Received: $initialMessage');
      currentMessageData = initialMessage;
      _handleInitialMessageLogic(initialMessage);
    }
  } on Exception catch (e) {
    debugPrint("Error handling initial message: $e");
  }

  // Foreground Message Handling
  FirebaseMessaging.onMessage.listen((message) {
    currentMessageData = message;
    _handleForegroundMessageLogic(message);
  });

  // Background Message Handling
  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  // Message Opened App Handling
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    currentMessageData = message;
    _handleMessageOpenedAppLogic(message);
  });

  await NotificationService.initializeNotification();

  runApp(const MyApp());
}

// for notification navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void _stripeInitialization() {
  String? stripePublishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'];
  if (stripePublishableKey != null) {
    Stripe.publishableKey = stripePublishableKey;
  } else {
    debugPrint('Stripe publishable key is not found');
    throw Exception('Stripe publishable key is not found');
  }
}

// Example logic for each handler (replace with your specific actions)
void _handleInitialMessageLogic(RemoteMessage message) {
  // Navigate to a specific screen based on message data
  // Or display a custom message using a SnackBar
}

Future<void> _handleForegroundMessageLogic(RemoteMessage message) async {
  // display a notification using the NotificationService
  if (message.notification != null) {
    await NotificationService.showNotification(
      title: message.notification?.title ?? 'Notification Title',
      body: message.notification?.body ?? 'Notification Body',
    );
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // No need to display a notification here, firebase messaging will handle it
  currentMessageData = message;
  // Schedule a background task
  // Or update server data
}

void _handleMessageOpenedAppLogic(RemoteMessage message) {
  // Access the message data from `currentMessageData` if needed
  // Show a detailed message or perform further actions
  // navigation can be done here
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => VerificationDocumentProvider()),
        ChangeNotifierProvider(create: (_) => StatusHistoryProvider()),
        ChangeNotifierProvider(create: (_) => CarProvider()),
        ChangeNotifierProvider(create: (_) => BankAccountProvider()),
        ChangeNotifierProvider(create: (_) => CarRentalProvider()),
        ChangeNotifierProvider(create: (_) => IssueReportProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => SearchCarsProvider()),
        ChangeNotifierProvider(create: (_) => SearchRentalsProvider()),
        ChangeNotifierProvider(create: (_) => SearchIssueReportsProvider()),
        ChangeNotifierProvider(create: (_) => SearchUsersProvider()),
        ChangeNotifierProvider(create: (_) => StripePaymentMethodProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, themeProvider, __) => MaterialApp(
          title: 'PRIME',
          navigatorKey: navigatorKey,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              brightness: themeProvider.themeMode == ThemeModeType.light
                  ? Brightness.light
                  : Brightness.dark,
              seedColor: Colors.cyanAccent,
            ),
          ),
          debugShowCheckedModeBanner: false,
          home: const AuthScreen(),
        ),
      ),
    );
  }
}
