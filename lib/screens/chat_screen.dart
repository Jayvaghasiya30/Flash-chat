

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = Firestore.instance;
  final messageTextController = TextEditingController();
  String mssgtext;
  String loginuser;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getuser();
  }

  void getuser() async{
    try{
      final user = await _auth.currentUser;
      print(user.email);
      loginuser = user.email;
    }
    catch(e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
               _auth.signOut();
               Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder <QuerySnapshot>(
              stream: _firestore.collection('messeges').snapshots(),
                builder: (context , snapshot) {
                final messgs = snapshot.data.docs.reversed;
                if(!snapshot.hasData){
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.blueAccent,
                    ),
                  );
                }
                List<Messagebubble> messgtextwedgit =[];
                for(var messege in messgs){

                  final mstext = messege.data()['text'];
                  final mssender = messege.data()['sender'];

                  final messagewidget = Messagebubble(
                      sender: mssender,
                      text: mstext,
                      isMe: mssender == loginuser,
                  );
                  messgtextwedgit.add(messagewidget);
                }
                  return Expanded(
                    child: ListView(
                      reverse: true,
                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
                    children: messgtextwedgit,
                    ),
                  );
                },

            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        mssgtext = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                     _firestore.collection('messeges').add({
                       'text': mssgtext,
                       'sender': loginuser,
                     });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Messagebubble extends StatelessWidget {
  Messagebubble({this.sender,this.text,this.isMe});
  String sender;
  String text;
  bool isMe;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text("from $sender",
          style: TextStyle(
            fontSize: 15,
            color: Colors.black54,
          ),),
          Material(
            borderRadius: isMe ? BorderRadius.only(topLeft: Radius.circular(30),bottomLeft: Radius.circular(30),bottomRight:  Radius.circular(30) )
            : BorderRadius.only(topRight: Radius.circular(30),bottomLeft: Radius.circular(30),bottomRight:  Radius.circular(30) ),
            elevation: 5,
            color: isMe ? Colors.blueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10 ,vertical: 20),
              child: Text(
                '$text',
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
