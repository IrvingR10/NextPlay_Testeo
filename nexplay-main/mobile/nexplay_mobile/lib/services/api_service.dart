import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/api_constants.dart';
import '../models/category_model.dart';
import '../models/game_model.dart';
import '../models/achievement_model.dart';
import '../models/challenge_model.dart';
import '../models/ranking_user_model.dart';

class ApiService {
  static Future<Map<String, dynamic>> login(
    String correo,
    String contrasena,
  ) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}',
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'correo': correo, 'password': contrasena}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final prefs = await SharedPreferences.getInstance();

        if (data['token'] != null) {
          await prefs.setString('auth_token', data['token'].toString());
        }

        final rawUsuario = data['usuario'];

        if (rawUsuario is Map) {
          final usuario = Map<String, dynamic>.from(rawUsuario);
          final rawUserId =
              usuario['idUsuario'] ??
              usuario['id_usuario'] ??
              usuario['id'] ??
              usuario['usuarioId'];

          if (rawUserId != null) {
            final userId = rawUserId is int
                ? rawUserId
                : int.tryParse(rawUserId.toString());

            if (userId != null) {
              await prefs.setInt('user_id', userId);
            }
          }
        }

        return {'success': true, 'data': data};
      }

      final errorBody = response.body;

      return {
        'success': false,
        'message': errorBody.isNotEmpty ? errorBody : 'Credenciales invÃ¡lidas',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error de conexiÃ³n: $e'};
    }
  }

  static Future<List<GameModel>> getJuegos() async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.juegosEndpoint}',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);

        return body.map((item) => GameModel.fromJson(item)).toList();
      }

      throw Exception('Error al cargar juegos: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error de conexiÃ³n: $e');
    }
  }

  static Future<List<CategoryModel>> getCategorias() async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.categoriasEndpoint}',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);

        return body.map((item) => CategoryModel.fromJson(item)).toList();
      }

      throw Exception('Error al cargar categorÃ­as: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error de conexiÃ³n: $e');
    }
  }

  static Future<List<GameModel>> getJuegosPorCategoria(int categoriaId) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}'
      '${ApiConstants.categoriasEndpoint}'
      '/$categoriaId/juegos',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);

        return body.map((item) => GameModel.fromJson(item)).toList();
      }

      throw Exception(
        'Error al cargar juegos de la categorÃ­a: '
        '${response.statusCode}',
      );
    } catch (e) {
      throw Exception('Error de conexiÃ³n: $e');
    }
  }

  static Future<List<ChallengeModel>> getRetos() async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.retosEndpoint}',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => ChallengeModel.fromJson(item)).toList();
      }

      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<List<AchievementModel>> getLogros() async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.logrosEndpoint}',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => AchievementModel.fromJson(item)).toList();
      }

      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<List<RankingUserModel>> getRankingGlobal() async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.rankingGlobalEndpoint}',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);

        return body
            .asMap()
            .entries
            .map(
              (entry) =>
                  RankingUserModel.fromJson(entry.value, index: entry.key),
            )
            .toList();
      }

      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<List<RankingUserModel>> getRankingSemanal() async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.rankingSemanalEndpoint}',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);

        return body
            .asMap()
            .entries
            .map(
              (entry) =>
                  RankingUserModel.fromJson(entry.value, index: entry.key),
            )
            .toList();
      }

      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<List<RankingUserModel>> getRankingMensual() async {
    return [];
  }
}
