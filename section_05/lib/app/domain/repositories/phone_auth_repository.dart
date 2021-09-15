import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_auth/app/domain/models/country.dart';
import 'package:flutter_firebase_auth/app/domain/responses/phone_auth_request_response.dart';
import 'package:flutter_firebase_auth/app/domain/responses/phone_auth_response.dart';

typedef OnVerificationComplete = void Function(User user);

abstract class PhoneAuthRepository {
  Future<bool> isValidNumber(String phoneNumber, Country country);

  Future<PhoneAuthRequestResponse> requestCode(
    String phoneNumber, {
    int? forceResendingToken,
  });

  Future<PhoneAuthResponse> validateSmsCode(
    String verificationId,
    String code,
  );

  void addVerificationCompleteListener(OnVerificationComplete func);
}
