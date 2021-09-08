import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_firebase_auth/app/data/data_source/remote/apple_sign_in.dart';
import 'package:flutter_firebase_auth/app/domain/repositories/authentication_repository.dart';
import 'package:flutter_firebase_auth/app/domain/responses/reset_password_response.dart';
import 'package:flutter_firebase_auth/app/domain/responses/sign_in_response.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebookAuth;
  final AppleSignIn _appleSignIn;
  User? _user;

  final Completer<void> _completer = Completer();

  AuthenticationRepositoryImpl({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
    required FacebookAuth facebookAuth,
    required AppleSignIn appleSignIn,
  })  : _auth = firebaseAuth,
        _googleSignIn = googleSignIn,
        _facebookAuth = facebookAuth,
        _appleSignIn = appleSignIn {
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
      await _checkAuthProvider(
        email: email,
        signInMethod: 'password',
      );
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user!;
      return SignInResponse.getSuccessResponse(
        user,
        userCredential.credential?.providerId,
      );
    } on FirebaseAuthException catch (e) {
      return getSignInError(e);
    }
  }

  @override
  Future<ResetPasswordResponse> sendResetPasswordLink(String email) async {
    try {
      await _checkAuthProvider(email: email, signInMethod: 'password');
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
        return SignInResponse.getCancelledError();
      }

      await _checkAuthProvider(
        email: account.email,
        signInMethod: 'google.com',
      );

      final googleAuth = await account.authentication;

      final OAuthCredential oAuthCredential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      return _signInWithCredential(oAuthCredential);
    } on FirebaseAuthException catch (e) {
      return getSignInError(e);
    }
  }

  @override
  Future<SignInResponse> signInWithFacebook() async {
    try {
      final result = await _facebookAuth.login();

      if (result.status == LoginStatus.success) {
        final userData = await _facebookAuth.getUserData();
        final email = userData['email'] as String?;
        if (email != null) {
          await _checkAuthProvider(
            email: email,
            signInMethod: 'facebook.com',
          );
        }

        final oAuthCredential = FacebookAuthProvider.credential(result.accessToken!.token);
        return _signInWithCredential(oAuthCredential);
      } else if (result.status == LoginStatus.cancelled) {
        return SignInResponse.getCancelledError();
      }

      return SignInResponse.getUnknownError();
    } on FirebaseAuthException catch (e) {
      return getSignInError(e);
    }
  }

  Future<SignInResponse> _signInWithCredential(AuthCredential oAuthCredential) async {
    try {
      final userCredential = await _auth.signInWithCredential(
        oAuthCredential,
      );
      final user = userCredential.user!;
      if (!user.emailVerified && user.email != null) {
        await user.sendEmailVerification();
      }
      return SignInResponse.getSuccessResponse(
        user,
        userCredential.credential?.providerId,
      );
    } on FirebaseAuthException catch (e) {
      return getSignInError(e);
    }
  }

  ///
  Future<void> _checkAuthProvider({
    required String email,
    required String signInMethod,
  }) async {
    final methods = await _auth.fetchSignInMethodsForEmail(email);
    if (methods.isNotEmpty && !methods.contains(signInMethod)) {
      if (signInMethod == 'facebook.com') {
        await _facebookAuth.logOut();
      } else if (signInMethod == 'google.com') {
        await _googleSignIn.signOut();
      }
      throw FirebaseAuthException(
        code: "account-exists-with-different-credential",
        credential: AuthCredential(
          providerId: methods.first,
          signInMethod: signInMethod,
        ),
      );
    }
  }

  ///
  @override
  Future<SignInResponse> signInWithApple() async {
    try {
      final appleResponse = await _appleSignIn.signIn();
      final identityToken = appleResponse.credential.identityToken;

      if (identityToken != null) {
        final data = JwtDecoder.decode(identityToken);

        final email = data['email'] as String?;
        if (email != null) {
          await _checkAuthProvider(
            email: email,
            signInMethod: 'apple.com',
          );
        }
      }

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oAuthCredential = OAuthProvider("apple.com").credential(
        idToken: identityToken,
        rawNonce: appleResponse.rawNonce,
      );

      return _signInWithCredential(oAuthCredential);
    } on SignInWithAppleAuthorizationException {
      return SignInResponse.getCancelledError();
    } on FirebaseAuthException catch (e) {
      return getSignInError(e);
    } catch (e) {
      return SignInResponse.getUnknownError();
    }
  }

  @override
  Future<bool> get isAppleSignInAvailable => _appleSignIn.isAvailable;
}
