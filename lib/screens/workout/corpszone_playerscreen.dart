import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../l10n/app_localizations.dart';
import '../../models/workout_model.dart';
import '../../services/points_service.dart';
import '../../theme/app_theme.dart';
import '../../providers/points_provider.dart';
import '../../core/shop/shop_provider.dart';

class CorpsZonePlayerScreen extends ConsumerStatefulWidget {
  final WorkoutModel workout;
  final String zoneName;

  const CorpsZonePlayerScreen({
    super.key,
    required this.workout,
    required this.zoneName,
  });

  @override
  ConsumerState<CorpsZonePlayerScreen> createState() => _CorpsZonePlayerScreenState();
}

class _CorpsZonePlayerScreenState extends ConsumerState<CorpsZonePlayerScreen>
    with WidgetsBindingObserver {
  late PageController _pageController;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  VideoPlayerController? _nextController;
  final Map<String, VideoPlayerController> _controllerCache = {};
  int _currentPage = 0;
  bool _isVideoReady = false;
  String _currentVideoPath = '';

  // 80 % watch → points
  final Set<int> _pointsAwardedForIndex = {};
  VideoPlayerController? _activeListenerCtrl;
  int _currentListenerIndex = 0;
  
  final List<String> _videoUrls = [
    'assets/videos/workout1.mp4',
    'assets/videos/workout2.mp4',
    'assets/videos/workout3.mp4',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController();
    _initializeVideo(0);
  }

  Future<void> _initializeVideo(int videoIndex) async {
    final videoUrl = _videoUrls[videoIndex % _videoUrls.length];

    // Do not recreate anything if it is already the current video.
    if (_currentVideoPath == videoUrl) {
      if (_chewieController != null) {
        _preloadNext(videoIndex);
      }
      return;
    }
    
    _currentVideoPath = videoUrl; // Track which video we are currently loading
    
    try {
      debugPrint('🎬 Loading video from: $videoUrl');
      
      // Stop ALL current sounds immediately before switching
      for (final controller in _controllerCache.values) {
        if (controller.value.isPlaying) {
          await controller.pause();
        }
      }
      
      setState(() {
        _isVideoReady = false; 
      });

      final videoPlayerController = await _getOrCreateController(videoUrl);
      
      debugPrint('✅ Video initialized: $videoUrl');

      if (mounted) {
        _chewieController?.dispose();
        _videoPlayerController = videoPlayerController;
        _chewieController = ChewieController(
          videoPlayerController: videoPlayerController,
          autoPlay: true,
          looping: false,
          showControls: true,
          showControlsOnInitialize: true,
          customControls: const MaterialControls(),
          allowFullScreen: true,
        );
        
        setState(() {
          _isVideoReady = true;
        });

        // Attach 80 % listener for this exercise index
        _activeListenerCtrl?.removeListener(_videoListener);
        _currentListenerIndex = videoIndex;
        _activeListenerCtrl = videoPlayerController;
        _activeListenerCtrl!.addListener(_videoListener);

        _preloadNext(videoIndex);
        
        debugPrint('🎮 Chewie controller ready');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Video error: $e\n$stackTrace');
      if (mounted) {
        setState(() {
          _isVideoReady = false;
        });
      }
    }
  }

  Future<void> _goToNextExercise(int exercisesCount) async {
    if (_currentPage >= exercisesCount - 1) {
      if (mounted) {
        Navigator.pop(context);
      }
      return;
    }

    final nextIndex = _currentPage + 1;

    // Start page animation immediately for responsiveness.
    // onPageChanged will trigger _initializeVideo(nextIndex).
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<VideoPlayerController> _getOrCreateController(String url) async {
    final cached = _controllerCache[url];
    if (cached != null) {
      return cached;
    }

    final controller = VideoPlayerController.asset(url);
    await controller.initialize();
    _controllerCache[url] = controller;
    return controller;
  }

  Future<void> _preloadNext(int index) async {
    final nextUrl = _videoUrls[(index + 1) % _videoUrls.length];

    // Keep controller alive in cache and do not recreate it.
    if (_controllerCache.containsKey(nextUrl)) {
      _nextController = _controllerCache[nextUrl];
      return;
    }

    try {
      _nextController = VideoPlayerController.asset(nextUrl);
      await _nextController!.initialize();
      _controllerCache[nextUrl] = _nextController!;
      debugPrint('⏭️ Preloaded next video: $nextUrl');
    } catch (e) {
      debugPrint('❌ Error preloading next video: $e');
    }
  }

  Future<void> _cleanupVideo() async {
    try {
      if (_chewieController != null) {
        _chewieController?.dispose();
        _chewieController = null;
      }
      _videoPlayerController = null;
    } catch (e) {
      debugPrint('Error cleaning up video: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _videoPlayerController?.pause();
    } else if (state == AppLifecycleState.resumed) {
      if (_isVideoReady) {
        _videoPlayerController?.play();
      }
    }
  }

  void _videoListener() {
    final ctrl = _activeListenerCtrl;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    final dur = ctrl.value.duration.inMilliseconds;
    final pos = ctrl.value.position.inMilliseconds;
    if (dur <= 0) return;
    if (pos / dur >= 0.80 && !_pointsAwardedForIndex.contains(_currentListenerIndex)) {
      _pointsAwardedForIndex.add(_currentListenerIndex);
      PointsService.addPoints(PointsService.pointsPerVideo).then((total) {
        if (!mounted) return;
        ref.read(pointsProvider.notifier).loadPoints();
        ref.read(shopProvider.notifier).refresh();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ref.read(l10nProvider).corpszonePoints(PointsService.pointsPerVideo, total)),
              duration: const Duration(seconds: 2),
              backgroundColor: const Color(0xFF1C4D30),
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _activeListenerCtrl?.removeListener(_videoListener);
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _chewieController?.dispose();
    final uniqueControllers = _controllerCache.values.toSet();
    for (final controller in uniqueControllers) {
      controller.dispose();
    }
    _controllerCache.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = widget.workout.exercises;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Single video player for the current page
          Positioned.fill(
            child: _isVideoReady && _chewieController != null
                ? Chewie(
                    controller: _chewieController!,
                  )
                : Container(
                    color: Colors.black,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading video...',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // 2. Horizontal swipe area to switch videos
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              final videoUrl = _videoUrls[index % _videoUrls.length];
              if (_currentVideoPath != videoUrl) {
                _initializeVideo(index);
              } else {
                _preloadNext(index);
              }
            },
            itemCount: exercises.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return const SizedBox.expand(
                child: ColoredBox(color: Colors.transparent),
              );
            },
          ),

          // 3. Top Controls & Progress
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  // Progress Bars (like Instagram/TikTok)
                  Row(
                    children: List.generate(exercises.length, (index) {
                      return Expanded(
                        child: Container(
                          height: 3,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: index <= _currentPage
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.x, color: Colors.white, size: 20),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.zoneName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 36), // Balanced placeholder
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 4. Bottom Details Area
          Positioned(
            left: 20,
            right: 20,
            bottom: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'EXERCICE ${_currentPage + 1}/${exercises.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  exercises[_currentPage],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Concentrez-vous sur la respiration et gardez le dos droit. Maintenez chaque mouvement.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                // Actions (Next button if needed, but swipe works)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await _goToNextExercise(exercises.length);
                        },
                        icon: Icon(
                          _currentPage < exercises.length - 1
                              ? LucideIcons.chevronRight
                              : LucideIcons.check,
                          size: 18,
                        ),
                        label: Text(
                          _currentPage < exercises.length - 1
                              ? 'Suivant'
                              : 'Terminer',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
