import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;

import '../models/coach_model.dart';
import '../models/video_model.dart';
import 'supabase_config.dart';

/// Vidéos autonomes (workout_id NULL) — cartes Dance/Cardio/Récupération qui
/// s'ouvrent directement dans ExercisePlayerScreen sans passer par un programme.
class VideoService {
  static Future<List<VideoModel>> fetchStandalone() async {
    final rows = await SupabaseConfig.table('videos')
        .select('*, coaches!coach_id(*)')
        .isFilter('workout_id', null)
        .order('sort_order', ascending: true);

    final list = rows as List;
    final result = <VideoModel>[];
    for (final r in list) {
      final m = r as Map<String, dynamic>;
      try {
        result.add(_fromRow(m));
      } catch (e, st) {
        // Une ligne mal formée ne doit pas faire échouer tout le chargement.
        debugPrint('[VideoService] ERROR mapping video id=${m['id']}: $e');
        debugPrint('[VideoService] row=$m');
        debugPrint('[VideoService] stack=$st');
      }
    }
    return result;
  }

  // ── Parsing défensif : Supabase peut renvoyer du JSON déjà décodé
  // (List/Map) OU du texte JSON (String) selon le type de colonne. ──────────
  static dynamic _safeJson(dynamic v) {
    if (v == null) return null;
    if (v is List || v is Map) return v;
    if (v is String) {
      final s = v.trim();
      if (s.isEmpty || s == '[]' || s == '{}') return null;
      try {
        return jsonDecode(s);
      } catch (_) {
        return v;
      }
    }
    return v;
  }

  static List<String> _safeStringList(dynamic v) {
    final j = _safeJson(v);
    if (j is List) {
      final out = <String>[];
      for (final e in j) {
        if (e == null) continue;
        final s = e.toString().trim();
        if (s.isNotEmpty) out.add(s);
      }
      return out;
    }
    if (j is String) return [j];
    return const <String>[];
  }

  static CoachModel? _safeCoach(dynamic v) {
    final j = _safeJson(v);
    if (j is Map) {
      try {
        return CoachModel.fromRow(Map<String, dynamic>.from(j));
      } catch (e) {
        debugPrint('[VideoService] ERROR parsing coach: $e');
        return null;
      }
    }
    if (j is List && j.isNotEmpty) {
      final first = j.first;
      if (first is Map) {
        try {
          return CoachModel.fromRow(Map<String, dynamic>.from(first));
        } catch (e) {
          debugPrint('[VideoService] ERROR parsing coach: $e');
          return null;
        }
      }
    }
    return null;
  }

  static List<({String name, double level})> _safeMusclesPrimary(dynamic v) {
    final j = _safeJson(v);
    if (j is! List) return const <({String name, double level})>[];
    final out = <({String name, double level})>[];
    for (final m in j) {
      if (m == null) continue;
      if (m is Map) {
        // Ligne de base : {"name": "...", "level": ...}
        final name = (m['name'] ?? m['title'] ?? m['label'] ?? '')
            .toString()
            .trim();
        final rawLevel = m['level'] ?? m['intensity'] ?? 0;
        final level = (rawLevel is num) ? rawLevel.toDouble() : 0.0;
        if (name.isNotEmpty) out.add((name: name, level: level));
      } else {
        // Donnée réelle en base : liste de simples chaînes -> ["Full Body"]
        final s = m.toString().trim();
        if (s.isNotEmpty) out.add((name: s, level: 0.0));
      }
    }
    return out;
  }

  static List<({String title, String tip})> _safeTips(dynamic v) {
    final j = _safeJson(v);
    if (j is! List) return const <({String title, String tip})>[];
    final out = <({String title, String tip})>[];
    for (final t in j) {
      if (t == null) continue;
      if (t is Map) {
        final title = (t['title'] ?? t['name'] ?? '').toString().trim();
        final tip =
            (t['tip'] ?? t['text'] ?? t['description'] ?? '').toString().trim();
        out.add((title: title, tip: tip));
      } else {
        // Donnée réelle en base : liste de simples chaînes -> ["Stay hydrated"]
        final s = t.toString().trim();
        if (s.isNotEmpty) out.add((title: '', tip: s));
      }
    }
    return out;
  }

  static int _safeInt(dynamic v, int fallback) =>
      (v is num) ? v.toInt() : fallback;

  static String _safeStr(dynamic v) => v?.toString() ?? '';

  static VideoModel _fromRow(Map<String, dynamic> r) => VideoModel(
        id: _safeStr(r['id']),
        title: _safeStr(r['title']),
        duration: _safeStr(r['duration']),
        points: _safeInt(r['points'], 0),
        thumbnailUrl: _safeStr(r['thumbnail_url']),
        url: _safeStr(r['url']),
        category: _safeStr(r['category']),
        phases: _safeStr(r['phases']),
        coachId: r['coach_id'] == null ? null : _safeStr(r['coach_id']),
        coach: _safeCoach(r['coaches']),
        techniqueDescription: _safeStr(r['technique_description']),
        techniqueSteps: _safeStringList(r['technique_steps']),
        musclesPrimary: _safeMusclesPrimary(r['muscles_primary']),
        musclesSecondary: _safeStringList(r['muscles_secondary']),
        tips: _safeTips(r['tips']),
        sets: _safeInt(r['sets'], 3),
        workSeconds: _safeInt(r['work_seconds'], 45),
        restSeconds: _safeInt(r['rest_seconds'], 15),
      );
}
