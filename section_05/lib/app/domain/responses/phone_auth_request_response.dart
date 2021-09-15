class PhoneAuthRequestResponse {
  final String? error;
  final String? verificationId;
  final int? resendToken;

  PhoneAuthRequestResponse({
    this.error,
    this.verificationId,
    this.resendToken,
  });
}
