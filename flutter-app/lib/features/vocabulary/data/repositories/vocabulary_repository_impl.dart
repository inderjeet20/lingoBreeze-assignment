import 'package:dartz/dartz.dart';
import '../../domain/entities/word_entity.dart';
import '../../domain/repositories/vocabulary_repository.dart';
import '../datasources/remote_data_source.dart';
import '../../../../core/error/failures.dart';

class VocabularyRepositoryImpl implements VocabularyRepository {
  final RemoteDataSource remoteDataSource;

  VocabularyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<WordEntity>>> getWords() async {
    try {
      final remoteWords = await remoteDataSource.getWords();
      return Right(remoteWords);
    } on ConnectionFailure {
      return Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, WordEntity>> addWord(
    String word,
    String meaning,
    String translation,
  ) async {
    try {
      final newWord = await remoteDataSource.addWord(word, meaning, translation);
      return Right(newWord);
    } on ConnectionFailure {
      return Left(ConnectionFailure());
    } catch (e) {
      return Left(DatabaseFailure());
    }
  }
}
