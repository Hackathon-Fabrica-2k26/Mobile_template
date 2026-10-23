import 'package:flutter/material.dart';
import '../constants/marsupi_theme.dart';
import '../services/mock_data_service.dart';
import 'loading_screen.dart';

class CriarAtividadeFlowScreen extends StatefulWidget {
  final int turmaId;
  final String turmaNome;

  const CriarAtividadeFlowScreen({
    super.key,
    required this.turmaId,
    required this.turmaNome,
  });

  @override
  State<CriarAtividadeFlowScreen> createState() => _CriarAtividadeFlowScreenState();
}

class _CriarAtividadeFlowScreenState extends State<CriarAtividadeFlowScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _enunciadoController = TextEditingController();
  String _tipo = 'Linguagem / Alfabetização';
  bool _anexoAdicionado = false;
  final String _nomeAnexo = 'exercicio_letras.docx';

  // Alunos que precisam de adaptação identificados pela IA
  List<Map<String, dynamic>> _alunosParaAdaptar = [];
  final Map<int, bool> _selecionados = {};
  bool _analisouAlunos = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _enunciadoController.dispose();
    super.dispose();
  }

  Future<void> _analisarQuemPrecisaAdaptar() async {
    if (!_formKey.currentState!.validate()) return;

    final alunos = await showMarsupiLoading(
      context,
      message: 'Consultando perfis de apoio da turma...',
      task: () async {
        await Future.delayed(const Duration(milliseconds: 500));
        return await MockDataService.instance.getAlunos(turmaId: widget.turmaId);
      },
    );

    if (!mounted || alunos == null) return;

    setState(() {
      // Filtra alunos com necessidades especiais ou sugestões de apoio
      _alunosParaAdaptar = alunos.where((a) {
        final needs = a['support_needs'] as List<dynamic>? ?? [];
        return needs.isNotEmpty;
      }).toList();

      for (var a in _alunosParaAdaptar) {
        _selecionados[a['id'] as int] = true;
      }
      _analisouAlunos = true;
    });
  }

  void _gerarVariacoesComIA() async {
    final alunosSelecionados = _alunosParaAdaptar
        .where((a) => _selecionados[a['id'] as int] == true)
        .toList();

    await showMarsupiLoading(
      context,
      message: 'IA gerando versão geral e variações inclusivas...',
      task: () async => await Future.delayed(const Duration(milliseconds: 700)),
    );

    if (!mounted) return;

    // Navega para a tela de revisão e aprovação das variações
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RevisarAprovarAtividadeScreen(
          turmaId: widget.turmaId,
          titulo: _tituloController.text.trim(),
          tipo: _tipo,
          enunciadoGeral: _enunciadoController.text.trim(),
          alunosAdaptados: alunosSelecionados,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar atividade'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: MarsupiColors.mintContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'TURMA: ${widget.turmaNome.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: MarsupiColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                const Text(
                  'Crie a atividade para a turma',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: MarsupiColors.darkForest,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'A Marsupi analisa a turma e sugere versões adaptadas automaticamente.',
                  style: TextStyle(fontSize: 13, color: MarsupiColors.textMuted),
                ),
                const SizedBox(height: 24),

                // Título da Atividade
                const Text(
                  'Título da atividade *',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _tituloController,
                  decoration: const InputDecoration(hintText: 'Ex: Explorando as vogais'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o título da atividade' : null,
                ),
                const SizedBox(height: 16),

                // Campo / Disciplina
                const Text(
                  'Campo de aprendizagem / Disciplina',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _tipo,
                  decoration: const InputDecoration(),
                  items: const [
                    DropdownMenuItem(value: 'Linguagem / Alfabetização', child: Text('Linguagem / Alfabetização')),
                    DropdownMenuItem(value: 'Coordenação Motora', child: Text('Coordenação Motora')),
                    DropdownMenuItem(value: 'Raciocínio Lógico & Números', child: Text('Raciocínio Lógico & Números')),
                    DropdownMenuItem(value: 'Expressão Artística', child: Text('Expressão Artística')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _tipo = val);
                  },
                ),
                const SizedBox(height: 16),

                // Enunciado / Conteúdo
                const Text(
                  'Enunciado ou instruções da atividade *',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _enunciadoController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Descreva a tarefa ou cole o texto aqui...',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o enunciado' : null,
                ),
                const SizedBox(height: 16),

                // Anexo opcional (Texto, PDF ou DOCX)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: MarsupiColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: MarsupiColors.mintBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_file, color: MarsupiColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _anexoAdicionado ? _nomeAnexo : 'Anexar PDF ou DOCX da atividade (opcional)',
                          style: TextStyle(
                            fontSize: 13,
                            color: _anexoAdicionado ? MarsupiColors.darkForest : MarsupiColors.textMuted,
                            fontWeight: _anexoAdicionado ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _anexoAdicionado = !_anexoAdicionado;
                          });
                        },
                        child: Text(_anexoAdicionado ? 'Remover' : 'Anexar'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (!_analisouAlunos) ...[
                  ElevatedButton.icon(
                    onPressed: _analisarQuemPrecisaAdaptar,
                    icon: const Icon(Icons.psychology_outlined),
                    label: const Text('Analisar quem precisa de adaptação'),
                  ),
                ] else ...[
                  // Seção: Ver quem precisa adaptar (como no mapa do Figma)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: MarsupiColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: MarsupiColors.accentPeach, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome, color: MarsupiColors.accentPeach, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '${_alunosParaAdaptar.length} alunos com apoio mapeado',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: MarsupiColors.darkForest),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'A IA identificou particularidades sensoriais ou de foco para os seguintes estudantes:',
                          style: TextStyle(fontSize: 12, color: MarsupiColors.textMuted),
                        ),
                        const SizedBox(height: 12),
                        ..._alunosParaAdaptar.map((aluno) {
                          final id = aluno['id'] as int;
                          final nome = aluno['nome'] as String;
                          final needs = (aluno['support_needs'] as List<dynamic>? ?? []).join('; ');

                          return CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            subtitle: Text(
                              needs.isNotEmpty ? needs : 'Adaptação visual e motora sugerida.',
                              style: const TextStyle(fontSize: 12, color: MarsupiColors.textMuted),
                            ),
                            value: _selecionados[id] ?? false,
                            activeColor: MarsupiColors.primary,
                            onChanged: (val) {
                              setState(() {
                                _selecionados[id] = val ?? false;
                              });
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _gerarVariacoesComIA,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Gerar versões adaptadas com IA'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ETAPA 3 e 4: Revisar, Aprovar, Baixar e Imprimir
class RevisarAprovarAtividadeScreen extends StatefulWidget {
  final int turmaId;
  final String titulo;
  final String tipo;
  final String enunciadoGeral;
  final List<Map<String, dynamic>> alunosAdaptados;

  const RevisarAprovarAtividadeScreen({
    super.key,
    required this.turmaId,
    required this.titulo,
    required this.tipo,
    required this.enunciadoGeral,
    required this.alunosAdaptados,
  });

  @override
  State<RevisarAprovarAtividadeScreen> createState() => _RevisarAprovarAtividadeScreenState();
}

class _RevisarAprovarAtividadeScreenState extends State<RevisarAprovarAtividadeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, String> _versoesAdaptadas = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1 + widget.alunosAdaptados.length, vsync: this);

    // Gera texto simulado de adaptação pedagógica com base nas necessidades mapeadas
    for (var aluno in widget.alunosAdaptados) {
      final nome = aluno['nome'] as String;
      _versoesAdaptadas[nome] =
          '• Versão Adaptada para $nome:\n- Formatação com tipografia ampliada e espaçamento duplo.\n- Adição de âncoras visuais (ícones coloridos) ao lado de cada palavra.\n- Tarefa dividida em 3 pequenos blocos de 5 minutos, com reforço positivo ao final de cada bloco.';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _aprovarESalvar() async {
    await showMarsupiLoading(
      context,
      message: 'Salvando atividade e gerando PDFs...',
      task: () => MockDataService.instance.addAtividadeComAdaptacoes(
        turmaId: widget.turmaId,
        nome: widget.titulo,
        tipo: widget.tipo,
        descricao: widget.enunciadoGeral,
        adaptacoesPorAluno: _versoesAdaptadas,
      ),
    );

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: MarsupiColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.check_circle_outline, color: MarsupiColors.primary, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Atividade Aprovada!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
            ),
            const SizedBox(height: 6),
            const Text(
              'A versão geral da turma e as versões adaptadas estão prontas para impressão.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: MarsupiColors.textMuted),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('📥 Download iniciado: geral.pdf'),
                    backgroundColor: MarsupiColors.primary,
                  ),
                );
              },
              icon: const Icon(Icons.download),
              label: const Text('Baixar versão geral (.pdf)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('📥 Download iniciado: ${widget.alunosAdaptados.length} atividades adaptadas (.pdf)'),
                    backgroundColor: MarsupiColors.primary,
                  ),
                );
                Navigator.of(context).pop(); // Volta para a tela da turma
              },
              icon: const Icon(Icons.print),
              label: const Text('Baixar e imprimir adaptadas (.pdf)'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revisar e aprovar'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: MarsupiColors.accentPeach,
          labelColor: MarsupiColors.darkForest,
          unselectedLabelColor: MarsupiColors.textMuted,
          tabs: [
            const Tab(text: 'Geral (Turma)'),
            ...widget.alunosAdaptados.map((a) => Tab(text: 'Adaptada: ${a['nome']}')),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Aba Versão Geral
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(widget.tipo, style: const TextStyle(fontSize: 12, color: MarsupiColors.textMuted)),
                        const Divider(height: 24),
                        const Text(
                          'Instruções gerais para a turma:',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: MarsupiColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: MarsupiColors.mintBorder),
                            ),
                            child: SingleChildScrollView(
                              child: Text(
                                widget.enunciadoGeral,
                                style: const TextStyle(fontSize: 14, height: 1.5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Abas das Versões Adaptadas por Aluno
                  ...widget.alunosAdaptados.map((aluno) {
                    final nome = aluno['nome'] as String;
                    final adaptacao = _versoesAdaptadas[nome] ?? '';

                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome, color: MarsupiColors.accentPeach, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Adaptação Curricular para $nome',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Gerada pela IA com base nas necessidades sensoriais e cognitivas do estudante.',
                            style: TextStyle(fontSize: 12, color: MarsupiColors.textMuted),
                          ),
                          const Divider(height: 20),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FBF9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: MarsupiColors.primary.withValues(alpha: 0.4)),
                              ),
                              child: SingleChildScrollView(
                                child: Text(
                                  adaptacao,
                                  style: const TextStyle(fontSize: 14, height: 1.6, color: MarsupiColors.darkForest),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton.icon(
                onPressed: _aprovarESalvar,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Aprovar e gerar PDFs'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
