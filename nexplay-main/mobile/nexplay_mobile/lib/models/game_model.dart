import '../core/constants/api_constants.dart';
import 'category_model.dart';

class GameModel {
  final int id;
  final String nombre;
  final String descripcion;
  final String dificultad;
  final String imagen;
  final int maxJugadores;
  final int recompensaXpBase;
  final int recompensaMonedasBase;
  final int recompensaGemasBase;
  final List<CategoryModel> categorias;

  const GameModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.dificultad,
    required this.imagen,
    required this.maxJugadores,
    required this.recompensaXpBase,
    required this.recompensaMonedasBase,
    required this.recompensaGemasBase,
    required this.categorias,
  });

  int get categoriaId => categorias.isEmpty ? 0 : categorias.first.id;

  String? get categoriaNombre =>
      categorias.isEmpty ? null : categorias.first.nombre;

  String? get imagenUrl {
    final value = imagen.trim();

    if (value.isEmpty) return null;

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    final normalized = value.startsWith('/') ? value : '/$value';
    return '${ApiConstants.baseUrl}$normalized';
  }

  factory GameModel.fromJson(Map<String, dynamic> json) {
    final rawCategorias = json['categorias'];

    final categorias = rawCategorias is List
        ? rawCategorias
              .whereType<Map>()
              .map(
                (item) =>
                    CategoryModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
        : <CategoryModel>[];

    return GameModel(
      id: _toInt(json['idJuego'] ?? json['id']) ?? 0,
      nombre: (json['nombre'] ?? '').toString(),
      descripcion: (json['descripcion'] ?? '').toString(),
      dificultad: (json['dificultad'] ?? 'FACIL').toString(),
      imagen: (json['imagen'] ?? '').toString(),
      maxJugadores: _toInt(json['maxJugadores']) ?? 1,
      recompensaXpBase: _toInt(json['recompensaXpBase']) ?? 0,
      recompensaMonedasBase: _toInt(json['recompensaMonedasBase']) ?? 0,
      recompensaGemasBase: _toInt(json['recompensaGemasBase']) ?? 0,
      categorias: categorias,
    );
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}
