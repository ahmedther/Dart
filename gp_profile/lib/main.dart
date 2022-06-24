import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import './providers/providers.dart';
import 'package:provider/provider.dart';
import './screens/add_gp_screen.dart';
import '../screens/search_screen.dart';
//
import 'auth/main_page.dart';

void main() async {
  /// initialize FireBase App
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Providers()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Flutter Log In & Sign up Authentication with FireBase",
      home: MainScreen(),
      routes: {
        AddGPScreen.routeName: (context) => AddGPScreen(),
        SearchScreen.routeName: (context) => SearchScreen(),
      },
    );
  }
}
