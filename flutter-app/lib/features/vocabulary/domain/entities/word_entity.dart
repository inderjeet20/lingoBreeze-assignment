import 'package:equatable/equatable.dart';

class WordEntity extends Equatable {
  final String id;
  final String word;
  final String meaning;
  final String translation;

  const WordEntity({
    required this.id,
    required this.word,
    required this.meaning,
    required this.translation,
  });

  @override
  List<Object?> get props => [id, word, meaning, translation];
}
