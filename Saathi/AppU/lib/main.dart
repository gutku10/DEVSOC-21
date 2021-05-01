import 'package:AppU/Screens/Auth_screen.dart';
import 'package:AppU/Screens/dashboard_Screen.dart';
import 'package:AppU/Screens/new_trip_screen.dart';
import 'package:AppU/Screens/ongoin_trip_screen.dart';
import 'package:AppU/Screens/tabs_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        accentColor: Colors.orangeAccent,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, userSnapShot) {
          if (userSnapShot.hasData) {
            return TabsScreen();
          }
          return AuthScreen();
        },
      ),
      routes: {
        // TabsScreen.routeName: (context) => TabsScreen(),
        // AuthScreen.routeName: (context) => AuthScreen(),
        DashboardScreen.routeName: (context) => DashboardScreen(),
        NewTripScreen.routeName: (context) => NewTripScreen(),
        OngoingTripScreen.routeName: (context) => OngoingTripScreen(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => DashboardScreen(),
      ),
    );
  }
}
