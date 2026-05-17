// lib/services/firebase_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';

class FirebaseService {
  static FirebaseService? _instance;
  static bool _initialized = false;
  FirebaseAuth? _auth;
  GoogleSignIn? _googleSignIn;

  factory FirebaseService() {
    _instance ??= FirebaseService._internal();
    return _instance!;
  }

  FirebaseService._internal() {
    print('FirebaseService._internal constructor called');
  }

  Future<void> initialize() async {
    if (_initialized) {
      print('FirebaseService.initialize() skipped because already initialized');
      return;
    }

    print('FirebaseService.initialize() start');
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('FirebaseService.initialize() after Firebase.initializeApp');

      _auth = FirebaseAuth.instance;
      _googleSignIn = GoogleSignIn();
      _initialized = true;
      print('FirebaseService.initialize() complete');
    } catch (e, st) {
      print('FirebaseService.initialize() failed: $e');
      print(st);
      _auth = null;
      _googleSignIn = null;
      // Leave the service in an uninitialized state so the app can still launch
      // and report the initialization failure instead of crashing.
    }
  }

  Future<String?> googleSignIn() async {
    final auth = _auth;
    final googleSignIn = _googleSignIn;
    if (auth == null || googleSignIn == null) {
      throw StateError('FirebaseService.initialize() must be called first.');
    }

    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return null; // User cancelled
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await auth.signInWithCredential(credential);

      return await userCredential.user?.getIdToken();
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.message}');
      rethrow;
    } catch (e) {
      print('Google Sign-In Error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    final auth = _auth;
    final googleSignIn = _googleSignIn;
    if (auth == null || googleSignIn == null) {
      throw StateError('FirebaseService.initialize() must be called first.');
    }

    try {
      await googleSignIn.signOut();
      await auth.signOut();
    } catch (e) {
      print('Sign Out Error: $e');
      rethrow;
    }
  }

  User? getCurrentUser() {
    final auth = _auth;
    if (auth == null) {
      throw StateError('FirebaseService.initialize() must be called first.');
    }
    return auth.currentUser;
  }

  bool get isReady {
    return _initialized && _auth != null && _googleSignIn != null;
  }

  Future<String?> getCurrentIdToken() async {
    final auth = _auth;
    if (auth == null) {
      throw StateError('FirebaseService.initialize() must be called first.');
    }
    return await auth.currentUser?.getIdToken();
  }

  Stream<User?> get authStateChanges {
    final auth = _auth;
    if (auth == null) {
      return const Stream<User?>.empty();
    }
    return auth.authStateChanges();
  }

  bool get isSignedIn {
    final auth = _auth;
    if (auth == null) {
      return false;
    }
    return auth.currentUser != null;
  }
}
