import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:meetroom/services/auth.dart';
import 'package:meetroom/teacherScreens/view_Students.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../shared/constants.dart';

class SubjectInfo extends StatefulWidget {
  final bool isStudent;
  final String subjectCode;
  final String name;
  final String teacher;
  final String email;
  const SubjectInfo({
    Key? key,
    required this.isStudent,
    required this.name,
    required this.teacher,
    required this.subjectCode,
    required this.email,
  }) : super(key: key);

  @override
  State<SubjectInfo> createState() => _SubjectInfoState();
}

class _SubjectInfoState extends State<SubjectInfo> {
  final AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: kBlack,
      appBar: AppBar(
        backgroundColor: kBlack,
        elevation: 0,
        //back Button
        leading: Builder(
          builder: (context) => GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back_ios_new)),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20),
            child: Center(
              child: Text('Subject Details',
                  style: kBodyText.copyWith(
                      color: kWhite,
                      fontSize: 30,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Share.share(
                      'Enroll yourself in ${widget.name} in MeetRoom using code: ${widget.subjectCode}',
                      subject: 'Enroll subject in MeetRoom');
                },
                child: Container(
                  width: size.width * 0.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors
                        .primaries[Random().nextInt(Colors.primaries.length)]
                        .withOpacity(0.3),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Subject Code:',
                                style: kBodyText.copyWith(
                                    color: kGrey, fontSize: 13),
                              ),
                              Text(
                                widget.subjectCode,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                style: kBodyText.copyWith(
                                  fontSize: 18,
                                ),
                              ),
                            ]),
                        Icon(
                          Icons.share,
                          color: kWhite,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Container(
                width: size.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors
                      .primaries[Random().nextInt(Colors.primaries.length)]
                      .withOpacity(0.3),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Subject Name:',
                          style: kBodyText.copyWith(color: kGrey, fontSize: 13),
                        ),
                        Text(
                          widget.name,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: kBodyText.copyWith(
                            fontSize: 18,
                          ),
                        ),
                      ]),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Container(
                width: size.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors
                      .primaries[Random().nextInt(Colors.primaries.length)]
                      .withOpacity(0.3),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isStudent ? "Teacher's Name:" : "Your Name:",
                          style: kBodyText.copyWith(color: kGrey, fontSize: 13),
                        ),
                        Text(
                          widget.teacher,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: kBodyText.copyWith(
                            fontSize: 18,
                          ),
                        ),
                      ]),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: GestureDetector(
                onTap: widget.isStudent
                    ? () async {
                        final Uri emailLaunchUri = Uri(
                          scheme: 'mailto',
                          path: 'admin@meetroom.com',
                        );

                        await launchUrl(emailLaunchUri);
                      }
                    : () {},
                child: Container(
                  width: size.width * 0.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors
                        .primaries[Random().nextInt(Colors.primaries.length)]
                        .withOpacity(0.3),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.isStudent
                                    ? "Teacher's Email:"
                                    : "Your Mail:",
                                style: kBodyText.copyWith(
                                    color: kGrey, fontSize: 13),
                              ),
                              Text(
                                widget.email,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                style: kBodyText.copyWith(
                                  fontSize: 18,
                                ),
                              ),
                            ]),
                        widget.isStudent
                            ? Icon(
                                Icons.mail,
                                color: kWhite,
                              )
                            : const SizedBox()
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: !widget.isStudent,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => ViewStudents(
                          subjectCode: widget.subjectCode,
                        ));
                  },
                  child: Container(
                    width: size.width * 0.9,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors
                          .primaries[Random().nextInt(Colors.primaries.length)]
                          .withOpacity(0.3),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Students:',
                                  style: kBodyText.copyWith(
                                      color: kGrey, fontSize: 13),
                                ),
                                StreamBuilder<dynamic>(
                                    stream: FirebaseFirestore.instance
                                        .collection('subjects')
                                        .doc(widget.subjectCode)
                                        .snapshots(),
                                    builder: (_, snapshot) {
                                      if (!snapshot.hasData) {
                                        return SpinKitCircle(
                                          color: kPrimaryColor,
                                          size: 13,
                                        );
                                      } else {
                                        return Text(
                                          snapshot.data['totalStudents']
                                              .toString(),
                                          style: kBodyText.copyWith(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        );
                                      }
                                    }),
                              ]),
                          Icon(
                            Icons.view_list,
                            color: kWhite,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Container(
                width: size.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors
                      .primaries[Random().nextInt(Colors.primaries.length)]
                      .withOpacity(0.3),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Classes:',
                          style: kBodyText.copyWith(color: kGrey, fontSize: 13),
                        ),
                        StreamBuilder<dynamic>(
                            stream: FirebaseFirestore.instance
                                .collection('subjects')
                                .doc(widget.subjectCode)
                                .snapshots(),
                            builder: (_, snapshot) {
                              if (!snapshot.hasData) {
                                return SpinKitCircle(
                                  color: kPrimaryColor,
                                  size: 13,
                                );
                              } else {
                                return Text(
                                  snapshot.data['totalClasses'].toString(),
                                  style: kBodyText.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                );
                              }
                            }),
                      ]),
                ),
              ),
            ),
          ),
          Visibility(
            visible: widget.isStudent,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Container(
                  width: size.width * 0.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors
                        .primaries[Random().nextInt(Colors.primaries.length)]
                        .withOpacity(0.3),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Attended:',
                            style:
                                kBodyText.copyWith(color: kGrey, fontSize: 13),
                          ),
                          StreamBuilder<dynamic>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(_auth.getCurrentUser())
                                  .collection('subjects')
                                  .doc(widget.subjectCode)
                                  .snapshots(),
                              builder: (_, snapshot) {
                                if (!snapshot.hasData) {
                                  return SpinKitCircle(
                                    color: kPrimaryColor,
                                    size: 13,
                                  );
                                } else {
                                  return Text(
                                    snapshot.data['attended'].toString(),
                                    style: kBodyText.copyWith(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  );
                                }
                              }),
                        ]),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Container(
                width: size.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors
                      .primaries[Random().nextInt(Colors.primaries.length)]
                      .withOpacity(0.3),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Assignments:',
                          style: kBodyText.copyWith(color: kGrey, fontSize: 13),
                        ),
                        StreamBuilder<dynamic>(
                            stream: FirebaseFirestore.instance
                                .collection('subjects')
                                .doc(widget.subjectCode)
                                .snapshots(),
                            builder: (_, snapshot) {
                              if (!snapshot.hasData) {
                                return SpinKitCircle(
                                  color: kPrimaryColor,
                                  size: 13,
                                );
                              } else {
                                return Text(
                                  snapshot.data['totalAssignments'].toString(),
                                  style: kBodyText.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                );
                              }
                            }),
                      ]),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Container(
                width: size.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors
                      .primaries[Random().nextInt(Colors.primaries.length)]
                      .withOpacity(0.3),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Quizzes:',
                          style: kBodyText.copyWith(color: kGrey, fontSize: 13),
                        ),
                        StreamBuilder<dynamic>(
                            stream: FirebaseFirestore.instance
                                .collection('subjects')
                                .doc(widget.subjectCode)
                                .snapshots(),
                            builder: (_, snapshot) {
                              if (!snapshot.hasData) {
                                return SpinKitCircle(
                                  color: kPrimaryColor,
                                  size: 13,
                                );
                              } else {
                                return Text(
                                  snapshot.data['totalQuizzes'].toString(),
                                  style: kBodyText.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                );
                              }
                            }),
                      ]),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          )
        ]),
      ),
    );
  }
}
