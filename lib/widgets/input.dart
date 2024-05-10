import 'dart:io';

import 'package:chat/models/User.dart';
import 'package:chat/widgets/loader.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class Input extends StatefulWidget {
  firebase_auth.User? user;

  Input({
    super.key,
    this.user,
  });

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  String inputValue = "";

  bool sendLoading = false;

  final TextEditingController controller = TextEditingController();

  final ImagePicker imagePicker = ImagePicker();

  Future<void> takePicture(ImageSource source, BuildContext context) async {
    if (!context.mounted) return;

    try {
      XFile? file = await imagePicker.pickImage(
        source: source,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 100,
      );

      if (file != null) {
        sendFile(file);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await imagePicker.retrieveLostData();

    if (response.isEmpty) {
      return;
    }

    if (response.file != null) {
      sendFile(response.file!);
    }
  }

  Map<String, dynamic> _buildMessage() {
    if (widget.user != null) {
      return {
        "createdAt": DateTime.now().toIso8601String(),
        "user": User(
          name: widget.user!.displayName as String,
          key: widget.user!.uid,
          photoUrl: widget.user!.photoURL
        ).toMap(),
      };
    }

    return {
      "createdAt": DateTime.now().toIso8601String(),
      "user": User(name: "Ivan Guima", key: "1235", photoUrl: "https://pbs.twimg.com/profile_images/1233222232375164933/WsSmDqvb_400x400.jpg").toMap(),
    };
  }

  sendFile(XFile file) async {
    String fileName = const Uuid().v4().toString();
    String ext = file.name.split(".")[1];

    setState(() {
      sendLoading = true;
    });

    try {
      TaskSnapshot snapshot = await FirebaseStorage.instance.ref().child('chat').child('messages').child("$fileName.$ext").putFile(File(file.path));
      String fullPath = await snapshot.ref.getDownloadURL();

      FirebaseDatabase database = FirebaseDatabase.instance;
      DatabaseReference ref = database.ref('chat/messages');
      DatabaseReference newMessageRef = ref.push();

      Map<String, dynamic> message = _buildMessage();
      message["file"] = fullPath;

      await newMessageRef.set(message);
    } catch (e) {}
    finally {
      setState(() {
        sendLoading = false;
      });
    }
  }

  sendMessage() async {
    setState(() {
      sendLoading = true;
    });

    try {
      FirebaseDatabase database = FirebaseDatabase.instance;
      DatabaseReference ref = database.ref('chat/messages');
      DatabaseReference newMessageRef = ref.push();

      Map<String, dynamic> message = _buildMessage();
      message["text"] = inputValue;

      await newMessageRef.set(message);

      FocusScope.of(context).unfocus();
      controller.clear();
      onChangeText("");
    } catch (e) {}
    finally {
      setState(() {
        sendLoading = false;
      });
    }
  }

  onChangeText(String value) {
    setState(() {
      inputValue = value;
    });
  }

  onSubmitted(String value) {
    sendMessage();
  }

  @override
  Widget build(BuildContext context) {
    IconButton cameraButton = IconButton(
      onPressed: () {
        takePicture(ImageSource.camera, context);
      },
      icon: const Icon(Icons.camera_alt)
    );

    TextField input = TextField(
      controller: controller,
      onChanged: onChangeText,
      keyboardType: TextInputType.multiline,
      decoration: const InputDecoration(
        border: InputBorder.none,
        hintText: "Enviar uma mensagem",
        hintStyle: TextStyle(color: Colors.grey),
      ),
      onSubmitted: onSubmitted,
      maxLines: 5,
    );

    IconButton sendButton = IconButton(
        onPressed: inputValue.isEmpty ? null : sendMessage,
        disabledColor: Colors.grey,
        icon: const Icon(Icons.send),
    );

    Padding inputContainer = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: input,
    );

    List<Widget> inputElements = [cameraButton, Expanded(child: inputContainer), sendButton];

    Expanded loaderContainer = const Expanded(child: Loader());

    Row row = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: sendLoading ? [loaderContainer] : inputElements,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: row,
    );
  }
}
