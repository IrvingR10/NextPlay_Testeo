import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import '../models/user_model.dart';

class ApiConnectionException implements Exception {
  const ApiConnectionException(this.message);

  final String message;

  @override
  String toString() => message;
}

class UserService {
  Future<UserModel> getUserById(int userId) async {
    late final http.Response response;

    try {
      response = await http
          .get(
            Uri.parse(
              '${ApiConstants.baseUrl}'
              '${ApiConstants.usersEndpoint}/$userId',
            ),
          )
          .timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw const ApiConnectionException(
        'La conexión tardó demasiado. Revisa tu red e inténtalo nuevamente.',
      );
    } on http.ClientException {
      throw const ApiConnectionException(
        'No pudimos conectar con NEXPLAY. Revisa tu conexión e inténtalo nuevamente.',
      );
    } catch (_) {
      throw const ApiConnectionException(
        'No pudimos conectar con NEXPLAY. Revisa tu conexión e inténtalo nuevamente.',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        return UserModel.fromJson(data);
      }

      throw Exception('Respuesta de usuario inválida.');
    }

    throw Exception('No se pudo cargar el usuario.');
  }

  Future<UserModel> createUser({
    required String nombreCompleto,
    required String correo,
    required String password,
    String? apodo,
    int? idAvatar,
  }) async {
    final normalizedApodo = apodo?.trim();

    final payload = <String, dynamic>{
      'nombreCompleto': nombreCompleto,
      'correo': correo,
      'password': password,
    };

    if (normalizedApodo != null && normalizedApodo.isNotEmpty) {
      payload['apodo'] = normalizedApodo;
    }

    if (idAvatar != null) {
      payload['idAvatar'] = idAvatar;
    }

    late final http.Response response;

    try {
      response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.usersEndpoint}'),
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw const ApiConnectionException(
        'No pudimos conectar con el servidor NEXPLAY. Inténtalo nuevamente.',
      );
    } on http.ClientException {
      throw const ApiConnectionException(
        'No pudimos conectar con el servidor NEXPLAY. Inténtalo nuevamente.',
      );
    } catch (_) {
      throw const ApiConnectionException(
        'No pudimos conectar con el servidor NEXPLAY. Inténtalo nuevamente.',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      final userJson = data['usuario'] ?? data;

      return UserModel.fromJson(userJson);
    }

    final errorBody = jsonDecode(response.body);

    final message = errorBody is Map<String, dynamic>
        ? (errorBody['mensaje'] ?? 'No se pudo crear el usuario.')
        : 'No se pudo crear el usuario.';

    throw Exception(message);
  }

  Future<UserModel> updateUser({
    required int userId,
    required String nombreCompleto,
    String? apodo,
    int? idAvatar,
  }) async {
    final normalizedApodo = apodo?.trim();

    final payload = <String, dynamic>{'nombreCompleto': nombreCompleto};

    if (normalizedApodo != null && normalizedApodo.isNotEmpty) {
      payload['apodo'] = normalizedApodo;
    }

    if (idAvatar != null) {
      payload['idAvatar'] = idAvatar;
    }

    late final http.Response response;

    try {
      response = await http
          .put(
            Uri.parse(
              '${ApiConstants.baseUrl}'
              '${ApiConstants.usersEndpoint}/$userId',
            ),
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw const ApiConnectionException(
        'La conexión tardó demasiado. Revisa tu red e inténtalo nuevamente.',
      );
    } on http.ClientException {
      throw const ApiConnectionException(
        'No pudimos conectar con NEXPLAY. Revisa tu conexión e inténtalo nuevamente.',
      );
    } catch (_) {
      throw const ApiConnectionException(
        'No pudimos conectar con NEXPLAY. Revisa tu conexión e inténtalo nuevamente.',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      final userJson = data['usuario'] ?? data;

      return UserModel.fromJson(userJson);
    }

    final errorBody = jsonDecode(response.body);

    final message = errorBody is Map<String, dynamic>
        ? (errorBody['mensaje'] ?? 'No se pudo actualizar el usuario.')
        : 'No se pudo actualizar el usuario.';

    throw Exception(message);
  }
}
