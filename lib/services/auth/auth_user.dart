import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';


@immutable //不可改变 means this class and its own subclasses need to be immutable (they cannot have any field that changes)
class AuthUser {
  final String? email;
  final bool isEmailVerified;
  const AuthUser({required this.email, required this.isEmailVerified});


  factory AuthUser.fromFirebase(User user) {
    return AuthUser(email: user.email, isEmailVerified : user.emailVerified);
  } //for concept i have example in main.dart for factory constructor
}