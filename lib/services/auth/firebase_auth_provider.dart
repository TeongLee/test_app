import 'package:firebase_core/firebase_core.dart';
import 'package:test_app/firebase_options.dart';
import 'package:test_app/services/auth/auth_exceptions.dart';
import 'package:test_app/services/auth/auth_provider.dart';
import 'package:test_app/services/auth/auth_user.dart';
import 'package:firebase_auth/firebase_auth.dart'
  show FirebaseAuth, FirebaseAuthException;


class FirebaseAuthProvider implements AuthProvider{
  @override
  Future<AuthUser> createUser({required String email, required String password}) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      final user = currentUser; //call getter function to get currentUser
      if(user!=null){
        return user;
      }else{
        throw UserNotLoggedInAuthException();
      }
    }on FirebaseAuthException catch(e){
      if (e.code == "weak-password"){
        throw WeakPasswordAuthException();
      } else if (e.code == "email-already-in-use"){
        throw EmailAlreadyInUseAuthException();
      } else if (e.code == 'invalid-email'){
        throw InvalidEmailAuthException();
      } else {
        throw GenericAuthException();
      }
    }catch(e){
      throw GenericAuthException();
    }
  }

  @override
  AuthUser? get currentUser{ //getter syntax, to call view line 12
    final user = FirebaseAuth.instance.currentUser;
    if (user!= null){
      return AuthUser.fromFirebase(user);
    }else{
      return null;
    }
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) async {
     try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      final user = currentUser; //call getter function to get currentUser
      if(user!=null){
        return user;
      }else{
        throw UserNotLoggedInAuthException();
      }
    }on FirebaseAuthException catch (e){
      if (e.code == 'user-not-found') {
        throw  UserNotFoundAuthException();
      } else if (e.code == 'wrong-password') {
        throw WrongPasswordAuthException();
      }else {
        throw GenericAuthException();
      }
    } catch (e){
      throw GenericAuthException();
    }
}

  @override
  Future<void> logOut() async{
    final user = currentUser; //call getter function to get currentUser
    if(user!=null){
      await FirebaseAuth.instance.signOut();
    }else{
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async{
    final user = FirebaseAuth.instance.currentUser;
    if(user!=null){
        await user.sendEmailVerification();
      }else{
        throw UserNotLoggedInAuthException();
      }
  }
  
  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

}


