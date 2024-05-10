import 'package:chat/models/User.dart';
import 'package:firebase_database/firebase_database.dart';

class Message {
  late String key;
  late String? text;
  late String? file;
  late String createdAt;
  late User user;

  Message({
    required this.key,
    required this.createdAt,
    required this.user,
    this.text,
    this.file,
  });

  factory Message.fromFirestore(
      DataSnapshot snapshot
  ) {
    dynamic data = snapshot.value;

    return Message(
      key: snapshot.key!,
      createdAt: data?['createdAt'],
      file: data?['file'],
      text: data?['text'],
      user: User.from(data?['user'])
    );
  }
}