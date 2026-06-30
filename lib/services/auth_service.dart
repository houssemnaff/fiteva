import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'storage_service.dart';
import 'supabase_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Résultat d'une opération d'authentification
// ─────────────────────────────────────────────────────────────────────────────
class AuthResult {
  final bool success;
  final String? error;
  final User? user;

  const AuthResult._({required this.success, this.error, this.user});

  factory AuthResult.ok(User user) => AuthResult._(success: true, user: user);
  factory AuthResult.fail(String message) => AuthResult._(success: false, error: message);

  bool get isSuccess => success;
}

// ─────────────────────────────────────────────────────────────────────────────
// AuthService — Email · Google · Apple + persistence locale
// ─────────────────────────────────────────────────────────────────────────────
class AuthService {
  static SupabaseClient get _client => SupabaseConfig.client;

  // ── TODO: remplace par ton Web Client ID (Google Cloud Console)
  // Android : le "Web application" OAuth client ID
  // iOS     : le "iOS" OAuth client ID (pour clientId)
  static const _googleWebClientId =
      'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';
  static const _googleIosClientId =
      'YOUR_IOS_CLIENT_ID.apps.googleusercontent.com';

  // ── Utilisateur courant ───────────────────────────────────────────────────

  static User?   get currentUser     => _client.auth.currentUser;
  static String? get userId          => currentUser?.id;
  static String? get userEmail       => currentUser?.email;
  static bool    get isAuthenticated => currentUser != null;

  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  // ─────────────────────────────────────────────────────────────────────────
  // EMAIL / MOT DE PASSE
  // ─────────────────────────────────────────────────────────────────────────

  static Future<AuthResult> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password.trim(),
        data: {'username': username.trim()},
      );

      final user = response.user;
      if (user == null) return AuthResult.fail('Inscription échouée. Réessaie plus tard.');

      await _saveLocally(uid: user.id, email: email.trim(), username: username.trim());
      await _upsertProfile(uid: user.id, email: email.trim(), username: username.trim());
      return AuthResult.ok(user);
    } on AuthException catch (e) {
      return AuthResult.fail(_translateAuthError(e.message));
    } catch (e) {
      return AuthResult.fail('Erreur inattendue : $e');
    }
  }

  static Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final user = response.user;
      if (user == null) return AuthResult.fail('Connexion échouée. Vérifie tes identifiants.');

      await _saveLocally(uid: user.id, email: email.trim());
      await _pullProfileToLocal(user.id);
      return AuthResult.ok(user);
    } on AuthException catch (e) {
      return AuthResult.fail(_translateAuthError(e.message));
    } catch (e) {
      return AuthResult.fail('Erreur inattendue : $e');
    }
  }

  /// Inscription → si email déjà utilisé, tente la connexion automatiquement.
  static Future<AuthResult> signUpOrSignIn({
    required String email,
    required String password,
    required String username,
  }) async {
    final result = await signUp(email: email, password: password, username: username);
    if (result.isSuccess) return result;

    final alreadyExists = result.error?.toLowerCase().contains('already') == true ||
        result.error?.toLowerCase().contains('registered') == true;
    if (alreadyExists) return signIn(email: email, password: password);
    return result;
  }

  static Future<AuthResult> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim());
      // resetPasswordForEmail ne retourne pas d'user — on retourne un succès fictif
      return AuthResult._(success: true);
    } on AuthException catch (e) {
      return AuthResult.fail(_translateAuthError(e.message));
    } catch (e) {
      return AuthResult.fail(e.toString());
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GOOGLE SIGN-IN  (natif iOS/Android)
  // ─────────────────────────────────────────────────────────────────────────

  static Future<AuthResult> signInWithGoogle() async {
    if (kIsWeb) return AuthResult.fail('Google Sign-In non disponible sur web.');
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:       _googleIosClientId,   // iOS uniquement
        serverClientId: _googleWebClientId,   // Android + iOS pour obtenir idToken
        scopes: ['email', 'profile'],
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return AuthResult.fail('Connexion Google annulée.');

      final googleAuth = await googleUser.authentication;
      final idToken    = googleAuth.idToken;
      if (idToken == null) return AuthResult.fail('Token Google introuvable.');

      final response = await _client.auth.signInWithIdToken(
        provider:    OAuthProvider.google,
        idToken:     idToken,
        accessToken: googleAuth.accessToken,
      );

      final user = response.user;
      if (user == null) return AuthResult.fail('Authentification Google échouée.');

      final email    = user.email ?? googleUser.email;
      final username = googleUser.displayName ?? email.split('@').first;

      await _saveLocally(uid: user.id, email: email, username: username);
      await _upsertProfile(uid: user.id, email: email, username: username);
      await _pullProfileToLocal(user.id);
      return AuthResult.ok(user);
    } on AuthException catch (e) {
      return AuthResult.fail(_translateAuthError(e.message));
    } catch (e) {
      return AuthResult.fail('Erreur Google : $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // APPLE SIGN-IN  (iOS / macOS uniquement)
  // ─────────────────────────────────────────────────────────────────────────

  static bool get isAppleSignInAvailable =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS);

  static Future<AuthResult> signInWithApple() async {
    if (!isAppleSignInAvailable) {
      return AuthResult.fail('Sign in with Apple disponible uniquement sur iOS/macOS.');
    }
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final idToken = credential.identityToken;
      if (idToken == null) return AuthResult.fail('Token Apple introuvable.');

      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken:  idToken,
      );

      final user = response.user;
      if (user == null) return AuthResult.fail('Authentification Apple échouée.');

      final firstName = credential.givenName ?? '';
      final lastName  = credential.familyName ?? '';
      final username  = [firstName, lastName].where((s) => s.isNotEmpty).join(' ').trim();
      final email     = user.email ?? '';

      await _saveLocally(uid: user.id, email: email, username: username.isNotEmpty ? username : email.split('@').first);
      await _upsertProfile(uid: user.id, email: email, username: username.isNotEmpty ? username : email.split('@').first);
      await _pullProfileToLocal(user.id);
      return AuthResult.ok(user);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return AuthResult.fail('Connexion Apple annulée.');
      }
      return AuthResult.fail('Erreur Apple : ${e.message}');
    } on AuthException catch (e) {
      return AuthResult.fail(_translateAuthError(e.message));
    } catch (e) {
      return AuthResult.fail('Erreur Apple : $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DÉCONNEXION
  // ─────────────────────────────────────────────────────────────────────────

  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (_) {}
    await StorageService.setString('auth_uid', '');
    await StorageService.setString('auth_email', '');
    StorageService.setOnboardingCompleted(false);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPERS PRIVÉS
  // ─────────────────────────────────────────────────────────────────────────

  static Future<void> _saveLocally({
    required String uid,
    required String email,
    String? username,
  }) async {
    await StorageService.setString('auth_uid', uid);
    await StorageService.setString('auth_email', email);
    final current = StorageService.getOnboardingData();
    current['email'] = email;
    if (username != null) current['username'] = username;
    await StorageService.saveOnboardingData(current);
  }

  static Future<void> _pullProfileToLocal(String uid) async {
    try {
      final profile = await SupabaseConfig.table('user_profiles')
          .select('username, email').eq('id', uid).maybeSingle();
      final bio = await SupabaseConfig.table('user_biometrics')
          .select().eq('user_id', uid).maybeSingle();
      final cycle = await SupabaseConfig.table('user_cycle_settings')
          .select().eq('user_id', uid).maybeSingle();

      final merged = <String, dynamic>{
        ...StorageService.getOnboardingData(),
        if (profile != null) ...{'username': profile['username'] ?? '', 'email': profile['email'] ?? ''},
        if (bio     != null) ...{
          'height_cm': bio['height_cm'], 'weight_kg': bio['weight_kg'],
          'age': bio['age'], 'fitness_level': bio['fitness_level'],
          'goals': bio['goals'] ?? [], 'equipment': bio['equipment'] ?? [],
        },
        if (cycle   != null) ...{
          'health_status': cycle['health_status'],
          'cycle_duration': cycle['cycle_duration']?.toString(),
          'last_period': cycle['last_period_date'],
        },
      };

      await StorageService.saveOnboardingData(merged);
      if ((profile?['username'] as String? ?? '').isNotEmpty) {
        StorageService.setOnboardingCompleted(true);
      }
    } catch (_) {}
  }

  static Future<void> _upsertProfile({
    required String uid,
    required String email,
    required String username,
  }) async {
    try {
      await SupabaseConfig.table('user_profiles').upsert({
        'id': uid, 'email': email, 'username': username,
        'updated_at': DateTime.now().toIso8601String(),
      });
      print('[AuthService] ✅ user_profiles sauvegardé pour $uid');
    } catch (e) {
      print('[AuthService] ❌ user_profiles ERREUR: $e');
    }
  }

  static String _translateAuthError(String raw) {
    final msg = raw.toLowerCase();
    if (msg.contains('invalid login') || msg.contains('invalid credentials'))
      return 'Email ou mot de passe incorrect.';
    if (msg.contains('already registered') || msg.contains('already been registered'))
      return 'already_registered';
    if (msg.contains('password') && msg.contains('short'))
      return 'Le mot de passe doit contenir au moins 6 caractères.';
    if (msg.contains('email') && (msg.contains('invalid') || msg.contains('format')))
      return 'Adresse email invalide.';
    if (msg.contains('network') || msg.contains('connection'))
      return 'Pas de connexion internet. Réessaie.';
    if (msg.contains('email not confirmed'))
      return 'Confirme ton email avant de te connecter.';
    return raw;
  }
}

