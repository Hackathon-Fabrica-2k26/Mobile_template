import 'package:flutter/material.dart';
import '../constants/marsupi_theme.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _matriculaController = TextEditingController(text: 'PROF-2026');
  final _senhaController = TextEditingController(text: '123456');
  bool _obscurePassword = true;
  bool _manterConectado = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _matriculaController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const OtpScreen(email: 'ana.professora@escola.edu.br'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  // Logo Marsupi
                  Center(
                    child: Image.asset(
                      'assets/images/logo_marsupi.png',
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Título e Subtítulo
                  const Text(
                    'Bem-vindo de volta',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: MarsupiColors.darkForest,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Entre com sua matrícula para continuar.',
                    style: TextStyle(
                      fontSize: 14,
                      color: MarsupiColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Campo Matrícula
                  const Text(
                    'Matrícula',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: MarsupiColors.darkForest,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _matriculaController,
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

                  // Campo Senha
                  const Text(
                    'Senha',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: MarsupiColors.darkForest,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _senhaController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Digite sua senha',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: MarsupiColors.primary,
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
                  const SizedBox(height: 12),

                  // Manter conectado e Esqueci senha
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: _manterConectado,
                              activeColor: MarsupiColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: (val) =>
                                  setState(() => _manterConectado = val ?? false),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Manter conectado',
                            style: TextStyle(
                              fontSize: 12,
                              color: MarsupiColors.darkForest,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Esqueci minha senha',
                          style: TextStyle(
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                            color: MarsupiColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Botão Entrar
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Entrar'),
                  ),

                  const SizedBox(height: 48),
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
        ),
      ),
    );
  }
}
