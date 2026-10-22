import 'package:flutter/foundation.dart';

import '../core/constants/api_constants.dart';

class AvatarModel {
  final int idAvatar;
  final String nombre;
  final String imagen;

  const AvatarModel({
    required this.idAvatar,
    required this.nombre,
    required this.imagen,
  });

  factory AvatarModel.fromJson(Map<String, dynamic> json) {
    return AvatarModel(
      idAvatar: (json['idAvatar'] ?? json['id_avatar'] ?? 0) as int,
      nombre: (json['nombre'] ?? '').toString(),
      imagen: (json['imagen'] ?? '').toString(),
    );
  }

  String get resolvedImageUrl {
    final trimmed = imagen.trim();
    debugPrint('Avatar path: $imagen');

    if (trimmed.isEmpty) {
      debugPrint('Avatar URL final: ');
      return '';
    }

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      debugPrint('Avatar URL final: $trimmed');
      return trimmed;
    }

    final normalizedPath = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    final resolvedUrl = '${ApiConstants.baseUrl}$normalizedPath';
    debugPrint('Avatar URL final: $resolvedUrl');

    return resolvedUrl;
  }
}
