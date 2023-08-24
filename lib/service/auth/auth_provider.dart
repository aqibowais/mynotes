//it is the provider of our all the authentication as we seen in firebase console like email combinations,google,facebook,etc
import 'package:mynotes/service/auth/auth_user.dart';

//creating abstract class
abstract class AuthProvider {
  AuthUser? get currentUser; //getter
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
