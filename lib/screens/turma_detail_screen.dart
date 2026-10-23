import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/marsupi_theme.dart';
import '../services/api_service.dart';
import '../services/mock_data_service.dart';
import 'aluno_detalhes_screen.dart';
import 'enviar_atividades_screen.dart';
import 'loading_screen.dart';
import 'turma_cadastro_flow.dart';

class TurmaDetailScreen extends StatefulWidget {
  final int turmaId;
  final String turmaNome;
  final String turno;
  final int totalAlunos;

  const TurmaDetailScreen({
    super.key,
    required this.turmaId,
    required this.turmaNome,
    required this.turno,
    required this.totalAlunos,
  });

  @override
  State<TurmaDetailScreen> createState() => _TurmaDetailScreenState();
}

class _TurmaDetailScreenState extends State<TurmaDetailScreen> {
  List<Map<String, dynamic>> _estudantes = [];
  List<Map<String, dynamic>> _atividades = [];
  Map<String, dynamic> _user = {};
  bool _isLoading = true;
  bool _mostrarTodasAtividades = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant TurmaDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.turmaId != widget.turmaId) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final user = await ApiService.instance.getUser();
    final alunos =
        await ApiService.instance.getAlunos(turmaId: widget.turmaId);
    final ativs =
        await ApiService.instance.getAtividades(turmaId: widget.turmaId);
    if (mounted) {
      setState(() {
        _user = user;
        _estudantes = alunos;
        _atividades = ativs;
        _isLoading = false;
      });
    }
  }

  Future<void> _adicionarFotoChamada() async {
    final ocrNomes = await showMarsupiLoading<List<Map<String, dynamic>>>(
      context,
      message: 'Carregando...',
      task: () async {
        await Future.delayed(const Duration(milliseconds: 500));
        return MockDataService.instance.getChamadaOcrNomes();
      },
    );

    if (!mounted || ocrNomes == null) return;

    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ConfirmarNomesScreen(
          turmaId: widget.turmaId,
          nomeTurma: widget.turmaNome,
          turno: widget.turno,
          anoLetivo: 2026,
          nomesIniciais: ocrNomes,
        ),
      ),
    );

    if (updated == true && mounted) {
      _loadData();
    }
  }

  Future<void> _abrirEnviarAtividade() async {
    final enviada = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EnviarAtividadesScreen(
          turmaNome: widget.turmaNome,
          turmaId: widget.turmaId,
        ),
      ),
    );
    if (enviada == true && mounted) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAvatar = (_user['avatar'] as String?) ?? 'AP';
    final atividadesExibidas = _mostrarTodasAtividades
        ? _atividades
        : (_atividades.isNotEmpty ? [_atividades.first] : <Map<String, dynamic>>[]);

    return Scaffold(
      backgroundColor: MarsupiTheme.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: MarsupiTheme.primaryGreen,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top bar idêntica ao Figma (326:78 e 346:2)
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            'Marsupi',
                            style: GoogleFonts.poppins(
                              fontSize: 23,
                              fontWeight: FontWeight.w700,
                              color: MarsupiTheme.primaryGreen,
                            ),
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
                    const SizedBox(height: 16),

                    // Breadcrumb
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Minhas turmas / ${widget.turmaNome}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF70877B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Banner verde da turma (Figma 326:78 / 346:2)
                    Container(
                      height: 150,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: MarsupiTheme.primaryGreen,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -12,
                            top: -10,
                            child: Container(
                              width: 108,
                              height: 108,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: MarsupiTheme.mintBorder
                                    .withValues(alpha: 0.24),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 16,
                            bottom: 12,
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: MarsupiTheme.amberHighlight
                                    .withValues(alpha: 0.28),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ensino fundamental',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: const Color(0xFFDCECE2),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.turmaNome,
                                  style: GoogleFonts.poppins(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    color: MarsupiTheme.background,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${widget.turno} · ${_estudantes.length} estudantes',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: const Color(0xFFE7F0EA),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Cada descoberta começa aqui.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: const Color(0xFFDCECE2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Aba Estudantes com sublinhado âmbar (Figma 326:78 / 346:2)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 12, bottom: 8),
                          child: Text(
                            'Estudantes',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: MarsupiTheme.primaryGreen,
                            ),
                          ),
                        ),
                        Stack(
                          children: [
                            Container(
                              height: 3,
                              width: double.infinity,
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                height: 1,
                                color: const Color(0xFFDCE6DF),
                              ),
                            ),
                            Container(
                              width: 103,
                              height: 3,
                              decoration: BoxDecoration(
                                color: MarsupiTheme.amberHighlight,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Cabeçalho Estudantes da turma
                    Text(
                      'Estudantes da turma',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: MarsupiTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Acompanhe os perfis e registros da turma.',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF526D65),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Botão Adicionar foto (Figma 326:78 / 346:2)
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MarsupiTheme.primaryGreen,
                          foregroundColor: MarsupiTheme.background,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _adicionarFotoChamada,
                        icon: const Icon(
                          Icons.camera_alt_outlined,
                          size: 18,
                          color: MarsupiTheme.background,
                        ),
                        label: Text(
                          'Adicionar foto',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: MarsupiTheme.background,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Estado sem alunos (326:78) vs Alunos cadastrados (346:2)
                    if (_estudantes.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 22,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFDCE6DF)),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEBF2EC),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person_outline,
                                color: MarsupiTheme.primaryGreen,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Nenhum aluno cadastrado',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: MarsupiTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Adicione uma foto da chamada\npara cadastrar os alunos.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFF526D65),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Os estudantes aparecerão aqui.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: const Color(0xFF70877B),
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFDCE5DD)),
                        ),
                        child: Column(
                          children: List.generate(_estudantes.length, (index) {
                            final est = _estudantes[index];
                            final nome = (est['nome'] as String?) ?? '';
                            final avatar = (est['avatar'] as String?) ??
                                (nome.isNotEmpty ? nome[0].toUpperCase() : 'A');
                            final isLast = index == _estudantes.length - 1;

                            return Column(
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.vertical(
                                    top: index == 0
                                        ? const Radius.circular(14)
                                        : Radius.zero,
                                    bottom: isLast
                                        ? const Radius.circular(14)
                                        : Radius.zero,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AlunoDetalhesScreen(
                                          aluno: est,
                                          turmaNome: widget.turmaNome,
                                        ),
                                      ),
                                    );
                                  },
                                  child: SizedBox(
                                    height: 44,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 28,
                                            height: 28,
                                            alignment: Alignment.center,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFE5EEE5),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              avatar,
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color:
                                                    MarsupiTheme.primaryGreen,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              nome,
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: MarsupiTheme.textPrimary,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '›',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              color: MarsupiTheme.primaryGreen,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                if (!isLast)
                                  const Divider(
                                    height: 1,
                                    thickness: 1,
                                    indent: 14,
                                    endIndent: 14,
                                    color: Color(0xFFEDF1EB),
                                  ),
                              ],
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Text(
                          '${_estudantes.length} estudantes cadastrados',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: MarsupiTheme.primaryGreen,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),

                    // Bloco Atividades da turma (Figma 326:78 e 346:2)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF2EC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFD5E1D7)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Atividades da turma',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: MarsupiTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Acompanhe os relatórios individuais.',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF526D65),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _atividades.length == 1
                                ? '1 atividade cadastrada'
                                : '${_atividades.length} atividades cadastradas',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: MarsupiTheme.primaryGreen,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...atividadesExibidas.map((ativ) {
                            final nomeAtiv =
                                (ativ['nome'] as String?) ?? '';
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.fromLTRB(
                                14,
                                12,
                                14,
                                12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFDCE6DF),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nomeAtiv,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: MarsupiTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Relatórios da atividade',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: const Color(0xFF70877B),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Abrir atividade',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: MarsupiTheme.primaryGreen,
                                        ),
                                      ),
                                      Text(
                                        '›',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: MarsupiTheme.primaryGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: _abrirEnviarAtividade,
                            child: Text(
                              '+ Enviar nova atividade',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: MarsupiTheme.primaryGreen,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 42,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MarsupiTheme.primaryGreen,
                                foregroundColor: MarsupiTheme.background,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _mostrarTodasAtividades =
                                      !_mostrarTodasAtividades;
                                });
                              },
                              child: Text(
                                _mostrarTodasAtividades
                                    ? 'Mostrar menos'
                                    : 'Ver todas as atividades',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: MarsupiTheme.background,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
