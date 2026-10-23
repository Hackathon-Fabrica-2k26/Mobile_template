import 'package:flutter/material.dart';
import '../constants/marsupi_theme.dart';
import '../services/mock_data_service.dart';
import 'loading_screen.dart';
import 'turma_detail_screen.dart';

/// ETAPA 1: Dados da Turma e Captura da Foto da Chamada (Figma 277:361)
class NovaTurmaFotoScreen extends StatefulWidget {
  const NovaTurmaFotoScreen({super.key});

  @override
  State<NovaTurmaFotoScreen> createState() => _NovaTurmaFotoScreenState();
}

class _NovaTurmaFotoScreenState extends State<NovaTurmaFotoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController(text: '1º ano A');
  final _anoController = TextEditingController(text: '2026');
  String _turno = 'Manhã';
  bool _fotoAdicionada = true;
  String _nomeArquivo = 'chamada_1ano_a.jpg';

  @override
  void dispose() {
    _nomeController.dispose();
    _anoController.dispose();
    super.dispose();
  }

  void _avancarParaConfirmacao() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_fotoAdicionada) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, adicione uma foto da folha de chamada.'),
          backgroundColor: MarsupiColors.primary,
        ),
      );
      return;
    }

    // Efeito de leitura da foto com IA conforme o Figma (Lendo a chamada...)
    await showMarsupiLoading(
      context,
      message: 'Lendo a chamada e reconhecendo nomes...',
      task: () async => await Future.delayed(const Duration(milliseconds: 600)),
    );

    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConfirmarNomesScreen(
          turmaNome: _nomeController.text.trim(),
          anoLetivo: int.tryParse(_anoController.text.trim()) ?? 2026,
          turno: _turno,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova turma'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Indicador de Etapa
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: MarsupiColors.mintContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'ETAPA 1 DE 3',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: MarsupiColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                const Text(
                  'Cadastre sua turma a partir de uma foto da chamada',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: MarsupiColors.darkForest,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'A IA reconhece os nomes dos alunos automaticamente.',
                  style: TextStyle(fontSize: 13, color: MarsupiColors.textMuted),
                ),
                const SizedBox(height: 24),

                // Campo Nome da turma
                const Text(
                  'Nome da turma *',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(hintText: 'Ex: 1º ano A'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome da turma' : null,
                ),
                const SizedBox(height: 16),

                // Linha Ano Letivo e Turno
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ano letivo *',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _anoController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: '2026'),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Turno *',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _turno,
                            decoration: const InputDecoration(),
                            items: const [
                              DropdownMenuItem(value: 'Manhã', child: Text('Manhã')),
                              DropdownMenuItem(value: 'Tarde', child: Text('Tarde')),
                              DropdownMenuItem(value: 'Integral', child: Text('Integral')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _turno = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Bloco Foto da Chamada
                const Text(
                  'Foto da chamada *',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
                ),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: MarsupiColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: MarsupiColors.mintBorder),
                  ),
                  child: Column(
                    children: [
                      if (_fotoAdicionada) ...[
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: MarsupiColors.mintContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.document_scanner_outlined, color: MarsupiColors.primary, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _nomeArquivo,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: MarsupiColors.darkForest),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    '2,4 MB · Foto pronta para OCR',
                                    style: TextStyle(fontSize: 12, color: MarsupiColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _fotoAdicionada = false;
                                });
                              },
                              child: const Text('Trocar', style: TextStyle(color: MarsupiColors.primary)),
                            ),
                          ],
                        ),
                      ] else ...[
                        const Icon(Icons.camera_alt_outlined, size: 40, color: MarsupiColors.primary),
                        const SizedBox(height: 10),
                        const Text(
                          'Envie uma foto da folha de chamada',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'JPG ou PNG até 20 MB',
                          style: TextStyle(fontSize: 12, color: MarsupiColors.textMuted),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => setState(() {
                                _fotoAdicionada = true;
                                _nomeArquivo = 'foto_camera.jpg';
                              }),
                              icon: const Icon(Icons.photo_camera, size: 16),
                              label: const Text('Tirar foto'),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: () => setState(() {
                                _fotoAdicionada = true;
                                _nomeArquivo = 'chamada_1ano_a.jpg';
                              }),
                              icon: const Icon(Icons.upload_file, size: 16),
                              label: const Text('Galeria'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Card de Dicas de Captura
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: MarsupiColors.mintContainer.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.tips_and_updates_outlined, color: MarsupiColors.primary, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Para reconhecer melhor com IA:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: MarsupiColors.darkForest),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildDicaItem('01 Fotografe a lista inteira sem cortes.'),
                      _buildDicaItem('02 Utilize um ambiente bem iluminado.'),
                      _buildDicaItem('03 Evite sombras ou folhas amassadas.'),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Botão Avançar
                ElevatedButton.icon(
                  onPressed: _avancarParaConfirmacao,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Reconhecer nomes com IA'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDicaItem(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 12, color: MarsupiColors.darkForest),
      ),
    );
  }
}

/// ETAPA 2: Conferência dos Nomes Reconhecidos pelo OCR (Figma 277:361)
class ConfirmarNomesScreen extends StatefulWidget {
  final String turmaNome;
  final int anoLetivo;
  final String turno;

  const ConfirmarNomesScreen({
    super.key,
    required this.turmaNome,
    required this.anoLetivo,
    required this.turno,
  });

  @override
  State<ConfirmarNomesScreen> createState() => _ConfirmarNomesScreenState();
}

class _ConfirmarNomesScreenState extends State<ConfirmarNomesScreen> {
  // Lista inicial de estudantes reconhecidos pela IA (como no Figma 277:361)
  final List<Map<String, dynamic>> _alunosReconhecidos = [
    {'nome': 'Alice Santos', 'precisaConferencia': false},
    {'nome': 'Arthur Oliveira', 'precisaConferencia': false},
    {'nome': 'Beatriz Costa', 'precisaConferencia': false},
    {'nome': 'Davi Pereira', 'precisaConferencia': true},
    {'nome': 'Helena Martins', 'precisaConferencia': false},
    {'nome': 'Lucas Almeida', 'precisaConferencia': false},
    {'nome': 'Maria Eduarda Lima', 'precisaConferencia': true},
    {'nome': 'Miguel Souza', 'precisaConferencia': false},
  ];

  void _editarNome(int index) {
    final controller = TextEditingController(text: _alunosReconhecidos[index]['nome'] as String);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar nome'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nome completo do aluno'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _alunosReconhecidos[index]['nome'] = controller.text.trim();
                  _alunosReconhecidos[index]['precisaConferencia'] = false;
                });
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _removerNome(int index) {
    setState(() {
      _alunosReconhecidos.removeAt(index);
    });
  }

  void _adicionarNomeManual() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adicionar aluno'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Digite o nome do estudante'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _alunosReconhecidos.add({
                    'nome': controller.text.trim(),
                    'precisaConferencia': false,
                  });
                });
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _concluirCadastro() async {
    final nomes = _alunosReconhecidos.map((a) => a['nome'] as String).toList();

    final novaTurma = await showMarsupiLoading(
      context,
      message: 'Salvando turma e criando perfis...',
      task: () => MockDataService.instance.addTurmaComAlunos(
        nome: widget.turmaNome,
        turno: widget.turno,
        anoLetivo: widget.anoLetivo,
        nomesAlunos: nomes,
      ),
    );

    if (!mounted || novaTurma == null) return;

    // Remove rotas anteriores até a Home e abre a nova turma
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => TurmaDetailScreen(
          turmaId: novaTurma['id'] as int,
          turmaNome: novaTurma['nome'] as String,
          turno: novaTurma['turno'] as String,
          totalAlunos: novaTurma['estudantes_count'] as int,
        ),
      ),
      (route) => route.isFirst,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✓ Turma "${widget.turmaNome}" criada com sucesso! ${nomes.length} estudantes cadastrados.'),
        backgroundColor: MarsupiColors.primary,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _alunosReconhecidos.length;
    final pendentes = _alunosReconhecidos.where((a) => a['precisaConferencia'] == true).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confira os nomes'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: MarsupiColors.mintContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'ETAPA 2 DE 3',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: MarsupiColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Text(
                '$total nomes encontrados',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: MarsupiColors.darkForest,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                pendentes > 0
                    ? '$pendentes nomes precisam da sua conferência.'
                    : 'Todos os nomes foram verificados.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: pendentes > 0 ? MarsupiColors.accentPeach : MarsupiColors.primary,
                ),
              ),
              const SizedBox(height: 16),

              // Lista de Alunos Reconhecidos
              ..._alunosReconhecidos.asMap().entries.map((entry) {
                final index = entry.key;
                final aluno = entry.value;
                final precisa = aluno['precisaConferencia'] == true;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 0,
                  color: precisa ? const Color(0xFFFFF9ED) : MarsupiColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: precisa ? MarsupiColors.accentPeach : MarsupiColors.mintBorder,
                      width: precisa ? 1.5 : 1.0,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: MarsupiColors.mintContainer,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: MarsupiColors.darkForest,
                        ),
                      ),
                    ),
                    title: Text(
                      aluno['nome'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    subtitle: Row(
                      children: [
                        Icon(
                          precisa ? Icons.edit_note : Icons.check_circle_outline,
                          size: 14,
                          color: precisa ? MarsupiColors.accentPeach : MarsupiColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          precisa ? 'Conferir escrita' : 'Reconhecido',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: precisa ? MarsupiColors.accentPeach : MarsupiColors.primary,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20, color: MarsupiColors.darkForest),
                          onPressed: () => _editarNome(index),
                          tooltip: 'Editar',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                          onPressed: () => _removerNome(index),
                          tooltip: 'Remover',
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _adicionarNomeManual,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar nome manualmente'),
              ),
              const SizedBox(height: 24),

              // Botão Confirmar Turma
              ElevatedButton.icon(
                onPressed: _alunosReconhecidos.isEmpty ? null : _concluirCadastro,
                icon: const Icon(Icons.check),
                label: Text('Confirmar $total alunos e criar turma'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
