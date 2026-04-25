import 'package:fiteva/services/step_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pedometer/pedometer.dart';

final stepServiceProvider = FutureProvider<StepService>((ref) async {
  final service = StepService();
  await service.initialize();
  return service;
});

/// Stream provider for step count updates
final stepCountStreamProvider = StreamProvider<StepCount>((ref) async* {
  final service = await ref.watch(stepServiceProvider.future);
  final stream = service.getStepStream();
  
  await for (final stepCount in stream) {
    service.onStepEvent(stepCount);
    yield stepCount;
  }
});

/// Provider for steps today
final stepsTodayProvider = FutureProvider<int>((ref) async {
  final service = await ref.watch(stepServiceProvider.future);
  
  // Listen to stream updates
  await ref.watch(stepCountStreamProvider.future);
  
  return service.getStepsToday();
});

/// Provider for formatted steps today
final formattedStepsTodayProvider = FutureProvider<String>((ref) async {
  final stepsToday = await ref.watch(stepsTodayProvider.future);
  return StepService.formatNumber(stepsToday);
});

/// Provider for step progress (0.0 to 1.0)
final stepProgressProvider = FutureProvider<double>((ref) async {
  final stepsToday = await ref.watch(stepsTodayProvider.future);
  const goalSteps = 10000;
  return (stepsToday / goalSteps).clamp(0.0, 1.0);
});
