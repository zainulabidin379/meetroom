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
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class EditAssignment extends StatefulWidget {
  final String subjectCode;
  final String code;
  final String assignmentNo;
  final String marks;
  final String description;
  final Timestamp date;
  final String fileExtension;
  final bool attachmentUploaded;
  final bool isUploadable;
  const EditAssignment(
      {Key? key,
      required this.subjectCode,
      required this.code,
      required this.attachmentUploaded,
      required this.date,
      required this.description,
      required this.fileExtension,
      required this.marks,
      required this.isUploadable,
      required this.assignmentNo})
      : super(key: key);

  @override
  State<EditAssignment> createState() => _EditAssignmentState();
}

class _EditAssignmentState extends State<EditAssignment> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final assignmentNoController = TextEditingController();
  final marksController = TextEditingController();
  final dueDateController = TextEditingController();
  final descriptionController = TextEditingController();
  final attachmentController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  DateTime dateTime = DateTime.now();
  bool isUploadable = true;
  bool loading = false;
  bool attachment = false;
  late File _attachment;
  String fileUrl = '';
  String _fileExtension = '';
  bool attachmentUpdated = false;

  @override
  void initState() {
    assignmentNoController.text = widget.assignmentNo;
    marksController.text = widget.marks;
    descriptionController.text = widget.description;
    attachmentController.text = widget.code + widget.fileExtension;
    dueDateController.text =
        DateFormat('dd-MM-yyyy hh:mm a').format(widget.date.toDate());
    dateTime = widget.date.toDate();
    isUploadable = widget.isUploadable;
    attachment = widget.attachmentUploaded;
    super.initState();
  }

  Future pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

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
        FirebaseStorage.instance.ref().child('assignmentData/$fileName');
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
          Navigator.pop(context);
          Get.snackbar(
            'Message',
            'New Assignment added successfully',
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

  // Select for Date
  Future<DateTime> _selectDate(BuildContext context) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );
    if (selected != null && selected != selectedDate) {
      setState(() {
        selectedDate = selected;
      });
    }
    return selectedDate;
  }

// Select for Time
  Future<TimeOfDay> _selectTime(BuildContext context) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (selected != null && selected != selectedTime) {
      setState(() {
        selectedTime = selected;
      });
    }
    return selectedTime;
  }
  // select date time picker

  Future _selectDateTime(BuildContext context) async {
    final date = await _selectDate(context);
    // ignore: unnecessary_null_comparison
    if (date == null) return;

    // ignore: use_build_context_synchronously
    final time = await _selectTime(context);

    // ignore: unnecessary_null_comparison
    if (time == null) return;
    setState(() {
      dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      dueDateController.text =
          DateFormat('dd-MM-yyyy hh:mm a').format(dateTime);
    });
  }

  @override
  void dispose() {
    assignmentNoController.dispose();
    marksController.dispose();
    dueDateController.dispose();
    descriptionController.dispose();
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
                        child: Text('Update Assignment',
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
                        controller: assignmentNoController,
                        style: kBodyText.copyWith(color: kGrey),
                        cursorColor: kPrimaryColor,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 20),
                          hintText: 'Assignment No.',
                          hintStyle: kBodyText.copyWith(color: kGrey),
                          prefixIcon: Icon(
                            Icons.numbers,
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
                        validator: FieldValidator.required(
                            message: 'Assignment No. is Required'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20),
                      child: TextFormField(
                        controller: marksController,
                        style: kBodyText.copyWith(color: kGrey),
                        cursorColor: kPrimaryColor,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 20),
                          hintText: 'Total Marks',
                          hintStyle: kBodyText.copyWith(color: kGrey),
                          prefixIcon: Icon(
                            Icons.grade,
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
                        validator: FieldValidator.required(
                            message: 'Total marks are required'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20),
                      child: InkWell(
                        onTap: () {
                          _selectDateTime(context);
                        },
                        child: TextFormField(
                          controller: dueDateController,
                          style: kBodyText.copyWith(color: kGrey),
                          cursorColor: kPrimaryColor,
                          enabled: false,
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 20),
                            hintText: 'Choose Due Date',
                            hintStyle: kBodyText.copyWith(color: kGrey),
                            prefixIcon: Icon(
                              Icons.calendar_month,
                              color: kGrey,
                              size: 22,
                            ),
                            errorStyle: const TextStyle(
                              color: Colors.red,
                              fontSize: 16.0,
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              borderSide:
                                  const BorderSide(color: Colors.red, width: 1),
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
                              message: 'Due date is Required'),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20),
                      child: TextFormField(
                        controller: descriptionController,
                        style: kBodyText.copyWith(color: kGrey),
                        cursorColor: kPrimaryColor,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        maxLines: 3,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 20),
                          hintText: 'Description',
                          hintStyle: kBodyText.copyWith(color: kGrey),
                          prefixIcon: Icon(
                            Icons.description,
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
                              message: 'Description is Required'),
                          FieldValidator.minLength(3,
                              message: 'Please enter a valid description'),
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
                              'Upload Attachment',
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
                              'Allow File Submission',
                              style: kBodyText,
                            ),
                          ),
                          CupertinoSwitch(
                            activeColor: kPrimaryColor,
                            trackColor: kGrey.withOpacity(0.5),
                            value: isUploadable,
                            onChanged: (bool newValue) {
                              setState(() {
                                isUploadable = newValue;
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
                                'assignmentNo': assignmentNoController.text,
                                'dueDate': dateTime,
                                'description': descriptionController.text,
                                'fileSubmission': isUploadable,
                                'totalMarks': marksController.text,
                              }).then((value) async {
                                if (attachmentUpdated) {
                                  uploadFileToFirebase(context, widget.code);
                                } else {
                                  Navigator.pop(context);
                                  Get.snackbar(
                                    'Message',
                                    'Assignment updated successfully',
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
                                    'Update Assignment',
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
