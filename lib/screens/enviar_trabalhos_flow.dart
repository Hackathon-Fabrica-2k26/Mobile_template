import 'package:flutter/material.dart';
import '../constants/marsupi_theme.dart';
import '../services/mock_data_service.dart';
import 'loading_screen.dart';

class EnviarTrabalhosFlowScreen extends StatefulWidget {
  final int atividadeId;
  final String atividadeNome;

  const EnviarTrabalhosFlowScreen({
    super.key,
    required this.atividadeId,
    required this.atividadeNome,
  });

  @override
  State<EnviarTrabalhosFlowScreen> createState() => _EnviarTrabalhosFlowScreenState();
}

class _EnviarTrabalhosFlowScreenState extends State<EnviarTrabalhosFlowScreen> {
  List<Map<String, dynamic>> _trabalhosCapturados = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarTrabalhos();
  }

  Future<void> _carregarTrabalhos() async {
    final list = await MockDataService.instance.getTrabalhosTemplate();
    if (!mounted) return;
    setState(() {
      _trabalhosCapturados = list;
      _isLoading = false;
    });
  }

  void _confirmarAluno(int index) {
    setState(() {
      _trabalhosCapturados[index]['duvida'] = false;
      _trabalhosCapturados[index]['status'] = 'Confirmado pela professora';
    });
  }

  void _trocarAluno(int index) {
    final controller = TextEditingController(text: _trabalhosCapturados[index]['alunoReconhecido'] as String);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Identificar estudante'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nome do aluno desta folha'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _trabalhosCapturados[index]['alunoReconhecido'] = controller.text.trim();
                _trabalhosCapturados[index]['duvida'] = false;
                _trabalhosCapturados[index]['status'] = 'Ajustado pela professora';
              });
              Navigator.of(ctx).pop();
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _processarComIA() async {
    await showMarsupiLoading(
      context,
      message: 'IA analisando esforço cognitivo, escrita e raciocínio...',
      task: () => MockDataService.instance.processarTrabalhosPorFoto(
        atividadeId: widget.atividadeId,
        trabalhosConfirmados: _trabalhosCapturados,
      ),
    );

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => DetalheResultadoAtividadeScreen(
          atividadeNome: widget.atividadeNome,
          totalTrabalhos: _trabalhosCapturados.length,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Enviar trabalhos da aula'),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: MarsupiColors.primary),
        ),
      );
    }

    final temDuvida = _trabalhosCapturados.any((t) => t['duvida'] == true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enviar trabalhos da aula'),
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
                child: Text(
                  'ATIVIDADE: ${widget.atividadeNome.toUpperCase()}',
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
                'Revisar identificação das fotos',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: MarsupiColors.darkForest,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'A IA leu o cabeçalho manuscrito em cada foto. Confira os nomes destacados antes de processar.',
                style: TextStyle(fontSize: 13, color: MarsupiColors.textMuted),
              ),
              const SizedBox(height: 20),

              ..._trabalhosCapturados.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final duvida = item['duvida'] == true;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  color: duvida ? const Color(0xFFFFF8EE) : MarsupiColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: duvida ? MarsupiColors.accentPeach : MarsupiColors.mintBorder,
                      width: duvida ? 1.5 : 1.0,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 56,
                          decoration: BoxDecoration(
                            color: MarsupiColors.mintContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.photo_outlined, color: MarsupiColors.primary),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['alunoReconhecido'] as String,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: MarsupiColors.darkForest),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item['status'] as String,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: duvida ? MarsupiColors.accentPeach : MarsupiColors.textMuted,
                                  fontWeight: duvida ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (duvida) ...[
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: MarsupiColors.primary),
                            onPressed: () => _confirmarAluno(index),
                            tooltip: 'Confirmar',
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: MarsupiColors.darkForest),
                            onPressed: () => _trocarAluno(index),
                            tooltip: 'Alterar',
                          ),
                        ] else ...[
                          const Icon(Icons.check, color: MarsupiColors.primary),
                        ],
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _processarComIA,
                icon: const Icon(Icons.auto_awesome),
                label: Text(temDuvida ? 'Confirmar e processar com IA' : 'Processar relatórios com IA'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ETAPA: Detalhe da Atividade & Pontos de Atenção Pedagógica (Figma 259:115-119)
class DetalheResultadoAtividadeScreen extends StatelessWidget {
  final String atividadeNome;
  final int totalTrabalhos;

  const DetalheResultadoAtividadeScreen({
    super.key,
    required this.atividadeNome,
    required this.totalTrabalhos,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatório da atividade'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: MarsupiColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Processamento Concluído',
                      style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      atividadeNome,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$totalTrabalhos trabalhos avaliados pela IA inclusiva',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Pontos de Atenção (Figma 259:118)
              const Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: MarsupiColors.accentPeach, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Pontos de Atenção Mapeados',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Observações pedagógicas para orientar o professor no próximo planejamento:',
                style: TextStyle(fontSize: 12, color: MarsupiColors.textMuted),
              ),
              const SizedBox(height: 14),

              _buildCardAtencao(
                nome: 'Davi Pereira',
                avatar: 'D',
                titulo: 'Sinal de fadiga motora na escrita',
                descricao: 'Demonstrou esforço acentuado na preensão do lápis no terço final da folha. Recomenda-se engrossador de lápis e pausas ativas.',
                tipo: 'Apoio Motor',
              ),
              _buildCardAtencao(
                nome: 'Alice Santos',
                avatar: 'A',
                titulo: 'Excelente absorção por pistas visuais',
                descricao: 'Completou a versão adaptada em 12 minutos com 100% de acerto nas associações fonema-imagem.',
                tipo: 'Ponto Forte',
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Voltar para a turma'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardAtencao({
    required String nome,
    required String avatar,
    required String titulo,
    required String descricao,
    required String tipo,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: MarsupiColors.mintBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: MarsupiColors.mintContainer,
                  foregroundColor: MarsupiColors.darkForest,
                  child: Text(avatar, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                ),
                const SizedBox(width: 8),
                Text(nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: MarsupiColors.mintContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tipo,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: MarsupiColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: MarsupiColors.darkForest)),
            const SizedBox(height: 4),
            Text(descricao, style: const TextStyle(fontSize: 12, color: MarsupiColors.textMuted, height: 1.4)),
          ],
        ),
      ),
    );
  }
}
