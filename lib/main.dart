import 'package:flutter/material.dart';
import 'constants/marsupi_theme.dart';
import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MarsupiApp());
}

class MarsupiApp extends StatelessWidget {
  const MarsupiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marsupi',
      debugShowCheckedModeBanner: false,
      theme: MarsupiTheme.theme,
      home: const LoginScreen(),
    );
  }
}
