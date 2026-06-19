import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/word_model.dart';
import '../../../../core/error/failures.dart';

abstract class RemoteDataSource {
  Future<List<WordModel>> getWords();
  Future<WordModel> addWord(String word, String meaning, String translation);
  Future<WordModel> updateWord(
    String id,
    String word,
    String meaning,
    String translation,
  );
  Future<void> deleteWord(String id);
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final http.Client client;
  final String baseUrl; // E.g., http://localhost:3000

  RemoteDataSourceImpl({required this.client, required this.baseUrl});

  Map<String, String> get _jsonHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  @override
  Future<List<WordModel>> getWords() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/words'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw ServerFailure();
      }

      final decoded = json.decode(response.body);
      if (decoded is! List) {
        throw ServerFailure();
      }

      return decoded
          .map((word) => WordModel.fromJson(word as Map<String, dynamic>))
          .toList();
    } on ServerFailure {
      rethrow;
    } catch (_) {
      throw ConnectionFailure();
    }
  }

  @override
  Future<WordModel> addWord(
    String word,
    String meaning,
    String translation,
  ) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/words'),
        headers: _jsonHeaders,
        body: _encodeWordBody(word, meaning, translation),
      );

      if (response.statusCode != 201) {
        throw ServerFailure();
      }

      final decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw ServerFailure();
      }

      return WordModel.fromJson(decoded);
    } on ServerFailure {
      rethrow;
    } catch (_) {
      throw ConnectionFailure();
    }
  }

  @override
  Future<WordModel> updateWord(
    String id,
    String word,
    String meaning,
    String translation,
  ) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/words/$id'),
        headers: _jsonHeaders,
        body: _encodeWordBody(word, meaning, translation),
      );

      if (response.statusCode != 200) {
        throw ServerFailure();
      }

      final decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw ServerFailure();
      }

      return WordModel.fromJson(decoded);
    } on ServerFailure {
      rethrow;
    } catch (_) {
      throw ConnectionFailure();
    }
  }

  @override
  Future<void> deleteWord(String id) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/words/$id'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode != 204) {
        throw ServerFailure();
      }
    } on ServerFailure {
      rethrow;
    } catch (_) {
      throw ConnectionFailure();
    }
  }

  String _encodeWordBody(String word, String meaning, String translation) {
    return json.encode({
      'word': word,
      'meaning': meaning,
      'translation': translation,
    });
  }
}
