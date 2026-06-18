import 'package:flutter/material.dart';
import '../../domain/entities/word_entity.dart';
import '../../domain/usecases/get_words.dart';
import '../../domain/usecases/add_word.dart';

enum VocabularyStatus { initial, loading, loaded, error }

class VocabularyProvider with ChangeNotifier {
  final GetWords getWordsUseCase;
  final AddWord addWordUseCase;

  VocabularyProvider({
    required this.getWordsUseCase,
    required this.addWordUseCase,
  });

  List<WordEntity> _words = [];
  List<WordEntity> get words => _words;

  VocabularyStatus _status = VocabularyStatus.initial;
  VocabularyStatus get status => _status;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> fetchWords() async {
    _status = VocabularyStatus.loading;
    notifyListeners();

    final result = await getWordsUseCase();

    result.fold(
      (failure) {
        _status = VocabularyStatus.error;
        _errorMessage = 'Failed to fetch words. Please check your connection.';
      },
      (words) {
        _status = VocabularyStatus.loaded;
        _words = words;
      },
    );

    notifyListeners();
  }

  Future<bool> addNewWord(
    String word,
    String meaning,
    String translation,
  ) async {
    final result = await addWordUseCase(word, meaning, translation);

    return result.fold(
      (failure) {
        _errorMessage = 'Failed to add word';
        return false;
      },
      (newWord) {
        _words.insert(0, newWord);
        notifyListeners();
        return true;
      },
    );
  }
}
