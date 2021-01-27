import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/sendNotification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chatScreen.dart';
class ListOfUserOriginal extends StatefulWidget {
  @override
  _ListOfUserOriginalState createState() => _ListOfUserOriginalState();
}

class _ListOfUserOriginalState extends State<ListOfUserOriginal> {
  String id;
  List<QueryDocumentSnapshot> userList;
  String currentName;
  String currentImage;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text("List of User"),
      ),
        body: Container(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot){
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if(snapshot.data.documents.length<=0){
                return Center(
                  child:Text('No data found'),
                );
              }
              else{
                return ListView.builder(
                  padding: EdgeInsets.all(10.0),
                  itemBuilder: (context, index) => buildItem(context, snapshot.data.documents[index]),
                  itemCount: snapshot.data.documents.length,
                );
              }
            },
          ),
        ),
    );
  }

  buildItem(context,DocumentSnapshot document){
    return InkWell(
        onTap: () async{
          // final QuerySnapshot result = await Firestore.instance.collection('messages').where('id', isEqualTo: '123').getDocuments();
          // final List <DocumentSnapshot> documents = result.documents;
          // if (documents.length == 0) {
          //   // Update data to server if new user
          //   Firestore.instance.collection('messages').document('123').setData(
          //       { 'hello':'mohitt' });
          // }
          Navigator.pushReplacement(
              context,
              new MaterialPageRoute(
                  builder: (BuildContext context) =>
                  new ChatScreen(peerId:document.data()['id'],peerAvatar:document.data()['photoUrl'],id: id,name:document.data()['nickname'],)));
        },
        child: id!=document.data()['id']?
        Card(
            elevation: 10,
            child:
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  Material(
                    child: CachedNetworkImage(
                      placeholder: (context, url) => Container(
                        child: CircularProgressIndicator(
                          strokeWidth: 1.0,
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                        width: 35.0,
                        height: 35.0,
                        padding: EdgeInsets.all(10.0),
                      ),
                      imageUrl:document.data()['photoUrl'],
                      width: 35.0,
                      height: 35.0,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(18.0),
                    ),
                    clipBehavior: Clip.hardEdge,
                  ),
                  SizedBox(width: 10,),
                  Text(document.data()['nickname'],style: TextStyle(color:Colors.blue,fontWeight: FontWeight.bold),),
                ],
              ),
            )):Container());
  }
  fetchData() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString('id');
    currentName = preferences.getString('name');
    currentImage = preferences.getString('userImage');
    setState(() {});
  }
}
