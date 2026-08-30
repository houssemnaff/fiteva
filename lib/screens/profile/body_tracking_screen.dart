// ignore_for_file: deprecated_member_use
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../providers/body_tracking_provider.dart';
import '../../providers/theme_provider.dart';

// ── Theme tokens ────────────────────────────────────────────────────────────

class _P {
  _P._();
  static const accent  = Color(0xFF1B5E3B);
  static const bgL     = Color(0xFFF7F8F6);
  static const cardL   = Colors.white;
  static const borderL = Color(0xFFE8ECE9);
  static const t1L     = Color(0xFF1A1A1A);
  static const t2L     = Color(0xFF6B7B73);
  static const bgD     = Color(0xFF0F1A14);
  static const cardD   = Color(0xFF162119);
  static const borderD = Color(0xFF253D2E);
  static const t1D     = Color(0xFFF0F0EE);
  static const t2D     = Color(0xFF8A9B92);
  static Color bg(bool d)     => d ? bgD : bgL;
  static Color card(bool d)   => d ? cardD : cardL;
  static Color border(bool d) => d ? borderD : borderL;
  static Color t1(bool d)     => d ? t1D : t1L;
  static Color t2(bool d)     => d ? t2D : t2L;
}

// ══════════════════════════════════════════════════════════════════════════════
// SCREEN
// ══════════════════════════════════════════════════════════════════════════════

class BodyTrackingScreen extends ConsumerStatefulWidget {
  const BodyTrackingScreen({super.key});

  @override
  ConsumerState<BodyTrackingScreen> createState() => _BodyTrackingScreenState();
}

class _BodyTrackingScreenState extends ConsumerState<BodyTrackingScreen> {
  final _picker = ImagePicker();

  // Measurement controllers
  final _waistCtrl  = TextEditingController();
  final _hipsCtrl   = TextEditingController();
  final _chestCtrl  = TextEditingController();
  final _thighsCtrl = TextEditingController();
  final _armsCtrl   = TextEditingController();
  final _bfCtrl     = TextEditingController();

  @override
  void dispose() {
    _waistCtrl.dispose();
    _hipsCtrl.dispose();
    _chestCtrl.dispose();
    _thighsCtrl.dispose();
    _armsCtrl.dispose();
    _bfCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final st = ref.watch(bodyTrackingProvider);

    return Scaffold(
      backgroundColor: _P.bg(dark),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ────────────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader(dark)),

            // ── Weight section ────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildWeightSection(dark, st)),

            // ── Body fat section ──────────────────────────────────────────
            SliverToBoxAdapter(child: _buildBodyFatSection(dark, st)),

            // ── Measurements section ──────────────────────────────────────
            SliverToBoxAdapter(child: _buildMeasurementsSection(dark, st)),

            // ── Progress photos ───────────────────────────────────────────
            SliverToBoxAdapter(child: _buildPhotosSection(dark)),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(bool dark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(LucideIcons.arrowLeft, color: _P.t1(dark)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              'Mon Corps',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _P.t1(dark),
              ),
            ),
          ),
          const SizedBox(width: 48), // balance the back arrow
        ],
      ),
    );
  }

  // ── Weight Section ────────────────────────────────────────────────────────

  Widget _buildWeightSection(bool dark, BodyTrackingState st) {
    final current = st.latest?.weightKg ?? 0.0;
    final history = st.lastNDays(14);
    final weightPoints = history
        .where((e) => e.weightKg != null)
        .map((e) => _ChartPoint(e.date, e.weightKg!))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return _card(dark, child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(dark, LucideIcons.scale, 'Poids'),
        const SizedBox(height: 16),
        // Big number + adjustment
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _pillButton(dark, LucideIcons.minus, () {
              HapticFeedback.lightImpact();
              final nw = math.max(30.0, current - 0.1);
              ref.read(bodyTrackingProvider.notifier).updateWeight(
                  double.parse(nw.toStringAsFixed(1)));
            }),
            const SizedBox(width: 20),
            Column(
              children: [
                Text(
                  current.toStringAsFixed(1),
                  style: GoogleFonts.outfit(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: _P.accent,
                  ),
                ),
                Text('kg', style: GoogleFonts.inter(
                  fontSize: 14, color: _P.t2(dark),
                )),
              ],
            ),
            const SizedBox(width: 20),
            _pillButton(dark, LucideIcons.plus, () {
              HapticFeedback.lightImpact();
              final nw = current + 0.1;
              ref.read(bodyTrackingProvider.notifier).updateWeight(
                  double.parse(nw.toStringAsFixed(1)));
            }),
          ],
        ),
        const SizedBox(height: 20),
        // Chart
        if (weightPoints.length >= 2) ...[
          Text('14 derniers jours',
              style: GoogleFonts.inter(fontSize: 12, color: _P.t2(dark))),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: CustomPaint(
              size: Size.infinite,
              painter: _LineChartPainter(
                points: weightPoints,
                lineColor: _P.accent,
                fillColor: _P.accent.withOpacity(0.10),
                gridColor: _P.border(dark),
                labelColor: _P.t2(dark),
                suffix: 'kg',
              ),
            ),
          ),
        ] else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Enregistre ton poids plusieurs jours pour voir la courbe.',
              style: GoogleFonts.inter(fontSize: 13, color: _P.t2(dark)),
            ),
          ),
      ],
    ));
  }

  // ── Body Fat Section ──────────────────────────────────────────────────────

  Widget _buildBodyFatSection(bool dark, BodyTrackingState st) {
    final current = st.latest?.bodyFatPct;
    final history = st.lastNDays(14);
    final bfPoints = history
        .where((e) => e.bodyFatPct != null)
        .map((e) => _ChartPoint(e.date, e.bodyFatPct!))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return _card(dark, child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(dark, LucideIcons.percent, 'Masse grasse'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _bfCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: GoogleFonts.inter(fontSize: 16, color: _P.t1(dark)),
                decoration: _inputDeco(dark, 'Ex: 22.5', '%'),
              ),
            ),
            const SizedBox(width: 12),
            _saveButton(dark, () {
              final v = double.tryParse(_bfCtrl.text.replaceAll(',', '.'));
              if (v == null || v < 3 || v > 60) return;
              ref.read(bodyTrackingProvider.notifier).updateBodyFat(v);
              _bfCtrl.clear();
              FocusScope.of(context).unfocus();
            }),
          ],
        ),
        if (current != null) ...[
          const SizedBox(height: 8),
          Text('Actuel : ${current.toStringAsFixed(1)} %',
              style: GoogleFonts.inter(fontSize: 13, color: _P.t2(dark))),
        ],
        if (bfPoints.length >= 2) ...[
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: CustomPaint(
              size: Size.infinite,
              painter: _LineChartPainter(
                points: bfPoints,
                lineColor: const Color(0xFF6C63FF),
                fillColor: const Color(0xFF6C63FF).withOpacity(0.10),
                gridColor: _P.border(dark),
                labelColor: _P.t2(dark),
                suffix: '%',
              ),
            ),
          ),
        ],
      ],
    ));
  }

  // ── Measurements Section ──────────────────────────────────────────────────

  Widget _buildMeasurementsSection(bool dark, BodyTrackingState st) {
    final latest = st.latest;

    final fields = <_MeasField>[
      _MeasField('Tour de taille', _waistCtrl, latest?.waistCm, LucideIcons.moveHorizontal),
      _MeasField('Hanches', _hipsCtrl, latest?.hipsCm, LucideIcons.circleDot),
      _MeasField('Poitrine', _chestCtrl, latest?.chestCm, LucideIcons.heart),
      _MeasField('Cuisses', _thighsCtrl, latest?.thighsCm, LucideIcons.arrowDownUp),
      _MeasField('Bras', _armsCtrl, latest?.armsCm, LucideIcons.dumbbell),
    ];

    return _card(dark, child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(dark, LucideIcons.ruler, 'Mensurations (cm)'),
        const SizedBox(height: 12),
        ...fields.map((f) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Icon(f.icon, size: 16, color: _P.t2(dark)),
              const SizedBox(width: 8),
              SizedBox(
                width: 100,
                child: Text(f.label,
                    style: GoogleFonts.inter(fontSize: 13, color: _P.t1(dark))),
              ),
              if (f.lastValue != null) ...[
                Text(f.lastValue!.toStringAsFixed(1),
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: _P.t2(dark),
                        fontWeight: FontWeight.w500)),
                const SizedBox(width: 6),
                Icon(LucideIcons.arrowRight, size: 12, color: _P.t2(dark)),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: TextField(
                    controller: f.ctrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: GoogleFonts.inter(fontSize: 14, color: _P.t1(dark)),
                    decoration: _inputDeco(dark, '—', 'cm'),
                  ),
                ),
              ),
            ],
          ),
        )),
        const SizedBox(height: 8),
        Center(
          child: _saveButton(dark, _saveMeasurements, wide: true),
        ),
      ],
    ));
  }

  void _saveMeasurements() {
    double? p(TextEditingController c) {
      final v = double.tryParse(c.text.replaceAll(',', '.'));
      if (v != null && v > 0 && v < 300) return v;
      return null;
    }

    final waist  = p(_waistCtrl);
    final hips   = p(_hipsCtrl);
    final chest  = p(_chestCtrl);
    final thighs = p(_thighsCtrl);
    final arms   = p(_armsCtrl);

    if (waist == null && hips == null && chest == null && thighs == null && arms == null) return;

    ref.read(bodyTrackingProvider.notifier).updateMeasurement(
      waist: waist,
      hips: hips,
      chest: chest,
      thighs: thighs,
      arms: arms,
    );

    _waistCtrl.clear();
    _hipsCtrl.clear();
    _chestCtrl.clear();
    _thighsCtrl.clear();
    _armsCtrl.clear();
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mensurations enregistrees !',
            style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: _P.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Progress Photos Section ───────────────────────────────────────────────

  Widget _buildPhotosSection(bool dark) {
    const labels = ['Face', 'Profil', 'Dos'];
    const keys   = ['front', 'side', 'back'];

    return _card(dark, child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(dark, LucideIcons.camera, 'Photos de progres'),
        const SizedBox(height: 12),
        Row(
          children: List.generate(3, (i) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : 6, right: i == 2 ? 0 : 6),
              child: _PhotoSlot(
                label: labels[i],
                slotKey: keys[i],
                dark: dark,
                picker: _picker,
              ),
            ),
          )),
        ),
      ],
    ));
  }

  // ── Shared Widgets ────────────────────────────────────────────────────────

  Widget _card(bool dark, {required Widget child}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _P.card(dark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _P.border(dark)),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(bool dark, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _P.accent),
        const SizedBox(width: 8),
        Text(title, style: GoogleFonts.outfit(
          fontSize: 16, fontWeight: FontWeight.w700, color: _P.t1(dark),
        )),
      ],
    );
  }

  Widget _pillButton(bool dark, IconData icon, VoidCallback onTap) {
    return Material(
      color: _P.accent.withOpacity(0.12),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, size: 20, color: _P.accent),
        ),
      ),
    );
  }

  Widget _saveButton(bool dark, VoidCallback onTap, {bool wide = false}) {
    return Material(
      color: _P.accent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: wide ? 32 : 16,
            vertical: 10,
          ),
          child: Text('Enregistrer',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(bool dark, String hint, String suffix) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 13, color: _P.t2(dark)),
      suffixText: suffix,
      suffixStyle: GoogleFonts.inter(fontSize: 12, color: _P.t2(dark)),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      filled: true,
      fillColor: _P.bg(dark),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _P.border(dark)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _P.border(dark)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _P.accent, width: 1.5),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PHOTO SLOT WIDGET
// ══════════════════════════════════════════════════════════════════════════════

class _PhotoSlot extends StatefulWidget {
  final String label;
  final String slotKey;
  final bool dark;
  final ImagePicker picker;

  const _PhotoSlot({
    required this.label,
    required this.slotKey,
    required this.dark,
    required this.picker,
  });

  @override
  State<_PhotoSlot> createState() => _PhotoSlotState();
}

class _PhotoSlotState extends State<_PhotoSlot> {
  List<File> _photos = [];

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<Directory> _slotDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/body_photos/${widget.slotKey}');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<void> _loadPhotos() async {
    try {
      final dir = await _slotDir();
      final files = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.jpg') || f.path.endsWith('.png'))
          .toList()
        ..sort((a, b) => b.path.compareTo(a.path)); // newest first by name
      if (mounted) setState(() { _photos = files; });
    } catch (_) {
      if (mounted) setState(() {});
    }
  }

  Future<void> _takePhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: _P.card(widget.dark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(LucideIcons.camera, color: _P.accent),
                title: Text('Prendre une photo',
                    style: GoogleFonts.inter(color: _P.t1(widget.dark))),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(LucideIcons.image, color: _P.accent),
                title: Text('Choisir depuis la galerie',
                    style: GoogleFonts.inter(color: _P.t1(widget.dark))),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null) return;

    final xFile = await widget.picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (xFile == null) return;

    final dir = await _slotDir();
    final stamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
    final dest = File('${dir.path}/$stamp.jpg');
    await File(xFile.path).copy(dest.path);
    await _loadPhotos();
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    final latest = _photos.isNotEmpty ? _photos.first : null;

    return Column(
      children: [
        GestureDetector(
          onTap: _takePhoto,
          child: Container(
            height: 130,
            decoration: BoxDecoration(
              color: _P.bg(dark),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _P.border(dark),
                style: latest == null ? BorderStyle.solid : BorderStyle.none,
              ),
              image: latest != null
                  ? DecorationImage(
                      image: FileImage(latest),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: latest == null
                ? Center(
                    child: Icon(LucideIcons.plus, size: 28, color: _P.t2(dark)),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 6),
        Text(widget.label,
            style: GoogleFonts.inter(fontSize: 12, color: _P.t2(dark))),
        if (latest != null) ...[
          const SizedBox(height: 2),
          Text(
            _dateFromFile(latest),
            style: GoogleFonts.inter(fontSize: 10, color: _P.t2(dark).withOpacity(0.7)),
          ),
        ],
        if (_photos.length > 1) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => _showComparison(context, dark),
            child: Text(
              'Avant / Apres',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _P.accent,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _dateFromFile(File f) {
    final name = f.path.split('/').last.split('\\').last.replaceAll('.jpg', '').replaceAll('.png', '');
    // name format: 2026-08-27T14-30-00
    final parts = name.split('T');
    if (parts.isEmpty) return '';
    return parts.first;
  }

  void _showComparison(BuildContext context, bool dark) {
    final oldest = _photos.last;
    final newest = _photos.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _P.card(dark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Avant / Apres',
                  style: GoogleFonts.outfit(
                      fontSize: 18, fontWeight: FontWeight.w700, color: _P.t1(dark))),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _comparisonImage(oldest, 'Avant', dark)),
                  const SizedBox(width: 12),
                  Expanded(child: _comparisonImage(newest, 'Apres', dark)),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _comparisonImage(File file, String label, bool dark) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(file, height: 200, width: double.infinity, fit: BoxFit.cover),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w600, color: _P.t1(dark))),
        Text(_dateFromFile(file),
            style: GoogleFonts.inter(fontSize: 10, color: _P.t2(dark))),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// LINE CHART PAINTER
// ══════════════════════════════════════════════════════════════════════════════

class _ChartPoint {
  final DateTime date;
  final double value;
  _ChartPoint(this.date, this.value);
}

class _LineChartPainter extends CustomPainter {
  final List<_ChartPoint> points;
  final Color lineColor;
  final Color fillColor;
  final Color gridColor;
  final Color labelColor;
  final String suffix;

  _LineChartPainter({
    required this.points,
    required this.lineColor,
    required this.fillColor,
    required this.gridColor,
    required this.labelColor,
    required this.suffix,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final values = points.map((p) => p.value).toList();
    final minV = values.reduce(math.min) - 0.5;
    final maxV = values.reduce(math.max) + 0.5;
    final range = maxV - minV;
    if (range == 0) return;

    const leftPad = 40.0;
    const bottomPad = 20.0;
    final chartW = size.width - leftPad;
    final chartH = size.height - bottomPad;

    // Grid lines
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;
    for (int i = 0; i <= 3; i++) {
      final y = chartH * (1 - i / 3);
      canvas.drawLine(Offset(leftPad, y), Offset(size.width, y), gridPaint);
      final label = (minV + range * i / 3).toStringAsFixed(1);
      final tp = TextPainter(
        text: TextSpan(
            text: label,
            style: TextStyle(color: labelColor, fontSize: 9)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    // Compute points
    final offsets = <Offset>[];
    for (int i = 0; i < points.length; i++) {
      final x = leftPad + (chartW * i / (points.length - 1));
      final y = chartH * (1 - (points[i].value - minV) / range);
      offsets.add(Offset(x, y));
    }

    // Fill
    final fillPath = Path()..moveTo(offsets.first.dx, chartH);
    for (final o in offsets) {
      fillPath.lineTo(o.dx, o.dy);
    }
    fillPath.lineTo(offsets.last.dx, chartH);
    fillPath.close();
    canvas.drawPath(fillPath, Paint()..color = fillColor);

    // Line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final linePath = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (int i = 1; i < offsets.length; i++) {
      linePath.lineTo(offsets[i].dx, offsets[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Dots
    final dotPaint = Paint()..color = lineColor;
    for (final o in offsets) {
      canvas.drawCircle(o, 3, dotPaint);
    }

    // X labels (first and last date)
    for (int i = 0; i < points.length; i++) {
      if (i != 0 && i != points.length - 1) continue;
      final d = points[i].date;
      final label = '${d.day}/${d.month}';
      final tp = TextPainter(
        text: TextSpan(
            text: label,
            style: TextStyle(color: labelColor, fontSize: 9)),
        textDirection: TextDirection.ltr,
      )..layout();
      final xPos = offsets[i].dx - tp.width / 2;
      tp.paint(canvas, Offset(xPos.clamp(leftPad, size.width - tp.width), chartH + 4));
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) => true;
}

// ── Helper model ────────────────────────────────────────────────────────────

class _MeasField {
  final String label;
  final TextEditingController ctrl;
  final double? lastValue;
  final IconData icon;
  _MeasField(this.label, this.ctrl, this.lastValue, this.icon);
}
