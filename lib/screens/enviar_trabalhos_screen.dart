import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/marsupi_theme.dart';
import '../services/api_service.dart';
import 'loading_screen.dart';

class EnviarTrabalhosScreen extends StatefulWidget {
  final int turmaId;
  final String turmaNome;
  final int atividadeId;
  final String atividadeTitulo;
  final List<Map<String, dynamic>>? estudantesIniciais;
  final List<Map<String, dynamic>>? trabalhosIniciais;

  const EnviarTrabalhosScreen({
    super.key,
    required this.turmaId,
    required this.turmaNome,
    required this.atividadeId,
    required this.atividadeTitulo,
    this.estudantesIniciais,
    this.trabalhosIniciais,
  });

  @override
  State<EnviarTrabalhosScreen> createState() => _EnviarTrabalhosScreenState();
}

class _EnviarTrabalhosScreenState extends State<EnviarTrabalhosScreen> {
  final List<Map<String, dynamic>> _arquivosFila = [];
  List<Map<String, dynamic>> _estudantes = [];
  List<Map<String, dynamic>> _trabalhos = [];
  final Map<int, int> _alunoSelecionadoPorTrabalho = {};
  bool _houveAlteracao = false;

  @override
  void initState() {
    super.initState();
    _estudantes = List<Map<String, dynamic>>.from(
      widget.estudantesIniciais ?? const [],
    );
    _trabalhos = List<Map<String, dynamic>>.from(
      widget.trabalhosIniciais ?? const [],
    );
    _sincronizarSelecoes();
    _carregarDados();
  }

  void _sincronizarSelecoes() {
    for (final t in _trabalhos) {
      final tId = t['id'] as int?;
      final alunoId = t['aluno'] as int?;
      if (tId != null && alunoId != null) {
        _alunoSelecionadoPorTrabalho[tId] = alunoId;
      }
    }
  }

  Future<void> _carregarDados() async {
    try {
      if (_estudantes.isEmpty) {
        final alunos =
            await ApiService.instance.getAlunos(turmaId: widget.turmaId);
        if (mounted) {
          setState(() => _estudantes = alunos);
        }
      }
      if (widget.trabalhosIniciais == null) {
        final existentes = await ApiService.instance.getTrabalhos(
          atividadeId: widget.atividadeId,
        );
        if (mounted) {
          setState(() {
            _trabalhos = existentes;
            _sincronizarSelecoes();
          });
        }
      }
    } on ApiException {
      // Se estiver offline no carregamento inicial, mantém os dados já em tela.
    }
  }

  String _formatarTamanho(int bytes) {
    if (bytes <= 0) return '';
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }

  void _adicionarNaFila(List<int> bytes, String filename) {
    if (bytes.length > 20 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('O arquivo "$filename" excede o limite de 20 MB.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    setState(() {
      _arquivosFila.add({
        'bytes': bytes,
        'filename': filename,
        'tamanho': _formatarTamanho(bytes.length),
      });
    });
  }

  Future<void> _tirarFotoCamera() async {
    final foto = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 2000,
      imageQuality: 85,
    );
    if (foto == null || !mounted) return;
    final bytes = await foto.readAsBytes();
    if (!mounted) return;
    final nome = foto.name.isNotEmpty
        ? foto.name
        : 'trabalho_${DateTime.now().millisecondsSinceEpoch}.jpg';
    _adicionarNaFila(bytes, nome);
  }

  Future<void> _escolherDaGaleria() async {
    final fotos = await ImagePicker().pickMultiImage(
      maxWidth: 2000,
      imageQuality: 85,
    );
    if (fotos.isEmpty || !mounted) return;
    for (var i = 0; i < fotos.length; i++) {
      final foto = fotos[i];
      final bytes = await foto.readAsBytes();
      if (!mounted) return;
      final nome = foto.name.isNotEmpty
          ? foto.name
          : 'trabalho_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
      _adicionarNaFila(bytes, nome);
    }
  }

  Future<void> _escolherArquivosPdfOuImagem() async {
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: true,
        withData: true,
      );
    } catch (_) {
      return;
    }
    if (result == null || result.files.isEmpty || !mounted) return;
    for (final picked in result.files) {
      try {
        final bytes = picked.bytes ?? await picked.xFile.readAsBytes();
        if (!mounted) return;
        _adicionarNaFila(bytes, picked.name);
      } catch (_) {}
    }
  }

  Future<void> _enviarArquivos() async {
    if (_arquivosFila.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione ao menos uma foto ou arquivo PDF do trabalho.'),
          backgroundColor: MarsupiTheme.primaryGreen,
        ),
      );
      return;
    }

    String? erro;
    final resposta = await showMarsupiLoading<Map<String, dynamic>?>(
      context,
      message: 'Analisando trabalhos com IA...',
      task: () async {
        try {
          return await ApiService.instance.enviarTrabalhos(
            atividadeId: widget.atividadeId,
            arquivos: List<Map<String, dynamic>>.from(_arquivosFila),
          );
        } on ApiException catch (e) {
          erro = e.message;
          return null;
        }
      },
    );

    if (!mounted) return;
    if (erro != null || resposta == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erro ?? 'Falha ao enviar trabalhos.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final novos = (resposta['trabalhos'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map(Map<String, dynamic>.from)
        .toList();

    setState(() {
      _arquivosFila.clear();
      _trabalhos = [...novos, ..._trabalhos];
      _sincronizarSelecoes();
      _houveAlteracao = true;
    });

    final pendentes = _trabalhos
        .where((t) => (t['identificacao'] ?? 'pendente') == 'pendente')
        .length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          pendentes > 0
              ? 'Trabalhos analisados! Confira os $pendentes com identificação pendente.'
              : 'Trabalhos enviados e identificados com sucesso!',
        ),
        backgroundColor: MarsupiTheme.primaryGreen,
      ),
    );
  }

  Future<void> _confirmarAlunoTrabalho(int trabalhoId) async {
    final alunoId = _alunoSelecionadoPorTrabalho[trabalhoId];
    if (alunoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione o estudante da turma antes de confirmar.'),
          backgroundColor: MarsupiTheme.primaryGreen,
        ),
      );
      return;
    }

    String? erro;
    final atualizado = await showMarsupiLoading<Map<String, dynamic>?>(
      context,
      message: 'Confirmando identificação...',
      task: () async {
        try {
          return await ApiService.instance.confirmarTrabalho(
            id: trabalhoId,
            alunoId: alunoId,
          );
        } on ApiException catch (e) {
          erro = e.message;
          return null;
        }
      },
    );

    if (!mounted) return;
    if (erro != null || atualizado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erro ?? 'Não foi possível confirmar o aluno.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final alunoNome = (_estudantes.firstWhere(
          (a) => a['id'] == alunoId,
          orElse: () => {'nome': atualizado['aluno_nome'] ?? ''},
        )['nome'] as String?) ??
        '';

    setState(() {
      _trabalhos = _trabalhos.map((t) {
        if (t['id'] == trabalhoId) {
          return {
            ...t,
            ...atualizado,
            'aluno': alunoId,
            'aluno_nome':
                (atualizado['aluno_nome'] as String?)?.isNotEmpty == true
                    ? atualizado['aluno_nome']
                    : alunoNome,
            'identificacao': 'confirmada',
          };
        }
        return t;
      }).toList();
      _houveAlteracao = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Identificação confirmada com sucesso.'),
        backgroundColor: MarsupiTheme.primaryGreen,
      ),
    );
  }

  String _nomeAlunoPorId(int? alunoId, String? fallback) {
    if (fallback != null && fallback.trim().isNotEmpty) return fallback;
    if (alunoId == null) return 'Não identificado';
    final encontrado = _estudantes.firstWhere(
      (e) => e['id'] == alunoId,
      orElse: () => const <String, dynamic>{},
    );
    return (encontrado['nome'] as String?) ?? 'Aluno #$alunoId';
  }

  @override
  Widget build(BuildContext context) {
    final pendentesCount = _trabalhos
        .where((t) => (t['identificacao'] ?? 'pendente') == 'pendente')
        .length;

    return Scaffold(
      backgroundColor: MarsupiTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Enviar trabalhos',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: MarsupiTheme.textPrimary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(_houveAlteracao),
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
              const SizedBox(height: 4),
              Text(
                '${widget.turmaNome} · ${widget.atividadeTitulo}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: MarsupiTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tire fotos dos trabalhos ou escolha arquivos da galeria/PDF (até 20 MB).',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF526D65),
                ),
              ),
              const SizedBox(height: 16),

              // Botões de Câmera, Galeria e PDF
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MarsupiTheme.primaryGreen,
                          foregroundColor: MarsupiTheme.background,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _tirarFotoCamera,
                        icon: const Icon(Icons.camera_alt_outlined, size: 18),
                        label: Text(
                          'Tirar foto',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: MarsupiTheme.primaryGreen,
                          side: const BorderSide(
                            color: MarsupiTheme.primaryGreen,
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _escolherDaGaleria,
                        icon: const Icon(Icons.photo_library_outlined, size: 18),
                        label: Text(
                          'Galeria',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFEFF5F0),
                    foregroundColor: MarsupiTheme.primaryGreen,
                    side: const BorderSide(
                      color: Color(0xFFB7CBBF),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _escolherArquivosPdfOuImagem,
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                  label: Text(
                    'Selecionar PDF ou imagem (até 20 MB)',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (_arquivosFila.isNotEmpty) ...[
                Text(
                  'Arquivos prontos para envio (${_arquivosFila.length})',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: MarsupiTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                ..._arquivosFila.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final arq = entry.value;
                  return Container(
                    height: 44,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFDCE6DF)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.insert_drive_file_outlined,
                          color: MarsupiTheme.primaryGreen,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${arq['filename']} (${arq['tamanho']})',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: MarsupiTheme.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Color(0xFF70877B),
                          ),
                          onPressed: () {
                            setState(() => _arquivosFila.removeAt(idx));
                          },
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 6),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MarsupiTheme.primaryGreen,
                      foregroundColor: MarsupiTheme.background,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _enviarArquivos,
                    child: Text(
                      'Analisar e enviar (${_arquivosFila.length})',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // Lista de trabalhos enviados e revisão de identificação pendente
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trabalhos enviados (${_trabalhos.length})',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: MarsupiTheme.textPrimary,
                    ),
                  ),
                  if (pendentesCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3D6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: MarsupiTheme.amberHighlight),
                      ),
                      child: Text(
                        '$pendentesCount pendente(s)',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF8A5A00),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              if (_trabalhos.isEmpty)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFDCE6DF)),
                  ),
                  child: Text(
                    'Nenhum trabalho enviado ainda para esta atividade.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF70877B),
                    ),
                  ),
                )
              else
                ..._trabalhos.map((trab) {
                  final trabId = trab['id'] as int?;
                  final ident =
                      (trab['identificacao'] ?? 'pendente').toString();
                  final isPendente = ident == 'pendente';
                  final nomeLido = (trab['nome_lido'] ?? '').toString().trim();
                  final confianca =
                      (trab['confianca_nome'] as num?)?.toDouble();
                  final confiancaPct = confianca != null
                      ? '${(confianca * 100).round()}%'
                      : null;
                  final alunoAtualId = trab['aluno'] as int?;
                  final alunoNomeConfirmado = _nomeAlunoPorId(
                    alunoAtualId,
                    trab['aluno_nome'] as String?,
                  );

                  final selecionado = trabId != null
                      ? _alunoSelecionadoPorTrabalho[trabId]
                      : alunoAtualId;
                  final idsEstudantes =
                      _estudantes.map((e) => e['id'] as int?).whereType<int>().toSet();
                  final valorDropdown =
                      (selecionado != null && idsEstudantes.contains(selecionado))
                          ? selecionado
                          : null;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isPendente
                            ? MarsupiTheme.amberHighlight
                            : const Color(0xFFDCE6DF),
                        width: isPendente ? 1.5 : 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                nomeLido.isNotEmpty
                                    ? 'Nome lido: $nomeLido'
                                    : 'Nome não identificado na foto',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: MarsupiTheme.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: isPendente
                                    ? const Color(0xFFFFF3D6)
                                    : const Color(0xFFE3F2E7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isPendente
                                    ? 'Pendente'
                                    : 'Identificado',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isPendente
                                      ? const Color(0xFF8A5A00)
                                      : MarsupiTheme.primaryGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (confiancaPct != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Confiança da leitura: $confiancaPct',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFF70877B),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        if (!isPendente)
                          Text(
                            'Estudante: $alunoNomeConfirmado',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: MarsupiTheme.primaryGreen,
                            ),
                          )
                        else ...[
                          Text(
                            'Escolha o aluno da turma para confirmar:',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF8A5A00),
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<int>(
                            key: ValueKey('trab_${trabId}_$valorDropdown'),
                            initialValue: valorDropdown,
                            hint: Text(
                              'Selecionar aluno da turma',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFF8CA095),
                              ),
                            ),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: MarsupiTheme.textPrimary,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF9FBF9),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFB7CBBF),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: MarsupiTheme.primaryGreen,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            items: _estudantes
                                .where((e) => e['id'] is int)
                                .map(
                                  (e) => DropdownMenuItem<int>(
                                    value: e['id'] as int,
                                    child: Text((e['nome'] as String?) ?? ''),
                                  ),
                                )
                                .toList(),
                            onChanged: trabId == null
                                ? null
                                : (val) {
                                    if (val != null) {
                                      setState(() {
                                        _alunoSelecionadoPorTrabalho[trabId] =
                                            val;
                                      });
                                    }
                                  },
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            height: 38,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MarsupiTheme.primaryGreen,
                                foregroundColor: MarsupiTheme.background,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: trabId == null
                                  ? null
                                  : () => _confirmarAlunoTrabalho(trabId),
                              child: Text(
                                'Confirmar aluno',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}
