import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/marsupi_theme.dart';
import '../services/mock_data_service.dart';

class AlunoPeiScreen extends StatefulWidget {
  final int alunoId;
  final String alunoNome;

  const AlunoPeiScreen({
    super.key,
    required this.alunoId,
    required this.alunoNome,
  });

  @override
  State<AlunoPeiScreen> createState() => _AlunoPeiScreenState();
}

class _AlunoPeiScreenState extends State<AlunoPeiScreen> {
  Map<String, dynamic>? _peiData;
  bool _isLoading = true;
  String _codigoAcesso = '';

  @override
  void initState() {
    super.initState();
    _loadPei();
  }

  Future<void> _loadPei() async {
    final pei = await MockDataService.instance.gerarPEI(widget.alunoId);
    final alunos = await MockDataService.instance.getAlunos();
    final aluno = alunos.firstWhere(
      (a) => a['id'] == widget.alunoId,
      orElse: () => alunos.first,
    );
    final cod = (aluno['codigo_acesso'] as String?) ?? 'MARS-${widget.alunoId * 37 % 9000 + 1000}';

    if (mounted) {
      setState(() {
        _peiData = pei;
        _codigoAcesso = cod;
        _isLoading = false;
      });
    }
  }

  void _copiarCodigo() {
    Clipboard.setData(ClipboardData(text: _codigoAcesso));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Código $_codigoAcesso copiado para a área de transferência!'),
        backgroundColor: MarsupiColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PEI & Relatório Pedagógico'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: MarsupiColors.primary))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Banner Aluno
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: MarsupiColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
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
                              'PLANO DE ENSINO INDIVIDUALIZADO (PEI)',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.alunoNome,
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Rascunho estruturado por IA para conselho de classe e AEE',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Card de Código do Aluno (Figma 259:124)
                    Card(
                      elevation: 0,
                      color: const Color(0xFFF9F7F1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: MarsupiColors.accentPeach, width: 1.5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.vpn_key_outlined, color: MarsupiColors.accentPeach, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Código de Acesso do Responsável',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: MarsupiColors.darkForest),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Compartilhe este código com os pais para acesso seguro aos relatórios da criança.',
                              style: TextStyle(fontSize: 12, color: MarsupiColors.textMuted),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: MarsupiColors.mintBorder),
                                  ),
                                  child: Text(
                                    _codigoAcesso,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: MarsupiColors.primary,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: _copiarCodigo,
                                  icon: const Icon(Icons.copy, size: 16),
                                  label: const Text('Copiar'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Metas Trimestrais
                    const Text(
                      'Metas de Desenvolvimento Individualizadas',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
                    ),
                    const SizedBox(height: 10),
                    ...((_peiData?['metas_trimestrais'] as List<dynamic>?) ?? []).map((meta) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_outline, color: MarsupiColors.primary, size: 18),
                            const SizedBox(width: 10),
                            Expanded(child: Text(meta as String, style: const TextStyle(fontSize: 13, height: 1.4))),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 20),

                    // Acomodações Pedagógicas
                    const Text(
                      'Acomodações Curriculares e Sensoriais',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
                    ),
                    const SizedBox(height: 10),
                    ...((_peiData?['acomodacoes_pedagogicas'] as List<dynamic>?) ?? []).map((ac) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.spa_outlined, color: MarsupiColors.accentPeach, size: 18),
                            const SizedBox(width: 10),
                            Expanded(child: Text(ac as String, style: const TextStyle(fontSize: 13, height: 1.4))),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 20),

                    // Parecer do Conselho
                    const Text(
                      'Parecer para o Conselho Pedagógico',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: MarsupiColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: MarsupiColors.mintBorder),
                      ),
                      child: Text(
                        (_peiData?['parecer_conselho'] as String?) ?? '',
                        style: const TextStyle(fontSize: 13, height: 1.5, color: MarsupiColors.darkForest),
                      ),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('📥 Exportando PEI e Relatório oficial em PDF...'),
                            backgroundColor: MarsupiColors.primary,
                          ),
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Exportar PEI em PDF oficial'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
