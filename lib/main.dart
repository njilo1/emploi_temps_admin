import 'package:flutter/material.dart';
import 'pages/dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion Emplois du Temps',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const DashboardPage(),
    );
  }
}
