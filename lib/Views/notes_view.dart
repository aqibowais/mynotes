import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/Views/constants/routes.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

enum MenuAction { logout }

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main UI'),
        actions: [
          PopupMenuButton<MenuAction>(onSelected: (value) async {
            switch (value) {
              case MenuAction.logout:
                final shouldLogOut = await showLogOutDailogue(context);
                // developer.log(shouldLogOut.toString());
                // break;
                if (shouldLogOut) {
                  await FirebaseAuth.instance.signOut();
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    loginRoute,
                    (_) => false,
                  );
                }
            }
            // developer.log(value.toString());
            // print(value);
          }, itemBuilder: (context) {
            return [
              const PopupMenuItem<MenuAction>(
                value: MenuAction.logout,
                child: Text('Log out'),
              )
            ];
          })
        ],
      ),
      body: const Text('Hello world'),
    );
  }
}

// dailogue box for logout
Future<bool> showLogOutDailogue(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to Sign Out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Log out'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
