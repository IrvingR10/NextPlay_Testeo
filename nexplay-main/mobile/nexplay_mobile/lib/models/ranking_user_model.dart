class RankingUserModel {
  final int id;
  final String username;
  final String? avatarUrl;
  final int puntos;
  final int posicion;
  final String tendencia; // 'up', 'down', 'same'
  final bool isCurrentUser;
  final int? puntosParaSiguientePuesto;
  final List<String> logrosDestacados;
  final String rangoGamer;

  RankingUserModel({
    required this.id,
    required this.username,
    this.avatarUrl,
    required this.puntos,
    required this.posicion,
    this.tendencia = 'same',
    this.isCurrentUser = false,
    this.puntosParaSiguientePuesto,
    this.logrosDestacados = const [],
    this.rangoGamer = 'Gamer NEXPLAY',
  });

  factory RankingUserModel.fromJson(Map<String, dynamic> json, {int index = 0, int currentUserId = -1}) {
    final userId = json['id'] ?? json['usuarioId'] ?? json['idUsuario'] ?? 0;
    final pos = json['posicion'] ?? json['rank'] ?? (index + 1);
    return RankingUserModel(
      id: userId,
      username: json['username'] ?? json['apodo'] ?? json['nombre'] ?? json['nombreUsuario'] ?? 'GamerNEX',
      avatarUrl: json['avatarUrl'] ?? json['urlAvatar'] ?? json['avatar']?['urlImagen'],
      puntos: json['puntos'] ?? json['puntaje'] ?? json['totalPuntos'] ?? json['xp'] ?? 0,
      posicion: pos,
      tendencia: json['tendencia'] ?? 'same',
      isCurrentUser: userId == currentUserId,
      puntosParaSiguientePuesto: json['puntosFaltantes'] ?? (pos > 1 ? 850 : null),
      logrosDestacados: (json['logros'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          ['Campeón Invicto', 'Velocista Estratégico', 'Primer Paso Gamer'],
      rangoGamer: pos == 1 ? 'LEYENDA SUPREMA' : (pos <= 3 ? 'MAESTRO ELITE' : 'COMPETIDOR PRO'),
    );
  }
}
