import 'package:firebase_auth/firebase_auth.dart';

class SignInResponse {
  final SignInError? error;
  final User? user;
  final String? providerId;

  SignInResponse({
    required this.error,
    required this.user,
    required this.providerId,
  });
}

enum SignInError {
  cancelled,
  tooManyRequests,
  networkRequestFailed,
  userDisabled,
  userNotFound,
  wrongPassword,
  unknown,
  accountExistsWithDifferentCredential,
  invalidCredential,
}

SignInResponse getSignInError(FirebaseAuthException e) {
  late SignInError error;
  switch (e.code) {
    case "too-many-requests":
      error = SignInError.tooManyRequests;
      break;
    case "user-disabled":
      error = SignInError.userDisabled;
      break;
    case "user-not-found":
      error = SignInError.userNotFound;
      break;
    case "network-request-failed":
      error = SignInError.networkRequestFailed;
      break;
    case "wrong-password":
      error = SignInError.wrongPassword;
      break;
    case "invalid-credential":
      error = SignInError.invalidCredential;
      break;
    case "account-exists-with-different-credential":
      error = SignInError.accountExistsWithDifferentCredential;
      break;
    default:
      error = SignInError.unknown;
  }
  return SignInResponse(
    error: error,
    user: null,
    providerId: e.credential?.providerId,
  );
}
