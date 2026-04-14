import 'package:flutter/material.dart';
import 'package:fluttermoji/fluttermoji.dart';

import '../../../theme/app_theme.dart';

class StepWelcome extends StatelessWidget {
  final VoidCallback onNext;

  const StepWelcome({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Bienvenue sur fitana.',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'Votre compagnon bien-etre et cycle menstruel.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              child: const Text(
                'Commencer',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StepAvatar extends StatelessWidget {
  final VoidCallback onNext;

  const StepAvatar({
    super.key,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Choisissez votre avatar',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          FluttermojiCircleAvatar(
            radius: 56,
            backgroundColor: Colors.grey.shade200,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: FluttermojiCustomizer(
              scaffoldWidth: MediaQuery.of(context).size.width,
              scaffoldHeight: MediaQuery.of(context).size.height * 0.42,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              child: const Text('Suivant'),
            ),
          ),
        ],
      ),
    );
  }
}

class StepName extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback onNext;

  const StepName({
    super.key,
    required this.controller,
    this.onChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final hasName = controller.text.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Comment vous appelez-vous ?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: const InputDecoration(
              labelText: 'Prenom',
              border: OutlineInputBorder(),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: hasName ? onNext : null,
              child: const Text('Suivant'),
            ),
          ),
        ],
      ),
    );
  }
}

class StepGoals extends StatelessWidget {
  final List<String> selectedGoals;
  final ValueChanged<String> onToggleGoal;
  final VoidCallback onNext;

  const StepGoals({
    super.key,
    required this.selectedGoals,
    required this.onToggleGoal,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    const options = [
      'Perte de poids',
      'Prise de muscle',
      'Sante hormonale',
      'Endurance',
    ];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Quels sont vos objectifs ?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: options.map((option) {
              final selected = selectedGoals.contains(option);
              return ChoiceChip(
                label: Text(option),
                selected: selected,
                onSelected: (_) => onToggleGoal(option),
              );
            }).toList(),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedGoals.isNotEmpty ? onNext : null,
              child: const Text('Suivant'),
            ),
          ),
        ],
      ),
    );
  }
}

class StepFitnessLevel extends StatelessWidget {
  final String? selectedLevel;
  final ValueChanged<String> onChanged;
  final VoidCallback onNext;

  const StepFitnessLevel({
    super.key,
    required this.selectedLevel,
    required this.onChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    const options = ['Debutant', 'Intermediaire', 'Avance'];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Quel est votre niveau ?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          Column(
            children: options
                .map(
                  (option) => RadioListTile<String>(
                    title: Text(option),
                    value: option,
                    groupValue: selectedLevel,
                    onChanged: (value) {
                      if (value != null) {
                        onChanged(value);
                      }
                    },
                  ),
                )
                .toList(),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedLevel != null && selectedLevel!.isNotEmpty ? onNext : null,
              child: const Text('Suivant'),
            ),
          ),
        ],
      ),
    );
  }
}

class StepEquipment extends StatelessWidget {
  final List<String> selectedEquipment;
  final ValueChanged<String> onToggleEquipment;
  final VoidCallback onNext;

  const StepEquipment({
    super.key,
    required this.selectedEquipment,
    required this.onToggleEquipment,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    const options = ['Aucun', 'Halteres', 'Bandes elastiques', 'Tapis'];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Quel equipement avez-vous ?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          Column(
            children: options.map((option) {
              final selected = selectedEquipment.contains(option);
              return CheckboxListTile(
                title: Text(option),
                value: selected,
                onChanged: (_) => onToggleEquipment(option),
              );
            }).toList(),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedEquipment.isNotEmpty ? onNext : null,
              child: const Text('Suivant'),
            ),
          ),
        ],
      ),
    );
  }
}

class StepCycle extends StatelessWidget {
  final String? selectedCycle;
  final ValueChanged<String> onChanged;
  final VoidCallback onNext;

  const StepCycle({
    super.key,
    required this.selectedCycle,
    required this.onChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    const options = ['Regulier', 'Irregulier', 'Tracking plus tard', 'Prefer not to say'];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Suivi du cycle',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Configurons votre suivi de cycle.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: options
                .map(
                  (option) => ChoiceChip(
                    label: Text(option),
                    selected: selectedCycle == option,
                    onSelected: (_) => onChanged(option),
                  ),
                )
                .toList(),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedCycle != null && selectedCycle!.isNotEmpty ? onNext : null,
              child: const Text('Terminer !'),
            ),
          ),
        ],
      ),
    );
  }
}

