import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Configuration Cloudinary — upload non-signé (unsigned) depuis l'app.
/// Dashboard Cloudinary → Settings → Upload → Upload presets.
/// ─────────────────────────────────────────────────────────────────────────────
class CloudinaryConfig {
  static const String cloudName = 'dmo9p642p';
  static const String uploadPreset = 'fiteva_image';
  static const String folder = 'fiteva';

  static Uri get _uploadUri =>
      Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

  /// Upload une image vers Cloudinary et retourne son URL publique (secure_url),
  /// ou `null` en cas d'échec.
  static Future<String?> uploadImage(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      final request = http.MultipartRequest('POST', _uploadUri)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = folder
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: file.name,
        ));

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode != 200) {
        debugPrint('[CloudinaryConfig] uploadImage failed '
            '(${response.statusCode}): ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['secure_url'] as String?;
    } catch (e) {
      debugPrint('[CloudinaryConfig] uploadImage error: $e');
      return null;
    }
  }
}
