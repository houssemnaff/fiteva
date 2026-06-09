import 'package:fiteva/models/post_model.dart';
import 'package:fiteva/screens/community/model/event_model.dart';
import 'package:fiteva/screens/community/model/partner_model.dart';
import 'package:fiteva/services/comuniter_service.dart';
import 'package:flutter_riverpod/legacy.dart';

// ─── Tab index ───────────────────────────────────────────────────────────────
final communityTabProvider = StateProvider<int>((ref) => 0);

// ─── Seed data ───────────────────────────────────────────────────────────────

final _seedPosts = [
  PostModel(
    id: 'p_seed_1',
    username: 'Sarah',
    userAvatarUrl: 'https://i.pravatar.cc/150?img=1',
    content: 'EVENT: Tennis match ce samedi à 9h00. Besoin de 3 partenaires. Tous niveaux bienvenus !',
    imageUrl: '',
    likes: 42,
    comments: 18,
    timeAgo: '35m',
    category: 'Challenge',
  ),
  PostModel(
    id: 'p_seed_2',
    username: 'Nora Fit',
    userAvatarUrl: 'https://i.pravatar.cc/150?img=33',
    content: 'Petite victoire du jour : j\'ai terminé ma séance même avec peu de motivation. Progrès avant perfection.',
    imageUrl: '',
    likes: 63,
    comments: 11,
    timeAgo: '1h',
    category: 'Workout',
  ),
  PostModel(
    id: 'p_seed_3',
    username: 'Fit Community',
    userAvatarUrl: 'https://i.pravatar.cc/150?img=20',
    content: 'La constance bat la motivation à chaque fois 💯',
    imageUrl: 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=500',
    likes: 210,
    comments: 34,
    timeAgo: '6h',
    category: 'Workout',
  ),
  PostModel(
    id: 'p_seed_4',
    username: 'Jessica Alba',
    userAvatarUrl: 'https://i.pravatar.cc/150?img=32',
    content: 'Repas équilibrés = plus d\'énergie toute la journée 🌱💚',
    imageUrl: 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=500',
    likes: 97,
    comments: 12,
    timeAgo: '3h',
    category: 'Nutrition',
  ),
];

final _seedEvents = [
  EventModel(
    id: 'ev_seed_1',
    title: 'Morning Run – Corniche',
    organizer: 'Sara B.',
    organizerAvatar: 'https://i.pravatar.cc/150?img=47',
    type: 'running',
    date: 'Sam 3 Mai',
    time: '6h30',
    location: 'Corniche, Sousse',
    maxSpots: 10,
    joinedCount: 7,
    participantAvatars: [
      'https://i.pravatar.cc/150?img=12',
      'https://i.pravatar.cc/150?img=25',
      'https://i.pravatar.cc/150?img=33',
    ],
    imageUrl: 'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=600&q=80',
  ),
  EventModel(
    id: 'ev_seed_2',
    title: 'Session Yoga Plein Air',
    organizer: 'Lina M.',
    organizerAvatar: 'https://i.pravatar.cc/150?img=5',
    type: 'yoga',
    date: 'Dim 4 Mai',
    time: '8h00',
    location: 'Parc du Khézama',
    maxSpots: 15,
    joinedCount: 11,
    participantAvatars: [
      'https://i.pravatar.cc/150?img=9',
      'https://i.pravatar.cc/150?img=16',
      'https://i.pravatar.cc/150?img=20',
    ],
    imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=600&q=80',
  ),
  EventModel(
    id: 'ev_seed_3',
    title: 'Bootcamp Mixte – Gym FitEva',
    organizer: 'Coach Karim',
    organizerAvatar: 'https://i.pravatar.cc/150?img=52',
    type: 'gym',
    date: 'Lun 5 Mai',
    time: '18h00',
    location: 'FitEva Gym, Sahloul',
    maxSpots: 8,
    joinedCount: 6,
    participantAvatars: [
      'https://i.pravatar.cc/150?img=31',
      'https://i.pravatar.cc/150?img=44',
    ],
    imageUrl: 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=600&q=80',
  ),
];

final _seedPartners = [
  PartnerModel(
    id: 'pt_seed_1',
    name: 'Yasmine K.',
    avatar: 'https://i.pravatar.cc/150?img=47',
    goal: 'Tonifier',
    level: 'Intermédiaire',
    region: 'Sousse',
    frequency: '3x/semaine',
    description: 'Je cherche une partenaire motivée pour salle de sport. J\'adore le cardio et la muscu légère 💪',
    tags: ['Salle de sport', 'Cardio', 'Femmes uniquement'],
  ),
  PartnerModel(
    id: 'pt_seed_2',
    name: 'Amira S.',
    avatar: 'https://i.pravatar.cc/150?img=9',
    goal: 'Perdre du poids',
    level: 'Débutant',
    region: 'Sousse',
    frequency: '2x/semaine',
    description: 'Débutante cherche partenaire bienveillante pour running et marche rapide le matin 🌅',
    tags: ['Running', 'Marche', 'Matin'],
  ),
  PartnerModel(
    id: 'pt_seed_3',
    name: 'Nour B.',
    avatar: 'https://i.pravatar.cc/150?img=16',
    goal: 'Prendre de la masse',
    level: 'Avancé',
    region: 'Monastir',
    frequency: '5x/semaine',
    description: 'Coach amateur cherche partenaire sérieux pour séances muscu avancées. Objectif compétition 🏆',
    tags: ['Muscu', 'Powerlifting', 'Compétition'],
  ),
  PartnerModel(
    id: 'pt_seed_4',
    name: 'Rania T.',
    avatar: 'https://i.pravatar.cc/150?img=25',
    goal: 'Bien-être',
    level: 'Intermédiaire',
    region: 'Sousse',
    frequency: '3x/semaine',
    description: 'Passionnée de yoga et pilates, je cherche quelqu\'un pour pratiquer ensemble 🧘‍♀️',
    tags: ['Yoga', 'Pilates', 'Flexibilité'],
  ),
];

// ─── Posts Notifier ──────────────────────────────────────────────────────────

class PostsNotifier extends StateNotifier<List<PostModel>> {
  PostsNotifier() : super([]) {
    _init();
  }

  final Set<String> _liked = {};

  Future<void> _init() async {
    var posts = await CommunityService.loadPosts();
    if (posts.isEmpty) {
      posts = _seedPosts;
      await CommunityService.savePosts(posts);
    }
    _liked.addAll(await CommunityService.loadLikedPosts());
    state = posts;
  }

  bool isLiked(String id) => _liked.contains(id);

  Future<void> toggleLike(String id) async {
    final wasLiked = _liked.contains(id);
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
    await CommunityService.saveLikedPosts(_liked);
    await CommunityService.savePosts(state);
  }

  Future<void> addPost(PostModel post) async {
    state = [post, ...state];
    await CommunityService.savePosts(state);
  }

  Future<void> incrementComments(String postId) async {
    state = [
      for (final p in state)
        if (p.id == postId)
          p.copyWith(comments: p.comments + 1)
        else
          p,
    ];
    await CommunityService.savePosts(state);
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
    var events = await CommunityService.loadEvents();
    if (events.isEmpty) {
      events = _seedEvents;
      await CommunityService.saveEvents(events);
    }
    _joined.addAll(await CommunityService.loadJoinedEvents());
    state = [
      for (final e in events)
        e.copyWith(isJoined: _joined.contains(e.id)),
    ];
  }

  Future<void> toggleJoin(String id) async {
    final wasJoined = _joined.contains(id);
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
    await CommunityService.saveJoinedEvents(_joined);
  }

  Future<void> addEvent(EventModel event) async {
    state = [event, ...state];
    await CommunityService.saveEvents(state);
  }
}

final eventsNotifierProvider =
    StateNotifierProvider<EventsNotifier, List<EventModel>>(
        (_) => EventsNotifier());

// Keep legacy alias so existing event_tab code compiles without changes
// eventsTab uses: ref.watch(eventsProvider) and ref.read(eventsProvider.notifier).update(...)
// → We replace those call sites below, so this is a transitional alias only.
final eventsProvider = eventsNotifierProvider;

// ─── Partners Notifier ───────────────────────────────────────────────────────

class PartnersNotifier extends StateNotifier<List<PartnerModel>> {
  PartnersNotifier() : super([]) {
    _init();
  }

  Future<void> _init() async {
    var partners = await CommunityService.loadPartners();
    if (partners.isEmpty) {
      partners = _seedPartners;
      await CommunityService.savePartners(partners);
    }
    state = partners;
  }

  Future<void> addPartner(PartnerModel partner) async {
    state = [partner, ...state];
    await CommunityService.savePartners(state);
  }
}

final partnersNotifierProvider =
    StateNotifierProvider<PartnersNotifier, List<PartnerModel>>(
        (_) => PartnersNotifier());

// Legacy alias for partner_tab
final partnersProvider = partnersNotifierProvider;
