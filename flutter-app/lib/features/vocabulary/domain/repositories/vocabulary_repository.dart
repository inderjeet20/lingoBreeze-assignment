import 'package:dartz/dartz.dart';
import '../entities/word_entity.dart';
import '../../../../core/error/failures.dart';

abstract class VocabularyRepository {
  Future<Either<Failure, List<WordEntity>>> getWords();
  Future<Either<Failure, WordEntity>> addWord(
    String word,
    String meaning,
    String translation,
  );
  Future<Either<Failure, WordEntity>> updateWord(
    String id,
    String word,
    String meaning,
    String translation,
  );
  Future<Either<Failure, Unit>> deleteWord(String id);
}
