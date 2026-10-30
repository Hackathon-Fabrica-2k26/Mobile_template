import 'package:flutter/material.dart';
import 'constants/marsupi_theme.dart';
import 'screens/erro_404_screen.dart';
import 'screens/login_screen.dart';
import 'services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MarsupiApp());
}

class MarsupiApp extends StatelessWidget {
  const MarsupiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: ApiService.navigatorKey,
      title: 'Marsupi',
      debugShowCheckedModeBanner: false,
      theme: MarsupiTheme.theme,
      home: const LoginScreen(),
      onUnknownRoute: (_) => MaterialPageRoute(
        builder: (_) => const Erro404Screen(),
      ),
    );
  }
}
