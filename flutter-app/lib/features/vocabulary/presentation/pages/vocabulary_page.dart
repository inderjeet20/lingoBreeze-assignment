import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/word_entity.dart';
import '../providers/vocabulary_provider.dart';
import '../widgets/word_card.dart';
import '../widgets/add_word_bottom_sheet.dart';

class VocabularyPage extends StatelessWidget {
  const VocabularyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F4),
      appBar: AppBar(
        title: const Text(
          'My Vocabulary',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF7F7F4),
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: Consumer<VocabularyProvider>(
          builder: (context, provider, child) {
            if (provider.status == VocabularyStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.status == VocabularyStatus.error) {
              return _EmptyOrErrorState(
                icon: Icons.error_outline,
                title: 'Couldn\'t load vocabulary',
                message: provider.errorMessage,
                actionLabel: 'Try again',
                actionIcon: Icons.refresh,
                onAction: () => provider.fetchWords(),
              );
            }

            if (provider.words.isEmpty) {
              return _EmptyOrErrorState(
                icon: Icons.add_circle_outline,
                title: 'You haven\'t saved any words yet.',
                message:
                    'Create your first vocabulary entry when you are ready.',
                actionLabel: 'Add Your First Word',
                actionIcon: Icons.add,
                onAction: () => _showAddWordSheet(context),
              );
            }

            return RefreshIndicator(
              onRefresh: () => provider.fetchWords(),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                itemCount: provider.words.length,
                itemBuilder: (context, index) {
                  final word = provider.words[index];
                  return WordCard(
                    word: word,
                    onEdit: () => _showAddWordSheet(context, word),
                    onDelete: () => _confirmDelete(context, word.id),
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        onPressed: () => _showAddWordSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddWordSheet(BuildContext context, [WordEntity? word]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddWordBottomSheet(initialWord: word),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String wordId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete word?'),
        content: const Text('This will remove the word from your vocabulary.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) return;

    final success = await context.read<VocabularyProvider>().deleteExistingWord(
      wordId,
    );

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete word. Check backend connection.'),
        ),
      );
    }
  }
}

class _EmptyOrErrorState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback onAction;

  const _EmptyOrErrorState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(icon, size: 40, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: Icon(actionIcon),
              label: Text(actionLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
