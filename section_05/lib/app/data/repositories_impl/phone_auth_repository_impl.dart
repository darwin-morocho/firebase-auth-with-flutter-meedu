import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_auth/app/domain/models/country.dart';
import 'package:flutter_firebase_auth/app/domain/repositories/phone_auth_repository.dart';
import 'package:flutter_firebase_auth/app/domain/responses/phone_auth_request_response.dart';
import 'package:flutter_firebase_auth/app/domain/responses/phone_auth_response.dart';
import 'package:phone_number/phone_number.dart';

class PhoneAuthRepositoryImpl implements PhoneAuthRepository {
  final FirebaseAuth _auth;
  final PhoneNumberUtil _phoneNumberUtil;
  OnVerificationComplete? _onVerificationCompleted;

  PhoneAuthRepositoryImpl(this._auth, this._phoneNumberUtil);

  Completer<PhoneAuthRequestResponse>? _smsRequestCompleter;

  /// this will be complete when the sms validation request is finished
  Completer<PhoneAuthResponse>? _smsValidationCompleter;

  @override
  void addVerificationCompleteListener(OnVerificationComplete func) {
    _onVerificationCompleted = func;
  }

  @override
  Future<PhoneAuthRequestResponse> requestCode(
    String phoneNumber, {
    int? forceResendingToken,
  }) async {
    if (_smsRequestCompleter != null) {
      return _smsRequestCompleter!.future;
    }
    _smsRequestCompleter = Completer();
    _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: forceResendingToken,
      verificationCompleted: (credential) async {
        try {
          final UserCredential userCredential = await _auth.signInWithCredential(credential);
          final user = userCredential.user;
          if (_smsValidationCompleter != null) {
            _smsValidationCompleter!.complete(
              PhoneAuthResponse.success(user!),
            );
            _smsValidationCompleter = null;
          } else if (_onVerificationCompleted != null) {
            _onVerificationCompleted!(user!);
          }
        } catch (_) {}
      },
      verificationFailed: (exception) {
        _smsRequestCompleter?.complete(
          PhoneAuthRequestResponse(
            error: exception.code,
          ),
        );
        _smsRequestCompleter = null;
      },
      codeSent: (String verificationId, int? resendToken) {
        _smsRequestCompleter?.complete(
          PhoneAuthRequestResponse(
            verificationId: verificationId,
            resendToken: resendToken,
          ),
        );
        _smsRequestCompleter = null;
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
    return _smsRequestCompleter!.future;
  }

  @override
  Future<PhoneAuthResponse> validateSmsCode(String verificationId, String code) {
    _smsValidationCompleter = Completer();
    final PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: code,
    );
    _auth.signInWithCredential(credential).then(
      (UserCredential credential) {
        if (_smsValidationCompleter != null) {
          _smsValidationCompleter!.complete(
            PhoneAuthResponse.success(credential.user!),
          );
          _smsValidationCompleter = null;
        }
      },
      onError: (e) {
        if (e is FirebaseAuthException) {
          if (_smsValidationCompleter != null) {
            _smsValidationCompleter!.complete(
              PhoneAuthResponse.fail(e.code),
            );
            _smsValidationCompleter = null;
          }
        }
      },
    );

    return _smsValidationCompleter!.future;
  }

  @override
  Future<bool> isValidNumber(String phoneNumber, Country country) async {
    try {
      final isValid = await _phoneNumberUtil.validate(
        phoneNumber,
        country.code,
      );
      return isValid;
    } catch (_) {
      return false;
    }
  }
}
