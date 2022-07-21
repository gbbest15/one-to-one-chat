import 'dart:developer';

import 'package:chattest/base.dart';
import 'package:chattest/chatList.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddUser extends StatefulWidget {
  const AddUser({Key? key}) : super(key: key);

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();

  bool runing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add user'),
      ),
      body: SafeArea(
        child: Center(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: email,
                  decoration: const InputDecoration(
                    hintText: "Email",
                    alignLabelWithHint: true,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    String pattern =
                        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                        r"{0,253}[a-zA-Z0-9])?)*$";
                    RegExp regex = RegExp(pattern);
                    if (v == null || v.isEmpty || !regex.hasMatch(v)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: "password",
                    alignLabelWithHint: true,
                  ),
                  validator: (v) {
                    if (v!.isEmpty) {
                      return "Password must 6 characters";
                    }
                    return null;
                  },
                  onChanged: (value) {},
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: name,
                  decoration: const InputDecoration(
                    hintText: "Name",
                    alignLabelWithHint: true,
                  ),
                  validator: (v) {
                    if (v!.isEmpty) {
                      return "Name is empty";
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: runing
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            try {
                              setState(() {
                                runing = true;
                              });
                              final _authenticatedUser =
                                  await auth.createUserWithEmailAndPassword(
                                      email: email.text,
                                      password: password.text);
                              if (_authenticatedUser.user != null) {
                                auth
                                    .signInWithEmailAndPassword(
                                        email: email.text,
                                        password: password.text)
                                    .then((value) {
                                  firestore
                                      .collection('user')
                                      .doc(auth.currentUser!.uid)
                                      .set({
                                    'id': auth.currentUser!.uid,
                                    'email': email.text,
                                    'password': password.text,
                                    'name': name.text
                                  }).then((value) => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const ChatList(),
                                            ),
                                          ));
                                });
                              }
                              setState(() {
                                runing = false;
                              });
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'email-already-in-use') {
                                setState(() {
                                  runing = true;
                                });
                                auth
                                    .signInWithEmailAndPassword(
                                        email: email.text,
                                        password: password.text)
                                    .then((value) {
                                  firestore
                                      .collection('user')
                                      .doc(auth.currentUser!.uid)
                                      .set({
                                    'id': auth.currentUser!.uid,
                                    'email': email.text,
                                    'password': password.text,
                                    'name': name.text
                                  }).then((value) => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const ChatList(),
                                            ),
                                          ));
                                });
                                setState(() {
                                  runing = false;
                                });
                              } else {
                                setState(() {
                                  runing = false;
                                });
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  backgroundColor: Colors.blue,
                                  content: Text(e.code.toString()),
                                  duration: const Duration(seconds: 2),
                                ));
                              }
                              log(e.toString());
                            }
                          }
                        },
                  child: runing
                      ? const CircularProgressIndicator()
                      : const Text('Add'),
                )
              ],
            ),
          ),
        )),
      ),
    );
  }
}
