import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_1.dart';

import 'base.dart';

class Chat extends StatefulWidget {
  final String peerid;
  final String userid;
  final String name;
  const Chat({
    Key? key,
    required this.peerid,
    required this.userid,
    required this.name,
  }) : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final message = TextEditingController();
  Future<void> seeMsg(String peerId, String senderId) async {
    await firestore
        .collection('chat')
        .doc(peerId)
        .collection('Messages')
        .where('idFrom', isNotEqualTo: senderId)
        .where('isread', isEqualTo: false)
        .get()
        .then((value) {
      for (var doc in value.docs) {
        doc.reference.update({'isread': true});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white24,
        elevation: 0,
        leading: const CircleAvatar(
            radius: 25, backgroundImage: AssetImage('assets/Oval (3).png')),
        title: Row(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              const Text(
                'Online',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: 15,
                ),
              ),
            ],
          )
        ]),
        centerTitle: false,
        actions: const [
          Icon(
            Icons.phone,
            color: Colors.blue,
          ),
          SizedBox(
            width: 10,
          ),
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: Icon(
              Icons.video_call_rounded,
              color: Colors.blue,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map>>(
                  stream: firestore
                      .collection('chat')
                      .doc(widget.peerid)
                      .collection('Messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.lightBlueAccent,
                        ),
                      );
                    }
                    if (snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Padding(
                              padding: EdgeInsets.only(top: 30),
                              child: Icon(
                                Icons.chat_bubble_outline,
                                size: 100,
                              ),
                            ),
                            Text(
                              'Say Hello',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            )
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                        //  physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        reverse: true,
                        itemCount: snapshot.data?.docs.length,
                        itemBuilder: (context, i) {
                          seeMsg(widget.peerid, auth.currentUser!.uid);
                          final id = snapshot.data!.docs[i].data()['idFrom'];
                          final data = snapshot.data!.docs[i].data();
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Column(
                              crossAxisAlignment: id == auth.currentUser!.uid
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ChatBubble(
                                      clipper: ChatBubbleClipper1(
                                        type: id == auth.currentUser!.uid
                                            ? BubbleType.sendBubble
                                            : BubbleType.receiverBubble,
                                      ),
                                      alignment: Alignment.topRight,
                                      margin: const EdgeInsets.only(top: 20),
                                      backGroundColor: Colors.blue,
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7,
                                        ),
                                        child: Text(
                                          data['content'] ?? '',
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                    data['isread']
                                        ? Container(
                                            height: 20,
                                            width: 20,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.blueAccent,
                                              ),
                                            ),
                                            child: const Center(
                                                child: Icon(
                                              Icons.check,
                                              size: 10,
                                            )),
                                          )
                                        : Container(
                                            height: 20,
                                            width: 20,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.blueAccent,
                                              ),
                                            ),
                                          )
                                  ],
                                ),
                              ],
                            ),
                          );
                        });
                  }),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 50,
              decoration: const BoxDecoration(
                color: Colors.white54,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.menu),
                  const SizedBox(
                    width: 10,
                  ),
                  const Icon(
                    Icons.camera_alt,
                    color: Colors.blue,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Icon(
                    Icons.mic,
                    color: Colors.blue,
                  ),
                  Expanded(
                    child: Container(
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        maxLines: null,
                        controller: message,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: const InputDecoration(
                          hintText: "Aa",
                          suffixIcon: Icon(
                            Icons.emoji_emotions,
                            color: Colors.blue,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: 10,
                    child: GestureDetector(
                      onTap: () {
                        log('send1');
                        if (message.text.trim().isNotEmpty &&
                            message.text.trim() != '') {
                          log('send2');
                          Controller().sendMessage(
                            chatID: widget.peerid,
                            content: message.text,
                            myID: auth.currentUser!.uid,
                            selectedUserID: widget.userid,
                          );
                          message.clear();
                        }
                      },
                      child: const Center(
                        child: Icon(
                          Icons.send,
                          color: Colors.blue,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            )
          ],
        ),
      ),
    );
  }
}
