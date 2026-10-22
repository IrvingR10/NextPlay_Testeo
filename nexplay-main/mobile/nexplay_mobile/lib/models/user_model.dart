class UserModel {
  final int idUsuario;
  final String nombreCompleto;
  final String correo;
  final String? apodo;
  final int? idAvatar;
  final int xpTotal;
  final int monedas;
  final int gemas;

  const UserModel({
    required this.idUsuario,
    required this.nombreCompleto,
    required this.correo,
    this.apodo,
    this.idAvatar,
    required this.xpTotal,
    required this.monedas,
    required this.gemas,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idUsuario: (json['idUsuario'] ?? json['id_usuario'] ?? 0) as int,
      nombreCompleto: (json['nombreCompleto'] ?? json['nombre_completo'] ?? '')
          .toString(),
      correo: (json['correo'] ?? '').toString(),
      apodo: json['apodo']?.toString(),
      idAvatar: json['idAvatar'] is int ? json['idAvatar'] : null,
      xpTotal: (json['xpTotal'] ?? json['xp_total'] ?? 0) as int,
      monedas: (json['monedas'] ?? 0) as int,
      gemas: (json['gemas'] ?? 0) as int,
    );
  }
}
