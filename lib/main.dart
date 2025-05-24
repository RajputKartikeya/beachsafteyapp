import 'package:flutter/material.dart';
import 'screens/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Firebase Realtime Database with persistence enabled
    FirebaseDatabase.instance.setPersistenceEnabled(true);

    // Configure database to use HTTPS for web and secure connections
    FirebaseDatabase.instance.databaseURL =
        'https://beachsafteyappbpit-default-rtdb.firebaseio.com';

    // Set log level in debug mode to help with troubleshooting
    FirebaseDatabase.instance.setLoggingEnabled(true);

    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  runApp(const BeachSafeApp());
}

class BeachSafeApp extends StatelessWidget {
  const BeachSafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BeachSafe India',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
