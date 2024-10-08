import 'package:test/test.dart';
import 'package:test_app/services/auth/auth_exceptions.dart';
import 'package:test_app/services/auth/auth_provider.dart';
import 'package:test_app/services/auth/auth_user.dart';

void main(){
  group('Mock Authentication', (){
    final provider = MockAuthProvider();
    test('Should not be initialized  to begin with', (){
      expect(provider.isInitialized, false); //the expectation, isInitialized must be false
    });

    test('Cannot log out if not initialized', (){
      expect(provider.logOut(), throwsA(const TypeMatcher<NotInitializedException>()));
    });

    test('Should be able to initialized', () async{
      await provider.initialize();
      expect(provider.isInitialized,true);
    });

    test('User should be null after initialization', (){
      expect(provider.currentUser, null);
    });

    test('Should be ale to initialize in less than 2 seconds', () async{
      await provider.initialize();
      expect(provider.isInitialized, true);
    },
    timeout: const Timeout(Duration(seconds: 2)));

    test('Create user should delegate to login', () async{
      final badEmailUser = provider.createUser(email: 'khooteonglee@gmail.com', password: 'anypassword');
      expect(badEmailUser, 
        throwsA(const TypeMatcher<UserNotFoundAuthException>()));

      final badPassworduser = provider.createUser(email: 'lala@gmail.com', password: 'lalala123');
      expect(badPassworduser, 
        throwsA(const TypeMatcher<WrongPasswordAuthException>()));

      final user = await provider.createUser(email: 'foo', password: 'bar');
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test('Logged in user should be able to get verfied', (){
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('Should be able to log out and log in again', () async {
      await provider.logOut();
      await provider.logIn(email: 'email', password: 'password');
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}


class MockAuthProvider implements AuthProvider {
  AuthUser? _user ;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({required String email, required String password,}) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password,);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async{
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'khooteonglee@gmail.com') throw UserNotFoundAuthException();
    if (password == 'lalala123') throw WrongPasswordAuthException();
    const user = AuthUser(isEmailVerified: false, email: 'khooteonglee@gmail.com');
    _user = user;
    return Future.value(user); //value means value that return
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async{
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true, email: 'khooteonglee@gmail.com');
    _user = newUser;
  }

}

