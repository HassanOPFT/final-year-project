import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:prime/providers/bank_account_provider.dart';
import 'package:prime/providers/car_provider.dart';
import 'package:prime/providers/car_rental_provider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'providers/status_history_provider.dart';
import 'providers/verification_document_provider.dart';
import 'providers/address_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/user_provider.dart';
import 'providers/theme_provider.dart';
import 'views/auth/auth_screen.dart';

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
  runApp(const MyApp());
}

void _stripeInitialization() {
  String? stripePublishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'];
  if (stripePublishableKey != null) {
    Stripe.publishableKey = stripePublishableKey;
  } else {
    debugPrint('Stripe publishable key is not found');
    throw Exception('Stripe publishable key is not found');
  }
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
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, themeProvider, __) => MaterialApp(
          title: 'PRIME',
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
