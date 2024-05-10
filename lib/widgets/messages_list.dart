import 'package:chat/firebase_options.dart';
import 'package:chat/models/Message.dart' as message_model;
import 'package:chat/widgets/loader.dart';
import 'package:chat/widgets/message.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class MessagesList extends StatelessWidget {
  firebase_auth.User? user;

  MessagesList({
    super.key,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString(),
              style: const TextStyle(fontSize: 20));
        }

        if (snapshot.connectionState == ConnectionState.waiting || snapshot.connectionState == ConnectionState.none) {
          return const Loader();
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return Padding(
            padding: const EdgeInsets.all(15),
            child: StreamBuilder(
              stream: FirebaseDatabase.instance
                  .ref('chat')
                  .child("messages")
                  .onValue,
              builder: (streamContext, streamSnapshot) {
                if (streamSnapshot.data == null) return const Loader();

                List<message_model.Message> messages = streamSnapshot.data!.snapshot.children
                    .map((e) => message_model.Message.fromFirestore(e))
                    .toList();

                return ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (listViewContext, index) {
                    message_model.Message message = messages[index];
                    return Message(message: message, user: user);
                  },
                  separatorBuilder: (listViewContext, index) {
                    return const SizedBox(height: 10, width: 10);
                  },
                  itemCount: messages.length
                );
            }),
          );
        }

        return Text(snapshot.connectionState.toString());
      },
    );
  }
}
