import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';



final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

Future signInWithGoogle() async {
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final UserCredential authResult = await _auth.signInWithCredential(credential);
  final User user = authResult.user;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
   String fcmToken = await _firebaseMessaging.getToken();
   print(fcmToken);
  if (user != null) {
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final User currentUser = _auth.currentUser;
    assert(user.uid == currentUser.uid);

    final QuerySnapshot result = await Firestore.instance.collection('users').where('id', isEqualTo: user.uid).getDocuments();
    final List <DocumentSnapshot> documents = result.documents;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("id",user.uid);
    sharedPreferences.setString("name",user.displayName);
    sharedPreferences.setString("userImage",user.photoURL);
    if (documents.length == 0){
      // Update data to server if new user
      Firestore.instance.collection('users').document(user.uid).setData(
          { 'nickname': user.displayName, 'photoUrl': user.photoUrl, 'id': user.uid,'fcm':fcmToken.toString().trim()});
    }
    else{
      await Firestore.instance.collection('users').doc(user.uid).update({
       "fcm":fcmToken
      });
      //final DocumentSnapshot documents = result.documents[0];


    }
    print(user.photoURL);
    print(user);
    return user;
  }

  return null;
}
void signOutGoogle() async{
  await googleSignIn.signOut();

  print("User Signed Out");
}

