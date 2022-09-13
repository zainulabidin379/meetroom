import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../shared/constants.dart';

class ViewStudents extends StatefulWidget {
  final String subjectCode;
  const ViewStudents({Key? key, required this.subjectCode}) : super(key: key);

  @override
  State<ViewStudents> createState() => _ViewStudentsState();
}

class _ViewStudentsState extends State<ViewStudents> {
  Future getStudents() async {
    var firestore = FirebaseFirestore.instance;
    QuerySnapshot qn = await firestore
        .collection('subjects')
        .doc(widget.subjectCode)
        .collection('students')
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
        title: Text(
          'Students',
          style: GoogleFonts.merienda(
              fontSize: 22, color: kPrimaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          FutureBuilder<dynamic>(
            future: getStudents(),
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
                      for (var i = 0; i < snapshot.data.length; i++) ...[
                        studentCard(
                          size,
                          snapshot.data[i]['uid'],
                          snapshot.data[i]['name'],
                          snapshot.data[i]['dpUrl'],
                          snapshot.data[i]['email'],
                          snapshot.data[i]['rollNo'],
                          snapshot.data[i]['phone'],
                        )
                      ]
                    ]
                  ],
                );
              }
            },
          ),
        ],
      )),
    );
  }

  Widget studentCard(
    Size size,
    String uid,
    String name,
    dynamic dpUrl,
    String email,
    String rollNo,
    String phone,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Center(
        child: Container(
          width: size.width * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: Colors
                    .primaries[Random().nextInt(Colors.primaries.length)]),
            color: kGrey.withOpacity(0.2),
          ),
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        height: 90,
                        width: 70,
                        decoration: BoxDecoration(
                            color: kGrey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16)),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: (dpUrl == null)
                                ? Image.asset(
                                    'assets/icons/guest.png',
                                  )
                                : Image.network(
                                    dpUrl,
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
                      const SizedBox(
                        width: 8,
                      ),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name.toUpperCase(),
                              style: kBodyText.copyWith(
                                  fontSize: 20,
                                  overflow: TextOverflow.ellipsis,
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.email,
                                  color: kGrey,
                                  size: 15,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                SizedBox(
                                  width: size.width * 0.55,
                                  child: AutoSizeText(
                                    email,
                                    maxLines: 1,
                                    style: kBodyText.copyWith(fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.numbers,
                                  color: kGrey,
                                  size: 15,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  rollNo,
                                  style: kBodyText.copyWith(fontSize: 15),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  color: kGrey,
                                  size: 15,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  phone,
                                  style: kBodyText.copyWith(fontSize: 15),
                                ),
                              ],
                            ),
                          ]),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: GestureDetector(
                      onTap: () async {
                        Get.defaultDialog(
                          title: 'Remove Student',
                          titleStyle:
                              kBodyText.copyWith(fontWeight: FontWeight.bold),
                          backgroundColor: kBlack,
                          content: Center(
                            child: Text(
                              'Are you sure to remove this student from class?',
                              textAlign: TextAlign.center,
                              style: kBodyText,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 10),
                          titlePadding:
                              const EdgeInsets.symmetric(vertical: 20),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: Text('cancel',
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
                                    .collection('users')
                                    .doc(uid)
                                    .collection('subjects')
                                    .doc(widget.subjectCode)
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
                                      'totalStudents':
                                          value['totalStudents'] - 1,
                                    }).then((value) async {
                                      await FirebaseFirestore.instance
                                          .collection('subjects')
                                          .doc(widget.subjectCode)
                                          .collection('students')
                                          .doc(uid)
                                          .delete()
                                          .then((value) {
                                        Get.back();
                                        Get.back();
                                        Get.back();
                                        Get.snackbar(
                                          'Message',
                                          'Student removed from class successfully',
                                          duration: const Duration(seconds: 3),
                                          backgroundColor: kPrimaryColor,
                                          colorText: kWhite,
                                          borderRadius: 10,
                                        );
                                      });
                                    });
                                  });
                                });
                              },
                              child: Text('Remove',
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.dangerous,
                              color: kWhite.withOpacity(0.8),
                              size: 20,
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            Text(
                              'Remove Student',
                              style: kBodyText.copyWith(
                                  fontSize: 13, color: kWhite.withOpacity(0.8)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }
}
