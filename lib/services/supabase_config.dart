import 'package:supabase_flutter/supabase_flutter.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Configuration Supabase — à remplir avec vos valeurs depuis :
///   https://app.supabase.com → Settings → API
/// ─────────────────────────────────────────────────────────────────────────────
class SupabaseConfig {
  static const String url = 'https://mkzybprlhllcrbwlknkg.supabase.co';

  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1renlicHJsaGxsY3Jid2xrbmtnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIyOTgwMDgsImV4cCI6MjA5Nzg3NDAwOH0.LE2XY00xsEDD1vVwpX_0GhBKNhengQM04rUVwb50eFE';

  /// Client Supabase global
  static SupabaseClient get client => Supabase.instance.client;

  /// Utilisateur connecté (null si non authentifié)
  static User? get currentUser => client.auth.currentUser;

  /// UUID de l'utilisateur connecté
  static String? get userId => currentUser?.id;

  /// Email de l'utilisateur connecté
  static String? get userEmail => currentUser?.email;

  /// À appeler dans main() avant runApp()
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      // ignore: deprecated_member_use
      anonKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  /// Raccourci vers la table [table]
  static SupabaseQueryBuilder table(String table) => client.from(table);
}
