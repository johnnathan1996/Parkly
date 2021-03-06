import 'package:Parked/script/changeDate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:Parked/constant.dart';
import 'package:Parked/pages/maps.dart';
import 'package:Parked/setup/logIn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:Parked/setup/globals.dart' as globals;
import 'package:rxdart/subjects.dart';
import 'package:intl/date_symbol_data_local.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Streams are created so that app can respond to notification-related events since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

NotificationAppLaunchDetails notificationAppLaunchDetails;

int unreadedMessage = 0;

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });
}

Future<void> main() async {
  var delegate = await LocalizationDelegate.create(
      fallbackLocale: 'en', supportedLocales: ['nl', 'fr', 'en']);

  WidgetsFlutterBinding.ensureInitialized();

  notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {
        didReceiveLocalNotificationSubject.add(ReceivedNotification(
            id: id, title: title, body: body, payload: payload));
      });
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      print('notification payload: ' + payload);
    }
    selectNotificationSubject.add(payload);
  });

  FirebaseAuth.instance.currentUser().then((e) {
    Firestore.instance
        .collection('users')
        .document(e.uid)
        .snapshots()
        .listen((snapshot) {
      Firestore.instance
          .collection('conversation')
          .where('userInChat', arrayContains: e.uid)
          .snapshots()
          .listen((snapshots) {
        snapshots.documents.forEach((element) {
          if (element.data["chat"].length != 0) {
            if (element.data["seenLastMessage"] == false &&
                element.data["chat"].last["auteur"] !=
                    snapshot.data["voornaam"]) {
              unreadedMessage++;
            }
          }
        });

        globals.notifications = unreadedMessage;
        unreadedMessage = 0;
      });
       

      checkReservations(e.uid);

      checkMessages(snapshot.data["voornaam"], e.uid);
      
     
    });
  }).catchError((onError) {
    print(onError);
  });

  initializeDateFormatting().then((_) => runApp(LocalizedApp(
      delegate,
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: new MyApp(),
      ))));
}

void checkMessages(String sendName, String uid) async {
  Firestore.instance
      .collection("conversation")
      .where("userInChat", arrayContains: uid)
      .snapshots()
      .listen((value) {
    value.documentChanges.forEach((snapshot) {
      if (snapshot.document.data["chat"].length != 0) {
        if (snapshot.document.data["seenLastMessage"] == false &&
            snapshot.document.data["chat"].last["auteur"] != sendName) {
          var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
            'com.example.parkly',
            'Parked',
            'Your channel description',
            playSound: true,
            enableVibration: true,
            importance: Importance.Max,
            priority: Priority.High,
          );
          var iOSPlatformChannelSpecifics = IOSNotificationDetails();
          var platformChannelSpecifics = NotificationDetails(
              androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
          flutterLocalNotificationsPlugin.show(
            0,
            snapshot.document.data["chat"].last['auteur'],
            snapshot.document.data["chat"].last['message'],
            platformChannelSpecifics,
            payload: 'item x',
          );
        }
        FlutterAppBadger.updateBadgeCount(globals.notifications);
      }
    });
  });
  
}

void checkReservations(String uid) async {
  Firestore.instance
      .collection("reservaties")
      .where("eigenaar", isEqualTo: uid)
      .snapshots()
      .listen((value) {
    value.documentChanges.forEach((snapshot) {

      if(snapshot.document.data["status"] == 1){
        var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
            'com.example.parkly',
            'Parked',
            'Your channel description',
            playSound: true,
            enableVibration: true,
            importance: Importance.Max,
            priority: Priority.High,
          );
          var iOSPlatformChannelSpecifics = IOSNotificationDetails();
          var platformChannelSpecifics = NotificationDetails(
              androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
          flutterLocalNotificationsPlugin.show(
            0,
            "Nieuwe reservering",
            "Bevestig alstublieft " + changeDate(snapshot.document.data["begin"].toDate()),
            platformChannelSpecifics,
            payload: 'item x',
          );
      }
          
    });
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void getCurrentUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user != null) {
      if (this.mounted) {
        setState(() {
          globals.userId = user.uid;
        });
      }
    } else {
      if (this.mounted) {
        setState(() {
          globals.userId = null;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: Blauw,
          accentColor: Zwart,
          fontFamily: "Montserrat",
          scaffoldBackgroundColor: LichtGrijs,
          canvasColor: Wit),
      home: checkUser(),
    );
  }

  checkUser() {
    if (globals.userId != null) {
      return MapsPage();
    } else {
      return LogInPage();
    }
  }
}
