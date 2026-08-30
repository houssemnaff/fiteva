import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../services/supabase_config.dart';
import '../../../../widgets/mascot_widget.dart';
import '../../model/challenge_model.dart';

// ── Hardcoded seed challenges (will come from Supabase later) ────────────────
final _seedChallenges = [
  ChallengeModel(
    id: 'weekly_abs',
    title: 'Abdos en feu',
    description: '7 jours pour sculpter tes abdos — 10 min par jour.',
    emoji: '🔥',
    type: ChallengeType.weekly,
    durationDays: 7,
    startDate: _thisMonday(),
    endDate: _thisMonday().add(const Duration(days: 7)),
    participantCount: 47,
  ),
  ChallengeModel(
    id: 'glutes_30',
    title: 'Fessiers 30 jours',
    description: 'Le défi qui transforme — squats, bridges et kicks progressifs.',
    emoji: '🍑',
    type: ChallengeType.thirtyDay,
    durationDays: 30,
    startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
    endDate: DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
    participantCount: 128,
  ),
  ChallengeModel(
    id: 'cycle_sync',
    title: 'Défi synchronisé',
    description: 'Entraîne-toi en harmonie avec ta phase — exercices adaptés chaque jour.',
    emoji: '🌙',
    type: ChallengeType.cycleSynced,
    durationDays: 28,
    cyclePhase: 'auto',
    startDate: DateTime.now().subtract(const Duration(days: 3)),
    endDate: DateTime.now().add(const Duration(days: 25)),
    participantCount: 63,
  ),
  ChallengeModel(
    id: 'weekly_cardio',
    title: 'Cardio blast',
    description: '7 jours de cardio intensif — HIIT, corde, course.',
    emoji: '💨',
    type: ChallengeType.weekly,
    durationDays: 7,
    startDate: _thisMonday(),
    endDate: _thisMonday().add(const Duration(days: 7)),
    participantCount: 35,
  ),
];

DateTime _thisMonday() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day - (now.weekday - 1));
}

// ── Providers ────────────────────────────────────────────────────────────────

final challengesProvider =
    StateNotifierProvider<ChallengesNotifier, List<ChallengeModel>>(
        (ref) => ChallengesNotifier(ref));

class ChallengesNotifier extends StateNotifier<List<ChallengeModel>> {
  ChallengesNotifier(this._ref) : super(_seedChallenges) {
    _loadJoined();
  }

  final Ref _ref;
  final Set<String> _joinedIds = {};

  Future<void> _loadJoined() async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;
    try {
      final rows = await SupabaseConfig.table('challenge_participants')
          .select('challenge_id, completed_days')
          .eq('user_id', uid);
      for (final r in rows as List) {
        _joinedIds.add(r['challenge_id'] as String);
      }
      state = [
        for (final c in state)
          if (_joinedIds.contains(c.id))
            c.copyWith(
              isJoined: true,
              completedDays: (rows as List)
                      .where((r) => r['challenge_id'] == c.id)
                      .map((r) => r['completed_days'] as int? ?? 0)
                      .firstOrNull ??
                  0,
            )
          else
            c,
      ];
    } catch (_) {}
  }

  Future<void> toggleJoin(String id) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;
    final wasJoined = _joinedIds.contains(id);

    if (wasJoined) {
      _joinedIds.remove(id);
    } else {
      _joinedIds.add(id);
    }
    state = [
      for (final c in state)
        if (c.id == id)
          c.copyWith(
            isJoined: !wasJoined,
            participantCount: c.participantCount + (wasJoined ? -1 : 1),
          )
        else
          c,
    ];

    try {
      if (wasJoined) {
        await SupabaseConfig.table('challenge_participants')
            .delete()
            .eq('user_id', uid)
            .eq('challenge_id', id);
      } else {
        await SupabaseConfig.table('challenge_participants').insert({
          'user_id': uid,
          'challenge_id': id,
          'completed_days': 0,
        });
      }
    } catch (_) {}
  }

  Future<void> completeDay(String id) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;
    state = [
      for (final c in state)
        if (c.id == id) c.copyWith(completedDays: c.completedDays + 1) else c,
    ];
    try {
      final c = state.firstWhere((c) => c.id == id);
      await SupabaseConfig.table('challenge_participants')
          .update({'completed_days': c.completedDays})
          .eq('user_id', uid)
          .eq('challenge_id', id);
    } catch (_) {}
  }
}

// ── Tab chip filter ──────────────────────────────────────────────────────────
enum _Filter { all, weekly, thirtyDay, cycleSynced }

// ═════════════════════════════════════════════════════════════════════════════
// CHALLENGES TAB
// ═════════════════════════════════════════════════════════════════════════════
class ChallengesTab extends ConsumerStatefulWidget {
  const ChallengesTab({super.key});

  @override
  ConsumerState<ChallengesTab> createState() => _ChallengesTabState();
}

class _ChallengesTabState extends ConsumerState<ChallengesTab> {
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final challenges = ref.watch(challengesProvider);
    final accent = cs.primary;

    final filtered = _filter == _Filter.all
        ? challenges
        : challenges.where((c) {
            return switch (_filter) {
              _Filter.weekly => c.type == ChallengeType.weekly,
              _Filter.thirtyDay => c.type == ChallengeType.thirtyDay,
              _Filter.cycleSynced => c.type == ChallengeType.cycleSynced,
              _ => true,
            };
          }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
      children: [
        // ── Filter chips ──
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _filterChip('Tous', _Filter.all, accent, cs),
              const SizedBox(width: 8),
              _filterChip('7 jours', _Filter.weekly, accent, cs),
              const SizedBox(width: 8),
              _filterChip('30 jours', _Filter.thirtyDay, accent, cs),
              const SizedBox(width: 8),
              _filterChip('Phase', _Filter.cycleSynced, accent, cs),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // ── Challenge cards ──
        ...filtered.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _ChallengeCard(
                challenge: c,
                dark: dark,
                onJoin: () => ref.read(challengesProvider.notifier).toggleJoin(c.id),
                onComplete: () =>
                    ref.read(challengesProvider.notifier).completeDay(c.id),
                onLeaderboard: () =>
                    _showLeaderboard(context, c, dark),
              ),
            )),

        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Column(children: [
              Icon(LucideIcons.trophy, size: 40,
                  color: cs.onSurface.withValues(alpha: 0.2)),
              const SizedBox(height: 12),
              Text('Aucun défi trouvé',
                  style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface.withValues(alpha: 0.4))),
            ]),
          ),
      ],
    );
  }

  Widget _filterChip(String label, _Filter f, Color accent, ColorScheme cs) {
    final sel = _filter == f;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _filter = f);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? accent : cs.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: sel ? null : Border.all(color: cs.outline.withValues(alpha: 0.12)),
        ),
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: sel ? cs.onPrimary : cs.onSurface.withValues(alpha: 0.6))),
      ),
    );
  }

  void _showLeaderboard(
      BuildContext context, ChallengeModel challenge, bool dark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LeaderboardSheet(challenge: challenge, dark: dark),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// CHALLENGE CARD
// ═════════════════════════════════════════════════════════════════════════════
class _ChallengeCard extends StatelessWidget {
  final ChallengeModel challenge;
  final bool dark;
  final VoidCallback onJoin;
  final VoidCallback onComplete;
  final VoidCallback onLeaderboard;

  const _ChallengeCard({
    required this.challenge,
    required this.dark,
    required this.onJoin,
    required this.onComplete,
    required this.onLeaderboard,
  });

  String get _typeLabel => switch (challenge.type) {
        ChallengeType.weekly => '7 JOURS',
        ChallengeType.thirtyDay => '30 JOURS',
        ChallengeType.cycleSynced => 'PHASE',
      };

  Color _typeColor(ColorScheme cs) => switch (challenge.type) {
        ChallengeType.weekly => const Color(0xFFFF9F0A),
        ChallengeType.thirtyDay => const Color(0xFFFF375F),
        ChallengeType.cycleSynced => const Color(0xFF5E5CE6),
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = cs.primary;
    final typeColor = _typeColor(cs);
    final surface = dark ? const Color(0xFF162119) : Colors.white;
    final border = dark ? const Color(0xFF253D2E) : const Color(0xFFE8ECE9);

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border, width: 0.5),
        boxShadow: dark
            ? null
            : [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 3))
              ],
      ),
      child: Column(children: [
        // ── Header ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(challenge.emoji,
                  style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(_typeLabel,
                            style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: typeColor,
                                letterSpacing: 0.8)),
                      ),
                      const SizedBox(width: 8),
                      Text('${challenge.participantCount} participantes',
                          style: GoogleFonts.inter(
                              fontSize: 10.5,
                              color: cs.onSurface.withValues(alpha: 0.4))),
                    ]),
                    const SizedBox(height: 4),
                    Text(challenge.title,
                        style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface)),
                  ]),
            ),
            GestureDetector(
              onTap: onLeaderboard,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.trophy, size: 16, color: accent),
              ),
            ),
          ]),
        ),

        // ── Description ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Text(challenge.description,
              style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: cs.onSurface.withValues(alpha: 0.55),
                  height: 1.4)),
        ),

        // ── Progress (if joined) ──
        if (challenge.isJoined) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(children: [
              Row(children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: challenge.progress,
                      minHeight: 6,
                      backgroundColor: accent.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation(accent),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                    '${challenge.completedDays}/${challenge.durationDays}j',
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: accent)),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                Icon(LucideIcons.clock, size: 11,
                    color: cs.onSurface.withValues(alpha: 0.35)),
                const SizedBox(width: 4),
                Text('${challenge.daysLeft}j restants',
                    style: GoogleFonts.inter(
                        fontSize: 10.5,
                        color: cs.onSurface.withValues(alpha: 0.35))),
              ]),
            ]),
          ),
        ],

        // ── Actions ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  if (challenge.isJoined) {
                    onComplete();
                  } else {
                    onJoin();
                  }
                },
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: challenge.isJoined
                        ? accent.withValues(alpha: 0.1)
                        : accent,
                    borderRadius: BorderRadius.circular(27),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          challenge.isJoined
                              ? LucideIcons.checkCircle
                              : LucideIcons.zap,
                          size: 15,
                          color:
                              challenge.isJoined ? accent : cs.onPrimary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          challenge.isJoined
                              ? "Valider aujourd'hui"
                              : 'Rejoindre le défi',
                          style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: challenge.isJoined
                                  ? accent
                                  : cs.onPrimary),
                        ),
                      ]),
                ),
              ),
            ),
            if (challenge.isJoined) ...[
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onJoin,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD04040).withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.logOut,
                      size: 15, color: Color(0xFFD04040)),
                ),
              ),
            ],
          ]),
        ),
      ]),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// LEADERBOARD SHEET
// ═════════════════════════════════════════════════════════════════════════════
class _LeaderboardSheet extends StatelessWidget {
  final ChallengeModel challenge;
  final bool dark;
  const _LeaderboardSheet({required this.challenge, required this.dark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = cs.primary;
    final bg = dark ? const Color(0xFF0D0D0D) : Colors.white;
    final t2 = cs.onSurface.withValues(alpha: 0.5);

    final entries = challenge.leaderboard.isNotEmpty
        ? challenge.leaderboard
        : List.generate(
            8,
            (i) => ChallengeLeaderEntry(
                  userId: 'u$i',
                  username: [
                    'Yasmine',
                    'Fatma',
                    'Amira',
                    'Nour',
                    'Salma',
                    'Ines',
                    'Mariem',
                    'Rania'
                  ][i],
                  completedDays: (challenge.durationDays - i * 2).clamp(0, challenge.durationDays),
                  rank: i + 1,
                ));

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (ctx, ctrl) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: t2.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2)),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Row(children: [
              Icon(LucideIcons.trophy, size: 18, color: accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Classement · ${challenge.title}',
                    style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface)),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(LucideIcons.x,
                    size: 20, color: cs.onSurface.withValues(alpha: 0.4)),
              ),
            ]),
          ),

          // Entries
          Expanded(
            child: ListView.separated(
              controller: ctrl,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (_, i) {
                final e = entries[i];
                final isTop3 = e.rank <= 3;
                final medalColor = switch (e.rank) {
                  1 => const Color(0xFFFFD700),
                  2 => const Color(0xFFC0C0C0),
                  3 => const Color(0xFFCD7F32),
                  _ => null,
                };
                final isMe = e.userId == SupabaseConfig.userId;

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe
                        ? accent.withValues(alpha: 0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: isMe
                        ? Border.all(color: accent.withValues(alpha: 0.25))
                        : null,
                  ),
                  child: Row(children: [
                    // Rank
                    SizedBox(
                      width: 28,
                      child: isTop3
                          ? Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: medalColor!.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text('${e.rank}',
                                  style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: medalColor)),
                            )
                          : Text('${e.rank}',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: t2)),
                    ),
                    const SizedBox(width: 12),
                    // Avatar
                    MascotWidget(
                      type: MascotType.values.firstWhere(
                          (t) => t.name == e.mascotType,
                          orElse: () => MascotType.blob),
                      mood: MascotMood.values.firstWhere(
                          (m) => m.name == e.mascotMood,
                          orElse: () => MascotMood.happy),
                      size: 34,
                    ),
                    const SizedBox(width: 10),
                    // Name
                    Expanded(
                      child: Text(
                        isMe ? '${e.username} (toi)' : e.username,
                        style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight:
                                isMe ? FontWeight.w800 : FontWeight.w600,
                            color: cs.onSurface),
                      ),
                    ),
                    // Progress
                    Text(
                        '${e.completedDays}/${challenge.durationDays}j',
                        style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isTop3
                                ? medalColor
                                : cs.onSurface.withValues(alpha: 0.5))),
                  ]),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
