class ChallengeModel {
  final int id;
  final String titulo;
  final String descripcion;
  final int recompensaXp;
  final int recompensaMonedas;
  final String dificultad;
  final bool completado;
  final double progreso;
  final String tipo;

  ChallengeModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.recompensaXp,
    required this.recompensaMonedas,
    required this.dificultad,
    required this.completado,
    required this.progreso,
    required this.tipo,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      id: json['id'] ?? json['idReto'] ?? 0,
      titulo: json['titulo'] ?? json['nombre'] ?? json['tituloReto'] ?? 'Desafío Gamer',
      descripcion: json['descripcion'] ?? 'Completa este reto para ganar recompensas.',
      recompensaXp: json['recompensaXp'] ?? json['xp'] ?? json['puntos'] ?? 150,
      recompensaMonedas: json['recompensaMonedas'] ?? json['monedas'] ?? 50,
      dificultad: json['dificultad'] ?? 'Normal',
      completado: json['completado'] ?? (json['estado'] == 'Completado') ?? false,
      progreso: (json['progreso'] is num)
          ? (json['progreso'] as num).toDouble()
          : (json['completado'] == true ? 1.0 : 0.5),
      tipo: json['tipo'] ?? json['categoria'] ?? 'Diario',
    );
  }
}
