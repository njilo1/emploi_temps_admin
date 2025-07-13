import 'package:flutter/material.dart';
import 'pages/dashboard.dart';
import 'utils/platform_utils.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.teal,
        // Amélioration de l'interface pour le desktop
        cardTheme: CardThemeData(
          elevation: PlatformUtils.isDesktop ? 8 : 4,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: PlatformUtils.isDesktop 
              ? const EdgeInsets.symmetric(horizontal: 24, vertical: 16)
              : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: PlatformUtils.isDesktop
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
      home: const DashboardPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
