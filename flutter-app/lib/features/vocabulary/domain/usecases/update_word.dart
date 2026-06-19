import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/word_entity.dart';
import '../repositories/vocabulary_repository.dart';

class UpdateWord {
  final VocabularyRepository repository;

  UpdateWord(this.repository);

  Future<Either<Failure, WordEntity>> call(
    String id,
    String word,
    String meaning,
    String translation,
  ) async {
    return await repository.updateWord(id, word, meaning, translation);
  }
}
