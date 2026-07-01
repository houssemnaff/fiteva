import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_config.dart';
import '../screens/cycle/pregnancy/daily_insight_model.dart';
import '../screens/cycle/pregnancy/PregnancyInsightRepository.dart';
import '../screens/cycle/pregnancy/checklist/pregnancy_checklist_repository.dart';
import '../screens/cycle/pregnancy/baby-story/baby_story.dart';
import '../screens/cycle/pregnancy/baby-story/baby_story_repository.dart';
import '../screens/cycle/pregnancy/postpartum/postpartum_insight_repository.dart';

// ── Pregnancy insights ────────────────────────────────────────────────────────

final pregnancyInsightProvider =
    FutureProvider.family<DailyInsight, int>((ref, week) async {
  try {
    final row = await SupabaseConfig.table('pregnancy_insights')
        .select()
        .eq('week', week)
        .maybeSingle();
    if (row == null) return PregnancyInsightRepository.forWeek(week);
    return DailyInsight(
      week:        row['week'] as int,
      title:       row['title'] as String? ?? '',
      babyInsight: row['baby_insight'] as String? ?? '',
      momTip:      row['mom_tip'] as String? ?? '',
      poeticLine:  row['poetic_line'] as String? ?? '',
    );
  } catch (_) {
    return PregnancyInsightRepository.forWeek(week);
  }
});

// ── Pregnancy checklist ───────────────────────────────────────────────────────

final pregnancyChecklistProvider =
    FutureProvider.family<List<ChecklistTask>, int>((ref, week) async {
  try {
    final rows = await SupabaseConfig.table('pregnancy_checklist')
        .select()
        .eq('week', week)
        .order('id') as List;
    if (rows.isEmpty) return PregnancyChecklistRepository.forWeek(week);
    return rows.cast<Map<String, dynamic>>().map((r) => ChecklistTask(
      id:          r['id'] as String,
      title:       r['title'] as String? ?? '',
      description: r['description'] as String? ?? '',
      category:    r['category'] as String? ?? 'pratique',
    )).toList();
  } catch (_) {
    return PregnancyChecklistRepository.forWeek(week);
  }
});

// ── Postpartum insights ───────────────────────────────────────────────────────

final postpartumInsightProvider =
    FutureProvider.family<PostpartumInsight, int>((ref, week) async {
  try {
    final row = await SupabaseConfig.table('postpartum_insights')
        .select()
        .eq('week', week)
        .maybeSingle();
    if (row == null) return PostpartumInsightRepository.forWeek(week);
    return PostpartumInsight(
      week:          row['week'] as int,
      title:         row['title'] as String? ?? '',
      babyMilestone: row['baby_milestone'] as String? ?? '',
      momRecovery:   row['mom_recovery'] as String? ?? '',
      mentalHealth:  row['mental_health'] as String? ?? '',
      poeticLine:    row['poetic_line'] as String? ?? '',
    );
  } catch (_) {
    return PostpartumInsightRepository.forWeek(week);
  }
});

// ── Baby stories ──────────────────────────────────────────────────────────────

final babyStoryProvider =
    FutureProvider.family<BabyStory, int>((ref, week) async {
  try {
    final row = await SupabaseConfig.table('baby_stories')
        .select()
        .eq('week', week)
        .maybeSingle();
    if (row == null) return BabyStoryRepository.forWeek(week);
    return BabyStory(
      week:       row['week'] as int,
      title:      row['title'] as String? ?? '',
      story:      row['story'] as String? ?? '',
      fact:       row['fact'] as String? ?? '',
      milestones: List<String>.from(row['milestones'] as List? ?? []),
    );
  } catch (_) {
    return BabyStoryRepository.forWeek(week);
  }
});
