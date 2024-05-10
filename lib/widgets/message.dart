import 'dart:io';

import 'package:chat/models/Message.dart' as message_model;
import 'package:chat/models/message_side.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class Message extends StatelessWidget {
  message_model.Message message;

  firebase_auth.User? user;

  Message({
    super.key,
    required this.message,
    this.user
  });

  Side getSide() {
    if (user == null) return Side.left;
    if (user!.uid == message.user.key) return Side.right;

    return Side.left;
  }

  Widget _getPhoto() {
    if (message.user.photoUrl != null) {
      return Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(50)),
          color: Colors.grey,
        ),
        height: 45,
        width: 45,
        child: CircleAvatar(
          radius: 50,
          child: ClipOval(
            child: Image.network(message.user.photoUrl!, width: 45, height: 45),
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(50)),
        color: Colors.brown,
      ),
      height: 45,
      width: 45,
      child: Center(
        child: Text(
          message.user.name[0],
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }

  Widget _getMessage() {
    if (message.text != null) {
      return Text(message.text!, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500));
    }

    if (message.file != null) {
      return Container(
        alignment: Alignment.centerRight,
        height: 300.0,
        width: 250.0,
        child: Image.network(message.file!),
      );
    }

    return const Placeholder();
  }

  @override
  Widget build(BuildContext context) {
    Widget photo = _getPhoto();

    Widget msg = _getMessage();
    Text name = Text(message.user.name, style: const TextStyle(fontSize: 13));

    Column column = Column(
      crossAxisAlignment: getSide() == Side.left ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [msg, name],
    );

    Padding padding = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: column,
    );

    Row row = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      textDirection: getSide() == Side.left ? TextDirection.rtl : TextDirection.ltr,
      children: [padding, photo],
    );

    return row;
  }
}
