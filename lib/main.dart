import 'package:flutter/material.dart';
import 'pages/dashboard.dart';
import 'pages/entity_list_page.dart'; // <-- Assure-toi que ce chemin est correct

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
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardPage(),
        '/salles': (context) => const EntityListPage(
          endpoint: 'salles/',
          fieldsToShow: ['nom', 'capacite', 'disponible'],
        ),
        // Tu peux ajouter d'autres routes ici si besoin
      },
    );
  }
}