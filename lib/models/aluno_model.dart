import 'perfil_apoio_model.dart';

class Aluno {
  final int? id;
  final String nome;
  final int turmaId;
  final String? turmaNome;
  final String? matricula;
  final String? nascimento;
  final String status;
  final bool precisaConferencia;
  final String? acompanhamento;
  final PerfilApoio? perfilApoio;
  final DateTime? createdAt;

  const Aluno({
    this.id,
    required this.nome,
    required this.turmaId,
    this.turmaNome,
    this.matricula,
    this.nascimento,
    this.status = 'Aluno ativo',
    this.precisaConferencia = false,
    this.acompanhamento,
    this.perfilApoio,
    this.createdAt,
  });

  String get avatar {
    final clean = nome.trim();
    return clean.isNotEmpty ? clean[0].toUpperCase() : 'A';
  }

  factory Aluno.fromJson(Map<String, dynamic> json) {
    PerfilApoio? apoio;
    if (json['perfil_apoio'] is Map<String, dynamic>) {
      apoio = PerfilApoio.fromJson(json['perfil_apoio'] as Map<String, dynamic>);
    } else if (json['meta_dados_detail'] is Map<String, dynamic>) {
      apoio = PerfilApoio.fromJson(json['meta_dados_detail'] as Map<String, dynamic>);
    }

    return Aluno(
      id: json['id'] is int
          ? json['id'] as int
          : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      nome: json['nome'] as String? ?? json['name'] as String? ?? 'Aluno',
      turmaId: (json['turma'] is int
              ? json['turma'] as int
              : (json['turma_id'] as int? ?? json['idTurma'] as int?)) ??
          0,
      turmaNome: json['turma_nome'] as String?,
      matricula: json['matricula'] as String?,
      nascimento: json['nascimento'] as String?,
      status: json['status'] as String? ?? 'Aluno ativo',
      precisaConferencia: json['precisa_conferencia'] as bool? ??
          json['precisaConferencia'] as bool? ??
          false,
      acompanhamento: json['acompanhamento'] as String?,
      perfilApoio: apoio,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'turma': turmaId,
      if (matricula != null) 'matricula': matricula,
      if (nascimento != null) 'nascimento': nascimento,
      'status': status,
      'precisa_conferencia': precisaConferencia,
      if (acompanhamento != null) 'acompanhamento': acompanhamento,
      if (perfilApoio != null) 'perfil_apoio': perfilApoio!.toJson(),
    };
  }
}
