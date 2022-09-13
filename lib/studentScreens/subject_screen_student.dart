import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:meetroom/shared/constants.dart';
import 'package:meetroom/sharedScreens/subject_info.dart';
import 'package:meetroom/studentScreens/join_meeting.dart';
import 'package:meetroom/studentScreens/remove_subject.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:readmore/readmore.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import '../services/auth.dart';
import '../shared/download_file.dart';

class SubjectScreenStudent extends StatefulWidget {
  final bool isStudent;
  final String subjectCode;
  final String name;
  final String teacher;
  final String email;
  final int attended;
  final String rollNo;
  final String studentName;
  const SubjectScreenStudent({
    Key? key,
    required this.isStudent,
    required this.name,
    required this.teacher,
    required this.subjectCode,
    required this.email,
    required this.attended,
    required this.rollNo,
    required this.studentName,
  }) : super(key: key);

  @override
  State<SubjectScreenStudent> createState() => _SubjectScreenStudentState();
}

class _SubjectScreenStudentState extends State<SubjectScreenStudent> {
  final AuthService _auth = AuthService();
  String uid = '';
  late File _attachment;
  String _fileExtension = '';
  bool assignmentPicked = false;
  String _localPath = '';
  @override
  void initState() {
    uid = _auth.getCurrentUser();
    super.initState();
  }

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

  Future<bool> pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      setState(() {
        _attachment = File(result.files.single.path!);
        _localPath = _attachment.path;
      });
      getExtension();
      return true;
    } else {
      return false;
      // User canceled the picker
    }
  }

  getExtension() {
    final File file = File(_attachment.path);
    _fileExtension = p.extension(file.path);
  }

  Future uploadFileToFirebase(
      BuildContext context, String code, bool isQuiz) async {
    if (isQuiz) {
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('quizData/uploads/$uid');
      UploadTask uploadTask = firebaseStorageRef.putFile(_attachment);
      try {
        uploadTask.whenComplete(() async {
          String fileUrl = await firebaseStorageRef.getDownloadURL();
          await FirebaseFirestore.instance
              .collection('subjects')
              .doc(widget.subjectCode)
              .collection('data')
              .doc(code)
              .collection('quizzes')
              .doc(uid)
              .update({
            'localPath': _localPath,
            'attachment': fileUrl,
            'attachmentExtension': _fileExtension,
            'uid': uid,
          }).then((value) {
            Get.back();
            Get.back();
            Get.snackbar(
              'Message',
              'Quiz submitted successfully',
              duration: const Duration(seconds: 3),
              backgroundColor: kPrimaryColor,
              colorText: kWhite,
              borderRadius: 10,
            );
          });
        });
      } on FirebaseException catch (error) {
        Get.snackbar(
          'Error',
          error.toString(),
          duration: const Duration(seconds: 3),
          backgroundColor: kRed,
          colorText: kWhite,
          borderRadius: 10,
        );
      }
    } else {
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('assignmentData/uploads/$uid');
      UploadTask uploadTask = firebaseStorageRef.putFile(_attachment);
      try {
        uploadTask.whenComplete(() async {
          String fileUrl = await firebaseStorageRef.getDownloadURL();
          await FirebaseFirestore.instance
              .collection('subjects')
              .doc(widget.subjectCode)
              .collection('data')
              .doc(code)
              .collection('assignments')
              .doc(uid)
              .update({
            'localPath': _localPath,
            'attachment': fileUrl,
            'attachmentExtension': _fileExtension,
            'uid': uid,
          }).then((value) {
            Get.back();
            Get.back();
            Get.snackbar(
              'Message',
              'Assignment submitted successfully',
              duration: const Duration(seconds: 3),
              backgroundColor: kPrimaryColor,
              colorText: kWhite,
              borderRadius: 10,
            );
          });
        });
      } on FirebaseException catch (error) {
        Get.snackbar(
          'Error',
          error.toString(),
          duration: const Duration(seconds: 3),
          backgroundColor: kRed,
          colorText: kWhite,
          borderRadius: 10,
        );
      }
    }
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
                Get.to(() => RemoveSubject(
                      subjectName: widget.name,
                      subjectCode: widget.subjectCode,
                      uid: uid,
                    ));
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Icon(
                  Icons.backspace_outlined,
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
          child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kPrimaryColor.withOpacity(0.5))),
            child: FloatingActionButton(
                heroTag: 'createMeeting',
                backgroundColor: kBlack,
                elevation: 15,
                child: Icon(
                  Icons.videocam,
                  color: kPrimaryColor,
                  size: 30,
                ),
                onPressed: () {
                  Get.to(() => JoinMeeting(
                        subjectCode: widget.subjectCode,
                        name: widget.teacher,
                        email: widget.email,
                      ));
                }),
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
                                          snapshot.data[i]['checked'],
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
                                          snapshot.data[i]['checked'])
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
                                          snapshot.data[i]['checked'])
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
                                          snapshot.data[i]['fileSubmission'],
                                          snapshot.data[i]['checked'])
                                } else if (snapshot.data[i]['type'] ==
                                    'announcement') ...{
                                  (snapshot.data[i]['attachmentUploaded'])
                                      ? announcementCard(
                                          size,
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
                    widget.teacher,
                    style: kBodyText.copyWith(color: kGrey, fontSize: 13),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
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
                      Row(
                        children: [
                          Text(
                            'Attended: ',
                            style: kBodyText.copyWith(fontSize: 15),
                          ),
                          StreamBuilder<dynamic>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(uid)
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
                        ],
                      ),
                    ],
                  ),
                  Row(
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
                                snapshot.data['totalAssignments'].toString(),
                                style: kBodyText.copyWith(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              );
                            }
                          }),
                    ],
                  ),
                  Row(
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
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              );
                            }
                          }),
                    ],
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
    bool uploadsAllowed,
    bool checked,
  ) {
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
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'Assignment $number',
                  maxLines: 2,
                  style: kBodyText.copyWith(
                      color: kWhite, fontWeight: FontWeight.bold),
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
              checked
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Your Marks: ',
                          style: kBodyText.copyWith(
                            color: kGrey,
                            fontSize: 13,
                          ),
                        ),
                        StreamBuilder<dynamic>(
                            stream: FirebaseFirestore.instance
                                .collection('subjects')
                                .doc(widget.subjectCode)
                                .collection('data')
                                .doc(code)
                                .collection('assignments')
                                .doc(uid)
                                .snapshots(),
                            builder: (_, snapshot) {
                              if (!snapshot.hasData) {
                                return SpinKitCircle(
                                  color: kPrimaryColor,
                                  size: 13,
                                );
                              } else {
                                if (snapshot.data!.exists) {
                                  return Text(
                                    "${snapshot.data['givenMarks'].toString()}/$marks",
                                    style: kBodyText.copyWith(
                                        fontSize: 13,
                                        color: kPrimaryColor,
                                        fontWeight: FontWeight.bold),
                                  );
                                } else {
                                  return Text(
                                    "0/$marks",
                                    style: kBodyText.copyWith(
                                      fontSize: 13,
                                      color: kPrimaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }
                              }
                            }),
                      ],
                    )
                  : Row(
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
                                'View Attachment',
                                style: kBodyText.copyWith(
                                    fontSize: 13,
                                    color: kWhite.withOpacity(0.8)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: uploadsAllowed,
                      child: StreamBuilder<dynamic>(
                          stream: FirebaseFirestore.instance
                              .collection('subjects')
                              .doc(widget.subjectCode)
                              .collection('data')
                              .doc(code)
                              .collection('assignments')
                              .doc(uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox();
                            } else {
                              if (snapshot.data!.exists) {
                                return GestureDetector(
                                  onTap: () async {
                                    Get.defaultDialog(
                                      title: 'Assignment Submitted',
                                      titleStyle: kBodyText.copyWith(
                                          fontWeight: FontWeight.bold),
                                      backgroundColor: kBlack,
                                      content: const SizedBox(),
                                      titlePadding: const EdgeInsets.symmetric(
                                          vertical: 20),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () async {
                                            if (await pickFile()) {
                                              Get.defaultDialog(
                                                title: '',
                                                backgroundColor:
                                                    Colors.transparent,
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
                                                  .collection('assignments')
                                                  .doc(uid)
                                                  .set({
                                                'name': widget.studentName,
                                                'rollNo': widget.rollNo,
                                                'givenMarks': 0,
                                                'checked': false,
                                                'timestamp': DateTime.now(),
                                              }).then((value) {
                                                uploadFileToFirebase(
                                                    context, code, false);
                                              });
                                            }
                                          },
                                          child: Text('Upload Again',
                                              style: kBodyText.copyWith(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            if (await Permission.storage
                                                .request()
                                                .isGranted) {
                                              if (await File(snapshot
                                                      .data['localPath'])
                                                  .exists()) {
                                                OpenFile.open(
                                                    snapshot.data['localPath']);
                                              } else {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      DownloadingDialog(
                                                          url: attachment,
                                                          fileName:
                                                              '$code$attachmentExtension',
                                                          path:
                                                              "/storage/emulated/0/Download/$code$attachmentExtension"),
                                                );
                                              }
                                            } else {
                                              Get.snackbar(
                                                'Error',
                                                'Please provide storage permission to view attachment',
                                                duration:
                                                    const Duration(seconds: 3),
                                                backgroundColor: kRed,
                                                colorText: kWhite,
                                                borderRadius: 10,
                                              );
                                            }
                                          },
                                          child: Text('View',
                                              style: kBodyText.copyWith(
                                                  color: kRed,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    );
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
                                          Icons.assignment_turned_in,
                                          color: kWhite.withOpacity(0.8),
                                          size: 20,
                                        ),
                                        const SizedBox(
                                          width: 3,
                                        ),
                                        Text(
                                          'Submitted',
                                          style: kBodyText.copyWith(
                                              fontSize: 13,
                                              color: kWhite.withOpacity(0.8)),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              return (dueOn.toDate().isAfter(DateTime.now()))
                                  ? GestureDetector(
                                      onTap: () async {
                                        if (await pickFile()) {
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
                                              .collection('assignments')
                                              .doc(uid)
                                              .set({
                                            'name': widget.studentName,
                                            'rollNo': widget.rollNo,
                                            'givenMarks': 0,
                                            'checked': false,
                                            'timestamp': DateTime.now(),
                                          }).then((value) {
                                            uploadFileToFirebase(
                                                context, code, false);
                                          });
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: kPrimaryColor,
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                              'Upload Work',
                                              style: kBodyText.copyWith(
                                                  fontSize: 13,
                                                  color:
                                                      kWhite.withOpacity(0.8)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: kPrimaryColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.error,
                                            color: kWhite.withOpacity(0.8),
                                            size: 20,
                                          ),
                                          const SizedBox(
                                            width: 3,
                                          ),
                                          Text(
                                            'Missed',
                                            style: kBodyText.copyWith(
                                                fontSize: 13,
                                                color: kWhite.withOpacity(0.8)),
                                          ),
                                        ],
                                      ),
                                    );
                            }
                          }),
                    )
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
      bool uploadsAllowed,
      bool checked) {
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
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'Quiz $number',
                  maxLines: 2,
                  style: kBodyText.copyWith(
                      color: kWhite, fontWeight: FontWeight.bold),
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
                        fontWeight: FontWeight.bold),
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
                                'View Attachment',
                                style: kBodyText.copyWith(
                                    fontSize: 13,
                                    color: kWhite.withOpacity(0.8)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: uploadsAllowed,
                      child: StreamBuilder<dynamic>(
                          stream: FirebaseFirestore.instance
                              .collection('subjects')
                              .doc(widget.subjectCode)
                              .collection('data')
                              .doc(code)
                              .collection('quizzes')
                              .doc(uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox();
                            } else {
                              if (snapshot.data!.exists) {
                                return GestureDetector(
                                  onTap: () async {
                                    Get.defaultDialog(
                                      title: 'Quiz Submitted',
                                      titleStyle: kBodyText.copyWith(
                                          fontWeight: FontWeight.bold),
                                      backgroundColor: kBlack,
                                      content: const SizedBox(),
                                      titlePadding: const EdgeInsets.symmetric(
                                          vertical: 20),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () async {
                                            if (await pickFile()) {
                                              Get.defaultDialog(
                                                title: '',
                                                backgroundColor:
                                                    Colors.transparent,
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
                                                  .collection('quizzes')
                                                  .doc(uid)
                                                  .set({
                                                'name': widget.studentName,
                                                'rollNo': widget.rollNo,
                                                'givenMarks': 0,
                                                'checked': false,
                                                'timestamp': DateTime.now(),
                                              }).then((value) {
                                                uploadFileToFirebase(
                                                    context, code, true);
                                              });
                                            }
                                          },
                                          child: Text('Upload Again',
                                              style: kBodyText.copyWith(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            if (await Permission.storage
                                                .request()
                                                .isGranted) {
                                              if (await File(snapshot
                                                      .data['localPath'])
                                                  .exists()) {
                                                OpenFile.open(
                                                    snapshot.data['localPath']);
                                              } else {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      DownloadingDialog(
                                                          url: attachment,
                                                          fileName:
                                                              '$code$attachmentExtension',
                                                          path:
                                                              "/storage/emulated/0/Download/$code$attachmentExtension"),
                                                );
                                              }
                                            } else {
                                              Get.snackbar(
                                                'Error',
                                                'Please provide storage permission to view attachment',
                                                duration:
                                                    const Duration(seconds: 3),
                                                backgroundColor: kRed,
                                                colorText: kWhite,
                                                borderRadius: 10,
                                              );
                                            }
                                          },
                                          child: Text('View',
                                              style: kBodyText.copyWith(
                                                  color: kRed,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    );
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
                                          Icons.assignment_turned_in,
                                          color: kWhite.withOpacity(0.8),
                                          size: 20,
                                        ),
                                        const SizedBox(
                                          width: 3,
                                        ),
                                        Text(
                                          'Submitted',
                                          style: kBodyText.copyWith(
                                              fontSize: 13,
                                              color: kWhite.withOpacity(0.8)),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                              return (dueOn.toDate().isAfter(DateTime.now()))
                                  ? GestureDetector(
                                      onTap: () async {
                                        if (await pickFile()) {
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
                                              .collection('quizzes')
                                              .doc(uid)
                                              .set({
                                            'name': widget.studentName,
                                            'rollNo': widget.rollNo,
                                            'givenMarks': 0,
                                            'checked': false,
                                            'timestamp': DateTime.now(),
                                          }).then((value) {
                                            uploadFileToFirebase(
                                                context, code, true);
                                          });
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: kPrimaryColor,
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                              'Upload Work',
                                              style: kBodyText.copyWith(
                                                  fontSize: 13,
                                                  color:
                                                      kWhite.withOpacity(0.8)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: kPrimaryColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.error,
                                            color: kWhite.withOpacity(0.8),
                                            size: 20,
                                          ),
                                          const SizedBox(
                                            width: 3,
                                          ),
                                          Text(
                                            'Missed',
                                            style: kBodyText.copyWith(
                                                fontSize: 13,
                                                color: kWhite.withOpacity(0.8)),
                                          ),
                                        ],
                                      ),
                                    );
                            }
                          }),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget announcementCard(Size size, String announcement, String date,
      String attachment, String attachmentExtension, bool attachmentUploaded) {
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
                padding: const EdgeInsets.all(10),
                child: Text(
                  'Announcement',
                  maxLines: 2,
                  style: kBodyText.copyWith(
                      color: kWhite, fontWeight: FontWeight.bold),
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
                padding: const EdgeInsets.all(10),
                child: Text(
                  'Attendance',
                  maxLines: 2,
                  style: kBodyText.copyWith(
                      color: kRed, fontWeight: FontWeight.bold),
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
              StreamBuilder<dynamic>(
                  stream: FirebaseFirestore.instance
                      .collection('subjects')
                      .doc(widget.subjectCode)
                      .collection('data')
                      .doc(code)
                      .collection('attendance')
                      .doc(uid)
                      .snapshots(),
                  builder: (_, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox();
                    } else {
                      if (!snapshot.data!.exists) {
                        if (dueTime.toDate().isAfter(DateTime.now())) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: GestureDetector(
                                  onTap: () async {
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
                                        .collection('attendance')
                                        .doc(uid)
                                        .set({
                                      'name': widget.studentName,
                                      'rollNo': widget.rollNo,
                                      'timestamp': DateTime.now(),
                                    }).then((value) async {
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(uid)
                                          .collection('subjects')
                                          .doc(widget.subjectCode)
                                          .get()
                                          .then((value) async {
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(uid)
                                            .collection('subjects')
                                            .doc(widget.subjectCode)
                                            .update({
                                          'attended': value['attended'] + 1,
                                        }).then((value) {
                                          Navigator.pop(context);
                                          Get.snackbar(
                                            'Message',
                                            'Attendance Marked',
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
                                          'Mark Attendance',
                                          style: kBodyText.copyWith(
                                              fontSize: 13,
                                              color: kWhite.withOpacity(0.8)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return const SizedBox();
                        }
                      } else {
                        return const SizedBox();
                      }
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
