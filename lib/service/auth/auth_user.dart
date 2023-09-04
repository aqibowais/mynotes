import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart'; //to avoid exposing to much of the classes

@immutable //This class or any class of this class will be immutable upon initialization
class AuthUser {
   //creating email field bcz we need an email as an input for notes service
  final String? email;
  final bool isEmailVerified;
  const AuthUser({
    required this.email,
    required this.isEmailVerified,
  }); //constructor

  factory AuthUser.fromFirebase(User user) => AuthUser(
        isEmailVerified: user.emailVerified,
        email: user.email,
      );
  //this factory constructor will go to the above constructor for the value of emailverified and then place it in User so it will be save in AuthUser class(we create instance of our class)
}
