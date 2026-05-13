import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';

// ─────────────────────────────────────────
// DESIGN TOKENS — iOS Fitness Dark Theme
// ─────────────────────────────────────────
class _C {
  // Backgrounds
  static const bg = Colors.white;
  static const surface = Colors.white;
  static const surfaceElevated = Color(0xFF2C2C2E);
  static const surfaceHigh = Color(0xFF3A3A3C);

  // Accent ring colors (Apple Fitness rings)
  static const move = Color(0xFFFF375F);   // red — calories/move
  static const exercise = Color(0xFF30D158); // green — workouts
  static const stand = Color(0xFF0A84FF);   // blue — streak/time

  static const amber = Color(0xFFFFD60A);
  static const purple = Color(0xFFBF5AF2);

  // Text
  static const textPrimary = Colors.black;
  static const textSecondary = Color(0xFF8E8E93);
  static const textTertiary = Color(0xFF48484A);

  static const separator = Color(0xFF38383A);
}

// ─────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────
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

// ─────────────────────────────────────────
// PROVIDER
// ─────────────────────────────────────────
final userProfileProvider =
    FutureProvider.family<UserProfile, String>((ref, userId) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return UserProfile(
    id: userId,
    name: 'Karim Benali',
    username: '@karimfit',
    bio: 'Coach certifié 🏋️ · Sousse, TN · En route vers l\'excellence',
    niveau: 'Avancé',
    niveauXp: 3200,
    niveauMaxXp: 4000,
    reach: const WorkoutReach(
      totalWorkouts: 148,
      totalMinutes: 6320,
      currentStreak: 12,
      longestStreak: 34,
      totalKcal: 52400,
      workoutsByType: {
        'Musculation': 62,
        'Cardio': 45,
        'HIIT': 28,
        'Yoga': 13,
      },
    ),
    posts: [
      UserPost(
        id: 'p1',
        content: 'Séance de dos/biceps terminée 💪 Nouvelle PR : 120kg au soulevé de terre !',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        likes: 47,
        comments: 12,
      ),
      UserPost(
        id: 'p2',
        content: 'Conseil du jour : l\'échauffement, c\'est pas optionnel. 15 min = des semaines de blessure évitées.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        likes: 89,
        comments: 23,
      ),
      UserPost(
        id: 'p3',
        content: 'Plan nutrition prêt ✅ 180g protéines · 250g glucides · 70g lipides. On reste focus ! 🥗',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        likes: 61,
        comments: 8,
      ),
    ],
    events: [
      UserEvent(
        id: 'e1',
        title: 'Boot Camp Matinal',
        date: DateTime.now().add(const Duration(days: 5)),
        location: 'Parc de la Corniche, Sousse',
        participants: 18,
        category: 'Cardio',
      ),
      UserEvent(
        id: 'e2',
        title: 'Atelier Musculation Débutants',
        date: DateTime.now().add(const Duration(days: 12)),
        location: 'FitEva Gym, Centre-ville',
        participants: 8,
        category: 'Force',
      ),
      UserEvent(
        id: 'e3',
        title: 'Course 5km Solidarité',
        date: DateTime.now().subtract(const Duration(days: 10)),
        location: 'Boulevard Habib Bourguiba',
        participants: 42,
        category: 'Course',
      ),
    ],
  );
});

// ─────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────
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
    final profileAsync = ref.watch(userProfileProvider(widget.userId));

    return Scaffold(
      backgroundColor: _C.bg,
      body: profileAsync.when(
        loading: () => const _ProfileSkeleton(),
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

// ─────────────────────────────────────────
// PROFILE CONTENT
// ─────────────────────────────────────────
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
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          pinned: true,
          floating: false,
          elevation: 0,
          backgroundColor: _C.bg,
          surfaceTintColor: Colors.transparent,
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.of(context).pop(),
            child: const Icon(CupertinoIcons.chevron_back,
                color: _C.textPrimary, size: 22),
          ),
          actions: [
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              onPressed: () => _showOptions(context),
              child: const Icon(CupertinoIcons.ellipsis_circle,
                  color: _C.textSecondary, size: 22),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(44),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: _C.separator, width: 0.5),
                ),
              ),
              child: TabBar(
                controller: tabController,
                labelColor: _C.textPrimary,
                unselectedLabelColor: _C.textSecondary,
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(color: _C.move, width: 2),
                  insets: EdgeInsets.symmetric(horizontal: 24),
                ),
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                tabs: const [
                  Tab(text: 'Aperçu'),
                  Tab(text: 'Posts'),
                  Tab(text: 'Événements'),
                ],
              ),
            ),
          ),
        ),
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

// ─────────────────────────────────────────
// PROFILE HEADER
// ─────────────────────────────────────────
class _ProfileHeader extends StatefulWidget {
  final UserProfile profile;
  final String? heroTag;

  const _ProfileHeader({required this.profile, this.heroTag});

  @override
  State<_ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<_ProfileHeader> {
  bool _following = false;

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;

    return Container(
      color: _C.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero banner area ─────────────────────────────────
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Gradient banner
              Container(
                height: 100,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1C1C1E), Color(0xFF2C1810)],
                  ),
                ),
              ),
              // Subtle glow
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _C.move.withOpacity(0.25),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Avatar overlapping bottom of banner
              Positioned(
                bottom: -40,
                left: 20,
                child: _Avatar(
                  profile: profile,
                  heroTag: widget.heroTag,
                ),
              ),
            ],
          ),

          const SizedBox(height: 52), // space for avatar overflow

          // ── Name row ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: _C.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile.username,
                        style: const TextStyle(
                          fontSize: 14,
                          color: _C.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                // Follow button
               
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Bio ───────────────────────────────────────────────
          if (profile.bio != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                profile.bio!,
                style: const TextStyle(
                  fontSize: 14,
                  color: _C.textSecondary,
                  height: 1.5,
                ),
              ),
            ),

          const SizedBox(height: 16),

          // ── Niveau badge + XP ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _NiveauXpCard(
              niveau: profile.niveau,
              xp: profile.niveauXp,
              maxXp: profile.niveauMaxXp,
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// AVATAR
// ─────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final UserProfile profile;
  final String? heroTag;

  const _Avatar({required this.profile, this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag ?? 'avatar_${profile.id}',
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _C.bg, width: 3),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 6, 61, 25).withOpacity(0.35),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipOval(
          child: profile.avatarUrl != null
              ? Image.network(profile.avatarUrl!, fit: BoxFit.cover)
              : Container(
                  color: _C.surface,
                  child: Center(
                    child: Text(
                      profile.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: _C.textPrimary,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// NIVEAU + XP CARD
// ─────────────────────────────────────────
class _NiveauXpCard extends StatelessWidget {
  final String niveau;
  final int xp;
  final int maxXp;

  const _NiveauXpCard({
    required this.niveau,
    required this.xp,
    required this.maxXp,
  });

  Color get _accent => switch (niveau.toLowerCase()) {
        'débutant' => _C.exercise,
        'intermédiaire' => _C.stand,
        'avancé' => _C.purple,
        'expert' => _C.amber,
        _ => _C.textSecondary,
      };

  String get _emoji => switch (niveau.toLowerCase()) {
        'débutant' => '🌱',
        'intermédiaire' => '⚡',
        'avancé' => '🔥',
        'expert' => '👑',
        _ => '🏅',
      };

  @override
  Widget build(BuildContext context) {
    final progress = (xp / maxXp).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accent.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'Niveau $niveau',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _accent,
                ),
              ),
              const Spacer(),
              Text(
                '$xp / $maxXp XP',
                style: const TextStyle(
                  fontSize: 12,
                  color: _C.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: _C.surfaceElevated,
              valueColor: AlwaysStoppedAnimation<Color>(_accent),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${((1 - progress) * maxXp).round()} XP avant le prochain niveau',
            style: const TextStyle(
              fontSize: 11,
              color: _C.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// TAB 1 — OVERVIEW
// ─────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final UserProfile profile;

  const _OverviewTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    final reach = profile.reach;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      children: [
        // ── 3 ring-style hero stats ───────────────────────────
        Row(
          children: [
            Expanded(
              child: _RingStat(
                label: 'Séances',
                value: '${reach.totalWorkouts}',
                color: _C.exercise,
                icon: CupertinoIcons.flame_fill,
                progress: 0.82,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _RingStat(
                label: 'Série actuelle',
                value: '${reach.currentStreak}j',
                color: _C.stand,
                icon: CupertinoIcons.bolt_fill,
                progress: reach.currentStreak / reach.longestStreak,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _RingStat(
                label: 'Calories',
                value: '${(reach.totalKcal / 1000).toStringAsFixed(1)}k',
                color: _C.move,
                icon: CupertinoIcons.heart_fill,
                progress: 0.68,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ── Secondary stats ───────────────────────────────────
        _GroupCard(
          children: [
            _StatRow(
              label: 'Temps total d\'entraînement',
              value: _formatMinutes(reach.totalMinutes),
              icon: CupertinoIcons.time,
              color: _C.amber,
            ),
            _Divider(),
            _StatRow(
              label: 'Meilleure série',
              value: '${reach.longestStreak} jours 🏆',
              icon: CupertinoIcons.rosette,
              color: _C.purple,
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ── Workout distribution ──────────────────────────────
        _SectionLabel(label: 'Types d\'entraînement'),
        const SizedBox(height: 10),
        _GroupCard(
          children: _buildDistribution(reach.workoutsByType),
        ),
      ],
    );
  }

  String _formatMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h}h ${m}min';
  }

  List<Widget> _buildDistribution(Map<String, int> map) {
    final total = map.values.fold(0, (a, b) => a + b);
    final colors = [_C.exercise, _C.move, _C.stand, _C.purple, _C.amber];
    final entries = map.entries.toList();

    final List<Widget> rows = [];
    for (int i = 0; i < entries.length; i++) {
      final e = entries[i];
      final pct = e.value / total;
      final color = colors[i % colors.length];

      rows.add(_DistributionRow(
        label: e.key,
        count: e.value,
        pct: pct,
        color: color,
      ));
      if (i < entries.length - 1) rows.add(_Divider());
    }
    return rows;
  }
}

// ─────────────────────────────────────────
// RING STAT CARD (Apple Fitness ring style)
// ─────────────────────────────────────────
class _RingStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final double progress;

  const _RingStat({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 5,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      color.withOpacity(0.15)),
                ),
                CircularProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  strokeWidth: 5,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: _C.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// GROUP CARD (iOS settings-style)
// ─────────────────────────────────────────
class _GroupCard extends StatelessWidget {
  final List<Widget> children;

  const _GroupCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: _C.textPrimary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: _C.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DistributionRow extends StatelessWidget {
  final String label;
  final int count;
  final double pct;
  final Color color;

  const _DistributionRow({
    required this.label,
    required this.count,
    required this.pct,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: _C.textPrimary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Text(
                '$count séances',
                style: const TextStyle(
                  fontSize: 13,
                  color: _C.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: color.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 60),
      child: Divider(height: 0, thickness: 0.5, color: _C.separator),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _C.textSecondary,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// TAB 2 — POSTS
// ─────────────────────────────────────────
class _PostsTab extends StatelessWidget {
  final List<UserPost> posts;

  const _PostsTab({required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const _EmptyState(
        emoji: '📝',
        message: 'Aucun post publié',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      itemCount: posts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.post.content,
            style: const TextStyle(
              fontSize: 15,
              color: _C.textPrimary,
              height: 1.5,
              letterSpacing: -0.1,
            ),
          ),
          if (widget.post.imageUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.post.imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 180,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                _timeAgo(widget.post.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: _C.textTertiary,
                ),
              ),
              const Spacer(),
              // Like button
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 0,
                onPressed: () => setState(() => _liked = !_liked),
                child: Row(
                  children: [
                    Icon(
                      _liked
                          ? CupertinoIcons.heart_fill
                          : CupertinoIcons.heart,
                      size: 16,
                      color: _liked ? _C.move : _C.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.post.likes + (_liked ? 1 : 0)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _liked ? _C.move : _C.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  const Icon(CupertinoIcons.chat_bubble,
                      size: 16, color: _C.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.post.comments}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _C.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours}h';
    return 'il y a ${diff.inDays}j';
  }
}

// ─────────────────────────────────────────
// TAB 3 — EVENTS
// ─────────────────────────────────────────
class _EventsTab extends StatelessWidget {
  final List<UserEvent> events;

  const _EventsTab({required this.events});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const _EmptyState(emoji: '📅', message: 'Aucun événement créé');
    }

    final now = DateTime.now();
    final upcoming = events.where((e) => e.date.isAfter(now)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final past = events.where((e) => !e.date.isAfter(now)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      children: [
        if (upcoming.isNotEmpty) ...[
          _SectionLabel(label: 'À venir'),
          const SizedBox(height: 10),
          _GroupCard(
            children: [
              for (int i = 0; i < upcoming.length; i++) ...[
                _EventRow(event: upcoming[i], isPast: false),
                if (i < upcoming.length - 1) _Divider(),
              ],
            ],
          ),
          const SizedBox(height: 24),
        ],
        if (past.isNotEmpty) ...[
          _SectionLabel(label: 'Passés'),
          const SizedBox(height: 10),
          _GroupCard(
            children: [
              for (int i = 0; i < past.length; i++) ...[
                _EventRow(event: past[i], isPast: true),
                if (i < past.length - 1) _Divider(),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _EventRow extends StatelessWidget {
  final UserEvent event;
  final bool isPast;

  const _EventRow({required this.event, required this.isPast});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isPast ? 0.5 : 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Date block
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isPast
                    ? _C.surfaceElevated
                    : _C.move.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _monthShort(event.date),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isPast ? _C.textTertiary : _C.move,
                    ),
                  ),
                  Text(
                    '${event.date.day}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isPast ? _C.textSecondary : _C.move,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _C.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    event.location,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _C.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _CategoryChip(label: event.category),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(CupertinoIcons.person_2,
                        size: 12, color: _C.textTertiary),
                    const SizedBox(width: 3),
                    Text(
                      '${event.participants}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: _C.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _monthShort(DateTime dt) {
    const months = [
      'JAN', 'FÉV', 'MAR', 'AVR', 'MAI', 'JUN',
      'JUL', 'AOÛ', 'SEP', 'OCT', 'NOV', 'DÉC'
    ];
    return months[dt.month - 1];
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;

  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _C.surfaceElevated,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _C.textSecondary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String emoji;
  final String message;

  const _EmptyState({required this.emoji, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              fontSize: 15,
              color: _C.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// LOADING SKELETON
// ─────────────────────────────────────────
class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: _C.bg,
        elevation: 0,
        leading: const CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: null,
          child: Icon(CupertinoIcons.chevron_back, color: _C.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Shimmer(width: double.infinity, height: 100, radius: 0),
          const SizedBox(height: 52),
          Row(
            children: [
              Expanded(child: _Shimmer(width: 160, height: 22, radius: 6)),
              const SizedBox(width: 16),
              _Shimmer(width: 80, height: 38, radius: 20),
            ],
          ),
          const SizedBox(height: 16),
          _Shimmer(width: double.infinity, height: 80, radius: 16),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _Shimmer(width: double.infinity, height: 110, radius: 18)),
              const SizedBox(width: 10),
              Expanded(child: _Shimmer(width: double.infinity, height: 110, radius: 18)),
              const SizedBox(width: 10),
              Expanded(child: _Shimmer(width: double.infinity, height: 110, radius: 18)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Shimmer extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const _Shimmer({required this.width, required this.height, required this.radius});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
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
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(
              _C.surface, _C.surfaceElevated, _anim.value),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// ERROR STATE
// ─────────────────────────────────────────
class _ProfileError extends StatelessWidget {
  final String error;

  const _ProfileError({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.exclamationmark_circle,
                size: 44, color: _C.move),
            const SizedBox(height: 16),
            const Text(
              'Impossible de charger ce profil',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(fontSize: 13, color: _C.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}