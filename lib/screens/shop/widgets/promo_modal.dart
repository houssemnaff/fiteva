import 'dart:typed_data';
import 'package:fiteva/screens/nutrition/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/boutique_item.dart';


class PromoModal extends StatefulWidget {
  final BoutiqueItem item;
  const PromoModal({super.key, required this.item});

  @override
  State<PromoModal> createState() => _PromoModalState();
}

class _PromoModalState extends State<PromoModal> {
  bool _copied = false;
  bool _generating = false;

  Future<void> _downloadPDF() async {
    setState(() => _generating = true);

    final pdf = pw.Document();

    Uint8List? imageBytes;
    try {
      final response = await NetworkAssetBundle(Uri.parse(widget.item.imageUrl))
          .load(widget.item.imageUrl);
      imageBytes = response.buffer.asUint8List();
    } catch (_) {}

    final qrValidationResult = QrValidator.validate(
      data: 'https://validate.tse.app/${widget.item.promoCode}',
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );
    final qrImage = qrValidationResult.isValid ? qrValidationResult.qrCode : null;

    final r = ((widget.item.primaryColor.value >> 16) & 0xFF) / 255;
    final g = ((widget.item.primaryColor.value >> 8) & 0xFF) / 255;
    final b = (widget.item.primaryColor.value & 0xFF) / 255;
    final brandColor = PdfColor(r, g, b);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (pw.Context ctx) {
          return pw.Stack(
            children: [
              pw.Container(
                width: double.infinity,
                height: double.infinity,
                color: PdfColor(0.98, 0.97, 0.96),
              ),
              pw.Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: pw.Container(
                  height: 240,
                  color: brandColor,
                  child: pw.Stack(
                    children: [
                      if (imageBytes != null)
                        pw.Positioned.fill(
                          child: pw.Opacity(
                            opacity: 0.35,
                            child: pw.Image(
                              pw.MemoryImage(imageBytes),
                              fit: pw.BoxFit.cover,
                            ),
                          ),
                        ),
                      pw.Positioned(
                        left: 32,
                        bottom: 28,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              widget.item.brand,
                              style: pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            pw.Text(
                              widget.item.discount,
                              style: pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 72,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              'sur le site',
                              style: const pw.TextStyle(
                                color: PdfColors.white,
                                fontSize: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              pw.Positioned(
                top: 260,
                left: 24,
                right: 24,
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(24),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    borderRadius: pw.BorderRadius.circular(16),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Ton code promo',
                        style: const pw.TextStyle(color: PdfColors.grey, fontSize: 12),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        decoration: pw.BoxDecoration(
                          color: PdfColor(0.96, 0.94, 0.92),
                          borderRadius: pw.BorderRadius.circular(10),
                        ),
                        child: pw.Text(
                          widget.item.promoCode,
                          style: pw.TextStyle(
                            fontSize: 26,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 4,
                            color: PdfColor(0.1, 0.07, 0.05),
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 20),
                      pw.Row(
                        children: [
                          if (qrImage != null)
                            pw.BarcodeWidget(
                              barcode: pw.Barcode.qrCode(),
                              data:
                                  'https://validate.tse.app/${widget.item.promoCode}',
                              width: 90,
                              height: 90,
                              color: PdfColor(0.1, 0.07, 0.05),
                            ),
                          pw.SizedBox(width: 16),
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'Scanne le QR code',
                                  style: pw.TextStyle(
                                    fontSize: 13,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColor(0.1, 0.07, 0.05),
                                  ),
                                ),
                                pw.SizedBox(height: 4),
                                pw.Text(
                                  'ou saisis le code manuellement lors de ta commande en ligne.',
                                  style: const pw.TextStyle(
                                    fontSize: 11,
                                    color: PdfColors.grey,
                                  ),
                                ),
                                pw.SizedBox(height: 10),
                                pw.Text(
                                  'Site : ${widget.item.siteUrl}',
                                  style: pw.TextStyle(fontSize: 10, color: brandColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 20),
                      pw.Divider(color: PdfColor(0.9, 0.88, 0.86)),
                      pw.SizedBox(height: 12),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Valable jusqu\'au ${widget.item.validUntil}',
                            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                          ),
                          pw.Text(
                            'Réservé aux abonnés TSE',
                            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              pw.Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: pw.Center(
                  child: pw.Text(
                    'Carte personnelle · Non cessible · Généré via l\'app TSE',
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'promo_${widget.item.promoCode}.pdf',
    );

    if (mounted) setState(() => _generating = false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final item = widget.item;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, MediaQuery.of(context).padding.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Text('🎉', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          const Text(
            'Ta récompense est prête !',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Utilise le code ou le QR code sur le site partenaire.',
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Promo card
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: item.primaryColor.withOpacity(0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                children: [
                  SizedBox(
                    height: 140,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [item.primaryColor, item.secondaryColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        CachedNetworkImage(
                          imageUrl: item.imageUrl,
                          fit: BoxFit.cover,
                          color: colorScheme.scrim.withOpacity(0.3),
                          colorBlendMode: BlendMode.darken,
                          placeholder: (_, __) => Container(),
                          errorWidget: (_, __, ___) => Container(),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                item.brand,
                                style: TextStyle(
                                  color: colorScheme.onPrimary.withOpacity(0.85),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Text(
                                item.discount,
                                style: TextStyle(
                                  color: colorScheme.onPrimary,
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                  letterSpacing: -2,
                                ),
                              ),
                              Text(
                                'sur le site',
                                style: TextStyle(color: colorScheme.onPrimary.withOpacity(0.85), fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: colorScheme.surface,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Code promo',
                                      style: TextStyle(
                                          fontSize: 11, color: colorScheme.onSurfaceVariant),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.promoCode,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: colorScheme.onSurface,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(
                                      ClipboardData(text: item.promoCode));
                                  setState(() => _copied = true);
                                  Future.delayed(
                                    const Duration(seconds: 2),
                                    () {
                                      if (mounted) setState(() => _copied = false);
                                    },
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _copied
                                        ? colorScheme.primary
                                        : colorScheme.secondary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _copied
                                            ? Icons.check
                                            : Icons.copy_rounded,
                                        color: colorScheme.onPrimary,
                                        size: 15,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        _copied ? 'Copié !' : 'Copier',
                                        style: TextStyle(
                                          color: colorScheme.onPrimary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: colorScheme.outlineVariant),
                              ),
                              child: QrImageView(
                                data:
                                    'https://validate.tse.app/${item.promoCode}',
                                version: QrVersions.auto,
                                size: 62,
                                backgroundColor: colorScheme.surface,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Text(
                                    'Scanne le QR code',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                    Text(
                                    'Ou saisis le code manuellement lors de ta commande.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colorScheme.onSurfaceVariant,
                                        height: 1.5,
                                      ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Valable jusqu\'au ${item.validUntil}',
                                      style: TextStyle(
                                          fontSize: 11, color: colorScheme.onSurfaceVariant),
                                  ),
                                ],
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
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _generating ? null : _downloadPDF,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
                elevation: 0,
              ),
              child: _generating
                  ?  SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                              AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.picture_as_pdf_outlined,
                              color: colorScheme.onPrimary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Télécharger en PDF',
                          style: TextStyle(
                              color: colorScheme.onPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Fermer',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}