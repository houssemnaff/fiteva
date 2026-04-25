import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/workout_model.dart';
import '../models/nutrition_model.dart';
import '../models/post_model.dart';

// User Provider
final userProvider = Provider<UserModel>((ref) {
  return UserModel(
    id: '1',
    name: 'Sarah',
    avatarUrl: 'https://i.pravatar.cc/150?img=1',
    level: 4,
    xp: 2500,
    streak: 12,
  );
});

// Avatar Change Provider
class AvatarNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void increment() => state++;
}
final avatarProvider = NotifierProvider<AvatarNotifier, int>(AvatarNotifier.new);

// Workouts Provider
final workoutsProvider = Provider<List<WorkoutModel>>((ref) {
  return [
    // HIIT
    WorkoutModel(
      id: 'w1',
      title: 'Full Body HIIT',
      category: 'HIIT',
      duration: '45 min',
      level: 'Intermediate',
      calories: '700',
      imageUrl: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=500',
      exercises: ['Jumping Jacks', 'Burpees', 'Mountain Climbers', 'Squat Jumps'],
    ),

    // PILATES
    WorkoutModel(
      id: 'w2',
      title: 'Morning Pilates',
      category: 'Pilates',
      duration: '30 min',
      level: 'Beginner',
      calories: '500',
      imageUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=500',
      exercises: ['The Hundred', 'Roll Up', 'Single Leg Circle', 'Rolling Like a Ball'],
    ),

    WorkoutModel(
      id: 'w12',
      title: 'Core Pilates',
      category: 'Pilates',
      duration: '20 min',
      level: 'Intermediate',
      calories: '400',
      imageUrl: 'https://images.unsplash.com/photo-1552196563-55cd4e45efb3?w=500',
      exercises: ['Plank', 'Leg Stretch', 'Side Kick', 'Teaser'],
    ),

    // MUSCULATION (Strength)
    WorkoutModel(
      id: 'w3',
      title: 'Strength Training',
      category: 'musculation',
      duration: '60 min',
      level: 'Advanced',
      calories: '600',
      imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=500',
      exercises: ['Deadlifts', 'Squats', 'Bench Press', 'Pull-ups'],
    ),

    WorkoutModel(
      id: 'w13',
      title: 'Upper Body Workout',
      category: 'musculation',
      duration: '40 min',
      level: 'Intermediate',
      calories: '550',
      imageUrl: 'https://images.unsplash.com/photo-1599058917765-a780eda07a3e?w=500',
      exercises: ['Push-ups', 'Dumbbell Press', 'Bicep Curls', 'Tricep Dips'],
    ),

    // DANSE
    WorkoutModel(
      id: 'w14',
      title: 'Dance Cardio',
      category: 'Dance',
      duration: '35 min',
      level: 'Beginner',
      calories: '450',
      imageUrl: 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=500',
      exercises: ['Warm-up Groove', 'Hip Hop Moves', 'Zumba Steps', 'Cool Down'],
    ),

    WorkoutModel(
      id: 'w15',
      title: 'Zumba Energy',
      category: 'Dance',
      duration: '50 min',
      level: 'Intermediate',
      calories: '650',
      imageUrl: 'https://images.unsplash.com/photo-1524594154908-edd3dcb1c6b4?w=500',
      exercises: ['Salsa Steps', 'Reggaeton', 'Freestyle Dance', 'Stretch'],
    ),

    // RUNNING
    WorkoutModel(
      id: 'w16',
      title: 'Morning Run',
      category: 'Running',
      duration: '25 min',
      level: 'Beginner',
      calories: '300',
      imageUrl: 'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=500',
      exercises: ['Light Jog', 'Breathing', 'Cooldown Walk'],
    ),

    WorkoutModel(
      id: 'w17',
      title: 'Endurance Run',
      category: 'Running',
      duration: '60 min',
      level: 'Advanced',
      calories: '800',
      imageUrl: 'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=500',
      exercises: ['Warm-up', 'Long Distance Run', 'Sprint Finish'],
    ),
  ];
});

final joinedProgramsProvider = Provider<List<WorkoutModel>>((ref) {
  final workouts = ref.watch(workoutsProvider);
  return workouts.take(3).toList();
});

// Nutrition Provider
final nutritionProvider = Provider<NutritionSummary>((ref) {
  return NutritionSummary(
    currentCalories: 1450,
    targetCalories: 2000,
    carbs: 180,
    protein: 120,
    fat: 45,
    meals: [
      MealModel(id: 'm1', name: 'Oatmeal & Berries', calories: 350, type: 'breakfast', time: '08:00 AM'),
      MealModel(id: 'm2', name: 'Chicken Salad', calories: 450, type: 'lunch', time: '01:00 PM'),
      MealModel(id: 'm3', name: 'Protein Shake', calories: 200, type: 'snack', time: '04:00 PM'),
      MealModel(id: 'm4', name: 'Salmon & Quinoa', calories: 450, type: 'dinner', time: '07:30 PM'),
    ],
  );
});

// Community Posts Provider
final postsProvider = Provider<List<PostModel>>((ref) {
  return [
    PostModel(
      id: 'p_event_1',
      username: 'Sarah',
      userAvatarUrl: 'https://i.pravatar.cc/150?img=1',
      content: 'EVENT: Tennis match this Saturday at 9:00 AM in City Court. Need 3 friends to join. All levels welcome!',
      imageUrl: '',
      likes: 42,
      comments: 18,
      timeAgo: '35m ago',
      isEvent: true,
      eventTitle: 'Saturday Tennis Match',
      eventDate: 'Sat, 26 Apr 2026',
      eventTime: '09:00 AM - 11:00 AM',
      eventLocation: 'City Court, Downtown',
      maxParticipants: 6,
      initialParticipants: const [
        EventParticipant(
          id: 'u_1',
          name: 'Sarah',
          avatarUrl: 'https://i.pravatar.cc/150?img=1',
        ),
        EventParticipant(
          id: 'u_12',
          name: 'Lina',
          avatarUrl: 'https://i.pravatar.cc/150?img=12',
        ),
      ],
    ),
    PostModel(
      id: 'p_text_1',
      username: 'Nora Fit',
      userAvatarUrl: 'https://i.pravatar.cc/150?img=33',
      content: 'Small win today: I finished my workout even with low motivation. Progress over perfection.',
      imageUrl: '',
      likes: 63,
      comments: 11,
      timeAgo: '1h ago',
    ),
   PostModel(
  id: 'p3',
  username: 'Fit Community',
  userAvatarUrl: 'https://i.pravatar.cc/150?img=20',
  content: 'Consistency beats motivation every single time 💯',
  imageUrl: 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=500',
  likes: 210,
  comments: 34,
  timeAgo: '6h ago',
),
PostModel(
  id: 'p2',
  username: 'Jessica Alba',
  userAvatarUrl: 'https://i.pravatar.cc/150?img=32',
  content: 'Balanced meals = better energy all day 🌱💚',
  imageUrl: 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=500',
  likes: 97,
  comments: 12,
  timeAgo: '3h ago',
),
    PostModel(
      id: 'p3',
      username: 'Jessica Alba',
      userAvatarUrl: 'https://i.pravatar.cc/150?img=9',
      content: 'Healthy eating is not a diet, it is a lifestyle. Here is my lunch today 🥗',
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500',
      likes: 89,
      comments: 5,
      timeAgo: '5h ago',
    ),
  ];
});

class EventJoinStateNotifier extends Notifier<Map<String, List<EventParticipant>>> {
  @override
  Map<String, List<EventParticipant>> build() {
    final posts = ref.read(postsProvider);
    final data = <String, List<EventParticipant>>{};

    for (final post in posts) {
      if (post.isEvent) {
        data[post.id] = List<EventParticipant>.from(post.initialParticipants);
      }
    }

    return data;
  }

  bool isJoined({required String postId, required String userId}) {
    final users = state[postId] ?? <EventParticipant>[];
    return users.any((user) => user.id == userId);
  }

  bool isFull({required String postId, required int? maxParticipants}) {
    if (maxParticipants == null) {
      return false;
    }
    final users = state[postId] ?? <EventParticipant>[];
    return users.length >= maxParticipants;
  }

  bool joinEvent({
    required String postId,
    required EventParticipant participant,
    required int? maxParticipants,
  }) {
    final users = List<EventParticipant>.from(state[postId] ?? <EventParticipant>[]);
    final alreadyJoined = users.any((user) => user.id == participant.id);
    if (alreadyJoined) {
      return true;
    }

    if (maxParticipants != null && users.length >= maxParticipants) {
      return false;
    }

    users.add(participant);
    state = {
      ...state,
      postId: users,
    };
    return true;
  }
}

final eventJoinStateProvider =
    NotifierProvider<EventJoinStateNotifier, Map<String, List<EventParticipant>>>(
  EventJoinStateNotifier.new,
);

// Cycle Tracking Mock Provider
class CyclePhase {
  final String name;
  final int dayOfCycle;
  final String advice;
  
  CyclePhase({required this.name, required this.dayOfCycle, required this.advice});
}

final cycleProvider = Provider<CyclePhase>((ref) {
  return CyclePhase(
    name: 'Follicular',
    dayOfCycle: 8,
    advice: 'High energy phase! Great time for HIIT and challenging workouts.',
  );
});

// Body Zones Provider
final bodyZonesProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return [
    {
      'title': 'Abdos Express',
      'imageUrl': 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=500',
      'exercises': ['Crunch basique', 'Planche dynamique', 'Russian Twists', 'Levé de jambes'],
    },
    {
      'title': 'Bas du corps',
      'imageUrl': 'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=500',
      'exercises': ['Squats', 'Fentes arrières', 'Glute Bridges', 'Soulevé de terre roumain'],
    },
    {
      'title': 'Full body HIIT',
      'imageUrl': 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=500',
      'exercises': ['Burpees', 'Jumping Jacks', 'Mountain Climbers', 'High Knees'],
    },
    {
      'title': 'Haut du corps',
      'imageUrl': 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=500',
      'exercises': ['Pompes', 'Dips triceps', 'Planche commando', 'Superman'],
    },
  ];
});
