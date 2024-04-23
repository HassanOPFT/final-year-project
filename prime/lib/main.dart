import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
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
