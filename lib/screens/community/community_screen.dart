import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/mock_data_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/post_model.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(LucideIcons.penTool, color: Colors.white),
        onPressed: () {},
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: posts.length,
        separatorBuilder: (context, index) => const SizedBox(height: 24),
        itemBuilder: (context, index) {
          final post = posts[index];
          return _buildPostCard(context, post);
        },
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, PostModel post) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                  backgroundImage: NetworkImage(post.userAvatarUrl),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.username, style: Theme.of(context).textTheme.titleMedium),
                      Text(post.timeAgo, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
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
            child: Text(post.content, style: Theme.of(context).textTheme.bodyLarge),
          ),
          const SizedBox(height: 16),
          Image.network(
            post.imageUrl,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.heart, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('${post.likes}'),
                  ],
                ),
                const SizedBox(width: 24),
                Row(
                  children: [
                    const Icon(LucideIcons.messageCircle, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('${post.comments}'),
                  ],
                ),
                const Spacer(),
                const Icon(LucideIcons.share, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
