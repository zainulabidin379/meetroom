import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:meetroom/shared/constants.dart';
import 'package:meetroom/sharedScreens/subject_info.dart';
import 'package:meetroom/teacherScreens/choose_activity.dart';
import 'package:meetroom/teacherScreens/create_meeting.dart';
import 'package:meetroom/teacherScreens/delete_subject.dart';
import 'package:meetroom/teacherScreens/edit_announcement.dart';
import 'package:meetroom/teacherScreens/edit_assignment.dart';
import 'package:meetroom/teacherScreens/edit_attendance.dart';
import 'package:meetroom/teacherScreens/edit_quiz.dart';
import 'package:meetroom/teacherScreens/view_assignment_record.dart';
import 'package:meetroom/teacherScreens/view_attendance_record.dart';
import 'package:meetroom/teacherScreens/view_quiz_record.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:readmore/readmore.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import '../shared/download_file.dart';

class SubjectScreenTeacher extends StatefulWidget {
  final bool isStudent;
  final String subjectCode;
  final String name;
  final String teacher;
  final String email;
  const SubjectScreenTeacher({
    Key? key,
    required this.isStudent,
    required this.name,
    required this.teacher,
    required this.subjectCode,
    required this.email,
  }) : super(key: key);

  @override
  State<SubjectScreenTeacher> createState() => _SubjectScreenTeacherState();
}

class _SubjectScreenTeacherState extends State<SubjectScreenTeacher> {
  Future getSubjectData() async {
    var firestore = FirebaseFirestore.instance;
    QuerySnapshot qn = await firestore
        .collection('subjects')
        .doc(widget.subjectCode)
        .collection('data')
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
          actions: [
            GestureDetector(
              onTap: () {
                Get.to(() => DeleteSubject(
                      subjectName: widget.name,
                      subjectCode: widget.subjectCode,
                    ));
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Icon(
                  Icons.delete_outline,
                  color: kWhite,
                  size: 30,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Get.to(() => SubjectInfo(
                    isStudent: widget.isStudent,
                    subjectCode: widget.subjectCode,
                    name: widget.name,
                    teacher: widget.teacher,
                    email: widget.email,
                  )),
              child: Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Icon(
                  Icons.info_outline,
                  color: kWhite,
                  size: 30,
                ),
              ),
            )
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(
            bottom: 40,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: kPrimaryColor.withOpacity(0.5))),
                child: FloatingActionButton(
                    heroTag: 'joinMeeting',
                    backgroundColor: kBlack,
                    elevation: 15,
                    child: Icon(
                      Icons.videocam,
                      color: kPrimaryColor,
                      size: 30,
                    ),
                    onPressed: () {
                      Get.to(() => CreateMeeting(
                                subjectCode: widget.subjectCode,
                                subjectName: widget.name,
                                name: widget.teacher,
                                email: widget.email,
                              ))!
                          .then((_) async {
                        await FirebaseFirestore.instance
                            .collection('subjects')
                            .doc(widget.subjectCode)
                            .update({
                          'meeting': null,
                        });
                      });
                    }),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: kPrimaryColor.withOpacity(0.5))),
                child: FloatingActionButton(
                  heroTag: 'add',
                  backgroundColor: kBlack,
                  elevation: 15,
                  child: Icon(
                    Icons.add,
                    color: kPrimaryColor,
                    size: 30,
                  ),
                  onPressed: () {
                    Get.to(() => ChooseActivityType(
                              subjectName: widget.name,
                              teacherName: widget.teacher,
                              subjectCode: widget.subjectCode,
                            ))!
                        .then((_) {
                      setState(() {});
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          color: kPrimaryColor,
          backgroundColor: kBlack,
          triggerMode: RefreshIndicatorTriggerMode.anywhere,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                subjectHeaderCard(size),
                FutureBuilder<dynamic>(
                    future: getSubjectData(),
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
                                if (snapshot.data[i]['type'] ==
                                    'assignment') ...{
                                  (snapshot.data[i]['attachmentUploaded'])
                                      ? assignmentCard(
                                          size,
                                          snapshot.data[i]['assignmentCode'],
                                          snapshot.data[i]['assignmentNo'],
                                          snapshot.data[i]['dueDate'],
                                          snapshot.data[i]['totalMarks'],
                                          snapshot.data[i]['description'],
                                          snapshot.data[i]['attachment'],
                                          snapshot.data[i]
                                              ['attachmentExtension'],
                                          snapshot.data[i]
                                              ['attachmentUploaded'],
                                          snapshot.data[i]['fileSubmission'],
                                        )
                                      : assignmentCard(
                                          size,
                                          snapshot.data[i]['assignmentCode'],
                                          snapshot.data[i]['assignmentNo'],
                                          snapshot.data[i]['dueDate'],
                                          snapshot.data[i]['totalMarks'],
                                          snapshot.data[i]['description'],
                                          '',
                                          '',
                                          snapshot.data[i]
                                              ['attachmentUploaded'],
                                          snapshot.data[i]['fileSubmission'],
                                        )
                                } else if (snapshot.data[i]['type'] ==
                                    'quiz') ...{
                                  (snapshot.data[i]['attachmentUploaded'])
                                      ? quizCard(
                                          size,
                                          snapshot.data[i]['quizCode'],
                                          snapshot.data[i]['quizNo'],
                                          snapshot.data[i]['dueDate'],
                                          snapshot.data[i]['totalMarks'],
                                          snapshot.data[i]['description'],
                                          snapshot.data[i]['attachment'],
                                          snapshot.data[i]
                                              ['attachmentExtension'],
                                          snapshot.data[i]
                                              ['attachmentUploaded'],
                                          snapshot.data[i]['fileSubmission'],
                                        )
                                      : quizCard(
                                          size,
                                          snapshot.data[i]['quizCode'],
                                          snapshot.data[i]['quizNo'],
                                          snapshot.data[i]['dueDate'],
                                          snapshot.data[i]['totalMarks'],
                                          snapshot.data[i]['description'],
                                          '',
                                          '',
                                          snapshot.data[i]
                                              ['attachmentUploaded'],
                                          snapshot.data[i]['fileSubmission'])
                                } else if (snapshot.data[i]['type'] ==
                                    'announcement') ...{
                                  (snapshot.data[i]['attachmentUploaded'])
                                      ? announcementCard(
                                          size,
                                          snapshot.data[i]['announcementCode'],
                                          snapshot.data[i]['announcement'],
                                          snapshot.data[i]['date'],
                                          snapshot.data[i]['attachment'],
                                          snapshot.data[i]
                                              ['attachmentExtension'],
                                          snapshot.data[i]
                                              ['attachmentUploaded'],
                                        )
                                      : announcementCard(
                                          size,
                                          snapshot.data[i]['announcementCode'],
                                          snapshot.data[i]['announcement'],
                                          snapshot.data[i]['date'],
                                          '',
                                          '',
                                          snapshot.data[i]
                                              ['attachmentUploaded'],
                                        )
                                } else if (snapshot.data[i]['type'] ==
                                    'attendance') ...{
                                  attendanceCard(
                                    size,
                                    snapshot.data[i]['attendanceCode'],
                                    snapshot.data[i]['message'],
                                    snapshot.data[i]['date'],
                                    snapshot.data[i]['dueTime'],
                                  )
                                }
                              }
                            ] else ...[
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                child: SizedBox(
                                  width: 250,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 150,
                                        width: 150,
                                        child: Image.asset(
                                          'assets/icons/noSubjects.png',
                                          color: kPrimaryColor,
                                        ),
                                      ),
                                      Text(
                                        "No activity to show here!",
                                        textAlign: TextAlign.center,
                                        style: kBodyText.copyWith(fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                child: SizedBox(
                                  width: 270,
                                  child: Text(
                                    "Add subject data by pressing '+' icon in the bottom right",
                                    textAlign: TextAlign.center,
                                    style: kBodyText.copyWith(
                                        color: kGrey.withOpacity(0.5),
                                        fontSize: 15),
                                  ),
                                ),
                              )
                            ]
                          ],
                        );
                      }
                    }),
              ],
            ),
          ),
        ));
  }

  Widget subjectHeaderCard(Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Center(
        child: Container(
          width: size.width * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.primaries[Random().nextInt(Colors.primaries.length)]
                .withOpacity(0.3),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.name,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: kBodyText.copyWith(
                        fontSize: 22,
                        color: kPrimaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '(${widget.subjectCode})',
                    style: kBodyText.copyWith(color: kGrey, fontSize: 13),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5.0, vertical: 5),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.primaries[
                                Random().nextInt(Colors.primaries.length)]
                            .withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Classes: ',
                            style: kBodyText.copyWith(fontSize: 15),
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
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5.0, vertical: 5),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.primaries[
                                Random().nextInt(Colors.primaries.length)]
                            .withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Assignments: ',
                            style: kBodyText.copyWith(fontSize: 15),
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
                                    snapshot.data['totalAssignments']
                                        .toString(),
                                    style: kBodyText.copyWith(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  );
                                }
                              }),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5.0, vertical: 5),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.primaries[
                                Random().nextInt(Colors.primaries.length)]
                            .withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Quizzes: ',
                            style: kBodyText.copyWith(fontSize: 15),
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
                        ],
                      ),
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }

  Widget assignmentCard(
      Size size,
      String code,
      String number,
      Timestamp dueOn,
      String marks,
      String description,
      String attachment,
      String attachmentExtension,
      bool attachmentUploaded,
      bool isUploadable) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          width: size.width * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.greenAccent),
            color: kGrey.withOpacity(0.1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  top: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(
                      width: 40,
                    ),
                    Flexible(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Assignment $number',
                          maxLines: 2,
                          style: kBodyText.copyWith(
                              color: kWhite, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
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
                              Get.to(() => EditAssignment(
                                        code: code,
                                        assignmentNo: number,
                                        subjectCode: widget.subjectCode,
                                        attachmentUploaded: attachmentUploaded,
                                        date: dueOn,
                                        description: description,
                                        fileExtension: attachmentExtension,
                                        marks: marks,
                                        isUploadable: isUploadable,
                                      ))!
                                  .then((value) {
                                setState(() {});
                              });
                            }
                            break;
                          case 1:
                            {
                              Get.defaultDialog(
                                title: 'Delete Assignment',
                                titleStyle: kBodyText.copyWith(
                                    fontWeight: FontWeight.bold),
                                backgroundColor: kBlack,
                                content: Center(
                                  child: Text(
                                    'Are you sure to delete this Assignment?',
                                    textAlign: TextAlign.center,
                                    style: kBodyText,
                                  ),
                                ),
                                titlePadding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 10),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
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
                                          .collection('subjects')
                                          .doc(widget.subjectCode)
                                          .collection('data')
                                          .doc(code)
                                          .delete()
                                          .then((value) async {
                                        await FirebaseFirestore.instance
                                            .collection('subjects')
                                            .doc(widget.subjectCode)
                                            .get()
                                            .then((value) async {
                                          await FirebaseFirestore.instance
                                              .collection('subjects')
                                              .doc(widget.subjectCode)
                                              .update({
                                            'totalAssignments':
                                                value['totalAssignments'] - 1
                                          }).then((value) {
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                            setState(() {});
                                            Get.snackbar(
                                              'Message',
                                              'Assignment deleted successfully',
                                              duration:
                                                  const Duration(seconds: 3),
                                              backgroundColor: kPrimaryColor,
                                              colorText: kWhite,
                                              borderRadius: 10,
                                            );
                                          });
                                        });
                                      });
                                    },
                                    child: Text('Delete',
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
                              'Edit',
                              style: kBodyText,
                            )),
                        PopupMenuItem<int>(
                            value: 1,
                            child: Text(
                              'Delete',
                              style: kBodyText,
                            )),
                      ],
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Due Date: ',
                    style: kBodyText.copyWith(color: kGrey, fontSize: 13),
                  ),
                  Text(
                    DateFormat('dd-MM-yyyy hh:mm a').format(dueOn.toDate()),
                    style: kBodyText.copyWith(
                        color: (dueOn.toDate().isAfter(DateTime.now()))
                            ? kRed
                            : kGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Total Marks: ',
                    style: kBodyText.copyWith(
                      color: kGrey,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    marks,
                    style: kBodyText.copyWith(
                      fontSize: 13,
                      color: kGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Divider(color: kGrey),
              Padding(
                padding: const EdgeInsets.all(10),
                child: ReadMoreText(
                  description,
                  style: kBodyText.copyWith(color: kGrey, fontSize: 15),
                  trimLength: 100,
                  colorClickableText: kPrimaryColor,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Visibility(
                      visible: attachmentUploaded,
                      child: GestureDetector(
                        onTap: () async {
                          if (await Permission.storage.request().isGranted) {
                            if (await File(
                                    '/storage/emulated/0/Download/$code$attachmentExtension')
                                .exists()) {
                              OpenFile.open(
                                  '/storage/emulated/0/Download/$code$attachmentExtension');
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) => DownloadingDialog(
                                    url: attachment,
                                    fileName: '$code$attachmentExtension',
                                    path:
                                        "/storage/emulated/0/Download/$code$attachmentExtension"),
                              );
                            }
                          } else {
                            Get.snackbar(
                              'Error',
                              'Please provide storage permission to view attachment',
                              duration: const Duration(seconds: 3),
                              backgroundColor: kRed,
                              colorText: kWhite,
                              borderRadius: 10,
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.attachment,
                                color: kWhite.withOpacity(0.8),
                                size: 20,
                              ),
                              const SizedBox(
                                width: 3,
                              ),
                              Text(
                                'Attachment',
                                style: kBodyText.copyWith(
                                    fontSize: 13,
                                    color: kWhite.withOpacity(0.8)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => ViewAssignmentRecord(
                            assignmentCode: code,
                            assignmentNo: number,
                            subjectCode: widget.subjectCode,
                            totalMarks: marks,
                            date: dueOn));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.upload,
                              color: kWhite.withOpacity(0.8),
                              size: 20,
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            Text(
                              'View Uploads',
                              style: kBodyText.copyWith(
                                  fontSize: 13, color: kWhite.withOpacity(0.8)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget quizCard(
      Size size,
      String code,
      String number,
      Timestamp dueOn,
      String marks,
      String description,
      String attachment,
      String attachmentExtension,
      bool attachmentUploaded,
      bool isUploadable) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          width: size.width * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange),
            color: kGrey.withOpacity(0.1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  top: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40),
                    Text(
                      'Quiz $number',
                      maxLines: 2,
                      style: kBodyText.copyWith(
                          color: kWhite, fontWeight: FontWeight.bold),
                    ),
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
                              Get.to(() => EditQuiz(
                                        code: code,
                                        quizNo: number,
                                        subjectCode: widget.subjectCode,
                                        attachment: attachment,
                                        attachmentUploaded: attachmentUploaded,
                                        date: dueOn,
                                        description: description,
                                        fileExtension: attachmentExtension,
                                        marks: marks,
                                        isUploadable: isUploadable,
                                      ))!
                                  .then((value) {
                                setState(() {});
                              });
                            }
                            break;
                          case 1:
                            {
                              Get.defaultDialog(
                                title: 'Delete Quiz',
                                titleStyle: kBodyText.copyWith(
                                    fontWeight: FontWeight.bold),
                                backgroundColor: kBlack,
                                content: Center(
                                  child: Text(
                                    'Are you sure to delete this Quiz?',
                                    textAlign: TextAlign.center,
                                    style: kBodyText,
                                  ),
                                ),
                                titlePadding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 10),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
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
                                          .collection('subjects')
                                          .doc(widget.subjectCode)
                                          .collection('data')
                                          .doc(code)
                                          .delete()
                                          .then((value) async {
                                        await FirebaseFirestore.instance
                                            .collection('subjects')
                                            .doc(widget.subjectCode)
                                            .get()
                                            .then((value) async {
                                          await FirebaseFirestore.instance
                                              .collection('subjects')
                                              .doc(widget.subjectCode)
                                              .update({
                                            'totalQuizzes':
                                                value['totalQuizzes'] - 1
                                          }).then((value) {
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                            setState(() {});
                                            Get.snackbar(
                                              'Message',
                                              'Quiz deleted successfully',
                                              duration:
                                                  const Duration(seconds: 3),
                                              backgroundColor: kPrimaryColor,
                                              colorText: kWhite,
                                              borderRadius: 10,
                                            );
                                          });
                                        });
                                      });
                                    },
                                    child: Text('Delete',
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
                              'Edit',
                              style: kBodyText,
                            )),
                        PopupMenuItem<int>(
                            value: 1,
                            child: Text(
                              'Delete',
                              style: kBodyText,
                            )),
                      ],
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Due Date: ',
                    style: kBodyText.copyWith(color: kGrey, fontSize: 13),
                  ),
                  Text(
                    DateFormat('dd-MM-yyyy hh:mm a').format(dueOn.toDate()),
                    style: kBodyText.copyWith(
                        color: (dueOn.toDate().isAfter(DateTime.now()))
                            ? kRed
                            : kGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Total Marks: ',
                    style: kBodyText.copyWith(
                      color: kGrey,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    marks,
                    style: kBodyText.copyWith(
                      fontSize: 13,
                      color: kGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Divider(color: kGrey),
              Padding(
                padding: const EdgeInsets.all(10),
                child: ReadMoreText(
                  description,
                  style: kBodyText.copyWith(color: kGrey, fontSize: 15),
                  trimLength: 100,
                  colorClickableText: kPrimaryColor,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Visibility(
                      visible: attachmentUploaded,
                      child: GestureDetector(
                        onTap: () async {
                          if (await Permission.storage.request().isGranted) {
                            if (await File(
                                    '/storage/emulated/0/Download/$code$attachmentExtension')
                                .exists()) {
                              OpenFile.open(
                                  '/storage/emulated/0/Download/$code$attachmentExtension');
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) => DownloadingDialog(
                                    url: attachment,
                                    fileName: '$code$attachmentExtension',
                                    path:
                                        "/storage/emulated/0/Download/$code$attachmentExtension"),
                              );
                            }
                          } else {
                            Get.snackbar(
                              'Error',
                              'Please provide storage permission to view attachment',
                              duration: const Duration(seconds: 3),
                              backgroundColor: kRed,
                              colorText: kWhite,
                              borderRadius: 10,
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.attachment,
                                color: kWhite.withOpacity(0.8),
                                size: 20,
                              ),
                              const SizedBox(
                                width: 3,
                              ),
                              Text(
                                'Attachment',
                                style: kBodyText.copyWith(
                                    fontSize: 13,
                                    color: kWhite.withOpacity(0.8)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => ViewQuizRecord(
                            quizCode: code,
                            quizNo: number,
                            subjectCode: widget.subjectCode,
                            totalMarks: marks,
                            date: dueOn));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.upload,
                              color: kWhite.withOpacity(0.8),
                              size: 20,
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            Text(
                              'View Uploads',
                              style: kBodyText.copyWith(
                                  fontSize: 13, color: kWhite.withOpacity(0.8)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget announcementCard(
      Size size,
      String code,
      String announcement,
      String date,
      String attachment,
      String attachmentExtension,
      bool attachmentUploaded) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          width: size.width * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.redAccent),
            color: kGrey.withOpacity(0.1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  top: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(
                      width: 35,
                    ),
                    Text(
                      'Announcement',
                      maxLines: 2,
                      style: kBodyText.copyWith(
                          color: kWhite, fontWeight: FontWeight.bold),
                    ),
                    PopupMenuButton<int>(
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
                              Get.to(() => EditAnnouncement(
                                      code: code,
                                      subjectCode: widget.subjectCode,
                                      attachmentUrl: attachment,
                                      announcement: announcement,
                                      fileExtension: attachmentExtension,
                                      attachment: attachmentUploaded))!
                                  .then((value) {
                                setState(() {});
                              });
                            }
                            break;
                          case 1:
                            {
                              Get.defaultDialog(
                                title: 'Delete Announcement',
                                titleStyle: kBodyText.copyWith(
                                    fontWeight: FontWeight.bold),
                                backgroundColor: kBlack,
                                content: Center(
                                  child: Text(
                                    'Are you sure to delete this Announcement?',
                                    textAlign: TextAlign.center,
                                    style: kBodyText,
                                  ),
                                ),
                                titlePadding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 10),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
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
                                          .collection('subjects')
                                          .doc(widget.subjectCode)
                                          .collection('data')
                                          .doc(code)
                                          .delete()
                                          .then((value) {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                        setState(() {});
                                        Get.snackbar(
                                          'Message',
                                          'Announcement Deleted successfully',
                                          duration: const Duration(seconds: 3),
                                          backgroundColor: kPrimaryColor,
                                          colorText: kWhite,
                                          borderRadius: 10,
                                        );
                                      });
                                    },
                                    child: Text('Delete',
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
                              'Edit',
                              style: kBodyText,
                            )),
                        PopupMenuItem<int>(
                            value: 1,
                            child: Text(
                              'Delete',
                              style: kBodyText,
                            )),
                      ],
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Date: ',
                    style: kBodyText.copyWith(color: kGrey, fontSize: 13),
                  ),
                  Text(
                    date,
                    style: kBodyText.copyWith(
                        color: kGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ],
              ),
              Divider(color: kGrey),
              Padding(
                padding: const EdgeInsets.all(10),
                child: ReadMoreText(
                  announcement,
                  style: kBodyText.copyWith(color: kGrey, fontSize: 15),
                  trimLength: 100,
                  colorClickableText: kPrimaryColor,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Visibility(
                      visible: attachmentUploaded,
                      child: GestureDetector(
                        onTap: () async {
                          if (await Permission.storage.request().isGranted) {
                            if (await File(
                                    '/storage/emulated/0/Download/$code$attachmentExtension')
                                .exists()) {
                              OpenFile.open(
                                  '/storage/emulated/0/Download/$code$attachmentExtension');
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) => DownloadingDialog(
                                    url: attachment,
                                    fileName: '$code$attachmentExtension',
                                    path:
                                        "/storage/emulated/0/Download/$code$attachmentExtension"),
                              );
                            }
                          } else {
                            Get.snackbar(
                              'Error',
                              'Please provide storage permission to view attachment',
                              duration: const Duration(seconds: 3),
                              backgroundColor: kRed,
                              colorText: kWhite,
                              borderRadius: 10,
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.attachment,
                                color: kWhite.withOpacity(0.8),
                                size: 20,
                              ),
                              const SizedBox(
                                width: 3,
                              ),
                              Text(
                                'Attachment',
                                style: kBodyText.copyWith(
                                    fontSize: 13,
                                    color: kWhite.withOpacity(0.8)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox()
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget attendanceCard(Size size, String code, String description, String date,
      Timestamp dueTime) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          width: size.width * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amberAccent),
            color: kGrey.withOpacity(0.1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  top: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(
                      width: 35,
                    ),
                    Text(
                      'Attendance',
                      maxLines: 2,
                      style: kBodyText.copyWith(
                          color: kRed, fontWeight: FontWeight.bold),
                    ),
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
                              Get.to(() => EditAttendance(
                                        code: code,
                                        subjectCode: widget.subjectCode,
                                        message: description,
                                        date: dueTime,
                                      ))!
                                  .then((value) {
                                setState(() {});
                              });
                            }
                            break;
                          case 1:
                            {
                              Get.defaultDialog(
                                title: 'Delete Attendance',
                                titleStyle: kBodyText.copyWith(
                                    fontWeight: FontWeight.bold),
                                backgroundColor: kBlack,
                                content: Center(
                                  child: Text(
                                    'Are you sure to delete this Attendance?',
                                    textAlign: TextAlign.center,
                                    style: kBodyText,
                                  ),
                                ),
                                titlePadding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 10),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
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
                                          .collection('subjects')
                                          .doc(widget.subjectCode)
                                          .collection('data')
                                          .doc(code)
                                          .delete()
                                          .then((value) async {
                                        await FirebaseFirestore.instance
                                            .collection('subjects')
                                            .doc(widget.subjectCode)
                                            .get()
                                            .then((value) async {
                                          await FirebaseFirestore.instance
                                              .collection('subjects')
                                              .doc(widget.subjectCode)
                                              .update({
                                            'totalClasses':
                                                value['totalClasses'] - 1
                                          }).then((value) {
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                            setState(() {});
                                            Get.snackbar(
                                              'Message',
                                              'Attendance deleted successfully',
                                              duration:
                                                  const Duration(seconds: 3),
                                              backgroundColor: kPrimaryColor,
                                              colorText: kWhite,
                                              borderRadius: 10,
                                            );
                                          });
                                        });
                                      });
                                    },
                                    child: Text('Delete',
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
                              'Edit',
                              style: kBodyText,
                            )),
                        PopupMenuItem<int>(
                            value: 1,
                            child: Text(
                              'Delete',
                              style: kBodyText,
                            )),
                      ],
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Date: ',
                    style: kBodyText.copyWith(color: kGrey, fontSize: 13),
                  ),
                  Text(
                    date,
                    style: kBodyText.copyWith(
                        color: kGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    (dueTime.toDate().isAfter(DateTime.now()))
                        ? 'Active Till: '
                        : 'Was Active Till: ',
                    style: kBodyText.copyWith(color: kGrey, fontSize: 13),
                  ),
                  Text(
                    DateFormat('dd-MM-yyyy hh:mm a').format(dueTime.toDate()),
                    style: kBodyText.copyWith(
                        color: (dueTime.toDate().isAfter(DateTime.now()))
                            ? kRed
                            : kGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ],
              ),
              Divider(color: kGrey),
              Padding(
                padding: const EdgeInsets.all(10),
                child: ReadMoreText(
                  description,
                  style: kBodyText.copyWith(color: kGrey, fontSize: 15),
                  trimLength: 100,
                  colorClickableText: kPrimaryColor,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: GestureDetector(
                      onTap: () {
                        Get.to(() => ViewAttendance(
                            attendanceCode: code,
                            subjectCode: widget.subjectCode,
                            date: date));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: kWhite.withOpacity(0.8),
                              size: 20,
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            Text(
                              'View Attendance',
                              style: kBodyText.copyWith(
                                  fontSize: 13, color: kWhite.withOpacity(0.8)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// Get.defaultDialog(
// title: '',
// backgroundColor: Colors.transparent,
// barrierDismissible: false,
// content: SpinKitCircle(
//   color: kPrimaryColor,
//   size: 50.0,
// ),
// );