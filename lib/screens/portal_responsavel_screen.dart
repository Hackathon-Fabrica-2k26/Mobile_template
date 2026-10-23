import 'package:flutter/material.dart';
import '../constants/marsupi_theme.dart';
import '../services/mock_data_service.dart';
import 'loading_screen.dart';

class PortalResponsavelScreen extends StatefulWidget {
  const PortalResponsavelScreen({super.key});

  @override
  State<PortalResponsavelScreen> createState() => _PortalResponsavelScreenState();
}

class _PortalResponsavelScreenState extends State<PortalResponsavelScreen> {
  final _codigoController = TextEditingController();
  bool _consentimentoAceito = false;
  Map<String, dynamic>? _alunoEncontrado;
  bool _emVisualizacaoPerfil = false;
  bool _laudoEnviado = false;

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  void _consultarCodigo() async {
    final cod = _codigoController.text.trim();
    if (cod.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, informe o código fornecido pela escola.'),
          backgroundColor: MarsupiColors.primary,
        ),
      );
      return;
    }

    final aluno = await showMarsupiLoading(
      context,
      message: 'Localizando dados do estudante...',
      task: () => MockDataService.instance.getAlunoPorCodigo(cod),
    );

    if (!mounted) return;

    if (aluno != null) {
      setState(() {
        _alunoEncontrado = aluno;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código não encontrado. Verifique com a professora da turma.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _avancarAposConsentimento() {
    if (!_consentimentoAceito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, confirme a leitura do termo de consentimento.'),
          backgroundColor: MarsupiColors.primary,
        ),
      );
      return;
    }

    setState(() {
      _emVisualizacaoPerfil = true;
    });
  }

  void _enviarLaudo() async {
    await showMarsupiLoading(
      context,
      message: 'IA processando laudo e extraindo recomendações sensoriais...',
      task: () async => await Future.delayed(const Duration(milliseconds: 600)),
    );

    if (!mounted) return;

    setState(() {
      _laudoEnviado = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Laudo integrado com sucesso! As recomendações pedagógicas foram incluídas no perfil de apoio.'),
        backgroundColor: MarsupiColors.primary,
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portal da Família'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: _emVisualizacaoPerfil ? _buildPerfilApoio() : _buildIdentificacaoEConsentimento(),
        ),
      ),
    );
  }

  Widget _buildIdentificacaoEConsentimento() {
    if (_alunoEncontrado == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Image.asset(
              'assets/images/logo_marsupi.png',
              height: 70,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Acompanhamento Escolar Inclusivo',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
          ),
          const SizedBox(height: 6),
          const Text(
            'Digite o código do aluno fornecido pela professora para acessar relatórios, metas e perfil de apoio da criança.',
            style: TextStyle(fontSize: 13, color: MarsupiColors.textMuted),
          ),
          const SizedBox(height: 24),
          const Text(
            'Código do Estudante *',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: MarsupiColors.darkForest),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _codigoController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              hintText: 'Ex: MARS-7821 ou MARS-101',
              prefixIcon: Icon(Icons.pin),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _consultarCodigo,
            icon: const Icon(Icons.search),
            label: const Text('Acessar com código'),
          ),
        ],
      );
    }

    // Tela de Consentimento LGPD (Figma 259:128)
    final nomeAluno = _alunoEncontrado?['nome'] ?? 'Estudante';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: MarsupiColors.mintContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: MarsupiColors.primary,
                foregroundColor: Colors.white,
                child: Text(nomeAluno.isNotEmpty ? nomeAluno[0] : 'A'),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nomeAluno,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: MarsupiColors.darkForest),
                    ),
                    const Text('Estudante vinculado à sua família', style: TextStyle(fontSize: 12, color: MarsupiColors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        const Text(
          'Termo de Consentimento & LGPD',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: MarsupiColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: MarsupiColors.mintBorder),
          ),
          child: const Text(
            'A plataforma Marsupi utiliza Inteligência Artificial apenas para fins de apoio pedagógico e adaptação inclusiva de atividades de sala de aula. Todos os dados são confidenciais, protegidos pela Lei Geral de Proteção de Dados (LGPD) e compartilhados exclusivamente entre a escola e você.',
            style: TextStyle(fontSize: 12, height: 1.5, color: MarsupiColors.darkForest),
          ),
        ),
        const SizedBox(height: 16),

        CheckboxListTile(
          value: _consentimentoAceito,
          contentPadding: EdgeInsets.zero,
          activeColor: MarsupiColors.primary,
          title: const Text(
            'Concordo com o uso assistido de IA para personalização pedagógica do meu filho(a).',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          onChanged: (val) => setState(() => _consentimentoAceito = val ?? false),
        ),
        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: _avancarAposConsentimento,
          child: const Text('Confirmar e acessar perfil de apoio'),
        ),
      ],
    );
  }

  Widget _buildPerfilApoio() {
    final nomeAluno = _alunoEncontrado?['nome'] ?? 'Estudante';
    final radar = _alunoEncontrado?['radar_metrics'] as Map<String, dynamic>?;
    final strengths = (_alunoEncontrado?['strengths'] as List<dynamic>?)?.cast<String>() ?? [];
    final supportNeeds = (_alunoEncontrado?['support_needs'] as List<dynamic>?)?.cast<String>() ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: MarsupiColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Perfil de Apoio Escolar',
                style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                nomeAluno,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Visão compartilhada entre escola e responsáveis.',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Enviar Laudo Médico (Figma 259:130)
        Card(
          elevation: 0,
          color: const Color(0xFFF9FBF9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: MarsupiColors.mintBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.medical_information_outlined, color: MarsupiColors.primary, size: 24),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Relatórios ou Laudos Clínicos',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: MarsupiColors.darkForest),
                      ),
                    ),
                    if (_laudoEnviado)
                      const Chip(
                        label: Text('Ativo', style: TextStyle(fontSize: 10, color: MarsupiColors.primary)),
                        backgroundColor: MarsupiColors.mintContainer,
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Envie relatórios de neuropediatra, psicólogo ou fonoaudiólogo para auxiliar os professores nas adaptações de sala.',
                  style: TextStyle(fontSize: 12, color: MarsupiColors.textMuted),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _enviarLaudo,
                  icon: const Icon(Icons.upload_file),
                  label: Text(_laudoEnviado ? 'Atualizar laudo (PDF/Imagem)' : 'Enviar laudo ou relatório'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        if (radar != null && radar.isNotEmpty) ...[
          const Text(
            'Habilidades & Desafios Observados na Escola',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
          ),
          const SizedBox(height: 12),
          ...radar.entries.map((e) {
            final val = (e.value as num).toInt();
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      Text('$val%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: MarsupiColors.primary)),
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

        if (strengths.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Pontos Fortes Mapeados',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
          ),
          const SizedBox(height: 6),
          ...strengths.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.star_outline, color: MarsupiColors.primary, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(s, style: const TextStyle(fontSize: 12))),
              ],
            ),
          )),
        ],

        if (supportNeeds.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Como apoiamos na escola e você pode apoiar em casa',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
          ),
          const SizedBox(height: 6),
          ...supportNeeds.map((n) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.favorite_outline, color: MarsupiColors.accentPeach, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(n, style: const TextStyle(fontSize: 12))),
              ],
            ),
          )),
        ],

        const SizedBox(height: 28),
        OutlinedButton(
          onPressed: () {
            setState(() {
              _alunoEncontrado = null;
              _emVisualizacaoPerfil = false;
              _consentimentoAceito = false;
              _codigoController.clear();
            });
          },
          child: const Text('Sair do portal da família'),
        ),
      ],
    );
  }
}
