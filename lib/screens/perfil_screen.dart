import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/marsupi_theme.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'turma_cadastro_flow.dart';
import 'turma_detail_screen.dart';

class PerfilScreen extends StatefulWidget {
  final bool? forceLoading;
  final bool? forceError;
  final List<Map<String, dynamic>>? initialTurmas;
  final Map<String, dynamic>? initialUser;

  const PerfilScreen({
    super.key,
    this.forceLoading,
    this.forceError,
    this.initialTurmas,
    this.initialUser,
  });

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  // Modo edição
  bool _isEditing = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String? _nameValidationError;
  bool _isSaving = false;

  // Abas: 0 = Minhas turmas, 1 = Atividades recentes
  int _selectedTab = 0;

  // Filtros
  final _turmaSearchController = TextEditingController();
  String _turmaSearchQuery = '';

  final _atividadeSearchController = TextEditingController();
  String _atividadeSearchQuery = '';

  // Dados
  Map<String, dynamic> _user = {};
  List<Map<String, dynamic>> _turmas = [];
  Map<String, dynamic> _resumo = {};
  List<Map<String, dynamic>> _atividades = [];

  @override
  void initState() {
    super.initState();
    if (widget.forceLoading == true) {
      _isLoading = true;
    } else if (widget.forceError == true) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = 'Não foi possível carregar os dados do perfil.';
    } else {
      _loadData();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _turmaSearchController.dispose();
    _atividadeSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final user = widget.initialUser ?? await ApiService.instance.getUser();
      final turmas = widget.initialTurmas ?? await ApiService.instance.getTurmas();
      final resumo = await ApiService.instance.getResumoPerfil();
      final atividades = await ApiService.instance.getAtividadesRecentes();

      if (mounted) {
        setState(() {
          _user = user;
          _turmas = turmas;
          _resumo = resumo;
          _atividades = atividades;
          _nameController.text = (_user['nome'] as String?) ?? '';
          _emailController.text = (_user['email'] as String?) ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Erro ao carregar dados do perfil: $e';
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filteredTurmas {
    if (_turmaSearchQuery.trim().isEmpty) return _turmas;
    final query = _turmaSearchQuery.toLowerCase();
    return _turmas.where((t) {
      final nome = (t['nome'] as String? ?? '').toLowerCase();
      final turno = (t['turno'] as String? ?? '').toLowerCase();
      return nome.contains(query) || turno.contains(query);
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredAtividades {
    if (_atividadeSearchQuery.trim().isEmpty) return _atividades;
    final query = _atividadeSearchQuery.toLowerCase();
    return _atividades.where((a) {
      final titulo = (a['titulo'] as String? ?? '').toLowerCase();
      final status = (a['status'] as String? ?? '').toLowerCase();
      return titulo.contains(query) || status.contains(query);
    }).toList();
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      _nameController.text = (_user['nome'] as String?) ?? '';
      _emailController.text = (_user['email'] as String?) ?? '';
      _nameValidationError = null;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _nameController.text = (_user['nome'] as String?) ?? '';
      _emailController.text = (_user['email'] as String?) ?? '';
      _nameValidationError = null;
    });
  }

  Future<void> _saveProfile() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      setState(() {
        _nameValidationError = 'Informe seu nome para continuar.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _nameValidationError = null;
    });

    try {
      final result = await ApiService.instance.updateProfile(
        name: newName,
        email: _emailController.text.trim(),
      );

      if (mounted) {
        final updatedUser = (result['user'] as Map<String, dynamic>?) ?? _user;
        setState(() {
          _user = updatedUser;
          _isEditing = false;
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado'),
            backgroundColor: MarsupiTheme.primaryGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar perfil: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Sair da conta?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: MarsupiTheme.textPrimary,
          ),
        ),
        content: Text(
          'Tem certeza que deseja sair do aplicativo Marsupi?',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: MarsupiColors.textMuted,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: MarsupiColors.textMuted,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ApiService.instance.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: Text(
              'Sair',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildSkeletonState();
    }

    if (_hasError) {
      return _buildErrorState();
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Avatar + Nome + Badge Professora
          _buildTeacherHeader(),

          const SizedBox(height: 16),

          // Se estiver em modo edição, exibe formulário; senão, exibe dados + botão editar
          if (_isEditing)
            _buildEditModeCard()
          else
            _buildProfileDataCard(),

          const SizedBox(height: 20),

          // 3 Cards de Resumo
          _buildSummaryCards(),

          const SizedBox(height: 20),

          // Abas: "Minhas turmas" e "Atividades recentes"
          _buildTabsHeader(),

          const SizedBox(height: 16),

          // Conteúdo da aba selecionada
          if (_selectedTab == 0)
            _buildMinhasTurmasTab()
          else
            _buildAtividadesRecentesTab(),

          const SizedBox(height: 28),

          // Botão Sair da conta
          _buildLogoutButton(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ==========================================
  // ESTADO 2: CARREGANDO (SKELETON)
  // ==========================================
  Widget _buildSkeletonState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        children: [
          // Avatar Skeleton
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFE2EBE5),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 14),
          // Nome Skeleton
          Container(
            width: 170,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFFE2EBE5),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 8),
          // Badge Skeleton
          Container(
            width: 90,
            height: 22,
            decoration: BoxDecoration(
              color: const Color(0xFFE2EBE5),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 20),
          // Info Card Skeleton
          Container(
            height: 130,
            decoration: BoxDecoration(
              color: const Color(0xFFE2EBE5),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 20),
          // 3 Summary Cards Skeleton
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2EBE5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2EBE5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2EBE5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Tabs Skeleton
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE2EBE5),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          // List Items Skeleton
          Container(
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFE2EBE5),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFE2EBE5),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ESTADO 5: ERRO (COM TENTAR NOVAMENTE)
  // ==========================================
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 38,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Não foi possível carregar o perfil',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: MarsupiTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Verifique sua conexão ou tente novamente mais tarde.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: MarsupiColors.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(
                'Tentar novamente',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: MarsupiTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // CABEÇALHO DO PROFESSOR (NORMAL)
  // ==========================================
  Widget _buildTeacherHeader() {
    final avatar = (_user['avatar'] as String?) ?? 'PD';
    final nome = (_user['nome'] as String?) ?? 'Professor Demo';

    return Column(
      children: [
        Center(
          child: Container(
            width: 76,
            height: 76,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFDDECE1),
              shape: BoxShape.circle,
            ),
            child: Text(
              avatar,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: MarsupiTheme.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            nome,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: MarsupiTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Badge Professora
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: MarsupiColors.mintContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: MarsupiColors.mintBorder),
            ),
            child: Text(
              'Professora',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: MarsupiColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // DADOS DO PERFIL (NOME / EMAIL / MATRÍCULA C/ CADEADO)
  // ==========================================
  Widget _buildProfileDataCard() {
    final nome = (_user['nome'] as String?) ?? '';
    final email = (_user['email'] as String?) ?? '';
    final matricula = (_user['matricula'] as String?) ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCE6DF)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dados do perfil',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: MarsupiTheme.textPrimary,
                ),
              ),
              InkWell(
                onTap: _startEditing,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: MarsupiTheme.primaryGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Editar perfil',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: MarsupiTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 18, color: Color(0xFFE8EEE8)),
          _buildInfoRow('Nome', nome),
          const Divider(height: 18, color: Color(0xFFE8EEE8)),
          _buildInfoRow('Email', email),
          const Divider(height: 18, color: Color(0xFFE8EEE8)),
          _buildInfoRowWithLock('Matrícula', matricula),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xFF70877B),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: MarsupiTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRowWithLock(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF70877B),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.lock_outline,
              size: 14,
              color: Color(0xFF70877B),
            ),
          ],
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: MarsupiTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // ESTADO 4: MODO EDIÇÃO
  // ==========================================
  Widget _buildEditModeCard() {
    final matricula = (_user['matricula'] as String?) ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MarsupiTheme.primaryGreen.withAlpha(120), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: MarsupiTheme.primaryGreen.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Editar perfil',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: MarsupiTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 14),

          // Campo Nome
          Text(
            'Nome',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: MarsupiColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Digite seu nome',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              errorText: _nameValidationError,
              filled: true,
              fillColor: const Color(0xFFF9FAF9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFDCE6DF)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFDCE6DF)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: MarsupiTheme.primaryGreen),
              ),
            ),
            style: GoogleFonts.poppins(fontSize: 13, color: MarsupiTheme.textPrimary),
          ),

          const SizedBox(height: 12),

          // Campo Email
          Text(
            'Email',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: MarsupiColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Digite seu email',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: const Color(0xFFF9FAF9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFDCE6DF)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFDCE6DF)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: MarsupiTheme.primaryGreen),
              ),
            ),
            style: GoogleFonts.poppins(fontSize: 13, color: MarsupiTheme.textPrimary),
          ),

          const SizedBox(height: 12),

          // Matrícula Bloqueada (Cadeado)
          Text(
            'Matrícula',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: MarsupiColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4F1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFDCE6DF)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  matricula,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                const Icon(
                  Icons.lock,
                  size: 16,
                  color: Colors.black45,
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Botões Salvar e Cancelar
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving ? null : _cancelEditing,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFFCBDAD1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: MarsupiColors.textMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MarsupiTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Salvar',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3 CARDS DE RESUMO
  // ==========================================
  Widget _buildSummaryCards() {
    final turmasCount = _resumo['turmas_count']?.toString() ?? _turmas.length.toString();
    final estudantesCount = _resumo['estudantes_count']?.toString() ?? '6';
    final atividadesCount = _resumo['atividades_count']?.toString() ?? _atividades.length.toString();

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            title: 'Turmas ativas',
            value: turmasCount,
            icon: Icons.school_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            title: 'Estudantes',
            value: estudantesCount,
            icon: Icons.people_outline,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            title: 'Atividades',
            value: atividadesCount,
            icon: Icons.assignment_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCE6DF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: MarsupiTheme.primaryGreen),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: MarsupiTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: MarsupiColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SELETOR DE ABAS: MINHAS TURMAS / ATIVIDADES RECENTES
  // ==========================================
  Widget _buildTabsHeader() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF2EC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedTab = 0),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _selectedTab == 0 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: _selectedTab == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withAlpha(12),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Minhas turmas',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: _selectedTab == 0 ? FontWeight.w700 : FontWeight.w500,
                    color: _selectedTab == 0 ? MarsupiTheme.primaryGreen : MarsupiColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedTab = 1),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _selectedTab == 1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: _selectedTab == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withAlpha(12),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Atividades recentes',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: _selectedTab == 1 ? FontWeight.w700 : FontWeight.w500,
                    color: _selectedTab == 1 ? MarsupiTheme.primaryGreen : MarsupiColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ABA 1: MINHAS TURMAS (NORMAL OU SEM TURMAS)
  // ==========================================
  Widget _buildMinhasTurmasTab() {
    final turmas = _filteredTurmas;
    final totalCount = turmas.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Campo de filtro de turmas
        TextField(
          controller: _turmaSearchController,
          onChanged: (val) => setState(() => _turmaSearchQuery = val),
          decoration: InputDecoration(
            hintText: 'Filtrar turmas...',
            prefixIcon: const Icon(Icons.search, size: 20, color: MarsupiColors.textMuted),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDCE6DF)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDCE6DF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: MarsupiTheme.primaryGreen),
            ),
          ),
          style: GoogleFonts.poppins(fontSize: 13),
        ),

        const SizedBox(height: 12),

        // Contador "Mostrando N turmas"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mostrando $totalCount ${totalCount == 1 ? 'turma' : 'turmas'}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: MarsupiColors.textMuted,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // ESTADO 3: SEM TURMAS
        if (turmas.isEmpty)
          _buildEmptyTurmasState()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: turmas.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (ctx, index) {
              final t = turmas[index];
              return _buildTurmaCard(t);
            },
          ),
      ],
    );
  }

  // Card individual de turma com navegação
  Widget _buildTurmaCard(Map<String, dynamic> turma) {
    final id = turma['id'] as int? ?? 1;
    final nome = turma['nome'] as String? ?? 'Turma';
    final turno = turma['turno'] as String? ?? 'Manhã';
    final anoLetivo = turma['ano_letivo']?.toString() ?? '2026';
    final count = turma['estudantes_count']?.toString() ?? '0';

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFDCE6DF)),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: MarsupiColors.mintContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.school_outlined,
            color: MarsupiTheme.primaryGreen,
            size: 22,
          ),
        ),
        title: Text(
          nome,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: MarsupiTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          '$turno • $anoLetivo • $count estudantes',
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: MarsupiColors.textMuted,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: MarsupiColors.textMuted,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TurmaDetailScreen(
                turmaId: id,
                turmaNome: nome,
                turno: turno,
                totalAlunos: int.tryParse(count) ?? 0,
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // ESTADO 3: SEM TURMAS (COM BOTÃO + NOVA TURMA)
  // ==========================================
  Widget _buildEmptyTurmasState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCE6DF)),
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
            child: const Icon(
              Icons.school_outlined,
              size: 28,
              color: MarsupiTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Nenhuma turma encontrada',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: MarsupiTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Comece cadastrando uma nova turma tirando uma foto da folha de chamada.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: MarsupiColors.textMuted,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NovaTurmaFotoScreen()),
              );
            },
            icon: const Icon(Icons.add, size: 18),
            label: Text(
              '+ Nova turma',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: MarsupiTheme.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ESTADO 6: ABA ATIVIDADES RECENTES
  // ==========================================
  Widget _buildAtividadesRecentesTab() {
    final atividades = _filteredAtividades;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Filtro por título
        TextField(
          controller: _atividadeSearchController,
          onChanged: (val) => setState(() => _atividadeSearchQuery = val),
          decoration: InputDecoration(
            hintText: 'Filtrar atividades por título...',
            prefixIcon: const Icon(Icons.search, size: 20, color: MarsupiColors.textMuted),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDCE6DF)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDCE6DF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: MarsupiTheme.primaryGreen),
            ),
          ),
          style: GoogleFonts.poppins(fontSize: 13),
        ),

        const SizedBox(height: 14),

        if (atividades.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFDCE6DF)),
            ),
            child: Text(
              'Nenhuma atividade recente encontrada.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: MarsupiColors.textMuted,
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFDCE6DF)),
            ),
            child: Column(
              children: [
                // Cabeçalho da tabela / lista
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Atividade',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: MarsupiColors.textMuted,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Data',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: MarsupiColors.textMuted,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Status',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: MarsupiColors.textMuted,
                          ),
                        ),
                      ),
                      Text(
                        'Ação',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: MarsupiColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE8EEE8)),
                // Linhas da lista
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: atividades.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFE8EEE8)),
                  itemBuilder: (ctx, index) {
                    final item = atividades[index];
                    final titulo = item['titulo'] as String? ?? 'Atividade';
                    final data = item['data'] as String? ?? '23/10/2026';
                    final status = item['status'] as String? ?? 'Concluída';
                    final isConcluida = status.toLowerCase().contains('concluíd');

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              titulo,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: MarsupiTheme.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            flex: 2,
                            child: Text(
                              data,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: MarsupiColors.textMuted,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isConcluida ? const Color(0xFFEBF2EC) : const Color(0xFFFFF4E5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  status,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isConcluida ? MarsupiTheme.primaryGreen : Colors.orange.shade800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              _showAtividadeDetalhes(item);
                            },
                            child: Text(
                              'Ver',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: MarsupiTheme.primaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _showAtividadeDetalhes(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          item['titulo'] as String? ?? 'Detalhes da Atividade',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: MarsupiTheme.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data: ${item['data'] ?? '23/10/2026'}',
              style: GoogleFonts.poppins(fontSize: 13, color: MarsupiColors.textMuted),
            ),
            const SizedBox(height: 6),
            Text(
              'Status: ${item['status'] ?? 'Concluída'}',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: MarsupiTheme.primaryGreen,
              ),
            ),
            if (item['descricao'] != null) ...[
              const SizedBox(height: 8),
              Text(
                item['descricao'] as String,
                style: GoogleFonts.poppins(fontSize: 12, color: MarsupiTheme.textPrimary),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Fechar',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: MarsupiTheme.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ESTADO 7: MODAL "SAIR DA CONTA?"
  // ==========================================
  Widget _buildLogoutButton() {
    return OutlinedButton.icon(
      onPressed: _confirmLogout,
      icon: const Icon(Icons.logout, size: 18, color: Colors.redAccent),
      label: Text(
        'Sair da conta',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: Colors.redAccent,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: Colors.red.shade200),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
