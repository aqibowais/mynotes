// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'dart:developer' as devtools show log;

import 'package:mynotes/Views/constants/routes.dart';
import 'package:mynotes/Views/login_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
  // Late final TextEditingController _email
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Enter email here',
            ),
          ),
          TextField(
            controller: _password,
            enableSuggestions: false,
            autocorrect: false,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Enter password here',
            ),
          ),
          TextButton(
              child: const Text('Register'),
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;
                try {
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: email, password: password);
                  // final user = FirebaseAuth.instance.currentUser;
                  // await user?.sendEmailVerification();
                  // devtools.log(userCredential.toString());
                  Navigator.of(context).pushNamed(verifyEmailRoute);
                } on FirebaseAuthException catch (e) {
                  // print('Caught an exception: ${e.code}');
                  if (e.code == 'invalid-email') {
                    // devtools.log('Invalid email format');
                    await showErrorDialog(
                      context,
                      'Invalid email format',
                    );
                  } else if (e.code == 'weak-password') {
                    // devtools.log('weak password');
                    await showErrorDialog(
                      context,
                      'weak password',
                    );
                  } else if (e.code == 'email-already-in-use') {
                    // devtools.log('email already in use');
                    await showErrorDialog(
                      context,
                      'email already in use',
                    );
                  }
                } catch (e) {
                  await showErrorDialog(
                    context,
                    'Error: ${e.toString()}',
                  );
                }
              }),
          TextButton(
              //now we create a named route to ink b/w login and register view
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    loginRoute,
                    (route) =>
                        false); //but it will cause an error bcz we dont have scaffold in reg. view
              },
              child: const Text('Already Registered? Login here!'))
        ],
      ),
    );
  }
}
