class Aluno {
  final int? id;
  final String nome;
  final int? turmaId;
  final String? turmaNome;
  final int? paisId;
  final Map<String, dynamic>? metaDados;
  final String? perfilDisc;
  final DateTime? createdAt;

  const Aluno({
    this.id,
    required this.nome,
    this.turmaId,
    this.turmaNome,
    this.paisId,
    this.metaDados,
    this.perfilDisc,
    this.createdAt,
  });

  factory Aluno.fromJson(Map<String, dynamic> json) {
    return Aluno(
      id: json['id'] is int
          ? json['id'] as int
          : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      nome: json['nome'] as String? ?? json['name'] as String? ?? 'Aluno',
      turmaId: json['idTurma'] as int? ?? json['turma_id'] as int?,
      turmaNome: json['turma_nome'] as String? ?? json['turma'] as String?,
      paisId: json['Pais_id'] as int? ?? json['pais_id'] as int?,
      metaDados: json['metadados'] is Map<String, dynamic>
          ? json['metadados'] as Map<String, dynamic>
          : null,
      perfilDisc: json['disk'] as String? ?? json['disc'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      if (turmaId != null) 'idTurma': turmaId,
      if (paisId != null) 'Pais_id': paisId,
      if (metaDados != null) 'metadados': metaDados,
    };
  }
}
