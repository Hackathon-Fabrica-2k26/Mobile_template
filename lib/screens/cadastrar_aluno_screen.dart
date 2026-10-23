import 'package:flutter/material.dart';
import '../constants/marsupi_theme.dart';
import '../services/mock_data_service.dart';
import 'loading_screen.dart';

class CadastrarAlunoScreen extends StatefulWidget {
  final int turmaId;
  final String turmaNome;
  final String turno;

  const CadastrarAlunoScreen({
    super.key,
    required this.turmaId,
    this.turmaNome = '1º ano A',
    this.turno = 'Manhã',
  });

  @override
  State<CadastrarAlunoScreen> createState() => _CadastrarAlunoScreenState();
}

class _CadastrarAlunoScreenState extends State<CadastrarAlunoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _nascimentoController = TextEditingController();
  final _matriculaController = TextEditingController();
  late String _turmaSelecionada;

  @override
  void initState() {
    super.initState();
    _turmaSelecionada = '${widget.turmaNome} · ${widget.turno}';
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _nascimentoController.dispose();
    _matriculaController.dispose();
    super.dispose();
  }

  void _salvarAluno() async {
    if (!_formKey.currentState!.validate()) return;

    final nome = _nomeController.text.trim();

    await showMarsupiLoading(
      context,
      message: 'Cadastrando aluno na turma...',
      task: () async {
        await Future.delayed(const Duration(milliseconds: 400));
        await MockDataService.instance.addTurmaComAlunos(
          nome: widget.turmaNome,
          turno: widget.turno,
          anoLetivo: 2026,
          nomesAlunos: [nome],
        );
      },
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✓ Estudante "$nome" adicionado com sucesso!'),
        backgroundColor: MarsupiColors.primary,
      ),
    );

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarsupiColors.background,
      appBar: AppBar(
        backgroundColor: MarsupiColors.background,
        elevation: 0,
        title: const Text(
          'Cadastrar aluno',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: MarsupiColors.darkForest,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: MarsupiColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: MarsupiColors.mintBorder),
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: MarsupiColors.darkForest, size: 20),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Fechar',
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                // Ícone Central (Figma)
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: MarsupiColors.mintContainer.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1_outlined,
                      size: 38,
                      color: MarsupiColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Adicione um aluno à sua turma.',
                    style: TextStyle(fontSize: 14, color: MarsupiColors.textMuted),
                  ),
                ),
                const SizedBox(height: 28),

                // Campo Nome completo *
                const Text(
                  'Nome completo *',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(hintText: 'Digite o nome do aluno'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome do aluno' : null,
                ),
                const SizedBox(height: 18),

                // Campo Data de nascimento (opcional)
                const Text(
                  'Data de nascimento (opcional)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nascimentoController,
                  keyboardType: TextInputType.datetime,
                  decoration: const InputDecoration(
                    hintText: 'dd/mm/aaaa',
                    suffixIcon: Icon(Icons.calendar_today_outlined, size: 20, color: MarsupiColors.primary),
                  ),
                ),
                const SizedBox(height: 18),

                // Campo Matrícula (opcional)
                const Text(
                  'Matrícula (opcional)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _matriculaController,
                  decoration: const InputDecoration(hintText: 'Digite a matrícula'),
                ),
                const SizedBox(height: 18),

                // Campo Turma
                const Text(
                  'Turma',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _turmaSelecionada,
                  decoration: const InputDecoration(),
                  items: [
                    DropdownMenuItem(
                      value: _turmaSelecionada,
                      child: Text(_turmaSelecionada),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _turmaSelecionada = val);
                  },
                ),
                const SizedBox(height: 6),
                const Text(
                  'O aluno será adicionado à lista desta turma.',
                  style: TextStyle(fontSize: 12, color: MarsupiColors.textMuted),
                ),
                const SizedBox(height: 40),

                // Botões (Figma)
                ElevatedButton(
                  onPressed: _salvarAluno,
                  child: const Text('Cadastrar aluno'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
