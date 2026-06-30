import 'package:fiteva/models/post_model.dart';
import 'package:fiteva/screens/community/model/event_model.dart';
import 'package:fiteva/screens/community/model/partner_model.dart';
import 'package:fiteva/services/comuniter_service.dart';
import 'package:flutter_riverpod/legacy.dart';

// ─── Tab index ───────────────────────────────────────────────────────────────
final communityTabProvider = StateProvider<int>((ref) => 0);

// ─── Posts Notifier ──────────────────────────────────────────────────────────

class PostsNotifier extends StateNotifier<List<PostModel>> {
  PostsNotifier() : super([]) {
    _init();
  }

  final Set<String> _liked = {};

  Future<void> _init() async {
    final posts = await CommunityService.loadPosts();
    _liked.addAll(await CommunityService.loadLikedPosts());
    state = posts;
  }

  /// Recharge les posts depuis Supabase
  Future<void> refresh() async {
    final posts = await CommunityService.loadPosts();
    _liked.addAll(await CommunityService.loadLikedPosts());
    state = posts;
  }

  bool isLiked(String id) => _liked.contains(id);

  Future<void> toggleLike(String id) async {
    final wasLiked = _liked.contains(id);
    // Mise à jour optimiste immédiate
    if (wasLiked) {
      _liked.remove(id);
    } else {
      _liked.add(id);
    }
    state = [
      for (final p in state)
        if (p.id == id)
          p.copyWith(likes: p.likes + (wasLiked ? -1 : 1))
        else
          p,
    ];
    // Sync Supabase
    if (wasLiked) {
      await CommunityService.unlikePost(id);
    } else {
      await CommunityService.likePost(id);
    }
  }

  /// Crée un post dans Supabase et l'ajoute en tête de liste
  Future<bool> addPost(PostModel post) async {
    final saved = await CommunityService.addPost(post);
    if (saved == null) return false;
    state = [saved, ...state];
    return true;
  }

  /// Met à jour le contenu d'un post existant.
  Future<bool> updatePost(PostModel post) async {
    final ok = await CommunityService.updatePost(post);
    if (!ok) return false;
    state = [for (final p in state) if (p.id == post.id) post else p];
    return true;
  }

  /// Supprime un post de Supabase et de la liste locale.
  Future<bool> deletePost(String postId) async {
    final ok = await CommunityService.deletePost(postId);
    if (!ok) return false;
    state = state.where((p) => p.id != postId).toList();
    return true;
  }

  Future<void> incrementComments(String postId) async {
    state = [
      for (final p in state)
        if (p.id == postId)
          p.copyWith(comments: p.comments + 1)
        else
          p,
    ];
  }
}

final postsNotifierProvider =
    StateNotifierProvider<PostsNotifier, List<PostModel>>(
        (_) => PostsNotifier());

// ─── Events Notifier ─────────────────────────────────────────────────────────

class EventsNotifier extends StateNotifier<List<EventModel>> {
  EventsNotifier() : super([]) {
    _init();
  }

  final Set<String> _joined = {};

  Future<void> _init() async {
    final events = await CommunityService.loadEvents();
    _joined.addAll(await CommunityService.loadJoinedEvents());
    state = [
      for (final e in events) e.copyWith(isJoined: _joined.contains(e.id)),
    ];
  }

  Future<void> toggleJoin(String id) async {
    final wasJoined = _joined.contains(id);
    // Mise à jour optimiste immédiate
    if (wasJoined) {
      _joined.remove(id);
    } else {
      _joined.add(id);
    }
    state = [
      for (final e in state)
        if (e.id == id)
          e.copyWith(
            isJoined: !wasJoined,
            joinedCount: e.joinedCount + (wasJoined ? -1 : 1),
          )
        else
          e,
    ];
    // Sync Supabase
    if (wasJoined) {
      await CommunityService.leaveEvent(id);
    } else {
      await CommunityService.joinEvent(id);
    }
  }

  Future<bool> addEvent(EventModel event) async {
    final saved = await CommunityService.addEvent(event);
    if (saved == null) return false;
    state = [saved, ...state];
    return true;
  }
}

final eventsNotifierProvider =
    StateNotifierProvider<EventsNotifier, List<EventModel>>(
        (_) => EventsNotifier());

// Alias utilisé dans les widgets existants
final eventsProvider = eventsNotifierProvider;

// ─── Partners Notifier ───────────────────────────────────────────────────────

class PartnersNotifier extends StateNotifier<List<PartnerModel>> {
  PartnersNotifier() : super([]) {
    _init();
  }

  Future<void> _init() async {
    final partners = await CommunityService.loadPartners();
    state = partners;
  }

  Future<bool> addPartner(PartnerModel partner) async {
    final saved = await CommunityService.addPartner(partner);
    if (saved == null) return false;
    state = [saved, ...state];
    return true;
  }
}

final partnersNotifierProvider =
    StateNotifierProvider<PartnersNotifier, List<PartnerModel>>(
        (_) => PartnersNotifier());

// Alias utilisé dans les widgets existants
final partnersProvider = partnersNotifierProvider;
