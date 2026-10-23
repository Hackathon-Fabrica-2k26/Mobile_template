class Relatorio {
  final int? id;
  final int alunoId;
  final String? alunoNome;
  final String profileSummary;
  final Map<String, int> radarMetrics;
  final List<String> strengths;
  final List<String> supportNeeds;
  final List<Map<String, dynamic>> adaptedActivities;
  final String? autonomyCoachingTip;
  final DateTime? createdAt;

  const Relatorio({
    this.id,
    required this.alunoId,
    this.alunoNome,
    required this.profileSummary,
    this.radarMetrics = const {},
    this.strengths = const [],
    this.supportNeeds = const [],
    this.adaptedActivities = const [],
    this.autonomyCoachingTip,
    this.createdAt,
  });

  factory Relatorio.fromJson(Map<String, dynamic> json) {
    final rawRadar = json['radar_metrics'] as Map<String, dynamic>? ?? {};
    final parsedRadar = rawRadar.map(
      (key, value) => MapEntry(key, value is int ? value : int.tryParse(value.toString()) ?? 50),
    );

    final rawActivities = json['adapted_activities'] as List<dynamic>? ?? [];
    final parsedActivities = rawActivities
        .whereType<Map<String, dynamic>>()
        .toList();

    return Relatorio(
      id: json['id'] is int
          ? json['id'] as int
          : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      alunoId: json['Aluno_id'] as int? ?? json['aluno_id'] as int? ?? 0,
      alunoNome: json['aluno_nome'] as String?,
      profileSummary: json['profile_summary'] as String? ??
          json['dadosfodas'] as String? ??
          json['resumo'] as String? ??
          '',
      radarMetrics: parsedRadar,
      strengths: (json['strengths'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      supportNeeds: (json['support_needs'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      adaptedActivities: parsedActivities,
      autonomyCoachingTip: json['autonomy_coaching_tip'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}
