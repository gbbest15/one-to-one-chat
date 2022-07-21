import 'package:chattest/base.dart';
import 'package:chattest/chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatList extends StatefulWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Chats',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: false,
        leading: const Padding(
          padding: EdgeInsets.only(left: 3.0),
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/Oval (1).png'),
          ),
        ),
        actions: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.camera_alt,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.edit,
                  color: Colors.black,
                ),
              ),
            ),
          )
        ],
      ),
      body: WillPopScope(
        onWillPop: () => Future.value(false),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 17),
                    hintText: 'Search',
                    suffixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(20),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: SizedBox(
                height: 100,
                child: StreamBuilder<QuerySnapshot<Map>>(
                    stream: firestore
                        .collection('user')
                        .where('id', isNotEqualTo: auth.currentUser!.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.data!.docs.isEmpty) {
                        return Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.add,
                              size: 50,
                            ),
                          ),
                        );
                      }
                      if (!snapshot.hasData) {
                        return Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.add,
                              size: 50,
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                          separatorBuilder: (context, index) => const SizedBox(
                                width: 15,
                              ),
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data!.docs.length + 1,
                          itemBuilder: (context, i) {
                            if (i == 0) {
                              return Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.add,
                                    size: 50,
                                  ),
                                ),
                              );
                            }
                            final name =
                                snapshot.data!.docs[i - 1].data()['name'];
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text('${name[0]}' '${name[1]}'),
                                  ),
                                ),
                                Positioned(
                                  left: 80,
                                  bottom: 10,
                                  child: Container(
                                    height: 25,
                                    width: 25,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.white, width: 3),
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                )
                              ],
                            );
                          });
                    }),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map>>(
                  stream: firestore
                      .collection('user')
                      .where('id', isNotEqualTo: auth.currentUser!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No user yet'));
                    }
                    if (!snapshot.hasData) {
                      return Container();
                    }
                    return ListView.separated(
                        separatorBuilder: (context, index) => const SizedBox(
                              height: 15,
                            ),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, i) {
                          final name = snapshot.data!.docs[i].data()['name'];
                          final dataId = snapshot.data!.docs[i].data();
                          String idpeer = auth.currentUser!.uid.hashCode <
                                  dataId['id'].hashCode
                              ? auth.currentUser!.uid + '_' + dataId['id']
                              : dataId['id'] + '_' + auth.currentUser!.uid;

                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 30.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Chat(
                                      peerid: idpeer,
                                      userid: dataId['id'],
                                      name: dataId['name'],
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Container(
                                    height: 70,
                                    width: 70,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text('${name[0] + name[1]}'),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 30,
                                  ),
                                  SizedBox(
                                    height: 50,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        const Flexible(
                                            child: Text('You: notSetYet'))
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                    child:
                                        const Center(child: Icon(Icons.check)),
                                  )
                                ],
                              ),
                            ),
                          );
                        });
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
