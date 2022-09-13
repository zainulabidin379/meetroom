import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../shared/constants.dart';
import '../sharedScreens/home_screen.dart';

class RemoveSubject extends StatefulWidget {
  final String subjectCode;

  final String subjectName;
  final String uid;
  const RemoveSubject({
    Key? key,
    required this.subjectCode,
    required this.uid,
    required this.subjectName,
  }) : super(key: key);

  @override
  State<RemoveSubject> createState() => _RemoveSubjectState();
}

class _RemoveSubjectState extends State<RemoveSubject> {
  bool loading = false;
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
              child: Text('Remove Subject',
                  style: kBodyText.copyWith(
                      color: kWhite,
                      fontSize: 30,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: Text(
              "Are you sure to remove ${widget.subjectName}?",
              textAlign: TextAlign.center,
              style: kBodyText.copyWith(
                color: kWhite,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: InkWell(
              onTap: () async {
                setState(() {
                  loading = true;
                });
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.uid)
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
                      'totalStudents': value['totalStudents'] - 1,
                    }).then((value) async {
                      await FirebaseFirestore.instance
                          .collection('subjects')
                          .doc(widget.subjectCode)
                          .collection('students')
                          .doc(widget.uid)
                          .delete()
                          .then((value) {
                        Get.offAll(() => const HomeScreen());
                        setState(() {});
                        Get.snackbar(
                          'Message',
                          'Subject ${widget.subjectName} removed successfully',
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
              child: Container(
                height: 60,
                width: size.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: kPrimaryColor,
                ),
                child: Center(
                  child: loading
                      ? SpinKitCircle(
                          color: kWhite,
                          size: 50.0,
                        )
                      : Text(
                          'Remove Subject',
                          style: kBodyText.copyWith(
                              fontWeight: FontWeight.bold, color: kWhite),
                        ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
