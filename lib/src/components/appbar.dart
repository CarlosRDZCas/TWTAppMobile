import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:two_way_transfer/src/class/listener_obj.dart';

import '../../main.dart';

class AdvancedAppBar extends StatefulWidget implements PreferredSizeWidget {
  AdvancedAppBar({Key? key, required this.datos}) : super(key: key);
  final String datos;

  @override
  _AdvancedAppBarState createState() => _AdvancedAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

List<String> listNoti = [];
StreamSubscription<QuerySnapshot>? streamSub;

class _AdvancedAppBarState extends State<AdvancedAppBar> {
  @override
  void initState() {
    super.initState();
    listenChanges();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void listenChanges() {
    getData();
    Timer.periodic(Duration(minutes: 3), (timer) {
      getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Transform.translate(
            offset: Offset(-15, 0),
            child: Container(
              height: 90,
              width: 90,
              child: Image(
                image: AssetImage(
                  "assets/images/twt.png",
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Text("Two Way Transfer",
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      actions: [
        listNoti.isEmpty
            ? Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(
                  Icons.notifications_none,
                  color: Colors.teal,
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: Icon(Icons.notifications),
                  color: Colors.red[700],
                  onPressed: () {
                    _showMyDialog(context);
                  },
                ),
              ),
      ],
    );
  }

  Widget dialog(BuildContext context) {
    return AlertDialog(
      title: Text("Nueva carta porte disponible!"),
      content: Text(
          "Tiene una nueva carta porte dispoible, Remision ${listNoti[0]} actualice para verla!"),
      actions: <Widget>[
        TextButton(
            child: Text("Aceptar"),
            onPressed: () {
              setState(() {
                listNoti.clear();
              });
              _cancelAllNotifications();
              Navigator.of(context).pop();
            }),
        TextButton(
            child: Text("Cancelar"),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ],
    );
  }

  Future<void> _showNotification() async {
    _cancelAllNotifications();
    final Int64List vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('nuevochan', 'chan',
            channelDescription: 'new',
            importance: Importance.max,
            priority: Priority.high,
            enableLights: true,
            ledColor: const Color.fromARGB(255, 255, 0, 0),
            ledOnMs: 1000,
            ledOffMs: 500,
            largeIcon: const DrawableResourceAndroidBitmap('ic_launcher'),
            sound: RawResourceAndroidNotificationSound('deduction'),
            playSound: true,
            vibrationPattern: vibrationPattern);
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Nueva Carta Porte Disponible',
      'Tiene una nueva Carta Porte Disponible!',
      platformChannelSpecifics,
    );
  }

  Future<void> _cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    streamSub!.pause();
  }

  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (_) => dialog(context),
    );
  }

  void getData() {
    CollectionReference reference =
        FirebaseFirestore.instance.collection('Notificaciones');
    streamSub = reference.snapshots().listen((querySnapshot) {
      querySnapshot.docChanges.forEach((change) {
        if (mounted) {
          var doc = ListenerObj.fromJson(change);
          if (doc.log == widget.datos) {
            String obj = doc.remision;
            setState(() {
              listNoti.add(obj);
            });
            _showNotification();
            reference.doc(change.doc.id).delete();
            streamSub!.pause();
            print(streamSub?.isPaused);
          } else {
            streamSub!.pause();
            print(streamSub?.isPaused);
          }
        }
      });
    });
  }
}
