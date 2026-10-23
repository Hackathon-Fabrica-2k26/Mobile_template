import 'package:flutter/material.dart';
import '../constants/marsupi_theme.dart';
import '../services/mock_data_service.dart';
import 'portal_responsavel_screen.dart';
import 'turma_cadastro_flow.dart';
import 'turma_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  Map<String, dynamic> _user = {};
  List<Map<String, dynamic>> _turmas = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  List<Map<String, dynamic>> get _filteredTurmas {
    if (_searchQuery.trim().isEmpty) return _turmas;
    return _turmas.where((t) {
      final nome = (t['nome'] as String? ?? '').toLowerCase();
      final turno = (t['turno'] as String? ?? '').toLowerCase();
      return nome.contains(_searchQuery.toLowerCase()) || turno.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final userName = (_user['nome'] as String?) ?? 'Ana';
    final userAvatar = (_user['avatar'] as String?) ?? 'AP';

    return Scaffold(
      backgroundColor: MarsupiColors.background,
      appBar: AppBar(
        backgroundColor: MarsupiColors.background,
        elevation: 0,
        title: const Text(
          'Marsupi',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: MarsupiColors.primary,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu, color: MarsupiColors.darkForest, size: 26),
              tooltip: 'Menu',
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 4.0),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: const Color(0xFFD2E4D9),
              child: Text(
                userAvatar,
                style: const TextStyle(
                  color: MarsupiColors.darkForest,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: MarsupiColors.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: MarsupiColors.mintContainer,
                    child: Text(
                      userAvatar,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: MarsupiColors.darkForest,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userName,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'CEI Araquari · Ensino Inclusivo',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.family_restroom, color: MarsupiColors.primary),
              title: const Text('Portal da Família / Responsável'),
              subtitle: const Text('Acesso com código do aluno e laudos'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PortalResponsavelScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline, color: MarsupiColors.primary),
              title: const Text('Nova Turma (Foto da chamada)'),
              onTap: () async {
                Navigator.of(context).pop();
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NovaTurmaFotoScreen()),
                );
                _loadData();
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined, color: MarsupiColors.primary),
              title: const Text('Privacidade & Termos LGPD'),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: MarsupiColors.primary))
          : IndexedStack(
              index: _currentNavIndex,
              children: [
                _buildInicioView(userName),
                _buildTurmasView(),
                _buildPerfilView(userName),
              ],
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: MarsupiColors.mintBorder.withValues(alpha: 0.6))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentNavIndex,
          onTap: (index) => setState(() => _currentNavIndex = index),
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: MarsupiColors.primary,
          unselectedItemColor: MarsupiColors.textMuted,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article_outlined),
              activeIcon: Icon(Icons.article),
              label: 'Turmas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInicioView(String userName) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Campo de Busca (Figma: rounded search bar)
          Container(
            decoration: BoxDecoration(
              color: MarsupiColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: MarsupiColors.mintBorder),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: const InputDecoration(
                hintText: 'Buscar turma',
                hintStyle: TextStyle(fontSize: 14, color: MarsupiColors.textMuted),
                prefixIcon: Icon(Icons.search, color: MarsupiColors.darkForest, size: 22),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Saudação (Figma: Bem-vinda, Ana! / Seu próximo passo começa na turma.)
          Text(
            'Bem-vinda, $userName!',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: MarsupiColors.darkForest,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Seu próximo passo começa na turma.',
            style: TextStyle(fontSize: 13, color: MarsupiColors.textMuted),
          ),
          const SizedBox(height: 24),

          // Cabeçalho Minhas turmas (Figma: Minhas turmas + link "+ Nova turma")
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
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NovaTurmaFotoScreen()),
                  );
                  _loadData();
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                  child: Row(
                    children: [
                      Icon(Icons.add, size: 16, color: MarsupiColors.primary),
                      SizedBox(width: 4),
                      Text(
                        'Nova turma',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: MarsupiColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Lista de Cards de Turmas (Figma mobile_inicio.png)
          ..._filteredTurmas.map((turma) {
            final nome = (turma['nome'] as String?) ?? 'Turma';
            final turno = (turma['turno'] as String?) ?? 'Manhã';
            final totalAlunos = (turma['estudantes_count'] ?? turma['estudantes'] ?? 25) as int;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 0,
              color: MarsupiColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: MarsupiColors.mintBorder),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Linha do Título e Ícone de documento (Figma)
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
                        const Icon(
                          Icons.article_outlined,
                          color: MarsupiColors.primary,
                          size: 26,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Colunas Turno e Estudantes
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Turno', style: TextStyle(fontSize: 12, color: MarsupiColors.textMuted)),
                            const SizedBox(height: 2),
                            Text(
                              turno,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
                            ),
                          ],
                        ),
                        const SizedBox(width: 40),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Estudantes', style: TextStyle(fontSize: 12, color: MarsupiColors.textMuted)),
                            const SizedBox(height: 2),
                            Text(
                              '$totalAlunos',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: MarsupiColors.mintBorder),
                    const SizedBox(height: 12),

                    // Linha Acessar turma > (Figma)
                    InkWell(
                      onTap: () {
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
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Acessar turma',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: MarsupiColors.darkForest,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: MarsupiColors.primary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTurmasView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Todas as turmas',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: MarsupiColors.primary, size: 28),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NovaTurmaFotoScreen()),
                  );
                  _loadData();
                },
                tooltip: 'Nova turma',
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Gerencie o cadastro de alunos e o acompanhamento inclusivo.',
            style: TextStyle(fontSize: 13, color: MarsupiColors.textMuted),
          ),
          const SizedBox(height: 16),
          ..._turmas.map((t) {
            final nome = t['nome'] as String? ?? 'Turma';
            final turno = t['turno'] as String? ?? 'Manhã';
            final total = (t['estudantes_count'] ?? t['estudantes'] ?? 0) as int;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: MarsupiColors.mintBorder),
              ),
              child: ListTile(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TurmaDetailScreen(
                        turmaId: (t['id'] as int?) ?? 1,
                        turmaNome: nome,
                        turno: turno,
                        totalAlunos: total,
                      ),
                    ),
                  );
                },
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: MarsupiColors.mintContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.school_outlined, color: MarsupiColors.primary),
                ),
                title: Text(nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('$turno · $total estudantes', style: const TextStyle(fontSize: 12, color: MarsupiColors.textMuted)),
                trailing: const Icon(Icons.chevron_right, color: MarsupiColors.primary),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPerfilView(String userName) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFFD2E4D9),
              child: Text(
                (_user['avatar'] as String?) ?? 'AP',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: MarsupiColors.darkForest,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              userName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
            ),
          ),
          const Center(
            child: Text(
              'Professora de Educação Básica',
              style: TextStyle(fontSize: 13, color: MarsupiColors.textMuted),
            ),
          ),
          const SizedBox(height: 28),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: MarsupiColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: MarsupiColors.mintBorder),
            ),
            child: Column(
              children: [
                _buildPerfilItem(Icons.badge_outlined, 'Matrícula', (_user['matricula'] as String?) ?? 'PROF2026'),
                const Divider(height: 20, color: MarsupiColors.mintBorder),
                _buildPerfilItem(Icons.email_outlined, 'E-mail', (_user['email'] as String?) ?? 'ana.professora@escola.edu.br'),
                const Divider(height: 20, color: MarsupiColors.mintBorder),
                _buildPerfilItem(Icons.location_city_outlined, 'Escola', (_user['escola'] as String?) ?? 'CEI Araquari'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Botão para o Portal da Família / Responsável
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PortalResponsavelScreen()),
              );
            },
            icon: const Icon(Icons.family_restroom),
            label: const Text('Abrir Portal da Família / Responsável'),
          ),
        ],
      ),
    );
  }

  Widget _buildPerfilItem(IconData icon, String titulo, String valor) {
    return Row(
      children: [
        Icon(icon, size: 20, color: MarsupiColors.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: const TextStyle(fontSize: 11, color: MarsupiColors.textMuted)),
            Text(valor, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest)),
          ],
        ),
      ],
    );
  }
}
