import 'package:flutter/material.dart';
import '../constants/marsupi_theme.dart';
import 'create_screen.dart';
import 'turma_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _turmas = [
    {
      'nome': '1º ano A',
      'turno': 'Manhã',
      'estudantes': 25,
      'icon': Icons.edit_outlined,
      'color': const Color(0xFFEBF2EC),
    },
    {
      'nome': '2º ano B',
      'turno': 'Tarde',
      'estudantes': 28,
      'icon': Icons.menu_book_outlined,
      'color': const Color(0xFFF7F2E7),
    },
    {
      'nome': '3º ano A',
      'turno': 'Manhã',
      'estudantes': 26,
      'icon': Icons.chair_alt_outlined,
      'color': const Color(0xFFDCE9E0),
    },
  ];

  @override
  Widget build(BuildContext context) {
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
              child: const Text(
                'AP',
                style: TextStyle(
                  color: MarsupiColors.darkForest,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Saudação
            const Text(
              'Bem-vinda, Ana!',
              style: TextStyle(
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
            ..._turmas.map((turma) {
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
                            turma['nome'] as String,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: MarsupiColors.darkForest,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: turma['color'] as Color,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              turma['icon'] as IconData,
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
                                turma['turno'] as String,
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
                                '${turma['estudantes']}',
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
                                    turmaNome: turma['nome'] as String,
                                    turno: turma['turno'] as String,
                                    totalAlunos: turma['estudantes'] as int,
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
