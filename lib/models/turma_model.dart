class Turma {
  final int? id;
  final String nome;
  final String turno;
  final String? turnoDisplay;
  final int totalEstudantes;
  final int? escola;
  final List<int> professores;

  const Turma({
    this.id,
    required this.nome,
    required this.turno,
    this.turnoDisplay,
    this.totalEstudantes = 0,
    this.escola,
    this.professores = const [],
  });

  factory Turma.fromJson(Map<String, dynamic> json) {
    final rawTurno = json['turno'] as String? ?? 'manha';
    return Turma(
      id: json['id'] is int
          ? json['id'] as int
          : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      nome: json['nome'] as String? ?? '',
      turno: rawTurno,
      turnoDisplay: json['turno_display'] as String? ??
          (rawTurno.toLowerCase().contains('tarde')
              ? 'Tarde'
              : rawTurno.toLowerCase().contains('integral')
                  ? 'Integral'
                  : 'Manhã'),
      totalEstudantes: json['total_estudantes'] as int? ??
          json['estudantes_count'] as int? ??
          0,
      escola: json['escola'] as int?,
      professores: (json['professores'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'turno': turno,
      if (escola != null) 'escola': escola,
    };
  }
}
