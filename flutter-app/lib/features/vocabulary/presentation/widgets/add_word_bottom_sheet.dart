import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/word_entity.dart';
import '../providers/vocabulary_provider.dart';

class AddWordBottomSheet extends StatefulWidget {
  final WordEntity? initialWord;

  const AddWordBottomSheet({super.key, this.initialWord});

  @override
  State<AddWordBottomSheet> createState() => _AddWordBottomSheetState();
}

class _AddWordBottomSheetState extends State<AddWordBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _wordController = TextEditingController();
  final _meaningController = TextEditingController();
  final _translationController = TextEditingController();
  bool _isLoading = false;

  bool get _isEditing => widget.initialWord != null;

  @override
  void initState() {
    super.initState();

    final initialWord = widget.initialWord;
    if (initialWord != null) {
      _wordController.text = initialWord.word;
      _meaningController.text = initialWord.meaning;
      _translationController.text = initialWord.translation;
    }
  }

  @override
  void dispose() {
    _wordController.dispose();
    _meaningController.dispose();
    _translationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final provider = context.read<VocabularyProvider>();
    final word = _wordController.text.trim();
    final meaning = _meaningController.text.trim();
    final translation = _translationController.text.trim();

    final success = _isEditing
        ? await provider.updateExistingWord(
            widget.initialWord!.id,
            word,
            meaning,
            translation,
          )
        : await provider.addNewWord(word, meaning, translation);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save word. Check backend connection.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isEditing ? 'Edit Word' : 'Add Word',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _wordController,
                label: 'Word',
                hint: 'e.g. Apple',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _meaningController,
                label: 'Meaning',
                hint: 'e.g. A fruit',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _translationController,
                label: 'Translation',
                hint: 'e.g. Manzana',
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _isEditing ? 'Update Word' : 'Save Word',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }
}
