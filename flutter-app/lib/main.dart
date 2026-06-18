import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';

import 'features/vocabulary/domain/usecases/get_words.dart';
import 'features/vocabulary/domain/usecases/add_word.dart';
import 'features/vocabulary/data/repositories/vocabulary_repository_impl.dart';
import 'features/vocabulary/data/datasources/remote_data_source.dart';
import 'features/vocabulary/presentation/providers/vocabulary_provider.dart';
import 'features/vocabulary/presentation/pages/vocabulary_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final httpClient = http.Client();
  final baseUrl = _resolveApiBaseUrl();
  debugPrint('Using API base URL: $baseUrl');

  final remoteDataSource = RemoteDataSourceImpl(
    client: httpClient,
    baseUrl: baseUrl,
  );

  final repository = VocabularyRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );

  final getWordsUseCase = GetWords(repository);
  final addWordUseCase = AddWord(repository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => VocabularyProvider(
            getWordsUseCase: getWordsUseCase,
            addWordUseCase: addWordUseCase,
          )..fetchWords(),
        ),
      ],
      child: const LingoBreezeApp(),
    ),
  );
}

String _resolveApiBaseUrl() {
  const apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL');
  if (apiBaseUrlOverride.isNotEmpty) {
    return apiBaseUrlOverride;
  }

  if (kIsWeb) {
    return 'http://localhost:3000';
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'http://10.0.2.2:3000';
    case TargetPlatform.iOS:
      return 'http://localhost:3000';
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
      return 'http://localhost:3000';
    case TargetPlatform.fuchsia:
      return 'http://localhost:3000';
  }
}

class LingoBreezeApp extends StatelessWidget {
  const LingoBreezeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LingoBreeze',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const VocabularyPage(),
    );
  }
}
