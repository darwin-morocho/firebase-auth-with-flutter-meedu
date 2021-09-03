import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_firebase_auth/app/domain/repositories/authentication_repository.dart';
import 'package:flutter_firebase_auth/app/domain/responses/reset_password_response.dart';
import 'package:flutter_firebase_auth/app/domain/responses/sign_in_response.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebookAuth;
  User? _user;

  final Completer<void> _completer = Completer();

  AuthenticationRepositoryImpl({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
    required FacebookAuth facebookAuth,
  })  : _auth = firebaseAuth,
        _googleSignIn = googleSignIn,
        _facebookAuth = facebookAuth {
    _init();
  }

  @override
  Future<User?> get user async {
    await _completer.future;
    return _user;
  }

  void _init() async {
    _auth.authStateChanges().listen(
      (User? user) {
        if (!_completer.isCompleted) {
          _completer.complete();
        }
        _user = user;
      },
    );
  }

  @override
  Future<void> signOut() async {
    final data = _user?.providerData ?? [];
    String providerId = 'firebase';
    for (final provider in data) {
      // password
      // phone
      // google.com
      // facebook.com
      // twitter.com
      // github.com
      // apple.com
      if (provider.providerId != 'firebase') {
        providerId = provider.providerId;
        break;
      }
    }

    if (providerId == 'google.com') {
      await _googleSignIn.signOut();
    } else if (providerId == 'facebook.com') {
      await _facebookAuth.logOut();
    }
    return _auth.signOut();
  }

  @override
  Future<SignInResponse> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user!;
      return SignInResponse(
        user: user,
        providerId: userCredential.credential?.providerId,
        error: null,
      );
    } on FirebaseAuthException catch (e) {
      return getSignInError(e);
    }
  }

  @override
  Future<ResetPasswordResponse> sendResetPasswordLink(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return ResetPasswordResponse.ok;
    } on FirebaseAuthException catch (e) {
      return stringToResetPasswordResponse(e.code);
    }
  }

  @override
  Future<SignInResponse> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        return SignInResponse(
          error: SignInError.cancelled,
          user: null,
          providerId: null,
        );
      }

      final googleAuth = await account.authentication;

      final OAuthCredential oAuthCredential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCredential = await _auth.signInWithCredential(
        oAuthCredential,
      );
      return SignInResponse(
        error: null,
        user: userCredential.user,
        providerId: userCredential.credential?.providerId,
      );
    } on FirebaseAuthException catch (e) {
      return getSignInError(e);
    }
  }

  @override
  Future<SignInResponse> signInWithFacebook() async {
    try {
      final result = await _facebookAuth.login();

      if (result.status == LoginStatus.success) {
        final facebookData = await _facebookAuth.getUserData();
        final email = facebookData['email'] as String?;
        print("🔥 user.email ${email}");
        if (email != null) {
          final methods = await fetchSignInMethodsForEmail(email);
          print(methods);
        }
        final oAuthCredential = FacebookAuthProvider.credential(result.accessToken!.token);

        final userCredential = await _auth.signInWithCredential(
          oAuthCredential,
        );
        final user = userCredential.user!;

        if (!user.emailVerified && user.email != null) {
          await user.sendEmailVerification();
        }
        return SignInResponse(
          error: null,
          user: user,
          providerId: userCredential.credential?.providerId,
        );
      } else if (result.status == LoginStatus.cancelled) {
        return SignInResponse(
          error: SignInError.cancelled,
          user: null,
          providerId: null,
        );
      }

      return SignInResponse(
        error: SignInError.unknown,
        user: null,
        providerId: null,
      );
    } on FirebaseAuthException catch (e) {
      return getSignInError(e);
    }
  }

  @override
  Future<bool> get signInWithAppleAvailable {
    return SignInWithApple.isAvailable();
  }

  @override
  Future<SignInResponse> signInWithApple(String clientId, String redirectURL) async {
    try {
      // To prevent replay attacks with the credential returned from Apple, we
      // include a nonce in the credential request. When signing in with
      // Firebase, the nonce in the id token returned by Apple, is expected to
      // match the sha256 hash of `rawNonce`.
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: clientId,
          redirectUri: Uri.parse(redirectURL),
        ),
        nonce: nonce,
        state: "origin:app",
      );
      print("appleCredential.email ${appleCredential.identityToken}");
      print("appleCredential.email ${appleCredential.givenName}");
      print("appleCredential.email ${appleCredential.email}");
      // Create an `OAuthCredential` from the credential returned by Apple.
      final oAuthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      final userCredential = await _auth.signInWithCredential(
        oAuthCredential,
      );
      return SignInResponse(
        error: null,
        user: userCredential.user,
        providerId: userCredential.credential?.providerId,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      return SignInResponse(
        error: SignInError.cancelled,
        user: null,
        providerId: null,
      );
    } on FirebaseAuthException catch (e) {
      return getSignInError(e);
    }
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Future<List<String>> fetchSignInMethodsForEmail(String email) {
    return _auth.fetchSignInMethodsForEmail(email);
  }
}

