import 'package:flutter/material.dart';
import '../constants/marsupi_theme.dart';

/// Diálogo modal de carregamento para transições assíncronas entre telas
Future<T?> showMarsupiLoading<T>(
  BuildContext context, {
  String message = 'Carregando...',
  required Future<T> Function() task,
}) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          decoration: BoxDecoration(
            color: MarsupiColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/canguru_simbolo.png',
                height: 80,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: MarsupiColors.darkForest,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDot(MarsupiColors.primary),
                  const SizedBox(width: 6),
                  _buildDot(MarsupiColors.sage),
                  const SizedBox(width: 6),
                  _buildDot(MarsupiColors.accentPeach),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );

  try {
    final result = await task();
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    return result;
  } catch (e) {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    rethrow;
  }
}

Widget _buildDot(Color color) {
  return Container(
    width: 7,
    height: 7,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
    ),
  );
}

/// Widget reutilizável para estados de carregamento em tela
class MarsupiLoadingView extends StatelessWidget {
  final String message;

  const MarsupiLoadingView({super.key, this.message = 'Carregando...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/canguru_simbolo.png',
            height: 110,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: MarsupiColors.darkForest,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDot(MarsupiColors.primary),
              const SizedBox(width: 6),
              _buildDot(MarsupiColors.sage),
              const SizedBox(width: 6),
              _buildDot(MarsupiColors.accentPeach),
            ],
          ),
        ],
      ),
    );
  }
}
