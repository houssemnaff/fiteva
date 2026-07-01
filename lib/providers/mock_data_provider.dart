import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/home_program_model.dart';
import '../models/user_model.dart';
import '../models/workout_model.dart';

import '../services/program_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgresChangeEvent;
import '../services/supabase_config.dart';
import 'user_profile_provider.dart';

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

// ─── Tous les programmes (accès public pour d'autres providers) ──────────────

final allProgramsProvider = Provider.autoDispose<List<HomeProgramModel>>((ref) {
  return ref.watch(_allProgramsFutureProvider).maybeWhen(
    data: (all) => all,
    orElse: () => [],
  );
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

// ─── Body Zones ───────────────────────────────────────────────────────────────
const _mockBodyZones = <Map<String, dynamic>>[
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

final bodyZonesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final rows = await SupabaseConfig.table('body_zones')
        .select()
        .order('sort_order', ascending: true) as List;
    if (rows.isEmpty) return _mockBodyZones;
    return rows.cast<Map<String, dynamic>>().map((r) => <String, dynamic>{
      'title':     r['title'] as String? ?? '',
      'imageUrl':  r['image_url'] as String? ?? '',
      'exercises': List<String>.from(r['exercises'] as List? ?? []),
    }).toList();
  } catch (_) {
    return _mockBodyZones;
  }
});


// ─── Cycle (calculé depuis le profil Supabase) ────────────────────────────────
class CycleStatus {
  final String name;
  final int dayOfCycle;
  final String advice;
  CycleStatus({required this.name, required this.dayOfCycle, required this.advice});
}

final cycleProvider = Provider<CycleStatus>((ref) {
  final profile = ref.watch(userProfileProvider);
  final today = DateTime.now();

  // Calcule le jour du cycle depuis lastPeriod (déjà en Supabase)
  final last = profile.lastPeriod;
  final totalDays = profile.cycleDays;
  final int currentDay;
  if (last == null) {
    currentDay = 1;
  } else {
    final raw = today.difference(last).inDays % totalDays + 1;
    currentDay = raw.clamp(1, totalDays);
  }

  // Phase + conseil selon le jour
  final String name;
  final String advice;
  if (currentDay <= 5) {
    name = 'Règles';
    advice = 'Corps au repos · Privilégie la récupération et les mouvements doux.';
  } else if (currentDay <= 13) {
    name = 'Folliculaire';
    advice = 'Énergie en hausse · Idéal pour les entraînements intensifs et nouveaux défis.';
  } else if (currentDay <= 16) {
    name = 'Ovulation';
    advice = 'Pic d\'énergie · Excellente période pour le HIIT et les performances maximales.';
  } else {
    name = 'Lutéale';
    advice = 'Corps se prépare · Écoute tes besoins, privilégie le yoga et la mobilité.';
  }

  return CycleStatus(name: name, dayOfCycle: currentDay, advice: advice);
});
