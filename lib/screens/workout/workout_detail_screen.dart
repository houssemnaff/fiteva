import 'package:flutter/material.dart';
import '../../models/workout_model.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'active_workout_screen.dart';
import '../../theme/app_theme.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final WorkoutModel workout;
  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  int _currentTab = 0; // 0: À propos, 1: Les séances
  int _selectedWeek = 0; // For week selector (Sem 1, Sem 2, etc.)

  Widget _buildGoalTag(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppTheme.textPrimaryColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String title) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: AppTheme.primaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textPrimaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workout = widget.workout;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── HEADER (SliverAppBar) ──
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                backgroundColor: AppTheme.primaryColor,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_back, color: AppTheme.primaryColor, size: 20),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.more_vert, color: AppTheme.primaryColor, size: 20),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Hero image
                      Image.asset(
                        workout.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade800),
                      ),
                      // Overlay gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                            stops: const [0.4, 1.0],
                          ),
                        ),
                      ),
                      // Text content over image (bottom)
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workout.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Tags row
                            Row(
                              children: [
                                _buildHeaderTag('Tonification'),
                                _buildHeaderTag('Cardio'),
                                _buildHeaderTag('Minceur'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── TAB BAR ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _currentTab = 0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _currentTab == 0 ? AppTheme.accentColor.withOpacity(0.3) : Colors.transparent,
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Text(
                                'À propos',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _currentTab == 0 ? AppTheme.primaryColor : Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _currentTab = 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _currentTab == 1 ? AppTheme.accentColor.withOpacity(0.3) : Colors.transparent,
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Text(
                                'Les séances',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _currentTab == 1 ? AppTheme.primaryColor : Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── TAB CONTENT ──
              if (_currentTab == 0)
                // TAB 1 — À propos
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats row
                        Row(
                          children: [
                            _buildStatCard(Icons.calendar_today_rounded, '4 semaines'),
                            _buildStatCard(Icons.bolt_rounded, workout.level),
                            _buildStatCard(Icons.schedule_rounded, '20-40 min\n/ séance'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Description text
                        Text(
                          'Ce programme complet de musculation et cardio vous aidera à sculpter votre corps et améliorer votre endurance globale. Mêlant des exercices variés pour éviter la monotonie, chaque séance est pensée pour des résultats optimaux.',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Coach card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 25,
                                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Coach Sarah',
                                    style: TextStyle(
                                      color: AppTheme.textPrimaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Expert Fitness & Nutrition',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Goals section
                        Text(
                          'Objectifs',
                          style: TextStyle(
                            color: AppTheme.textPrimaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          children: [
                            _buildGoalTag('Tonification'),
                            _buildGoalTag('Cardio'),
                            _buildGoalTag('Minceur'),
                            _buildGoalTag('Fessiers'),
                            _buildGoalTag('Ventre plat'),
                          ],
                        ),
                        const SizedBox(height: 100), // Padding for CTA
                      ],
                    ),
                  ),
                )
              else
                // TAB 2 — Les séances
                SliverList(
                  delegate: SliverChildListDelegate([
                    // Week selector
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(4, (index) {
                          final isSelected = _selectedWeek == index;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedWeek = index),
                            child: Container(
                              padding: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: isSelected ? Colors.black : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Sem ${index + 1}',
                                style: TextStyle(
                                  color: isSelected ? Colors.black : Colors.grey.shade500,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Session list
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: List.generate(workout.exercises.length, (index) {
                          // Mocking completed state for first item
                          final isDone = index == 0; 
                          
                          return GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => ActiveWorkoutScreen(workout: workout)),
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
                              ),
                              child: Row(
                                children: [
                                  // Checkbox circle
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: isDone ? AppTheme.primaryColor : Colors.transparent,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isDone ? AppTheme.primaryColor : Colors.grey.shade300,
                                        width: 2,
                                      ),
                                    ),
                                    child: isDone
                                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  
                                  // Thumbnail
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: Image.asset(
                                        workout.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(color: AppTheme.accentColor),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  
                                  // Center (Name, equip, duration)
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Séance ${index + 1}: ${workout.exercises[index]}',
                                          style: TextStyle(
                                            color: AppTheme.textPrimaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Tapis • Haltères',
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          index % 2 == 0 ? '25 min' : '40 min',
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Right chevron
                                  Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 24),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 100), // Padding for CTA
                  ]),
                ),
            ],
          ),

          // ── BOTTOM CTA ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppTheme.backgroundColor,
                    AppTheme.backgroundColor.withOpacity(0.0),
                  ],
                ),
              ),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
                child: const Text(
                  'Rejoindre le programme',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTag(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}