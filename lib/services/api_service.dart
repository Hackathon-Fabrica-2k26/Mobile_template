import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/item_model.dart';

/// Exceção com mensagem amigável para exibição direta ao usuário
class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  ApiService._internal();
  static final ApiService instance = ApiService._internal();

  /// Permite sobrescrever a URL base manualmente (ex: em desenvolvimento)
  static String? customBaseUrl;

  /// Retorna a URL base adequada dependendo da plataforma
  static String get baseUrl {
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      return customBaseUrl!.endsWith('/')
          ? customBaseUrl!.substring(0, customBaseUrl!.length - 1)
          : customBaseUrl!;
    }

    if (kIsWeb) {
      return 'http://localhost:8000/api';
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    }

    return 'http://localhost:8000/api';
  }

  static const Duration _timeout = Duration(seconds: 10);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      };

  AppException _handleError(Object error, [String defaultMessage = 'Não foi possível completar a operação. Tente novamente.']) {
    debugPrint('[ApiService Error Técnico]: $error');

    if (error is TimeoutException) {
      return const AppException(
        'O servidor demorou muito para responder. Verifique sua conexão e tente novamente.',
      );
    }

    final errStr = error.toString().toLowerCase();
    if (errStr.contains('socketexception') ||
        errStr.contains('connection refused') ||
        errStr.contains('clientexception') ||
        errStr.contains('failed host lookup') ||
        errStr.contains('network is unreachable')) {
      return const AppException(
        'Não foi possível conectar ao servidor. Verifique sua conexão com a internet e tente novamente.',
      );
    }

    if (error is AppException) {
      return error;
    }

    return AppException(defaultMessage);
  }

  /// Lista itens da API
  Future<List<Item>> getItems() async {
    final uri = Uri.parse('$baseUrl/items/');
    try {
      final response = await http.get(uri, headers: _headers).timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));

        if (decoded is Map<String, dynamic> && decoded.containsKey('results')) {
          final results = decoded['results'] as List<dynamic>;
          return results
              .map((e) => Item.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (decoded is List) {
          return decoded
              .map((e) => Item.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          return [];
        }
      } else {
        debugPrint('[ApiService Response Status]: ${response.statusCode} - ${response.body}');
        throw const AppException(
          'O serviço está temporariamente indisponível. Tente novamente mais tarde.',
        );
      }
    } catch (e) {
      throw _handleError(e, 'Não foi possível carregar os dados no momento.');
    }
  }

  /// Cria um novo item
  Future<Item> createItem({
    required String title,
    String description = '',
    bool done = false,
  }) async {
    final uri = Uri.parse('$baseUrl/items/');
    try {
      final response = await http
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({
              'title': title,
              'description': description,
              'done': done,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return Item.fromJson(decoded);
      } else {
        debugPrint('[ApiService Response Status]: ${response.statusCode} - ${response.body}');
        throw const AppException(
          'Não foi possível salvar o item. Tente novamente em alguns instantes.',
        );
      }
    } catch (e) {
      throw _handleError(e, 'Não foi possível salvar o item. Tente novamente.');
    }
  }

  /// Atualiza os dados de um item existente (PATCH)
  Future<Item> updateItem(Item item) async {
    if (item.id == null) {
      throw const AppException('Item inválido para atualização.');
    }

    final uri = Uri.parse('$baseUrl/items/${item.id}/');
    try {
      final response = await http
          .patch(
            uri,
            headers: _headers,
            body: jsonEncode({
              'title': item.title,
              'description': item.description,
              'done': item.done,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded =
            jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return Item.fromJson(decoded);
      } else {
        debugPrint('[ApiService Response Status]: ${response.statusCode} - ${response.body}');
        throw const AppException(
          'Não foi possível atualizar o item. Tente novamente mais tarde.',
        );
      }
    } catch (e) {
      throw _handleError(e, 'Não foi possível atualizar o item. Tente novamente.');
    }
  }

  /// Deleta um item pelo ID
  Future<void> deleteItem(int id) async {
    final uri = Uri.parse('$baseUrl/items/$id/');
    try {
      final response =
          await http.delete(uri, headers: _headers).timeout(_timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('[ApiService Response Status]: ${response.statusCode} - ${response.body}');
        throw const AppException(
          'Não foi possível excluir o item. Tente novamente mais tarde.',
        );
      }
    } catch (e) {
      throw _handleError(e, 'Não foi possível excluir o item. Tente novamente.');
    }
  }
}
