import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import '../models/avatar_model.dart';
import 'user_service.dart';

class AvatarService {
  Future<List<AvatarModel>> getAvatars() async {
    late final http.Response response;
    try {
      response = await http
          .get(
            Uri.parse('${ApiConstants.baseUrl}${ApiConstants.avatarsEndpoint}'),
          )
          .timeout(const Duration(seconds: 8));
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
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded
            .map((item) => AvatarModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return const [];
    }

    throw Exception('No se pudieron cargar los avatares.');
  }
}
