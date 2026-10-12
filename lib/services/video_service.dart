
import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;

import '../models/coach_model.dart';
import '../models/video_model.dart';
import 'supabase_config.dart';

/// Vidéos autonomes (workout_id NULL) — cartes Dance/Cardio/Récupération
/// qui s'ouvrent directement dans ExercisePlayerScreen.
class VideoService {
  static Future<List<VideoModel>> fetchStandalone() async {
    final rows = await SupabaseConfig.table('videos')
        .select()
        .isFilter('workout_id', null)
        .order('sort_order', ascending: true);

    final list = rows as List;

    // Collecter les identifiants des coachs.
    final coachIds = <String>{};

    for (final row in list) {
      if (row is! Map) continue;

      final cid = row['coach_id']?.toString();

      if (cid != null && cid.isNotEmpty) {
        coachIds.add(cid);
      }
    }

    // Charger tous les coachs en une seule requête.
    final coaches = <String, CoachModel>{};

    if (coachIds.isNotEmpty) {
      final coachRows = await SupabaseConfig.table('coaches')
          .select()
          .inFilter('id', coachIds.toList());

      for (final row in coachRows as List) {
        if (row is! Map) continue;

        final coachRow = Map<String, dynamic>.from(row);
        final id = coachRow['id']?.toString();

        if (id != null && id.isNotEmpty) {
          try {
            coaches[id] = CoachModel.fromRow(coachRow);
          } catch (e) {
            debugPrint(
              '[VideoService] ERROR parsing coach id=$id: $e',
            );
          }
        }
      }
    }

    // Convertir les lignes en VideoModel.
    final result = <VideoModel>[];

    for (final row in list) {
      if (row is! Map) continue;

      final m = Map<String, dynamic>.from(row);

      try {
        final video = _fromRow(m);

        // Associer le coach récupéré à la vidéo.
        final coachId = video.coachId;
        final coach = coachId == null ? null : coaches[coachId];

        result.add(
          VideoModel(
            id: video.id,
            title: video.title,
            duration: video.duration,
            points: video.points,
            thumbnailUrl: video.thumbnailUrl,
            url: video.url,
            category: video.category,
            phases: video.phases,
            coachId: video.coachId,
            coach: coach ?? video.coach,
            techniqueDescription: video.techniqueDescription,
            techniqueSteps: video.techniqueSteps,
            musclesPrimary: video.musclesPrimary,
            musclesSecondary: video.musclesSecondary,
            tips: video.tips,
            sets: video.sets,
            workSeconds: video.workSeconds,
            restSeconds: video.restSeconds,
          ),
        );
      } catch (e, st) {
        // Une vidéo mal formée ne bloque pas les autres.
        debugPrint(
          '[VideoService] ERROR mapping video id=${m['id']}: $e',
        );
        debugPrint('[VideoService] row=$m');
        debugPrint('[VideoService] stack=$st');
      }
    }

    return result;
  }

  // Parsing défensif : Supabase peut renvoyer du JSON décodé ou du texte JSON.
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

  static List<({String name, double level})> _safeMusclesPrimary(
    dynamic v,
  ) {
    final j = _safeJson(v);

    if (j is! List) {
      return const <({String name, double level})>[];
    }

    final out = <({String name, double level})>[];

    for (final m in j) {
      if (m == null) continue;

      if (m is Map) {
        final name = (m['name'] ?? m['title'] ?? m['label'] ?? '')
            .toString()
            .trim();

        final rawLevel = m['level'] ?? m['intensity'] ?? 0;
        final level = rawLevel is num ? rawLevel.toDouble() : 0.0;

        if (name.isNotEmpty) {
          out.add((name: name, level: level));
        }
      } else {
        final s = m.toString().trim();

        if (s.isNotEmpty) {
          out.add((name: s, level: 0.0));
        }
      }
    }

    return out;
  }

  static List<({String title, String tip})> _safeTips(dynamic v) {
    final j = _safeJson(v);

    if (j is! List) {
      return const <({String title, String tip})>[];
    }

    final out = <({String title, String tip})>[];

    for (final t in j) {
      if (t == null) continue;

      if (t is Map) {
        final title = (t['title'] ?? t['name'] ?? '').toString().trim();

        final tip = (t['tip'] ??
                t['text'] ??
                t['description'] ??
                '')
            .toString()
            .trim();

        out.add((title: title, tip: tip));
      } else {
        final s = t.toString().trim();

        if (s.isNotEmpty) {
          out.add((title: '', tip: s));
        }
      }
    }

    return out;
  }

  static int _safeInt(dynamic v, int fallback) =>
      v is num ? v.toInt() : fallback;

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
        coachId: r['coach_id'] == null
            ? null
            : _safeStr(r['coach_id']),
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
