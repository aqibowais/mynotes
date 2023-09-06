import 'package:flutter_test/flutter_test.dart';
import 'package:mynotes/service/auth/auth_exceptions.dart';
import 'package:mynotes/service/auth/auth_provider.dart';
import 'package:mynotes/service/auth/auth_user.dart';
// import 'package:test/test.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test('Should not be initialized with begin', () {
      expect(provider.isinitialized, false);
    });
    test('Cannot logout is not initialized', () {
      expect(provider.logOut(),
          throwsA(const TypeMatcher<NotInitializedException>()));
    });
    //Testing provider initialization
    test('Should be able to be initialized', () async {
      await provider.initialize();
      expect(provider.isinitialized, true);
    });
    test('User should be null after initialization', () {
      expect(provider.currentUser, null);
    });
    test(
      'Should be able to initialize in less than 2 seconds',
      () async {
        await provider.initialize();
        expect(provider.isinitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );

    test('Create User should delegate to login', () async {
      final badEmail =
          provider.createUser(email: 'foo@bar.com', password: 'anypassword');
      expect(badEmail, throwsA(const TypeMatcher<UserNotFoundAuthException>()));
      final badPassword =
          provider.createUser(email: 'someone@bar.com', password: 'foobar');
      expect(
        badPassword,
        throwsA(const TypeMatcher<WrongPasswordAuthException>()),
      );
      final user = await provider.createUser(
        email: 'foo',
        password: 'bar',
      );
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });
    test('logged in user should be able to get verified', () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });
    test('should be able to logout and login again', () async {
      await provider.logOut();
      await provider.logIn(
        email: 'email',
        password: 'password',
      );
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

//Mocking
class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isinitialized = false;
  bool get isinitialized => _isinitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isinitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isinitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String? email,
    required String password,
  }) async {
    if (!isinitialized) throw NotInitializedException();
    if (email == 'foo@bar.com') throw UserNotFoundAuthException();
    if (password == 'foobar') throw WrongPasswordAuthException();
    //specific email password test(mocking and testing)
    const user = AuthUser(
      isEmailVerified: false,
      email: 'foo@bar.com',
    );
    _user = user;
    return Future.value(_user);
  }

  @override
  Future<void> logOut() async {
    if (!isinitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isinitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(
      isEmailVerified: true,
      email: 'foo@bar.com',
    );
    _user = newUser;
  }
}
