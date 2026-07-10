import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/post_model.dart';
import '../screens/community/model/event_model.dart';
import '../screens/community/model/partner_model.dart';
import 'cloudinary_config.dart';
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

      // Batch-fetch usernames + mascotte pour tous les auteurs concernés.
      final userIds = rows.map((r) => r['user_id'] as String).toSet().toList();
      final profileRows = await SupabaseConfig.table('public_profiles')
          .select('id, username, mascot_type, mascot_mood, is_pro')
          .inFilter('id', userIds) as List;

      final usernameMap = <String, String>{
        for (final p in profileRows)
          p['id'] as String: (p['username'] as String? ?? '').trim(),
      };
      final mascotTypeMap = <String, String>{
        for (final p in profileRows)
          p['id'] as String: (p['mascot_type'] as String? ?? 'blob'),
      };
      final mascotMoodMap = <String, String>{
        for (final p in profileRows)
          p['id'] as String: (p['mascot_mood'] as String? ?? 'happy'),
      };
      final isProMap = <String, bool>{
        for (final p in profileRows)
          p['id'] as String: (p['is_pro'] as bool? ?? false),
      };

      return rows.map((r) {
        final userId = r['user_id'] as String? ?? '';
        final name = usernameMap[userId] ?? '';
        return PostModel(
          id:            r['id'] as String,
          userId:        userId,
          username:      name.isNotEmpty ? name : 'User',
          userAvatarUrl: '',
          mascotType:    mascotTypeMap[userId] ?? 'blob',
          mascotMood:    mascotMoodMap[userId] ?? 'happy',
          title:         r['title'] as String? ?? '',
          content:       r['content'] as String? ?? '',
          imageUrl:      r['image_url'] as String? ?? '',
          likes:         r['likes_count'] as int? ?? 0,
          comments:      r['comments_count'] as int? ?? 0,
          timeAgo:       _timeAgo(r['created_at'] as String? ?? ''),
          category:      r['category'] as String? ?? '',
          isPro:         isProMap[userId] ?? false,
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
        'title':     post.title,
        'content':   post.content,
        'image_url': post.imageUrl,
        'category':  _validCategory(post.category.isNotEmpty ? post.category : 'Other'),
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
          : await SupabaseConfig.table('public_profiles')
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

  /// Upload une photo de couverture d'événement vers Cloudinary et retourne
  /// son URL publique.
  static Future<String?> uploadEventImage(XFile file) async {
    if (_uid == null) return null;
    return CloudinaryConfig.uploadImage(file);
  }

  static Future<List<EventModel>> loadEvents() async {
    try {
      final rows = await SupabaseConfig.table('community_events')
          .select('id, organizer_id, title, event_type, event_date, event_time, '
              'location, max_spots, joined_count, image_url, description, '
              'contact_whatsapp, contact_instagram, contact_facebook')
          .order('event_date') as List;

      if (rows.isEmpty) return [];

      // Batch-fetch usernames + mascotte des organisateurs.
      final orgIds = rows.map((r) => r['organizer_id'] as String).toSet().toList();
      final profileRows = await SupabaseConfig.table('public_profiles')
          .select('id, username, mascot_type, mascot_mood, is_pro')
          .inFilter('id', orgIds) as List;

      final usernameMap = <String, String>{
        for (final p in profileRows)
          p['id'] as String: (p['username'] as String? ?? '').trim(),
      };
      final mascotTypeMap = <String, String>{
        for (final p in profileRows)
          p['id'] as String: (p['mascot_type'] as String? ?? 'blob'),
      };
      final mascotMoodMap = <String, String>{
        for (final p in profileRows)
          p['id'] as String: (p['mascot_mood'] as String? ?? 'happy'),
      };
      final isProMap = <String, bool>{
        for (final p in profileRows)
          p['id'] as String: (p['is_pro'] as bool? ?? false),
      };

      return rows.map((r) {
        final orgId = r['organizer_id'] as String? ?? '';
        final name  = usernameMap[orgId] ?? '';
        return EventModel(
          id:                 r['id'] as String,
          title:              r['title'] as String? ?? '',
          organizer:          name.isNotEmpty ? name : 'User',
          organizerId:        orgId,
          organizerAvatar:    '',
          organizerMascotType: mascotTypeMap[orgId] ?? 'blob',
          organizerMascotMood: mascotMoodMap[orgId] ?? 'happy',
          organizerIsPro:     isProMap[orgId] ?? false,
          type:               r['event_type'] as String? ?? 'other',
          date:               _formatDate(r['event_date'] as String? ?? ''),
          dateIso:            r['event_date'] as String? ?? '',
          time:               r['event_time'] as String? ?? '',
          location:           r['location'] as String? ?? '',
          maxSpots:           r['max_spots'] as int? ?? 10,
          joinedCount:        r['joined_count'] as int? ?? 0,
          participantAvatars: [],
          imageUrl:           r['image_url'] as String? ?? '',
          description:        r['description'] as String? ?? '',
          contactWhatsapp:    r['contact_whatsapp'] as String? ?? '',
          contactInstagram:   r['contact_instagram'] as String? ?? '',
          contactFacebook:    r['contact_facebook'] as String? ?? '',
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
        'description':  event.description,
        'joined_count': 0,
        'contact_whatsapp':  event.contactWhatsapp,
        'contact_instagram': event.contactInstagram,
        'contact_facebook':  event.contactFacebook,
      }).select('id, title, event_type, event_date, event_time, location, '
                'max_spots, joined_count, image_url, description, '
                'contact_whatsapp, contact_instagram, contact_facebook')
          .single();

      return EventModel(
        id:                 row['id'] as String,
        title:              row['title'] as String? ?? event.title,
        organizer:          event.organizer,
        organizerId:        _uid!,
        organizerAvatar:    '',
        type:               row['event_type'] as String? ?? 'other',
        date:               _formatDate(row['event_date'] as String? ?? ''),
        dateIso:            row['event_date'] as String? ?? event.dateIso,
        time:               row['event_time'] as String? ?? event.time,
        location:           row['location'] as String? ?? event.location,
        maxSpots:           row['max_spots'] as int? ?? event.maxSpots,
        joinedCount:        0,
        participantAvatars: [],
        imageUrl:           row['image_url'] as String? ?? '',
        description:        row['description'] as String? ?? event.description,
        contactWhatsapp:    row['contact_whatsapp'] as String? ?? '',
        contactInstagram:   row['contact_instagram'] as String? ?? '',
        contactFacebook:    row['contact_facebook'] as String? ?? '',
      );
    } catch (e) {
      debugPrint('[CommunityService] addEvent error: $e');
      return null;
    }
  }

  /// Met à jour un événement existant (uniquement si organizer_id correspond).
  /// Le nombre de places ne peut jamais être réduit sous le nombre d'inscrits.
  static Future<EventModel?> updateEvent(EventModel event) async {
    if (_uid == null) return null;
    try {
      final current = await SupabaseConfig.table('community_events')
          .select('joined_count')
          .eq('id', event.id)
          .maybeSingle();
      final joinedCount = current?['joined_count'] as int? ?? 0;
      if (event.maxSpots < joinedCount) {
        debugPrint('[CommunityService] updateEvent: maxSpots below joinedCount');
        return null;
      }

      final row = await SupabaseConfig.table('community_events').update({
        'title':        event.title,
        'event_type':   _validEventType(event.type),
        'event_date':   event.dateIso,
        'event_time':   event.time,
        'location':     event.location,
        'max_spots':    event.maxSpots,
        'image_url':    event.imageUrl,
        'description':  event.description,
        'contact_whatsapp':  event.contactWhatsapp,
        'contact_instagram': event.contactInstagram,
        'contact_facebook':  event.contactFacebook,
      }).eq('id', event.id).eq('organizer_id', _uid!)
          .select('id, title, event_type, event_date, event_time, location, '
                  'max_spots, joined_count, image_url, description, '
                  'contact_whatsapp, contact_instagram, contact_facebook')
          .single();

      return event.copyWith(
        title:              row['title'] as String? ?? event.title,
        type:               row['event_type'] as String? ?? event.type,
        date:               _formatDate(row['event_date'] as String? ?? ''),
        dateIso:            row['event_date'] as String? ?? event.dateIso,
        time:               row['event_time'] as String? ?? event.time,
        location:           row['location'] as String? ?? event.location,
        maxSpots:           row['max_spots'] as int? ?? event.maxSpots,
        joinedCount:        row['joined_count'] as int? ?? event.joinedCount,
        imageUrl:           row['image_url'] as String? ?? event.imageUrl,
        description:        row['description'] as String? ?? event.description,
        contactWhatsapp:    row['contact_whatsapp'] as String? ?? '',
        contactInstagram:   row['contact_instagram'] as String? ?? '',
        contactFacebook:    row['contact_facebook'] as String? ?? '',
      );
    } catch (e) {
      debugPrint('[CommunityService] updateEvent error: $e');
      return null;
    }
  }

  /// Supprime un événement (uniquement si organizer_id correspond).
  static Future<bool> deleteEvent(String eventId) async {
    if (_uid == null) return false;
    try {
      await SupabaseConfig.table('community_events')
          .delete()
          .eq('id', eventId)
          .eq('organizer_id', _uid!);
      return true;
    } catch (e) {
      debugPrint('[CommunityService] deleteEvent error: $e');
      return false;
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
      final profileRows = await SupabaseConfig.table('public_profiles')
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

  static const _partnerColumns =
      'id, user_id, name, avatar_url, goal, level, region, frequency, '
      'description, tags, contact_whatsapp, contact_instagram, contact_facebook';

  static Future<List<PartnerModel>> loadPartners() async {
    try {
      final rows = (await SupabaseConfig.table('training_partners')
          .select(_partnerColumns)
          .order('created_at', ascending: false)
          .limit(50) as List)
          .cast<Map<String, dynamic>>();
      if (rows.isEmpty) return [];

      // Batch-fetch la mascotte des auteurs (pas stockée sur training_partners).
      final userIds = rows
          .map((r) => r['user_id'] as String? ?? '')
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();
      final profileRows = userIds.isEmpty
          ? <Map<String, dynamic>>[]
          : (await SupabaseConfig.table('public_profiles')
              .select('id, mascot_type, mascot_mood, is_pro')
              .inFilter('id', userIds) as List)
              .cast<Map<String, dynamic>>();

      final mascotTypeMap = <String, String>{
        for (final p in profileRows)
          p['id'] as String: (p['mascot_type'] as String? ?? 'blob'),
      };
      final mascotMoodMap = <String, String>{
        for (final p in profileRows)
          p['id'] as String: (p['mascot_mood'] as String? ?? 'happy'),
      };
      final isProMap = <String, bool>{
        for (final p in profileRows)
          p['id'] as String: (p['is_pro'] as bool? ?? false),
      };

      return rows.map((r) {
        final userId = r['user_id'] as String? ?? '';
        return _partnerFromRow(r,
            mascotType: mascotTypeMap[userId] ?? 'blob',
            mascotMood: mascotMoodMap[userId] ?? 'happy',
            isPro: isProMap[userId] ?? false);
      }).toList();
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
        'user_id':           _uid,
        'name':              partner.name,
        'avatar_url':        '',
        'goal':              partner.goal,
        'level':             partner.level,
        'region':            partner.region,
        'frequency':         partner.frequency,
        'description':       partner.description,
        'tags':              partner.tags,
        'contact_whatsapp':  partner.contactWhatsapp,
        'contact_instagram': partner.contactInstagram,
        'contact_facebook':  partner.contactFacebook,
      }).select(_partnerColumns).single();

      return _partnerFromRow(row);
    } catch (e) {
      debugPrint('[CommunityService] addPartner error: $e');
      return null;
    }
  }

  /// Met à jour une annonce partenaire existante (uniquement si user_id correspond).
  static Future<PartnerModel?> updatePartner(PartnerModel partner) async {
    if (_uid == null) return null;
    try {
      final row = await SupabaseConfig.table('training_partners').update({
        'goal':              partner.goal,
        'level':             partner.level,
        'region':            partner.region,
        'frequency':         partner.frequency,
        'description':       partner.description,
        'tags':              partner.tags,
        'contact_whatsapp':  partner.contactWhatsapp,
        'contact_instagram': partner.contactInstagram,
        'contact_facebook':  partner.contactFacebook,
      }).eq('id', partner.id).eq('user_id', _uid!)
          .select(_partnerColumns).single();

      return _partnerFromRow(row,
          mascotType: partner.mascotType, mascotMood: partner.mascotMood);
    } catch (e) {
      debugPrint('[CommunityService] updatePartner error: $e');
      return null;
    }
  }

  /// Supprime une annonce partenaire (uniquement si user_id correspond).
  static Future<bool> deletePartner(String partnerId) async {
    if (_uid == null) return false;
    try {
      await SupabaseConfig.table('training_partners')
          .delete()
          .eq('id', partnerId)
          .eq('user_id', _uid!);
      return true;
    } catch (e) {
      debugPrint('[CommunityService] deletePartner error: $e');
      return false;
    }
  }

  static Future<void> savePartners(List<PartnerModel> partners) async {}

  // ────────────────────────────────────────────────────────────────────────────
  // DEMANDES DE MISE EN RELATION (training_partners → partner_join_requests)
  // ────────────────────────────────────────────────────────────────────────────

  /// Envoie une demande pour rejoindre un partenaire (liste d'attente).
  /// Utilise upsert car (partner_id, requester_id) est unique : si une demande
  /// refusée existait déjà, elle repasse simplement à 'pending'.
  /// Retourne le statut résultant ('pending' si succès, null en cas d'erreur).
  static Future<String?> sendPartnerJoinRequest({
    required String partnerId,
    required String ownerId,
  }) async {
    if (_uid == null) return null;
    try {
      await SupabaseConfig.table('partner_join_requests').upsert({
        'partner_id':   partnerId,
        'requester_id': _uid,
        'owner_id':     ownerId,
        'status':       'pending',
      }, onConflict: 'partner_id,requester_id');
      return 'pending';
    } catch (e) {
      debugPrint('[CommunityService] sendPartnerJoinRequest error: $e');
      return null;
    }
  }

  /// Statut ('pending'/'accepted'/'declined') des demandes envoyées par
  /// l'utilisateur courant, indexé par partner_id.
  static Future<Map<String, String>> loadMyPartnerRequestStatuses() async {
    final uid = _uid;
    if (uid == null) return {};
    try {
      final rows = await SupabaseConfig.table('partner_join_requests')
          .select('partner_id, status')
          .eq('requester_id', uid) as List;
      return {
        for (final r in rows.cast<Map<String, dynamic>>())
          r['partner_id'] as String: r['status'] as String,
      };
    } catch (e) {
      debugPrint('[CommunityService] loadMyPartnerRequestStatuses error: $e');
      return {};
    }
  }

  /// Demandes en attente reçues pour les partenaires publiés par l'utilisateur.
  ///
  /// Fait plusieurs requêtes (pas d'embed PostgREST) car `requester_id`
  /// référence auth.users, pas user_profiles — il n'y a donc pas de FK directe
  /// utilisable pour un embed entre les deux tables. On récupère aussi le post
  /// partenaire concerné (goal/région) car un même owner peut en publier
  /// plusieurs, il faut donc pouvoir distinguer à quel post chaque demande
  /// se rapporte.
  static Future<List<PartnerJoinRequest>> loadIncomingPartnerRequests() async {
    final uid = _uid;
    if (uid == null) return [];
    try {
      final rows = await SupabaseConfig.table('partner_join_requests')
          .select('id, partner_id, requester_id, status, created_at')
          .eq('owner_id', uid)
          .eq('status', 'pending')
          .order('created_at', ascending: false) as List;
      final requests = rows.cast<Map<String, dynamic>>();
      if (requests.isEmpty) return [];

      final requesterIds = requests.map((r) => r['requester_id'] as String).toSet().toList();
      final profiles = await SupabaseConfig.table('public_profiles')
          .select('id, username, mascot_type, mascot_mood')
          .inFilter('id', requesterIds) as List;
      final namesById = {
        for (final p in profiles.cast<Map<String, dynamic>>())
          p['id'] as String: p['username'] as String? ?? 'User',
      };
      final mascotTypeById = {
        for (final p in profiles.cast<Map<String, dynamic>>())
          p['id'] as String: p['mascot_type'] as String? ?? 'blob',
      };
      final mascotMoodById = {
        for (final p in profiles.cast<Map<String, dynamic>>())
          p['id'] as String: p['mascot_mood'] as String? ?? 'happy',
      };

      final partnerIds = requests.map((r) => r['partner_id'] as String).toSet().toList();
      final partnerRows = await SupabaseConfig.table('training_partners')
          .select('id, goal, region')
          .inFilter('id', partnerIds) as List;
      final partnerInfoById = {
        for (final p in partnerRows.cast<Map<String, dynamic>>())
          p['id'] as String: (p['goal'] as String? ?? '', p['region'] as String? ?? ''),
      };

      return requests.map((r) {
        final partnerInfo = partnerInfoById[r['partner_id']];
        return PartnerJoinRequest(
          id: r['id'] as String,
          partnerId: r['partner_id'] as String,
          requesterId: r['requester_id'] as String,
          requesterName: namesById[r['requester_id']] ?? 'User',
          requesterMascotType: mascotTypeById[r['requester_id']] ?? 'blob',
          requesterMascotMood: mascotMoodById[r['requester_id']] ?? 'happy',
          status: r['status'] as String,
          createdAt: DateTime.parse(r['created_at'] as String),
          partnerGoal: partnerInfo?.$1 ?? '',
          partnerRegion: partnerInfo?.$2 ?? '',
        );
      }).toList();
    } catch (e) {
      debugPrint('[CommunityService] loadIncomingPartnerRequests error: $e');
      return [];
    }
  }

  /// Accepte ou refuse une demande reçue (réservé au propriétaire du partenaire).
  static Future<bool> respondToPartnerRequest({
    required String requestId,
    required bool accept,
  }) async {
    try {
      await SupabaseConfig.table('partner_join_requests').update({
        'status': accept ? 'accepted' : 'declined',
      }).eq('id', requestId);
      return true;
    } catch (e) {
      debugPrint('[CommunityService] respondToPartnerRequest error: $e');
      return false;
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // PROFIL UTILISATEUR (pour la vue profil communauté)
  // ────────────────────────────────────────────────────────────────────────────

  /// Récupère les données publiques d'un utilisateur par son UUID Supabase.
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final profile = await SupabaseConfig.table('public_profiles')
          .select('id, username, mascot_type, mascot_mood, is_pro')
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
        'mascot_type':    profile['mascot_type'] as String? ?? 'blob',
        'mascot_mood':    profile['mascot_mood'] as String? ?? 'happy',
        'is_pro':         profile['is_pro'] as bool? ?? false,
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
          .select('id, title, content, image_url, category, likes_count, comments_count, created_at')
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
          .select('id, title, event_type, event_date, event_time, location, joined_count, image_url')
          .eq('organizer_id', userId)
          .order('event_date', ascending: false)
          .limit(20) as List;
      return rows.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[CommunityService] getUserEvents error: $e');
      return [];
    }
  }

  /// Annonces partenaire publiées par un utilisateur (onglet Partenaires du profil).
  static Future<List<PartnerModel>> getUserPartners(String userId) async {
    try {
      final rows = (await SupabaseConfig.table('training_partners')
          .select(_partnerColumns)
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(20) as List)
          .cast<Map<String, dynamic>>();
      return rows.map((r) => _partnerFromRow(r)).toList();
    } catch (e) {
      debugPrint('[CommunityService] getUserPartners error: $e');
      return [];
    }
  }

  /// Solde d'étoiles (points boutique) d'un utilisateur.
  /// Nécessite la policy de lecture publique sur user_points (voir schema).
  static Future<int> getUserPoints(String userId) async {
    try {
      final row = await SupabaseConfig.table('user_points')
          .select('etoiles')
          .eq('user_id', userId)
          .maybeSingle();
      return row?['etoiles'] as int? ?? 0;
    } catch (e) {
      debugPrint('[CommunityService] getUserPoints error: $e');
      return 0;
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

  static PartnerModel _partnerFromRow(Map<String, dynamic> r,
      {String mascotType = 'blob', String mascotMood = 'happy', bool isPro = false}) => PartnerModel(
    id:          r['id'] as String,
    userId:      r['user_id'] as String? ?? '',
    name:        r['name'] as String? ?? '',
    avatar:      r['avatar_url'] as String? ?? '',
    mascotType:  mascotType,
    mascotMood:  mascotMood,
    goal:        r['goal'] as String? ?? '',
    level:       r['level'] as String? ?? '',
    region:      r['region'] as String? ?? '',
    frequency:   r['frequency'] as String? ?? '',
    description: r['description'] as String? ?? '',
    tags:        List<String>.from(r['tags'] as List? ?? []),
    contactWhatsapp:  r['contact_whatsapp'] as String? ?? '',
    contactInstagram: r['contact_instagram'] as String? ?? '',
    contactFacebook:  r['contact_facebook'] as String? ?? '',
    isPro:       isPro,
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
