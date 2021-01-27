import 'package:chatapp/authscreen/authScreen.dart';
import 'package:chatapp/secondScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String id;
  String _message = '';
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String fcmToken;

  _register() {
    _firebaseMessaging.getToken().then((token) async{
      fcmToken = token;
      print(token);
      await Firestore.instance.collection('users').doc(id).update({
        "fcm":fcmToken
      });
    });

  }
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
    getMessage();
  }

  void getMessage(){
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print('on message $message');
          Fluttertoast.showToast(msg: 'msg');
          setState(() => _message = message["notification"]["title"]);
        }, onResume: (Map<String, dynamic> message) async {
      print('on resume $message');
      Fluttertoast.showToast(msg: 'msg');
      setState(() => _message = message["notification"]["title"]);
    }, onLaunch: (Map<String, dynamic> message) async {
      print('on launch $message');
      Fluttertoast.showToast(msg: 'msg');
      setState(() => _message = message["notification"]["title"]);
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: id!=null?ListOfUser():Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: RaisedButton(
          color: Colors.blue,
          onPressed: () async{
           final user =await signInWithGoogle();
           print(user);
           if(user!=null){
             id = user.uid;
             setState(() {});
             // Navigator.push(
             //   context,
             //   MaterialPageRoute(builder: (context) => ListOfUser(
             //   )),
             // );
           }
          },
          child: Text("Sign in with google"),
        )
      ),
    );
  }
  fetchData() async{
    await Firebase.initializeApp();
    SharedPreferences sharedPreferences  =  await SharedPreferences.getInstance();
    id = sharedPreferences.get('id');
    setState(() {});
    if(id!=null){
      _register();
    }
  }
}
