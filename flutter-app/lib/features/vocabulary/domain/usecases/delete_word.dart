import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/vocabulary_repository.dart';

class DeleteWord {
  final VocabularyRepository repository;

  DeleteWord(this.repository);

  Future<Either<Failure, Unit>> call(String id) async {
    return await repository.deleteWord(id);
  }
}
