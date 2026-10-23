import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/marsupi_theme.dart';

/// Tela de carregamento exibida entre transições assíncronas de páginas (Figma 125:96)
Future<T?> showMarsupiLoading<T>(
  BuildContext context, {
  String message = 'Carregando...',
  required Future<T> Function() task,
}) async {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: MarsupiTheme.background,
    pageBuilder: (ctx, anim1, anim2) => Scaffold(
      backgroundColor: MarsupiTheme.background,
      body: MarsupiLoadingView(message: message),
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
    width: 8,
    height: 8,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
    ),
  );
}

/// Widget reutilizável idêntico ao frame Mobile / Carregamento (Figma 125:96)
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
            width: 128,
            height: 152,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: MarsupiTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDot(MarsupiTheme.primaryGreen),
              const SizedBox(width: 10),
              _buildDot(MarsupiTheme.mintBorder),
              const SizedBox(width: 10),
              _buildDot(MarsupiTheme.amberHighlight),
            ],
          ),
        ],
      ),
    );
  }
}
