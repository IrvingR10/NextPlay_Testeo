class AchievementModel {
  final int id;
  final String nombre;
  final String descripcion;
  final String requisitos;
  final int recompensaXp;
  final int recompensaMonedas;
  final bool desbloqueado;
  final double progreso;
  final String? fechaDesbloqueo;
  final String icono;

  AchievementModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.requisitos,
    required this.recompensaXp,
    required this.recompensaMonedas,
    required this.desbloqueado,
    required this.progreso,
    this.fechaDesbloqueo,
    required this.icono,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] ?? json['idLogro'] ?? 0,
      nombre: json['nombre'] ?? json['titulo'] ?? 'Insignia Gamer',
      descripcion: json['descripcion'] ?? 'Completa este logro en NEXPLAY.',
      requisitos: json['requisitos'] ?? 'Cumple el objetivo dentro del juego.',
      recompensaXp: json['recompensaXp'] ?? json['xp'] ?? json['puntos'] ?? 250,
      recompensaMonedas: json['recompensaMonedas'] ?? json['monedas'] ?? 100,
      desbloqueado: json['desbloqueado'] ?? (json['estado'] == 'Desbloqueado') ?? false,
      progreso: (json['progreso'] is num)
          ? (json['progreso'] as num).toDouble()
          : (json['desbloqueado'] == true ? 1.0 : 0.4),
      fechaDesbloqueo: json['fechaDesbloqueo'] ?? json['fecha'],
      icono: json['icono'] ?? 'trophy',
    );
  }
}
