class Trabalho {
  final int? id;
  final int? atividadeId;
  final int? alunoId;
  final String? alunoNome;
  final String? arquivoNome;
  final String? arquivoUrl;
  final String? tamanho;
  final bool precisaConferencia;
  final String? status;
  final DateTime? createdAt;

  const Trabalho({
    this.id,
    this.atividadeId,
    this.alunoId,
    this.alunoNome,
    this.arquivoNome,
    this.arquivoUrl,
    this.tamanho,
    this.precisaConferencia = false,
    this.status,
    this.createdAt,
  });

  factory Trabalho.fromJson(Map<String, dynamic> json) {
    return Trabalho(
      id: json['id'] is int
          ? json['id'] as int
          : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      atividadeId: json['atividade_id'] as int? ?? json['atividade'] as int?,
      alunoId: json['aluno_id'] as int? ?? json['aluno'] as int?,
      alunoNome: json['aluno_nome'] as String? ?? json['alunoReconhecido'] as String?,
      arquivoNome: json['arquivo_nome'] as String? ?? json['arquivo'] as String? ?? json['nome'] as String?,
      arquivoUrl: json['arquivo_url'] as String?,
      tamanho: json['tamanho'] as String?,
      precisaConferencia: json['duvida'] as bool? ??
          json['precisa_conferencia'] as bool? ??
          false,
      status: json['status'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (atividadeId != null) 'atividade': atividadeId,
      if (alunoId != null) 'aluno': alunoId,
      if (alunoNome != null) 'aluno_nome': alunoNome,
      if (arquivoNome != null) 'arquivo': arquivoNome,
      if (arquivoUrl != null) 'arquivo_url': arquivoUrl,
      if (tamanho != null) 'tamanho': tamanho,
      'precisa_conferencia': precisaConferencia,
      if (status != null) 'status': status,
    };
  }
}
