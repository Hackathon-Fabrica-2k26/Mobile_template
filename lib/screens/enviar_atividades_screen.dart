import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/marsupi_theme.dart';
import '../services/api_service.dart';
import '../services/mock_data_service.dart';
import 'loading_screen.dart';

class EnviarAtividadesScreen extends StatefulWidget {
  final int turmaId;
  final String turmaNome;

  const EnviarAtividadesScreen({
    super.key,
    required this.turmaId,
    required this.turmaNome,
  });

  @override
  State<EnviarAtividadesScreen> createState() => _EnviarAtividadesScreenState();
}

class _EnviarAtividadesScreenState extends State<EnviarAtividadesScreen> {
  final _tituloController = TextEditingController();
  final _dataController = TextEditingController();
  final _obsController = TextEditingController();
  late String _turmaSelecionada;
  List<String> _nomesTurmas = [];
  final List<Map<String, String>> _arquivos = [];

  @override
  void initState() {
    super.initState();
    _turmaSelecionada = widget.turmaNome;
    _carregarDadosIniciais();
  }

  Future<void> _carregarDadosIniciais() async {
    final turmas = await ApiService.instance.getTurmas();
    final exemplos = await MockDataService.instance.getArquivosExemplo();
    if (!mounted) return;
    setState(() {
      _nomesTurmas = turmas
          .map((t) => (t['nome'] as String?) ?? '')
          .where((n) => n.isNotEmpty)
          .toList();
      if (!_nomesTurmas.contains(_turmaSelecionada) &&
          _nomesTurmas.isNotEmpty) {
        _turmaSelecionada = _nomesTurmas.first;
      }
      _arquivos
        ..clear()
        ..addAll(exemplos);
    });
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _dataController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  void _removerArquivo(int index) {
    setState(() {
      _arquivos.removeAt(index);
    });
  }

  Future<void> _adicionarArquivo() async {
    final exemplos = await MockDataService.instance.getArquivosExemplo();
    if (!mounted || exemplos.isEmpty) return;
    setState(() {
      final proximo = exemplos[_arquivos.length % exemplos.length];
      _arquivos.add(Map<String, String>.from(proximo));
    });
  }

  Future<void> _enviar() async {
    if (_tituloController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe o título da atividade.'),
          backgroundColor: MarsupiTheme.primaryGreen,
        ),
      );
      return;
    }

    await showMarsupiLoading<void>(
      context,
      message: 'Carregando...',
      task: () async {
        await Future.delayed(const Duration(milliseconds: 450));
        await ApiService.instance.addAtividade(
          turmaId: widget.turmaId,
          nome: _tituloController.text.trim(),
          dataAtividade: _dataController.text.trim(),
          observacoes: _obsController.text.trim(),
        );
      },
    );

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final opcoesTurma = _nomesTurmas.isEmpty
        ? <String>[_turmaSelecionada]
        : _nomesTurmas;

    return Scaffold(
      backgroundColor: MarsupiTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cabeçalho Mobile / Enviar atividades (Figma 250:119)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Enviar atividades',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: MarsupiTheme.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
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
              const SizedBox(height: 6),
              Text(
                'A IA identifica os alunos e preenche os dados automaticamente.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF526D65),
                ),
              ),
              const SizedBox(height: 16),

              // Dropzone (Figma 250:127)
              GestureDetector(
                onTap: _adicionarArquivo,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF5F0),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: MarsupiTheme.mintBorder,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDDEBE0),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.file_upload_outlined,
                          color: MarsupiTheme.primaryGreen,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Arraste e solte os arquivos',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: MarsupiTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ou Procurar arquivos',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: MarsupiTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'PDF, DOC, DOCX, JPG e PNG\nAté 20 MB por arquivo',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF70877B),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Campos do formulário (vazios por padrão)
              Text(
                'Título da atividade',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: MarsupiTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 40,
                child: TextField(
                  controller: _tituloController,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: MarsupiTheme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ex: Explorando as vogais',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF8CA095),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFFB7CBBF),
                        width: 1.2,
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
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'Turma',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: MarsupiTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 40,
                child: DropdownButtonFormField<String>(
                  key: ValueKey(_turmaSelecionada),
                  initialValue: _turmaSelecionada,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: MarsupiTheme.primaryGreen,
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: MarsupiTheme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFFB7CBBF),
                        width: 1.2,
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
                  items: opcoesTurma
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _turmaSelecionada = val);
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'Data da atividade',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: MarsupiTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 40,
                child: TextField(
                  controller: _dataController,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: MarsupiTheme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'DD/MM/AAAA',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF8CA095),
                    ),
                    suffixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: MarsupiTheme.primaryGreen,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFFB7CBBF),
                        width: 1.2,
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
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'Observações (opcional)',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: MarsupiTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 54,
                child: TextField(
                  controller: _obsController,
                  maxLines: 2,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: MarsupiTheme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Adicione observações sobre a atividade',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF8CA095),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFFB7CBBF),
                        width: 1.2,
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
                ),
              ),
              const SizedBox(height: 14),

              Text(
                'Arquivos (${_arquivos.length})',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: MarsupiTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              ..._arquivos.asMap().entries.map((entry) {
                final index = entry.key;
                final file = entry.value;

                return Container(
                  height: 44,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFDCE6DF),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        color: MarsupiTheme.primaryGreen,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              file['nome'] ?? '',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: MarsupiTheme.textPrimary,
                              ),
                            ),
                            Text(
                              file['tamanho'] ?? '',
                              style: GoogleFonts.poppins(
                                fontSize: 9,
                                color: const Color(0xFF70877B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _removerArquivo(index),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFF70877B),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 12),
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
                  onPressed: _enviar,
                  child: Text(
                    'Enviar',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: MarsupiTheme.background,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: MarsupiTheme.primaryGreen,
                    side: const BorderSide(
                      color: Color(0xFFB7CBBF),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: MarsupiTheme.primaryGreen,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
