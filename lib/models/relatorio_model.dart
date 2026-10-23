import 'perfil_apoio_model.dart';

class Relatorio {
  final int? id;
  final int alunoId;
  final String? alunoNome;
  final PerfilApoio dados;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Relatorio({
    this.id,
    required this.alunoId,
    this.alunoNome,
    required this.dados,
    this.createdAt,
    this.updatedAt,
  });

  factory Relatorio.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> dadosMap = json['dados'] is Map<String, dynamic>
        ? json['dados'] as Map<String, dynamic>
        : json;

    return Relatorio(
      id: json['id'] is int
          ? json['id'] as int
          : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      alunoId: (json['aluno'] is int
              ? json['aluno'] as int
              : (json['aluno_id'] as int? ?? json['Aluno_id'] as int?)) ??
          0,
      alunoNome: json['aluno_nome'] as String?,
      dados: PerfilApoio.fromJson(dadosMap),
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
      'aluno': alunoId,
      'dados': dados.toJson(),
    };
  }
}
