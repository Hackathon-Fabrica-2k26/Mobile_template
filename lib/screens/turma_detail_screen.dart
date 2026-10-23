import 'package:flutter/material.dart';
import '../constants/marsupi_theme.dart';
import 'create_screen.dart';

class TurmaDetailScreen extends StatefulWidget {
  final String turmaNome;
  final String turno;
  final int totalAlunos;

  const TurmaDetailScreen({
    super.key,
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

  final List<Map<String, dynamic>> _estudantes = [
    {
      'nome': 'Alice Santos',
      'avatar': 'A',
      'status': 'Perfil pedagógico atualizado',
      'color': const Color(0xFFD2E4D9),
      'hasObservation': true,
      'radar': {'Foco': 40, 'Raciocínio': 90, 'Social': 80, 'Sensorial': 50},
    },
    {
      'nome': 'Bruno Oliveira',
      'avatar': 'B',
      'status': '2 registros recentes',
      'color': const Color(0xFFEBF2EC),
      'hasObservation': true,
      'radar': {'Foco': 70, 'Raciocínio': 65, 'Social': 60, 'Sensorial': 75},
    },
    {
      'nome': 'Clara Souza',
      'avatar': 'C',
      'status': 'Perfil pedagógico atualizado',
      'color': const Color(0xFFE7D7BB),
      'hasObservation': true,
      'radar': {'Foco': 85, 'Raciocínio': 80, 'Social': 90, 'Sensorial': 80},
    },
    {
      'nome': 'Davi Costa',
      'avatar': 'D',
      'status': '1 observação pendente',
      'color': const Color(0xFFDCE9E0),
      'hasObservation': false,
      'radar': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showStudentRadar(Map<String, dynamic> aluno) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: MarsupiColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final radar = aluno['radar'] as Map<String, int>?;
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: aluno['color'] as Color,
                    foregroundColor: MarsupiColors.darkForest,
                    child: Text(aluno['avatar'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          aluno['nome'] as String,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
                        ),
                        Text(aluno['status'] as String, style: const TextStyle(fontSize: 12, color: MarsupiColors.textMuted)),
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
              if (radar != null) ...[
                const Text(
                  'Radar de Habilidades & Desafios (IA)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
                ),
                const SizedBox(height: 12),
                ...radar.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            Text('${entry.value}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: MarsupiColors.primary)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: entry.value / 100,
                          backgroundColor: MarsupiColors.mintContainer,
                          color: entry.value < 50 ? MarsupiColors.accentPeach : MarsupiColors.primary,
                          borderRadius: BorderRadius.circular(4),
                          minHeight: 6,
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: MarsupiColors.mintContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: MarsupiColors.primary, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Dica de Autonomia: Use o raciocínio visual elevado para ancorar tarefas de foco prolongado.',
                          style: TextStyle(fontSize: 12, color: MarsupiColors.darkForest),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text('Nenhuma observação cadastrada para este aluno ainda.'),
                  ),
                ),
              ],
              const SizedBox(height: 20),
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
      body: TabBarView(
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

                // Lista de alunos
                ..._estudantes.map((aluno) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: MarsupiColors.mintBorder),
                    ),
                    child: ListTile(
                      onTap: () => _showStudentRadar(aluno),
                      leading: CircleAvatar(
                        backgroundColor: aluno['color'] as Color,
                        foregroundColor: MarsupiColors.darkForest,
                        child: Text(aluno['avatar'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      title: Text(
                        aluno['nome'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w600, color: MarsupiColors.darkForest),
                      ),
                      subtitle: Text(
                        aluno['status'] as String,
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
                    child: const Text('Ver todos os 25 estudantes', style: TextStyle(color: MarsupiColors.primary, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),

          // Aba 2: Atividades
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
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: MarsupiColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: MarsupiColors.mintBorder.withValues(alpha: 0.7)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.description_outlined, color: MarsupiColors.primary, size: 28),
                              SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Explorando as vogais', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    SizedBox(height: 2),
                                    Text('25 relatórios disponíveis', style: TextStyle(fontSize: 12, color: MarsupiColors.textMuted)),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right, color: MarsupiColors.primary),
                            ],
                          ),
                        ),
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
            child: Text('Histórico de registros pedagógicos da turma.'),
          ),
        ],
      ),
    );
  }
}
