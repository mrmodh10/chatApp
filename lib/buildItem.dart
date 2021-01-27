import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
Widget buildItem(int index, DocumentSnapshot document,String id,List<QueryDocumentSnapshot> listMessage,peerAvatar,userImage) {
  if (document.data()['idFrom'] == id){
    // Right (my message)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: <Widget>[
            document.data()['type'] == 0
            // Text
                ? Container(
              child: Text(
                document.data()['content'],
                style: TextStyle(color:Colors.white),
              ),
              padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
              width: 200.0,
              decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8.0)),
              margin: EdgeInsets.only(
                  bottom: isLastMessageRight(index,listMessage,id) ? 0.0 : 0.0,
                  right: 5.0),
            )
                : document.data()['type'] == 1
            // Image
                ? Container(
              child: FlatButton(
                child: Material(
                  child: CachedNetworkImage(
                    placeholder: (context, url) => Container(
                      child: CircularProgressIndicator(
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      width: 200.0,
                      height: 200.0,
                      padding: EdgeInsets.all(70.0),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Material(
                      child: Image.asset(
                        'images/img_not_available.jpeg',
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                      clipBehavior: Clip.hardEdge,
                    ),
                    imageUrl: document.data()['content'],
                    width: 200.0,
                    height: 200.0,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  clipBehavior: Clip.hardEdge,
                ),
                onPressed: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => FullPhoto(
                  //             url: document.data()['content'])));
                },
                padding: EdgeInsets.all(0),
              ),
              margin: EdgeInsets.only(
                  bottom: isLastMessageRight(index,listMessage,id) ? 20.0 : 10.0,
                  right: 10.0),
            )
            // Sticker
                : Container(
              child: Image.asset(
                'images/${document.data()['content']}.gif',
                width: 100.0,
                height: 100.0,
                fit: BoxFit.cover,
              ),
              margin: EdgeInsets.only(
                  bottom: isLastMessageRight(index,listMessage,id) ? 20.0 : 10.0,
                  right: 10.0),
            ),
            isLastMessageRight(index,listMessage,id)
                ? Material(
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
                imageUrl: userImage,
                width: 35.0,
                height: 35.0,
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(18.0),
              ),
              clipBehavior: Clip.hardEdge,
            )
                : Container(width: 35.0),
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5,right: 35),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              isLastMessageRight(index,listMessage,id)
                  ? Padding(
                    padding: const EdgeInsets.only(right: 5,bottom: 5),
                    child: Text(
                      DateFormat('dd MMM kk:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(document.data()['timestamp']))),
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic),
                    ),
                  )
                  : Container(),
              Padding(
                padding: const EdgeInsets.only(right: 5,bottom: 5),
                child: Text(document.data()['seen']?"seen":"delivered",style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12.0,
                    fontStyle: FontStyle.italic),),
              )
            ],
          ),
        ),

      ],
    );
  } else {
    // Left (peer message)
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            isLastMessageLeft(index,listMessage,id)
                ? Material(
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
                imageUrl: peerAvatar,
                width: 35.0,
                height: 35.0,
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(18.0),
              ),
              clipBehavior: Clip.hardEdge,
            )
                : Container(width: 35.0),
            document.data()['type'] == 0
                ? Container(
              child: Text(
                document.data()['content'],
                style: TextStyle(color: Colors.white),
              ),
              padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
              width: 200.0,
              decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(8.0)),
              margin: EdgeInsets.only(left: 10.0,bottom: 10),
            )
                : document.data()['type'] == 1
                ? Container(
              child: FlatButton(
                child: Material(
                  child: CachedNetworkImage(
                    placeholder: (context, url) => Container(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue),
                      ),
                      width: 200.0,
                      height: 200.0,
                      padding: EdgeInsets.all(70.0),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(
                          Radius.circular(8.0),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        Material(
                          child: Image.asset(
                            'images/img_not_available.jpeg',
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                          clipBehavior: Clip.hardEdge,
                        ),
                    imageUrl: document.data()['content'],
                    width: 200.0,
                    height: 200.0,
                    fit: BoxFit.cover,
                  ),
                  borderRadius:
                  BorderRadius.all(Radius.circular(8.0)),
                  clipBehavior: Clip.hardEdge,
                ),
                onPressed: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => FullPhoto(
                  //             url: document.data()['content'])));
                },
                padding: EdgeInsets.all(0),
              ),
              margin: EdgeInsets.only(left: 10.0),
            )
                : Container(
              child: Image.asset(
                'images/${document.data()['content']}.gif',
                width: 100.0,
                height: 100.0,
                fit: BoxFit.cover,
              ),
              margin: EdgeInsets.only(
                  bottom: isLastMessageRight(index,listMessage,id) ? 20.0 : 10.0,
                  right: 10.0),
            ),
          ],
        ),
        // Time
        isLastMessageLeft(index,listMessage,id)
            ? Container(
          child: Text(
            DateFormat('dd MMM kk:mm').format(
                DateTime.fromMillisecondsSinceEpoch(
                    int.parse(document.data()['timestamp']))),
            style: TextStyle(
                color: Colors.grey,
                fontSize: 12.0,
                fontStyle: FontStyle.italic),
          ),
          margin: EdgeInsets.only(left: 50.0, bottom: 5.0),
        )
            : Container()
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }
}

bool isLastMessageLeft(int index,List<QueryDocumentSnapshot> listMessage,String id) {
  if ((index > 0 &&
      listMessage != null &&
      listMessage[index - 1].data()['idFrom'] == id) ||
      index == 0) {
    return true;
  } else {
    return false;
  }
}

bool isLastMessageRight(int index,List<QueryDocumentSnapshot> listMessage,String id) {
  if ((index > 0 &&
      listMessage != null &&
      listMessage[index - 1].data()['idFrom'] != id) ||
      index == 0) {
    return true;
  } else {
    return false;
  }
}