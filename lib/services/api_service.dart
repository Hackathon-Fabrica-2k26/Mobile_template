import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/item_model.dart';

class ApiService {
  ApiService._internal();
  static final ApiService instance = ApiService._internal();

  /// Permite sobrescrever a URL base manualmente em tempo de execução
  static String? customBaseUrl;

  /// Retorna a URL base adequada dependendo da plataforma:
  /// - Android Emulator: 10.0.2.2:8000
  /// - iOS / Web / Desktop: localhost:8000
  /// - Celular Físico: configure ApiService.customBaseUrl com o IP do seu PC
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
      // Loopback padrão do emulador Android para a máquina host
      return 'http://10.0.2.2:8000/api';
    }

    // iOS Simulator, macOS, Linux, Windows
    return 'http://localhost:8000/api';
  }

  static const Duration _timeout = Duration(seconds: 10);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      };

  /// Lista itens da API (suporta resposta paginada do DRF ou array puro)
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
        throw Exception(
            'Falha ao carregar itens: ${response.statusCode} - ${response.body}');
      }
    } on TimeoutException {
      throw Exception(
          'Tempo limite excedido ao conectar com a API ($baseUrl). O backend Django está rodando?');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro de conexão com $baseUrl: $e');
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
        throw Exception(
            'Erro ao criar item: ${response.statusCode} - ${response.body}');
      }
    } on TimeoutException {
      throw Exception('Tempo limite excedido ao criar item.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro ao criar item: $e');
    }
  }

  /// Atualiza os dados de um item existente (PATCH)
  Future<Item> updateItem(Item item) async {
    if (item.id == null) {
      throw Exception('Item sem ID para atualização.');
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
        throw Exception(
            'Erro ao atualizar item: ${response.statusCode} - ${response.body}');
      }
    } on TimeoutException {
      throw Exception('Tempo limite excedido ao atualizar item.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro ao atualizar item: $e');
    }
  }

  /// Deleta um item pelo ID
  Future<void> deleteItem(int id) async {
    final uri = Uri.parse('$baseUrl/items/$id/');
    try {
      final response =
          await http.delete(uri, headers: _headers).timeout(_timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
            'Erro ao deletar item: ${response.statusCode} - ${response.body}');
      }
    } on TimeoutException {
      throw Exception('Tempo limite excedido ao deletar item.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro ao deletar item: $e');
    }
  }
}
