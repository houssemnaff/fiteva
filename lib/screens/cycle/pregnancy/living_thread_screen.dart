  import 'dart:math' as math;
  import 'package:fiteva/screens/cycle/pregnancy/heartbeat_pulse.dart';
  import 'package:fiteva/screens/cycle/pregnancy/pregnancy_week.dart';
  import 'package:fiteva/screens/cycle/pregnancy/theme.dart';
  import 'package:fiteva/screens/cycle/pregnancy/thread_painter.dart';
  import 'package:fiteva/screens/cycle/pregnancy/week_detail_card.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';

  /// The Living Thread — main pregnancy tracker screen.
  ///
  /// The full 40-week thread is displayed in a scrollable canvas.
  /// Week 1 (conception) sits at the bottom; week 40 (birth) at the top.
  /// The current week glows as a luminous knot.
  class LivingThreadScreen extends StatefulWidget {
    const LivingThreadScreen({super.key});

    @override
    State<LivingThreadScreen> createState() => _LivingThreadScreenState();
  }

  class _LivingThreadScreenState extends State<LivingThreadScreen>
      with TickerProviderStateMixin {
    // ── State ─────────────────────────────────────────────────────────────
    int _currentWeek = 24;
    int? _selectedWeek;        // week whose detail card is open
    bool _showingPulse = false;
    Offset _pulsePosition = Offset.zero;

    // ── Animation ─────────────────────────────────────────────────────────
    late AnimationController _breathController;
    late Animation<double> _breathPhase;

    // ── Scroll ────────────────────────────────────────────────────────────
    final ScrollController _scrollController = ScrollController();

    // ── Canvas key (for hit testing) ──────────────────────────────────────
    final GlobalKey _canvasKey = GlobalKey();

    // ── Canvas metrics ────────────────────────────────────────────────────
    // Each week segment is 22px pitch; total height for 40 weeks + margins
    static const double _canvasHeight = 40 * 22.0 + 120;

    @override
    void initState() {
      super.initState();
      _breathController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 4),
      )..repeat();
      _breathPhase = Tween(begin: 0.0, end: math.pi * 2).animate(_breathController);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentWeek());
    }

    @override
    void dispose() {
      _breathController.dispose();
      _scrollController.dispose();
      super.dispose();
    }

    // ── Scroll to bring current week into comfortable view ─────────────────
    void _scrollToCurrentWeek() {
      final canvasSize = Size(double.infinity, _canvasHeight);
      final painter = ThreadPainter(
        currentWeek: _currentWeek,
        breathPhase: 0,
        scrollOffset: 0,
      );
      final knotY = painter.weekY(_currentWeek, canvasSize);
      final screenH = MediaQuery.of(context).size.height;
      final targetOffset = (knotY - screenH * 0.45).clamp(0.0, _canvasHeight);
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
      );
    }

    // ── Handle tap on canvas ───────────────────────────────────────────────
    void _handleTap(TapDownDetails details) {
      final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
      if (box == null) return;
      final local = box.globalToLocal(details.globalPosition);
      final painter = ThreadPainter(
        currentWeek: _currentWeek,
        breathPhase: _breathPhase.value,
        scrollOffset: 0,
      );
      final week = painter.hitTestWeek(local, box.size);
      if (week != null) {
        HapticFeedback.lightImpact();
        setState(() => _selectedWeek = week == _selectedWeek ? null : week);
      } else {
        setState(() => _selectedWeek = null);
      }
    }

    // ── Handle long press — heartbeat pulse on current week ────────────────
    void _handleLongPress(LongPressStartDetails details) {
      final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
      if (box == null) return;
      final local = box.globalToLocal(details.globalPosition);
      final painter = ThreadPainter(
        currentWeek: _currentWeek,
        breathPhase: _breathPhase.value,
        scrollOffset: 0,
      );
      final week = painter.hitTestWeek(local, box.size);
      if (week == _currentWeek) {
        HapticFeedback.mediumImpact();
        setState(() {
          _showingPulse = true;
          _pulsePosition = local;
        });
      }
    }

    void _onSetCurrentWeek(int week) {
      setState(() {
        _currentWeek = week;
        _selectedWeek = null;
      });
      _scrollToCurrentWeek();
      HapticFeedback.selectionClick();
    }

    @override
    Widget build(BuildContext context) {
      final selectedData = _selectedWeek != null
          ? PregnancyDataRepository.forWeek(_selectedWeek!)
          : null;
      final currentData = PregnancyDataRepository.forWeek(_currentWeek);
      final knotColor = ThreadTheme.threadColorForWeek(_currentWeek);

      return Scaffold(
        backgroundColor: ThreadTheme.bg,
        body: Stack(
          children: [
            // ── Background gradient ─────────────────────────────────────
            _BackgroundGradient(week: _currentWeek),

            // ── Main scrollable thread canvas ───────────────────────────
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: _ThreadHeader(
                    currentWeek: _currentWeek,
                    color: knotColor,
                    onWeekChanged: (w) => setState(() {
                      _currentWeek = w;
                      _scrollToCurrentWeek();
                    }),
                  ),
                ),

                // Thread canvas
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: _canvasHeight,
                    child: GestureDetector(
                      onTapDown: _handleTap,
                      onLongPressStart: _handleLongPress,
                      child: AnimatedBuilder(
                        animation: _breathPhase,
                        builder: (_, __) => CustomPaint(
                          key: _canvasKey,
                          painter: ThreadPainter(
                            currentWeek: _currentWeek,
                            breathPhase: _breathPhase.value,
                            scrollOffset: 0,
                          ),
                          child: _showingPulse
                              ? HeartbeatPulseOverlay(
                                  position: _pulsePosition,
                                  color: knotColor,
                                  bpm: currentData.fetalHeartRateBpm,
                                  onDone: () => setState(() => _showingPulse = false),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),

                // Trimester label rail
                SliverToBoxAdapter(
                  child: _TrimesterRail(currentWeek: _currentWeek),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),

            // ── Week detail card overlay ────────────────────────────────
            if (selectedData != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _DetailCardSheet(
                  data: selectedData,
                  isCurrentWeek: _selectedWeek == _currentWeek,
                  onSetCurrentWeek: () => _onSetCurrentWeek(_selectedWeek!),
                  onDismiss: () => setState(() => _selectedWeek = null),
                ),
              ),

            // ── Bottom progress strip ───────────────────────────────────
            Positioned(
              bottom: selectedData != null ? null : 0,
              left: 0,
              right: 0,
              child: selectedData != null
                  ? const SizedBox.shrink()
                  : _ProgressStrip(currentWeek: _currentWeek, color: knotColor),
            ),
          ],
        ),
      );
    }
  }

  // ── Background gradient widget ───────────────────────────────────────────────

  class _BackgroundGradient extends StatelessWidget {
    final int week;
    const _BackgroundGradient({required this.week});

    @override
    Widget build(BuildContext context) {
      final color = ThreadTheme.threadColorForWeek(week);
      return Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.3),
            radius: 1.2,
            colors: [
            
              Colors.white,
            ],
          ),
        ),
      );
    }
  }

  // ── Screen header ────────────────────────────────────────────────────────────

  class _ThreadHeader extends StatelessWidget {
    final int currentWeek;
    final Color color;
    final ValueChanged<int> onWeekChanged;

    const _ThreadHeader({
      required this.currentWeek,
      required this.color,
      required this.onWeekChanged,
    });

    @override
    Widget build(BuildContext context) {
      final data = PregnancyDataRepository.forWeek(currentWeek);
      final weeksLeft = 40 - currentWeek;
      return Padding(
        padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 16, 24, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'MY PREGNANCY',
                  style: TextStyle(
                    color: color.withOpacity(0.5),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.5,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _showWeekPicker(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withOpacity(0.3), width: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Week $currentWeek',
                          style: TextStyle(
                            color: color,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.expand_more, color: color, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: data.babySize,
                    style: TextStyle(
                      color: color,
                      fontSize: 26,
                      fontWeight: FontWeight.w300,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const TextSpan(
                    text: ' · ',
                    style: TextStyle(color: ThreadTheme.textTertiary, fontSize: 22),
                  ),
                  TextSpan(
                    text: weeksLeft > 0 ? '$weeksLeft weeks to go' : 'Due this week',
                    style: const TextStyle(
                      color: ThreadTheme.textSecondary,
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            _ProgressBar(currentWeek: currentWeek, color: color),
            const SizedBox(height: 12),
          ],
        ),
      );
    }

    void _showWeekPicker(BuildContext context) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        isScrollControlled: true,
        builder: (_) => _WeekPickerSheet(
          currentWeek: currentWeek,
          onSelected: onWeekChanged,
        ),
      );
    }
  }

  class _ProgressBar extends StatelessWidget {
    final int currentWeek;
    final Color color;
    const _ProgressBar({required this.currentWeek, required this.color});

    @override
    Widget build(BuildContext context) {
      return LayoutBuilder(
        builder: (_, constraints) => Stack(
          children: [
            Container(
              height: 2,
              width: constraints.maxWidth,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            Container(
              height: 2,
              width: constraints.maxWidth * (currentWeek / 40),
              decoration: BoxDecoration(
                color: color.withOpacity(0.6),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      );
    }
  }

  // ── Trimester label rail (decorative side labels) ───────────────────────────

  class _TrimesterRail extends StatelessWidget {
    final int currentWeek;
    const _TrimesterRail({required this.currentWeek});

    @override
    Widget build(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            _TrimLabel(
              label: 'Trimester 1',
              weeks: 'Wk 1–13',
              color: ThreadTheme.t1End,
              active: currentWeek <= 13,
            ),
            const SizedBox(width: 8),
            _TrimLabel(
              label: 'Trimester 2',
              weeks: 'Wk 14–27',
              color: ThreadTheme.t2End,
              active: currentWeek > 13 && currentWeek <= 27,
            ),
            const SizedBox(width: 8),
            _TrimLabel(
              label: 'Trimester 3',
              weeks: 'Wk 28–40',
              color: ThreadTheme.t3End,
              active: currentWeek > 27,
            ),
          ],
        ),
      );
    }
  }

  class _TrimLabel extends StatelessWidget {
    final String label;
    final String weeks;
    final Color color;
    final bool active;
    const _TrimLabel({required this.label, required this.weeks, required this.color, required this.active});

    @override
    Widget build(BuildContext context) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: active ? color.withOpacity(0.1) : const Color.fromARGB(0, 214, 15, 15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active ? color.withOpacity(0.3) : ThreadTheme.bgCardBorder,
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                style: TextStyle(
                  color: active ? color : ThreadTheme.textTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              Text(weeks,
                style: TextStyle(
                  color: active ? color.withOpacity(0.5) : ThreadTheme.textTertiary.withOpacity(0.5),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  // ── Detail card bottom sheet ─────────────────────────────────────────────────

  class _DetailCardSheet extends StatelessWidget {
    final PregnancyWeekData data;
    final bool isCurrentWeek;
    final VoidCallback onSetCurrentWeek;
    final VoidCallback onDismiss;

    const _DetailCardSheet({
      required this.data,
      required this.isCurrentWeek,
      required this.onSetCurrentWeek,
      required this.onDismiss,
    });

    @override
    Widget build(BuildContext context) {
      return GestureDetector(
        onTap: onDismiss,
        child: Container(
          color: const Color.fromARGB(0, 235, 2, 2),
          child: GestureDetector(
            onTap: () {},
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dismiss handle
                Center(
                  child: Container(
                    width: 36,
                    height: 3,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: ThreadTheme.textTertiary.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                WeekDetailCard(
                  data: data,
                  isCurrentWeek: isCurrentWeek,
                  onSelectAsCurrentWeek: isCurrentWeek ? null : onSetCurrentWeek,
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
              ],
            ),
          ),
        ),
      );
    }
  }

  // ── Bottom progress strip ────────────────────────────────────────────────────

  class _ProgressStrip extends StatelessWidget {
    final int currentWeek;
    final Color color;
    const _ProgressStrip({required this.currentWeek, required this.color});

    @override
    Widget build(BuildContext context) {
      final pct = (currentWeek / 40 * 100).round();
      return Container(
        padding: EdgeInsets.fromLTRB(
          24, 14, 24, MediaQuery.of(context).padding.bottom + 14),
        decoration: BoxDecoration(
          color: ThreadTheme.bgSurface,
          border: Border(top: BorderSide(color: ThreadTheme.bgCardBorder, width: 0.5)),
        ),
        child: Row(
          children: [
            Text(
              '$pct% complete',
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              '${40 - currentWeek} weeks remaining',
              style: const TextStyle(
                color: ThreadTheme.textTertiary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }
  }

  // ── Week picker sheet ────────────────────────────────────────────────────────

  class _WeekPickerSheet extends StatefulWidget {
    final int currentWeek;
    final ValueChanged<int> onSelected;
    const _WeekPickerSheet({required this.currentWeek, required this.onSelected});

    @override
    State<_WeekPickerSheet> createState() => _WeekPickerSheetState();
  }

  class _WeekPickerSheetState extends State<_WeekPickerSheet> {
    late int _selected;

    @override
    void initState() {
      super.initState();
      _selected = widget.currentWeek;
    }

    @override
    Widget build(BuildContext context) {
      return Container(
        decoration: const BoxDecoration(
          color: ThreadTheme.bgCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
          24, 12, 24, MediaQuery.of(context).padding.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36, height: 3,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: ThreadTheme.textTertiary.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'SELECT WEEK',
              style: TextStyle(
                color: ThreadTheme.textTertiary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: ListWheelScrollView.useDelegate(
                itemExtent: 44,
                perspective: 0.003,
                diameterRatio: 1.5,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (i) {
                  setState(() => _selected = i + 1);
                  HapticFeedback.selectionClick();
                },
                controller: FixedExtentScrollController(
                  initialItem: _selected - 1,
                ),
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: 40,
                  builder: (_, i) {
                    final w = i + 1;
                    final isActive = w == _selected;
                    final color = ThreadTheme.threadColorForWeek(w);
                    final data = PregnancyDataRepository.forWeek(w);
                    return AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 150),
                      style: TextStyle(
                        color: isActive ? color : ThreadTheme.textTertiary,
                        fontSize: isActive ? 18 : 14,
                        fontWeight: isActive ? FontWeight.w500 : FontWeight.w300,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Week $w'),
                          if (isActive) ...[
                            const SizedBox(width: 12),
                            Text(
                              '· ${data.babySize}',
                              style: TextStyle(
                                color: color.withOpacity(0.6),
                                fontSize: 13,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                widget.onSelected(_selected);
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: ThreadTheme.threadColorForWeek(_selected).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: ThreadTheme.threadColorForWeek(_selected).withOpacity(0.4),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  'Set Week $_selected',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ThreadTheme.threadColorForWeek(_selected),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }