import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ExercisePlayerScreen extends StatefulWidget {
  final String workoutTitle;
  final String exerciseName;
  final int exerciseIndex;
  final int totalExercises;
  final VoidCallback onCompleted;

  const ExercisePlayerScreen({
    super.key,
    required this.workoutTitle,
    required this.exerciseName,
    required this.exerciseIndex,
    required this.totalExercises,
    required this.onCompleted,
  });

  @override
  State<ExercisePlayerScreen> createState() => _ExercisePlayerScreenState();
}

class _ExercisePlayerScreenState extends State<ExercisePlayerScreen> with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  bool _isDone = false;
  double _buttonScale = 1.0;
  
  void _markAsDone() async {
    if (_isDone) return;
    
    // Scale down bounce
    setState(() => _buttonScale = 0.95);
    await Future.delayed(const Duration(milliseconds: 150));
    
    // Mark done, color transition, scale back up
    setState(() {
      _isDone = true;
      _buttonScale = 1.0;
    });
    
    widget.onCompleted();

    // Auto navigate back after showing success state
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildPill(String text, {Color? bgColor}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor ?? AppTheme.accentColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppTheme.textPrimaryColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.arrow_back, color: AppTheme.primaryColor, size: 20),
            ),
          ),
        ),
        title: Text(
          widget.exerciseName,
          style: TextStyle(color: AppTheme.textPrimaryColor, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${widget.exerciseIndex + 1} / ${widget.totalExercises}',
                style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // VIDEO PLAYER (16:9 ratio)
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      color: const Color(0xFF1A1A1A),
                      child: Stack(
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: () => setState(() => _isPlaying = !_isPlaying),
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                                child: Icon(
                                  _isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: const Color(0xFF1A1A1A),
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                          const Positioned(
                            top: 16,
                            right: 16,
                            child: Icon(Icons.volume_up, color: Colors.white70, size: 24),
                          ),
                          Positioned(
                            bottom: 12,
                            left: 16,
                            right: 16,
                            child: Row(
                              children: [
                                const Text('0:23', style: TextStyle(color: Colors.white, fontSize: 12)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: 0.2, // Mock progress
                                    backgroundColor: Colors.white30,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('1:45', style: TextStyle(color: Colors.white, fontSize: 12)),
                                const SizedBox(width: 12),
                                const Icon(Icons.fullscreen, color: Colors.white, size: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // EXERCISE INFO CARD
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.exerciseName,
                                style: TextStyle(color: AppTheme.textPrimaryColor, fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _buildPill('Fessiers'),
                                  _buildPill('Tapis', bgColor: Colors.grey.shade200),
                                  _buildPill('🔥🔥 Modéré', bgColor: Colors.orange.withOpacity(0.1)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Text('3', style: TextStyle(color: AppTheme.textPrimaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text('séries', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                    ],
                                  ),
                                  Container(height: 20, width: 1, color: Colors.grey.shade300),
                                  Column(
                                    children: [
                                      Text('45 sec', style: TextStyle(color: AppTheme.textPrimaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text('travail', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                    ],
                                  ),
                                  Container(height: 20, width: 1, color: Colors.grey.shade300),
                                  Column(
                                    children: [
                                      Text('15 sec', style: TextStyle(color: AppTheme.textPrimaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text('repos', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Debout, pieds écartés largeur épaules. Descends en pliant les genoux à 90° en gardant le dos bien droit et la poitrine sortie. Pousse sur tes talons pour remonter.',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // TIPS SECTION
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.accentColor.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.lightbulb_outline, size: 18, color: AppTheme.primaryColor),
                                  const SizedBox(width: 8),
                                  Text('Conseils de forme', style: TextStyle(color: AppTheme.textPrimaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ', style: TextStyle(color: Colors.grey)),
                                  Expanded(child: Text('Garde les genoux alignés avec tes orteils.', style: TextStyle(color: Colors.grey.shade600, fontSize: 13))),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ', style: TextStyle(color: Colors.grey)),
                                  Expanded(child: Text('Engage ta sangle abdominale pendant tout le mouvement.', style: TextStyle(color: Colors.grey.shade600, fontSize: 13))),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // NAVIGATION ROW
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text('← Précédent', style: TextStyle(color: AppTheme.primaryColor, fontSize: 13)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text('Suivant →', style: TextStyle(color: AppTheme.primaryColor, fontSize: 13)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // BOTTOM CTA
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, -4), blurRadius: 10)],
            ),
            child: SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: _markAsDone,
                child: AnimatedScale(
                  scale: _buttonScale,
                  duration: const Duration(milliseconds: 150),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _isDone ? Colors.green : AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Center(
                      child: Text(
                        _isDone ? 'Terminé ✓' : 'Marquer comme terminé',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
