class PerfilApoio {
  final int? id;
  final String? resumo;
  final Map<String, dynamic> caracteristicas;
  final Map<String, int> metricasRadar;
  final List<String> pontosFortes;
  final List<String> necessidadesApoio;
  final String? dicaAutonomia;

  const PerfilApoio({
    this.id,
    this.resumo,
    this.caracteristicas = const {},
    this.metricasRadar = const {},
    this.pontosFortes = const [],
    this.necessidadesApoio = const [],
    this.dicaAutonomia,
  });

  factory PerfilApoio.fromJson(Map<String, dynamic> json) {
    final rawRadar = (json['radar_metrics'] ?? json['metricas_radar'])
            as Map<String, dynamic>? ??
        {};
    final parsedRadar = rawRadar.map(
      (key, value) => MapEntry(
        key,
        value is int ? value : int.tryParse(value.toString()) ?? 50,
      ),
    );

    return PerfilApoio(
      id: json['id'] is int
          ? json['id'] as int
          : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      resumo: json['profile_summary'] as String? ??
          json['resumo'] as String? ??
          json['acompanhamento'] as String?,
      caracteristicas: json['caracteristicas'] is Map<String, dynamic>
          ? json['caracteristicas'] as Map<String, dynamic>
          : const {},
      metricasRadar: parsedRadar,
      pontosFortes: (json['strengths'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      necessidadesApoio: (json['support_needs'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      dicaAutonomia: json['autonomy_coaching_tip'] as String? ??
          json['dica_autonomia'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (resumo != null) 'profile_summary': resumo,
      'caracteristicas': caracteristicas,
      'radar_metrics': metricasRadar,
      'strengths': pontosFortes,
      'support_needs': necessidadesApoio,
      if (dicaAutonomia != null) 'autonomy_coaching_tip': dicaAutonomia,
    };
  }
}
