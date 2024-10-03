import 'package:test_app/services/auth/firebase_auth_provider.dart';

import 'auth_provider.dart';
import 'auth_user.dart';

//This class is a class used by main ui of the app that communicates with the auth provider class
//different auth provider is used, so need to call by constructor which one is user, by using factory constructor
//in our case, we only use Firebase auth provider by using
//The levels of app:
//1. Main UI
//2. Service (Auth) => implemets auth provider, aids in selecting which auth provider used in Main UI
//3. Specific Auth Provider (eg: Firebase, google, yahoo...) => also implements auth provider
//4. Service Provider (Auth) => An abstract class that implemets by differents type of auth provider


class AuthService implements AuthProvider{
  final AuthProvider provider;  //because there is exist of many auth provider, so in the service

  //constructor
  const AuthService(this.provider); //so, in the service, we can know which auth provider is used by the main ui

  factory AuthService.firebase() => AuthService(FirebaseAuthProvider()); //here, we use factory consturctor that create an instance of firebase auth provider
  
  @override
  Future<AuthUser> createUser({
    required String email, 
    required String password
    }) =>
      provider.createUser(email: email, password: password);
  
  @override
  AuthUser? get currentUser => provider.currentUser;
  
  @override
  Future<AuthUser> logIn({
    required String email, 
    required String password
    }) =>
      provider.logIn(email: email, password: password);
  
  @override
  Future<void> logOut() => provider.logOut();
  
  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();
  
  @override
  Future<void> initialize() => provider.initialize();
}