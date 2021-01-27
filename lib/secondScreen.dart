import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/allUsers.dart';
import 'package:chatapp/sendNotification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hardware_buttons/hardware_buttons.dart' as HardwareButtons;

import 'chatScreen.dart';
class ListOfUser extends StatefulWidget {
  @override
  _ListOfUserState createState() => _ListOfUserState();
}

class _ListOfUserState extends State<ListOfUser> {
  String id;
  List<QueryDocumentSnapshot> userList;
  String currentName;
  String currentImage;
  StreamSubscription<HardwareButtons.HomeButtonEvent> _homeButtonSubscription;
  StreamSubscription<HardwareButtons.LockButtonEvent> _lockButtonSubscription;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
    _homeButtonSubscription = HardwareButtons.homeButtonEvents.listen((event) {
      try{
        Firestore.instance.collection('users').document(id).update(
            {'status':'last seen on '+DateFormat('dd-MM HH:mm').format(DateTime.now())});
      }
      catch(e){
        Firestore.instance.collection('users').document(id).update(
            {'status':'last seen on'+DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())});
      }
    });

    _lockButtonSubscription = HardwareButtons.lockButtonEvents.listen((event) {
      try{
        Firestore.instance.collection('users').document(id).update(
            {'status':'online'});
      }
      catch(e){
        Firestore.instance.collection('users').document(id).set(
            {'status':'online'});
      }
    });
  }
  @override
  void dispose() {
    super.dispose();
    _homeButtonSubscription?.cancel();
    _lockButtonSubscription?.cancel();
  }
  @override
  Widget build(BuildContext context) {
    if(id!=null){
      changeUserStatus();
    }
    return WillPopScope(
      onWillPop: (){
        try{
          Firestore.instance.collection('users').document(id).update(
              {'status':'last seen on '+DateFormat('dd-MM HH:mm').format(DateTime.now())});
          exit(0);
        }
        catch(e){
          Firestore.instance.collection('users').document(id).update(
              {'status':'last seen on'+DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())});
          exit(0);
        }
      },
      child: Scaffold(
        body: Container(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('messages').where('ids',arrayContains:id).orderBy("time",descending: true).snapshots(),
            builder: (context,AsyncSnapshot<QuerySnapshot> snapshot){
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
                  function();
                return ListView.builder(
                  padding: EdgeInsets.all(10.0),
                  itemBuilder: (context, index) => buildItem(context, snapshot.data.documents[index]),
                  itemCount: snapshot.data.documents.length,
                );
              }
            },
          ),
        ),
          floatingActionButton: new FloatingActionButton(
              elevation: 0.0,
              child: new Icon(Icons.add),
              backgroundColor: Colors.blue,
              onPressed: (){
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (BuildContext context) =>
                        new ListOfUserOriginal()));
              }
          )
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
        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (BuildContext context) =>
                new ChatScreen(peerId:document.data()['ids'][0]==id?document.data()['ids'][1]:document.data()['ids'][0],peerAvatar:document.data()['user1Image']==currentImage?document.data()['user2Image']:document.data()['user1Image'],id: id,name:document.data()['user1']==currentName?document.data()['user2']:document.data()['user1'],)));
      },
        child: id!=document.data()['id']?
        Card(
          elevation: 10,
            child:
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
                      imageUrl:document.data()['user1Image']==currentImage?document.data()['user2Image']:document.data()['user1Image'],
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
                  Text(document.data()['user1']==currentName?document.data()['user2']:document.data()['user1'],style: TextStyle(color:Colors.blue,fontWeight: FontWeight.bold),),
                ],
              ),
              document.data()[id]==null||document.data()[id]=="0"?Container():Container(
                width: 25,
                height: 25,
                child: Center(child: Text(document.data()[id],style: TextStyle(color: Colors.white),)),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue),
              )
            ],
          ),
        )):Container());
  }
  function() async{
    QuerySnapshot messagesList = await FirebaseFirestore.instance.collection('messages').where('ids',arrayContains: id).orderBy("time",descending: true).get();
    for(int i=0;i<messagesList.documents.length;i++){
      print(messagesList.documents[i].data()['user1']);
    }
    // print(messagesList.documents[0].data());
    // for(int i=0;i<userList.length;i++){
    //
    // }
  }
  fetchData() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString('id');
    currentName = preferences.getString('name');
    currentImage = preferences.getString('userImage');
    setState(() {});
  }
  changeUserStatus() async{
    final QuerySnapshot result = await Firestore.instance.collection('users').where('nickname', isEqualTo:currentName).getDocuments();
    final DocumentSnapshot documents = result.documents[0];
    try{
      Firestore.instance.collection('users').document(id).update(
          {'status':'online'});
    }
    catch(e){
      Firestore.instance.collection('users').document(id).set(
          {'status':'online'});
    }
  }
}
