import 'package:flutter/material.dart';
import '../constants/marsupi_theme.dart';
import '../services/mock_data_service.dart';
import 'home_screen.dart';
import 'loading_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _maskedEmail {
    final email = widget.email.trim();
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return '$name***@$domain';
    return '${name[0]}***${name[name.length - 1]}@$domain';
  }

  Future<void> _verifyOtp() async {
    final code = _controllers.map((c) => c.text.trim()).join();
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, informe os 4 dígitos do código de acesso.'),
          backgroundColor: MarsupiColors.primary,
        ),
      );
      return;
    }

    final success = await showMarsupiLoading<bool>(
      context,
      message: 'Confirmando seu acesso...',
      task: () => MockDataService.instance.verifyOtp(code),
    );

    if (mounted && (success ?? false)) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Voltar
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, size: 18, color: MarsupiColors.primary),
                  label: const Text(
                    'Voltar',
                    style: TextStyle(
                      color: MarsupiColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Título
              const Text(
                'Confirme seu acesso',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: MarsupiColors.darkForest,
                ),
              ),
              const SizedBox(height: 8),

              // Subtítulo e link
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'Digite o código de 4 dígitos enviado para ',
                    style: TextStyle(fontSize: 14, color: MarsupiColors.textMuted),
                  ),
                  Text(
                    _maskedEmail,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: MarsupiColors.darkForest,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Alterar e-mail',
                      style: TextStyle(
                        fontSize: 13,
                        color: MarsupiColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              const Text(
                'Código de verificação',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: MarsupiColors.darkForest,
                ),
              ),
              const SizedBox(height: 12),

              // 4 Caixas de PIN
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 68,
                    height: 72,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: MarsupiColors.darkForest,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: _controllers[index].text.isNotEmpty
                                ? MarsupiColors.primary
                                : MarsupiColors.mintBorder,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: MarsupiColors.primary,
                            width: 2.0,
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        setState(() {});
                        if (val.isNotEmpty && index < 3) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (val.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // Linha suave de progresso com pontinhos (do design Figma)
              Center(
                child: CustomPaint(
                  size: const Size(220, 16),
                  painter: _WavyProgressPainter(),
                ),
              ),
              const SizedBox(height: 36),

              // Botão Verificar
              ElevatedButton(
                onPressed: _verifyOtp,
                child: const Text('Verificar código'),
              ),
              const SizedBox(height: 20),

              // Reenviar
              const Center(
                child: Text(
                  'Reenviar código em 00:24',
                  style: TextStyle(
                    fontSize: 13,
                    color: MarsupiColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              const Center(
                child: Text(
                  'Não encontrou? Confira a caixa de spam.',
                  style: TextStyle(
                    fontSize: 12,
                    color: MarsupiColors.textMuted,
                  ),
                ),
              ),

              const SizedBox(height: 60),
              const Center(
                child: Text(
                  'Marsupi',
                  style: TextStyle(
                    fontSize: 12,
                    color: MarsupiColors.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WavyProgressPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = MarsupiColors.mintBorder
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.8, size.width * 0.5, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.1, size.width, size.height * 0.5);
    canvas.drawPath(path, paint);

    // Pontos verdes e ponto final âmbar
    final dotPaint = Paint()..style = PaintingStyle.fill;

    dotPaint.color = MarsupiColors.primary;
    canvas.drawCircle(Offset(10, size.height * 0.55), 4, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.45, size.height * 0.45), 4, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.4), 4, dotPaint);

    dotPaint.color = MarsupiColors.accentPeach;
    canvas.drawCircle(Offset(size.width - 10, size.height * 0.5), 4.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
