import 'package:chat/widgets/input.dart';
import 'package:chat/widgets/messages_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _Chat();
}

class _Chat extends State<Chat> {
  final GoogleSignIn googleSignIn = GoogleSignIn();

  User? user;

  void login() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;

      final AuthCredential authCredential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(authCredential);

      setState(() {
        user = userCredential.user!;
      });
    } catch (error) {
      print("ererererererer");
    }
  }

  void logout() {
    print("Logout");
  }

  @override
  Widget build(BuildContext context) {
    IconButton logoutButton = IconButton(onPressed: login, icon: const Icon(Icons.login, color: Colors.white));

    AppBar appBar = AppBar(
      backgroundColor: Colors.blue,
      actions: [logoutButton],
      titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
      title: const Text("Olá, Daniel Ciofi"),
      centerTitle: true,
    );

    Column column = Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Expanded(child: MessagesList(user: user)), Container(height: 50, width: double.maxFinite, child: Input(user: user))],
      // children: [Expanded(child: MessagesList()), Input()],
    );

    Scaffold scaffold = Scaffold(
      appBar: appBar,
      body: column,
    );

    return scaffold;
  }
}
