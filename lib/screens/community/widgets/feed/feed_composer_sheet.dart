import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../theme/app_theme.dart';
import '../shared/community_shared_widgets.dart';

class FeedComposerSheet extends StatefulWidget {
  const FeedComposerSheet({super.key});

  @override
  State<FeedComposerSheet> createState() => _FeedComposerSheetState();
}

class _FeedComposerSheetState extends State<FeedComposerSheet> {
  final _titleCtrl = TextEditingController();
  final _textCtrl = TextEditingController();
  String _selectedType = 'Texte';

  static const _types = ['Texte', 'Photo', 'Avant/Après'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SheetHandle(),
                const SizedBox(height: 18),
                Text(
                  'Créer un post 🔥',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Partage ta progression, ton workout ou ton repas.',
                  style: TextStyle(color: AppTheme.textSecondaryColor),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _types
                      .map((t) => ChoiceChip(
                            label: Text(t),
                            selected: _selectedType == t,
                            onSelected: (_) =>
                                setState(() => _selectedType = t),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Titre',
                    hintText: 'Day 5 challenge FitEva 🔥',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _textCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: _selectedType == 'Photo'
                        ? 'Caption'
                        : _selectedType == 'Avant/Après'
                            ? 'Décris ta transformation'
                            : 'Ton post',
                    hintText: 'Partage quelque chose d\'inspirant…',
                  ),
                ),
                if (_selectedType != 'Texte') ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FC),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(LucideIcons.imagePlus,
                            color: AppTheme.primaryColor),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Ajouter une photo (démo statique)',
                            style: TextStyle(
                                color: AppTheme.textSecondaryColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Annuler'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Post publié ! 🎉')),
                          );
                        },
                        child: const Text('Publier'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}