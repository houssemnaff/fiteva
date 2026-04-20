import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/workout_model.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final WorkoutModel workout;
  const ActiveWorkoutScreen({super.key, required this.workout});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen>
    with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  int _currentIndex = 0;
  int _seconds = 0;
  Timer? _timer;
  late AnimationController _pulseController;

  Color _categoryColor(String label) {
    switch (label.toUpperCase()) {
     case 'MUSCULATION': return const Color.fromARGB(255, 115, 229, 216);
    case 'PILATES': return const Color(0xFFB39DDB);
    case 'HIIT': return const Color(0xFFFFCA28);
    case 'DANCE': return const Color(0xFFFF8DA1);
    case 'YOGA': return const Color(0xFF80CBC4);
    case 'RUNNING': return const Color(0xFF64B5F6);
    default: return const Color(0xFFB0BEC5);
    }
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _seconds++);
      });
    } else {
      _timer?.cancel();
    }
  }

  void _next() {
    if (_currentIndex < widget.workout.exercises.length - 1) {
      setState(() {
        _currentIndex++;
        _seconds = 0;
      });
    }
  }

  void _prev() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _seconds = 0;
      });
    }
  }

  String _formatTime(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  @override
  Widget build(BuildContext context) {
    final exercises = widget.workout.exercises;
    final catColor = _categoryColor(widget.workout.category);
    final current = exercises[_currentIndex];
    final remaining = exercises.skip(_currentIndex + 1).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Column(
       
          children: [
            // ── Hero image with overlay ──────────────────────────
            Stack(
            children: [
              SizedBox(
                height: 280,
                width: double.infinity,
                child: Image.network(
                  widget.workout.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.grey[800]),
                ),
              ),

              // shadow sur le image !!!!!!
              Container(
                height: 280,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black38, Colors.black87],
                  ),
                ),
              ),
              // Play video icon centered
          
              // Back button
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                  ),
                ),
              ),


              // icon  start
              
              
            Positioned.fill(
  child: Align(
    alignment: Alignment.center,
    child: Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.play_arrow_rounded,
        color: Colors.black87,
        size: 36,
      ),
    ),
  ),
),
            ],
          ),


          // ── White sheet ──────────────────────────────────────
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF2F2F2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  // Timer + controls
              

                  const SizedBox(height: 16),

                  // Next exercises list
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Text(
                          'Exercices suivants',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1A2E1A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${remaining.length} restants)',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  Expanded(
                    child: remaining.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.trophy,
                                    size: 48, color: catColor),
                                const SizedBox(height: 12),
                                const Text(
                                  'Workout terminé ! 🎉',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16),
                            itemCount: remaining.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin:
                                    const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.grey[100],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${_currentIndex + index + 2}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontWeight:
                                                FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            remaining[index],
                                            style: const TextStyle(
                                              fontWeight:
                                                  FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '3 séries × 12 reps',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '45s',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
     
    );
  }

}