import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/marsupi_theme.dart';

class LoadingScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const LoadingScreen({super.key, required this.onFinished});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1400), widget.onFinished);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarsupiColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/canguru_simbolo.png',
              height: 140,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 28),
            const Text(
              'Carregando...',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: MarsupiColors.darkForest,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(MarsupiColors.primary),
                const SizedBox(width: 8),
                _buildDot(MarsupiColors.sage),
                const SizedBox(width: 8),
                _buildDot(MarsupiColors.accentPeach),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
