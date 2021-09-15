import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_firebase_auth/app/data/data_source/remote/apple_sign_in.dart';
import 'package:flutter_firebase_auth/app/data/repositories_impl/account_repository_impl.dart';
import 'package:flutter_firebase_auth/app/data/repositories_impl/authentication_repository_impl.dart';
import 'package:flutter_firebase_auth/app/data/repositories_impl/phone_auth_repository_impl.dart';
import 'package:flutter_firebase_auth/app/data/repositories_impl/preferences_repository_impl.dart';
import 'package:flutter_firebase_auth/app/data/repositories_impl/sign_up_repository_impl.dart';
import 'package:flutter_firebase_auth/app/domain/repositories/account_repository.dart';
import 'package:flutter_firebase_auth/app/domain/repositories/authentication_repository.dart';
import 'package:flutter_firebase_auth/app/domain/repositories/phone_auth_repository.dart';
import 'package:flutter_firebase_auth/app/domain/repositories/preferences_repository.dart';
import 'package:flutter_firebase_auth/app/domain/repositories/sign_up_repository.dart';
import 'package:flutter_meedu/flutter_meedu.dart';
import 'package:flutter_meedu/meedu.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:phone_number/phone_number.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> injectDependencies() async {
  final preferences = await SharedPreferences.getInstance();
  Get.i.lazyPut<AuthenticationRepository>(
    () => AuthenticationRepositoryImpl(
      firebaseAuth: FirebaseAuth.instance,
      googleSignIn: GoogleSignIn(),
      facebookAuth: FacebookAuth.i,
      appleSignIn: AppleSignIn(
        clientId: 'app.meedu.flutterFirebaseAuth.web',
        redirectURL:
            'https://us-central1-flutter-firebase-auth-cf2e4.cloudfunctions.net/handleAppleSignInOnAndroid',
      ),
    ),
  );
  Get.i.lazyPut<SignUpRepository>(
    () => SignUpRepositoryImpl(
      FirebaseAuth.instance,
    ),
  );
  Get.i.lazyPut<AccountRepository>(
    () => AccountRepositoryImpl(
      FirebaseAuth.instance,
    ),
  );
  Get.i.lazyPut<PreferencesRepository>(
    () => PreferencesRepositoryImpl(preferences),
  );
  Get.i.lazyPut<PhoneAuthRepository>(
    () => PhoneAuthRepositoryImpl(
      FirebaseAuth.instance,
      PhoneNumberUtil(),
    ),
    autoRemove: true,
  );
}
