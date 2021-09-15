import 'package:firebase_auth/firebase_auth.dart';

class PhoneAuthResponse {
  final String? error;
  final User? user;

  PhoneAuthResponse._({
    required this.error,
    required this.user,
  });

  static PhoneAuthResponse success(User user) {
    return PhoneAuthResponse._(
      error: null,
      user: user,
    );
  }

  static PhoneAuthResponse fail(String error) {
    return PhoneAuthResponse._(
      error: error,
      user: null,
    );
  }
}
