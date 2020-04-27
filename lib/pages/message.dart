import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:parkly/constant.dart';
import 'package:parkly/localization/keys.dart';
import 'package:parkly/pages/chatPage.dart';
import 'package:parkly/script/changeDate.dart';
import 'package:parkly/ui/dot.dart';
import 'package:parkly/ui/navigation.dart';
import 'package:parkly/ui/title.dart';
import '../setup/globals.dart' as globals;
import 'package:content_placeholder/content_placeholder.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

class MessagePage extends StatefulWidget {
  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  String sendName, myName;
  int unreadedMessage = 0;

  void getSendName() {
    Firestore.instance
        .collection('users')
        .document(globals.userId)
        .snapshots()
        .listen((snapshot) {
      sendName = snapshot.data["voornaam"];
    });
  }

  void getUnreaded() async {
    Firestore.instance
        .collection('conversation')
        .where('userInChat', arrayContains: globals.userId)
        .snapshots()
        .listen((snapshot) {
      snapshot.documents.forEach((element) {
        if (element.data["seenLastMessage"] == false) {
          unreadedMessage++;
        }
      });
      FlutterAppBadger.updateBadgeCount(unreadedMessage);
      if (this.mounted) {
        setState(() {
          globals.notifications = unreadedMessage;
        });
      }
      unreadedMessage = 0;
    });
  }

  @override
  void initState() {
    getSendName();

    getUnreaded();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Zwart),
          backgroundColor: Wit,
          elevation: 0.0,
          title: Image.asset('assets/images/logo.png', height: 32),
        ),
        body: Container(
            decoration: BoxDecoration(
                image: new DecorationImage(
                    image: new AssetImage('assets/images/backgroundP.png'),
                    fit: BoxFit.cover)),
            child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection('conversation')
                  .where('userInChat', arrayContains: globals.userId)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: <Widget>[
                      TitleComponent(label: translate(Keys.Title_Message)),
                      Expanded(
                          child: ListView.builder(
                              itemCount: snapshot.data.documents.length,
                              itemBuilder: (_, index) {
                                return Card(
                                    elevation: 0,
                                    child: ListTile(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => ChatPage(
                                                    conversationID: snapshot
                                                        .data
                                                        .documents[index]
                                                        .documentID)));
                                      },
                                      title: StreamBuilder<DocumentSnapshot>(
                                          stream: Firestore.instance
                                              .collection('users')
                                              .document(
                                                  "PlEVTxX5XkhQSDu1Ya5g13ubYcm2") //TODO: changer le nom
                                              .snapshots(),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<DocumentSnapshot>
                                                  snapshots) {
                                            if (snapshots.hasData) {
                                              return Text(
                                                  snapshots.data["voornaam"]);
                                            } else {
                                              return Container();
                                            }
                                          }),
                                      leading: SizedBox(
                                          width: 80,
                                          child: StreamBuilder<
                                                  DocumentSnapshot>(
                                              stream: Firestore.instance
                                                  .collection('garages')
                                                  .document(snapshot
                                                      .data
                                                      .documents[index]
                                                      .data["garageId"])
                                                  .snapshots(),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<
                                                          DocumentSnapshot>
                                                      snapshots) {
                                                if (snapshots.hasData) {
                                                  return Image.network(
                                                      snapshots
                                                          .data['garageImg'],
                                                      fit: BoxFit.cover);
                                                } else {
                                                  return ContentPlaceholder();
                                                }
                                              })),
                                      subtitle: Row(
                                        children: <Widget>[
                                          Text(
                                              snapshot
                                                          .data
                                                          .documents[index]
                                                          .data["chat"]
                                                          .last["auteur"] ==
                                                      sendName
                                                  ? translate(
                                                          Keys.Chattext_You) +
                                                      " : "
                                                  : "",
                                              style: ChatStyle),
                                          snapshot.data.documents[index].data[
                                                      "seenLastMessage"] ==
                                                  false
                                              ? sendName !=
                                                      snapshot
                                                          .data
                                                          .documents[index]
                                                          .data["chat"]
                                                          .last["auteur"]
                                                  ? Flexible(
                                                      child: RichText(
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          strutStyle:
                                                              StrutStyle(
                                                                  fontSize:
                                                                      12.0),
                                                          text: TextSpan(
                                                            style: TextStyle(
                                                                fontSize: 14.0,
                                                                color: Zwart,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                            text: snapshot
                                                                .data
                                                                .documents[
                                                                    index]
                                                                .data["chat"]
                                                                .last["message"],
                                                          )))
                                                  : Flexible(
                                                      child: RichText(
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          strutStyle:
                                                              StrutStyle(
                                                                  fontSize:
                                                                      12.0),
                                                          text: TextSpan(
                                                            style: TextStyle(
                                                                fontSize: 14.0,
                                                                color: Grijs,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300),
                                                            text: snapshot
                                                                .data
                                                                .documents[
                                                                    index]
                                                                .data["chat"]
                                                                .last["message"],
                                                          )))
                                              : Flexible(
                                                  child: RichText(
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      strutStyle: StrutStyle(
                                                          fontSize: 12.0),
                                                      text: TextSpan(
                                                        style: TextStyle(
                                                            fontSize: 14.0,
                                                            color: Grijs,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w300),
                                                        text: snapshot
                                                            .data
                                                            .documents[index]
                                                            .data["chat"]
                                                            .last["message"],
                                                      )))
                                        ],
                                      ),
                                      trailing: snapshot.data.documents[index]
                                                  .data["seenLastMessage"] ==
                                              false
                                          ? sendName !=
                                                  snapshot
                                                      .data
                                                      .documents[index]
                                                      .data["chat"]
                                                      .last["auteur"]
                                              ? DotComponent(
                                                  number: snapshot
                                                          .data
                                                          .documents[index]
                                                          .data["chat"]
                                                          .length -
                                                      snapshot
                                                              .data
                                                              .documents[index]
                                                              .data[
                                                          "seenLastIndex"])
                                              : Text(changeDate(snapshot.data.documents[index].data["chat"].last["time"].toDate()),
                                                  style: ChatStyle)
                                          : Text(
                                              changeDate(snapshot.data.documents[index].data["chat"].last["time"].toDate()),
                                              style: ChatStyle),
                                    ));
                              }))
                    ],
                  );
                } else {
                  return CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(Blauw));
                }
              },
            )),
        drawer: Navigation(activeMes: true));
  }
}
