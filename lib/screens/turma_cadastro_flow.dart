import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/marsupi_theme.dart';
import '../services/api_service.dart';
import 'loading_screen.dart';

class NovaTurmaFotoScreen extends StatefulWidget {
  const NovaTurmaFotoScreen({super.key});

  @override
  State<NovaTurmaFotoScreen> createState() => _NovaTurmaFotoScreenState();
}

class _NovaTurmaFotoScreenState extends State<NovaTurmaFotoScreen> {
  final _nomeController = TextEditingController();
  final _anoController = TextEditingController();
  String _turnoSelecionado = 'Manhã';
  bool _fotoAnexada = false;
  String? _origemFoto;
  Uint8List? _fotoBytes;
  String _fotoNome = 'chamada.jpg';

  @override
  void dispose() {
    _nomeController.dispose();
    _anoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarFoto(String origem) async {
    try {
      final foto = await ImagePicker().pickImage(
        source: origem == 'Câmera' ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 2000,
        imageQuality: 85,
      );
      if (foto == null) return;
      final bytes = await foto.readAsBytes();
      if (!mounted) return;
      setState(() {
        _fotoAnexada = true;
        _origemFoto = origem;
        _fotoBytes = bytes;
        _fotoNome = foto.name.isNotEmpty ? foto.name : 'chamada.jpg';
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível acessar a foto.')),
      );
    }
  }

  Future<void> _avancarParaRevisao() async {
    if (_nomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome da turma.')),
      );
      return;
    }
    if (!_fotoAnexada || _fotoBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Envie ou tire uma foto da lista de chamada para reconhecer os nomes.'),
        ),
      );
      return;
    }

    final anoLetivo = int.tryParse(_anoController.text.trim()) ?? 2026;
    String? erro;
    final ocrNomes = await showMarsupiLoading<List<Map<String, dynamic>>>(
      context,
      message: 'Carregando...',
      task: () async {
        try {
          return await ApiService.instance.reconhecerChamada(
            bytes: _fotoBytes!,
            filename: _fotoNome,
          );
        } on ApiException catch (e) {
          erro = e.message;
          return <Map<String, dynamic>>[];
        }
      },
    );

    if (erro != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(erro!), backgroundColor: Colors.redAccent),
        );
      }
      return;
    }

    if (!mounted || ocrNomes == null) return;

    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ConfirmarNomesScreen(
          nomeTurma: _nomeController.text.trim(),
          turno: _turnoSelecionado,
          anoLetivo: anoLetivo,
          nomesIniciais: ocrNomes,
        ),
      ),
    );

    if (created == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarsupiTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar idêntica ao Figma (277:566)
            Container(
              height: 78,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset(
                      'assets/images/logo_marsupi.png',
                      width: 56,
                      height: 56,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const Text(
                    '☰',
                    style: TextStyle(
                      fontSize: 22,
                      color: MarsupiTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Minhas turmas / Nova turma',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF70877B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Nova turma',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: MarsupiTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ETAPA 1 DE 2 · DADOS E FOTO',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: MarsupiTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: const LinearProgressIndicator(
                        value: 120 / 358,
                        minHeight: 3,
                        backgroundColor: Color(0xFFDDE7DF),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          MarsupiTheme.primaryGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nome da turma *',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: MarsupiTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            height: 44,
                            child: TextField(
                              controller: _nomeController,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: MarsupiTheme.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Ex: 1º ano A',
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: const Color(0xFF8EA398),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFCFDCD4),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: MarsupiTheme.primaryGreen,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ano letivo *',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: MarsupiTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    SizedBox(
                                      height: 44,
                                      child: TextField(
                                        controller: _anoController,
                                        keyboardType: TextInputType.number,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: MarsupiTheme.textPrimary,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: '2026',
                                          hintStyle: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: const Color(0xFF8EA398),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFCFDCD4),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                              color: MarsupiTheme.primaryGreen,
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Turno *',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: MarsupiTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    SizedBox(
                                      height: 44,
                                      child: DropdownButtonFormField<String>(
                                        initialValue: _turnoSelecionado,
                                        icon: const Icon(
                                          Icons.keyboard_arrow_down,
                                          size: 18,
                                          color: Color(0xFF70877B),
                                        ),
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: MarsupiTheme.textPrimary,
                                        ),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFCFDCD4),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                              color: MarsupiTheme.primaryGreen,
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                        items: ['Manhã', 'Tarde', 'Integral']
                                            .map(
                                              (t) => DropdownMenuItem(
                                                value: t,
                                                child: Text(t),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (val) => setState(
                                          () =>
                                              _turnoSelecionado = val ?? 'Manhã',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Foto da chamada *',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: MarsupiTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F8F3),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: MarsupiTheme.mintBorder,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  _fotoAnexada
                                      ? Icons.check_circle_outline
                                      : Icons.file_upload_outlined,
                                  size: 24,
                                  color: MarsupiTheme.primaryGreen,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _fotoAnexada
                                      ? 'Foto selecionada ($_origemFoto)'
                                      : 'Envie uma foto da lista de alunos',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: MarsupiTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 36,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                MarsupiTheme.primaryGreen,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            padding: EdgeInsets.zero,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: () =>
                                              _selecionarFoto('Galeria'),
                                          child: Text(
                                            'Enviar foto',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: SizedBox(
                                        height: 36,
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor:
                                                MarsupiTheme.primaryGreen,
                                            side: const BorderSide(
                                              color: Color(0xFFCBD9D0),
                                            ),
                                            padding: EdgeInsets.zero,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: () =>
                                              _selecionarFoto('Câmera'),
                                          child: Text(
                                            'Tirar foto',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: MarsupiTheme.primaryGreen,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'JPG ou PNG · até 20 MB',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: const Color(0xFF70877B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'A IA reconhece. Você confere antes de salvar.',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFF70877B),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MarsupiTheme.primaryGreen,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _avancarParaRevisao,
                              child: Text(
                                'Reconhecer nomes',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
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
          ],
        ),
      ),
    );
  }
}

class ConfirmarNomesScreen extends StatefulWidget {
  final int? turmaId;
  final String nomeTurma;
  final String turno;
  final int anoLetivo;
  final List<Map<String, dynamic>> nomesIniciais;

  const ConfirmarNomesScreen({
    super.key,
    this.turmaId,
    required this.nomeTurma,
    required this.turno,
    required this.anoLetivo,
    required this.nomesIniciais,
  });

  @override
  State<ConfirmarNomesScreen> createState() => _ConfirmarNomesScreenState();
}

class _ConfirmarNomesScreenState extends State<ConfirmarNomesScreen> {
  late List<Map<String, dynamic>> _alunosOcr;

  @override
  void initState() {
    super.initState();
    _alunosOcr = widget.nomesIniciais
        .map((a) => Map<String, dynamic>.from(a))
        .toList();
  }

  Future<void> _editarNome(int index) async {
    final ctrl =
        TextEditingController(text: _alunosOcr[index]['nome'] as String);
    final novoNome = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Conferir nome do estudante'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nome completo',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (novoNome != null && novoNome.isNotEmpty) {
      setState(() {
        _alunosOcr[index]['nome'] = novoNome;
        _alunosOcr[index]['precisaConferencia'] = false;
      });
    }
  }

  Future<void> _adicionarAlunoExtra() async {
    final ctrl = TextEditingController();
    final novoNome = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adicionar nome'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nome completo',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );

    if (novoNome != null && novoNome.isNotEmpty) {
      setState(() {
        _alunosOcr.add({
          'nome': novoNome,
          'precisaConferencia': false,
        });
      });
    }
  }

  Future<void> _confirmarTurma() async {
    final listaFinal = _alunosOcr.map((a) => a['nome'] as String).toList();

    String? erro;
    await showMarsupiLoading<void>(
      context,
      message: 'Carregando...',
      task: () async {
        try {
          if (widget.turmaId != null) {
            await ApiService.instance.addAlunosNaTurma(
              turmaId: widget.turmaId!,
              nomesAlunos: listaFinal,
            );
          } else {
            await ApiService.instance.addTurmaComAlunos(
              nome: widget.nomeTurma,
              turno: widget.turno,
              anoLetivo: widget.anoLetivo,
              nomesAlunos: listaFinal,
            );
          }
        } on ApiException catch (e) {
          erro = e.message;
        }
      },
    );

    if (!mounted) return;
    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro!), backgroundColor: Colors.redAccent),
      );
      return;
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final pendentes =
        _alunosOcr.where((a) => a['precisaConferencia'] == true).length;

    return Scaffold(
      backgroundColor: MarsupiTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar idêntica ao Figma (277:599)
            Container(
              height: 78,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset(
                      'assets/images/logo_marsupi.png',
                      width: 56,
                      height: 56,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const Text(
                    '☰',
                    style: TextStyle(
                      fontSize: 22,
                      color: MarsupiTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Minhas turmas / Nova turma',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF70877B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Confira os nomes',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: MarsupiTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ETAPA 2 DE 2 · CONFERIR E CRIAR',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: MarsupiTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: const LinearProgressIndicator(
                        value: 240 / 358,
                        minHeight: 3,
                        backgroundColor: Color(0xFFDDE7DF),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          MarsupiTheme.primaryGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      '${_alunosOcr.length} nomes encontrados',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: MarsupiTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8EEDB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        pendentes > 0
                            ? 'Confira os $pendentes nomes destacados'
                            : 'Todos os nomes foram conferidos',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF8C6531),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(_alunosOcr.length, (index) {
                      final item = _alunosOcr[index];
                      final precisa = item['precisaConferencia'] == true;
                      return GestureDetector(
                        onTap: () => _editarNome(index),
                        child: Container(
                          height: 40,
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: precisa
                                ? const Color(0xFFFAF3E7)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: precisa
                                ? Border.all(
                                    color: MarsupiTheme.amberHighlight,
                                    width: 1,
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 22,
                                child: Text(
                                  '${index + 1}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: const Color(0xFF70877B),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  item['nome'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: MarsupiTheme.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                precisa ? '✎' : '✓',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: MarsupiTheme.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _adicionarAlunoExtra,
                      child: Text(
                        '+ Adicionar nome',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: MarsupiTheme.primaryGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MarsupiTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _confirmarTurma,
                        child: Text(
                          'Confirmar ${_alunosOcr.length} alunos',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          'Voltar',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: MarsupiTheme.primaryGreen,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
