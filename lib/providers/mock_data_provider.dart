import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/home_program_model.dart';
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
      imageUrl: 'assets/images/fullbody.jpg',
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
      imageUrl: 'assets/images/pilates.jpg',
      exercises: ['The Hundred', 'Roll Up', 'Single Leg Circle', 'Rolling Like a Ball'],
    ),

    WorkoutModel(
      id: 'w12',
      title: 'Core Pilates',
      category: 'Pilates',
      duration: '20 min',
      level: 'Intermediate',
      calories: '400',
      imageUrl: 'assets/images/Core.jpg',
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
      imageUrl: 'assets/images/strength.jpg',
      exercises: ['Deadlifts', 'Squats', 'Bench Press', 'Pull-ups'],
    ),

    WorkoutModel(
      id: 'w13',
      title: 'Upper Body Workout',
      category: 'musculation',
      duration: '40 min',
      level: 'Intermediate',
      calories: '550',
      imageUrl: 'assets/images/upper.jpg',
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
      imageUrl: 'assets/images/cardio.jpg',
      phases: 'Follic. + Ovul.',
      exercises: ['Warm-up Groove', 'Hip Hop Moves', 'Zumba Steps', 'Cool Down'],
    ),

    WorkoutModel(
      id: 'w15',
      title: 'Zumba Energy',
      category: 'Dance',
      duration: '50 min',
      level: 'Intermediate',
      calories: '650',
      imageUrl: 'assets/images/Zumba.jpg',
      phases: 'Ovul.',
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
      imageUrl: 'assets/images/Morning.jpg',
      phases: 'Follic. + Ovul.',
      exercises: ['Light Jog', 'Breathing', 'Cooldown Walk'],
    ),

    WorkoutModel(
      id: 'w17',
      title: 'Endurance Run',
      category: 'Running',
      duration: '60 min',
      level: 'Advanced',
      calories: '800',
      imageUrl: 'assets/images/Endurance.jpg',
      phases: 'Ovul.',
      exercises: ['Warm-up', 'Long Distance Run', 'Sprint Finish'],
    ),
    // SALLE
    WorkoutModel(
      id: 'w_salle_1',
      title: 'Power Lift',
      category: 'SALLE',
      duration: '55 min',
      level: 'Intermédiaire',
      calories: '620',
      imageUrl: 'assets/images/strength.jpg',
      phases: 'Follic. + Ovul.',
      exercises: ['Deadlift', 'Back Squat', 'Bench Press', 'Row Machine'],
    ),
    WorkoutModel(
      id: 'w_salle_2',
      title: 'Upper Build',
      category: 'SALLE',
      duration: '45 min',
      level: 'Avancé',
      calories: '540',
      imageUrl: 'assets/images/upper.jpg',
      phases: 'Ovul. + Lut.',
      exercises: ['Pull-ups', 'Dumbbell Press', 'Lat Pulldown', 'Dips'],
    ),
    WorkoutModel(
      id: 'w_salle_3',
      title: 'Machine Burn',
      category: 'SALLE',
      duration: '40 min',
      level: 'Débutant',
      calories: '480',
      imageUrl: 'assets/images/workout.jpeg',
      phases: 'Follic. + Lut.',
      exercises: ['Leg Press', 'Chest Press', 'Cable Rows', 'Ab Crunch Machine'],
    ),
    // MAISON
    WorkoutModel(
      id: 'w_maison_1',
      title: 'Home Burn',
      category: 'MAISON',
      duration: '30 min',
      level: 'Tous niveaux',
      calories: '300',
      imageUrl: 'assets/images/fullbody.jpg',
      phases: 'Follic. + Ovul.',
      exercises: ['Squats', 'Push-ups', 'Mountain Climbers', 'Plank'],
    ),
    WorkoutModel(
      id: 'w_maison_2',
      title: 'No Equipment Flow',
      category: 'MAISON',
      duration: '25 min',
      level: 'Débutant',
      calories: '240',
      imageUrl: 'assets/images/fiteva_girl.jpg',
      phases: 'Follic. + Lut.',
      exercises: ['Warm-up March', 'Glute Bridge', 'Standing Crunch', 'Side Lunges'],
    ),
    WorkoutModel(
      id: 'w_maison_3',
      title: 'Core At Home',
      category: 'MAISON',
      duration: '20 min',
      level: 'Intermédiaire',
      calories: '220',
      imageUrl: 'assets/images/slim1.png',
      phases: 'Toutes phases',
      exercises: ['Dead Bug', 'Russian Twist', 'Leg Raise', 'Hollow Hold'],
    ),
    // GROSSESSE
    WorkoutModel(
      id: 'w_preg_1',
      title: 'Pregnancy Gentle Flow',
      category: 'Grossesse',
      duration: '25 min',
      level: 'Tous niveaux',
      calories: '120',
      imageUrl: 'assets/images/Endurance.jpg',
      phases: 'Toutes phases',
      exercises: ['Respiration guidée', 'Étirements doux', 'Mobilité pelvienne'],
    ),
    WorkoutModel(
      id: 'w_preg_2',
      title: 'Prenatal Strength',
      category: 'Grossesse',
      duration: '30 min',
      level: 'Débutant',
      calories: '160',
      imageUrl: 'assets/images/Endurance.jpg',
      phases: 'Toutes phases',
      exercises: ['Ponts fessiers', 'Squats assistés', 'Travail du dos'],
    ),
    WorkoutModel(
      id: 'w_preg_3',
      title: 'Posture & Pelvis',
      category: 'Grossesse',
      duration: '20 min',
      level: 'Tous niveaux',
      calories: '100',
      imageUrl: 'assets/images/Endurance.jpg',
      phases: 'Toutes phases',
      exercises: ['Renforcement du périnée', 'Étirements du dos', 'Alignement postural'],
    ),
    // RÉCUPÉRATION
    WorkoutModel(
      id: 'w_recup_1',
      title: 'Yoga Relax',
      category: 'RECUPERATION',
      duration: '20 min',
      level: 'Tous niveaux',
      calories: '90',
      imageUrl: 'assets/images/Endurance.jpg',
      phases: 'Règles + Lut.',
      exercises: ['Respiration profonde', 'Étirements doux', 'Relaxation guidée'],
    ),
    WorkoutModel(
      id: 'w_recup_2',
      title: 'Deep Stretch',
      category: 'RECUPERATION',
      duration: '25 min',
      level: 'Débutant',
      calories: '110',
      imageUrl: 'assets/images/Endurance.jpg',
      phases: 'Règles + Lut.',
      exercises: ['Étirement des ischio-jambiers', 'Étirement du dos', 'Ouverture des hanches'],
    ),
    WorkoutModel(
      id: 'w_recup_3',
      title: 'Guided Meditation',
      category: 'RECUPERATION',
      duration: '15 min',
      level: 'Tous niveaux',
      calories: '50',
      imageUrl: 'assets/images/Endurance.jpg',
      phases: 'Règles + Lut.',
      exercises: ['Méditation assise', 'Scan corporel', 'Respiration rythmée'],
    ),
  ];
});

final joinedProgramsProvider = Provider<List<WorkoutModel>>((ref) {
  final workouts = ref.watch(workoutsProvider);
  return workouts.take(3).toList();
});

final homeProgramsProvider = Provider<List<HomeProgramModel>>((ref) {
  return [
    HomeProgramModel(
      name: 'Home Glow',
      duration: '4 semaines',
      phases: 'Règles + Foll. + Ovul.',
      sessions: '3 séances / sem.',
      color: const Color(0xFF3B7DD8),
      imageUrl: 'assets/images/fullbody.jpg',
      compatibleCycles: const ['Folliculaire', 'Ovulation'],
      workouts: [
        WorkoutModel(
          id: 'home_glow_1',
          title: 'Lower Body Flow',
          category: 'MAISON',
          duration: '20 min',
          level: 'Tous niveaux',
          calories: '220',
          imageUrl: 'assets/images/fullbody.jpg',
          exercises: ['Squats', 'Glute Bridge', 'Lunges'],
        ),
        WorkoutModel(
          id: 'home_glow_2',
          title: 'Core & Posture',
          category: 'MAISON',
          duration: '18 min',
          level: 'Débutant',
          calories: '180',
          imageUrl: 'assets/images/slim1.png',
          exercises: ['Dead Bug', 'Bird Dog', 'Plank'],
        ),
        WorkoutModel(
          id: 'home_glow_3',
          title: 'Quick Cardio',
          category: 'MAISON',
          duration: '15 min',
          level: 'Intermédiaire',
          calories: '200',
          imageUrl: 'assets/images/fiteva_girl.jpg',
          exercises: ['March Run', 'Jumping Jacks', 'High Knees'],
        ),
      ],
    ),
    HomeProgramModel(
      name: 'Pilates Reset',
      duration: '8 semaines',
      phases: 'Toutes phases',
      sessions: '3 séances / sem.',
      color: const Color(0xFF1565C0),
      imageUrl: 'assets/images/pilates.jpg',
      compatibleCycles: const ['Règles', 'Lutéale'],
      workouts: [
        WorkoutModel(
          id: 'pilates_reset_1',
          title: 'Morning Centering',
          category: 'MAISON',
          duration: '25 min',
          level: 'Débutant',
          calories: '180',
          imageUrl: 'assets/images/pilates.jpg',
          exercises: ['Breathing', 'Roll Up', 'Hundred'],
        ),
        WorkoutModel(
          id: 'pilates_reset_2',
          title: 'Spine Mobility',
          category: 'MAISON',
          duration: '22 min',
          level: 'Tous niveaux',
          calories: '170',
          imageUrl: 'assets/images/Core.jpg',
          exercises: ['Cat-Cow', 'Side Reach', 'Teaser Prep'],
        ),
        WorkoutModel(
          id: 'pilates_reset_3',
          title: 'Deep Core Work',
          category: 'MAISON',
          duration: '20 min',
          level: 'Intermédiaire',
          calories: '190',
          imageUrl: 'assets/images/Core.jpg',
          exercises: ['Single Leg Stretch', 'Leg Circle', 'Plank'],
        ),
      ],
    ),
    HomeProgramModel(
      name: 'Booty From Home',
      duration: '4 semaines',
      phases: 'Toutes phases',
      sessions: '4 séances / sem.',
      color: const Color(0xFF283593),
      imageUrl: 'assets/images/strength.jpg',
      compatibleCycles: const ['Folliculaire', 'Lutéale'],
      workouts: [
        WorkoutModel(
          id: 'booty_home_1',
          title: 'Glute Activation',
          category: 'MAISON',
          duration: '18 min',
          level: 'Débutant',
          calories: '200',
          imageUrl: 'assets/images/strength.jpg',
          exercises: ['Clamshell', 'Glute Bridge', 'Kickback'],
        ),
        WorkoutModel(
          id: 'booty_home_2',
          title: 'Booty Sculpt',
          category: 'MAISON',
          duration: '24 min',
          level: 'Intermédiaire',
          calories: '240',
          imageUrl: 'assets/images/upper.jpg',
          exercises: ['Squats', 'Sumo Squats', 'Split Squats'],
        ),
        WorkoutModel(
          id: 'booty_home_3',
          title: 'Finisher Burn',
          category: 'MAISON',
          duration: '12 min',
          level: 'Tous niveaux',
          calories: '150',
          imageUrl: 'assets/images/fullbody.jpg',
          exercises: ['Pulse Squats', 'Donkey Kicks', 'Wall Sit'],
        ),
      ],
    ),
  
  
  ];
});

final salleProgramsProvider = Provider<List<HomeProgramModel>>((ref) {
  return [
    HomeProgramModel(
      name: 'Body Builder',
      duration: '6 semaines',
      phases: 'Follic. + Ovul.',
      sessions: '4 séances / sem.',
      color: const Color(0xFF1C4D30),
      imageUrl: 'assets/images/strength.jpg',
      compatibleCycles: const ['Folliculaire', 'Ovulation'],
      workouts: [
        WorkoutModel(
          id: 'salle_body_1',
          title: 'Heavy Compound',
          category: 'SALLE',
          duration: '25 min',
          level: 'Intermédiaire',
          calories: '260',
          imageUrl: 'assets/images/strength.jpg',
          exercises: ['Deadlift', 'Back Squat', 'Bench Press'],
        ),
        WorkoutModel(
          id: 'salle_body_2',
          title: 'Pull Focus',
          category: 'SALLE',
          duration: '20 min',
          level: 'Avancé',
          calories: '230',
          imageUrl: 'assets/images/upper.jpg',
          exercises: ['Pull-ups', 'Row Machine', 'Lat Pulldown'],
        ),
        WorkoutModel(
          id: 'salle_body_3',
          title: 'Leg Power',
          category: 'SALLE',
          duration: '22 min',
          level: 'Débutant',
          calories: '240',
          imageUrl: 'assets/images/workout.jpeg',
          exercises: ['Leg Press', 'Lunges', 'Calf Raises'],
        ),
      ],
    ),

  HomeProgramModel(
      name: 'Body ',
      duration: '6 semaines',
      phases: 'Follic. + Ovul.',
      sessions: '4 séances / sem.',
      color: const Color(0xFF1C4D30),
      imageUrl: 'assets/images/strength.jpg',
      compatibleCycles: const ['Folliculaire', 'Ovulation'],
      workouts: [
        WorkoutModel(
          id: 'salle_body_1',
          title: 'Heavy Compound',
          category: 'SALLE',
          duration: '25 min',
          level: 'Intermédiaire',
          calories: '260',
          imageUrl: 'assets/images/strength.jpg',
          exercises: ['Deadlift', 'Back Squat', 'Bench Press'],
        ),
        WorkoutModel(
          id: 'salle_body_2',
          title: 'Pull Focus',
          category: 'SALLE',
          duration: '20 min',
          level: 'Avancé',
          calories: '230',
          imageUrl: 'assets/images/upper.jpg',
          exercises: ['Pull-ups', 'Row Machine', 'Lat Pulldown'],
        ),
        WorkoutModel(
          id: 'salle_body_3',
          title: 'Leg Power',
          category: 'SALLE',
          duration: '22 min',
          level: 'Débutant',
          calories: '240',
          imageUrl: 'assets/images/workout.jpeg',
          exercises: ['Leg Press', 'Lunges', 'Calf Raises'],
        ),
      ],
    ),

    HomeProgramModel(
      name: 'Stronger You',
      duration: '4 semaines',
      phases: 'Toutes phases',
      sessions: '3 séances / sem.',
      color: const Color(0xFF2E7D32),
      imageUrl: 'assets/images/upper.jpg',
      compatibleCycles: const ['Règles', 'Ovulation'],
      workouts: [
        WorkoutModel(
          id: 'salle_stronger_1',
          title: 'Upper Push',
          category: 'SALLE',
          duration: '20 min',
          level: 'Intermédiaire',
          calories: '220',
          imageUrl: 'assets/images/upper.jpg',
          exercises: ['Push-ups', 'Dumbbell Press', 'Tricep Dips'],
        ),
        WorkoutModel(
          id: 'salle_stronger_2',
          title: 'Back Builder',
          category: 'SALLE',
          duration: '22 min',
          level: 'Avancé',
          calories: '240',
          imageUrl: 'assets/images/strength.jpg',
          exercises: ['Lat Pulldown', 'Bent Over Row', 'Face Pull'],
        ),
        WorkoutModel(
          id: 'salle_stronger_3',
          title: 'Arms Finish',
          category: 'SALLE',
          duration: '15 min',
          level: 'Tous niveaux',
          calories: '180',
          imageUrl: 'assets/images/workout.jpeg',
          exercises: ['Bicep Curls', 'Hammer Curls', 'Overhead Press'],
        ),
      ],
    ),
    HomeProgramModel(
      name: 'Lean 4 Life',
      duration: '4 semaines',
      phases: 'Toutes phases',
      sessions: '3 séances / sem.',
      color: const Color(0xFF00695C),
      imageUrl: 'assets/images/fullbody.jpg',
      compatibleCycles: const ['Règles', 'Folliculaire', 'Lutéale'],
      workouts: [
        WorkoutModel(
          id: 'salle_lean_1',
          title: 'Full Body Strength',
          category: 'SALLE',
          duration: '25 min',
          level: 'Tous niveaux',
          calories: '240',
          imageUrl: 'assets/images/fullbody.jpg',
          exercises: ['Squats', 'Press', 'Rows'],
        ),
        WorkoutModel(
          id: 'salle_lean_2',
          title: 'Burn Circuit',
          category: 'SALLE',
          duration: '20 min',
          level: 'Intermédiaire',
          calories: '230',
          imageUrl: 'assets/images/upper.jpg',
          exercises: ['Thrusters', 'Mountain Climbers', 'Burpees'],
        ),
        WorkoutModel(
          id: 'salle_lean_3',
          title: 'Core Finisher',
          category: 'SALLE',
          duration: '12 min',
          level: 'Débutant',
          calories: '150',
          imageUrl: 'assets/images/Core.jpg',
          exercises: ['Plank', 'Russian Twist', 'Leg Raise'],
        ),
      ],
    ),
  ];
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
});// Community Posts Provider
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
      category: 'Challenge',
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
      category: 'Workout',
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
      category: 'Workout',
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
      category: 'Nutrition',
    ),
    PostModel(
      id: 'p4',
      username: 'Jessica Alba',
      userAvatarUrl: 'https://i.pravatar.cc/150?img=9',
      content: 'Healthy eating is not a diet, it is a lifestyle. Here is my lunch today 🥗',
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=500',
      likes: 89,
      comments: 5,
      timeAgo: '5h ago',
      category: 'Nutrition',
    ),
  ];
});




// Cycle Tracking Mock Provider
class CycleStatus {
  final String name;
  final int dayOfCycle;
  final String advice;
  
  CycleStatus({required this.name, required this.dayOfCycle, required this.advice});
}

final cycleProvider = Provider<CycleStatus>((ref) {
  return CycleStatus(
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
      'imageUrl': 'assets/images/strength.jpg',
      'exercises': ['Crunch basique', 'Planche dynamique', 'Russian Twists', 'Levé de jambes'],
    },
    {
      'title': 'Bas du corps',
        'imageUrl': 'assets/images/legs.jpg',
      'exercises': ['Squats', 'Fentes arrières', 'Glute Bridges', 'Soulevé de terre roumain'],
    },
    {
      'title': 'Full body HIIT',
      'imageUrl': 'assets/images/fullbody.jpg',
      'exercises': ['Burpees', 'Jumping Jacks', 'Mountain Climbers', 'High Knees'],
    },
    {
      'title': 'Haut du corps',
      'imageUrl': 'assets/images/upperbody.jpg',
      'exercises': ['Pompes', 'Dips triceps', 'Planche commando', 'Superman'],
    },
  ];
});
