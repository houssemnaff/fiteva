import 'package:flutter/foundation.dart';
import '../models/post_model.dart';
import '../screens/community/model/event_model.dart';
import '../screens/community/model/partner_model.dart';
import 'supabase_config.dart';

/// Service communauté — posts, likes, commentaires, événements, partenaires
/// Source de vérité : Supabase (tables posts, post_likes, post_comments,
///   community_events, event_participants, training_partners)
class CommunityComment {
  final String id;
  final String text;
  final String author;
  final DateTime createdAt;
  final String userId;

  const CommunityComment({
    required this.id,
    required this.text,
    required this.author,
    required this.createdAt,
    required this.userId,
  });
}

class CommunityService {
  static String? get _uid => SupabaseConfig.userId;

  // ────────────────────────────────────────────────────────────────────────────
  // POSTS
  // ────────────────────────────────────────────────────────────────────────────

  static Future<List<PostModel>> loadPosts() async {
    try {
      // Fetch posts without relying on PostgREST auto-join (requires FK in schema).
      final rows = await SupabaseConfig.table('posts')
          .select('id, user_id, title, content, image_url, likes_count, comments_count, created_at, category')
          .order('created_at', ascending: false)
          .limit(50) as List;

      if (rows.isEmpty) return [];

      // Batch-fetch usernames for all unique authors.
      final userIds = rows.map((r) => r['user_id'] as String).toSet().toList();
      final profileRows = await SupabaseConfig.table('user_profiles')
          .select('id, username')
          .inFilter('id', userIds) as List;

      final usernameMap = <String, String>{
        for (final p in profileRows)
          p['id'] as String: (p['username'] as String? ?? '').trim(),
      };

      return rows.map((r) {
        final userId = r['user_id'] as String? ?? '';
        final name = usernameMap[userId] ?? '';
        return PostModel(
          id:            r['id'] as String,
          userId:        userId,
          username:      name.isNotEmpty ? name : 'User',
          userAvatarUrl: '',
          title:         r['title'] as String? ?? '',
          content:       r['content'] as String? ?? '',
          imageUrl:      r['image_url'] as String? ?? '',
          likes:         r['likes_count'] as int? ?? 0,
          comments:      r['comments_count'] as int? ?? 0,
          timeAgo:       _timeAgo(r['created_at'] as String? ?? ''),
          category:      r['category'] as String? ?? '',
        );
      }).toList();
    } catch (e) {
      debugPrint('[CommunityService] loadPosts error: $e');
      return [];
    }
  }

  static Future<void> savePosts(List<PostModel> posts) async {
    // No-op : les posts sont insérés via addPost, pas remplacés en masse
  }

  static Future<PostModel?> addPost(PostModel post) async {
    if (_uid == null) {
      debugPrint('[CommunityService] addPost: user not authenticated (_uid is null)');
      return null;
    }
    try {
      // Ensure user_profiles row exists (no trigger in dev setup).
      await SupabaseConfig.table('user_profiles').upsert({
        'id':       _uid,
        'username': post.username.isNotEmpty ? post.username : 'User',
        'email':    SupabaseConfig.userEmail ?? '',
      }, onConflict: 'id');

      final row = await SupabaseConfig.table('posts').insert({
        'user_id':   _uid,
        'title':     post.title,
        'content':   post.content,
        'image_url': post.imageUrl.isNotEmpty ? post.imageUrl : '',
        'category':  _validCategory(post.category),
      }).select('id, title, content, image_url, likes_count, comments_count, created_at, category')
          .single();

      return PostModel(
        id:            row['id'] as String,
        userId:        _uid!,
        username:      post.username,
        userAvatarUrl: '',
        title:         row['title'] as String? ?? post.title,
        content:       row['content'] as String? ?? post.content,
        imageUrl:      row['image_url'] as String? ?? '',
        likes:         row['likes_count'] as int? ?? 0,
        comments:      row['comments_count'] as int? ?? 0,
        timeAgo:       'À l\'instant',
        category:      row['category'] as String? ?? '',
      );
    } catch (e) {
      debugPrint('[CommunityService] addPost error: $e');
      return null;
    }
  }

  // ── Likes ─────────────────────────────────────────────────────────────────

  static Future<Set<String>> loadLikedPosts() async {
    if (_uid == null) return {};
    try {
      final rows = await SupabaseConfig.table('post_likes')
          .select('post_id')
          .eq('user_id', _uid!);
      return {for (final r in rows as List) r['post_id'] as String};
    } catch (_) {
      return {};
    }
  }

  /// Met à jour le contenu et la catégorie d'un post existant.
  static Future<bool> updatePost(PostModel post) async {
    if (_uid == null) return false;
    try {
      await SupabaseConfig.table('posts').update({
        'title':    post.title,
        'content':  post.content,
        'category': _validCategory(post.category.isNotEmpty ? post.category : 'Other'),
      }).eq('id', post.id).eq('user_id', _uid!);
      return true;
    } catch (e) {
      debugPrint('[CommunityService] updatePost error: $e');
      return false;
    }
  }

  /// Supprime un post (seulement si user_id correspond).
  static Future<bool> deletePost(String postId) async {
    if (_uid == null) return false;
    try {
      await SupabaseConfig.table('posts')
          .delete()
          .eq('id', postId)
          .eq('user_id', _uid!);
      return true;
    } catch (e) {
      debugPrint('[CommunityService] deletePost error: $e');
      return false;
    }
  }

  static Future<void> likePost(String postId) async {
    if (_uid == null) return;
    try {
      await SupabaseConfig.table('post_likes')
          .insert({'user_id': _uid, 'post_id': postId});
    } catch (_) {}
  }

  static Future<void> unlikePost(String postId) async {
    if (_uid == null) return;
    try {
      await SupabaseConfig.table('post_likes')
          .delete()
          .eq('user_id', _uid!)
          .eq('post_id', postId);
    } catch (_) {}
  }

  /// Compatibilité avec l'ancienne API
  static Future<void> saveLikedPosts(Set<String> liked) async {}

  // ── Commentaires ──────────────────────────────────────────────────────────

  static Future<List<CommunityComment>> loadComments(String postId) async {
    try {
      final rows = await SupabaseConfig.table('post_comments')
          .select('id, content, user_id, created_at')
          .eq('post_id', postId)
          .order('created_at', ascending: true) as List;

      if (rows.isEmpty) return [];

      final userIds = rows
          .map((r) => (r['user_id'] as String? ?? '').trim())
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      final profileRows = userIds.isEmpty
          ? <Map<String, dynamic>>[]
          : await SupabaseConfig.table('user_profiles')
              .select('id, username')
              .inFilter('id', userIds) as List;

      final usernameMap = <String, String>{
        for (final p in profileRows)
          p['id'] as String: (p['username'] as String? ?? '').trim(),
      };

      return rows.map((r) {
        final userId = (r['user_id'] as String? ?? '').trim();
        final createdAt = DateTime.tryParse((r['created_at'] as String? ?? '')) ?? DateTime.now();
        final username = usernameMap[userId] ?? (userId == _uid ? 'Vous' : 'User');
        return CommunityComment(
          id: r['id'] as String? ?? '',
          text: r['content'] as String? ?? '',
          author: username.isNotEmpty ? username : 'User',
          createdAt: createdAt,
          userId: userId,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<CommunityComment?> addComment(String postId, String text) async {
    if (_uid == null) return null;
    try {
      final createdAt = DateTime.now();
      final row = await SupabaseConfig.table('post_comments').insert({
        'post_id':    postId,
        'user_id':    _uid,
        'content':    text,
        'created_at': createdAt.toIso8601String(),
      }).select('id, content, user_id, created_at').single();

      final username = await _currentUsername();
      return CommunityComment(
        id: row['id'] as String? ?? '',
        text: row['content'] as String? ?? text,
        author: username.isNotEmpty ? username : 'Vous',
        createdAt: DateTime.tryParse((row['created_at'] as String? ?? '')) ?? createdAt,
        userId: _uid!,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<String> _currentUsername() async {
    if (_uid == null) return 'Vous';
    try {
      final rows = await SupabaseConfig.table('user_profiles')
          .select('username')
          .eq('id', _uid!)
          .limit(1) as List;
      final username = rows.isNotEmpty ? (rows.first['username'] as String? ?? '').trim() : '';
      return username.isNotEmpty ? username : 'Vous';
    } catch (_) {
      return 'Vous';
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // ÉVÉNEMENTS
  // ────────────────────────────────────────────────────────────────────────────

  static Future<List<EventModel>> loadEvents() async {
    try {
      final rows = await SupabaseConfig.table('community_events')
          .select('id, organizer_id, title, event_type, event_date, event_time, '
              'location, max_spots, joined_count, image_url, description')
          .order('event_date') as List;

      if (rows.isEmpty) return [];

      // Batch-fetch organizer usernames.
      final orgIds = rows.map((r) => r['organizer_id'] as String).toSet().toList();
      final profileRows = await SupabaseConfig.table('user_profiles')
          .select('id, username')
          .inFilter('id', orgIds) as List;

      final usernameMap = <String, String>{
        for (final p in profileRows)
          p['id'] as String: (p['username'] as String? ?? '').trim(),
      };

      return rows.map((r) {
        final orgId = r['organizer_id'] as String? ?? '';
        final name  = usernameMap[orgId] ?? '';
        return EventModel(
          id:                 r['id'] as String,
          title:              r['title'] as String? ?? '',
          organizer:          name.isNotEmpty ? name : 'User',
          organizerAvatar:    '',
          type:               r['event_type'] as String? ?? 'other',
          date:               _formatDate(r['event_date'] as String? ?? ''),
          time:               r['event_time'] as String? ?? '',
          location:           r['location'] as String? ?? '',
          maxSpots:           r['max_spots'] as int? ?? 10,
          joinedCount:        r['joined_count'] as int? ?? 0,
          participantAvatars: [],
          imageUrl:           r['image_url'] as String? ?? '',
        );
      }).toList();
    } catch (e) {
      debugPrint('[CommunityService] loadEvents error: $e');
      return [];
    }
  }

  /// Crée un événement dans Supabase et le retourne.
  static Future<EventModel?> addEvent(EventModel event) async {
    if (_uid == null) {
      debugPrint('[CommunityService] addEvent: user not authenticated');
      return null;
    }
    try {
      // Ensure user_profiles row exists.
      await SupabaseConfig.table('user_profiles').upsert({
        'id':       _uid,
        'username': event.organizer.isNotEmpty ? event.organizer : 'User',
        'email':    SupabaseConfig.userEmail ?? '',
      }, onConflict: 'id');

      final row = await SupabaseConfig.table('community_events').insert({
        'organizer_id': _uid,
        'title':        event.title,
        'event_type':   _validEventType(event.type),
        'event_date':   event.date,          // ISO format 'YYYY-MM-DD' from sheet
        'event_time':   event.time,          // 'HH:mm'
        'location':     event.location,
        'max_spots':    event.maxSpots,
        'image_url':    event.imageUrl.isNotEmpty ? event.imageUrl : '',
        'description':  '',
        'joined_count': 0,
      }).select('id, title, event_type, event_date, event_time, location, '
                'max_spots, joined_count, image_url')
          .single();

      return EventModel(
        id:                 row['id'] as String,
        title:              row['title'] as String? ?? event.title,
        organizer:          event.organizer,
        organizerAvatar:    '',
        type:               row['event_type'] as String? ?? 'other',
        date:               _formatDate(row['event_date'] as String? ?? ''),
        time:               row['event_time'] as String? ?? event.time,
        location:           row['location'] as String? ?? event.location,
        maxSpots:           row['max_spots'] as int? ?? event.maxSpots,
        joinedCount:        0,
        participantAvatars: [],
        imageUrl:           row['image_url'] as String? ?? '',
      );
    } catch (e) {
      debugPrint('[CommunityService] addEvent error: $e');
      return null;
    }
  }

  static Future<void> saveEvents(List<EventModel> events) async {}

  static Future<Set<String>> loadJoinedEvents() async {
    if (_uid == null) return {};
    try {
      final rows = await SupabaseConfig.table('event_participants')
          .select('event_id')
          .eq('user_id', _uid!);
      return {for (final r in rows as List) r['event_id'] as String};
    } catch (_) {
      return {};
    }
  }

  static Future<void> joinEvent(String eventId) async {
    if (_uid == null) return;
    try {
      await SupabaseConfig.table('event_participants')
          .insert({'user_id': _uid, 'event_id': eventId});
    } catch (_) {}
  }

  static Future<void> leaveEvent(String eventId) async {
    if (_uid == null) return;
    try {
      await SupabaseConfig.table('event_participants')
          .delete()
          .eq('user_id', _uid!)
          .eq('event_id', eventId);
    } catch (_) {}
  }

  static Future<void> saveJoinedEvents(Set<String> joined) async {}

  /// Retourne la liste des participants d'un événement avec leur nom.
  static Future<List<Map<String, dynamic>>> getEventParticipants(
      String eventId) async {
    try {
      final rows = await SupabaseConfig.table('event_participants')
          .select('user_id')
          .eq('event_id', eventId) as List;

      if (rows.isEmpty) return [];

      final userIds = rows.map((r) => r['user_id'] as String).toList();
      final profileRows = await SupabaseConfig.table('user_profiles')
          .select('id, username')
          .inFilter('id', userIds) as List;

      return profileRows.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[CommunityService] getEventParticipants error: $e');
      return [];
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // PARTENAIRES
  // ────────────────────────────────────────────────────────────────────────────

  static Future<List<PartnerModel>> loadPartners() async {
    try {
      final rows = await SupabaseConfig.table('training_partners')
          .select('id, user_id, name, avatar_url, goal, level, region, '
              'frequency, description, tags')
          .order('created_at', ascending: false)
          .limit(50);
      return (rows as List).map((r) => _partnerFromRow(r as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('[CommunityService] loadPartners error: $e');
      return [];
    }
  }

  /// Crée un profil partenaire dans Supabase et le retourne.
  static Future<PartnerModel?> addPartner(PartnerModel partner) async {
    if (_uid == null) {
      debugPrint('[CommunityService] addPartner: user not authenticated');
      return null;
    }
    try {
      await SupabaseConfig.table('user_profiles').upsert({
        'id':       _uid,
        'username': partner.name.isNotEmpty ? partner.name : 'User',
        'email':    SupabaseConfig.userEmail ?? '',
      }, onConflict: 'id');

      final row = await SupabaseConfig.table('training_partners').insert({
        'user_id':     _uid,
        'name':        partner.name,
        'avatar_url':  '',
        'goal':        partner.goal,
        'level':       partner.level,
        'region':      partner.region,
        'frequency':   partner.frequency,
        'description': partner.description,
        'tags':        partner.tags,
      }).select('id, user_id, name, avatar_url, goal, level, region, '
                'frequency, description, tags')
          .single();

      return _partnerFromRow(row);
    } catch (e) {
      debugPrint('[CommunityService] addPartner error: $e');
      return null;
    }
  }

  static Future<void> savePartners(List<PartnerModel> partners) async {}

  // ────────────────────────────────────────────────────────────────────────────
  // PROFIL UTILISATEUR (pour la vue profil communauté)
  // ────────────────────────────────────────────────────────────────────────────

  /// Récupère les données publiques d'un utilisateur par son UUID Supabase.
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final profile = await SupabaseConfig.table('user_profiles')
          .select('id, username, email')
          .eq('id', userId)
          .maybeSingle();
      if (profile == null) return null;

      final xpRow = await SupabaseConfig.table('user_xp')
          .select('total_xp, streak')
          .eq('user_id', userId)
          .maybeSingle();

      final bioRow = await SupabaseConfig.table('user_biometrics')
          .select('fitness_level, frequency_days')
          .eq('user_id', userId)
          .maybeSingle();

      return {
        'id':             profile['id'] as String,
        'username':       (profile['username'] as String? ?? '').trim(),
        'total_xp':       xpRow?['total_xp'] as int? ?? 0,
        'streak':         xpRow?['streak'] as int? ?? 0,
        'fitness_level':  bioRow?['fitness_level'] as String? ?? '',
        'frequency_days': bioRow?['frequency_days'] as int? ?? 3,
      };
    } catch (e) {
      debugPrint('[CommunityService] getUserProfile error: $e');
      return null;
    }
  }

  /// Posts publiés par un utilisateur (pour l'onglet Posts du profil).
  static Future<List<Map<String, dynamic>>> getUserPosts(String userId) async {
    try {
      final rows = await SupabaseConfig.table('posts')
          .select('id, content, image_url, likes_count, comments_count, created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(30) as List;
      return rows.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[CommunityService] getUserPosts error: $e');
      return [];
    }
  }

  /// Événements organisés par un utilisateur (pour l'onglet Événements du profil).
  static Future<List<Map<String, dynamic>>> getUserEvents(String userId) async {
    try {
      final rows = await SupabaseConfig.table('community_events')
          .select('id, title, event_type, event_date, event_time, location, joined_count')
          .eq('organizer_id', userId)
          .order('event_date', ascending: false)
          .limit(20) as List;
      return rows.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[CommunityService] getUserEvents error: $e');
      return [];
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ────────────────────────────────────────────────────────────────────────────

  static const _validCategories = {'Challenge', 'Workout', 'Nutrition', 'Lifestyle', 'Other'};

  static String _validCategory(String cat) =>
      _validCategories.contains(cat) ? cat : 'Other';

  static const _validEventTypes = {'running', 'yoga', 'gym', 'cycling', 'swimming', 'other'};

  static String _validEventType(String type) =>
      _validEventTypes.contains(type.toLowerCase()) ? type.toLowerCase() : 'other';

  /// Converts ISO date '2025-05-03' → display string 'Sam 3 Mai'.
  static String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      const months = ['Jan','Fév','Mar','Avr','Mai','Jun','Jul','Aoû','Sep','Oct','Nov','Déc'];
      const days   = ['Lun','Mar','Mer','Jeu','Ven','Sam','Dim'];
      return '${days[dt.weekday - 1]} ${dt.day} ${months[dt.month - 1]}';
    } catch (_) {
      return iso;
    }
  }

  static PartnerModel _partnerFromRow(Map<String, dynamic> r) => PartnerModel(
    id:          r['id'] as String,
    userId:      r['user_id'] as String? ?? '',
    name:        r['name'] as String? ?? '',
    avatar:      r['avatar_url'] as String? ?? '',
    goal:        r['goal'] as String? ?? '',
    level:       r['level'] as String? ?? '',
    region:      r['region'] as String? ?? '',
    frequency:   r['frequency'] as String? ?? '',
    description: r['description'] as String? ?? '',
    tags:        List<String>.from(r['tags'] as List? ?? []),
  );

  static String _timeAgo(String createdAt) {
    if (createdAt.isEmpty) return '';
    try {
      final dt   = DateTime.parse(createdAt).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'À l\'instant';
      if (diff.inHours   < 1) return 'Il y a ${diff.inMinutes} min';
      if (diff.inDays    < 1) return 'Il y a ${diff.inHours}h';
      if (diff.inDays    < 7) return 'Il y a ${diff.inDays}j';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }
}
