import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/home_program_model.dart';
import '../models/user_model.dart';
import '../models/workout_model.dart';
import '../models/nutrition_model.dart';
import '../models/post_model.dart';
import '../services/program_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgresChangeEvent;
import '../services/supabase_config.dart';

class AvatarNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void increment() => state++;
}
final avatarProvider = NotifierProvider<AvatarNotifier, int>(AvatarNotifier.new);

// ─── Source unique : tous les programmes — Realtime Supabase ─────────────────
// Écoute les INSERT/UPDATE/DELETE sur la table programs en temps réel
final _allProgramsFutureProvider = StreamProvider.autoDispose<List<HomeProgramModel>>((ref) {
  final controller = StreamController<List<HomeProgramModel>>();

  // Chargement initial
  ProgramService.fetchAll()
      .then(controller.add)
      .catchError(controller.addError);

  // Abonnement Realtime — déclenche un rechargement à chaque changement
  final channel = SupabaseConfig.client
      .channel('programs_realtime')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'programs',
        callback: (_) async {
          try {
            controller.add(await ProgramService.fetchAll());
          } catch (e) {
            controller.addError(e);
          }
        },
      )
      .subscribe();

  ref.onDispose(() {
    SupabaseConfig.client.removeChannel(channel);
    controller.close();
  });

  return controller.stream;
});

// ─── Providers par catégorie (autoDispose suit le parent) ────────────────────

final homeProgramsProvider = Provider.autoDispose<List<HomeProgramModel>>((ref) {
  return ref.watch(_allProgramsFutureProvider).maybeWhen(
    data: (all) => all.where((p) => p.category == 'home').toList(),
    orElse: () => [],
  );
});

final salleProgramsProvider = Provider.autoDispose<List<HomeProgramModel>>((ref) {
  return ref.watch(_allProgramsFutureProvider).maybeWhen(
    data: (all) => all.where((p) => p.category == 'salle').toList(),
    orElse: () => [],
  );
});

final danceProgramsProvider = Provider.autoDispose<List<HomeProgramModel>>((ref) {
  return ref.watch(_allProgramsFutureProvider).maybeWhen(
    data: (all) => all.where((p) => p.category == 'dance').toList(),
    orElse: () => [],
  );
});

final recuperationProgramsProvider = Provider.autoDispose<List<HomeProgramModel>>((ref) {
  return ref.watch(_allProgramsFutureProvider).maybeWhen(
    data: (all) => all.where((p) => p.category == 'recuperation').toList(),
    orElse: () => [],
  );
});

final grossesseProgramsProvider = Provider.autoDispose<List<HomeProgramModel>>((ref) {
  return ref.watch(_allProgramsFutureProvider).maybeWhen(
    data: (all) => all.where((p) => p.category == 'grossesse').toList(),
    orElse: () => [],
  );
});

// ─── Dérivés ──────────────────────────────────────────────────────────────────

final joinedProgramsProvider = Provider.autoDispose<List<HomeProgramModel>>((ref) {
  return ref.watch(homeProgramsProvider).take(3).toList();
});

final workoutsProvider = Provider.autoDispose<List<WorkoutModel>>((ref) {
  return ref.watch(_allProgramsFutureProvider).maybeWhen(
    data: (all) => all.expand((p) => p.workouts).toList(),
    orElse: () => [],
  );
});

// ─── Body Zones (mock statique) ───────────────────────────────────────────────
final bodyZonesProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return [
    {
      'title': 'Abdos Express',
      'imageUrl': 'assets/images/strength.jpg',
      'exercises': ['Crunch basique', 'Planche dynamique', 'Russian Twists', 'Levé de jambes'],
    },
    {
      'title': 'Bas du corps',
      'imageUrl': 'assets/images/legs.jpg',
      'exercises': ['Squats', 'Fentes arrières', 'Glute Bridges', 'Soulevé de terre roumain'],
    },
    {
      'title': 'Full body HIIT',
      'imageUrl': 'assets/images/fullbody.jpg',
      'exercises': ['Burpees', 'Jumping Jacks', 'Mountain Climbers', 'High Knees'],
    },
    {
      'title': 'Haut du corps',
      'imageUrl': 'assets/images/upperbody.jpg',
      'exercises': ['Pompes', 'Dips triceps', 'Planche commando', 'Superman'],
    },
  ];
});

// ─── Nutrition (mock statique) ────────────────────────────────────────────────
final nutritionProvider = Provider<NutritionSummary>((ref) {
  return NutritionSummary(
    currentCalories: 1450,
    targetCalories: 2000,
    carbs: 180,
    protein: 120,
    fat: 45,
    meals: [
      MealModel(id: 'm1', name: 'Oatmeal & Berries', calories: 350, type: 'breakfast', time: '08:00 AM'),
      MealModel(id: 'm2', name: 'Chicken Salad', calories: 450, type: 'lunch', time: '01:00 PM'),
      MealModel(id: 'm3', name: 'Protein Shake', calories: 200, type: 'snack', time: '04:00 PM'),
      MealModel(id: 'm4', name: 'Salmon & Quinoa', calories: 450, type: 'dinner', time: '07:30 PM'),
    ],
  );
});

// ─── Community Posts (mock statique — remplacé progressivement par Supabase) ─
final postsProvider = Provider<List<PostModel>>((ref) {
  return [
    PostModel(
      id: 'p_text_1',
      username: 'Nora Fit',
      userAvatarUrl: 'https://i.pravatar.cc/150?img=33',
      content: 'Small win today: I finished my workout even with low motivation.',
      imageUrl: '',
      likes: 63,
      comments: 11,
      timeAgo: '1h ago',
      category: 'Workout',
    ),
  ];
});

// ─── Cycle (mock statique) ────────────────────────────────────────────────────
class CycleStatus {
  final String name;
  final int dayOfCycle;
  final String advice;
  CycleStatus({required this.name, required this.dayOfCycle, required this.advice});
}

final cycleProvider = Provider<CycleStatus>((ref) {
  return CycleStatus(
    name: 'Follicular',
    dayOfCycle: 8,
    advice: 'High energy phase! Great time for HIIT and challenging workouts.',
  );
});
