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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 6),
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
                Text(
                  'Journée en cours',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.secondary,
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
                      color: colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'i',
                      style: TextStyle(
                        fontSize: 9,
                        color: colorScheme.secondary,
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
                        backgroundColor: colorScheme.secondary,
                        foregroundColor: colorScheme.onSecondary,
                        disabledBackgroundColor: colorScheme.surfaceVariant,
                        disabledForegroundColor: colorScheme.onSurface.withOpacity(0.6),
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
        final colorScheme = Theme.of(context).colorScheme;

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
              decoration: BoxDecoration(
                color: colorScheme.secondary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_walk_rounded,
                color: colorScheme.secondary,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            // Step count + label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Aujourd'hui",
                    style: TextStyle(
                      fontSize: 12.5,
                      color: colorScheme.secondary,
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
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '/ 10 000',
                        style: TextStyle(
                          fontSize: 15,
                          color: colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'pas',
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.secondary,
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
            backgroundColor: colorScheme.secondaryContainer,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
            minHeight: 7,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "${(_progress * 100).toStringAsFixed(0)}% de l'objectif atteint",
          style: TextStyle(
            fontSize: 11.5,
            color: colorScheme.secondary,
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
    final colorScheme = Theme.of(context).colorScheme;


    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.secondary,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: colorScheme.secondary.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.directions_walk_rounded,
            color: colorScheme.secondary,
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
         Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Aujourd'hui",
                style: TextStyle(fontSize: 12.5, color: colorScheme.secondary),
              ),
              SizedBox(height: 4),
              Text(
                'Chargement...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
        final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.warning_outlined,
            color: colorScheme.error,
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
         Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Erreur',
                style: TextStyle(fontSize: 12, color: colorScheme.error),
              ),
              SizedBox(height: 4),
              Text(
                'Capteur non disponible',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onErrorContainer.withOpacity(0.9),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Vérifiez les permissions',
                style: TextStyle(fontSize: 11, color: colorScheme.onErrorContainer.withOpacity(0.9)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}