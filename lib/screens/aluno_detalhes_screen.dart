import 'package:flutter/material.dart';
import '../constants/marsupi_theme.dart';
import 'aluno_pei_screen.dart';

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
    final nome = widget.aluno['nome'] as String? ?? 'Estudante';
    final matricula = widget.aluno['matricula'] as String? ?? '-';
    final nascimento = widget.aluno['nascimento'] as String? ?? '-';
    final status = widget.aluno['status'] as String? ?? 'Aluno ativo';
    final acompanhamento = widget.aluno['acompanhamento'] as String? ?? 'Sem observações registradas ainda.';
    final atividades = (widget.aluno['atividades'] as List<dynamic>? ?? []);
    final radar = widget.aluno['radar_metrics'] as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: MarsupiColors.background,
      appBar: AppBar(
        backgroundColor: MarsupiColors.background,
        elevation: 0,
        title: const Text(
          'Detalhes do aluno',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: MarsupiColors.darkForest,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: MarsupiColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: MarsupiColors.mintBorder),
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: MarsupiColors.darkForest, size: 20),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Fechar',
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header do Aluno (Figma: foto à esquerda com "Adicionar foto" abaixo, dados à direita)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: MarsupiColors.mintContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: MarsupiColors.mintBorder, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          size: 46,
                          color: MarsupiColors.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Upload de foto do estudante acionado.'),
                              backgroundColor: MarsupiColors.primary,
                            ),
                          );
                        },
                        child: const Text(
                          'Adicionar foto',
                          style: TextStyle(
                            fontSize: 12,
                            color: MarsupiColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nome,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: MarsupiColors.darkForest,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.turmaNome} · ${widget.turno}',
                          style: const TextStyle(fontSize: 13, color: MarsupiColors.textMuted),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: MarsupiColors.mintContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: MarsupiColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Matrícula e Nascimento (duas colunas conforme Figma)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Matrícula', style: TextStyle(fontSize: 12, color: MarsupiColors.textMuted)),
                        const SizedBox(height: 2),
                        Text(
                          matricula,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Nascimento', style: TextStyle(fontSize: 12, color: MarsupiColors.textMuted)),
                        const SizedBox(height: 2),
                        Text(
                          nascimento,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Segmented Toggle Pill (Figma: [ Visão geral ] [ Registros ])
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: MarsupiColors.mintContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tabIndex = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _tabIndex == 0 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _tabIndex == 0
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Text(
                            'Visão geral',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _tabIndex == 0 ? MarsupiColors.primary : MarsupiColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tabIndex = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _tabIndex == 1 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _tabIndex == 1
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Text(
                            'Registros',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _tabIndex == 1 ? MarsupiColors.primary : MarsupiColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (_tabIndex == 0) ...[
                // Seção Acompanhamento (Figma)
                const Text(
                  'Acompanhamento',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: MarsupiColors.darkForest,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  acompanhamento,
                  style: const TextStyle(
                    fontSize: 13,
                    color: MarsupiColors.darkForest,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),

                // Radar de Habilidades & Desafios IA
                if (radar != null && radar.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: MarsupiColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: MarsupiColors.mintBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.auto_awesome, color: MarsupiColors.accentPeach, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Radar de Habilidades & Desafios (IA)',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ...radar.entries.map((entry) {
                          final val = (entry.value as num).toInt();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(entry.key, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                    Text('$val%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: MarsupiColors.primary)),
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Seção Atividades (Figma)
                Text(
                  'Atividades (${atividades.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: MarsupiColors.darkForest,
                  ),
                ),
                const SizedBox(height: 12),

                if (atividades.isEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: MarsupiColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: MarsupiColors.mintBorder),
                    ),
                    child: const Center(
                      child: Text(
                        'Nenhuma atividade registrada para este estudante.',
                        style: TextStyle(fontSize: 13, color: MarsupiColors.textMuted),
                      ),
                    ),
                  ),
                ] else ...[
                  ...atividades.map((item) {
                    final ativ = Map<String, dynamic>.from(item as Map);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildAtividadeCard(
                        titulo: ativ['titulo'] as String? ?? 'Atividade',
                        dataEnvio: ativ['data_envio'] as String? ?? '',
                        observacao: ativ['observacao'] as String? ?? '',
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 24),

                // Rodapé de Exportação e Ações
                if (atividades.isNotEmpty) ...[
                  Center(
                    child: Text(
                      'Exporte os relatórios das ${atividades.length} atividades.',
                      style: const TextStyle(fontSize: 12, color: MarsupiColors.textMuted),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('📥 Exportando relatórios consolidados em PDF...'),
                          backgroundColor: MarsupiColors.primary,
                        ),
                      );
                    },
                    child: const Text('Exportar todas as atividades'),
                  ),
                ],
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AlunoPeiScreen(
                          alunoId: (widget.aluno['id'] as num?)?.toInt() ?? 101,
                          alunoNome: nome,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.description_outlined, size: 18),
                  label: const Text('Abrir Rascunho de PEI e Código'),
                ),
              ] else ...[
                // Aba Registros
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: MarsupiColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: MarsupiColors.mintBorder),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.history_edu_outlined, size: 40, color: MarsupiColors.primary),
                      SizedBox(height: 12),
                      Text(
                        'Histórico de Registros Pedagógicos',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Nenhum registro pendente. Todos os relatórios foram consolidados.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: MarsupiColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAtividadeCard({
    required String titulo,
    required String dataEnvio,
    required String observacao,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MarsupiColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MarsupiColors.mintBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.article_outlined, color: MarsupiColors.primary, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(dataEnvio, style: const TextStyle(fontSize: 12, color: MarsupiColors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(observacao, style: const TextStyle(fontSize: 13, color: MarsupiColors.darkForest)),
          const Divider(height: 20, color: MarsupiColors.mintBorder),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('📥 Exportando relatório: $titulo'),
                  backgroundColor: MarsupiColors.primary,
                ),
              );
            },
            child: const Row(
              children: [
                Icon(Icons.download, size: 16, color: MarsupiColors.primary),
                SizedBox(width: 6),
                Text(
                  'Exportar relatório',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: MarsupiColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
