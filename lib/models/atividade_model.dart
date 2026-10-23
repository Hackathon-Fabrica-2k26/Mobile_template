class Atividade {
  final int? id;
  final String nome;
  final String tipo;
  final int? alunoId;
  final String? descricao;
  final String? inclusiveTip;

  const Atividade({
    this.id,
    required this.nome,
    required this.tipo,
    this.alunoId,
    this.descricao,
    this.inclusiveTip,
  });

  factory Atividade.fromJson(Map<String, dynamic> json) {
    return Atividade(
      id: json['id'] is int
          ? json['id'] as int
          : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      nome: json['nome'] as String? ?? json['title'] as String? ?? '',
      tipo: json['tipo'] as String? ?? json['type'] as String? ?? 'Geral',
      alunoId: json['Aluno_id'] as int? ?? json['aluno_id'] as int?,
      descricao: json['objective'] as String? ??
          json['instructions'] as String? ??
          json['descricao'] as String?,
      inclusiveTip: json['inclusive_tip'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'tipo': tipo,
      if (alunoId != null) 'Aluno_id': alunoId,
    };
  }
}
