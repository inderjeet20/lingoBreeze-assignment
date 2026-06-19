import 'package:flutter/material.dart';
import '../../domain/entities/word_entity.dart';
import '../../domain/usecases/get_words.dart';
import '../../domain/usecases/add_word.dart';
import '../../domain/usecases/update_word.dart';
import '../../domain/usecases/delete_word.dart';

enum VocabularyStatus { initial, loading, loaded, error }

class VocabularyProvider with ChangeNotifier {
  final GetWords getWordsUseCase;
  final AddWord addWordUseCase;
  final UpdateWord updateWordUseCase;
  final DeleteWord deleteWordUseCase;

  VocabularyProvider({
    required this.getWordsUseCase,
    required this.addWordUseCase,
    required this.updateWordUseCase,
    required this.deleteWordUseCase,
  });

  List<WordEntity> _words = [];
  List<WordEntity> get words => _words;

  VocabularyStatus _status = VocabularyStatus.initial;
  VocabularyStatus get status => _status;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> initialize() async {
    await fetchWords();
  }

  Future<void> fetchWords() async {
    _status = VocabularyStatus.loading;
    _errorMessage = '';
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
        _errorMessage = '';
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
        _status = VocabularyStatus.loaded;
        _errorMessage = '';
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> updateExistingWord(
    String id,
    String word,
    String meaning,
    String translation,
  ) async {
    final result = await updateWordUseCase(id, word, meaning, translation);

    return result.fold(
      (failure) {
        _errorMessage = 'Failed to update word';
        return false;
      },
      (updatedWord) {
        final index = _words.indexWhere((word) => word.id == updatedWord.id);
        if (index == -1) {
          _words.insert(0, updatedWord);
        } else {
          _words[index] = updatedWord;
        }

        _status = VocabularyStatus.loaded;
        _errorMessage = '';
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> deleteExistingWord(String id) async {
    final result = await deleteWordUseCase(id);

    return result.fold(
      (failure) {
        _errorMessage = 'Failed to delete word';
        return false;
      },
      (_) {
        _words.removeWhere((word) => word.id == id);
        _status = VocabularyStatus.loaded;
        _errorMessage = '';
        notifyListeners();
        return true;
      },
    );
  }
}
