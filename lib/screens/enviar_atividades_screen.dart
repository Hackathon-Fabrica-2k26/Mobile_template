import 'package:flutter/material.dart';
import '../constants/marsupi_theme.dart';
import 'enviar_trabalhos_flow.dart';

class EnviarAtividadesScreen extends StatefulWidget {
  final int turmaId;
  final String turmaNome;

  const EnviarAtividadesScreen({
    super.key,
    required this.turmaId,
    this.turmaNome = '1º ano A',
  });

  @override
  State<EnviarAtividadesScreen> createState() => _EnviarAtividadesScreenState();
}

class _EnviarAtividadesScreenState extends State<EnviarAtividadesScreen> {
  final List<Map<String, String>> _arquivos = [
    {
      'nome': 'Atividades-parte-01.pdf',
      'tamanho': '8,4 MB · Concluído',
    },
    {
      'nome': 'Atividades-parte-02.pdf',
      'tamanho': '6,2 MB · Concluído',
    },
    {
      'nome': 'Atividades-parte-03.jpg',
      'tamanho': '3,1 MB · Concluído',
    },
  ];

  void _removerArquivo(int index) {
    setState(() {
      _arquivos.removeAt(index);
    });
  }

  void _adicionarArquivo() {
    setState(() {
      _arquivos.add({
        'nome': 'Atividades-parte-0${_arquivos.length + 1}.pdf',
        'tamanho': '4,5 MB · Concluído',
      });
    });
  }

  void _avancarParaIdentificacao() {
    if (_arquivos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos um arquivo para enviar.'),
          backgroundColor: MarsupiColors.primary,
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => EnviarTrabalhosFlowScreen(
          atividadeId: 1,
          atividadeNome: 'Explorando as vogais',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MarsupiColors.background,
      appBar: AppBar(
        backgroundColor: MarsupiColors.background,
        elevation: 0,
        title: const Text(
          'Enviar atividades',
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
              const Text(
                'A IA identifica os alunos e preenche os dados automaticamente.',
                style: TextStyle(fontSize: 13, color: MarsupiColors.textMuted),
              ),
              const SizedBox(height: 20),

              // Dropzone tracejado (Figma: upload icon, drag & drop)
              GestureDetector(
                onTap: _adicionarArquivo,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                  decoration: BoxDecoration(
                    color: MarsupiColors.mintContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: MarsupiColors.mintBorder,
                      style: BorderStyle.solid,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: MarsupiColors.mintContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.upload, color: MarsupiColors.primary, size: 28),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Arraste e solte os arquivos',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: MarsupiColors.darkForest),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'ou Procurar arquivos',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: MarsupiColors.primary),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'PDF, DOC, DOCX, JPG e PNG\nAté 20 MB por arquivo',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: MarsupiColors.textMuted, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Lista de Arquivos Carregados (Figma)
              ..._arquivos.asMap().entries.map((entry) {
                final index = entry.key;
                final file = entry.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: MarsupiColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: MarsupiColors.mintBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.article_outlined, color: MarsupiColors.primary, size: 26),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              file['nome']!,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: MarsupiColors.darkForest),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              file['tamanho']!,
                              style: const TextStyle(fontSize: 12, color: MarsupiColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: MarsupiColors.textMuted, size: 20),
                        onPressed: () => _removerArquivo(index),
                        tooltip: 'Remover',
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 32),

              // Botões (Figma)
              ElevatedButton(
                onPressed: _avancarParaIdentificacao,
                child: const Text('Enviar'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
