import 'package:flutter/material.dart';
import '../../models/workout_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'active_workout_screen.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final WorkoutModel workout;
  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  int _currentTab = 0; // 0: À propos, 1: Les séances
  int _selectedWeek = 0; // For week selector (Sem 1, Sem 2, etc.)

  Widget _buildGoalTag(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, IconData icon, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface,
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
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final textSecondary = theme.textTheme.bodyMedium?.color ?? colorScheme.onSurface.withOpacity(0.72);

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── HEADER (SliverAppBar) ──
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                backgroundColor: colorScheme.primary,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_back, color: colorScheme.primary, size: 20),
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
                        decoration: BoxDecoration(
                          color: colorScheme.onPrimary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.more_vert, color: colorScheme.primary, size: 20),
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
                        errorBuilder: (_, __, ___) => Container(color: colorScheme.surfaceContainerHighest),
                      ),
                      // Overlay gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, colorScheme.onSurface.withOpacity(0.8)],
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
                              style: TextStyle(
                                color: colorScheme.onPrimary,
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
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                
                /*    decoration: BoxDecoration(
  color: colorScheme.surface.withOpacity(0.95), // light grey effect
  borderRadius: BorderRadius.circular(16),
  border: Border.all(
    color: Colors.grey.withOpacity(0.15),
  ),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ],
),*/
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _currentTab = 0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _currentTab == 0 ? colorScheme.primaryContainer : Colors.transparent,
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Text(
                                'À propos',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _currentTab == 0 ? colorScheme.onPrimaryContainer : textSecondary,
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
                                color: _currentTab == 1 ? colorScheme.primaryContainer : Colors.transparent,
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Text(
                                'Les séances',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _currentTab == 1 ? colorScheme.onPrimaryContainer : textSecondary,
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
                              _buildStatCard(context, Icons.calendar_today_rounded, '4 semaines'),
                              _buildStatCard(context, Icons.bolt_rounded, workout.level),
                              _buildStatCard(context, Icons.schedule_rounded, '20-40 min\n/ séance'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Description text
                        Text(
                          'Ce programme complet de musculation et cardio vous aidera à sculpter votre corps et améliorer votre endurance globale. Mêlant des exercices variés pour éviter la monotonie, chaque séance est pensée pour des résultats optimaux.',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Coach card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.shadow.withOpacity(0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
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
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Expert Fitness & Nutrition',
                                    style: TextStyle(
                                      color: textSecondary,
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
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          children: [
                            _buildGoalTag(context, 'Tonification'),
                            _buildGoalTag(context, 'Cardio'),
                            _buildGoalTag(context, 'Minceur'),
                            _buildGoalTag(context, 'Fessiers'),
                            _buildGoalTag(context, 'Ventre plat'),
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
                                    color: isSelected ? colorScheme.primary : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Sem ${index + 1}',
                                style: TextStyle(
                                  color: isSelected ? colorScheme.onSurface : textSecondary,
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
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.shadow.withOpacity(0.06),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Checkbox circle
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: isDone ? colorScheme.primary : Colors.transparent,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: isDone
                                              ? colorScheme.primary.withOpacity(0.18)
                                              : colorScheme.shadow.withOpacity(0.05),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: isDone
                                        ? Icon(Icons.check, color: colorScheme.onPrimary, size: 16)
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
                                        errorBuilder: (_, __, ___) => Container(color: colorScheme.surfaceContainerHighest),
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
                                            color: colorScheme.onSurface,
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
                                            color: textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          index % 2 == 0 ? '25 min' : '40 min',
                                          style: TextStyle(
                                            color: textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Right chevron
                                  Icon(Icons.chevron_right, color: colorScheme.outlineVariant, size: 24),
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
                    colorScheme.background,
                    colorScheme.background.withOpacity(0.0),
                  ],
                ),
              ),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withOpacity(0.35),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colorScheme.onPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}