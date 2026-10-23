import 'package:flutter/material.dart';
import '../constants/marsupi_theme.dart';
import '../services/mock_data_service.dart';
import 'aluno_detalhes_screen.dart';
import 'cadastrar_aluno_screen.dart';
import 'criar_atividade_flow.dart';
import 'enviar_atividades_screen.dart';
import 'enviar_trabalhos_flow.dart';
import 'turma_cadastro_flow.dart';

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

  @override
  Widget build(BuildContext context) {
    final estudantesCount = _estudantes.length;

    return Scaffold(
      backgroundColor: MarsupiColors.background,
      appBar: AppBar(
        backgroundColor: MarsupiColors.background,
        elevation: 0,
        title: const Text(
          'Marsupi',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: MarsupiColors.primary,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: MarsupiColors.darkForest, size: 26),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0, left: 4.0),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: Color(0xFFD2E4D9),
              child: Text(
                'AP',
                style: TextStyle(
                  color: MarsupiColors.darkForest,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Breadcrumb (Figma: Minhas turmas / 1º ano A)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Minhas turmas',
                        style: TextStyle(fontSize: 12, color: MarsupiColors.textMuted),
                      ),
                    ),
                    const Text(' / ', style: TextStyle(fontSize: 12, color: MarsupiColors.textMuted)),
                    Text(
                      widget.turmaNome,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
                    ),
                  ],
                ),
              ),
              TabBar(
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
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: MarsupiColors.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                // ABA 1: Estudantes
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Banner Hero (Figma: Ensino fundamental, turma, turno e decorative circle)
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
                                    '${widget.turno} · $estudantesCount estudantes',
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
                      const SizedBox(height: 20),

                      // Botão "Adicionar foto" (Figma: Botão largo de câmera para fotos de chamada)
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const NovaTurmaFotoScreen()),
                          );
                          _loadData();
                        },
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('Adicionar foto da chamada'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Cabeçalho da Lista de Estudantes
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
                            icon: const Icon(Icons.person_add_alt_1_outlined, color: MarsupiColors.primary),
                            onPressed: () async {
                              final created = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CadastrarAlunoScreen(
                                    turmaId: widget.turmaId,
                                    turmaNome: widget.turmaNome,
                                    turno: widget.turno,
                                  ),
                                ),
                              );
                              if (created == true) _loadData();
                            },
                            tooltip: 'Cadastrar aluno',
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Se a turma estiver sem alunos (Figma: mobile_turma_sem_alunos.png)
                      if (_estudantes.isEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                          decoration: BoxDecoration(
                            color: MarsupiColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: MarsupiColors.mintBorder),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: MarsupiColors.mintContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.image_outlined, color: MarsupiColors.primary, size: 30),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Nenhum aluno cadastrado',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Adicione uma foto da chamada para cadastrar os alunos.\nOs estudantes aparecerão aqui.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12, color: MarsupiColors.textMuted, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // Lista de estudantes (Figma: cards com avatar, nome, status e chevron)
                        ..._estudantes.asMap().entries.map((entry) {
                          final index = entry.key;
                          final aluno = entry.value;
                          final nome = (aluno['nome'] as String?) ?? 'Estudante';
                          final avatar = (aluno['avatar'] as String?) ?? (nome.isNotEmpty ? nome[0] : 'E');
                          final status = (aluno['status'] as String?) ?? 'Perfil pedagógico atualizado';
                          final color = _getStudentColor(index);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: MarsupiColors.mintBorder),
                            ),
                            child: ListTile(
                              onTap: () {
                                // Abre a tela dedicada de Detalhes do Aluno (Figma mobile_detalhes_do_aluno.png)
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => AlunoDetalhesScreen(
                                      aluno: aluno,
                                      turmaNome: widget.turmaNome,
                                      turno: widget.turno,
                                    ),
                                  ),
                                );
                              },
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
                      ],
                    ],
                  ),
                ),

                // ABA 2: Atividades
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Atividades da turma',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => CriarAtividadeFlowScreen(
                                            turmaId: widget.turmaId,
                                            turmaNome: widget.turmaNome,
                                          ),
                                        ),
                                      );
                                      _loadData();
                                    },
                                    child: const Text(
                                      '+ Enviar nova atividade',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: MarsupiColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Acompanhe os relatórios individuais dos seus alunos.',
                                style: TextStyle(fontSize: 12, color: MarsupiColors.textMuted),
                              ),
                              const SizedBox(height: 16),
                              if (_atividades.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Center(
                                    child: Text(
                                      'Nenhuma atividade registrada ainda nesta turma.',
                                      style: TextStyle(color: MarsupiColors.textMuted),
                                    ),
                                  ),
                                )
                              else
                                ..._atividades.map((ativ) {
                                  final id = ativ['id'] as int? ?? 1;
                                  final nome = ativ['nome'] as String? ?? 'Atividade';

                                  return InkWell(
                                    onTap: () async {
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => EnviarTrabalhosFlowScreen(
                                            atividadeId: id,
                                            atividadeNome: nome,
                                          ),
                                        ),
                                      );
                                      _loadData();
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: MarsupiColors.surface,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: MarsupiColors.mintBorder.withValues(alpha: 0.7)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.article_outlined, color: MarsupiColors.primary, size: 28),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                                const SizedBox(height: 2),
                                                const Text(
                                                  'Relatórios da atividade · Abrir atividade',
                                                  style: TextStyle(fontSize: 12, color: MarsupiColors.textMuted),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(Icons.chevron_right, color: MarsupiColors.primary),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EnviarAtividadesScreen(
                                turmaId: widget.turmaId,
                                turmaNome: widget.turmaNome,
                              ),
                            ),
                          );
                          _loadData();
                        },
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Enviar Atividades (Upload)'),
                      ),
                    ],
                  ),
                ),

                // ABA 3: Registros
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
