import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:the_validator/the_validator.dart';
import '../shared/constants.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class EditAttendance extends StatefulWidget {
  final String subjectCode;
  final String code;
  final Timestamp date;
  final String message;
  const EditAttendance(
      {Key? key,
      required this.subjectCode,
      required this.code,
      required this.date,
      required this.message})
      : super(key: key);

  @override
  State<EditAttendance> createState() => _EditAttendanceState();
}

class _EditAttendanceState extends State<EditAttendance> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final messageController = TextEditingController();
  final dueDateController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  DateTime dateTime = DateTime.now();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    messageController.text = widget.message;
    dueDateController.text =
        DateFormat('dd-MM-yyyy hh:mm a').format(widget.date.toDate());
    dateTime = widget.date.toDate();
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
    messageController.dispose();
    dueDateController.dispose();
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
                        child: Text('Update Attendance',
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
                            hintText: 'Attendance Active Time',
                            hintStyle: kBodyText.copyWith(color: kGrey),
                            prefixIcon: Icon(
                              Icons.timer,
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
                              message: 'Attendance expiry date is Required'),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20),
                      child: TextFormField(
                        controller: messageController,
                        style: kBodyText.copyWith(color: kGrey),
                        cursorColor: kPrimaryColor,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        maxLines: 3,
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 20),
                          hintText: 'Message',
                          hintStyle: kBodyText.copyWith(color: kGrey),
                          prefixIcon: Icon(
                            Icons.message,
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
                              message: 'Message is Required'),
                          FieldValidator.minLength(3,
                              message: 'Please enter a valid Message'),
                        ]),
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
                                'dueTime': dateTime,
                                'message': messageController.text,
                              }).then((value) async {
                                Navigator.pop(context);
                                Get.snackbar(
                                  'Message',
                                  'Attendance updated successfully',
                                  duration: const Duration(seconds: 3),
                                  backgroundColor: kPrimaryColor,
                                  colorText: kWhite,
                                  borderRadius: 10,
                                );
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
                                    'Update Attendance',
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
