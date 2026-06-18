import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/word_model.dart';
import '../../../../core/error/failures.dart';

abstract class RemoteDataSource {
  Future<List<WordModel>> getWords();
  Future<WordModel> addWord(String word, String meaning, String translation);
}

class RemoteDataSourceImpl implements RemoteDataSource {
  final http.Client client;
  final String baseUrl; // E.g., http://localhost:3000

  RemoteDataSourceImpl({required this.client, required this.baseUrl});

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
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode({
          'word': word,
          'meaning': meaning,
          'translation': translation,
        }),
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
}
