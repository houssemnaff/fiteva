import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import '../services/step_service.dart';

class MesPasCard extends StatefulWidget {
  const MesPasCard({super.key});

  @override
  State<MesPasCard> createState() => _MesPasCardState();
}

class _MesPasCardState extends State<MesPasCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late StepService _stepService;
  StreamSubscription<StepCount>? _stepSubscription;

  int _stepsToday = 0;
  final int _goalSteps = 10000;
  bool _isSyncing = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _initializeStepService();
  }

  Future<void> _initializeStepService() async {
    try {
      debugPrint('[Steps] Initializing step service...');
      _stepService = StepService();
      await _stepService.initialize();
      debugPrint('[Steps] Step service initialized successfully.');

      _stepSubscription = _stepService.getStepStream().listen(
        (StepCount stepCount) {
          debugPrint('[Steps] Stream event received: total=${stepCount.steps}');
          if (mounted) {
            setState(() {
              _stepService.onStepEvent(stepCount);
              _stepsToday = _stepService.getStepsToday();
              debugPrint('[Steps] Today=$_stepsToday');
              _isLoading = false;
            });
          }
        },
        onError: (e) {
          debugPrint('[Steps] Stream error: $e');
          if (mounted) {
            setState(() {
              _errorMessage = 'Erreur: Capteur non disponible';
              _isLoading = false;
            });
          }
        },
      );
    } catch (e) {
      debugPrint('[Steps] Initialization error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur d\'initialisation';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _stepSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSync() async {
    if (_isSyncing) return;
    setState(() {
      _isSyncing = true;
      _errorMessage = null;
    });
    try {
      await Future.delayed(const Duration(milliseconds: 950));
    } catch (e) {
      setState(() => _errorMessage = 'Erreur de synchronisation');
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  double get _progress => (_stepsToday / _goalSteps).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0EDE6), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: icon + step count
            if (_isLoading)
              _buildLoadingState()
            else if (_errorMessage != null)
              _buildErrorState(_errorMessage!)
            else
              _buildStepsDisplay(),

            const SizedBox(height: 16),

            // Mini stats row
            if (!_isLoading && _errorMessage == null) _buildMiniStats(),

            const SizedBox(height: 16),

            // Bottom row: label + sync button
            Row(
              children: [
                const Text(
                  'Journée en cours',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B9E7A),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 17,
                  height: 17,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFA8C9B5),
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'i',
                      style: TextStyle(
                        fontSize: 9,
                        color: Color(0xFF6B9E7A),
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: _isSyncing ? null : _handleSync,
                    icon: _isSyncing
                        ? const SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.sync_rounded, size: 16),
                    label: Text(
                      _isSyncing ? '...' : 'Synchroniser',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1C4D30),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFD6EAE0),
                      disabledForegroundColor: const Color(0xFF6B9E7A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 0,
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Walking icon circle
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFFEEF7F2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_walk_rounded,
                color: Color(0xFF1C4D30),
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            // Step count + label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Aujourd'hui",
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF7BAF8A),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        StepService.formatNumber(_stepsToday),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '/ 10 000',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFFB0C8BA),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'pas',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7BAF8A),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _progress,
            backgroundColor: const Color(0xFFE8F4EE),
            valueColor:
                const AlwaysStoppedAnimation<Color>(Color(0xFF1C4D30)),
            minHeight: 7,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "${(_progress * 100).toStringAsFixed(0)}% de l'objectif atteint",
          style: const TextStyle(
            fontSize: 11.5,
            color: Color(0xFF7BAF8A),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStats() {
    final double distanceKm = _stepsToday * 0.0007;
    final int calories = (_stepsToday * 0.042).round();
    final int minutes = (_stepsToday * 0.0097).round();

    return Row(
      children: [
        _buildStatChip(
          label: 'Distance',
          value: '${distanceKm.toStringAsFixed(1)} km',
        ),
        const SizedBox(width: 10),
        _buildStatChip(
          label: 'Calories',
          value: '$calories kcal',
        ),
        const SizedBox(width: 10),
        _buildStatChip(
          label: 'Durée',
          value: '${minutes ~/ 60}h ${minutes % 60}m',
        ),
      ],
    );
  }

  Widget _buildStatChip({required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFDDEDE4), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF7BAF8A),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            color: Color(0xFFEEF7F2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.directions_walk_rounded,
            color: Color(0xFF1C4D30),
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Aujourd'hui",
                style: TextStyle(fontSize: 12.5, color: Color(0xFF7BAF8A)),
              ),
              SizedBox(height: 4),
              Text(
                'Chargement...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7BAF8A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            color: Color(0xFFFFEEEE),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.warning_outlined,
            color: Color(0xFFE05C5C),
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Erreur',
                style: TextStyle(fontSize: 12, color: Color(0xFFE05C5C)),
              ),
              SizedBox(height: 4),
              Text(
                'Capteur non disponible',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9E8A7A),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Vérifiez les permissions',
                style: TextStyle(fontSize: 11, color: Color(0xFF9E8A7A)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}