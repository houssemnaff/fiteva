import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// Theme values are obtained from Theme.of(context).colorScheme
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                Text(
                  'Partage ta progression, ton workout ou ton repas.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _types
                      .map((t) {
                        final selected = _selectedType == t;
                        return ChoiceChip(
                          label: Text(t),
                          selected: selected,
                          onSelected: (_) => setState(() => _selectedType = t),
                          selectedColor: colorScheme.primaryContainer,
                          backgroundColor: colorScheme.surfaceVariant,
                          labelStyle: TextStyle(
                            color: selected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      })
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
                      color: colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.imagePlus, color: colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Ajouter une photo (démo statique)',
                            style: TextStyle(color: colorScheme.onSurfaceVariant),
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