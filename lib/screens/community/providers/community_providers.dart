import 'package:fiteva/screens/community/community_screen.dart';
import 'package:fiteva/screens/community/model/event_model.dart';
import 'package:fiteva/screens/community/model/partner_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';


// ─── Tab index ───────────────────────────────────────────────
final communityTabProvider = StateProvider<int>((ref) => 0);

// ─── Mock Events ─────────────────────────────────────────────
final eventsProvider = StateProvider<List<EventModel>>((ref) => [
      EventModel(
        id: '1',
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
        imageUrl:
            'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=600&q=80',
      ),
      EventModel(
        id: '2',
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
        imageUrl:
            'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=600&q=80',
      ),
      EventModel(
        id: '3',
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
        imageUrl:
            'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=600&q=80',
      ),
    ]);

// ─── Mock Partners ────────────────────────────────────────────
final partnersProvider = Provider<List<PartnerModel>>((ref) => const [
      PartnerModel(
        id: '1',
        name: 'Yasmine K.',
        avatar: 'https://i.pravatar.cc/150?img=47',
        goal: 'Tonifier',
        level: 'Intermédiaire',
        region: 'Sousse',
        frequency: '3x/semaine',
        description:
            'Je cherche une partenaire motivée pour salle de sport. J\'adore le cardio et la muscu légère 💪',
        tags: ['Salle de sport', 'Cardio', 'Femmes uniquement'],
      ),
      PartnerModel(
        id: '2',
        name: 'Amira S.',
        avatar: 'https://i.pravatar.cc/150?img=9',
        goal: 'Perdre du poids',
        level: 'Débutant',
        region: 'Sousse',
        frequency: '2x/semaine',
        description:
            'Débutante cherche partenaire bienveillante pour running et marche rapide le matin 🌅',
        tags: ['Running', 'Marche', 'Matin'],
      ),
      PartnerModel(
        id: '3',
        name: 'Nour B.',
        avatar: 'https://i.pravatar.cc/150?img=16',
        goal: 'Prendre de la masse',
        level: 'Avancé',
        region: 'Monastir',
        frequency: '5x/semaine',
        description:
            'Coach amateur cherche partenaire sérieux pour séances muscu avancées. Objectif compétition 🏆',
        tags: ['Muscu', 'Powerlifting', 'Compétition'],
      ),
      PartnerModel(
        id: '4',
        name: 'Rania T.',
        avatar: 'https://i.pravatar.cc/150?img=25',
        goal: 'Bien-être',
        level: 'Intermédiaire',
        region: 'Sousse',
        frequency: '3x/semaine',
        description:
            'Passionnée de yoga et pilates, je cherche quelqu\'un pour pratiquer ensemble en salle ou dehors 🧘‍♀️',
        tags: ['Yoga', 'Pilates', 'Flexibilité'],
      ),
    ]);