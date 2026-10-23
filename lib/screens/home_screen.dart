import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/marsupi_theme.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
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
    final user = await ApiService.instance.getUser();
    final turmas = await ApiService.instance.getTurmas();
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
      return nome.contains(_searchQuery.toLowerCase()) ||
          turno.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final fullUserName = (_user['nome'] as String?) ?? '';
    final firstName = fullUserName.trim().isNotEmpty
        ? fullUserName.trim().split(' ').first
        : '';
    final userAvatar = (_user['avatar'] as String?) ?? '';

    return Scaffold(
      backgroundColor: MarsupiTheme.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: MarsupiTheme.primaryGreen,
                ),
              )
            : Column(
                children: [
                  // Top Bar idêntica ao Figma Mobile / Início (247:182)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Row(
                      children: [
                        Text(
                          'Marsupi',
                          style: GoogleFonts.poppins(
                            fontSize: 23,
                            fontWeight: FontWeight.w700,
                            color: MarsupiTheme.primaryGreen,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          '☰',
                          style: TextStyle(
                            fontSize: 20,
                            color: MarsupiTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Color(0xFFDDECE1),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            userAvatar,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: MarsupiTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: IndexedStack(
                      index: _currentNavIndex,
                      children: [
                        _buildInicioView(firstName),
                        _buildInicioView(firstName),
                        _buildPerfilView(fullUserName, userAvatar),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFDCE6DF), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentNavIndex,
          onTap: (index) => setState(() => _currentNavIndex = index),
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: MarsupiTheme.primaryGreen,
          unselectedItemColor: const Color(0xFF70877B),
          selectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
            fontSize: 11,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
            fontSize: 11,
          ),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 22),
              activeIcon: Icon(Icons.home_outlined, size: 22),
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined, size: 22),
              activeIcon: Icon(Icons.description_outlined, size: 22),
              label: 'Turmas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 22),
              activeIcon: Icon(Icons.person_outline, size: 22),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInicioView(String firstName) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search Bar (Figma 247:191)
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFB7CBBF), width: 1.5),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: MarsupiTheme.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Buscar turma',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF70877B),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: MarsupiTheme.primaryGreen,
                  size: 20,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Bem-vinda, $firstName!',
            style: GoogleFonts.poppins(
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: MarsupiTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Seu próximo passo começa na turma.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF526D65),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Minhas turmas',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: MarsupiTheme.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NovaTurmaFotoScreen(),
                    ),
                  );
                  _loadData();
                },
                child: Text(
                  '+ Nova turma',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: MarsupiTheme.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ..._filteredTurmas.map((turma) {
            final nome = (turma['nome'] as String?) ?? '';
            final turno = (turma['turno'] as String?) ?? '';
            final totalAlunos =
                (turma['estudantes_count'] ?? turma['estudantes'] ?? 0) as int;

            return GestureDetector(
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TurmaDetailScreen(
                      turmaId: (turma['id'] as int?) ?? 1,
                      turmaNome: nome,
                      turno: turno,
                      totalAlunos: totalAlunos,
                    ),
                  ),
                );
                _loadData();
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDCE6DF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          nome,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: MarsupiTheme.textPrimary,
                          ),
                        ),
                        const Icon(
                          Icons.description_outlined,
                          color: MarsupiTheme.primaryGreen,
                          size: 22,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        SizedBox(
                          width: 112,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Turno',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: const Color(0xFF70877B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                turno,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: MarsupiTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estudantes',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: const Color(0xFF70877B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$totalAlunos',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: MarsupiTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFE8EEE8),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Acessar turma',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: MarsupiTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '›',
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            color: MarsupiTheme.primaryGreen,
                          ),
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
    );
  }

  Widget _buildPerfilView(String userName, String userAvatar) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFDDECE1),
                shape: BoxShape.circle,
              ),
              child: Text(
                userAvatar,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: MarsupiTheme.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              userName,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: MarsupiTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDCE6DF)),
            ),
            child: Column(
              children: [
                _buildPerfilItem(
                  'Matrícula',
                  (_user['matricula'] as String?) ?? '',
                ),
                const Divider(height: 20, color: Color(0xFFE8EEE8)),
                _buildPerfilItem(
                  'E-mail',
                  (_user['email'] as String?) ?? '',
                ),
                const Divider(height: 20, color: Color(0xFFE8EEE8)),
                _buildPerfilItem(
                  'Escola',
                  (_user['escola'] as String?) ?? '',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {
              ApiService.instance.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  Widget _buildPerfilItem(String titulo, String valor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titulo,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xFF70877B),
          ),
        ),
        Text(
          valor,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: MarsupiTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
