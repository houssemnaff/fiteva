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
    WorkoutModel(
      id: 'w1',
      title: 'Full Body HIIT',
      category: 'HIIT',
      duration: '45 min',
      level: 'Intermediate',
      imageUrl: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=500',
      exercises: ['Jumping Jacks', 'Burpees', 'Mountain Climbers', 'Squat Jumps'],
    ),
    WorkoutModel(
      id: 'w2',
      title: 'Morning Pilates',
      category: 'Pilates',
      duration: '30 min',
      level: 'Beginner',
      imageUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=500',
      exercises: ['The Hundred', 'Roll Up', 'Single Leg Circle', 'Rolling Like a Ball'],
    ),
    WorkoutModel(
      id: 'w3',
      title: 'Strength Training',
      category: 'Strength',
      duration: '60 min',
      level: 'Advanced',
      imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=500',
      exercises: ['Deadlifts', 'Squats', 'Bench Press', 'Pull-ups'],
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
});

// Community Posts Provider
final postsProvider = Provider<List<PostModel>>((ref) {
  return [
    PostModel(
      id: 'p1',
      username: 'Emma Fit',
      userAvatarUrl: 'https://i.pravatar.cc/150?img=5',
      content: 'Just finished my first 5k run! Feeling amazing 💪',
      imageUrl: 'https://images.unsplash.com/photo-1552674605-db6aea1128d8?w=500',
      likes: 124,
      comments: 18,
      timeAgo: '2h ago',
    ),
    PostModel(
      id: 'p2',
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
