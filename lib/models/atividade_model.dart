class Atividade {
  final int? id;
  final String nome;
  final String tipo;
  final int? turmaId;
  final int? alunoId;
  final String? descricao;
  final String? dataEnvio;
  final int relatoriosCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Atividade({
    this.id,
    required this.nome,
    this.tipo = 'Linguagem / Avaliação',
    this.turmaId,
    this.alunoId,
    this.descricao,
    this.dataEnvio,
    this.relatoriosCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory Atividade.fromJson(Map<String, dynamic> json) {
    return Atividade(
      id: json['id'] is int
          ? json['id'] as int
          : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      nome: json['nome'] as String? ?? json['title'] as String? ?? '',
      tipo: json['tipo'] as String? ?? json['type'] as String? ?? 'Geral',
      turmaId: json['turma_id'] as int? ?? json['turma'] as int?,
      alunoId: json['aluno_id'] as int? ?? json['aluno'] as int?,
      descricao: json['descricao'] as String? ??
          json['objective'] as String? ??
          json['instructions'] as String?,
      dataEnvio: json['data'] as String? ?? json['data_envio'] as String?,
      relatoriosCount: json['relatorios_count'] as int? ??
          (json['relatorios'] as List<dynamic>?)?.length ??
          0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'tipo': tipo,
      if (turmaId != null) 'turma_id': turmaId,
      if (alunoId != null) 'aluno': alunoId,
      if (descricao != null) 'descricao': descricao,
      if (dataEnvio != null) 'data': dataEnvio,
    };
  }
}
