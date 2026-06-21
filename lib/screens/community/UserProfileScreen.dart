import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fiteva/models/home_program_model.dart';
import 'package:fiteva/providers/workout_progress_provider.dart';
import 'package:fiteva/providers/points_provider.dart';
import 'package:fiteva/providers/mock_data_provider.dart';
import 'package:fiteva/providers/user_profile_provider.dart'
    hide UserProfile;
import 'package:google_fonts/google_fonts.dart';

// ─── Models ───────────────────────────────────────────────────
class UserProfile {
  final String id;
  final String name;
  final String username;
  final String? avatarUrl;
  final String? bio;
  final String niveau;
  final int niveauXp;
  final int niveauMaxXp;
  final WorkoutReach reach;
  final List<UserPost> posts;
  final List<UserEvent> events;

  const UserProfile({
    required this.id,
    required this.name,
    required this.username,
    this.avatarUrl,
    this.bio,
    required this.niveau,
    required this.niveauXp,
    required this.niveauMaxXp,
    required this.reach,
    required this.posts,
    required this.events,
  });
}

class WorkoutReach {
  final int totalWorkouts;
  final int totalMinutes;
  final int currentStreak;
  final int longestStreak;
  final double totalKcal;
  final Map<String, int> workoutsByType;

  const WorkoutReach({
    required this.totalWorkouts,
    required this.totalMinutes,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalKcal,
    required this.workoutsByType,
  });
}

class UserPost {
  final String id;
  final String content;
  final DateTime createdAt;
  final int likes;
  final int comments;
  final String? imageUrl;

  const UserPost({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.likes,
    required this.comments,
    this.imageUrl,
  });
}

class UserEvent {
  final String id;
  final String title;
  final DateTime date;
  final String location;
  final int participants;
  final String category;

  const UserEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.participants,
    required this.category,
  });
}

// ─── Provider ─────────────────────────────────────────────────
final communityUserProfileProvider =
    FutureProvider.family<UserProfile, String>((ref, userId) async {
  final completedWorkouts = await ref.watch(completedWorkoutsProvider.future);
  final completedPrograms = await ref.watch(completedProgramsProvider.future);
  final points = ref.watch(pointsProvider);
  final user = ref.watch(userProvider);

  final totalWorkouts = completedWorkouts.length;
  final totalPrograms = 12;
  final totalMinutes = totalWorkouts * 45;
  final totalKcal = totalWorkouts * 350;
  final currentStreak = user.streak;
  final longestStreak = user.streak * 2;

  return UserProfile(
    id: userId,
    name: user.name,
    username: '@${user.name.toLowerCase().replaceAll(' ', '')}',
    bio: 'Passionnée de fitness · $totalWorkouts séances complétées',
    niveau: user.level.toString(),
    niveauXp: points,
    niveauMaxXp: 5000,
    reach: WorkoutReach(
      totalWorkouts: totalWorkouts,
      totalMinutes: totalMinutes,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalKcal: totalKcal.toDouble(),
      workoutsByType: {
        'Complétés': completedWorkouts.length,
        'Programmes': completedPrograms.length,
        'En cours': totalPrograms - completedPrograms.length,
      },
    ),
    posts: [],
    events: [],
  );
});

// ─── Main Screen ──────────────────────────────────────────────
class UserProfileScreen extends ConsumerStatefulWidget {
  final String userId;
  final String? heroTag;

  const UserProfileScreen({
    super.key,
    required this.userId,
    this.heroTag,
  });

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final profileAsync = ref.watch(communityUserProfileProvider(widget.userId));

    return Scaffold(
      backgroundColor: cs.surface,
      body: profileAsync.when(
        loading: () => _ProfileSkeleton(),
        error: (e, _) => _ProfileError(error: e.toString()),
        data: (profile) => _ProfileContent(
          profile: profile,
          tabController: _tabController,
          heroTag: widget.heroTag,
        ),
      ),
    );
  }
}

// ─── Profile Content ──────────────────────────────────────────
class _ProfileContent extends StatelessWidget {
  final UserProfile profile;
  final TabController tabController;
  final String? heroTag;

  const _ProfileContent({
    required this.profile,
    required this.tabController,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return NestedScrollView(
      headerSliverBuilder: (context, _) => [
        // ── App bar ───────────────────────────────────────────
        SliverAppBar(
          pinned: true,
          floating: false,
          elevation: 0,
          backgroundColor: cs.surface,
          surfaceTintColor: Colors.transparent,
          leading: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.arrowLeft,
                  size: 16, color: cs.onSurface),
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () => _showOptions(context),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(LucideIcons.ellipsis,
                      size: 16, color: cs.onSurface),
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                      color: cs.outline.withValues(alpha: 0.5), width: 1),
                ),
              ),
              child: TabBar(
                controller: tabController,
                labelColor: cs.primary,
                unselectedLabelColor: cs.onSurface.withValues(alpha: 0.4),
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(color: cs.primary, width: 2.5),
                  insets: const EdgeInsets.symmetric(horizontal: 20),
                ),
                labelStyle: GoogleFonts.outfit(
                    fontSize: 13, fontWeight: FontWeight.w700),
                unselectedLabelStyle: GoogleFonts.outfit(
                    fontSize: 13, fontWeight: FontWeight.w500),
                tabs: const [
                  Tab(text: 'Aperçu'),
                  Tab(text: 'Posts'),
                  Tab(text: 'Événements'),
                ],
              ),
            ),
          ),
        ),

        // ── Header ────────────────────────────────────────────
        SliverToBoxAdapter(
          child: _ProfileHeader(profile: profile, heroTag: heroTag),
        ),
      ],
      body: TabBarView(
        controller: tabController,
        children: [
          _OverviewTab(profile: profile),
          _PostsTab(posts: profile.posts),
          _EventsTab(events: profile.events),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Signaler ce profil'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Masquer les publications'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          isDefaultAction: true,
          child: const Text('Annuler'),
        ),
      ),
    );
  }
}

// ─── Profile Header ───────────────────────────────────────────
class _ProfileHeader extends ConsumerStatefulWidget {
  final UserProfile profile;
  final String? heroTag;

  const _ProfileHeader({required this.profile, this.heroTag});

  @override
  ConsumerState<_ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends ConsumerState<_ProfileHeader> {
  bool _following = false;

  String get _initials {
    final parts = widget.profile.name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    final n = widget.profile.name;
    return n.substring(0, n.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final profile = widget.profile;
    final points = ref.watch(pointsProvider);
    final userProfile = ref.watch(userProfileProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── Hero band ──────────────────────────────────────────
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Solid primary banner
            Container(
              height: 130,
              width: double.infinity,
              color: cs.primary,
              child: Stack(children: [
                // Subtle geometric overlay
                Positioned(
                  top: -30, right: -30,
                  child: Container(
                    width: 180, height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -20, left: 80,
                  child: Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                ),
              ]),
            ),

            // Avatar — overlapping bottom of banner
            Positioned(
              bottom: -44,
              left: 20,
              child: Hero(
                tag: widget.heroTag ?? 'avatar_${profile.id}',
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.surface, width: 4),
                    color: cs.secondary,
                  ),
                  child: ClipOval(
                    child: profile.avatarUrl != null
                        ? Image.network(profile.avatarUrl!, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _InitialsCircle(
                              initials: _initials, cs: cs))
                        : _InitialsCircle(initials: _initials, cs: cs),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 56), // avatar overflow space

        // ── Name + follow row ─────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.name, style: GoogleFonts.outfit(
                      fontSize: 24, fontWeight: FontWeight.w800,
                      color: cs.onSurface, letterSpacing: -0.5, height: 1.1)),
                    const SizedBox(height: 2),
                    Text(profile.username, style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w500,
                      color: cs.onSurface.withValues(alpha: 0.45))),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _following = !_following);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: _following
                        ? Colors.transparent
                        : cs.primary,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: cs.primary,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    _following ? 'Suivi' : 'Suivre',
                    style: GoogleFonts.outfit(
                      fontSize: 13, fontWeight: FontWeight.w800,
                      color: _following ? cs.primary : cs.onPrimary,
                      letterSpacing: 0.1),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── Bio ───────────────────────────────────────────────
        if (profile.bio != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(profile.bio!, style: GoogleFonts.inter(
              fontSize: 14, color: cs.onSurface.withValues(alpha: 0.65),
              height: 1.55)),
          ),

        const SizedBox(height: 10),

        // ── Meta pills ────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(spacing: 8, runSpacing: 6, children: [
            if (userProfile.fitnessLevel != null)
              _MetaPill(
                icon: LucideIcons.target,
                label: userProfile.fitnessLevel!,
                cs: cs),
            if (userProfile.frequency != null)
              _MetaPill(
                icon: LucideIcons.dumbbell,
                label: userProfile.frequency!,
                cs: cs),
            _MetaPill(
              icon: LucideIcons.star,
              label: '$points XP',
              cs: cs,
              highlight: true),
          ]),
        ),

        const SizedBox(height: 20),

        // ── Stats strip ───────────────────────────────────────
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.outline),
          ),
          child: Row(children: [
            Expanded(child: _StripStat(
              value: '${profile.reach.totalWorkouts}',
              label: 'Séances', cs: cs)),
            _VertDivider(cs: cs),
            Expanded(child: _StripStat(
              value: '${profile.reach.currentStreak}',
              label: 'Série (j)', cs: cs)),
            _VertDivider(cs: cs),
            Expanded(child: _StripStat(
              value: _formatKcal(profile.reach.totalKcal),
              label: 'Calories', cs: cs)),
          ]),
        ),

        const SizedBox(height: 16),

        // ── Level progress ────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _LevelBar(
            niveau: profile.niveau,
            xp: profile.niveauXp,
            maxXp: profile.niveauMaxXp,
            cs: cs,
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  String _formatKcal(double kcal) {
    if (kcal >= 1000) return '${(kcal / 1000).toStringAsFixed(1)}k';
    return '${kcal.toInt()}';
  }
}

// ─── Initials circle fallback ─────────────────────────────────
class _InitialsCircle extends StatelessWidget {
  final String initials;
  final ColorScheme cs;
  const _InitialsCircle({required this.initials, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: cs.secondary,
      alignment: Alignment.center,
      child: Text(initials, style: GoogleFonts.outfit(
        fontSize: 30, fontWeight: FontWeight.w800,
        color: Colors.white.withValues(alpha: 0.9), letterSpacing: -1)),
    );
  }
}

// ─── Meta pill ────────────────────────────────────────────────
class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme cs;
  final bool highlight;
  const _MetaPill({
    required this.icon, required this.label, required this.cs,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: highlight
            ? cs.primary.withValues(alpha: 0.1)
            : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: highlight
              ? cs.primary.withValues(alpha: 0.3)
              : cs.outline),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11,
            color: highlight ? cs.primary : cs.onSurface.withValues(alpha: 0.5)),
        const SizedBox(width: 5),
        Text(label, style: GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w600,
          color: highlight
              ? cs.primary
              : cs.onSurface.withValues(alpha: 0.6))),
      ]),
    );
  }
}

// ─── Strip stat ───────────────────────────────────────────────
class _StripStat extends StatelessWidget {
  final String value, label;
  final ColorScheme cs;
  const _StripStat({required this.value, required this.label, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: GoogleFonts.outfit(
        fontSize: 22, fontWeight: FontWeight.w800,
        color: cs.primary, letterSpacing: -0.5)),
      const SizedBox(height: 2),
      Text(label, style: GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w500,
        color: cs.onSurface.withValues(alpha: 0.45))),
    ]);
  }
}

class _VertDivider extends StatelessWidget {
  final ColorScheme cs;
  const _VertDivider({required this.cs});
  @override
  Widget build(BuildContext context) => Container(
    width: 1, height: 36,
    color: cs.outline.withValues(alpha: 0.6));
}

// ─── Level bar ────────────────────────────────────────────────
class _LevelBar extends StatelessWidget {
  final String niveau;
  final int xp, maxXp;
  final ColorScheme cs;
  const _LevelBar({
    required this.niveau, required this.xp,
    required this.maxXp, required this.cs});

  int get _lvl => int.tryParse(niveau) ?? 1;

  Color get _accent {
    if (_lvl <= 2) return const Color(0xFF34D399);
    if (_lvl <= 4) return const Color(0xFF3B82F6);
    if (_lvl <= 6) return const Color(0xFFF59E0B);
    return const Color(0xFFBF5AF2);
  }

  IconData get _icon {
    if (_lvl <= 2) return LucideIcons.sprout;
    if (_lvl <= 4) return LucideIcons.zap;
    if (_lvl <= 6) return LucideIcons.flame;
    return LucideIcons.crown;
  }

  String get _levelLabel {
    if (_lvl <= 2) return 'Débutant';
    if (_lvl <= 4) return 'Intermédiaire';
    if (_lvl <= 6) return 'Avancé';
    return 'Expert';
  }

  @override
  Widget build(BuildContext context) {
    final progress = (xp / maxXp).clamp(0.0, 1.0);
    final remaining = ((1 - progress) * maxXp).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accent.withValues(alpha: 0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_icon, size: 14, color: _accent),
          ),
          const SizedBox(width: 10),
          Text('Niveau $_levelLabel', style: GoogleFonts.outfit(
            fontSize: 14, fontWeight: FontWeight.w800,
            color: _accent, letterSpacing: -0.2)),
          const Spacer(),
          Text('$xp / $maxXp XP', style: GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.w600,
            color: cs.onSurface.withValues(alpha: 0.45))),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: _accent.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(_accent),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 8),
        Text('$remaining XP avant le prochain niveau',
          style: GoogleFonts.inter(
            fontSize: 11, color: cs.onSurface.withValues(alpha: 0.4))),
      ]),
    );
  }
}

// ─── Tab 1 — Overview ─────────────────────────────────────────
class _OverviewTab extends ConsumerWidget {
  final UserProfile profile;
  const _OverviewTab({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final reach = profile.reach;
    final allPrograms = <HomeProgramModel>[
      ...ref.watch(homeProgramsProvider),
      ...ref.watch(salleProgramsProvider),
      ...ref.watch(danceProgramsProvider),
      ...ref.watch(recuperationProgramsProvider),
      ...ref.watch(grossesseProgramsProvider),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [

        // Section label
        _SectionTitle(label: 'STATISTIQUES', cs: cs),
        const SizedBox(height: 12),

        // 2×2 stat grid
        Row(children: [
          Expanded(child: _StatCard(
            icon: LucideIcons.dumbbell,
            value: '${reach.totalWorkouts}',
            label: 'Séances',
            color: cs.primary, cs: cs)),
          const SizedBox(width: 12),
          Expanded(child: _StatCard(
            icon: LucideIcons.zap,
            value: '${reach.currentStreak} j',
            label: 'Série en cours',
            color: const Color(0xFF3B82F6), cs: cs)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _StatCard(
            icon: LucideIcons.flame,
            value: _formatKcal(reach.totalKcal),
            label: 'Calories brûlées',
            color: const Color(0xFFEF4444), cs: cs)),
          const SizedBox(width: 12),
          Expanded(child: _StatCard(
            icon: LucideIcons.clock,
            value: _formatMinutes(reach.totalMinutes),
            label: 'Temps total',
            color: const Color(0xFFF59E0B), cs: cs)),
        ]),

        const SizedBox(height: 24),
        _SectionTitle(label: 'RÉPARTITION', cs: cs),
        const SizedBox(height: 12),

        // Distribution
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: cs.outline),
          ),
          child: Column(
            children: () {
              final entries = reach.workoutsByType.entries.toList();
              final total = reach.workoutsByType.values
                  .fold(0, (a, b) => a + b);
              final colors = [
                cs.primary, const Color(0xFF3B82F6), const Color(0xFFF59E0B)
              ];
              final List<Widget> rows = [];
              for (int i = 0; i < entries.length; i++) {
                final e = entries[i];
                final pct = total == 0 ? 0.0 : e.value / total;
                rows.add(_DistRow(
                  label: e.key, count: e.value,
                  pct: pct.toDouble(),
                  color: colors[i % colors.length], cs: cs));
                if (i < entries.length - 1)
                  rows.add(Divider(height: 1,
                      color: cs.outline.withValues(alpha: 0.5),
                      indent: 16, endIndent: 16));
              }
              return rows;
            }(),
          ),
        ),

        const SizedBox(height: 24),
        _StartedProgramsSection(programs: allPrograms),
      ],
    );
  }

  String _formatKcal(double kcal) {
    if (kcal >= 1000) return '${(kcal / 1000).toStringAsFixed(1)}k';
    return '${kcal.toInt()}';
  }

  String _formatMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return h > 0 ? '${h}h${m > 0 ? ' ${m}m' : ''}' : '${m}m';
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;
  final ColorScheme cs;
  const _SectionTitle({required this.label, required this.cs});
  @override
  Widget build(BuildContext context) => Text(label,
    style: GoogleFonts.inter(
      fontSize: 9, fontWeight: FontWeight.w700,
      color: cs.onSurface.withValues(alpha: 0.4), letterSpacing: 2));
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;
  final ColorScheme cs;
  const _StatCard({
    required this.icon, required this.value, required this.label,
    required this.color, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outline),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(height: 12),
        Text(value, style: GoogleFonts.outfit(
          fontSize: 22, fontWeight: FontWeight.w800,
          color: cs.onSurface, letterSpacing: -0.5)),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.inter(
          fontSize: 11, color: cs.onSurface.withValues(alpha: 0.45),
          fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

class _DistRow extends StatelessWidget {
  final String label;
  final int count;
  final double pct;
  final Color color;
  final ColorScheme cs;
  const _DistRow({
    required this.label, required this.count,
    required this.pct, required this.color, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: GoogleFonts.inter(
            fontSize: 14, color: cs.onSurface))),
          Text('$count', style: GoogleFonts.outfit(
            fontSize: 15, fontWeight: FontWeight.w700,
            color: cs.onSurface.withValues(alpha: 0.55))),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ),
      ]),
    );
  }
}

// ─── Tab 2 — Posts ────────────────────────────────────────────
class _PostsTab extends StatelessWidget {
  final List<UserPost> posts;
  const _PostsTab({required this.posts});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (posts.isEmpty) {
      return _EmptyState(
        icon: LucideIcons.fileText, message: 'Aucun post publié', cs: cs);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: posts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _PostCard(post: posts[i]),
    );
  }
}

class _PostCard extends StatefulWidget {
  final UserPost post;
  const _PostCard({required this.post});
  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.post.content, style: GoogleFonts.inter(
          fontSize: 15, color: cs.onSurface, height: 1.55,
          letterSpacing: -0.1)),
        if (widget.post.imageUrl != null) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(widget.post.imageUrl!,
              fit: BoxFit.cover, width: double.infinity, height: 180)),
        ],
        const SizedBox(height: 14),
        Row(children: [
          Text(_timeAgo(widget.post.createdAt), style: GoogleFonts.inter(
            fontSize: 12,
            color: cs.onSurface.withValues(alpha: 0.4))),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() => _liked = !_liked),
            child: Row(children: [
              Icon(
                _liked ? LucideIcons.heart : LucideIcons.heart,
                size: 16,
                color: _liked
                    ? const Color(0xFFFF375F)
                    : cs.onSurface.withValues(alpha: 0.4)),
              const SizedBox(width: 5),
              Text('${widget.post.likes + (_liked ? 1 : 0)}',
                style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: _liked
                      ? const Color(0xFFFF375F)
                      : cs.onSurface.withValues(alpha: 0.4))),
            ]),
          ),
          const SizedBox(width: 16),
          Row(children: [
            Icon(LucideIcons.messageCircle, size: 16,
                color: cs.onSurface.withValues(alpha: 0.4)),
            const SizedBox(width: 5),
            Text('${widget.post.comments}', style: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.w600,
              color: cs.onSurface.withValues(alpha: 0.4))),
          ]),
        ]),
      ]),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours}h';
    return 'il y a ${diff.inDays}j';
  }
}

// ─── Tab 3 — Events ───────────────────────────────────────────
class _EventsTab extends StatelessWidget {
  final List<UserEvent> events;
  const _EventsTab({required this.events});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (events.isEmpty) {
      return _EmptyState(
        icon: LucideIcons.calendarX, message: 'Aucun événement créé', cs: cs);
    }

    final now = DateTime.now();
    final upcoming = events.where((e) => e.date.isAfter(now)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final past = events.where((e) => !e.date.isAfter(now)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        if (upcoming.isNotEmpty) ...[
          _SectionTitle(label: 'À VENIR', cs: cs),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: cs.outline),
            ),
            child: Column(children: [
              for (int i = 0; i < upcoming.length; i++) ...[
                _EventRow(event: upcoming[i], isPast: false, cs: cs),
                if (i < upcoming.length - 1)
                  Divider(height: 1,
                    color: cs.outline.withValues(alpha: 0.5),
                    indent: 16, endIndent: 16),
              ],
            ]),
          ),
          const SizedBox(height: 24),
        ],
        if (past.isNotEmpty) ...[
          _SectionTitle(label: 'PASSÉS', cs: cs),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: cs.outline),
            ),
            child: Column(children: [
              for (int i = 0; i < past.length; i++) ...[
                _EventRow(event: past[i], isPast: true, cs: cs),
                if (i < past.length - 1)
                  Divider(height: 1,
                    color: cs.outline.withValues(alpha: 0.5),
                    indent: 16, endIndent: 16),
              ],
            ]),
          ),
        ],
      ],
    );
  }
}

class _EventRow extends StatelessWidget {
  final UserEvent event;
  final bool isPast;
  final ColorScheme cs;
  const _EventRow({required this.event, required this.isPast, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isPast ? 0.5 : 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: isPast ? 0.05 : 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: cs.primary.withValues(alpha: isPast ? 0.1 : 0.25)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_monthShort(event.date), style: GoogleFonts.inter(
                  fontSize: 9, fontWeight: FontWeight.w700,
                  color: cs.primary.withValues(alpha: isPast ? 0.5 : 1))),
                Text('${event.date.day}', style: GoogleFonts.outfit(
                  fontSize: 18, fontWeight: FontWeight.w800,
                  color: cs.primary.withValues(alpha: isPast ? 0.5 : 1),
                  height: 1.1)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.title, style: GoogleFonts.outfit(
                fontSize: 14, fontWeight: FontWeight.w700,
                color: cs.onSurface)),
              const SizedBox(height: 3),
              Row(children: [
                Icon(LucideIcons.mapPin, size: 10,
                    color: cs.onSurface.withValues(alpha: 0.4)),
                const SizedBox(width: 4),
                Expanded(child: Text(event.location,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: cs.onSurface.withValues(alpha: 0.45)))),
              ]),
            ],
          )),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(event.category, style: GoogleFonts.inter(
                fontSize: 10, fontWeight: FontWeight.w700,
                color: cs.primary)),
            ),
            const SizedBox(height: 5),
            Row(children: [
              Icon(LucideIcons.users, size: 11,
                  color: cs.onSurface.withValues(alpha: 0.35)),
              const SizedBox(width: 4),
              Text('${event.participants}', style: GoogleFonts.inter(
                fontSize: 11,
                color: cs.onSurface.withValues(alpha: 0.35))),
            ]),
          ]),
        ]),
      ),
    );
  }

  String _monthShort(DateTime dt) {
    const m = ['JAN','FÉV','MAR','AVR','MAI','JUN',
                'JUL','AOÛ','SEP','OCT','NOV','DÉC'];
    return m[dt.month - 1];
  }
}

// ─── Empty state ──────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final ColorScheme cs;
  const _EmptyState({required this.icon, required this.message, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 40, color: cs.onSurface.withValues(alpha: 0.15)),
      const SizedBox(height: 12),
      Text(message, style: GoogleFonts.inter(
        fontSize: 14, color: cs.onSurface.withValues(alpha: 0.35))),
    ]));
  }
}

// ─── Loading skeleton ─────────────────────────────────────────
class _ProfileSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: ListView(padding: EdgeInsets.zero, children: [
        _Shimmer(width: double.infinity, height: 130, radius: 0, cs: cs),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
          child: Column(children: [
            Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Shimmer(width: 160, height: 24, radius: 6, cs: cs),
                  const SizedBox(height: 8),
                  _Shimmer(width: 100, height: 14, radius: 6, cs: cs),
                ])),
              _Shimmer(width: 80, height: 38, radius: 50, cs: cs),
            ]),
            const SizedBox(height: 20),
            _Shimmer(width: double.infinity, height: 80, radius: 20, cs: cs),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _Shimmer(
                  width: double.infinity, height: 100, radius: 18, cs: cs)),
              const SizedBox(width: 12),
              Expanded(child: _Shimmer(
                  width: double.infinity, height: 100, radius: 18, cs: cs)),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _Shimmer extends StatefulWidget {
  final double width, height, radius;
  final ColorScheme cs;
  const _Shimmer({
    required this.width, required this.height,
    required this.radius, required this.cs});
  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 0.9).animate(_ctrl);
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width, height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(widget.cs.surface,
              widget.cs.surfaceContainerHighest, _anim.value),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

// ─── Started Programs Section ─────────────────────────────────
class _StartedProgramsSection extends ConsumerWidget {
  final List<HomeProgramModel> programs;
  const _StartedProgramsSection({required this.programs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    if (programs.isEmpty) return const SizedBox.shrink();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionTitle(label: 'PROGRAMMES EN COURS', cs: cs),
      const SizedBox(height: 12),
      SizedBox(
        height: 200,
        child: _ProgramsWithProgressFilter(programs: programs),
      ),
    ]);
  }
}

class _ProgramsWithProgressFilter extends ConsumerWidget {
  final List<HomeProgramModel> programs;
  const _ProgramsWithProgressFilter({required this.programs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: programs.length,
      itemBuilder: (context, index) {
        final program = programs[index];
        final statusAsync = ref.watch(programStatusProvider(program));
        return statusAsync.when(
          data: (status) {
            if (status.completionPercentage <= 0) return const SizedBox.shrink();
            return _CommunityProgramCard(program: program);
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    );
  }
}

class _CommunityProgramCard extends ConsumerWidget {
  final HomeProgramModel program;
  const _CommunityProgramCard({required this.program});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(programStatusProvider(program));
    final cs = Theme.of(context).colorScheme;

    return statusAsync.when(
      data: (status) {
        final isCompleted = status.isCompleted;
        final percentage = status.completionPercentage;
        final color = isCompleted ? const Color(0xFF34D399) : cs.primary;

        return Container(
          width: 160,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outline),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Stack(children: [
              Image.asset(program.imageUrl,
                height: 80, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 80, color: cs.outline.withValues(alpha: 0.1))),
              Positioned(
                top: 8, right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text('${(percentage * 100).toInt()}%',
                    style: GoogleFonts.outfit(
                      color: Colors.white, fontSize: 9,
                      fontWeight: FontWeight.w800)),
                ),
              ),
            ]),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(program.name, style: GoogleFonts.outfit(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: cs.onSurface),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(program.duration, style: GoogleFonts.inter(
                    color: cs.onSurface.withValues(alpha: 0.45), fontSize: 9)),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: LinearProgressIndicator(
                      value: percentage.clamp(0.0, 1.0), minHeight: 4,
                      backgroundColor: color.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation(color)),
                  ),
                ],
              ),
            ),
          ]),
        );
      },
      loading: () => Container(
        width: 160, margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16))),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

// ─── Error state ──────────────────────────────────────────────
class _ProfileError extends StatelessWidget {
  final String error;
  const _ProfileError({required this.error});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(LucideIcons.circleAlert, size: 44, color: cs.error),
        const SizedBox(height: 16),
        Text('Impossible de charger ce profil', style: GoogleFonts.outfit(
          fontSize: 17, fontWeight: FontWeight.w700,
          color: cs.onSurface), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(error, style: GoogleFonts.inter(
          fontSize: 13, color: cs.onSurface.withValues(alpha: 0.5)),
          textAlign: TextAlign.center),
      ]),
    ));
  }
}