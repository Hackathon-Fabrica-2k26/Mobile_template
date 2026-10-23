import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/marsupi_theme.dart';

class AlunoDetalhesScreen extends StatefulWidget {
  final Map<String, dynamic> aluno;
  final String turmaNome;
  final String turno;

  const AlunoDetalhesScreen({
    super.key,
    required this.aluno,
    this.turmaNome = '1º ano A',
    this.turno = 'Manhã',
  });

  @override
  State<AlunoDetalhesScreen> createState() => _AlunoDetalhesScreenState();
}

class _AlunoDetalhesScreenState extends State<AlunoDetalhesScreen> {
  int _tabIndex = 0; // 0 = Visão geral, 1 = Registros

  @override
  Widget build(BuildContext context) {
    final nome = (widget.aluno['nome'] as String?) ?? '';
    final matricula = (widget.aluno['matricula'] as String?) ?? '';
    final nascimento = (widget.aluno['nascimento'] as String?) ?? '';
    final status = (widget.aluno['status'] as String?) ?? 'Aluno ativo';
    final acompanhamento = (widget.aluno['acompanhamento'] as String?) ?? '';
    final atividades = (widget.aluno['atividades'] as List<dynamic>? ?? []);

    return Scaffold(
      backgroundColor: MarsupiTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cabeçalho Mobile / Detalhes do aluno (Figma 326:77)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detalhes do aluno',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: MarsupiTheme.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFB7CBBF),
                          width: 1.2,
                        ),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: MarsupiTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Avatar + Adicionar foto + Nome + Turma + Status (Figma 326:77)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBF2EC),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFB7CBBF),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          size: 38,
                          color: MarsupiTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Adicionar foto',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: MarsupiTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(
                          nome,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: MarsupiTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.turmaNome} · ${widget.turno}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF526D65),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 24,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          alignment: Alignment.center,
                          width: 98,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDDECE1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: MarsupiTheme.primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Caixas Matrícula e Nascimento (Figma 326:77)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFDCE6DF),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Matrícula',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: const Color(0xFF70877B),
                            ),
                          ),
                          Text(
                            matricula,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: MarsupiTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFDCE6DF),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Nascimento',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: const Color(0xFF70877B),
                            ),
                          ),
                          Text(
                            nascimento,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: MarsupiTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Segmented Toggle: Visão geral / Registros (Figma 326:77)
              Container(
                height: 36,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7EFE9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tabIndex = 0),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _tabIndex == 0
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Visão geral',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: _tabIndex == 0
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: _tabIndex == 0
                                  ? MarsupiTheme.primaryGreen
                                  : const Color(0xFF526D65),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tabIndex = 1),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _tabIndex == 1
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Registros',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: _tabIndex == 1
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: _tabIndex == 1
                                  ? MarsupiTheme.primaryGreen
                                  : const Color(0xFF526D65),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Acompanhamento (Figma 326:77)
              Text(
                'Acompanhamento',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: MarsupiTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFDCE6DF),
                    width: 1.2,
                  ),
                ),
                child: Text(
                  acompanhamento,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF526D65),
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Atividades (Figma 326:77)
              Text(
                'Atividades (${atividades.length})',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: MarsupiTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),

              ...atividades.map((item) {
                final ativ = Map<String, dynamic>.from(item as Map);
                final titulo = (ativ['titulo'] as String?) ?? '';
                final dataEnvio = (ativ['data_envio'] as String?) ?? '';
                final observacao = (ativ['observacao'] as String?) ?? '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFDCE6DF),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.description_outlined,
                            color: MarsupiTheme.primaryGreen,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  titulo,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: MarsupiTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  dataEnvio,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: const Color(0xFF70877B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        observacao,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF526D65),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFE6EDE7),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.file_download_outlined,
                            size: 14,
                            color: MarsupiTheme.primaryGreen,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Exportar relatório',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
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

              // Card final Exportar todas as atividades (Figma 326:77)
              Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF2EC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFD5E1D7),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Exporte os relatórios das ${atividades.length} atividades.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF526D65),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 36,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MarsupiTheme.primaryGreen,
                          foregroundColor: MarsupiTheme.background,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {},
                        child: Text(
                          'Exportar todas as atividades',
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
