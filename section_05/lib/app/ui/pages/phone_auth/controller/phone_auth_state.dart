import 'dart:ui' as ui;
import 'package:flutter_firebase_auth/app/domain/models/country.dart';
import 'package:flutter_firebase_auth/app/ui/global_widgets/country_picker/country_picker.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'phone_auth_state.freezed.dart';

@freezed
class PhoneAuthState with _$PhoneAuthState {
  factory PhoneAuthState({
    @Default('') String phoneNumber,
    required Country country,
    @Default('') String smsCode,
    String? verificationId,
    int? resendToken,
    String? routeName,
    @Default(false) bool codeSent,
    @Default(false) bool isValidNumber,
  }) = _PhoneAuthState;

  static PhoneAuthState get initialState => PhoneAuthState(
        country: defaultCountry,
      );
}

Country get defaultCountry {
  final countryCode = ui.window.locale.countryCode;
  if (countryCode != null) {
    final index = countries.indexWhere(
      (e) => e.code == countryCode,
    );
    if (index != -1) {
      return countries[index];
    }
  }
  return countries.first;
}
