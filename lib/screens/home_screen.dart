import 'package:flutter/material.dart';
import '../constants/marsupi_theme.dart';
import '../services/mock_data_service.dart';
import 'create_screen.dart';
import 'turma_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> _user = {};
  List<Map<String, dynamic>> _turmas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await MockDataService.instance.getUser();
    final turmas = await MockDataService.instance.getTurmas();
    if (mounted) {
      setState(() {
        _user = user;
        _turmas = turmas;
        _isLoading = false;
      });
    }
  }

  IconData _getTurmaIcon(String? icon) {
    switch (icon) {
      case 'pencil':
        return Icons.edit_outlined;
      case 'book':
        return Icons.menu_book_outlined;
      case 'desk':
        return Icons.chair_alt_outlined;
      default:
        return Icons.school_outlined;
    }
  }

  Color _getTurmaColor(int index) {
    const colors = [
      Color(0xFFEBF2EC),
      Color(0xFFF7F2E7),
      Color(0xFFDCE9E0),
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final userName = (_user['nome'] as String?) ?? 'Professora';
    final userAvatar = (_user['avatar'] as String?) ?? 'AP';

    return Scaffold(
      backgroundColor: MarsupiColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo_marsupi.png',
              height: 32,
              fit: BoxFit.contain,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: MarsupiColors.darkForest),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: MarsupiColors.sage,
              child: Text(
                userAvatar,
                style: const TextStyle(
                  color: MarsupiColors.darkForest,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: MarsupiColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Saudação
                  Text(
                    'Bem-vinda, $userName!',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: MarsupiColors.darkForest,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Seu copiloto pedagógico para ensino inclusivo.',
                    style: TextStyle(fontSize: 13, color: MarsupiColors.textMuted),
                  ),
                  const SizedBox(height: 24),

                  // Cabeçalho da seção Minhas turmas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Minhas turmas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: MarsupiColors.darkForest,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Nova turma', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: MarsupiColors.darkForest,
                          side: const BorderSide(color: MarsupiColors.mintBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Cards de Turmas (Figma Design)
                  ..._turmas.asMap().entries.map((entry) {
                    final index = entry.key;
                    final turma = entry.value;
                    final totalAlunos = (turma['estudantes_count'] ?? turma['estudantes'] ?? 25) as int;
                    final nome = (turma['nome'] as String?) ?? 'Turma';
                    final turno = (turma['turno'] as String?) ?? 'Manhã';
                    final icon = _getTurmaIcon(turma['icon'] as String?);
                    final color = _getTurmaColor(index);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 0,
                      color: MarsupiColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: MarsupiColors.mintBorder),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  nome,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: MarsupiColors.darkForest,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    icon,
                                    color: MarsupiColors.darkForest,
                                    size: 22,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 1, color: MarsupiColors.mintBorder),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Turno', style: TextStyle(fontSize: 11, color: MarsupiColors.textMuted)),
                                    const SizedBox(height: 2),
                                    Text(
                                      turno,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 32),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Estudantes', style: TextStyle(fontSize: 11, color: MarsupiColors.textMuted)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '$totalAlunos',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                FilledButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => TurmaDetailScreen(
                                          turmaId: (turma['id'] as int?) ?? 1,
                                          turmaNome: nome,
                                          turno: turno,
                                          totalAlunos: totalAlunos,
                                        ),
                                      ),
                                    );
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: MarsupiColors.mintContainer,
                                    foregroundColor: MarsupiColors.darkForest,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  ),
                                  child: const Text('Acessar turma →', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateItemScreen()),
          );
        },
        backgroundColor: MarsupiColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.psychology_outlined),
        label: const Text('Nova Observação'),
      ),
    );
  }
}
