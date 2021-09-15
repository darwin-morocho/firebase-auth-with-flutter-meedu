import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_auth/app/domain/models/country.dart';
import 'package:flutter_firebase_auth/app/domain/repositories/phone_auth_repository.dart';
import 'package:flutter_firebase_auth/app/ui/global_controllers/session_controller.dart';
import 'package:flutter_firebase_auth/app/ui/routes/routes.dart';
import 'package:flutter_meedu/meedu.dart';
import 'phone_auth_state.dart';

class PhoneAuthController extends StateNotifier<PhoneAuthState> {
  PhoneAuthController(this.sessionController) : super(PhoneAuthState.initialState) {
    _init();
  }

  final SessionController sessionController;
  final PhoneAuthRepository _phoneAuth = Get.i.find();

  final _requestAgainTime = 0.obs;
  int get requestAgainTime => _requestAgainTime.value;

  Timer? _timer;

  void _init() {
    _phoneAuth.addVerificationCompleteListener(
      (user) {
        if (!disposed) {
          _setUser(user);
        }
      },
    );
  }

  void onNumericKeyboard(String text) async {
    if (!state.codeSent) {
      final phoneNumber = "${state.phoneNumber}$text";
      final isValidNumber = await _validatePhoneNumber(phoneNumber);
      state = state.copyWith(
        phoneNumber: phoneNumber,
        isValidNumber: isValidNumber,
      );
    } else {
      final smsCode = state.smsCode;
      if (smsCode.length < 6) {
        state = state.copyWith(smsCode: "$smsCode$text");
      }
    }
  }

  void onNumericKeyboardDelete() async {
    if (!state.codeSent) {
      final phoneNumber = state.phoneNumber;
      if (phoneNumber.isNotEmpty) {
        final newValue = phoneNumber.substring(0, phoneNumber.length - 1);
        final isValidNumber = await _validatePhoneNumber(newValue);
        state = state.copyWith(
          phoneNumber: newValue,
          isValidNumber: isValidNumber,
        );
      }
    } else {
      final smsCode = state.smsCode;
      if (smsCode.isNotEmpty) {
        final newValue = smsCode.substring(0, smsCode.length - 1);
        state = state.copyWith(smsCode: newValue);
      }
    }
  }

  void onCountryChanged(Country country) {
    state = state.copyWith(country: country);
  }

  void backToPhoneNumber() {
    state = state.copyWith(
      codeSent: false,
      smsCode: "",
    );
  }

  Future<bool> _validatePhoneNumber(String phoneNumber) {
    final dialCode = state.country.dialCode;
    final country = state.country;
    return _phoneAuth.isValidNumber(
      dialCode + phoneNumber,
      country,
    );
  }

  Future<String?> requestCode() async {
    final response = await _phoneAuth.requestCode(
      state.country.dialCode + state.phoneNumber, // +5939897698745
      forceResendingToken: state.resendToken,
    );
    if (response.error == null) {
      _requestAgainTime.value = 30;
      _timer = Timer.periodic(
        const Duration(seconds: 1),
        (_) {
          if (requestAgainTime > 0) {
            _requestAgainTime.value--;
            if (requestAgainTime == 0) {
              _timer?.cancel();
              _timer = null;
            }
          }
        },
      );
      state = state.copyWith(
        codeSent: true,
        verificationId: response.verificationId,
        resendToken: response.resendToken,
      );
    }
    return response.error;
  }

  Future<String?> validateSmsCode() async {
    final response = await _phoneAuth.validateSmsCode(
      state.verificationId!,
      state.smsCode,
    );
    if (response.error == null) {
      _setUser(response.user!);
    }
    return response.error;
  }

  void _setUser(User user) {
    sessionController.setUser(user);
    state = state.copyWith(routeName: Routes.HOME);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _requestAgainTime.close();
    super.dispose();
  }
}
