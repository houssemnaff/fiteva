import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/home_program_model.dart';
import '../models/user_model.dart';
import '../models/workout_model.dart';
import '../models/video_model.dart';
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

final joinedProgramsProvider = Provider<List<HomeProgramModel>>((ref) {
  final programs = ref.watch(homeProgramsProvider);
  return programs.take(3).toList();
});

// Workouts Provider — extracts all workouts from all programs
final workoutsProvider = Provider<List<WorkoutModel>>((ref) {
  final homePrograms = ref.watch(homeProgramsProvider);
  final sallePrograms = ref.watch(salleProgramsProvider);

  final allWorkouts = <WorkoutModel>[];

  for (final program in homePrograms) {
    allWorkouts.addAll(program.workouts);
  }

  for (final program in sallePrograms) {
    allWorkouts.addAll(program.workouts);
  }

  return allWorkouts;
});

final homeProgramsProvider = Provider<List<HomeProgramModel>>((ref) {
  return [
    HomeProgramModel(
      id: 'prog_home_glow',
      name: 'Home Glow',
      duration: '4 semaines',
      phases: 'Règles + Foll. + Ovul.',
      sessions: '3 séances / sem.',
      color: const Color(0xFF3B7DD8),
      imageUrl: 'assets/images/fullbody.jpg',
      compatibleCycles: const ['Folliculaire', 'Ovulation'],
      totalPoints: 100,
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
          points: 35,
          videos: [
            VideoModel(id: 'vid_hg1_1', title: 'Warm Up', duration: '3 min', points: 12),
            VideoModel(id: 'vid_hg1_2', title: 'Main Workout', duration: '14 min', points: 12),
            VideoModel(id: 'vid_hg1_3', title: 'Cool Down', duration: '3 min', points: 11),
          ],
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
          points: 30,
          videos: [
            VideoModel(id: 'vid_hg2_1', title: 'Core Activation', duration: '6 min', points: 10),
            VideoModel(id: 'vid_hg2_2', title: 'Posture Work', duration: '10 min', points: 10),
            VideoModel(id: 'vid_hg2_3', title: 'Stretch', duration: '2 min', points: 10),
          ],
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
          points: 35,
          videos: [
            VideoModel(id: 'vid_hg3_1', title: 'Cardio Warm Up', duration: '3 min', points: 12),
            VideoModel(id: 'vid_hg3_2', title: 'HIIT Circuit', duration: '10 min', points: 12),
            VideoModel(id: 'vid_hg3_3', title: 'Recovery', duration: '2 min', points: 11),
          ],
        ),
      ],
    ),
    HomeProgramModel(
      id: 'prog_pilates_reset',
      name: 'Pilates Reset',
      duration: '8 semaines',
      phases: 'Toutes phases',
      sessions: '3 séances / sem.',
      color: const Color(0xFF1565C0),
      imageUrl: 'assets/images/pilates.jpg',
      compatibleCycles: const ['Règles', 'Lutéale'],
      totalPoints: 100,
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
          points: 35,
          videos: [
            VideoModel(id: 'vid_pr1_1', title: 'Breathing Exercise', duration: '5 min', points: 12),
            VideoModel(id: 'vid_pr1_2', title: 'Roll Up Series', duration: '12 min', points: 12),
            VideoModel(id: 'vid_pr1_3', title: 'Hundred Prep', duration: '8 min', points: 11),
          ],
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
          points: 32,
          videos: [
            VideoModel(id: 'vid_pr2_1', title: 'Spine Warm Up', duration: '6 min', points: 11),
            VideoModel(id: 'vid_pr2_2', title: 'Mobility Flow', duration: '12 min', points: 11),
            VideoModel(id: 'vid_pr2_3', title: 'Teaser Prep', duration: '4 min', points: 10),
          ],
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
          points: 33,
          videos: [
            VideoModel(id: 'vid_pr3_1', title: 'Core Activation', duration: '7 min', points: 11),
            VideoModel(id: 'vid_pr3_2', title: 'Core Series', duration: '11 min', points: 11),
            VideoModel(id: 'vid_pr3_3', title: 'Core Finisher', duration: '2 min', points: 11),
          ],
        ),
      ],
    ),
    HomeProgramModel(
      id: 'prog_booty_home',
      name: 'Booty From Home',
      duration: '4 semaines',
      phases: 'Toutes phases',
      sessions: '4 séances / sem.',
      color: const Color(0xFF283593),
      imageUrl: 'assets/images/strength.jpg',
      compatibleCycles: const ['Folliculaire', 'Lutéale'],
      totalPoints: 100,
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
          points: 30,
          videos: [
            VideoModel(id: 'vid_bh1_1', title: 'Activation Warm Up', duration: '5 min', points: 10),
            VideoModel(id: 'vid_bh1_2', title: 'Glute Work', duration: '10 min', points: 10),
            VideoModel(id: 'vid_bh1_3', title: 'Stretch & Recover', duration: '3 min', points: 10),
          ],
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
          points: 35,
          videos: [
            VideoModel(id: 'vid_bh2_1', title: 'Sculpt Warm Up', duration: '4 min', points: 12),
            VideoModel(id: 'vid_bh2_2', title: 'Booty Series', duration: '16 min', points: 12),
            VideoModel(id: 'vid_bh2_3', title: 'Cool Down', duration: '4 min', points: 11),
          ],
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
          points: 35,
          videos: [
            VideoModel(id: 'vid_bh3_1', title: 'Finisher Start', duration: '2 min', points: 12),
            VideoModel(id: 'vid_bh3_2', title: 'HIIT Finisher', duration: '8 min', points: 12),
            VideoModel(id: 'vid_bh3_3', title: 'Cooldown', duration: '2 min', points: 11),
          ],
        ),
      ],
    ),
  ];
});

final salleProgramsProvider = Provider<List<HomeProgramModel>>((ref) {
  return [
    HomeProgramModel(
      id: 'prog_salle_builder',
      name: 'Body Builder',
      duration: '6 semaines',
      phases: 'Follic. + Ovul.',
      sessions: '4 séances / sem.',
      color: const Color(0xFF1C4D30),
      imageUrl: 'assets/images/strength.jpg',
      compatibleCycles: const ['Folliculaire', 'Ovulation'],
      totalPoints: 100,
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
          points: 35,
          videos: [
            VideoModel(id: 'vid_sb1_1', title: 'Form Check', duration: '5 min', points: 12),
            VideoModel(id: 'vid_sb1_2', title: 'Heavy Sets', duration: '16 min', points: 12),
            VideoModel(id: 'vid_sb1_3', title: 'Recovery', duration: '4 min', points: 11),
          ],
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
          points: 33,
          videos: [
            VideoModel(id: 'vid_sb2_1', title: 'Warm Up', duration: '4 min', points: 11),
            VideoModel(id: 'vid_sb2_2', title: 'Pull Series', duration: '13 min', points: 11),
            VideoModel(id: 'vid_sb2_3', title: 'Stretch', duration: '3 min', points: 11),
          ],
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
          points: 32,
          videos: [
            VideoModel(id: 'vid_sb3_1', title: 'Leg Warm Up', duration: '4 min', points: 11),
            VideoModel(id: 'vid_sb3_2', title: 'Power Work', duration: '14 min', points: 11),
            VideoModel(id: 'vid_sb3_3', title: 'Cool Down', duration: '4 min', points: 10),
          ],
        ),
      ],
    ),
    HomeProgramModel(
      id: 'prog_salle_stronger',
      name: 'Stronger You',
      duration: '4 semaines',
      phases: 'Toutes phases',
      sessions: '3 séances / sem.',
      color: const Color(0xFF2E7D32),
      imageUrl: 'assets/images/upper.jpg',
      compatibleCycles: const ['Règles', 'Ovulation'],
      totalPoints: 100,
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
          points: 34,
          videos: [
            VideoModel(id: 'vid_ss1_1', title: 'Push Warm Up', duration: '4 min', points: 11),
            VideoModel(id: 'vid_ss1_2', title: 'Push Series', duration: '13 min', points: 12),
            VideoModel(id: 'vid_ss1_3', title: 'Finish', duration: '3 min', points: 11),
          ],
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
          points: 33,
          videos: [
            VideoModel(id: 'vid_ss2_1', title: 'Back Activation', duration: '5 min', points: 11),
            VideoModel(id: 'vid_ss2_2', title: 'Back Building', duration: '14 min', points: 11),
            VideoModel(id: 'vid_ss2_3', title: 'Stretch', duration: '3 min', points: 11),
          ],
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
          points: 33,
          videos: [
            VideoModel(id: 'vid_ss3_1', title: 'Arms Warm Up', duration: '3 min', points: 11),
            VideoModel(id: 'vid_ss3_2', title: 'Arms Series', duration: '10 min', points: 11),
            VideoModel(id: 'vid_ss3_3', title: 'Finisher', duration: '2 min', points: 11),
          ],
        ),
      ],
    ),
    HomeProgramModel(
      id: 'prog_salle_lean',
      name: 'Lean 4 Life',
      duration: '4 semaines',
      phases: 'Toutes phases',
      sessions: '3 séances / sem.',
      color: const Color(0xFF00695C),
      imageUrl: 'assets/images/fullbody.jpg',
      compatibleCycles: const ['Règles', 'Folliculaire', 'Lutéale'],
      totalPoints: 100,
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
          points: 34,
          videos: [
            VideoModel(id: 'vid_sl1_1', title: 'Full Body Warm Up', duration: '5 min', points: 11),
            VideoModel(id: 'vid_sl1_2', title: 'Strength Work', duration: '16 min', points: 12),
            VideoModel(id: 'vid_sl1_3', title: 'Cool Down', duration: '4 min', points: 11),
          ],
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
          points: 33,
          videos: [
            VideoModel(id: 'vid_sl2_1', title: 'Circuit Intro', duration: '3 min', points: 11),
            VideoModel(id: 'vid_sl2_2', title: 'Burn Circuit', duration: '14 min', points: 11),
            VideoModel(id: 'vid_sl2_3', title: 'Recovery', duration: '3 min', points: 11),
          ],
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
          points: 33,
          videos: [
            VideoModel(id: 'vid_sl3_1', title: 'Core Prep', duration: '3 min', points: 11),
            VideoModel(id: 'vid_sl3_2', title: 'Core Work', duration: '7 min', points: 11),
            VideoModel(id: 'vid_sl3_3', title: 'Finisher', duration: '2 min', points: 11),
          ],
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

// Dance Programs Provider
final danceProgramsProvider = Provider<List<HomeProgramModel>>((ref) {
  return [
    HomeProgramModel(
      id: 'prog_dance_zumba_flow',
      name: 'Zumba Flow',
      duration: '4 semaines',
      phases: 'Toutes phases',
      sessions: '3 séances / sem.',
      color: const Color(0xFFE91E63),
      imageUrl: 'assets/images/fullbody.jpg',
      compatibleCycles: const ['Folliculaire', 'Ovulation'],
      totalPoints: 100,
      workouts: [
        WorkoutModel(
          id: 'dance_zumba_1',
          title: 'Zumba Basics',
          category: 'DANCE',
          duration: '20 min',
          level: 'Débutant',
          calories: '200',
          imageUrl: 'assets/images/fullbody.jpg',
          exercises: ['Basic Step', 'Hip Movement', 'Arm Patterns'],
          points: 35,
          videos: [
            VideoModel(id: 'vid_dz1_1', title: 'Intro & Warm Up', duration: '4 min', points: 12),
            VideoModel(id: 'vid_dz1_2', title: 'Basic Steps', duration: '12 min', points: 12),
            VideoModel(id: 'vid_dz1_3', title: 'Cool Down', duration: '4 min', points: 11),
          ],
        ),
        WorkoutModel(
          id: 'dance_zumba_2',
          title: 'Zumba Party',
          category: 'DANCE',
          duration: '25 min',
          level: 'Intermédiaire',
          calories: '250',
          imageUrl: 'assets/images/fullbody.jpg',
          exercises: ['Salsa', 'Reggaeton', 'Latin Moves'],
          points: 35,
          videos: [
            VideoModel(id: 'vid_dz2_1', title: 'Warm Up', duration: '4 min', points: 12),
            VideoModel(id: 'vid_dz2_2', title: 'Party Combo', duration: '17 min', points: 12),
            VideoModel(id: 'vid_dz2_3', title: 'Stretch', duration: '4 min', points: 11),
          ],
        ),
        WorkoutModel(
          id: 'dance_zumba_3',
          title: 'Zumba Cardio Blast',
          category: 'DANCE',
          duration: '30 min',
          level: 'Avancé',
          calories: '300',
          imageUrl: 'assets/images/fullbody.jpg',
          exercises: ['Fast Pace', 'Complex Moves', 'Combinations'],
          points: 30,
          videos: [
            VideoModel(id: 'vid_dz3_1', title: 'Energy Start', duration: '5 min', points: 10),
            VideoModel(id: 'vid_dz3_2', title: 'Full Blast', duration: '22 min', points: 10),
            VideoModel(id: 'vid_dz3_3', title: 'Recovery', duration: '3 min', points: 10),
          ],
        ),
      ],
    ),
  ];
});

// Recuperation Programs Provider
final recuperationProgramsProvider = Provider<List<HomeProgramModel>>((ref) {
  return [
    HomeProgramModel(
      id: 'prog_recovery_gentle',
      name: 'Gentle Recovery',
      duration: '2 semaines',
      phases: 'Toutes phases',
      sessions: '5 séances / sem.',
      color: const Color(0xFF00BCD4),
      imageUrl: 'assets/images/fullbody.jpg',
      compatibleCycles: const ['Règles', 'Lutéale'],
      totalPoints: 80,
      workouts: [
        WorkoutModel(
          id: 'recup_gentle_1',
          title: 'Yoga Relaxation',
          category: 'RECUPERATION',
          duration: '15 min',
          level: 'Tous niveaux',
          calories: '80',
          imageUrl: 'assets/images/fullbody.jpg',
          exercises: ['Child Pose', 'Cat-Cow', 'Savasana'],
          points: 25,
          videos: [
            VideoModel(id: 'vid_rg1_1', title: 'Centering', duration: '3 min', points: 8),
            VideoModel(id: 'vid_rg1_2', title: 'Gentle Flow', duration: '10 min', points: 9),
            VideoModel(id: 'vid_rg1_3', title: 'Meditation', duration: '2 min', points: 8),
          ],
        ),
        WorkoutModel(
          id: 'recup_gentle_2',
          title: 'Stretching Session',
          category: 'RECUPERATION',
          duration: '18 min',
          level: 'Tous niveaux',
          calories: '90',
          imageUrl: 'assets/images/fullbody.jpg',
          exercises: ['Full Body Stretch', 'Deep Stretches', 'Breathing'],
          points: 27,
          videos: [
            VideoModel(id: 'vid_rg2_1', title: 'Warm Up', duration: '3 min', points: 9),
            VideoModel(id: 'vid_rg2_2', title: 'Deep Stretches', duration: '13 min', points: 9),
            VideoModel(id: 'vid_rg2_3', title: 'Breathwork', duration: '2 min', points: 9),
          ],
        ),
        WorkoutModel(
          id: 'recup_gentle_3',
          title: 'Foam Rolling & Mobility',
          category: 'RECUPERATION',
          duration: '20 min',
          level: 'Intermédiaire',
          calories: '100',
          imageUrl: 'assets/images/fullbody.jpg',
          exercises: ['Foam Roll', 'Mobility Work', 'Joint Care'],
          points: 28,
          videos: [
            VideoModel(id: 'vid_rg3_1', title: 'Intro', duration: '2 min', points: 9),
            VideoModel(id: 'vid_rg3_2', title: 'Rolling & Mobility', duration: '16 min', points: 10),
            VideoModel(id: 'vid_rg3_3', title: 'Finish', duration: '2 min', points: 9),
          ],
        ),
      ],
    ),
  ];
});

// Grossesse Programs Provider
final grossesseProgramsProvider = Provider<List<HomeProgramModel>>((ref) {
  return [
    HomeProgramModel(
      id: 'prog_pregnancy_safe',
      name: 'Pregnancy Safe',
      duration: '9 mois',
      phases: 'Grossesse',
      sessions: '3 séances / sem.',
      color: const Color(0xFFFFB74D),
      imageUrl: 'assets/images/fullbody.jpg',
      compatibleCycles: const ['Grossesse'],
      totalPoints: 120,
      workouts: [
        WorkoutModel(
          id: 'preg_safe_1',
          title: 'First Trimester Cardio',
          category: 'GROSSESSE',
          duration: '20 min',
          level: 'Débutant',
          calories: '150',
          imageUrl: 'assets/images/fullbody.jpg',
          exercises: ['Walking', 'Light Cardio', 'Breathing'],
          points: 40,
          videos: [
            VideoModel(id: 'vid_ps1_1', title: 'Safe Start', duration: '3 min', points: 13),
            VideoModel(id: 'vid_ps1_2', title: 'Cardio Flow', duration: '14 min', points: 14),
            VideoModel(id: 'vid_ps1_3', title: 'Recovery', duration: '3 min', points: 13),
          ],
        ),
        WorkoutModel(
          id: 'preg_safe_2',
          title: 'Pelvic Floor Strength',
          category: 'GROSSESSE',
          duration: '18 min',
          level: 'Tous niveaux',
          calories: '120',
          imageUrl: 'assets/images/fullbody.jpg',
          exercises: ['Pelvic Floor', 'Kegels', 'Core Work'],
          points: 40,
          videos: [
            VideoModel(id: 'vid_ps2_1', title: 'Introduction', duration: '3 min', points: 13),
            VideoModel(id: 'vid_ps2_2', title: 'Pelvic Work', duration: '12 min', points: 14),
            VideoModel(id: 'vid_ps2_3', title: 'Relaxation', duration: '3 min', points: 13),
          ],
        ),
        WorkoutModel(
          id: 'preg_safe_3',
          title: 'Prenatal Yoga',
          category: 'GROSSESSE',
          duration: '25 min',
          level: 'Tous niveaux',
          calories: '140',
          imageUrl: 'assets/images/fullbody.jpg',
          exercises: ['Prenatal Poses', 'Stretching', 'Meditation'],
          points: 40,
          videos: [
            VideoModel(id: 'vid_ps3_1', title: 'Centering', duration: '4 min', points: 13),
            VideoModel(id: 'vid_ps3_2', title: 'Yoga Flow', duration: '17 min', points: 14),
            VideoModel(id: 'vid_ps3_3', title: 'Meditation', duration: '4 min', points: 13),
          ],
        ),
      ],
    ),
  ];
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
