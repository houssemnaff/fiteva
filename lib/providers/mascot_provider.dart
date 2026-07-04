import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/mascot_widget.dart';
import '../services/storage_service.dart';
import '../services/supabase_config.dart';

class MascotState {
  final MascotType type;
  final MascotMood mood;

  const MascotState({
    this.type = MascotType.blob,
    this.mood = MascotMood.happy,
  });

  MascotState copyWith({MascotType? type, MascotMood? mood}) =>
      MascotState(type: type ?? this.type, mood: mood ?? this.mood);
}

class MascotNotifier extends Notifier<MascotState> {
  @override
  MascotState build() {
    final initial = _fromStorage();
    _refreshFromSupabase();
    return initial;
  }

  Future<void> _refreshFromSupabase() async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;

    try {
      final row = await SupabaseConfig.table('user_profiles')
          .select('mascot_type, mascot_mood')
          .eq('id', uid)
          .maybeSingle();
      if (row == null) return;

      final typeName = row['mascot_type'] as String? ?? state.type.name;
      final moodName = row['mascot_mood'] as String? ?? state.mood.name;
      final type = MascotType.values.firstWhere(
        (t) => t.name == typeName,
        orElse: () => state.type,
      );
      final mood = MascotMood.values.firstWhere(
        (m) => m.name == moodName,
        orElse: () => state.mood,
      );

      state = MascotState(type: type, mood: mood);
      final data = StorageService.getOnboardingData();
      data['mascot_type'] = type.name;
      data['mascot_mood'] = mood.name;
      await StorageService.saveOnboardingData(data);
    } catch (_) {}
  }

  MascotState _fromStorage() {
    final data = StorageService.getOnboardingData();
    final typeName = data['mascot_type'] as String? ?? 'blob';
    final moodName = data['mascot_mood'] as String? ?? 'happy';

    final type = MascotType.values.firstWhere(
      (t) => t.name == typeName,
      orElse: () => MascotType.blob,
    );
    final mood = MascotMood.values.firstWhere(
      (m) => m.name == moodName,
      orElse: () => MascotMood.happy,
    );
    return MascotState(type: type, mood: mood);
  }

  Future<void> update({MascotType? type, MascotMood? mood}) async {
    state = state.copyWith(type: type, mood: mood);
    final data = StorageService.getOnboardingData();
    data['mascot_type'] = state.type.name;
    data['mascot_mood'] = state.mood.name;
    await StorageService.saveOnboardingData(data);
    _syncToSupabase(state);
  }

  void _syncToSupabase(MascotState mascot) {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;

    SupabaseConfig.table('user_profiles').upsert({
      'id':          uid,
      'mascot_type': mascot.type.name,
      'mascot_mood': mascot.mood.name,
      'updated_at':  DateTime.now().toIso8601String(),
    }).catchError((e) {
      debugPrint('[Mascot] Supabase sync error: $e');
    });
  }

  void reload() {
    state = _fromStorage();
  }
}

final mascotProvider = NotifierProvider<MascotNotifier, MascotState>(
  MascotNotifier.new,
);
