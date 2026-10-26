import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/marsupi_theme.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'loading_screen.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _matriculaController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _obscurePassword = true;
  bool _manterConectado = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _matriculaController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final matricula = _matriculaController.text.trim();
    final senha = _senhaController.text;

    final result = await showMarsupiLoading<Map<String, dynamic>>(
      context,
      message: 'Carregando...',
      task: () => ApiService.instance.login(matricula, senha),
    );

    if (mounted) {
      if (result?['success'] == true && result?['otp_required'] == false) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else if (result?['success'] == true) {
        final email = (result?['email'] as String?) ?? '';
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OtpScreen(email: email),
          ),
        );
      } else {
        final errorMsg = result?['error'] as String? ?? 'Matrícula ou senha incorretos.';
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
    return Scaffold(
      backgroundColor: MarsupiTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 36),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Image.asset(
                    'assets/images/logo_marsupi_horizontal.png',
                    width: 250,
                    height: 104,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Bem-vindo de volta',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: MarsupiTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Entre com sua matrícula para continuar.',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: MarsupiTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Matrícula',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: MarsupiTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _matriculaController,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: MarsupiTheme.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Digite sua matrícula',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Informe sua matrícula';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                Text(
                  'Senha',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: MarsupiTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _senhaController,
                  obscureText: _obscurePassword,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: MarsupiTheme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Digite sua senha',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: MarsupiTheme.primaryGreen,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Informe sua senha';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    SizedBox(
                      height: 18,
                      width: 18,
                      child: Checkbox(
                        value: _manterConectado,
                        activeColor: MarsupiTheme.primaryGreen,
                        side: const BorderSide(
                          color: MarsupiTheme.mintBorder,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        onChanged: (val) =>
                            setState(() => _manterConectado = val ?? false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Manter conectado',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: MarsupiTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Esqueci minha senha',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        color: MarsupiTheme.primaryGreen,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text(
                      'Entrar',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: MarsupiTheme.background,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 96),
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
      ),
    );
  }
}
