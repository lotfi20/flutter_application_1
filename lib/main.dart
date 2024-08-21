import 'package:flutter/material.dart';
import 'routes.dart'; // Import the routes.dart file

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Suivi des Interventions',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        fontFamily: 'Roboto',  // Use a professional font family
      ),
      initialRoute: '/',
      routes: AppRoutes.define(),
    );
  }
}
