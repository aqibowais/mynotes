import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart'; //to avoid exposing to much of the classes

@immutable //This class or any class of this class will be immutable upon initialization
class AuthUser {
  final bool isEmailVerified;
  const AuthUser(this.isEmailVerified); //constructor

  factory AuthUser.fromFirebase(User user) => AuthUser(user.emailVerified);
  //this factory constructor will go to the above constructor for the value of emailverified and then place it in User so it will be save in AuthUser class(we create instance of our class)
}
