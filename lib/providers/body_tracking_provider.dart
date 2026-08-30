// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'package:flutter_riverpod/legacy.dart';
import '../services/supabase_config.dart';
import '../services/storage_service.dart';

// ── Data Model ──────────────────────────────────────────────────────────────

class BodyLogEntry {
  final DateTime date;
  final double? weightKg;
  final double? bodyFatPct;
  final double? waistCm;
  final double? hipsCm;
  final double? chestCm;
  final double? thighsCm;
  final double? armsCm;

  BodyLogEntry({
    required this.date,
    this.weightKg,
    this.bodyFatPct,
    this.waistCm,
    this.hipsCm,
    this.chestCm,
    this.thighsCm,
    this.armsCm,
  });

  BodyLogEntry copyWith({
    DateTime? date,
    double? weightKg,
    double? bodyFatPct,
    double? waistCm,
    double? hipsCm,
    double? chestCm,
    double? thighsCm,
    double? armsCm,
    bool clearWeight = false,
    bool clearBodyFat = false,
  }) {
    return BodyLogEntry(
      date: date ?? this.date,
      weightKg: clearWeight ? null : (weightKg ?? this.weightKg),
      bodyFatPct: clearBodyFat ? null : (bodyFatPct ?? this.bodyFatPct),
      waistCm: waistCm ?? this.waistCm,
      hipsCm: hipsCm ?? this.hipsCm,
      chestCm: chestCm ?? this.chestCm,
      thighsCm: thighsCm ?? this.thighsCm,
      armsCm: armsCm ?? this.armsCm,
    );
  }

  Map<String, dynamic> toMap() => {
        'date': _dateKey(date),
        'weight_kg': weightKg,
        'body_fat_pct': bodyFatPct,
        'waist_cm': waistCm,
        'hips_cm': hipsCm,
        'chest_cm': chestCm,
        'thighs_cm': thighsCm,
        'arms_cm': armsCm,
      };

  factory BodyLogEntry.fromMap(Map<String, dynamic> m) {
    return BodyLogEntry(
      date: DateTime.parse(m['date'] as String),
      weightKg: _toDouble(m['weight_kg']),
      bodyFatPct: _toDouble(m['body_fat_pct']),
      waistCm: _toDouble(m['waist_cm']),
      hipsCm: _toDouble(m['hips_cm']),
      chestCm: _toDouble(m['chest_cm']),
      thighsCm: _toDouble(m['thighs_cm']),
      armsCm: _toDouble(m['arms_cm']),
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }
}

String _dateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

// ── State ───────────────────────────────────────────────────────────────────

class BodyTrackingState {
  final List<BodyLogEntry> history;
  final bool isLoading;
  final String? error;

  const BodyTrackingState({
    this.history = const [],
    this.isLoading = false,
    this.error,
  });

  BodyLogEntry? get today {
    final key = _dateKey(DateTime.now());
    for (final e in history) {
      if (_dateKey(e.date) == key) return e;
    }
    return null;
  }

  BodyLogEntry? get latest {
    if (history.isEmpty) return null;
    return history.first; // sorted newest-first
  }

  List<BodyLogEntry> lastNDays(int n) {
    final cutoff = DateTime.now().subtract(Duration(days: n));
    return history.where((e) => e.date.isAfter(cutoff)).toList();
  }

  BodyTrackingState copyWith({
    List<BodyLogEntry>? history,
    bool? isLoading,
    String? error,
  }) =>
      BodyTrackingState(
        history: history ?? this.history,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

// ── Notifier ────────────────────────────────────────────────────────────────

class BodyTrackingNotifier extends StateNotifier<BodyTrackingState> {
  BodyTrackingNotifier() : super(const BodyTrackingState()) {
    loadHistory();
  }

  static const _tableName = 'user_body_logs';
  static const _localKey = 'body_logs_cache';

  // ── Load ────────────────────────────────────────────────────────────────

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true);
    try {
      final uid = SupabaseConfig.userId;
      if (uid == null) {
        _loadFromLocal();
        return;
      }
      final rows = await SupabaseConfig.table(_tableName)
          .select()
          .eq('user_id', uid)
          .order('date', ascending: false)
          .limit(90);
      final entries =
          (rows as List).map((r) => BodyLogEntry.fromMap(r as Map<String, dynamic>)).toList();
      state = state.copyWith(history: entries, isLoading: false);
      _saveToLocal(entries);
    } catch (_) {
      _loadFromLocal();
    }
  }

  void _loadFromLocal() {
    final raw = StorageService.getString(_localKey);
    if (raw != null) {
      try {
        final list = (jsonDecode(raw) as List)
            .map((e) => BodyLogEntry.fromMap(e as Map<String, dynamic>))
            .toList();
        state = state.copyWith(history: list, isLoading: false);
        return;
      } catch (_) {}
    }
    state = state.copyWith(isLoading: false);
  }

  Future<void> _saveToLocal(List<BodyLogEntry> entries) async {
    final json = jsonEncode(entries.map((e) => e.toMap()).toList());
    await StorageService.setString(_localKey, json);
  }

  // ── Save / Upsert ─────────────────────────────────────────────────────

  Future<void> saveEntry(BodyLogEntry entry) async {
    final uid = SupabaseConfig.userId;
    final key = _dateKey(entry.date);

    // Merge with existing entry for that date
    final existing = state.history.where((e) => _dateKey(e.date) == key).toList();
    final merged = existing.isEmpty
        ? entry
        : existing.first.copyWith(
            weightKg: entry.weightKg ?? existing.first.weightKg,
            bodyFatPct: entry.bodyFatPct ?? existing.first.bodyFatPct,
            waistCm: entry.waistCm ?? existing.first.waistCm,
            hipsCm: entry.hipsCm ?? existing.first.hipsCm,
            chestCm: entry.chestCm ?? existing.first.chestCm,
            thighsCm: entry.thighsCm ?? existing.first.thighsCm,
            armsCm: entry.armsCm ?? existing.first.armsCm,
          );

    // Update local state
    final updated = [
      merged,
      ...state.history.where((e) => _dateKey(e.date) != key),
    ]..sort((a, b) => b.date.compareTo(a.date));
    state = state.copyWith(history: updated);
    await _saveToLocal(updated);

    // Persist to Supabase
    if (uid != null) {
      try {
        await SupabaseConfig.table(_tableName).upsert(
          {
            'user_id': uid,
            ...merged.toMap(),
            'updated_at': DateTime.now().toIso8601String(),
          },
          onConflict: 'user_id,date',
        );
      } catch (_) {
        // offline — local cache already saved
      }
    }
  }

  Future<void> updateWeight(double kg) async {
    await saveEntry(BodyLogEntry(date: DateTime.now(), weightKg: kg));
  }

  Future<void> updateBodyFat(double pct) async {
    await saveEntry(BodyLogEntry(date: DateTime.now(), bodyFatPct: pct));
  }

  Future<void> updateMeasurement({
    double? waist,
    double? hips,
    double? chest,
    double? thighs,
    double? arms,
  }) async {
    await saveEntry(BodyLogEntry(
      date: DateTime.now(),
      waistCm: waist,
      hipsCm: hips,
      chestCm: chest,
      thighsCm: thighs,
      armsCm: arms,
    ));
  }
}

// ── Provider ────────────────────────────────────────────────────────────────

final bodyTrackingProvider =
    StateNotifierProvider<BodyTrackingNotifier, BodyTrackingState>(
  (ref) => BodyTrackingNotifier(),
);
