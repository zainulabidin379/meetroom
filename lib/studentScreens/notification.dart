import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import '../services/auth.dart';
import '../shared/constants.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final AuthService _auth = AuthService();
  Future getNotifications() async {
    var firestore = FirebaseFirestore.instance;
    QuerySnapshot qn = await firestore
        .collection('notifications')
        .doc('notificationsData')
        .collection(_auth.getCurrentUser())
        .orderBy('timestamp', descending: true)
        .get();

    return qn.docs;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: kBlack,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kBlack,
        title: Text('Notifications', style: kBodyText.copyWith(fontSize: 20)),
        centerTitle: true,
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back_ios_new)),
        actions: [
          PopupMenuButton(
            icon: Icon(
              Icons.more_vert,
              color: kWhite,
            ),
            color: kBlack,
            padding: EdgeInsets.zero,
            onSelected: (item) {
              switch (item) {
                case 0:
                  {
                    Get.defaultDialog(
                      title: 'Mark All as Read',
                      titleStyle:
                          kBodyText.copyWith(fontWeight: FontWeight.bold),
                      backgroundColor: kBlack,
                      content: Center(
                        child: Text(
                          'Are you sure to mark all notifications as read?',
                          textAlign: TextAlign.center,
                          style: kBodyText,
                        ),
                      ),
                      titlePadding: const EdgeInsets.symmetric(vertical: 20),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 10),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text('Cancel',
                              style: kBodyText.copyWith(
                                  fontWeight: FontWeight.bold)),
                        ),
                        TextButton(
                          onPressed: () async {
                            Get.defaultDialog(
                              title: '',
                              backgroundColor: Colors.transparent,
                              barrierDismissible: false,
                              content: SpinKitCircle(
                                color: kPrimaryColor,
                                size: 50.0,
                              ),
                            );
                            await FirebaseFirestore.instance
                                .collection('notifications')
                                .doc('notificationsData')
                                .collection(_auth.getCurrentUser())
                                .get()
                                .then((snapshot) async {
                              for (var i = 0; i < snapshot.docs.length; i++) {
                                await FirebaseFirestore.instance
                                    .collection('notifications')
                                    .doc('notificationsData')
                                    .collection(_auth.getCurrentUser())
                                    .doc(snapshot.docs[i]['id'])
                                    .update({
                                  'isRead': true,
                                });
                              }
                              Get.back();
                              Get.back();
                              setState(() {});
                              Get.snackbar(
                                'Message',
                                'All notifications marked as read',
                                duration: const Duration(seconds: 3),
                                backgroundColor: kPrimaryColor,
                                colorText: kWhite,
                                borderRadius: 10,
                              );
                            });
                          },
                          child: Text('Mark as Read',
                              style: kBodyText.copyWith(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    );
                  }
                  break;
                case 1:
                  {
                    Get.defaultDialog(
                      title: 'Clear All',
                      titleStyle:
                          kBodyText.copyWith(fontWeight: FontWeight.bold),
                      backgroundColor: kBlack,
                      content: Center(
                        child: Text(
                          'Are you sure to clear all notifications?',
                          textAlign: TextAlign.center,
                          style: kBodyText,
                        ),
                      ),
                      titlePadding: const EdgeInsets.symmetric(vertical: 20),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 10),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text('Cancel',
                              style: kBodyText.copyWith(
                                  fontWeight: FontWeight.bold)),
                        ),
                        TextButton(
                          onPressed: () async {
                            Get.defaultDialog(
                              title: '',
                              backgroundColor: Colors.transparent,
                              barrierDismissible: false,
                              content: SpinKitCircle(
                                color: kPrimaryColor,
                                size: 50.0,
                              ),
                            );
                            await FirebaseFirestore.instance
                                .collection('notifications')
                                .doc('notificationsData')
                                .collection(_auth.getCurrentUser())
                                .get()
                                .then((snapshot) async {
                              for (DocumentSnapshot ds in snapshot.docs) {
                                ds.reference.delete();
                              }
                              Navigator.pop(context);
                              Navigator.pop(context);
                              setState(() {});
                              Get.snackbar(
                                'Message',
                                'All notifications cleared',
                                duration: const Duration(seconds: 3),
                                backgroundColor: kPrimaryColor,
                                colorText: kWhite,
                                borderRadius: 10,
                              );
                            });
                          },
                          child: Text('Clear',
                              style: kBodyText.copyWith(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    );
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<int>(
                  value: 0,
                  child: Text(
                    'Mark all as Read',
                    style: kBodyText,
                  )),
              PopupMenuItem<int>(
                  value: 1,
                  child: Text(
                    'Clear all',
                    style: kBodyText,
                  )),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            height: size.height * 0.8,
            width: size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                FutureBuilder<dynamic>(
                    future: getNotifications(),
                    builder: (_, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SpinKitCircle(
                          color: kPrimaryColor,
                          size: 50.0,
                        );
                      } else {
                        return Column(
                          children: [
                            if (snapshot.data.length != 0) ...[
                              for (var i = 0;
                                  i < snapshot.data.length;
                                  i++) ...{
                                notificationCard(
                                  size,
                                  snapshot.data[i]['id'],
                                  snapshot.data[i]['type'],
                                  snapshot.data[i]['subjectCode'],
                                  snapshot.data[i]['notification'],
                                  snapshot.data[i]['timestamp'],
                                  snapshot.data[i]['isRead'],
                                )
                              }
                            ] else ...[
                              SizedBox(
                                  height: size.width * 0.5,
                                  width: size.width * 0.5,
                                  child: Image.asset(
                                    'assets/icons/notification.png',
                                    color: kPrimaryColor,
                                  )),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 20.0, bottom: 10),
                                child: Text('No Notifications!',
                                    style: kBodyText.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20)),
                              ),
                            ]
                          ],
                        );
                      }
                    }),
              ],
            ),
          )),
    );
  }

  Widget notificationCard(Size size, String id, String image,
      String subjectCode, String notification, Timestamp time, bool isRead) {
    return StreamBuilder<dynamic>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.getCurrentUser())
            .collection('subjects')
            .doc(subjectCode)
            .snapshots(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          } else {
            if (snapshot.data!.exists) {
              return GestureDetector(
                onTap: () {
                  Get.defaultDialog(
                    title: image.toUpperCase(),
                    titleStyle: kBodyText.copyWith(fontWeight: FontWeight.bold),
                    backgroundColor: kBlack,
                    content: Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Text(
                        notification,
                        textAlign: TextAlign.center,
                        style: kBodyText,
                      ),
                    ),
                    titlePadding: const EdgeInsets.symmetric(vertical: 20),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 10),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Close',
                            style: kBodyText.copyWith(
                                fontWeight: FontWeight.bold)),
                      ),
                      TextButton(
                        onPressed: () async {
                          Get.defaultDialog(
                            title: '',
                            backgroundColor: Colors.transparent,
                            barrierDismissible: false,
                            content: SpinKitCircle(
                              color: kPrimaryColor,
                              size: 50.0,
                            ),
                          );
                          if (isRead) {
                            await FirebaseFirestore.instance
                                .collection('notifications')
                                .doc('notificationsData')
                                .collection(_auth.getCurrentUser())
                                .doc(id)
                                .update({'isRead': false}).then((value) {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              setState(() {});
                              Get.snackbar(
                                'Message',
                                'Notification marked as unread',
                                duration: const Duration(seconds: 3),
                                backgroundColor: kPrimaryColor,
                                colorText: kWhite,
                                borderRadius: 10,
                              );
                            });
                          } else {
                            await FirebaseFirestore.instance
                                .collection('notifications')
                                .doc('notificationsData')
                                .collection(_auth.getCurrentUser())
                                .doc(id)
                                .update({'isRead': true}).then((value) {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              setState(() {});
                              Get.snackbar(
                                'Message',
                                'Notification marked as read',
                                duration: const Duration(seconds: 3),
                                backgroundColor: kPrimaryColor,
                                colorText: kWhite,
                                borderRadius: 10,
                              );
                            });
                          }
                        },
                        child: isRead
                            ? Text('Mark as Unread',
                                style: kBodyText.copyWith(
                                    color: kRed, fontWeight: FontWeight.bold))
                            : Text('Mark as Read',
                                style: kBodyText.copyWith(
                                    color: kRed, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  width: size.width,
                  decoration: BoxDecoration(
                      color: isRead
                          ? Colors.transparent
                          : kWhite.withOpacity(0.15),
                      border: Border(
                          bottom: BorderSide(
                        color: kBlack,
                      ))),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        height: 55,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: kPrimaryColor,
                          ),
                          color: Colors.transparent,
                        ),
                        child: Image.asset(
                          "assets/icons/$image.png",
                          color: (image == 'assignment')
                              ? Colors.greenAccent
                              : (image == 'quiz')
                                  ? Colors.orange
                                  : (image == 'attendance')
                                      ? Colors.amberAccent
                                      : Colors.redAccent,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              notification,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: kBodyText.copyWith(fontSize: 14),
                            ),
                            Text(
                              DateTimeFormat.relative(time.toDate(),
                                  ifNow: 'Now', appendIfAfter: 'ago'),
                              style: kBodyText.copyWith(
                                  fontSize: 12, color: kGrey),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            } else {
              return const SizedBox();
            }
          }
        });
  }
}
