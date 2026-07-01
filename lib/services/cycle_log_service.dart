import 'supabase_config.dart';

// ignore_for_file: avoid_catches_without_on_clauses
class CycleLogService {
  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static Future<Set<String>> loadSymptoms(DateTime date) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return {};
    try {
      final row = await SupabaseConfig.table('cycle_daily_logs')
          .select('symptoms')
          .eq('user_id', uid)
          .eq('log_date', _dateKey(date))
          .maybeSingle();
      if (row == null) return {};
      return Set<String>.from((row['symptoms'] as List? ?? []));
    } catch (_) {
      return {};
    }
  }

  static Future<void> saveSymptoms(DateTime date, Set<String> symptoms) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;
    try {
      await SupabaseConfig.table('cycle_daily_logs').upsert({
        'user_id':    uid,
        'log_date':   _dateKey(date),
        'symptoms':   symptoms.toList(),
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,log_date');
    } catch (_) {}
  }

  static Future<int?> loadMood(DateTime date) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return null;
    try {
      final row = await SupabaseConfig.table('cycle_daily_logs')
          .select('mood_index')
          .eq('user_id', uid)
          .eq('log_date', _dateKey(date))
          .maybeSingle();
      return row?['mood_index'] as int?;
    } catch (_) { return null; }
  }

  static Future<void> saveMood(DateTime date, int moodIndex) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;
    try {
      await SupabaseConfig.table('cycle_daily_logs').upsert({
        'user_id':    uid,
        'log_date':   _dateKey(date),
        'mood_index': moodIndex,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,log_date');
    } catch (_) {}
  }

  // ── Pregnancy checklist ───────────────────────────────────────────────────

  static Future<Set<String>> loadChecklistDone(String userId) async {
    try {
      final rows = await SupabaseConfig.table('pregnancy_tasks_done')
          .select('task_id')
          .eq('user_id', userId) as List;
      return rows.map((r) => r['task_id'] as String).toSet();
    } catch (_) { return {}; }
  }

  static Future<void> setChecklistTask(String taskId, bool done) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;
    try {
      if (done) {
        await SupabaseConfig.table('pregnancy_tasks_done').upsert({
          'user_id': uid,
          'task_id': taskId,
        }, onConflict: 'user_id,task_id');
      } else {
        await SupabaseConfig.table('pregnancy_tasks_done')
            .delete()
            .eq('user_id', uid)
            .eq('task_id', taskId);
      }
    } catch (_) {}
  }
}
