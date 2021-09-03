import 'package:flutter/widgets.dart' show FormState, GlobalKey;
import 'package:flutter_firebase_auth/app/domain/repositories/authentication_repository.dart';
import 'package:flutter_firebase_auth/app/domain/responses/sign_in_response.dart';
import 'package:flutter_firebase_auth/app/ui/global_controllers/session_controller.dart';
import 'package:flutter_meedu/meedu.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginController extends SimpleNotifier {
  final SessionController _sessionController;

  String _email = '', _password = '';
  final _authenticationRepository = Get.i.find<AuthenticationRepository>();

  final GlobalKey<FormState> formKey = GlobalKey();

  LoginController(this._sessionController);

  void onEmailChanged(String text) {
    _email = text;
  }

  void onPasswordChanged(String text) {
    _password = text;
  }

  Future<SignInResponse> signInWithEmailAndPassword() async {
    final response = await _authenticationRepository.signInWithEmailAndPassword(
      _email,
      _password,
    );

    if (response.error == null) {
      _sessionController.setUser(response.user!);
    }

    return response;
  }

  Future<SignInResponse> signInWithGoogle() async {
    final response = await _authenticationRepository.signInWithGoogle();
    if (response.error == null) {
      _sessionController.setUser(response.user!);
    }
    return response;
  }

  Future<SignInResponse> signInWithFacebook() async {
    final response = await _authenticationRepository.signInWithFacebook();
    if (response.error == null) {
      _sessionController.setUser(response.user!);
    }
    return response;
  }

  Future<SignInResponse> signInWithApple() async {
    final response = await _authenticationRepository.signInWithApple(
      "app.meedu.flutterFirebaseAuth.web",
      "https://flutter-firebase-auth-cf2e4.firebaseapp.com/__/auth/handler",
    );
    if (response.error == null) {
      _sessionController.setUser(response.user!);
    }
    return response;
  }
}
