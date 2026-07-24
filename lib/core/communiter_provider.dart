import 'package:fiteva/models/post_model.dart';
import 'package:fiteva/providers/mascot_provider.dart';
import 'package:fiteva/providers/user_profile_provider.dart';
import 'package:fiteva/screens/community/model/event_model.dart';
import 'package:fiteva/screens/community/model/partner_model.dart';
import 'package:fiteva/services/comuniter_service.dart';
import 'package:fiteva/services/supabase_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgresChangeEvent, RealtimeChannel;

// ─── Live profile sync ────────────────────────────────────────────────────────
// Les posts/événements/partenaires sont des instantanés chargés une seule
// fois depuis Supabase : chaque modèle embarque le nom + la mascotte de son
// auteur au moment du chargement. Si l'utilisateur change son avatar ou son
// nom dans son profil, ce helper patche en direct les entrées qui lui
// appartiennent déjà en mémoire (sinon il faudrait un pull-to-refresh dans
// chaque onglet pour voir le changement).
void _listenOwnProfile(Ref ref, void Function({String? username, String? mascotType, String? mascotMood}) patch) {
  ref.listen<MascotState>(mascotProvider, (_, next) {
    patch(mascotType: next.type.name, mascotMood: next.mood.name);
  });
  ref.listen<UserProfile>(userProfileProvider, (_, next) {
    if (next.username.isNotEmpty) patch(username: next.username);
  });
}

// ─── Tab index ───────────────────────────────────────────────────────────────
final communityTabProvider = StateProvider<int>((ref) => 0);

// ─── Posts Notifier ──────────────────────────────────────────────────────────

final postsLoadingProvider = StateProvider<bool>((ref) => true);

class PostsNotifier extends StateNotifier<List<PostModel>> {
  PostsNotifier(this._ref) : super([]) {
    _init();
  }

  final Ref _ref;

  final Set<String> _liked = {};

  Future<void> _init() async {
    _ref.read(postsLoadingProvider.notifier).state = true;
    final posts = await CommunityService.loadPosts();
    _liked.addAll(await CommunityService.loadLikedPosts());
    state = posts;
    _ref.read(postsLoadingProvider.notifier).state = false;

    _listenOwnProfile(_ref, ({username, mascotType, mascotMood}) {
      final uid = SupabaseConfig.userId;
      if (uid == null) return;
      state = [
        for (final p in state)
          if (p.userId == uid)
            p.copyWith(
              username: username,
              mascotType: mascotType,
              mascotMood: mascotMood,
            )
          else
            p,
      ];
    });
  }

  /// Recharge les posts depuis Supabase
  Future<void> refresh() async {
    _ref.read(postsLoadingProvider.notifier).state = true;
    final posts = await CommunityService.loadPosts();
    _liked.addAll(await CommunityService.loadLikedPosts());
    state = posts;
    _ref.read(postsLoadingProvider.notifier).state = false;
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
        (ref) => PostsNotifier(ref));

// ─── Events Notifier ─────────────────────────────────────────────────────────

class EventsNotifier extends StateNotifier<List<EventModel>> {
  EventsNotifier(this._ref) : super([]) {
    _init();
  }

  final Ref _ref;
  final Set<String> _joined = {};

  Future<void> _init() async {
    final events = await CommunityService.loadEvents();
    _joined.addAll(await CommunityService.loadJoinedEvents());
    state = [
      for (final e in events) e.copyWith(isJoined: _joined.contains(e.id)),
    ];

    _listenOwnProfile(_ref, ({username, mascotType, mascotMood}) {
      final uid = SupabaseConfig.userId;
      if (uid == null) return;
      state = [
        for (final e in state)
          if (e.organizerId == uid)
            e.copyWith(
              organizer: username,
              organizerMascotType: mascotType,
              organizerMascotMood: mascotMood,
            )
          else
            e,
      ];
    });
  }

  /// Recharge les événements depuis Supabase (pull-to-refresh).
  Future<void> refresh() async {
    final events = await CommunityService.loadEvents();
    final joined = await CommunityService.loadJoinedEvents();
    _joined
      ..clear()
      ..addAll(joined);
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

  /// Met à jour un événement existant. Le service refuse si `maxSpots`
  /// est réduit sous le nombre d'inscrits.
  Future<bool> updateEvent(EventModel event) async {
    final updated = await CommunityService.updateEvent(event);
    if (updated == null) return false;
    state = [
      for (final e in state)
        if (e.id == updated.id) updated.copyWith(isJoined: e.isJoined) else e,
    ];
    return true;
  }

  Future<bool> deleteEvent(String id) async {
    final ok = await CommunityService.deleteEvent(id);
    if (!ok) return false;
    state = state.where((e) => e.id != id).toList();
    _joined.remove(id);
    return true;
  }
}

final eventsNotifierProvider =
    StateNotifierProvider<EventsNotifier, List<EventModel>>(
        (ref) => EventsNotifier(ref));

// Alias utilisé dans les widgets existants
final eventsProvider = eventsNotifierProvider;

// ─── Partners Notifier ───────────────────────────────────────────────────────

final partnersLoadingProvider = StateProvider<bool>((ref) => true);

class PartnersNotifier extends StateNotifier<List<PartnerModel>> {
  PartnersNotifier(this._ref) : super([]) {
    _init();
  }

  final Ref _ref;
  late final RealtimeChannel _channel;

  Future<void> _init() async {
    _ref.read(partnersLoadingProvider.notifier).state = true;
    final partners = await CommunityService.loadPartners();
    state = partners;
    _ref.read(partnersLoadingProvider.notifier).state = false;

    // Écoute Realtime — recharge la liste dès qu'un partenaire est
    // publié/modifié/supprimé par n'importe quel utilisateur.
    _channel = SupabaseConfig.client
        .channel('training_partners_realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'training_partners',
          callback: (_) async {
            state = await CommunityService.loadPartners();
          },
        )
        .subscribe();

    _listenOwnProfile(_ref, ({username, mascotType, mascotMood}) {
      final uid = SupabaseConfig.userId;
      if (uid == null) return;
      state = [
        for (final p in state)
          if (p.userId == uid)
            p.copyWith(
              name: username,
              mascotType: mascotType,
              mascotMood: mascotMood,
            )
          else
            p,
      ];
    });
  }

  Future<void> refresh() async {
    _ref.read(partnersLoadingProvider.notifier).state = true;
    final partners = await CommunityService.loadPartners();
    state = partners;
    _ref.read(partnersLoadingProvider.notifier).state = false;
  }

  Future<bool> addPartner(PartnerModel partner) async {
    final saved = await CommunityService.addPartner(partner);
    if (saved == null) return false;
    state = [saved, ...state];
    return true;
  }

  Future<bool> updatePartner(PartnerModel partner) async {
    final updated = await CommunityService.updatePartner(partner);
    if (updated == null) return false;
    state = [for (final p in state) if (p.id == updated.id) updated else p];
    return true;
  }

  Future<bool> deletePartner(String id) async {
    final ok = await CommunityService.deletePartner(id);
    if (!ok) return false;
    state = state.where((p) => p.id != id).toList();
    return true;
  }

  @override
  void dispose() {
    SupabaseConfig.client.removeChannel(_channel);
    super.dispose();
  }
}

final partnersNotifierProvider =
    StateNotifierProvider<PartnersNotifier, List<PartnerModel>>(
        (ref) => PartnersNotifier(ref));

// Alias utilisé dans les widgets existants
final partnersProvider = partnersNotifierProvider;

// ─── Partner Join Requests Notifier ─────────────────────────────────────────

class PartnerRequestsState {
  /// Statut ('pending'/'accepted'/'declined') des demandes envoyées par
  /// l'utilisateur courant, indexé par partner_id.
  final Map<String, String> myStatusByPartnerId;
  /// Demandes en attente reçues pour les partenaires publiés par l'utilisateur.
  final List<PartnerJoinRequest> incoming;

  const PartnerRequestsState({
    this.myStatusByPartnerId = const {},
    this.incoming = const [],
  });

  PartnerRequestsState copyWith({
    Map<String, String>? myStatusByPartnerId,
    List<PartnerJoinRequest>? incoming,
  }) => PartnerRequestsState(
    myStatusByPartnerId: myStatusByPartnerId ?? this.myStatusByPartnerId,
    incoming: incoming ?? this.incoming,
  );
}

class PartnerRequestsNotifier extends StateNotifier<PartnerRequestsState> {
  PartnerRequestsNotifier() : super(const PartnerRequestsState()) {
    refresh();

    // Écoute Realtime — dès qu'une demande est créée (côté owner) ou que son
    // statut change (côté requester), on rafraîchit les deux vues.
    _channel = SupabaseConfig.client
        .channel('partner_join_requests_realtime')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'partner_join_requests',
          callback: (_) => refresh(),
        )
        .subscribe();
  }

  late final RealtimeChannel _channel;

  Future<void> refresh() async {
    final statuses = await CommunityService.loadMyPartnerRequestStatuses();
    final incoming = await CommunityService.loadIncomingPartnerRequests();
    state = state.copyWith(myStatusByPartnerId: statuses, incoming: incoming);
  }

  String statusFor(String partnerId) =>
      state.myStatusByPartnerId[partnerId] ?? 'none';

  /// Envoie une demande pour rejoindre un partenaire (liste d'attente).
  Future<void> join({required String partnerId, required String ownerId}) async {
    final result = await CommunityService.sendPartnerJoinRequest(
      partnerId: partnerId, ownerId: ownerId);
    if (result == null) return;
    state = state.copyWith(myStatusByPartnerId: {
      ...state.myStatusByPartnerId,
      partnerId: result,
    });
  }

  /// Accepte ou refuse une demande reçue, puis rafraîchit la liste des demandes.
  Future<void> respond({required String requestId, required bool accept}) async {
    final ok = await CommunityService.respondToPartnerRequest(
      requestId: requestId, accept: accept);
    if (!ok) return;
    state = state.copyWith(
      incoming: state.incoming.where((r) => r.id != requestId).toList(),
    );
  }

  @override
  void dispose() {
    SupabaseConfig.client.removeChannel(_channel);
    super.dispose();
  }
}

final partnerRequestsProvider =
    StateNotifierProvider<PartnerRequestsNotifier, PartnerRequestsState>(
        (_) => PartnerRequestsNotifier());
