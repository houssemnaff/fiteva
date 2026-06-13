import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/mascot_widget.dart';
import '../services/storage_service.dart';

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
  MascotState build() => _fromStorage();

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
  }

  void reload() {
    state = _fromStorage();
  }
}

final mascotProvider = NotifierProvider<MascotNotifier, MascotState>(
  MascotNotifier.new,
);
