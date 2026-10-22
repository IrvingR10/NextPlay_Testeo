class CategoryModel {
  final int id;
  final String nombre;

  CategoryModel({
    required this.id,
    required this.nombre,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? json['idCategoria'] ?? 0,
      nombre: json['nombre'] ?? '',
    );
  }
}
