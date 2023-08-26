// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mynotes/Constants/routes.dart';
import 'package:mynotes/Utilities/show_error_dialog.dart';
import 'package:mynotes/service/auth/auth_exceptions.dart';
import 'package:mynotes/service/auth/auth_service.dart';
// import 'dart:developer' as devtools show log;

// import 'package:mynotes/Views/login_view.dart';

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
                await AuthService.firebase().createUser(
                  email: email,
                  password: password,
                );

                // final user = FirebaseAuth.instance.currentUser;
                // await user?.sendEmailVerification();
                // devtools.log(userCredential.toString());
                AuthService.firebase().sendEmailVerification();
                Navigator.of(context).pushNamed(verifyEmailRoute);
              } on InvalidEmailAuthException {
                await showErrorDialog(
                  context,
                  'Invalid email format',
                );
              } on WeakPasswordAuthException {
                await showErrorDialog(
                  context,
                  'weak password',
                );
              } on EmailAlreadyInUseAuthException {
                await showErrorDialog(
                  context,
                  'email already in use',
                );
              } on GenericAuthException {
                await showErrorDialog(
                  context,
                  'Failed to register',
                );
              }
            },
          ),
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
