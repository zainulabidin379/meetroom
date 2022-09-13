import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../services/auth.dart';
import '../shared/constants.dart';
import '../sharedScreens/home_screen.dart';

class DeleteSubject extends StatefulWidget {
  final String subjectCode;

  final String subjectName;
  const DeleteSubject({
    Key? key,
    required this.subjectCode,
    required this.subjectName,
  }) : super(key: key);

  @override
  State<DeleteSubject> createState() => _DeleteSubjectState();
}

class _DeleteSubjectState extends State<DeleteSubject> {
  final AuthService _auth = AuthService();
  bool loading = false;
  String? uid;
  @override
  void initState() {
    uid = _auth.getCurrentUser();
    super.initState();
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
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20),
            child: Center(
              child: Text('Delete Subject',
                  style: kBodyText.copyWith(
                      color: kWhite,
                      fontSize: 30,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: Text(
              "Are you sure to delete ${widget.subjectName}?",
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
                    .collection('subjects')
                    .doc(widget.subjectCode)
                    .delete()
                    .then((value) async {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .get()
                      .then((value) async {
                    for (var i = 0; i < value.docs.length; i++) {
                      FirebaseFirestore.instance
                          .collection('users')
                          .doc(value.docs[i]['uid'])
                          .collection('subjects')
                          .doc(widget.subjectCode)
                          .get()
                          .then((snapshot) {
                        if (snapshot.exists) {
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(value.docs[i]['uid'])
                              .collection('subjects')
                              .doc(widget.subjectCode)
                              .delete();
                        }
                      });
                    }
                  });
                  Get.offAll(() => const HomeScreen());
                  setState(() {});
                  Get.snackbar(
                    'Message',
                    'Subject ${widget.subjectName} deleted successfully',
                    duration: const Duration(seconds: 3),
                    backgroundColor: kPrimaryColor,
                    colorText: kWhite,
                    borderRadius: 10,
                  );
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
                          'Delete Subject',
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
