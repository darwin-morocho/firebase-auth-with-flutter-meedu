import 'package:firebase_auth/firebase_auth.dart';

abstract class AccountRepository {
  Future<User?> updateDisplayName(String value);
}
