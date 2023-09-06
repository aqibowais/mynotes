import 'package:mynotes/Views/Notes/new_notes_view.dart';
import 'package:mynotes/service/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/Constants/routes.dart';
import 'package:mynotes/Views/login_view.dart';
import 'package:mynotes/Views/Notes/notes_view.dart';
import 'package:mynotes/Views/register_view.dart';
import 'package:mynotes/Views/verify_email_view.dart';
import 'package:path/path.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized;

  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        //   useMaterial3: true,
      ),
      home: const Homepage(),
      debugShowCheckedModeBanner: false,
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        newNoteRoute: (context) => const NewNoteView(),
      },
    ),
  );
}

class Homepage extends StatelessWidget {
  const Homepage({super.key});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              // return const LoginView();correct but not good enough,below is the good approach

              final user = AuthService.firebase().currentUser;
              if (user != null) {
                if (user.isEmailVerified) {
                  // print('Email is Verified');
                  return const NotesView();
                } else {
                  return const VerifyEmailView();
                }
              } else {
                return const LoginView();
              }
            // return const Text('Done');
            // print(user);
            // if (user?.emailVerified ?? false) {
            //   // print('you are a verified user');
            //   return const Text('Done');
            // } else {
            //   //if not verified than we pushed the verify email view
            //   // print('You need to verify your email first');
            //   // pushing screen
            //   // Navigator.of(context).push(
            //   //   MaterialPageRoute(
            //   //     builder: ((context) => const VerifyEmailView()),
            //   //   ),
            //   // ); //Unhandled Exception,because we cant push scafold on existing scaffold
            //   return const VerifyEmailView();
            // }

            default:
              // return const Text('loading');
              return const CircularProgressIndicator();
          }
        });
  }
}
