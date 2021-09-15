import 'package:flutter/widgets.dart' show FormState, GlobalKey;
import 'package:flutter_firebase_auth/app/domain/repositories/authentication_repository.dart';
import 'package:flutter_firebase_auth/app/domain/responses/sign_in_response.dart';
import 'package:flutter_firebase_auth/app/ui/global_controllers/session_controller.dart';
import 'package:flutter_meedu/meedu.dart';

class LoginController extends SimpleNotifier {
  final SessionController _sessionController;

  String _email = '', _password = '';
  final AuthenticationRepository _authenticationRepository = Get.i.find();

  final GlobalKey<FormState> formKey = GlobalKey();

  LoginController(this._sessionController);

  void onEmailChanged(String text) {
    _email = text;
  }

  void onPasswordChanged(String text) {
    _password = text;
  }

  Future<bool> get isAppleSignInAvailable => _authenticationRepository.isAppleSignInAvailable;

  Future<SignInResponse> signInWithEmailAndPassword() async {
    final response = await _authenticationRepository.signInWithEmailAndPassword(
      _email,
      _password,
    );
    return _handleSignInResponse(response);
  }

  Future<SignInResponse> signInWithGoogle() async {
    final response = await _authenticationRepository.signInWithGoogle();
    return _handleSignInResponse(response);
  }

  Future<SignInResponse> signInWithFacebook() async {
    final response = await _authenticationRepository.signInWithFacebook();
    return _handleSignInResponse(response);
  }

  Future<SignInResponse> signInWithApple() async {
    final response = await _authenticationRepository.signInWithApple();
    return _handleSignInResponse(response);
  }

  SignInResponse _handleSignInResponse(SignInResponse response) {
    if (response.error == null) {
      _sessionController.setUser(response.user!);
    }
    return response;
  }
}
