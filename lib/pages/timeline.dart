import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/progress.dart';

final usersRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<dynamic> users = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //deleteUser();
    //createUser();
  }

  createUser() {
    usersRef
        .document("Just2The2WayYouAre")
        .setData({"username": "Iskhak", "postCount": 99, "isAdmin": true});
  }

  updateUser() async {
    final DocumentSnapshot doc =
        await usersRef.document("gYqaS9Yk6qMEFEpLdJkE").get();
    if (doc.exists) {
      doc.reference.updateData(
          {"username": "Hello World", "postCount": 2, "isAdmin": false});
    }
    //.updateData(
    //    {"username": "Hello World", "postCount": 2, "isAdmin": false});
  }

  deleteUser() async {
    final DocumentSnapshot doc =
        await usersRef.document("Just2The2WayYouAre").get();
    if (doc.exists) {
      doc.reference.delete();
    }
  }

  // getUserById() async {
  //   final String id = "gYqaS9Yk6qMEFEpLdJkE";
  //   final DocumentSnapshot doc = await usersRef.document(id).get();
  //   print(doc.data);
  //   print(doc.documentID);
  //   print(doc.exists);
  // }

  @override
  Widget build(context) {
    return Scaffold(
        appBar: header(context, isAppTitle: true),
        body: StreamBuilder<QuerySnapshot>(
          stream: usersRef.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress(context);
            }
            final List<Text> children = snapshot.data.documents
                .map((doc) => Text(doc['username']))
                .toList();
            return Container(
              child: ListView(
                children: children,
              ),
            );
          },
        ));
  }
}
