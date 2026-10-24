import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/marsupi_theme.dart';
import '../services/api_service.dart';
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
    if (name.isEmpty) return '***@$domain';
    return '${name[0]}***@$domain';
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

    final result = await showMarsupiLoading<Map<String, dynamic>>(
      context,
      message: 'Carregando...',
      task: () => ApiService.instance.verifyOtp(code),
    );

    if (mounted) {
      if (result?['success'] == true) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else {
        final errorMsg = result?['error'] as String? ?? 'Código de verificação incorreto.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filledCount = _controllers.where((c) => c.text.trim().isNotEmpty).length;

    return Scaffold(
      backgroundColor: MarsupiTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text(
                    '← Voltar',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: MarsupiTheme.primaryGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 44),
              Text(
                'Confirme seu acesso',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: MarsupiTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Digite o código de 4 dígitos enviado para',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: MarsupiTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  Text(
                    _maskedEmail,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: MarsupiTheme.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(
                      'Alterar e-mail',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: MarsupiTheme.primaryGreen,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              Text(
                'Código de verificação',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: MarsupiTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  final hasValue = _controllers[index].text.isNotEmpty;
                  return SizedBox(
                    width: 76,
                    height: 72,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: MarsupiTheme.textPrimary,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: MarsupiTheme.background,
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: hasValue
                                ? MarsupiTheme.primaryGreen
                                : MarsupiTheme.mintBorder,
                            width: hasValue ? 2.0 : 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: MarsupiTheme.primaryGreen,
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
              const SizedBox(height: 18),
              SizedBox(
                height: 20,
                child: CustomPaint(
                  painter: _WavyProgressPainter(filledCount: filledCount),
                ),
              ),
              const SizedBox(height: 34),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _verifyOtp,
                  child: Text(
                    'Verificar código',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: MarsupiTheme.background,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Center(
                child: Text(
                  'Reenviar código em 00:24',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: MarsupiTheme.primaryGreen,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Não encontrou? Confira a caixa de spam.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: MarsupiTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 120),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Marsupi',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: MarsupiTheme.primaryGreen,
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
  final int filledCount;
  _WavyProgressPainter({required this.filledCount});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = MarsupiTheme.mintBorder
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final x0 = 38.0;
    final x1 = size.width * 0.36;
    final x2 = size.width * 0.64;
    final x3 = size.width - 38.0;

    path.moveTo(x0, 10);
    path.cubicTo(
      (x0 + x1) / 2,
      2,
      (x0 + x1) / 2,
      14,
      x1,
      8,
    );
    path.cubicTo(
      (x1 + x2) / 2,
      4,
      (x1 + x2) / 2,
      16,
      x2,
      11,
    );
    path.cubicTo(
      (x2 + x3) / 2,
      6,
      (x2 + x3) / 2,
      12,
      x3,
      9,
    );
    canvas.drawPath(path, linePaint);

    final points = [
      Offset(x0, 10),
      Offset(x1, 8),
      Offset(x2, 11),
      Offset(x3, 9),
    ];

    for (var i = 0; i < 4; i++) {
      if (i < 3) {
        final fillPaint = Paint()
          ..color = MarsupiTheme.primaryGreen
          ..style = PaintingStyle.fill;
        canvas.drawCircle(points[i], 4, fillPaint);
      } else {
        final bgPaint = Paint()
          ..color = MarsupiTheme.background
          ..style = PaintingStyle.fill;
        final strokePaint = Paint()
          ..color = filledCount >= 4
              ? MarsupiTheme.primaryGreen
              : MarsupiTheme.amberHighlight
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(points[i], 4, bgPaint);
        canvas.drawCircle(points[i], 4, strokePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WavyProgressPainter oldDelegate) =>
      oldDelegate.filledCount != filledCount;
}
