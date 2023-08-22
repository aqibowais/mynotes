// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'dart:developer' as devtools show log;

import 'package:mynotes/Views/constants/routes.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
        title: const Text('Login'),
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
            child: const Text('Login'),
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
                await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: email, password: password);
                
                Navigator.of(context).pushNamedAndRemoveUntil(
                  notesRoute,
                  (route) => false,
                );
              } on FirebaseAuthException catch (e) {
                if (e.code == 'user-not-found') {
                  // devtools.log("User not found");
                  await showErrorDialog(
                    context,
                    'User not found',
                  );
                } else if (e.code == "wrong-password") {
                  await showErrorDialog(
                    context,
                    'Wrong Credentials',
                  );
                  // devtools.log("Wrong password");
                } else {
                  await showErrorDialog(
                    context,
                    'Error:${e.code}',
                  );
                }
              } catch (e) {
                await showErrorDialog(
                  context,
                  'Error:${e.toString()}',
                );
              }
              //
            },
          ),
          TextButton(
              //now we create a named route to ink b/w login and register view
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    registerRoute,
                    (route) =>
                        false); //but it will cause an error bcz we dont have scaffold in reg. view
              },
              child: const Text('Not registered yet? Register here!'))
        ],
      ),
    );
  }
}

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('An error occured'),
          content: Text(text),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            )
          ],
        );
      });
}
