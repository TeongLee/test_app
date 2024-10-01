import 'package:test_app/services/auth/auth_user.dart';

//create an interface of auth provide class that can be used by 
//different type of auth provider (eg:Google, Apple...)

abstract class AuthProvider { //show what can be performed by auth provider
  AuthUser? get currentUser;
  Future<AuthUser> logIn({
    required String email,
    required String password,
  });
  Future<AuthUser> createUser({
    required String email,
    required String password,
  });
  Future<void> logOut();
  Future<void> sendEmailVerification();
}