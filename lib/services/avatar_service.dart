import 'package:image_picker/image_picker.dart';

import 'cloudinary_config.dart';
import 'supabase_config.dart';

/// AvatarService — upload de la photo de profil vers Cloudinary et
/// persistance de l'URL résultante dans user_profiles.image_url.
class AvatarService {
  /// Upload une photo vers Cloudinary et retourne son URL publique,
  /// ou `null` en cas d'échec.
  static Future<String?> uploadAvatar(XFile file) =>
      CloudinaryConfig.uploadImage(file);

  /// Persiste l'URL de l'avatar dans Supabase. No-op si l'utilisateur
  /// n'est pas encore authentifié (ex: choisi avant la fin de l'onboarding).
  static Future<void> saveAvatarUrl(String imageUrl) async {
    final uid = SupabaseConfig.userId;
    if (uid == null) return;
    await SupabaseConfig.table('user_profiles').upsert({
      'id': uid,
      'image_url': imageUrl,
      'updated_at': DateTime.now().toIso8601String(),
    }).catchError((_) {});
  }
}
