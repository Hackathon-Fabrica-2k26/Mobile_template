import 'package:flutter/material.dart';
import '../constants/marsupi_theme.dart';
import '../services/mock_data_service.dart';
import 'create_screen.dart';

class TurmaDetailScreen extends StatefulWidget {
  final int turmaId;
  final String turmaNome;
  final String turno;
  final int totalAlunos;

  const TurmaDetailScreen({
    super.key,
    this.turmaId = 1,
    required this.turmaNome,
    required this.turno,
    required this.totalAlunos,
  });

  @override
  State<TurmaDetailScreen> createState() => _TurmaDetailScreenState();
}

class _TurmaDetailScreenState extends State<TurmaDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _estudantes = [];
  List<Map<String, dynamic>> _atividades = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final alunos = await MockDataService.instance.getAlunos(turmaId: widget.turmaId);
    final atividades = await MockDataService.instance.getAtividades(turmaId: widget.turmaId);
    if (mounted) {
      setState(() {
        _estudantes = alunos;
        _atividades = atividades;
        _isLoading = false;
      });
    }
  }

  Color _getStudentColor(int index) {
    const colors = [
      Color(0xFFD2E4D9),
      Color(0xFFEBF2EC),
      Color(0xFFE7D7BB),
      Color(0xFFDCE9E0),
    ];
    return colors[index % colors.length];
  }

  void _showStudentRadar(Map<String, dynamic> aluno, Color color) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: MarsupiColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final radar = aluno['radar_metrics'] as Map<String, dynamic>?;
        final strengths = (aluno['strengths'] as List<dynamic>?)?.cast<String>() ?? [];
        final supportNeeds = (aluno['support_needs'] as List<dynamic>?)?.cast<String>() ?? [];
        final dica = aluno['dica_autonomia'] as String?;
        final nome = (aluno['nome'] as String?) ?? 'Estudante';
        final avatar = (aluno['avatar'] as String?) ?? (nome.isNotEmpty ? nome[0] : 'E');
        final status = (aluno['status'] as String?) ?? 'Perfil pedagógico';

        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: color,
                        foregroundColor: MarsupiColors.darkForest,
                        child: Text(avatar, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nome,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
                            ),
                            Text(status, style: const TextStyle(fontSize: 12, color: MarsupiColors.textMuted)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(ctx).pop(),
                      )
                    ],
                  ),
                  const Divider(height: 28),
                  if (radar != null && radar.isNotEmpty) ...[
                    const Text(
                      'Radar de Habilidades & Desafios (IA)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
                    ),
                    const SizedBox(height: 12),
                    ...radar.entries.map((entry) {
                      final val = (entry.value as num).toInt();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(entry.key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                Text('$val%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: MarsupiColors.primary)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: val / 100,
                              backgroundColor: MarsupiColors.mintContainer,
                              color: val < 50 ? MarsupiColors.accentPeach : MarsupiColors.primary,
                              borderRadius: BorderRadius.circular(4),
                              minHeight: 6,
                            ),
                          ],
                        ),
                      );
                    }),
                    if (strengths.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      const Text(
                        'Pontos Fortes Mapeados',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
                      ),
                      const SizedBox(height: 6),
                      ...strengths.map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_outline, color: MarsupiColors.primary, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(s, style: const TextStyle(fontSize: 12, color: MarsupiColors.darkForest))),
                          ],
                        ),
                      )),
                    ],
                    if (supportNeeds.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      const Text(
                        'Necessidades de Apoio Pedagógico',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
                      ),
                      const SizedBox(height: 6),
                      ...supportNeeds.map((need) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.spa_outlined, color: MarsupiColors.accentPeach, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(need, style: const TextStyle(fontSize: 12, color: MarsupiColors.darkForest))),
                          ],
                        ),
                      )),
                    ],
                    if (dica != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: MarsupiColors.mintContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.lightbulb_outline, color: MarsupiColors.primary, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                dica,
                                style: const TextStyle(fontSize: 12, color: MarsupiColors.darkForest),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: MarsupiColors.mintContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.insights_outlined, color: MarsupiColors.primary, size: 40),
                          SizedBox(height: 12),
                          Text(
                            'Radar em construção',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: MarsupiColors.darkForest),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Ainda não há observações suficientes registradas para consolidar as métricas de habilidades e desafios deste estudante.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: MarsupiColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CreateItemScreen()),
                      );
                    },
                    icon: const Icon(Icons.edit_note, size: 20),
                    label: const Text('Nova Observação Pedagógica'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.turmaNome),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: MarsupiColors.background,
            child: TabBar(
              controller: _tabController,
              indicatorColor: MarsupiColors.accentPeach,
              indicatorWeight: 3,
              labelColor: MarsupiColors.darkForest,
              unselectedLabelColor: MarsupiColors.textMuted,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: const [
                Tab(text: 'Estudantes'),
                Tab(text: 'Atividades'),
                Tab(text: 'Registros'),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: MarsupiColors.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                // Aba 1: Estudantes
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Banner Hero (como no Figma)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: MarsupiColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Ensino fundamental',
                                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    widget.turmaNome,
                                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${widget.turno} · ${widget.totalAlunos} estudantes',
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Cada descoberta começa aqui.',
                                    style: TextStyle(color: Colors.white70, fontSize: 11, fontStyle: FontStyle.italic),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: MarsupiColors.accentPeach.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Column(
                                children: [
                                  Text('01', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                                  Text('Aprender\njuntos', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Seção Estudantes da turma
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Estudantes da turma',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Acompanhe os perfis e registros da turma.',
                                style: TextStyle(fontSize: 12, color: MarsupiColors.textMuted),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.person_add_alt_1, color: MarsupiColors.primary),
                            onPressed: () {},
                            tooltip: 'Adicionar estudante',
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Lista dinâmica de alunos carregada do Mock JSON
                      ..._estudantes.asMap().entries.map((entry) {
                        final index = entry.key;
                        final aluno = entry.value;
                        final nome = (aluno['nome'] as String?) ?? 'Estudante';
                        final avatar = (aluno['avatar'] as String?) ?? (nome.isNotEmpty ? nome[0] : 'E');
                        final status = (aluno['status'] as String?) ?? 'Perfil pedagógico';
                        final color = _getStudentColor(index);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: MarsupiColors.mintBorder),
                          ),
                          child: ListTile(
                            onTap: () => _showStudentRadar(aluno, color),
                            leading: CircleAvatar(
                              backgroundColor: color,
                              foregroundColor: MarsupiColors.darkForest,
                              child: Text(avatar, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            title: Text(
                              nome,
                              style: const TextStyle(fontWeight: FontWeight.w600, color: MarsupiColors.darkForest),
                            ),
                            subtitle: Text(
                              status,
                              style: const TextStyle(fontSize: 12, color: MarsupiColors.textMuted),
                            ),
                            trailing: const Icon(Icons.chevron_right, color: MarsupiColors.primary),
                          ),
                        );
                      }),

                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Ver todos os ${widget.totalAlunos} estudantes',
                            style: const TextStyle(color: MarsupiColors.primary, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Aba 2: Atividades dinâmicas da turma
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: MarsupiColors.mintBorder),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Atividades da turma',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Acompanhe os envios e os relatórios individuais dos seus alunos.',
                                style: TextStyle(fontSize: 12, color: MarsupiColors.textMuted),
                              ),
                              const SizedBox(height: 16),
                              if (_atividades.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: Text(
                                      'Nenhuma atividade registrada ainda nesta turma.',
                                      style: TextStyle(color: MarsupiColors.textMuted),
                                    ),
                                  ),
                                )
                              else
                                ..._atividades.map((ativ) {
                                  final nome = ativ['nome'] as String? ?? 'Atividade';
                                  final tipo = ativ['tipo'] as String? ?? '';
                                  final total = ativ['relatorios_count'] ?? widget.totalAlunos;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: MarsupiColors.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: MarsupiColors.mintBorder.withValues(alpha: 0.7)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.description_outlined, color: MarsupiColors.primary, size: 28),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                              const SizedBox(height: 2),
                                              Text(
                                                '$total relatórios disponíveis · $tipo',
                                                style: const TextStyle(fontSize: 12, color: MarsupiColors.textMuted),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.chevron_right, color: MarsupiColors.primary),
                                      ],
                                    ),
                                  );
                                }),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Enviar Atividades (Upload)'),
                      ),
                    ],
                  ),
                ),

                // Aba 3: Registros
                const Center(
                  child: Text(
                    'Histórico de registros pedagógicos da turma.',
                    style: TextStyle(color: MarsupiColors.textMuted),
                  ),
                ),
              ],
            ),
    );
  }
}
