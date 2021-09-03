import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_firebase_auth/app/domain/repositories/authentication_repository.dart';
import 'package:flutter_firebase_auth/app/domain/responses/reset_password_response.dart';
import 'package:flutter_firebase_auth/app/domain/responses/sign_in_response.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
      await _checkAuthProvider(
        email: email,
        signInMethod: 'password',
      );
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
        return SignInResponse(
          error: SignInError.cancelled,
          user: null,
          providerId: null,
        );
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

  Future<SignInResponse> _signInWithCredential(AuthCredential oAuthCredential) async {
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
  }

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
}
