import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import '../shared/constants.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import '../shared/download_file.dart';

class ViewAssignmentRecord extends StatefulWidget {
  final String subjectCode;
  final String assignmentCode;
  final String assignmentNo;
  final String totalMarks;
  final Timestamp date;
  const ViewAssignmentRecord(
      {Key? key,
      required this.assignmentCode,
      required this.subjectCode,
      required this.assignmentNo,
      required this.totalMarks,
      required this.date})
      : super(key: key);

  @override
  State<ViewAssignmentRecord> createState() => _ViewAssignmentRecordState();
}

class _ViewAssignmentRecordState extends State<ViewAssignmentRecord> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final marksController = TextEditingController();

  @override
  void dispose() {
    marksController.dispose();
    super.dispose();
  }

  Future getAssignmentUploads() async {
    var firestore = FirebaseFirestore.instance;
    QuerySnapshot qn = await firestore
        .collection('subjects')
        .doc(widget.subjectCode)
        .collection('data')
        .doc(widget.assignmentCode)
        .collection('assignments')
        .orderBy('timestamp', descending: false)
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
          child: Column(children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20),
              child: Center(
                child: Text('Assignment ${widget.assignmentNo} Uploads',
                    textAlign: TextAlign.center,
                    style: kBodyText.copyWith(
                        color: kWhite,
                        fontSize: 27,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 3.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Due Date: ',
                    style: kBodyText.copyWith(color: kGrey, fontSize: 13),
                  ),
                  Text(
                    DateFormat('dd-MM-yyyy hh:mm a')
                        .format(widget.date.toDate()),
                    style: kBodyText.copyWith(
                        color: kGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Total Marks: ',
                    style: kBodyText.copyWith(color: kGrey, fontSize: 13),
                  ),
                  Text(
                    widget.totalMarks.toString(),
                    style: kBodyText.copyWith(
                        color: kGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ],
              ),
            ),
            FutureBuilder<dynamic>(
                future: getAssignmentUploads(),
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
                          for (var i = 0; i < snapshot.data.length; i++) ...{
                            studentCard(
                              size,
                              snapshot.data[i]['uid'],
                              snapshot.data[i]['name'],
                              snapshot.data[i]['rollNo'],
                              snapshot.data[i]['attachment'],
                              snapshot.data[i]['attachmentExtension'],
                              snapshot.data[i]['checked'],
                            )
                          }
                        ] else ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
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
                                    "0 uploads found!",
                                    textAlign: TextAlign.center,
                                    style: kBodyText.copyWith(fontSize: 15),
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
            const SizedBox(
              height: 20,
            )
          ]),
        ),
      ),
    );
  }

  Widget studentCard(Size size, String uid, String name, String rollNo,
      String attachment, String attachmentExtension, bool checked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          width: size.width * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.primaries[Random().nextInt(Colors.primaries.length)]
                .withOpacity(0.3),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: kBodyText.copyWith(color: kGrey, fontSize: 15),
                        ),
                        Text(
                          rollNo,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: kBodyText.copyWith(
                            fontSize: 18,
                          ),
                        ),
                      ]),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        if (await Permission.storage.request().isGranted) {
                          if (await File(
                                  '/storage/emulated/0/Download/$uid$attachmentExtension')
                              .exists()) {
                            OpenFile.open(
                                '/storage/emulated/0/Download/$uid$attachmentExtension');
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) => DownloadingDialog(
                                  url: attachment,
                                  fileName: '$uid$attachmentExtension',
                                  path:
                                      "/storage/emulated/0/Download/$uid$attachmentExtension"),
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
                        width: 65,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.zero),
                          color: kGrey.withOpacity(0.5),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.attachment,
                            color: kWhite,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.defaultDialog(
                          title: 'Update Marks',
                          titleStyle:
                              kBodyText.copyWith(fontWeight: FontWeight.bold),
                          backgroundColor: kBlack,
                          barrierDismissible: false,
                          content: Padding(
                            padding: const EdgeInsets.only(bottom: 30),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //Marks
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 20),
                                    child: TextFormField(
                                        controller: marksController,
                                        style: kBodyText,
                                        cursorColor: kPrimaryColor,
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.done,
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 20),
                                          hintText: 'Earned Marks',
                                          hintStyle:
                                              kBodyText.copyWith(color: kGrey),
                                          prefixIcon: Icon(
                                            Icons.numbers,
                                            color: kGrey,
                                            size: 25,
                                          ),
                                          errorStyle: const TextStyle(
                                            fontSize: 16.0,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                            borderSide: BorderSide(
                                                color: kPrimaryColor, width: 1),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                            borderSide: BorderSide(
                                              color: kGrey,
                                              width: 1,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                            borderSide: BorderSide(
                                              color: kGrey,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        validator: (val) {
                                          if (val!.isEmpty) {
                                            return 'Marks are required';
                                          }
                                          if (int.parse(val) >
                                              int.parse(widget.totalMarks)) {
                                            return 'Please enter valid marks';
                                          }
                                          return null;
                                        }),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          titlePadding:
                              const EdgeInsets.symmetric(vertical: 20),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 20),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text('Cancel',
                                  style: kBodyText.copyWith(
                                      fontWeight: FontWeight.bold)),
                            ),
                            TextButton(
                              onPressed: () async {
                                FocusScope.of(context).unfocus();
                                if (_formKey.currentState!.validate()) {
                                  Get.defaultDialog(
                                    title: '',
                                    backgroundColor: Colors.transparent,
                                    barrierDismissible: false,
                                    content: SpinKitCircle(
                                      color: kPrimaryColor,
                                      size: 50.0,
                                    ),
                                  );
                                  try {
                                    await FirebaseFirestore.instance
                                        .collection('subjects')
                                        .doc(widget.subjectCode)
                                        .collection('data')
                                        .doc(widget.assignmentCode)
                                        .collection('assignments')
                                        .doc(uid)
                                        .update({
                                      'givenMarks': marksController.text,
                                      'checked': true,
                                    }).then((value) async {
                                      Get.back();
                                      Get.back();
                                      Get.snackbar(
                                        'Message',
                                        'Marks Updated successfully',
                                        duration: const Duration(seconds: 3),
                                        backgroundColor: kPrimaryColor,
                                        colorText: kWhite,
                                        borderRadius: 10,
                                      );
                                      marksController.clear();
                                    });
                                  } on FirebaseException {
                                    Get.back();
                                    Get.back();
                                    Get.snackbar(
                                      'Error',
                                      'Error occurred please try again',
                                      duration: const Duration(seconds: 3),
                                      backgroundColor: kRed,
                                      colorText: kWhite,
                                      borderRadius: 10,
                                    );
                                  }
                                }
                              },
                              child: Text('Update',
                                  style: kBodyText.copyWith(
                                      color: kPrimaryColor,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        );
                      },
                      child: Container(
                        width: 65,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.zero,
                            topRight: Radius.circular(12),
                            bottomLeft: Radius.zero,
                            bottomRight: Radius.circular(12),
                          ),
                          color: kPrimaryColor,
                        ),
                        child: Center(
                          child: checked
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.done_all,
                                      color: kWhite,
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    StreamBuilder<dynamic>(
                                        stream: FirebaseFirestore.instance
                                            .collection('subjects')
                                            .doc(widget.subjectCode)
                                            .collection('data')
                                            .doc(widget.assignmentCode)
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
                                            return Text(
                                              "${snapshot.data['givenMarks'].toString()}/${widget.totalMarks}",
                                              style: kBodyText.copyWith(
                                                  fontSize: 13,
                                                  color:
                                                      kWhite.withOpacity(0.8)),
                                            );
                                          }
                                        }),
                                  ],
                                )
                              : Icon(
                                  Icons.done,
                                  color: kWhite,
                                ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
