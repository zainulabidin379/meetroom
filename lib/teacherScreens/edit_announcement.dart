import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:the_validator/the_validator.dart';
import '../shared/constants.dart';

class EditAnnouncement extends StatefulWidget {
  final String subjectCode;
  final String code;
  final String announcement;
  final bool attachment;
  final String attachmentUrl;
  final String fileExtension;
  const EditAnnouncement(
      {Key? key,
      required this.code,
      required this.subjectCode,
      required this.attachmentUrl,
      required this.announcement,
      required this.fileExtension,
      required this.attachment})
      : super(key: key);

  @override
  State<EditAnnouncement> createState() => _EditAnnouncementState();
}

class _EditAnnouncementState extends State<EditAnnouncement> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final announcementController = TextEditingController();
  final attachmentController = TextEditingController();
  bool loading = false;
  bool attachment = false;
  File _attachment = File('');
  String attachmentUrl = '';
  String _fileExtension = '';
  bool attachmentUpdated = false;
  @override
  void initState() {
    announcementController.text = widget.announcement;
    attachment = widget.attachment;
    attachmentUrl = widget.attachmentUrl;
    attachmentController.text = widget.code + widget.fileExtension;
    super.initState();
  }

  Future pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        attachmentUpdated = true;
        PlatformFile file = result.files.first;
        attachmentController.text = file.name;
        _attachment = File(result.files.single.path!);
      });
      getExtension();
    } else {
      // User canceled the picker
    }
  }

  getExtension() {
    final File file = File(_attachment.path);
    _fileExtension = extension(file.path);
  }

  Future uploadFileToFirebase(BuildContext context, String fileName) async {
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('quizData/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putFile(_attachment);
    try {
      uploadTask.whenComplete(() async {
        String fileUrl = await firebaseStorageRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('subjects')
            .doc(widget.subjectCode)
            .collection('data')
            .doc(fileName)
            .update({
          'attachment': fileUrl,
          'attachmentExtension': _fileExtension,
        }).then((value) {
          Navigator.pop(context);
          Get.snackbar(
            'Message',
            'Announcement updated successfully',
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

  @override
  void dispose() {
    announcementController.dispose();
    attachmentController.dispose();
    super.dispose();
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
              child: const Icon(Icons.arrow_back_ios)),
        ),
      ),
      body: GestureDetector(
        onTap: (() => FocusScope.of(context).unfocus()),
        child: SingleChildScrollView(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 30.0, left: 10, right: 10),
                      child: Center(
                        child: Text('Update Announcement',
                            textAlign: TextAlign.center,
                            style: kBodyText.copyWith(
                                color: kWhite,
                                fontSize: 30,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20),
                      child: TextFormField(
                        controller: announcementController,
                        style: kBodyText.copyWith(color: kGrey),
                        cursorColor: kPrimaryColor,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        maxLines: 3,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 20),
                          hintText: 'Announcement',
                          hintStyle: kBodyText.copyWith(color: kGrey),
                          prefixIcon: Icon(
                            Icons.announcement,
                            color: kGrey,
                            size: 22,
                          ),
                          errorStyle: const TextStyle(
                            fontSize: 16.0,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide:
                                BorderSide(color: kPrimaryColor, width: 1),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide(
                              color: kGrey,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide(
                              color: kGrey,
                              width: 1,
                            ),
                          ),
                        ),
                        validator: FieldValidator.multiple([
                          FieldValidator.required(
                              message: 'Announcement is Required'),
                          FieldValidator.minLength(3,
                              message: 'Please enter a valid Announcement'),
                        ]),
                      ),
                    ),
                    Visibility(
                      visible: attachment,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20),
                        child: InkWell(
                          onTap: () {
                            pickFile();
                          },
                          child: TextFormField(
                            controller: attachmentController,
                            style: kBodyText.copyWith(color: kGrey),
                            cursorColor: kPrimaryColor,
                            enabled: false,
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 20),
                              hintText: 'Choose Attachment',
                              hintStyle: kBodyText.copyWith(color: kGrey),
                              prefixIcon: Icon(
                                Icons.attachment,
                                color: kGrey,
                                size: 22,
                              ),
                              errorStyle: const TextStyle(
                                color: Colors.red,
                                fontSize: 16.0,
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: const BorderSide(
                                    color: Colors.red, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide:
                                    BorderSide(color: kPrimaryColor, width: 1),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: BorderSide(
                                  color: kGrey,
                                  width: 1,
                                ),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: BorderSide(
                                  color: kGrey,
                                  width: 1,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                borderSide: BorderSide(
                                  color: kGrey,
                                  width: 1,
                                ),
                              ),
                            ),
                            validator: FieldValidator.required(
                                message: 'Please upload Attachment'),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      height: 60,
                      color: kBlack,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Update Attachment',
                              style: kBodyText,
                            ),
                          ),
                          CupertinoSwitch(
                            activeColor: kPrimaryColor,
                            trackColor: kGrey.withOpacity(0.5),
                            value: attachment,
                            onChanged: (bool newValue) {
                              setState(() {
                                attachment = newValue;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: InkWell(
                        onTap: () async {
                          FocusScope.of(context).unfocus();
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              loading = true;
                            });
                            try {
                              await FirebaseFirestore.instance
                                  .collection('subjects')
                                  .doc(widget.subjectCode)
                                  .collection('data')
                                  .doc(widget.code)
                                  .update({
                                'attachmentUploaded': attachment,
                                'announcement': announcementController.text,
                              }).then((value) async {
                                if (attachmentUpdated) {
                                  uploadFileToFirebase(context, widget.code);
                                } else {
                                  Navigator.pop(context);
                                  Get.snackbar(
                                    'Message',
                                    'Announcement Updated successfully',
                                    duration: const Duration(seconds: 3),
                                    backgroundColor: kPrimaryColor,
                                    colorText: kWhite,
                                    borderRadius: 10,
                                  );
                                }
                              });
                            } on FirebaseException {
                              setState(() {
                                loading = false;
                              });
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
                                    'Update Announcement',
                                    style: kBodyText.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: kWhite),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 35,
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
