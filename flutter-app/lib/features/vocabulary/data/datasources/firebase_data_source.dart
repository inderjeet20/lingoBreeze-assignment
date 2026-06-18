import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/word_model.dart';

abstract class FirebaseDataSource {
  Future<WordModel> addWord(String word, String meaning, String translation);
}

class FirebaseDataSourceImpl implements FirebaseDataSource {
  final FirebaseFirestore firestore;

  FirebaseDataSourceImpl({required this.firestore});

  @override
  Future<WordModel> addWord(
    String word,
    String meaning,
    String translation,
  ) async {
    final docRef = await firestore.collection('vocabulary').add({
      'word': word,
      'meaning': meaning,
      'translation': translation,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return WordModel(
      id: docRef.id,
      word: word,
      meaning: meaning,
      translation: translation,
    );
  }
}
