import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../models/post_model.dart';
import '../../providers/mock_data_provider.dart';
import '../../theme/app_theme.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
    
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8FAFF), Color(0xFFF7F8FC)],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: false,
              elevation: 0,
              backgroundColor: Colors.white.withOpacity(0.92),
              surfaceTintColor: Colors.transparent,
            
              title: const Text('Community'),
              centerTitle: false,
              actions: [
                IconButton(
                  onPressed: () => _showComposerSheet(context),
                  icon: const Icon(LucideIcons.penTool, size: 20),
                ),
               
              ],
           
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                child: _CreatePostPrompt(
                  onTap: () => _showComposerSheet(context),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: _SectionHeader(
                  title: 'Trending now',
                  actionLabel: 'See all',
                  onActionTap: () {},
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final item = _filters[index];
                      final selected = index == 0;
                      return _FilterChip(
                        label: item,
                        selected: selected,
                      );
                    },
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 96),
              sliver: SliverList.separated(
                itemCount: posts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 18),
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return _PostCard(post: post);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<String> _filters = [
    'For you',
    'Workout',
    'Nutrition',
    'Events',
    'Support',
  ];

  void _showComposerSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _ComposerSheet(),
    );
  }
}

class _CreatePostPrompt extends StatelessWidget {
  final VoidCallback onTap;

  const _CreatePostPrompt({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(LucideIcons.penTool, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Share something',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Text, photo, or a community event',
                    style: TextStyle(color: AppTheme.textSecondaryColor),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, color: AppTheme.textSecondaryColor),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onActionTap;

  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        TextButton(
          onPressed: onActionTap,
          child: Text(actionLabel),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _FilterChip({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: selected ? AppTheme.primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: selected ? AppTheme.primaryColor : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppTheme.textPrimaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _PostCard extends ConsumerWidget {
  final PostModel post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasImage = post.imageUrl.trim().isNotEmpty;
    final joinedState = ref.watch(eventJoinStateProvider);
    final currentUser = ref.watch(userProvider);
    final participants = joinedState[post.id] ?? post.initialParticipants;
    final isJoined = participants.any((user) => user.id == currentUser.id);
    final isFull = post.maxParticipants != null && participants.length >= post.maxParticipants!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(post.userAvatarUrl),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.username,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        post.timeAgo,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.moreHorizontal),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              post.content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.45,
                  ),
            ),
          ),
          if (post.isEvent) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _EventInfoCard(
                post: post,
                participants: participants,
                isJoined: isJoined,
                isFull: isFull,
                onJoin: () {
                  final joined = ref.read(eventJoinStateProvider.notifier).joinEvent(
                    postId: post.id,
                    participant: EventParticipant(
                      id: currentUser.id,
                      name: currentUser.name,
                      avatarUrl: currentUser.avatarUrl,
                    ),
                    maxParticipants: post.maxParticipants,
                  );

                  if (!joined) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Event is full now.')),
                    );
                  }
                },
                onViewDetails: () => _showEventDetailsSheet(
                  context: context,
                  post: post,
                  participants: participants,
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          if (hasImage)
            Container(
              height: 230,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(post.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _ActionStat(icon: LucideIcons.heart, value: '${post.likes}'),
                const SizedBox(width: 18),
                _ActionStat(icon: LucideIcons.messageCircle, value: '${post.comments}'),
                const Spacer(),
                const Icon(LucideIcons.share2, color: AppTheme.textSecondaryColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

void _showEventDetailsSheet({
  required BuildContext context,
  required PostModel post,
  required List<EventParticipant> participants,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _EventDetailsSheet(
      post: post,
      participants: participants,
    ),
  );
}

class _EventInfoCard extends StatelessWidget {
  final PostModel post;
  final List<EventParticipant> participants;
  final bool isJoined;
  final bool isFull;
  final VoidCallback onJoin;
  final VoidCallback onViewDetails;

  const _EventInfoCard({
    required this.post,
    required this.participants,
    required this.isJoined,
    required this.isFull,
    required this.onJoin,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.calendarDays, size: 16, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  post.eventTitle ?? 'Community event',
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${participants.length}/${post.maxParticipants ?? '-'}',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('Date: ${post.eventDate ?? '-'}'),
          Text('Heure: ${post.eventTime ?? '-'}'),
          Text('Lieu: ${post.eventLocation ?? '-'}'),
          Text('Max participants: ${post.maxParticipants ?? '-'}'),
          const SizedBox(height: 10),
          if (participants.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: participants
                  .map(
                    (user) => Chip(
                      avatar: CircleAvatar(backgroundImage: NetworkImage(user.avatarUrl)),
                      label: Text(user.name),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (!isJoined)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isFull ? null : onJoin,
                    icon: const Icon(Icons.person_add_alt_1, size: 18),
                    label: Text(isFull ? 'Complet' : 'Join event'),
                  ),
                )
              else
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onViewDetails,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('View full details'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EventDetailsSheet extends StatelessWidget {
  final PostModel post;
  final List<EventParticipant> participants;

  const _EventDetailsSheet({
    required this.post,
    required this.participants,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                post.eventTitle ?? 'Event details',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(post.content),
              const SizedBox(height: 14),
              _EventDetailRow(icon: LucideIcons.calendarDays, text: post.eventDate ?? '-'),
              const SizedBox(height: 8),
              _EventDetailRow(icon: LucideIcons.clock3, text: post.eventTime ?? '-'),
              const SizedBox(height: 8),
              _EventDetailRow(icon: LucideIcons.mapPin, text: post.eventLocation ?? '-'),
              const SizedBox(height: 8),
              _EventDetailRow(
                icon: LucideIcons.users,
                text: 'Participants: ${participants.length}/${post.maxParticipants ?? '-'}',
              ),
              const SizedBox(height: 14),
              Text(
                'Joined users',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 10),
              if (participants.isEmpty)
                const Text(
                  'No users joined yet.',
                  style: TextStyle(color: AppTheme.textSecondaryColor),
                )
              else
                ...participants.map(
                  (user) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(backgroundImage: NetworkImage(user.avatarUrl)),
                    title: Text(user.name),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventDetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EventDetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryColor),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _ActionStat extends StatelessWidget {
  final IconData icon;
  final String value;

  const _ActionStat({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textSecondaryColor),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String label;
  final String value;

  const _HeaderStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.72),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComposerSheet extends StatefulWidget {
  const _ComposerSheet();

  @override
  State<_ComposerSheet> createState() => _ComposerSheetState();
}

class _ComposerSheetState extends State<_ComposerSheet> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  String _selectedType = 'Text';
  String _selectedAudience = 'Friends';

  static const List<String> _types = ['Text', 'Image', 'Event'];
  static const List<String> _audiences = ['Friends', 'Community', 'Public'];

  @override
  void dispose() {
    _textController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Create post',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Share text, an image, or a community event.',
                  style: TextStyle(color: AppTheme.textSecondaryColor),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _types
                      .map(
                        (type) => ChoiceChip(
                          label: Text(type),
                          selected: _selectedType == type,
                          onSelected: (_) {
                            setState(() => _selectedType = type);
                          },
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title / short description',
                    hintText: 'Weekend tennis match, looking for 2 friends...',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _textController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: _selectedType == 'Event'
                        ? 'Event details'
                        : _selectedType == 'Image'
                            ? 'Caption'
                            : 'Your post',
                    hintText: _selectedType == 'Event'
                        ? 'Date, place, time, and what people should bring...'
                        : _selectedType == 'Image'
                            ? 'Write a short caption for your photo...'
                            : 'Write something supportive, inspiring, or helpful...',
                  ),
                ),
                if (_selectedType == 'Image') ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FC),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: const [
                        Icon(LucideIcons.imagePlus, color: AppTheme.primaryColor),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Image upload preview is static in this demo.',
                            style: TextStyle(color: AppTheme.textSecondaryColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_selectedType == 'Event') ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _ComposerInfoTile(
                          icon: LucideIcons.calendarDays,
                          label: 'Date',
                          value: 'Sat, 12 Apr',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ComposerInfoTile(
                          icon: LucideIcons.mapPin,
                          label: 'Location',
                          value: 'City court',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _ComposerInfoTile(
                    icon: LucideIcons.users,
                    label: 'Looking for',
                    value: 'Friends to join a tennis match',
                  ),
                ],
                const SizedBox(height: 18),
                Text(
                  'Audience',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _audiences
                      .map(
                        (audience) => ChoiceChip(
                          label: Text(audience),
                          selected: _selectedAudience == audience,
                          onSelected: (_) {
                            setState(() => _selectedAudience = audience);
                          },
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _selectedType == 'Event'
                                    ? 'Static event draft ready: ${_titleController.text.isEmpty ? 'Tennis match' : _titleController.text}'
                                    : 'Static post draft ready: ${_titleController.text.isEmpty ? 'New community post' : _titleController.text}',
                              ),
                            ),
                          );
                        },
                        child: const Text('Publish'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ComposerInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ComposerInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
