import 'package:dartz/dartz.dart';
import '../entities/word_entity.dart';
import '../repositories/vocabulary_repository.dart';
import '../../../../core/error/failures.dart';

class AddWord {
  final VocabularyRepository repository;

  AddWord(this.repository);

  Future<Either<Failure, WordEntity>> call(
    String word,
    String meaning,
    String translation,
  ) async {
    return await repository.addWord(word, meaning, translation);
  }
}
