import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_auth/app/domain/responses/sign_in_response.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleSignIn {
  final FirebaseAuth _auth;
  AppleSignIn(this._auth);

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
}
