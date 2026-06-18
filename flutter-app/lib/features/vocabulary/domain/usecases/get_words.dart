import 'package:dartz/dartz.dart';
import '../entities/word_entity.dart';
import '../repositories/vocabulary_repository.dart';
import '../../../../core/error/failures.dart';

class GetWords {
  final VocabularyRepository repository;

  GetWords(this.repository);

  Future<Either<Failure, List<WordEntity>>> call() async {
    return await repository.getWords();
  }
}
