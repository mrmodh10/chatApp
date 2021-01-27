import 'dart:async';
import 'dart:io';
import 'package:chatapp/getDataFromShared.dart';
import 'package:chatapp/sendNotification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'buildItem.dart';

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerAvatar;
  final String id;
  final String name;
  ChatScreen({Key key, @required this.peerId, @required this.peerAvatar,this.id,this.name})
      : super(key: key);

  @override
  State createState() =>
      ChatScreenState(peerId: peerId, peerAvatar: peerAvatar);
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState({Key key, @required this.peerId, @required this.peerAvatar});
  String peerId;
  String peerAvatar;
  String id;
  String userImage;
  List<QueryDocumentSnapshot> listMessage = new List.from([]);
  int _limit = 20;
  final int _limitIncrement = 20;
  String groupChatId;
  SharedPreferences prefs;
  File imageFile;
  bool isLoading;
  bool isShowSticker;
  String imageUrl;
  String fcmToken;
  String frontUserId;
  String frontUserStatus;
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  _scrollListener() {
    if (listScrollController.offset >=
        listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      print("reach the bottom");
      setState(() {
        print("reach the bottom");
        _limit += _limitIncrement;
      });
    }
    if (listScrollController.offset <=
        listScrollController.position.minScrollExtent &&
        !listScrollController.position.outOfRange) {
      print("reach the top");
      setState(() {
        print("reach the top");
      });
    }
  }

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);
    listScrollController.addListener(_scrollListener);
    id = widget.id;
    isLoading = false;
    isShowSticker = false;
    imageUrl = '';
    groupChatId = "";
    readLocal();
    getOtherUserFcmToken(widget.name);
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    userImage = prefs.getString("userImage");
    if (id.hashCode <= peerId.hashCode) {
      groupChatId = '$id-$peerId';
    } else {
      groupChatId = '$peerId-$id';
    }
    FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .update({'chattingWith': peerId});
    _readed();
    setState(() {});
  }

  // Future getImage() async {
  //   ImagePicker imagePicker = ImagePicker();
  //   PickedFile pickedFile;
  //
  //   pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
  //   imageFile = File(pickedFile.path);
  //
  //   if (imageFile != null) {
  //     setState(() {
  //       isLoading = true;
  //     });
  //     uploadFile();
  //   }
  // }

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

 // Future uploadFile() async {
  //  String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    // StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    // StorageUploadTask uploadTask = reference.putFile(imageFile);
    // StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
  //   storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
  //     imageUrl = downloadUrl;
  //     setState(() {
  //       isLoading = false;
  //       onSendMessage(imageUrl, 1);
  //     });
  //   }, onError: (err) {
  //     setState(() {
  //       isLoading = false;
  //     });
  //     Fluttertoast.showToast(msg: 'This file is not an image');
  //   });
  // }

  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();
      var documentReference = FirebaseFirestore.instance
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          {
            'idFrom': id,
            'idTo': peerId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type,
            'seen':false
          },
        );
      }).whenComplete(() async{
        print("hello");
        sendMessage(content,fcmToken);
        int count = 1;
        for(int i=0;i<listMessage.length;i++){
          if(!listMessage[i].data()['seen']){
            count = count+1;
          }
        }
        print(count);
        print(id);
        DocumentSnapshot temp = await FirebaseFirestore.instance.collection('messages').
        doc(groupChatId).get();
        if(temp.data()==null){
          await FirebaseFirestore.instance.collection('messages').
          doc(groupChatId).setData({
            frontUserId:count.toString(),
            id:'0',
            'ids':[frontUserId,id],
            'time':DateTime.now().millisecondsSinceEpoch.toString(),
            'user1':widget.name,
            'user2':await getCurrentUserName(),
            'user1Image':peerAvatar,
            'user2Image':await getCurrentUserImage()
          });
        }
        else{
          await FirebaseFirestore.instance.collection('messages').
          doc(groupChatId).update({
            frontUserId:count.toString(),
            id:'0',
            'ids':[frontUserId,id],
            'time':DateTime.now().millisecondsSinceEpoch.toString(),
            'user1':widget.name,
            'user2':await getCurrentUserName(),
            'user1Image':peerAvatar,
            'user2Image':await getCurrentUserImage()
          });
        }
        setState(() {});
      });
      listScrollController.animateTo(0.0,duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(
          msg: 'Nothing to send',
          backgroundColor: Colors.black,
          textColor: Colors.red);
    }
  }

  Future<bool> onBackPress() {
    Navigator.pop(context);
    return Future.value(true);
    // if (isShowSticker) {
    //   setState(() {
    //     isShowSticker = false;
    //   });
    // } else {
    //   FirebaseFirestore.instance
    //       .collection('users')
    //       .doc(id)
    //       .update({'chattingWith': null});
    //   Navigator.pop(context);
    // }
    //
    // return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          titleSpacing:0,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.name,
                  style: TextStyle(color:Color(0xFAEBEFFF), fontWeight: FontWeight.bold),
                ),
              ),
              frontUserStatus!=null?Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  frontUserStatus??"",
                  style: TextStyle(color:Color(0xFAEBEFFF),fontSize: 12),textAlign: TextAlign.left,
                ),
              ):Container()
            ],
          ),
          centerTitle: false,
        ),
        body: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                // List of messages
                buildListMessage(),

                // Sticker
                (isShowSticker ? buildSticker() : Container()),

                // Input content
                buildInput(),
              ],
            ),

            // Loading
            buildLoading()
          ],
        ),
      ),
      onWillPop: onBackPress,
    );
  }

  Widget buildSticker() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi1', 2),
                child: Image.asset(
                  'images/mimi1.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi2', 2),
                child: Image.asset(
                  'images/mimi2.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi3', 2),
                child: Image.asset(
                  'images/mimi3.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi4', 2),
                child: Image.asset(
                  'images/mimi4.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi5', 2),
                child: Image.asset(
                  'images/mimi5.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi6', 2),
                child: Image.asset(
                  'images/mimi6.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi7', 2),
                child: Image.asset(
                  'images/mimi7.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi8', 2),
                child: Image.asset(
                  'images/mimi8.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi9', 2),
                child: Image.asset(
                  'images/mimi9.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
          color: Colors.white),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading ? CircularProgressIndicator() : Container(),
    );
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.image),
                onPressed: (){},
                color: Colors.deepOrange,
              ),
            ),
            color: Colors.white,
          ),
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.face),
                onPressed: getSticker,
                color: Colors.deepOrange,
              ),
            ),
            color: Colors.white,
          ),

          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                onSubmitted: (value) {
                  onSendMessage(textEditingController.text, 0);
                },
                style: TextStyle(color: Colors.grey[700], fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                focusNode: focusNode,
              ),
            ),
          ),

          // Button send message
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text, 0),
                color: Colors.green,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
          color: Colors.white),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId == ''
          ? Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)))
          : StreamBuilder(
        stream: FirebaseFirestore.instance.collection('messages')
            .doc(groupChatId)
            .collection(groupChatId)
            .orderBy('timestamp', descending: true)
            .limit(_limit)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.blue)));
          } else {
            _readed();
            listMessage = [];
            listMessage.addAll(snapshot.data.documents);
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) =>
                  buildItem(index, snapshot.data.documents[index],id,listMessage,peerAvatar,userImage),
              itemCount: snapshot.data.documents.length,
              reverse: true,
              controller: listScrollController,
            );
          }
        },
      ),
    );
  }
  Future _readed() async {
    var respectsQuery = Firestore.instance
        .collection('messages')
        .document(groupChatId)
        .collection(groupChatId)
        .where("idTo", isEqualTo: id)
        .where("seen", isEqualTo: false);
    QuerySnapshot querySnapshot = await respectsQuery.getDocuments();
    print(querySnapshot.documents.length);
    for (int i = 0; i < querySnapshot.documents.length; i++) {
      Firestore.instance
          .collection("messages")
          .document(groupChatId)
          .collection(groupChatId)
          .document(querySnapshot.documents[i].documentID)
          .updateData({"seen": true});
    }
    //update notification count
    await FirebaseFirestore.instance.collection('messages').
    doc(groupChatId).update({
      id:'0',
    });
  }
  getOtherUserFcmToken(frontUserName) async{
    print(frontUserName);
    final QuerySnapshot result = await Firestore.instance.collection('users').where('nickname', isEqualTo:frontUserName).getDocuments();
    final DocumentSnapshot documents = result.documents[0];
    print(documents.data());
    frontUserId = documents.data()['id'];
    fcmToken = documents.data()['fcm'];
    frontUserStatus = documents.data()['status'];
    setState(() {});
  }
}