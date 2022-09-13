import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meetroom/sharedScreens/nav_drawer.dart';
import 'package:meetroom/studentScreens/add_subject_student.dart';
import 'package:meetroom/studentScreens/notification.dart';
import 'package:meetroom/services/auth.dart';
import 'package:meetroom/shared/constants.dart';
import 'package:meetroom/teacherScreens/add_subject_teacher.dart';
import 'package:meetroom/teacherScreens/subject_screen_teacher.dart';
import '../studentScreens/subject_screen_student.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _auth = AuthService();
  String name = '';
  String email = '';
  String rollNo = '';
  String cnic = '';
  String phone = '';
  bool isApproved = false;
  // ignore: avoid_init_to_null
  dynamic dpUrl = null;
  bool isStudent = true;
  bool imageSelected = false;
  late File _dpImage;
  final picker = ImagePicker();
  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _dpImage = File(pickedFile!.path);
      imageSelected = true;
    });
    Get.snackbar(
      'Message',
      'Uploading Profile Image',
      duration: const Duration(seconds: 3),
      backgroundColor: kPrimaryColor,
      colorText: kWhite,
      borderRadius: 10,
    );
    uploadImageToFirebase();
  }

  Future getUser() async {
    var currentUser = _auth.getCurrentUser();
    var firestore = FirebaseFirestore.instance;
    DocumentSnapshot snapshot =
        await firestore.collection('users').doc(currentUser).get();
    if (snapshot['isStudent'] == true) {
      setState(() {
        name = snapshot['name'];
        rollNo = snapshot['rollNo'];
        email = snapshot['email'];
        phone = snapshot['phone'];
        dpUrl = snapshot['dpUrl'];
        isStudent = true;
        isApproved = snapshot['isApproved'];
      });
    } else {
      setState(() {
        name = snapshot['name'];
        cnic = snapshot['cnic'];
        email = snapshot['email'];
        phone = snapshot['phone'];
        dpUrl = snapshot['dpUrl'];
        isApproved = snapshot['isApproved'];
        isStudent = false;
      });
    }
  }

  Future uploadImageToFirebase() async {
    String fileName = _auth.getCurrentUser();
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('profilePictures/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putFile(_dpImage);
    try {
      uploadTask.whenComplete(() async {
        String url = await firebaseStorageRef.getDownloadURL();
        var currentUser = _auth.getCurrentUser();
        FirebaseFirestore.instance
            .collection("users")
            .doc(currentUser)
            .update({"dpUrl": url}).then((_) {
          setState(() {
            dpUrl = url;
          });
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
    //return url;
  }

  //Function to manage exit app button
  Future<bool> _onWillPop() async {
    return (await (Get.defaultDialog(
          title: 'Exit MeetRoom',
          titleStyle: kBodyText.copyWith(fontWeight: FontWeight.bold),
          backgroundColor: kBlack,
          content: Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Text(
              'Do you want to exit?',
              style: kBodyText,
            ),
          ),
          titlePadding: const EdgeInsets.symmetric(vertical: 20),
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No',
                  style: kBodyText.copyWith(fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Exit',
                  style: kBodyText.copyWith(
                      color: kRed, fontWeight: FontWeight.bold)),
            ),
          ],
        ))) ??
        false;
  }

  Future getSubjects() async {
    var firestore = FirebaseFirestore.instance;
    QuerySnapshot qn = await firestore
        .collection('users')
        .doc(_auth.getCurrentUser())
        .collection('subjects')
        .get();

    return qn.docs;
  }

  bool newNotification = false;
  double notificationCount = 0;

  newNotificationCheck() async {
    notificationCount = 0;
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc('notificationsData')
        .collection(_auth.getCurrentUser())
        .get()
        .then((value) async {
      for (var i = 0; i < value.docs.length; i++) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.getCurrentUser())
            .collection('subjects')
            .doc(value.docs[i]['subjectCode'])
            .get()
            .then((snapshot) {
          if (snapshot.exists) {
            if (snapshot['subjectCode'] == value.docs[i]['subjectCode']) {
              if (value.docs[i]['isRead'] == true) {
                setState(() {
                  newNotification = false;
                });
              } else if (value.docs[i]['isRead'] == false) {
                setState(() {
                  newNotification = true;
                  notificationCount += 1;
                });
              }
            }
          }
        });
      }
    });
  }

  @override
  void initState() {
    getUser();
    newNotificationCheck();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          backgroundColor: kBlack,
          drawer: const NavDrawer(),
          appBar: AppBar(
              backgroundColor: kBlack,
              elevation: 0,
              title: Text(
                'MeetRoom',
                style: GoogleFonts.merienda(
                    fontSize: 25,
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              //Menu Button
              leading: Builder(
                builder: (context) => GestureDetector(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Image.asset(
                      'assets/icons/menu.jpg',
                      color: kWhite,
                      height: 5,
                      width: 5,
                    ),
                  ),
                ),
              ),
              actions: [
                StreamBuilder<dynamic>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(_auth.getCurrentUser())
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return SpinKitCircle(
                          color: kPrimaryColor,
                          size: 20,
                        );
                      } else {
                        return Visibility(
                          visible: snapshot.data['isStudent'],
                          child: GestureDetector(
                            onTap: () {
                              if (isApproved) {
                                Get.to(() => const NotificationScreen())!
                                    .then((value) {
                                  newNotificationCheck();
                                });
                              } else {
                                Get.snackbar(
                                  'No Access',
                                  'Please wait until an admin approve your profile',
                                  duration: const Duration(seconds: 3),
                                  backgroundColor: Colors.red,
                                  colorText: kWhite,
                                  borderRadius: 10,
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    newNotification
                                        ? Icons.notifications_active_outlined
                                        : Icons.notifications_outlined,
                                    color: kWhite,
                                    size: 28,
                                  ),
                                  Positioned(
                                    top: 12,
                                    right: 0,
                                    child: Container(
                                      height: 15,
                                      width: 15,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Center(
                                        child: Text(
                                          notificationCount.toInt().toString(),
                                          style:
                                              kBodyText.copyWith(fontSize: 10),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    })
              ]),
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
                      border:
                          Border.all(color: kPrimaryColor.withOpacity(0.5))),
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
                      if (isStudent) {
                        if (isApproved) {
                          Get.to(() => const AddSubjectStudent())!.then((_) {
                            setState(() {});
                          });
                        } else {
                          Get.snackbar(
                            'No Access',
                            'Please wait until an admin approve your profile',
                            duration: const Duration(seconds: 3),
                            backgroundColor: Colors.red,
                            colorText: kWhite,
                            borderRadius: 10,
                          );
                        }
                      } else {
                        if (isApproved) {
                          Get.to(() => AddSubjectTeacher(
                                  teacherName: name,
                                  email: email,
                                  phone: phone))!
                              .then((_) {
                            setState(() {});
                          });
                        } else {
                          Get.snackbar(
                            'No Access',
                            'Please wait until an admin approve your profile',
                            duration: const Duration(seconds: 3),
                            backgroundColor: Colors.red,
                            colorText: kWhite,
                            borderRadius: 10,
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          body: Column(
            children: [
              profileCard(size),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      FutureBuilder<dynamic>(
                          future: getSubjects(),
                          builder: (_, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
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
                                        i++)
                                      isStudent
                                          ? subjectCard(
                                              size,
                                              snapshot.data[i]['subjectCode'],
                                              snapshot.data[i]['name'],
                                              snapshot.data[i]['teacher'],
                                              snapshot.data[i]['email'],
                                              snapshot.data[i]['attended'],
                                              0,
                                              0,
                                            )
                                          : subjectCard(
                                              size,
                                              snapshot.data[i]['subjectCode'],
                                              snapshot.data[i]['name'],
                                              snapshot.data[i]['teacher'],
                                              snapshot.data[i]['email'],
                                              0,
                                              0,
                                              0,
                                            )
                                  ] else ...[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15),
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
                                              "You don't have any subjects",
                                              textAlign: TextAlign.center,
                                              style: kBodyText.copyWith(
                                                  fontSize: 15),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ]
                                ],
                              );
                            }
                          }),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: SizedBox(
                          width: 270,
                          child: Text(
                            "Add subjects by pressing '+' icon in the bottom right",
                            textAlign: TextAlign.center,
                            style: kBodyText.copyWith(
                                color: kGrey.withOpacity(0.5), fontSize: 15),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }

  Widget profileCard(Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Center(
        child: Container(
          height: 120,
          width: size.width * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: kGrey.withOpacity(0.2),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: StreamBuilder<dynamic>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(_auth.getCurrentUser())
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return SpinKitCircle(
                      color: kPrimaryColor,
                      size: 13,
                    );
                  } else {
                    return Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (snapshot.data['dpUrl'] == null) {
                              pickImage();
                            }
                          },
                          child: Container(
                            height: 80,
                            width: 70,
                            decoration: BoxDecoration(
                                color: kGrey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(16)),
                            child: (snapshot.data['dpUrl'] == null)
                                ? Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      SizedBox(
                                        height: 50,
                                        width: 50,
                                        child: Image.asset(
                                            'assets/icons/upload.png',
                                            color: kWhite.withOpacity(0.8)),
                                      ),
                                      Text(
                                        'Upload',
                                        style: kBodyText.copyWith(
                                          fontSize: 10,
                                        ),
                                      )
                                    ],
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      snapshot.data['dpUrl'],
                                      fit: BoxFit.cover,
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Center(
                                          child: CircularProgressIndicator(
                                            color: kPrimaryColor,
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                    )),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.data['name'].toUpperCase(),
                                  style: kBodyText.copyWith(
                                      fontSize: 22,
                                      overflow: TextOverflow.ellipsis,
                                      color: kPrimaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                snapshot.data['isStudent']
                                    ? Text(
                                        'Roll # ${snapshot.data['rollNo']}',
                                        style: kBodyText,
                                      )
                                    : Text(
                                        'CNIC # ${snapshot.data['cnic']}',
                                        style: kBodyText,
                                      ),
                                Text(
                                  'Phone # ${snapshot.data['phone']}',
                                  style: kBodyText,
                                ),
                              ]),
                        ),
                      ],
                    );
                  }
                }),
          ),
        ),
      ),
    );
  }

  Widget subjectCard(
      Size size,
      String subjectCode,
      String subjectName,
      String teacher,
      String email,
      int attended,
      int totalAssignments,
      int totalQuizzes) {
    return GestureDetector(
      onTap: () {
        if (isStudent) {
          Get.to(() => SubjectScreenStudent(
                isStudent: isStudent,
                studentName: name,
                rollNo: rollNo,
                subjectCode: subjectCode,
                name: subjectName,
                teacher: teacher,
                email: email,
                attended: attended,
              ));
        } else {
          Get.to(() => SubjectScreenTeacher(
                isStudent: isStudent,
                subjectCode: subjectCode,
                name: subjectName,
                teacher: teacher,
                email: email,
              ));
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: Container(
            width: size.width * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: kGrey.withOpacity(0.1),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: Row(
                children: [
                  Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          color: Colors.primaries[
                              Random().nextInt(Colors.primaries.length)],
                          shape: BoxShape.circle),
                      child: Center(
                          child: Text(
                        subjectName[0].toUpperCase(),
                        style: kBodyText.copyWith(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ))),
                  const SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subjectName,
                            maxLines: 2,
                            style: kBodyText.copyWith(
                                color: kWhite, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 3,
                          ),
                          Text(
                            teacher,
                            style:
                                kBodyText.copyWith(color: kGrey, fontSize: 13),
                          ),
                        ]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
